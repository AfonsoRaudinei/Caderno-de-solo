import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/clientes/data/datasources/cliente_firestore_datasource.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';

void main() {
  group('ClienteFirestoreDatasource.criarCliente', () {
    test('salva cliente e registra token em cliente_tokens', () async {
      final firestore = FakeFirebaseFirestore();
      final datasource = ClienteFirestoreDatasource(firestore: firestore);
      final now = DateTime(2026, 7, 24);

      final id = await datasource.criarCliente(
        ClienteEntity(
          id: '',
          token: 'SF-2026-TEST',
          nome: 'Produtor Sem Contato',
          telefone: '',
          email: '',
          cidade: 'Palmas',
          estado: 'TO',
          usuarioId: 'user-1',
          criadoEm: now,
          atualizadoEm: now,
        ),
      );

      expect(id, isNotEmpty);
      final snap = await firestore.collection('clientes').doc(id).get();
      expect(snap.exists, isTrue);
      expect(snap.data()?['nome'], 'Produtor Sem Contato');
      expect(snap.data()?['telefone'], '');
      expect(snap.data()?['email'], '');
      expect(snap.data()?['token'], 'SF-2026-TEST');
      expect(snap.data()?['usuarioId'], 'user-1');

      final tokenSnap = await firestore
          .collection('cliente_tokens')
          .doc('SF-2026-TEST')
          .get();
      expect(tokenSnap.exists, isTrue);
      expect(tokenSnap.data()?['clienteId'], id);
      expect(tokenSnap.data()?['usuarioId'], 'user-1');
    });

    test('gera token automaticamente quando vazio', () async {
      final firestore = FakeFirebaseFirestore();
      final datasource = ClienteFirestoreDatasource(firestore: firestore);
      final now = DateTime(2026, 7, 24);

      final id = await datasource.criarCliente(
        ClienteEntity(
          id: 'cliente-auto-token',
          token: '',
          nome: 'Produtor Token Auto',
          telefone: '(63) 99999-0000',
          email: 'a@b.com',
          cidade: 'Palmas',
          estado: 'TO',
          usuarioId: 'user-1',
          criadoEm: now,
          atualizadoEm: now,
        ),
      );

      final snap = await firestore.collection('clientes').doc(id).get();
      final token = snap.data()?['token'] as String?;
      expect(token, isNotNull);
      expect(token, startsWith('SF-'));

      final tokenSnap =
          await firestore.collection('cliente_tokens').doc(token).get();
      expect(tokenSnap.exists, isTrue);
      expect(tokenSnap.data()?['clienteId'], id);
    });

    test('buscarClientePorToken resolve via cliente_tokens', () async {
      final firestore = FakeFirebaseFirestore();
      final datasource = ClienteFirestoreDatasource(firestore: firestore);
      final now = DateTime(2026, 7, 24);

      final id = await datasource.criarCliente(
        ClienteEntity(
          id: 'cliente-token-lookup',
          token: 'SF-2026-LOOK',
          nome: 'Lookup',
          telefone: '',
          email: '',
          cidade: 'Palmas',
          estado: 'TO',
          usuarioId: 'user-1',
          criadoEm: now,
          atualizadoEm: now,
        ),
      );

      final found = await datasource.buscarClientePorToken('SF-2026-LOOK');
      expect(found, isNotNull);
      expect(found!.id, id);
      expect(found.nome, 'Lookup');
    });
  });
}
