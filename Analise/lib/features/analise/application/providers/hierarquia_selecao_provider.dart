import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/utils/token_generator.dart';
import 'package:soloforte/features/analise/domain/services/produtor_resolucao_service.dart';
import 'package:soloforte/features/analise/domain/value_objects/hierarquia_selecao_result.dart';
import 'package:soloforte/features/analise/domain/value_objects/hierarquia_selecao_sugestao.dart';
import 'package:soloforte/features/auth/application/providers/auth_usecase_providers.dart';
import 'package:soloforte/features/clientes/data/repositories/cliente_repository.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';
import 'package:soloforte/features/clientes/domain/exceptions/cliente_session_exception.dart';

enum HierarquiaSelecaoModo {
  selecionar,
  criarCliente,
  criarFazenda,
  criarTalhao,
}

class HierarquiaSelecaoState {
  const HierarquiaSelecaoState({
    this.clientes = const [],
    this.clienteId,
    this.fazendaId,
    this.talhaoId,
    this.isLoading = false,
    this.erro,
    this.modo = HierarquiaSelecaoModo.selecionar,
    this.requiresLogin = false,
  });

  final List<ClienteEntity> clientes;
  final String? clienteId;
  final String? fazendaId;
  final String? talhaoId;
  final bool isLoading;
  final String? erro;
  final HierarquiaSelecaoModo modo;
  final bool requiresLogin;

  ClienteEntity? get clienteAtual {
    final id = clienteId?.trim() ?? '';
    if (id.isEmpty) return null;
    for (final cliente in clientes) {
      if (cliente.id == id) return cliente;
    }
    return null;
  }

  FazendaEntity? get fazendaAtual {
    final id = fazendaId?.trim() ?? '';
    if (id.isEmpty) return null;
    return clienteAtual?.fazendas.where((f) => f.id == id).firstOrNull;
  }

  TalhaoEntity? get talhaoAtual {
    final id = talhaoId?.trim() ?? '';
    if (id.isEmpty) return null;
    return fazendaAtual?.talhoes.where((t) => t.id == id).firstOrNull;
  }

  List<FazendaEntity> get fazendasDisponiveis =>
      clienteAtual?.fazendas ?? const [];

  List<TalhaoEntity> get talhoesDisponiveis =>
      fazendaAtual?.talhoes ?? const [];

  bool get podeConfirmar =>
      clienteId?.trim().isNotEmpty == true &&
      fazendaId?.trim().isNotEmpty == true &&
      talhaoId?.trim().isNotEmpty == true;

  bool get listaVazia => !isLoading && clientes.isEmpty;

  HierarquiaSelecaoState copyWith({
    List<ClienteEntity>? clientes,
    String? clienteId,
    String? fazendaId,
    String? talhaoId,
    bool? isLoading,
    String? erro,
    HierarquiaSelecaoModo? modo,
    bool? requiresLogin,
    bool clearErro = false,
    bool clearCliente = false,
    bool clearFazenda = false,
    bool clearTalhao = false,
  }) {
    return HierarquiaSelecaoState(
      clientes: clientes ?? this.clientes,
      clienteId: clearCliente ? null : clienteId ?? this.clienteId,
      fazendaId: clearFazenda || clearCliente
          ? null
          : fazendaId ?? this.fazendaId,
      talhaoId: clearTalhao || clearFazenda || clearCliente
          ? null
          : talhaoId ?? this.talhaoId,
      isLoading: isLoading ?? this.isLoading,
      erro: clearErro ? null : erro ?? this.erro,
      modo: modo ?? this.modo,
      requiresLogin: requiresLogin ?? this.requiresLogin,
    );
  }
}

final hierarquiaSelecaoProvider = StateNotifierProvider.autoDispose<
    HierarquiaSelecaoNotifier, HierarquiaSelecaoState>((ref) {
  return HierarquiaSelecaoNotifier(
    repository: ref.read(clienteRepositoryProvider),
    waitForCurrentUserId: ref.read(waitForCurrentUserIdUsecaseProvider).call,
  );
});

