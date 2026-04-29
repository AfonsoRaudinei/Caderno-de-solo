import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:soloforte/features/analise/data/datasources/analise_datasource.dart';
import 'package:soloforte/features/analise/data/models/analise_solo_model.dart';
import 'package:soloforte/features/analise/data/models/produtor_model.dart';
import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';

class AnaliseFirestoreDatasource implements AnaliseDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final bool _preferAtomic;
  late final CollectionReference<Map<String, dynamic>> _collection;
  late final CollectionReference<Map<String, dynamic>> _batchCollection;

  AnaliseFirestoreDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    bool preferAtomic = true,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _preferAtomic = preferAtomic {
    _collection = _firestore.collection('analises');
    _batchCollection = _firestore.collection('analise_save_batches');
  }

  Future<void> addAnalise(Map<String, dynamic> data) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();
      await _collection.add(data);
    } catch (e) {
      throw Exception('Erro ao adicionar análise: $e');
    }
  }

  Future<void> updateAnalise(String id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _collection.doc(id).update(data);
    } catch (e) {
      throw Exception('Erro ao atualizar análise: $e');
    }
  }

  @override
  Future<void> deleteAnalise(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar análise: $e');
    }
  }

  @override
  Future<List<AnaliseSoloModel>> getAnalises() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return [];

      await recoverPendingBatches();

      final querySnapshot =
          await _collection.where('userId', isEqualTo: uid).get();
      return _toCommittedAnalises(querySnapshot.docs);
    } catch (e) {
      throw Exception('Erro ao listar análises: $e');
    }
  }

  @override
  Stream<List<AnaliseSoloModel>> watchAnalises() {
    final controller = StreamController<List<AnaliseSoloModel>>();
    StreamSubscription<User?>? authSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? querySub;
    Future<void> bindQueue = Future.value();

    void emit(List<AnaliseSoloModel> value) {
      if (!controller.isClosed) controller.add(value);
    }

    void emitError(Object error, [StackTrace? stackTrace]) {
      debugPrint('AnaliseFirestoreDatasource erro Firestore: $error');
      if (!controller.isClosed) controller.addError(error, stackTrace);
    }

    Future<void> bindUser(User? user) async {
      await querySub?.cancel();
      querySub = null;

      final uid = user?.uid;
      if (uid == null) {
        emit(const <AnaliseSoloModel>[]);
        return;
      }

      // Dispara recover pendente fire-and-forget
      recoverPendingBatches().catchError((_) {});

      querySub = _collection.where('userId', isEqualTo: uid).snapshots().listen(
        (snapshot) {
          emit(_toCommittedAnalises(snapshot.docs));
        },
        onError: emitError,
      );
    }

    authSub = _auth.authStateChanges().listen(
          (user) {
            bindQueue = bindQueue.then((_) => bindUser(user));
          },
          onError: emitError,
          onDone: () async {
            await bindQueue;
            await querySub?.cancel();
            await controller.close();
          },
        );

    controller.onCancel = () async {
      await authSub?.cancel();
      await querySub?.cancel();
    };

    return controller.stream;
  }

  List<AnaliseSoloModel> _toCommittedAnalises(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final list = docs.where((doc) {
      final status = doc.data()['persistStatus'] as String?;
      return status == null || status == SaveBatchStatus.committed.name;
    }).map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AnaliseSoloModel.fromJson(data);
    }).toList(growable: false);

    list.sort((a, b) => b.dataCadastro.compareTo(a.dataCadastro));
    return list;
  }

  @override
  Future<void> saveAnalise(AnaliseSoloModel analise) async {
    await saveAnalisesBatch([analise]);
  }

  @override
  Future<SaveBatchResult> saveAnalisesBatch(
      List<AnaliseSoloModel> analises) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const SaveBatchException(
        code: SaveBatchCode.saveAtomicFailed,
        message: 'Sessão expirada. Usuário não autenticado.',
      );
    }
    if (analises.isEmpty) {
      final batchId = _newBatchId();
      return SaveBatchResult(
        batchId: batchId,
        idempotencyKey: 'empty',
        status: SaveBatchStatus.committed,
        strategy:
            _preferAtomic ? SaveStrategy.atomic : SaveStrategy.compensating,
        savedCount: 0,
        isReplay: false,
      );
    }

    final payloads = analises.map((a) => a.toJson()).toList(growable: false);
    final idempotencyKey = SaveBatchIdempotency.build(
      userId: uid,
      payloads: payloads,
      context: 'analise_batch_save',
    );
    final batchDocId = '$uid:$idempotencyKey';
    final batchRef = _batchCollection.doc(batchDocId);

    final replay = await _readReplayIfAny(batchRef, idempotencyKey);
    if (replay != null) return replay;

    final strategy =
        _preferAtomic ? SaveStrategy.atomic : SaveStrategy.compensating;
    final batchId = _newBatchId();
    final startedAt = DateTime.now();

    _logBatch(
      stage: 'start',
      batchId: batchId,
      idempotencyKey: idempotencyKey,
      strategy: strategy,
      payload: {'count': analises.length},
    );

    try {
      final result = switch (strategy) {
        SaveStrategy.atomic => await _saveAtomic(
            uid: uid,
            analises: analises,
            batchRef: batchRef,
            batchId: batchId,
            idempotencyKey: idempotencyKey,
          ),
        SaveStrategy.compensating => await _saveCompensating(
            uid: uid,
            analises: analises,
            batchRef: batchRef,
            batchId: batchId,
            idempotencyKey: idempotencyKey,
          ),
      };

      _logBatch(
        stage: 'done',
        batchId: batchId,
        idempotencyKey: idempotencyKey,
        strategy: strategy,
        payload: {
          'status': result.status.name,
          'savedCount': result.savedCount,
          'durationMs': DateTime.now().difference(startedAt).inMilliseconds,
        },
      );
      return result;
    } on SaveBatchException {
      rethrow;
    } on FirebaseException catch (e) {
      throw SaveBatchException(
        code: SaveBatchCode.saveAtomicFailed,
        message: 'Erro Firestore (${e.code}): ${e.message}',
        batchId: batchId,
        idempotencyKey: idempotencyKey,
        cause: e,
      );
    } catch (e) {
      throw SaveBatchException(
        code: SaveBatchCode.saveAtomicFailed,
        message: 'Erro ao salvar lote: $e',
        batchId: batchId,
        idempotencyKey: idempotencyKey,
        cause: e,
      );
    }
  }

  Future<SaveBatchResult> _saveAtomic({
    required String uid,
    required List<AnaliseSoloModel> analises,
    required DocumentReference<Map<String, dynamic>> batchRef,
    required String batchId,
    required String idempotencyKey,
  }) async {
    final analiseIds = analises.map((a) => a.id).toList(growable: false);
    await _firestore.runTransaction((tx) async {
      final batchSnap = await tx.get(batchRef);
      final status = batchSnap.data()?['status'] as String?;
      if (status == SaveBatchStatus.committed.name) {
        throw const SaveBatchException(
          code: SaveBatchCode.saveIdempotentReplay,
          message: 'Reenvio idempotente detectado.',
        );
      }
      if (status == SaveBatchStatus.persisting.name ||
          status == SaveBatchStatus.received.name ||
          status == SaveBatchStatus.validating.name) {
        throw const SaveBatchException(
          code: SaveBatchCode.saveInProgress,
          message: 'Lote já está em processamento.',
        );
      }

      final previousAttempt =
          (batchSnap.data()?['attempt'] as num?)?.toInt() ?? 0;
      final createdAt =
          batchSnap.data()?['createdAt'] ?? FieldValue.serverTimestamp();

      final analisesSnaps = <DocumentSnapshot>[];
      for (var i = 0; i < analises.length; i++) {
        final ref = _collection.doc(analises[i].id);
        analisesSnaps.add(await tx.get(ref));
      }

      tx.set(
          batchRef,
          {
            'batchId': batchId,
            'idempotencyKey': idempotencyKey,
            'userId': uid,
            'status': SaveBatchStatus.persisting.name,
            'strategy': SaveStrategy.atomic.name,
            'attempt': previousAttempt + 1,
            'createdAt': createdAt,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      for (var i = 0; i < analises.length; i++) {
        final model = analises[i];
        final ref = _collection.doc(model.id);
        final snap = analisesSnaps[i];
        final payload = <String, dynamic>{
          ...model.toJson(),
          'userId': uid,
          'columnRef': 'A${i + 1}',
          'saveBatchId': batchId,
          'idempotencyKey': idempotencyKey,
          'persistStatus': SaveBatchStatus.committed.name,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (!snap.exists) {
          payload['createdAt'] = FieldValue.serverTimestamp();
        }
        tx.set(ref, payload, SetOptions(merge: true));
      }

      tx.set(
          batchRef,
          {
            'status': SaveBatchStatus.committed.name,
            'resultAnaliseIds': analiseIds,
            'committedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    });

    return SaveBatchResult(
      batchId: batchId,
      idempotencyKey: idempotencyKey,
      status: SaveBatchStatus.committed,
      strategy: SaveStrategy.atomic,
      savedCount: analiseIds.length,
      isReplay: false,
    );
  }

  Future<SaveBatchResult> _saveCompensating({
    required String uid,
    required List<AnaliseSoloModel> analises,
    required DocumentReference<Map<String, dynamic>> batchRef,
    required String batchId,
    required String idempotencyKey,
  }) async {
    final now = FieldValue.serverTimestamp();
    final ids = analises.map((a) => a.id).toList(growable: false);
    try {
      final batchSnap = await batchRef.get();
      final previousAttempt =
          (batchSnap.data()?['attempt'] as num?)?.toInt() ?? 0;
      await batchRef.set({
        'batchId': batchId,
        'idempotencyKey': idempotencyKey,
        'userId': uid,
        'status': SaveBatchStatus.persisting.name,
        'strategy': SaveStrategy.compensating.name,
        'attempt': previousAttempt + 1,
        'createdAt': batchSnap.data()?['createdAt'] ?? now,
        'updatedAt': now,
      }, SetOptions(merge: true));

      final pendingWrite = _firestore.batch();
      for (var i = 0; i < analises.length; i++) {
        final model = analises[i];
        final ref = _collection.doc(model.id);
        pendingWrite.set(
          ref,
          {
            ...model.toJson(),
            'userId': uid,
            'columnRef': 'A${i + 1}',
            'saveBatchId': batchId,
            'idempotencyKey': idempotencyKey,
            'persistStatus': SaveBatchStatus.persisting.name,
            'updatedAt': now,
          },
          SetOptions(merge: true),
        );
      }
      await pendingWrite.commit();

      final commitWrite = _firestore.batch();
      for (final id in ids) {
        commitWrite.set(
          _collection.doc(id),
          {
            'persistStatus': SaveBatchStatus.committed.name,
            'updatedAt': now,
          },
          SetOptions(merge: true),
        );
      }
      commitWrite.set(
        batchRef,
        {
          'status': SaveBatchStatus.committed.name,
          'resultAnaliseIds': ids,
          'committedAt': now,
          'updatedAt': now,
        },
        SetOptions(merge: true),
      );
      await commitWrite.commit();

      return SaveBatchResult(
        batchId: batchId,
        idempotencyKey: idempotencyKey,
        status: SaveBatchStatus.committed,
        strategy: SaveStrategy.compensating,
        savedCount: ids.length,
        isReplay: false,
      );
    } catch (e) {
      await _compensateBatch(
        uid: uid,
        batchRef: batchRef,
        batchId: batchId,
        idempotencyKey: idempotencyKey,
        reason: e.toString(),
      );
      throw SaveBatchException(
        code: SaveBatchCode.saveCompensated,
        message:
            'Falha na persistência com compensação aplicada. Nenhum estado parcial foi exposto.',
        batchId: batchId,
        idempotencyKey: idempotencyKey,
        cause: e,
      );
    }
  }

  Future<void> _compensateBatch({
    required String uid,
    required DocumentReference<Map<String, dynamic>> batchRef,
    required String batchId,
    required String idempotencyKey,
    required String reason,
  }) async {
    final pending = await _collection
        .where('userId', isEqualTo: uid)
        .where('saveBatchId', isEqualTo: batchId)
        .where('persistStatus', isEqualTo: SaveBatchStatus.persisting.name)
        .get();

    final write = _firestore.batch();
    for (final doc in pending.docs) {
      write.set(
        doc.reference,
        {
          'persistStatus': SaveBatchStatus.compensated.name,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    write.set(
      batchRef,
      {
        'status': SaveBatchStatus.compensated.name,
        'lastError': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await write.commit();

    _logBatch(
      stage: 'compensate',
      batchId: batchId,
      idempotencyKey: idempotencyKey,
      strategy: SaveStrategy.compensating,
      payload: {'reason': reason, 'pendingDocs': pending.docs.length},
    );
  }

  Future<SaveBatchResult?> _readReplayIfAny(
    DocumentReference<Map<String, dynamic>> batchRef,
    String idempotencyKey,
  ) async {
    final snap = await batchRef.get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    final status = data['status'] as String?;
    final strategyRaw = data['strategy'] as String?;
    final strategy = strategyRaw == SaveStrategy.compensating.name
        ? SaveStrategy.compensating
        : SaveStrategy.atomic;
    final batchId = (data['batchId'] as String?) ?? _newBatchId();
    final resultIds = (data['resultAnaliseIds'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList(growable: false);

    if (status == SaveBatchStatus.committed.name) {
      return SaveBatchResult(
        batchId: batchId,
        idempotencyKey: idempotencyKey,
        status: SaveBatchStatus.committed,
        strategy: strategy,
        savedCount: resultIds.length,
        isReplay: true,
        code: SaveBatchCode.saveIdempotentReplay,
      );
    }
    if (status == SaveBatchStatus.persisting.name ||
        status == SaveBatchStatus.received.name ||
        status == SaveBatchStatus.validating.name) {
      throw SaveBatchException(
        code: SaveBatchCode.saveInProgress,
        message: 'Lote já está em processamento.',
        batchId: batchId,
        idempotencyKey: idempotencyKey,
      );
    }
    return null;
  }

  @override
  Future<void> recoverPendingBatches({
    Duration timeout = const Duration(minutes: 10),
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final query = await _batchCollection
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: SaveBatchStatus.persisting.name)
        .get();
    if (query.docs.isEmpty) return;

    final now = DateTime.now();
    for (final doc in query.docs) {
      final data = doc.data();
      final updatedAtTs = data['updatedAt'];
      final updatedAt = updatedAtTs is Timestamp
          ? updatedAtTs.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0);
      if (now.difference(updatedAt) < timeout) continue;

      final batchId = (data['batchId'] as String?) ?? '';
      final strategy =
          (data['strategy'] as String?) ?? SaveStrategy.compensating.name;
      const reason = 'Recovery automático após timeout de persisting.';

      if (strategy == SaveStrategy.atomic.name) {
        await doc.reference.set(
          {
            'status': SaveBatchStatus.failed.name,
            'lastError': reason,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        continue;
      }

      await _compensateBatch(
        uid: uid,
        batchRef: doc.reference,
        batchId: batchId,
        idempotencyKey: (data['idempotencyKey'] as String?) ?? '',
        reason: reason,
      );
    }
  }

  @override
  Future<List<ProdutorModel>> getProdutores() async {
    final analises = await getAnalises();
    final Map<String, ProdutorModel> map = {};
    for (final a in analises) {
      if (a.produtor.isEmpty) continue;
      final key = '${a.produtor}_${a.fazenda}';
      if (map.containsKey(key)) {
        final existing = map[key]!;
        map[key] = ProdutorModel(
          id: existing.id,
          nome: existing.nome,
          fazenda: existing.fazenda,
          totalAnalises: existing.totalAnalises + 1,
        );
      } else {
        map[key] = ProdutorModel(
          id: key,
          nome: a.produtor,
          fazenda: a.fazenda,
          totalAnalises: 1,
        );
      }
    }
    final list = map.values.toList();
    list.sort((a, b) => a.nome.compareTo(b.nome));
    return list;
  }

  Future<Map<String, dynamic>?> getAnalise(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar análise: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAnalisesByUser(String userId) async {
    try {
      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.where((doc) {
        final status = doc.data()['persistStatus'] as String?;
        return status == null || status == SaveBatchStatus.committed.name;
      }).map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Erro ao listar análises: $e');
    }
  }

  String _newBatchId() {
    return 'batch-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _logBatch({
    required String stage,
    required String batchId,
    required String idempotencyKey,
    required SaveStrategy strategy,
    Map<String, dynamic>? payload,
  }) {
    final log = {
      'scope': 'analise.batch',
      'stage': stage,
      'batchId': batchId,
      'idempotencyKey': idempotencyKey,
      'strategy': strategy.name,
      'payload': payload ?? const <String, dynamic>{},
    };
    debugPrint(jsonEncode(log));
  }
}
