import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/utils/token_generator.dart';
import 'package:soloforte/data/repositories/auth_repository_impl.dart';
import 'package:soloforte/features/auth/application/providers/auth_usecase_providers.dart';
import 'package:soloforte/features/clientes/data/repositories/cliente_repository.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';
import 'package:soloforte/features/clientes/domain/exceptions/cliente_session_exception.dart';

class ClienteState {
  final List<ClienteEntity> clientes;
  final ClienteEntity? clienteSelecionado;
  final bool isLoading;
  final String? erro;
  final bool requiresLogin;

  const ClienteState({
    this.clientes = const [],
    this.clienteSelecionado,
    this.isLoading = false,
    this.erro,
    this.requiresLogin = false,
  });

  ClienteState copyWith({
    List<ClienteEntity>? clientes,
    ClienteEntity? clienteSelecionado,
    bool? isLoading,
    String? erro,
    bool? requiresLogin,
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
      requiresLogin: requiresLogin ?? this.requiresLogin,
    );
  }
}

final clienteProvider =
    StateNotifierProvider<ClienteNotifier, ClienteState>((ref) {
  final waitForCurrentUserIdUsecase =
      ref.read(waitForCurrentUserIdUsecaseProvider);
  final authRepository = ref.read(authRepositoryProvider);
  return ClienteNotifier(
    repository: ref.read(clienteRepositoryProvider),
    waitForCurrentUserId: waitForCurrentUserIdUsecase.call,
    signOut: authRepository.logout,
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
    required Future<String?> Function({Duration timeout}) waitForCurrentUserId,
    required Future<void> Function() signOut,
  })  : _repository = repository,
        _waitForCurrentUserId = waitForCurrentUserId,
        _signOut = signOut,
        super(const ClienteState());

  final ClienteRepository _repository;
  final Future<String?> Function({Duration timeout}) _waitForCurrentUserId;
  final Future<void> Function() _signOut;

  Future<void> _markRequiresLogin({bool signOut = false}) async {
    if (signOut) {
      try {
        await _signOut();
      } catch (_) {}
    }
    state = state.copyWith(
      clientes: const [],
      isLoading: false,
      requiresLogin: true,
      clearSelecionado: true,
      clearErro: true,
    );
  }

  Future<void> carregarClientes() async {
    state = state.copyWith(isLoading: true, clearErro: true);
    final usuarioId = await _waitForCurrentUserId();
    if (usuarioId == null || usuarioId.isEmpty) {
      await _markRequiresLogin();
      return;
    }

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
        requiresLogin: false,
        clearErro: true,
      );
    } on ClienteSessionException {
      await _handleSessionException();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao carregar clientes: $e',
      );
    }
  }

  /// Permission-denied no Firestore não significa sessão Firebase encerrada.
  /// Se o usuário ainda estiver autenticado, mantém a tela e mostra erro
  /// recuperável em vez de fazer signOut e jogar para /login.
  Future<void> _handleSessionException() async {
    final usuarioId = await _waitForCurrentUserId(
      timeout: const Duration(seconds: 1),
    );
    if (usuarioId != null && usuarioId.isNotEmpty) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Não foi possível sincronizar os clientes. Puxe para atualizar.',
        requiresLogin: false,
      );
      return;
    }
    await _markRequiresLogin(signOut: true);
  }

  Future<String?> criarCliente(ClienteEntity cliente) async {
    final usuarioId = await _waitForCurrentUserId();
    if (usuarioId == null || usuarioId.isEmpty) {
      await _markRequiresLogin();
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
      final createdWithId = created.copyWith(id: id);
      state = state.copyWith(
        clientes: _upsertCliente(state.clientes, createdWithId),
        clienteSelecionado: createdWithId,
        isLoading: false,
        requiresLogin: false,
        clearErro: true,
      );

      // Reload não pode invalidar um create já persistido.
      try {
        final clientes = await _repository.listarClientes(usuarioId);
        final saved = await _repository.buscarClientePorId(id) ?? createdWithId;
        state = state.copyWith(
          clientes: _upsertCliente(clientes, saved),
          clienteSelecionado: saved,
          isLoading: false,
          requiresLogin: false,
          clearErro: true,
        );
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          clientes: _upsertCliente(state.clientes, createdWithId),
          clienteSelecionado: createdWithId,
          erro:
              'Cliente salvo e disponível localmente. Puxe para atualizar a lista.',
        );
      }
      return id;
    } on ClienteSessionException {
      await _handleSessionException();
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao criar cliente: $e',
      );
      return null;
    }
  }

  Future<bool> atualizarCliente(ClienteEntity cliente) async {
    state = state.copyWith(isLoading: true, clearErro: true);
    try {
      final updated = cliente.copyWith(atualizadoEm: DateTime.now());
      await _repository.atualizarCliente(updated);

      // Persistência ok: atualiza estado local antes do reload remoto.
      state = state.copyWith(
        clientes: _upsertCliente(state.clientes, updated),
        clienteSelecionado: updated,
        isLoading: false,
        requiresLogin: false,
        clearErro: true,
      );

      // Reload não pode inverter o sucesso do update nem forçar login.
      try {
        final usuarioId = await _waitForCurrentUserId(
          timeout: const Duration(seconds: 2),
        );
        if (usuarioId != null && usuarioId.isNotEmpty) {
          final clientes = await _repository.listarClientes(usuarioId);
          final saved =
              await _repository.buscarClientePorId(cliente.id) ?? updated;
          state = state.copyWith(
            clientes: _upsertCliente(clientes, saved),
            clienteSelecionado: saved,
            isLoading: false,
            requiresLogin: false,
            clearErro: true,
          );
        }
      } on ClienteSessionException {
        state = state.copyWith(
          isLoading: false,
          clientes: _upsertCliente(state.clientes, updated),
          clienteSelecionado: updated,
          erro:
              'Cliente atualizado. Não foi possível sincronizar a lista agora.',
          requiresLogin: false,
        );
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          clientes: _upsertCliente(state.clientes, updated),
          clienteSelecionado: updated,
          erro: 'Cliente atualizado, mas a tela não recarregou: $e',
          requiresLogin: false,
        );
      }
      return true;
    } on ClienteSessionException {
      await _handleSessionException();
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao atualizar cliente: $e',
      );
      return false;
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

  List<ClienteEntity> _upsertCliente(
    List<ClienteEntity> current,
    ClienteEntity cliente,
  ) {
    final byId = {
      for (final item in current)
        if (item.id.isNotEmpty) item.id: item,
    };
    if (cliente.id.isNotEmpty) {
      byId[cliente.id] = cliente;
    }
    final updated = byId.values.toList(growable: false)
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return updated;
  }
}
