import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soloforte/core/utils/firestore_doc_id.dart';
import 'package:soloforte/core/utils/token_generator.dart';
import 'package:soloforte/features/clientes/data/models/cliente_model.dart';
import 'package:soloforte/features/clientes/data/models/fazenda_model.dart';
import 'package:soloforte/features/clientes/data/models/talhao_model.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';
import 'package:soloforte/features/clientes/domain/exceptions/cliente_session_exception.dart';
import 'package:uuid/uuid.dart';

class ClienteFirestoreDatasource {
  ClienteFirestoreDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance {
    _collection = _firestore.collection('clientes');
    _tokens = _firestore.collection('cliente_tokens');
  }

  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();
  late final CollectionReference<Map<String, dynamic>> _collection;
  late final CollectionReference<Map<String, dynamic>> _tokens;

  // Fluxo de integração com o App Mapa:
  // 1. SoloForte cria o cliente e gera o token SF-AAAA-XXXX.
  // 2. Registra o token em cliente_tokens/{token} (lookup alinhado às rules).
  // 3. O App Mapa lê cliente_tokens/{token} e depois o clienteId.

  Future<String> criarCliente(ClienteEntity cliente) async {
    try {
      final documentId = sanitizeFirestoreDocId(
        cliente.id.isEmpty ? _uuid.v4() : cliente.id,
      );
      await _firestore.runTransaction((transaction) async {
        final allocation = await _allocateUniqueToken(
          transaction: transaction,
          preferred: cliente.token,
          clienteId: documentId,
          usuarioId: cliente.usuarioId,
        );
        final payload = ClienteModel.fromEntity(
          cliente.copyWith(
            id: documentId,
            token: allocation.token,
            criadoEm: cliente.criadoEm,
            atualizadoEm: cliente.atualizadoEm,
          ),
        ).toMap()
          ..remove('fazendas');

        transaction
          ..set(_collection.doc(documentId), payload)
          ..set(allocation.ref, allocation.payload);
      });
      return documentId;
    } on FirebaseException catch (e) {
      _throwClienteException('Erro ao criar cliente', e);
    } on ClienteSessionException {
      rethrow;
    } catch (e) {
      throw Exception('Erro ao criar cliente: $e');
    }
  }

  Future<ClienteEntity?> buscarClientePorId(String id) async {
    try {
      final snapshot = await _collection.doc(id).get();
      if (!snapshot.exists) return null;
      return _hydrateCliente(snapshot);
    } on FirebaseException catch (e) {
      if (_isPermissionDenied(e)) {
        throw const ClienteSessionException();
      }
      throw Exception('Erro ao buscar cliente: $e');
    } catch (e) {
      throw Exception('Erro ao buscar cliente: $e');
    }
  }

  Future<ClienteEntity?> buscarClientePorToken(String token) async {
    try {
      final normalized = token.trim();
      if (normalized.isEmpty) return null;

      // Lookup por documentId — compatível com rules (get pontual).
      final tokenSnap = await _tokens.doc(normalized).get();
      if (!tokenSnap.exists) return null;
      final clienteId = tokenSnap.data()?['clienteId'] as String?;
      if (clienteId == null || clienteId.isEmpty) return null;
      return buscarClientePorId(clienteId);
    } on FirebaseException catch (e) {
      if (_isPermissionDenied(e)) {
        throw const ClienteSessionException();
      }
      throw Exception('Erro ao buscar cliente por token: $e');
    } on ClienteSessionException {
      rethrow;
    } catch (e) {
      throw Exception('Erro ao buscar cliente por token: $e');
    }
  }

