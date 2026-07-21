import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:soloforte/core/utils/firestore_doc_id.dart';
import 'package:soloforte/core/utils/token_generator.dart';
import 'package:soloforte/features/clientes/data/models/cliente_model.dart';
import 'package:soloforte/features/clientes/data/models/fazenda_model.dart';
import 'package:soloforte/features/clientes/data/models/talhao_model.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';
import 'package:uuid/uuid.dart';

class ClienteFirestoreDatasource {
  ClienteFirestoreDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance {
    _collection = _firestore.collection('clientes');
  }

  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();
  late final CollectionReference<Map<String, dynamic>> _collection;

  // Fluxo de integração com o App Mapa:
  // 1. SoloForte cria o cliente e gera o token SF-AAAA-XXXX.
  // 2. O produtor escaneia o QR no App Mapa.
  // 3. O App Mapa chama buscarClientePorToken(token) para obter o clienteId.
  // 4. Depois consulta análises vinculadas a esse clienteId e os talhões GPS.

  Future<String> criarCliente(ClienteEntity cliente) async {
    try {
      final documentId = sanitizeFirestoreDocId(
        cliente.id.isEmpty ? _uuid.v4() : cliente.id,
      );
      final token = await _resolveUniqueToken(cliente.token);
      final payload = ClienteModel.fromEntity(
        cliente.copyWith(
          id: documentId,
          token: token,
          criadoEm: cliente.criadoEm,
          atualizadoEm: cliente.atualizadoEm,
        ),
      ).toMap()
        ..remove('fazendas');

      await _collection.doc(documentId).set(payload);
      return documentId;
    } catch (e) {
      throw Exception('Erro ao criar cliente: $e');
    }
  }

  Future<ClienteEntity?> buscarClientePorId(String id) async {
    try {
      final snapshot = await _collection.doc(id).get();
      if (!snapshot.exists) return null;
      return _hydrateCliente(snapshot);
    } catch (e) {
      throw Exception('Erro ao buscar cliente: $e');
    }
  }

  Future<ClienteEntity?> buscarClientePorToken(String token) async {
    try {
      final query =
          await _collection.where('token', isEqualTo: token).limit(1).get();
      if (query.docs.isEmpty) return null;
      return _hydrateCliente(query.docs.first);
    } catch (e) {
      throw Exception('Erro ao buscar cliente por token: $e');
    }
  }

  Future<List<ClienteEntity>> listarClientes(String usuarioId) async {
    try {
      final query = await _collection
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('nome')
          .get();
      return Future.wait(query.docs.map(_hydrateCliente));
    } catch (e) {
      throw Exception('Erro ao listar clientes: $e');
    }
  }

  Future<void> atualizarCliente(ClienteEntity cliente) async {
    try {
      final payload = ClienteModel.fromEntity(
        cliente.copyWith(atualizadoEm: DateTime.now()),
      ).toMap()
        ..remove('fazendas');
      await _collection.doc(cliente.id).update(payload);
    } catch (e) {
      throw Exception('Erro ao atualizar cliente: $e');
    }
  }