class HierarquiaSelecaoNotifier extends StateNotifier<HierarquiaSelecaoState> {
  HierarquiaSelecaoNotifier({
    required ClienteRepository repository,
    required Future<String?> Function({Duration timeout}) waitForCurrentUserId,
  })  : _repository = repository,
        _waitForCurrentUserId = waitForCurrentUserId,
        super(const HierarquiaSelecaoState());

  final ClienteRepository _repository;
  final Future<String?> Function({Duration timeout}) _waitForCurrentUserId;

  Future<void> inicializar(HierarquiaSelecaoSugestao sugestao) async {
    await carregarClientes();
    if (!mounted) return;
    _aplicarSugestao(sugestao);
  }

  Future<void> carregarClientes() async {
    state = state.copyWith(isLoading: true, clearErro: true);
    final usuarioId = await _waitForCurrentUserId();
    if (usuarioId == null || usuarioId.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        requiresLogin: true,
        clientes: const [],
        clearCliente: true,
      );
      return;
    }

    try {
      final clientes = await _repository.listarClientes(usuarioId);
      state = state.copyWith(
        clientes: clientes,
        isLoading: false,
        requiresLogin: false,
        clearErro: true,
      );
    } on ClienteSessionException {
      state = state.copyWith(
        isLoading: false,
        requiresLogin: true,
        clientes: const [],
        clearCliente: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao carregar clientes: $e',
      );
    }
  }

  void selecionarCliente(String? id) {
    state = state.copyWith(
      clienteId: id,
      clearFazenda: true,
      clearTalhao: true,
      modo: HierarquiaSelecaoModo.selecionar,
      clearErro: true,
    );
  }

  void selecionarFazenda(String? id) {
    state = state.copyWith(
      fazendaId: id,
      clearTalhao: true,
      modo: HierarquiaSelecaoModo.selecionar,
      clearErro: true,
    );
  }

  void selecionarTalhao(String? id) {
    state = state.copyWith(
      talhaoId: id,
      modo: HierarquiaSelecaoModo.selecionar,
      clearErro: true,
    );
  }

  void abrirModo(HierarquiaSelecaoModo modo) {
    state = state.copyWith(modo: modo, clearErro: true);
  }

  void cancelarModo() {
    state = state.copyWith(
      modo: HierarquiaSelecaoModo.selecionar,
      clearErro: true,
    );
  }

  Future<bool> criarCliente(String nome) async {
    final normalized = nome.trim();
    if (normalized.isEmpty) {
      state = state.copyWith(erro: 'Informe o nome do cliente.');
      return false;
    }

    final usuarioId = await _waitForCurrentUserId();
    if (usuarioId == null || usuarioId.isEmpty) {
      state = state.copyWith(requiresLogin: true);
      return false;
    }

    state = state.copyWith(isLoading: true, clearErro: true);
    try {
      final now = DateTime.now();
      final id = await _repository.criarCliente(
        ClienteEntity(
          id: '',
          token: TokenGenerator.generate(now: now),
          nome: normalized,
          telefone: '',
          email: '',
          cidade: '',
          estado: '',
          usuarioId: usuarioId,
          criadoEm: now,
          atualizadoEm: now,
        ),
      );
      await _recarregarESelecionar(
        clienteId: id,
        clearFazenda: true,
        clearTalhao: true,
      );
      state = state.copyWith(modo: HierarquiaSelecaoModo.selecionar);
      return true;
    } on ClienteSessionException {
      state = state.copyWith(isLoading: false, requiresLogin: true);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao criar cliente: $e',
      );
      return false;
    }
  }

  Future<bool> criarFazenda({
    required String nome,
    double areaTotal = 0,
  }) async {
    final clienteId = state.clienteId?.trim() ?? '';
    if (clienteId.isEmpty) {
      state = state.copyWith(erro: 'Selecione um cliente primeiro.');
      return false;
    }

    final normalized = nome.trim();
    if (normalized.isEmpty) {
      state = state.copyWith(erro: 'Informe o nome da propriedade.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearErro: true);
    try {
      final fazendaId = await _repository.adicionarFazenda(
        clienteId,
        FazendaEntity(
          id: '',
          nome: normalized,
          areaTotal: areaTotal,
          criadoEm: DateTime.now(),
        ),
      );
      await _recarregarESelecionar(
        clienteId: clienteId,
        fazendaId: fazendaId,
        clearTalhao: true,
      );
      state = state.copyWith(modo: HierarquiaSelecaoModo.selecionar);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao criar propriedade: $e',
      );
      return false;
    }
  }

  Future<bool> criarTalhao({
    required String nome,
    double area = 0,
  }) async {
    final clienteId = state.clienteId?.trim() ?? '';
    final fazendaId = state.fazendaId?.trim() ?? '';
    if (clienteId.isEmpty || fazendaId.isEmpty) {
      state = state.copyWith(erro: 'Selecione cliente e propriedade.');
      return false;
    }

    final normalized = nome.trim();
    if (normalized.isEmpty) {
      state = state.copyWith(erro: 'Informe o nome do talhão.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearErro: true);
    try {
      final talhaoId = await _repository.adicionarTalhao(
        clienteId,
        fazendaId,
        TalhaoEntity(
          id: '',
          nome: normalized,
          area: area,
          criadoEm: DateTime.now(),
        ),
      );
      await _recarregarESelecionar(
        clienteId: clienteId,
        fazendaId: fazendaId,
        talhaoId: talhaoId,
      );
      state = state.copyWith(modo: HierarquiaSelecaoModo.selecionar);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        erro: 'Erro ao criar talhão: $e',
      );
      return false;
    }
  }

  HierarquiaSelecaoResult? buildResult() {
    final cliente = state.clienteAtual;
    final fazenda = state.fazendaAtual;
    final talhao = state.talhaoAtual;
    if (cliente == null || fazenda == null || talhao == null) return null;

    return HierarquiaSelecaoResult(
      clienteId: cliente.id,
      fazendaId: fazenda.id,
      talhaoId: talhao.id,
      clienteNome: cliente.nome,
      fazendaNome: fazenda.nome,
      talhaoNome: talhao.nome,
    );
  }

  Future<void> _recarregarESelecionar({
    required String clienteId,
    String? fazendaId,
    String? talhaoId,
    bool clearFazenda = false,
    bool clearTalhao = false,
  }) async {
    final usuarioId = await _waitForCurrentUserId();
    if (usuarioId == null || usuarioId.isEmpty) {
      state = state.copyWith(isLoading: false, requiresLogin: true);
      return;
    }

    final clientes = await _repository.listarClientes(usuarioId);
    state = state.copyWith(
      clientes: clientes,
      clienteId: clienteId,
      fazendaId: clearFazenda ? null : fazendaId,
      talhaoId: clearTalhao ? null : talhaoId,
      isLoading: false,
      clearErro: true,
    );
  }

  void _aplicarSugestao(HierarquiaSelecaoSugestao sugestao) {
    if (sugestao.isEmpty || state.clientes.isEmpty) return;

    ClienteEntity? cliente;
    for (final item in state.clientes) {
      if (ProdutorResolucaoService.nomesProdutorCompativeis(
        sugestao.produtor,
        item.nome,
      )) {
        cliente = item;
        break;
      }
    }
    if (cliente == null) return;

    FazendaEntity? fazenda;
    if (sugestao.fazenda.trim().isNotEmpty) {
      for (final item in cliente.fazendas) {
        if (_textoCompativel(sugestao.fazenda, item.nome)) {
          fazenda = item;
          break;
        }
      }
    }

    TalhaoEntity? talhao;
    if (fazenda != null && sugestao.talhao.trim().isNotEmpty) {
      for (final item in fazenda.talhoes) {
        if (_textoCompativel(sugestao.talhao, item.nome)) {
          talhao = item;
          break;
        }
      }
    }

    state = state.copyWith(
      clienteId: cliente.id,
      fazendaId: fazenda?.id,
      talhaoId: talhao?.id,
    );
  }

  bool _textoCompativel(String a, String b) {
    final left = a.trim().toLowerCase();
    final right = b.trim().toLowerCase();
    if (left.isEmpty || right.isEmpty) return false;
    return left == right || left.contains(right) || right.contains(left);
  }
}
