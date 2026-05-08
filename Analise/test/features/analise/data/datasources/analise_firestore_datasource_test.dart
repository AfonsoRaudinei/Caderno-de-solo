import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloforte/data/datasources/remote/analise_firestore_datasource.dart';
import 'package:soloforte/features/analise/data/models/analise_solo_model.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late AnaliseFirestoreDatasource datasource;

  final analiseMock = AnaliseSoloModel(
    id: 'test-1',
    userId: 'uid-test',
    fazenda: 'Fazenda X',
    produtor: 'Produtor X',
    talhao: 'T01',
    numeroAmostra: '01',
    cultura: Cultura.soja,
    safra: '2025',
    laboratorio: 'Sellar',
    dataCadastro: DateTime.now(),
    profundidade: '0-20',
  );

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth(signedIn: true);
    datasource = AnaliseFirestoreDatasource(
      firestore: fakeFirestore,
      auth: mockAuth,
      preferAtomic: true,
    );
  });

  group('AnaliseFirestoreDatasource - saveAnalisesBatch', () {
    test('falha se nao autenticado', () async {
      mockAuth = MockFirebaseAuth(signedIn: false);
      datasource = AnaliseFirestoreDatasource(
        firestore: fakeFirestore,
        auth: mockAuth,
      );

      expect(
        () => datasource.saveAnalisesBatch([analiseMock]),
        throwsA(isA<SaveBatchException>().having(
          (e) => e.code,
          'code',
          SaveBatchCode.saveAtomicFailed,
        )),
      );
    });

    test('salva 1 analise com sucesso usando strategy atomic', () async {
      final res = await datasource.saveAnalisesBatch([analiseMock]);
      
      expect(res.status, SaveBatchStatus.committed);
      expect(res.strategy, SaveStrategy.atomic);
      expect(res.savedCount, 1);

      final snapshot = await fakeFirestore.collection('analises').get();
      expect(snapshot.docs.length, 1);
      final data = snapshot.docs.first.data();
      expect(data['userId'], mockAuth.currentUser?.uid);
      expect(data['talhao'], 'T01');
      expect(data['persistStatus'], SaveBatchStatus.committed.name);
      
      final batchSnap = await fakeFirestore.collection('analise_save_batches').doc('${mockAuth.currentUser?.uid}:${res.idempotencyKey}').get();
      expect(batchSnap.exists, isTrue);
      expect(batchSnap.data()?['status'], SaveBatchStatus.committed.name);
    });

    test('salva com strategy compensating e sucesso', () async {
      datasource = AnaliseFirestoreDatasource(
        firestore: fakeFirestore,
        auth: mockAuth,
        preferAtomic: false,
      );

      final res = await datasource.saveAnalisesBatch([analiseMock]);
      
      expect(res.status, SaveBatchStatus.committed);
      expect(res.strategy, SaveStrategy.compensating);
      expect(res.savedCount, 1);

      final snapshot = await fakeFirestore.collection('analises').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['persistStatus'], SaveBatchStatus.committed.name);
    });

    test('recoverPendingBatches compensa batches presos em persisting', () async {
      final uid = mockAuth.currentUser!.uid;
      const idempotencyKey = 'key-preso';
      const batchId = 'batch-preso';

      // Criar mock preso
      await fakeFirestore.collection('analise_save_batches').doc('$uid:$idempotencyKey').set({
        'batchId': batchId,
        'userId': uid,
        'status': SaveBatchStatus.persisting.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await fakeFirestore.collection('analises').doc('A02').set({
        'userId': uid,
        'saveBatchId': batchId,
        'persistStatus': SaveBatchStatus.persisting.name,
      });

      // Simular delay antigo para mock updatedAt
      final now = DateTime.now();
      await fakeFirestore.collection('analise_save_batches').doc('$uid:$idempotencyKey').update({
        'updatedAt': Timestamp.fromDate(now.subtract(const Duration(minutes: 15))),
      });

      await datasource.recoverPendingBatches();

      final batchSnap = await fakeFirestore.collection('analise_save_batches').doc('$uid:$idempotencyKey').get();
      expect(batchSnap.data()?['status'], SaveBatchStatus.compensated.name);

      final snap = await fakeFirestore.collection('analises').doc('A02').get();
      expect(snap.data()?['persistStatus'], SaveBatchStatus.compensated.name);
    });
  });

  group('AnaliseFirestoreDatasource - watchAnalises', () {
    test('reativa stream quando auth muda de null para usuário logado', () async {
      final auth = _MockAuth();
      final user = _MockUser();
      final authController = StreamController<User?>.broadcast();
      User? currentUser;

      when(() => user.uid).thenReturn('uid-watch-1');
      when(() => auth.currentUser).thenAnswer((_) => currentUser);
      when(() => auth.authStateChanges())
          .thenAnswer((_) => authController.stream);

      final firestore = FakeFirebaseFirestore();
      final data = analiseMock.toJson()
        ..['userId'] = 'uid-watch-1'
        ..['persistStatus'] = SaveBatchStatus.committed.name;
      await firestore.collection('analises').doc('watch-1').set(data);

      final ds = AnaliseFirestoreDatasource(
        firestore: firestore,
        auth: auth,
      );

      final values = <List<AnaliseSoloModel>>[];
      final sub = ds.watchAnalises(userId: 'uid-watch-1').listen(values.add);

      authController.add(null);
      await Future<void>.delayed(const Duration(milliseconds: 25));
      expect(values, isNotEmpty);
      expect(values.last, isEmpty);

      currentUser = user;
      authController.add(user);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(values.last.length, 1);
      expect(values.last.first.talhao, analiseMock.talhao);

      await sub.cancel();
      await authController.close();
    });

    test('volta para vazio ao receber logout no authStateChanges', () async {
      final auth = _MockAuth();
      final user = _MockUser();
      final authController = StreamController<User?>.broadcast();
      User? currentUser;

      when(() => user.uid).thenReturn('uid-watch-2');
      when(() => auth.currentUser).thenAnswer((_) => currentUser);
      when(() => auth.authStateChanges())
          .thenAnswer((_) => authController.stream);

      final firestore = FakeFirebaseFirestore();
      final data = analiseMock.toJson()
        ..['userId'] = 'uid-watch-2'
        ..['persistStatus'] = SaveBatchStatus.committed.name;
      await firestore.collection('analises').doc('watch-2').set(data);

      final ds = AnaliseFirestoreDatasource(
        firestore: firestore,
        auth: auth,
      );

      final values = <List<AnaliseSoloModel>>[];
      final sub = ds.watchAnalises(userId: 'uid-watch-2').listen(values.add);

      currentUser = user;
      authController.add(user);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(values.last.length, 1);

      currentUser = null;
      authController.add(null);
      await Future<void>.delayed(const Duration(milliseconds: 25));
      expect(values.last, isEmpty);

      await sub.cancel();
      await authController.close();
    });
  });
}