  Future<void> deletarCliente(String clienteId) async {
    try {
      final fazendas = await listarFazendas(clienteId);
      for (final fazenda in fazendas) {
        await deletarFazenda(clienteId, fazenda.id);
      }
      await _collection.doc(clienteId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar cliente: $e');
    }
  }

  Future<String> adicionarFazenda(
      String clienteId, FazendaEntity fazenda) async {
    try {
      final fazendaId =
          sanitizeFirestoreDocId(fazenda.id.isEmpty ? _uuid.v4() : fazenda.id);
      final payload = FazendaModel.fromEntity(
        fazenda.copyWith(id: fazendaId),
      ).toMap()
        ..remove('talhoes');
      await _fazendas(clienteId).doc(fazendaId).set(payload);
      return fazendaId;
    } catch (e) {
      throw Exception('Erro ao adicionar fazenda: $e');
    }
  }

  Future<void> atualizarFazenda(String clienteId, FazendaEntity fazenda) async {
    try {
      final payload = FazendaModel.fromEntity(fazenda).toMap()
        ..remove('talhoes');
      await _fazendas(clienteId).doc(fazenda.id).update(payload);
    } catch (e) {
      throw Exception('Erro ao atualizar fazenda: $e');
    }
  }

  Future<void> deletarFazenda(String clienteId, String fazendaId) async {
    try {
      final talhoes = await listarTalhoes(clienteId, fazendaId);
      for (final talhao in talhoes) {
        await deletarTalhao(clienteId, fazendaId, talhao.id);
      }
      await _fazendas(clienteId).doc(fazendaId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar fazenda: $e');
    }
  }

  Future<List<FazendaEntity>> listarFazendas(String clienteId) async {
    try {
      final query = await _fazendas(clienteId).orderBy('nome').get();
      final fazendas = <FazendaEntity>[];

      for (final doc in query.docs) {
        final data = doc.data();
        var talhoes = <TalhaoEntity>[];

        try {
          talhoes = await listarTalhoes(clienteId, doc.id);
        } on FirebaseException catch (e) {
          if (!_isPermissionDenied(e)) rethrow;
        }

        data['id'] = doc.id;
        data['talhoes'] = talhoes.map((talhao) => talhao.toMap()).toList();
        fazendas.add(FazendaModel.fromMap(data));
      }

      return fazendas;
    } catch (e) {
      throw Exception('Erro ao listar fazendas: $e');
    }
  }

  Future<String> adicionarTalhao(
    String clienteId,
    String fazendaId,
    TalhaoEntity talhao,
  ) async {
    try {
      final talhaoId =
          sanitizeFirestoreDocId(talhao.id.isEmpty ? _uuid.v4() : talhao.id);
      final payload = TalhaoModel.fromEntity(
        talhao.copyWith(id: talhaoId),
      ).toMap();
      await _talhoes(clienteId, fazendaId).doc(talhaoId).set(payload);
      return talhaoId;
    } catch (e) {
      throw Exception('Erro ao adicionar talhão: $e');
    }
  }

  Future<void> atualizarTalhao(
    String clienteId,
    String fazendaId,
    TalhaoEntity talhao,
  ) async {
    try {
      await _talhoes(clienteId, fazendaId).doc(talhao.id).update(
            TalhaoModel.fromEntity(talhao).toMap(),
          );
    } catch (e) {
      throw Exception('Erro ao atualizar talhão: $e');
    }
  }

  Future<void> deletarTalhao(
    String clienteId,
    String fazendaId,
    String talhaoId,
  ) async {
    try {
      await _talhoes(clienteId, fazendaId).doc(talhaoId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar talhão: $e');
    }
  }

  Future<List<TalhaoEntity>> listarTalhoes(
    String clienteId,
    String fazendaId,
  ) async {
    try {
      final query = await _talhoes(clienteId, fazendaId).orderBy('nome').get();
      return query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TalhaoModel.fromMap(data);
      }).toList(growable: false);
    } catch (e) {
      throw Exception('Erro ao listar talhões: $e');
    }
  }

  CollectionReference<Map<String, dynamic>> _fazendas(String clienteId) {
    return _collection.doc(clienteId).collection('fazendas');
  }

  CollectionReference<Map<String, dynamic>> _talhoes(
    String clienteId,
    String fazendaId,
  ) {
    return _fazendas(clienteId).doc(fazendaId).collection('talhoes');
  }

  Future<ClienteEntity> _hydrateCliente(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final data = snapshot.data() ?? <String, dynamic>{};
    data['id'] = snapshot.id;
    try {
      data['fazendas'] = (await listarFazendas(snapshot.id))
          .map((fazenda) => fazenda.toMap())
          .toList();
    } on FirebaseException catch (e) {
      if (!_isPermissionDenied(e)) rethrow;
      data['fazendas'] = const [];
    }
    return ClienteModel.fromMap(data);
  }

  Future<String> _resolveUniqueToken(String currentToken) async {
    var token =
        currentToken.isNotEmpty ? currentToken : TokenGenerator.generate();

    for (var attempt = 0; attempt < 3; attempt++) {
      final existing =
          await _collection.where('token', isEqualTo: token).limit(1).get();
      if (existing.docs.isEmpty) return token;
      token = TokenGenerator.generate();
    }

    debugPrint('ClienteFirestoreDatasource: colisão repetida de token.');
    throw Exception('Não foi possível gerar um token único para o cliente.');
  }

  bool _isPermissionDenied(FirebaseException error) {
    return error.code == 'permission-denied' ||
        error.code == 'missing-or-insufficient-permissions';
  }
}
