import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/clientes/data/datasources/cliente_firestore_datasource.dart';
import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';

void main() {
  group('ClienteFirestoreDatasource', () {
    test('listarClientes ignora permission-denied ao hidratar fazendas',
        () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('clientes').doc('cliente-1').set(
            _clienteData(
              nome: 'Cliente A',
              usuarioId: 'user-1',
            ),
          );

      final datasource = _FazendasNegadasDatasource(firestore: firestore);
      final clientes = await datasource.listarClientes('user-1');

      expect(clientes, hasLength(1));
      expect(clientes.single.nome, 'Cliente A');
      expect(clientes.single.fazendas, isEmpty);
    });

    test('listarClientes preserva fazendas quando talhoes negam acesso',
        () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('clientes').doc('cliente-1').set(
            _clienteData(
              nome: 'Cliente B',
              usuarioId: 'user-1',
            ),
          );
      await firestore
          .collection('clientes')
          .doc('cliente-1')
          .collection('fazendas')
          .doc('fazenda-1')
          .set(
            _fazendaData(
              nome: 'Fazenda 1',
            ),
          );

      final datasource = _TalhoesNegadosDatasource(firestore: firestore);
      final clientes = await datasource.listarClientes('user-1');

      expect(clientes, hasLength(1));
      expect(clientes.single.nome, 'Cliente B');
      expect(clientes.single.fazendas, hasLength(1));
      expect(clientes.single.fazendas.single.nome, 'Fazenda 1');
      expect(clientes.single.fazendas.single.talhoes, isEmpty);
    });
  });
}

Map<String, dynamic> _clienteData({
  required String nome,
  required String usuarioId,
}) {
  final now = DateTime(2026, 7, 15);
  return {
    'id': 'cliente-1',
    'token': 'SF-2026-ABCD',
    'nome': nome,
    'telefone': '(63) 99999-0000',
    'email': 'cliente@teste.com',
    'cidade': 'Palmas',
    'estado': 'TO',
    'observacoes': null,
    'fazendas': const [],
    'usuarioId': usuarioId,
    'criadoEm': now,
    'atualizadoEm': now,
    'analiseIds': const <String>[],
  };
}

Map<String, dynamic> _fazendaData({
  required String nome,
}) {
  final now = DateTime(2026, 7, 15);
  return {
    'id': 'fazenda-1',
    'nome': nome,
    'areaTotal': 120.5,
    'talhoes': const [],
    'criadoEm': now,
  };
}

class _FazendasNegadasDatasource extends ClienteFirestoreDatasource {
  _FazendasNegadasDatasource({required super.firestore});

  @override
  Future<List<FazendaEntity>> listarFazendas(String clienteId) {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
      message: 'missing permissions',
    );
  }
}

class _TalhoesNegadosDatasource extends ClienteFirestoreDatasource {
  _TalhoesNegadosDatasource({required super.firestore});

  @override
  Future<List<TalhaoEntity>> listarTalhoes(
    String clienteId,
    String fazendaId,
  ) {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
      message: 'missing permissions',
    );
  }
}
