import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/clientes/data/datasources/cliente_firestore_datasource.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';

final clienteDatasourceProvider = Provider<ClienteFirestoreDatasource>((ref) {
  return ClienteFirestoreDatasource();
});

final clienteRepositoryProvider = Provider<ClienteRepository>((ref) {
  return ClienteRepository(ref.read(clienteDatasourceProvider));
});

class ClienteRepository {
  ClienteRepository(this._datasource);

  final ClienteFirestoreDatasource _datasource;

  Future<String> criarCliente(ClienteEntity cliente) {
    return _datasource.criarCliente(cliente);
  }

  Future<ClienteEntity?> buscarClientePorId(String id) {
    return _datasource.buscarClientePorId(id);
  }

  Future<ClienteEntity?> buscarClientePorToken(String token) {
    return _datasource.buscarClientePorToken(token);
  }

  Future<List<ClienteEntity>> listarClientes(String usuarioId) {
    return _datasource.listarClientes(usuarioId);
  }

  Future<void> atualizarCliente(ClienteEntity cliente) {
    return _datasource.atualizarCliente(cliente);
  }

  Future<void> deletarCliente(String clienteId) {
    return _datasource.deletarCliente(clienteId);
  }

  Future<String> adicionarFazenda(String clienteId, FazendaEntity fazenda) {
    return _datasource.adicionarFazenda(clienteId, fazenda);
  }

  Future<void> atualizarFazenda(String clienteId, FazendaEntity fazenda) {
    return _datasource.atualizarFazenda(clienteId, fazenda);
  }

  Future<void> deletarFazenda(String clienteId, String fazendaId) {
    return _datasource.deletarFazenda(clienteId, fazendaId);
  }

  Future<List<FazendaEntity>> listarFazendas(String clienteId) {
    return _datasource.listarFazendas(clienteId);
  }

  Future<String> adicionarTalhao(
    String clienteId,
    String fazendaId,
    TalhaoEntity talhao,
  ) {
    return _datasource.adicionarTalhao(clienteId, fazendaId, talhao);
  }

  Future<void> atualizarTalhao(
    String clienteId,
    String fazendaId,
    TalhaoEntity talhao,
  ) {
    return _datasource.atualizarTalhao(clienteId, fazendaId, talhao);
  }

  Future<void> deletarTalhao(
    String clienteId,
    String fazendaId,
    String talhaoId,
  ) {
    return _datasource.deletarTalhao(clienteId, fazendaId, talhaoId);
  }

  Future<List<TalhaoEntity>> listarTalhoes(String clienteId, String fazendaId) {
    return _datasource.listarTalhoes(clienteId, fazendaId);
  }
}