  Future<List<ClienteEntity>> listarClientes(String usuarioId) async {
    try {
      // Sem orderBy no Firestore: where+orderBy exige índice composto que não
      // estava provisionado em produção (failed-precondition). Ordena em Dart.
      final query =
          await _collection.where('usuarioId', isEqualTo: usuarioId).get();
      final clientes = await Future.wait(query.docs.map(_hydrateCliente));
      clientes.sort(
        (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
      );
      return clientes;
    } on FirebaseException catch (e) {
      if (_isPermissionDenied(e)) {
        throw const ClienteSessionException();
      }
      throw Exception('Erro ao listar clientes: $e');
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
      if (cliente.token.isNotEmpty) {
        await _tokens.doc(cliente.token).set({
          'clienteId': cliente.id,
          'usuarioId': cliente.usuarioId,
          'token': cliente.token,
        }, SetOptions(merge: true));
      }
    } on FirebaseException catch (e) {
      _throwClienteException('Erro ao atualizar cliente', e);
    } catch (e) {
      throw Exception('Erro ao atualizar cliente: $e');
    }
  }

  /// Registra o ID da análise no cliente sem duplicar entradas.
  Future<void> adicionarAnaliseId(String clienteId, String analiseId) async {
    final normalizedClienteId = clienteId.trim();
    final normalizedAnaliseId = analiseId.trim();
    if (normalizedClienteId.isEmpty || normalizedAnaliseId.isEmpty) return;

    try {
      await _collection.doc(normalizedClienteId).update({
        'analiseIds': FieldValue.arrayUnion([normalizedAnaliseId]),
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      _throwClienteException('Erro ao vincular análise ao cliente', e);
    } catch (e) {
      throw Exception('Erro ao vincular análise ao cliente: $e');
    }
  }

  Future<void> deletarCliente(String clienteId) async {
    try {
      final existing = await _collection.doc(clienteId).get();
      final token = existing.data()?['token'] as String?;
      final fazendas = await listarFazendas(clienteId);
      for (final fazenda in fazendas) {
        await deletarFazenda(clienteId, fazenda.id);
      }
      await _collection.doc(clienteId).delete();
      if (token != null && token.isNotEmpty) {
        await _tokens.doc(token).delete();
      }
    } on FirebaseException catch (e) {
      _throwClienteException('Erro ao deletar cliente', e);
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
    } on FirebaseException catch (e) {
      _throwClienteException('Erro ao adicionar fazenda', e);
    } on ClienteSessionException {
      rethrow;
    } catch (e) {
      throw Exception('Erro ao adicionar fazenda: $e');
    }
  }

  Future<void> atualizarFazenda(String clienteId, FazendaEntity fazenda) async {
    try {
      final payload = FazendaModel.fromEntity(fazenda).toMap()
        ..remove('talhoes');
      await _fazendas(clienteId).doc(fazenda.id).update(payload);
    } on FirebaseException catch (e) {
      _throwClienteException('Erro ao atualizar fazenda', e);
    } on ClienteSessionException {
      rethrow;
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
    } on FirebaseException catch (e) {
      _throwClienteException('Erro ao deletar fazenda', e);
    } on ClienteSessionException {
      rethrow;
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
        } on ClienteSessionException {
          // Nested permission-denied: keep fazenda with empty talhões.
        }

        data['id'] = doc.id;
        data['talhoes'] = talhoes.map((talhao) => talhao.toMap()).toList();
        fazendas.add(FazendaModel.fromMap(data));
      }

      return fazendas;
    } on FirebaseException catch (e) {
      _throwClienteException('Erro ao listar fazendas', e);
    } on ClienteSessionException {
      rethrow;
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
    } on FirebaseException catch (e) {
      _throwClienteException('Erro ao adicionar talhão', e);
    } on ClienteSessionException {
      rethrow;
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
    } on FirebaseException catch (e) {
      _throwClienteException('Erro ao atualizar talhão', e);
    } on ClienteSessionException {
      rethrow;
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
    } on FirebaseException catch (e) {
      _throwClienteException('Erro ao deletar talhão', e);
    } on ClienteSessionException {
      rethrow;
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
    } on FirebaseException catch (e) {
      _throwClienteException('Erro ao listar talhões', e);
    } on ClienteSessionException {
      rethrow;
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

  Future<_TokenAllocation> _allocateUniqueToken({
    required Transaction transaction,
    required String preferred,
    required String clienteId,
    required String usuarioId,
  }) async {
    var token = preferred.isNotEmpty ? preferred : TokenGenerator.generate();

    for (var attempt = 0; attempt < 5; attempt++) {
      final ref = _tokens.doc(token);
      final existing = await transaction.get(ref);
      final payload = {
        'clienteId': clienteId,
        'usuarioId': usuarioId,
        'token': token,
      };
      if (!existing.exists) {
        return _TokenAllocation(
          token: token,
          ref: ref,
          payload: payload,
        );
      }

      final owner = existing.data()?['usuarioId'] as String?;
      final linkedCliente = existing.data()?['clienteId'] as String?;
      if (owner == usuarioId && linkedCliente == clienteId) {
        return _TokenAllocation(
          token: token,
          ref: ref,
          payload: payload,
        );
      }
      token = TokenGenerator.generate();
    }

    throw Exception('Não foi possível gerar um token único para o cliente.');
  }

  bool _isPermissionDenied(FirebaseException error) {
    return error.code == 'permission-denied' ||
        error.code == 'missing-or-insufficient-permissions';
  }

  Never _throwClienteException(String operation, FirebaseException error) {
    if (_isPermissionDenied(error)) {
      throw const ClienteSessionException();
    }
    throw Exception('$operation: $error');
  }
}

class _TokenAllocation {
  const _TokenAllocation({
    required this.token,
    required this.ref,
    required this.payload,
  });

  final String token;
  final DocumentReference<Map<String, dynamic>> ref;
  final Map<String, dynamic> payload;
}
