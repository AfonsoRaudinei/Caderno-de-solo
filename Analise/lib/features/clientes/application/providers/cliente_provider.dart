import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/utils/token_generator.dart';
import 'package:soloforte/features/auth/application/providers/auth_usecase_providers.dart';
import 'package:soloforte/features/clientes/data/repositories/cliente_repository.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';

class ClienteState {
  final List<ClienteEntity> clientes;
  final ClienteEntity? clienteSelecionado;
  final bool isLoading;
  final String? erro;

  const ClienteState({
    this.clientes = const [],
    this.clienteSelecionado,
    this.isLoading = false,
    this.erro,
  });

  ClienteState copyWith({
    List<ClienteEntity>? clientes,
    ClienteEntity? clienteSelecionado,
    bool? isLoading,
    String? erro,
    bool clearErro = false,
    bool clearSelecionado = false,
  }) {
    return ClienteState(
      clientes: clientes ?? this.clientes,
      clienteSelecionado: clearSelecionado
          ? null
          : clienteSelecionado ?? this.clienteSelecionado,
      isLoading: isLoading ?? this.isLoading,
      erro: clearErro ? null : erro ?? this.erro,
    );
  }
}

final clienteProvider =
    StateNotifierProvider<ClienteNotifier, ClienteState>((ref) {
  final getCurrentUserIdUsecase = ref.read(getCurrentUserIdUsecaseProvider);
  return ClienteNotifier(
    repository: ref.read(clienteRepositoryProvider),
    getCurrentUserId: getCurrentUserIdUsecase.call,
  )..carregarClientes();
});

final clientesListProvider = Provider<List<ClienteEntity>>((ref) {
  return ref.watch(clienteProvider).clientes;
});

final clienteSelecionadoProvider = Provider<ClienteEntity?>((ref) {
  return ref.watch(clienteProvider).clienteSelecionado;
});

class ClienteNotifier extends StateNotifier<ClienteState> {
  ClienteNotifier({
    required ClienteRepository repository,
    required String? Function() getCurrentUserId,
  })  : _repository = repository,
        _getCurrentUserId = getCurrentUserId,
        super(const ClienteState());

  final ClienteRepository _repository;
  final String? Function() _getCurrentUserId;

  Future<void> carregarClientes() async {
    final usuarioId = _getCurrentUserId();
    if (usuarioId == null || usuarioId.isEmpty) {
      state = state.copyWith(
        clientes: const [],
        isLoading: false,
        erro: 'Usuário não autenticado.',
        clearSelecionado: true,
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearErro: true);
    try {
      final clientes = await _repository.listarClientes(usuarioId);
      final selecionadoId = state.clienteSelecionado?.id;
      final selecionado = selecionadoId == null
          ? null
          : clientes.where((item) => item.id == selecionadoId).firstOrNull;
      state = state.copyWith(
        clientes: clientes,
        clienteSelecionado: selecionado,
        isLoading: false,
        clearErro: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao carregar clientes: $e',
      );
    }
  }

  Future<String?> criarCliente(ClienteEntity cliente) async {
    final usuarioId = _getCurrentUserId();
    if (usuarioId == null || usuarioId.isEmpty) {
      state = state.copyWith(erro: 'Usuário não autenticado.');
      return null;
    }

    state = state.copyWith(isLoading: true, clearErro: true);
    try {
      final now = DateTime.now();
      final created = cliente.copyWith(
        token: TokenGenerator.generate(now: now),
        usuarioId: usuarioId,
        criadoEm: now,
        atualizadoEm: now,
      );
      final id = await _repository.criarCliente(created);
      await carregarClientes();
      final saved = await _repository.buscarClientePorId(id);
      if (saved != null) {
        state = state.copyWith(clienteSelecionado: saved);
      }
      return id;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao criar cliente: $e',
      );
      return null;
    }
  }

  Future<void> atualizarCliente(ClienteEntity cliente) async {
    state = state.copyWith(isLoading: true, clearErro: true);
    try {
      await _repository.atualizarCliente(
        cliente.copyWith(atualizadoEm: DateTime.now()),
      );
      await carregarClientes();
      await carregarClienteDetalhe(cliente.id);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao atualizar cliente: $e',
      );
    }
  }

  Future<void> deletarCliente(String id) async {
    state = state.copyWith(isLoading: true, clearErro: true);
    try {
      await _repository.deletarCliente(id);
      await carregarClientes();
      state = state.copyWith(clearSelecionado: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao excluir cliente: $e',
      );
    }
  }

  Future<void> carregarClienteDetalhe(String id) async {
    state = state.copyWith(isLoading: true, clearErro: true);
    try {
      final cliente = await _repository.buscarClientePorId(id);
      state = state.copyWith(
        clienteSelecionado: cliente,
        isLoading: false,
        clearErro: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao carregar detalhe do cliente: $e',
      );
    }
  }

  void selecionarCliente(ClienteEntity? cliente) {
    state = state.copyWith(clienteSelecionado: cliente);
  }

  Future<void> adicionarFazenda(String clienteId, FazendaEntity fazenda) async {
    state = state.copyWith(isLoading: true, clearErro: true);
    try {
      await _repository.adicionarFazenda(clienteId, fazenda);
      await carregarClienteDetalhe(clienteId);
      await carregarClientes();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao adicionar fazenda: $e',
      );
    }
  }

  Future<void> atualizarFazenda(String clienteId, FazendaEntity fazenda) async {
    state = state.copyWith(isLoading: true, clearErro: true);
    try {
      await _repository.atualizarFazenda(clienteId, fazenda);
      await carregarClienteDetalhe(clienteId);
      await carregarClientes();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao atualizar fazenda: $e',
      );
    }
  }

  Future<void> deletarFazenda(String clienteId, String fazendaId) async {
    state = state.copyWith(isLoading: true, clearErro: true);
    try {
      await _repository.deletarFazenda(clienteId, fazendaId);
      await carregarClienteDetalhe(clienteId);
      await carregarClientes();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao excluir fazenda: $e',
      );
    }
  }

  Future<void> adicionarTalhao(
    String clienteId,
    String fazendaId,
    TalhaoEntity talhao,
  ) async {
    state = state.copyWith(isLoading: true, clearErro: true);
    try {
      await _repository.adicionarTalhao(clienteId, fazendaId, talhao);
      await carregarClienteDetalhe(clienteId);
      await carregarClientes();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao adicionar talhão: $e',
      );
    }
  }

  Future<void> atualizarTalhao(
    String clienteId,
    String fazendaId,
    TalhaoEntity talhao,
  ) async {
    state = state.copyWith(isLoading: true, clearErro: true);
    try {
      await _repository.atualizarTalhao(clienteId, fazendaId, talhao);
      await carregarClienteDetalhe(clienteId);
      await carregarClientes();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao atualizar talhão: $e',
      );
    }
  }

  Future<void> deletarTalhao(
    String clienteId,
    String fazendaId,
    String talhaoId,
  ) async {
    state = state.copyWith(isLoading: true, clearErro: true);
    try {
      await _repository.deletarTalhao(clienteId, fazendaId, talhaoId);
      await carregarClienteDetalhe(clienteId);
      await carregarClientes();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao excluir talhão: $e',
      );
    }
  }

  void limparErro() {
    state = state.copyWith(clearErro: true);
  }
}
