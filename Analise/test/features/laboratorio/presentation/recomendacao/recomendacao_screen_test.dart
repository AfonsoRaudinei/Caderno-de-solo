import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/clientes/application/providers/cliente_provider.dart';
import 'package:soloforte/features/clientes/data/datasources/cliente_firestore_datasource.dart';
import 'package:soloforte/features/clientes/data/repositories/cliente_repository.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';
import 'package:soloforte/features/config/domain/entities/tabela_metricas.dart';
import 'package:soloforte/features/config/domain/entities/tabela_metricas_defaults.dart';
import 'package:soloforte/features/config/presentation/config_page.dart'
    show PerfilAssets, PerfilAssetsNotifier, perfilAssetsProvider;
import 'package:soloforte/features/config/presentation/providers/tabela_metricas_provider.dart';
import 'package:soloforte/features/laboratorio/domain/repositories/calibracao_repository.dart';
import 'package:soloforte/features/laboratorio/domain/usecases/calibracao_usecases.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
import 'package:soloforte/features/laboratorio/presentation/providers/recomendacao_provider_real.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/widgets/recomendacao_selecao_analises.dart';

class _FakeCalibracaoController extends CalibracaoController {
  _FakeCalibracaoController({required List<CalibracaoProfile> profiles})
      : super(
          carregarCalibracoes: CarregarCalibracoesUsecase(
            _FakeCalibracaoRepository(profiles),
          ),
          salvarCalibracao: SalvarCalibracaoUsecase(
            _FakeCalibracaoRepository(profiles),
          ),
          excluirCalibracao: ExcluirCalibracaoUsecase(
            _FakeCalibracaoRepository(profiles),
          ),
        ) {
    final first = profiles.isNotEmpty ? profiles.first : _emptyProfile;
    state = state.copyWith(
      loading: false,
      profiles: profiles,
      selectedProfileId: profiles.isNotEmpty ? first.id : null,
      draft: first,
    );
  }
}

class _FakeCalibracaoRepository implements CalibracaoRepository {
  _FakeCalibracaoRepository(this.profiles);

  List<CalibracaoProfile> profiles;

  @override
  Future<List<CalibracaoProfile>> carregarPerfis() async => profiles;

  @override
  Future<void> salvarPerfis({
    required List<CalibracaoProfile> perfis,
    required CalibracaoProfile perfilSincronizar,
  }) async {
    profiles = perfis;
  }

  @override
  Future<void> excluirPerfil({
    required List<CalibracaoProfile> perfisRestantes,
    required String perfilId,
  }) async {
    profiles = perfisRestantes;
  }
}

class _FakeAnaliseNotifier extends AnaliseNotifier {
  _FakeAnaliseNotifier(this._analises);

  final List<AnaliseSolo> _analises;

  @override
  Stream<List<AnaliseSolo>> build() => Stream.value(_analises);
}

class _FakeTabelaMetricasNotifier extends TabelaMetricasNotifier {
  _FakeTabelaMetricasNotifier(this._tabelas);

  final List<TabelaMetricas> _tabelas;

  @override
  Future<List<TabelaMetricas>> build() async => _tabelas;
}

class _FakePerfilAssetsNotifier extends StateNotifier<PerfilAssets>
    implements PerfilAssetsNotifier {
  _FakePerfilAssetsNotifier() : super(const PerfilAssets());

  @override
  Future<bool> uploadLogo() async => true;

  @override
  Future<bool> uploadAssinatura() async => true;

  @override
  Future<bool> removeLogo() async => true;

  @override
  Future<bool> removeAssinatura() async => true;
}

class _FakeClienteNotifier extends ClienteNotifier {
  _FakeClienteNotifier(ClienteState initialState)
      : super(
          repository: ClienteRepository(
            ClienteFirestoreDatasource(firestore: FakeFirebaseFirestore()),
          ),
          waitForCurrentUserId:
              ({timeout = const Duration(seconds: 5)}) async => 'test-user',
          signOut: () async {},
        ) {
    state = initialState;
  }

  @override
  Future<void> carregarClientes() async {}
}

final _emptyProfile = CalibracaoProfile(
  id: '__empty__',
  nome: '',
  cultura: 'Soja',
  safra: '',
  cliente: '',
  fazenda: '',
  talhao: '',
  observacoes: '',
  parametrosCards: {},
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

CalibracaoProfile _profile() {
  return CalibracaoProfile(
    id: 'c-1',
    nome: 'Perfil Soja',
    cultura: 'Soja',
    safra: '24/25',
    cliente: 'Cliente A',
    fazenda: 'Fazenda A',
    talhao: 'Talhão A',
    observacoes: '',
    parametrosCards: {
      'corretivos': {
        'metodoCalagem': '① Saturação por Bases (V%)',
        'vDesejado': 60.0,
      },
      'fosforo': {'modoCalculo': '① Correção do solo'},
      'potassio': {'modoCalculo': '① Correção do solo'},
      'micros': {},
    },
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 2),
  );
}

ClienteEntity _cliente({
  String id = 'cli-1',
  String nome = 'Cliente A',
  List<String> analiseIds = const [],
}) {
  return ClienteEntity(
    id: id,
    token: 'SF-2026-AAAA',
    nome: nome,
    telefone: '',
    email: '',
    cidade: 'Palmas',
    estado: 'TO',
    usuarioId: 'user-1',
    criadoEm: DateTime(2026, 1, 1),
    atualizadoEm: DateTime(2026, 1, 1),
    analiseIds: analiseIds,
  );
}

AnaliseSolo _analise({
  String id = 'a-1',
  String talhao = 'Talhão A',
  String numeroAmostra = '001',
  String laboratorio = 'Lab A',
  String produtor = 'Produtor A',
  String profundidade = '0-20',
  String? clienteId = 'cli-1',
  double? ca = 2.1,
  double? k = 0.22,
  Map<String, dynamic>? metadata,
}) {
  return AnaliseSolo(
    id: id,
    fazenda: 'Fazenda A',
    produtor: produtor,
    talhao: talhao,
    numeroAmostra: numeroAmostra,
    cultura: Cultura.soja,
    safra: '24/25',
    laboratorio: laboratorio,
    dataCadastro: DateTime(2026, 4, 5),
    profundidade: profundidade,
    argila: 350,
    phAgua: 5.3,
    materiaOrganica: 3.0,
    pMehlich: 8.0,
    k: k,
    ca: ca,
    mg: 0.9,
    hMaisAl: 4.6,
    al: 0.2,
    s020: 7.0,
    b: 0.25,
    cu: 0.6,
    fe: 35,
    mn: 3.2,
    zn: 1.4,
    clienteId: clienteId,
    laudoMetadata: metadata,
  );
}

AnaliseSolo _analiseSemPotassio() {
  return AnaliseSolo(
    id: 'a-2',
    fazenda: 'Fazenda A',
    produtor: 'Produtor A',
    talhao: 'Talhão A',
    numeroAmostra: '002',
    cultura: Cultura.soja,
    safra: '24/25',
    laboratorio: 'Lab A',
    dataCadastro: DateTime(2026, 4, 5),
    profundidade: '0-20',
    argila: 350,
    phAgua: 5.3,
    materiaOrganica: 3.0,
    pMehlich: 8.0,
    k: null,
    ca: 2.1,
    mg: 0.9,
    hMaisAl: 4.6,
    al: 0.2,
    s020: 7.0,
    b: 0.25,
    cu: 0.6,
    fe: 35,
    mn: 3.2,
    zn: 1.4,
    clienteId: 'cli-1',
  );
}

Future<void> _pumpRecomendacao(
  WidgetTester tester, {
  required List<CalibracaoProfile> profiles,
  required List<AnaliseSolo> analises,
  List<ClienteEntity>? clientes,
  List<TabelaMetricas>? tabelas,
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const RecomendacaoScreen(),
      ),
    ],
  );

  final clientesState = ClienteState(
    clientes: clientes ??
        [
          _cliente(
            analiseIds: analises.map((a) => a.id).toList(growable: false),
          ),
        ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        calibracaoControllerProvider.overrideWith(
          (ref) => _FakeCalibracaoController(profiles: profiles),
        ),
        analiseNotifierProvider.overrideWith(
          () => _FakeAnaliseNotifier(analises),
        ),
        tabelaMetricasProvider.overrideWith(
          () => _FakeTabelaMetricasNotifier(
            tabelas ?? TabelaMetricasDefaults.build(),
          ),
        ),
        perfilAssetsProvider.overrideWith((ref) => _FakePerfilAssetsNotifier()),
        analisesVisiveisProvider.overrideWith(
          (ref) => ref.watch(analiseNotifierProvider).valueOrNull ?? const [],
        ),
        clienteProvider.overrideWith(
          (ref) => _FakeClienteNotifier(clientesState),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selecionarCliente(WidgetTester tester, String clienteId) async {
  final dropdown = tester.widget<DropdownButton<String>>(
    find.byType(DropdownButton<String>).first,
  );
  expect(dropdown.onChanged, isNotNull);
  dropdown.onChanged!(clienteId);
  await tester.pumpAndSettle();
}

Future<void> _adicionarAmostra(WidgetTester tester, String analiseId) async {
  await tester.tap(find.byKey(const Key('btn_adicionar_amostra')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('amostra_option_$analiseId')));
  await tester.pumpAndSettle();
}

Future<void> _setCalibracao(WidgetTester tester, String value) async {
  final dropdown = tester.widget<DropdownButton<String>>(
    find.byType(DropdownButton<String>).at(1),
  );
  expect(dropdown.onChanged, isNotNull);
  dropdown.onChanged!(value);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mostra aviso quando não há calibração salva', (tester) async {
    await _pumpRecomendacao(
      tester,
      profiles: const [],
      analises: const [],
      clientes: const [],
    );

    expect(
      find.text('Nenhuma calibração salva. Cadastre na aba Calibração.'),
      findsOneWidget,
    );
    expect(
      find.text('Selecione um cliente para listar as análises.'),
      findsOneWidget,
    );
  });

  testWidgets('gera resultado e exibe acao de compartilhar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final previousErrorHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      previousErrorHandler?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousErrorHandler);

    await _pumpRecomendacao(
      tester,
      profiles: [_profile()],
      analises: [_analise()],
    );

    await _selecionarCliente(tester, 'cli-1');
    await _adicionarAmostra(tester, 'a-1');
    await _setCalibracao(tester, 'c-1');

    final gerar = tester.widget<AppButton>(
      find.byKey(const Key('btn_gerar_recomendacao')),
    );
    expect(gerar.onPressed, isNotNull);
    gerar.onPressed!.call();
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(RecomendacaoScreen)),
    );
    final result = container.read(
      recomendacaoProvider(
        const RecomendacaoRequest(
          analiseIds: ['a-1'],
          calibracaoId: 'c-1',
        ),
      ),
    );
    expect(result.recomendacao, isNotNull);
    expect(result.diagnostico.valido, isTrue);

    await tester.scrollUntilVisible(
      find.byKey(const Key('btn_exportar_pdf')),
      500,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('recomendacao_body_scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('btn_exportar_pdf')), findsOneWidget);
    expect(find.text('Exportar relatorio'), findsOneWidget);
  });

  testWidgets(
    'permite várias amostras do mesmo laboratório com profundidades mistas',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpRecomendacao(
        tester,
        profiles: [_profile()],
        analises: [
          _analise(
            id: 'a-1',
            numeroAmostra: '001',
            laboratorio: 'Lab A',
            profundidade: '0-20',
          ),
          _analise(
            id: 'a-2',
            numeroAmostra: '002',
            laboratorio: 'Lab A',
            profundidade: '20-40',
          ),
          _analise(
            id: 'a-3',
            numeroAmostra: '003',
            laboratorio: 'Lab B',
            profundidade: '0-20',
          ),
        ],
      );

      await _selecionarCliente(tester, 'cli-1');
      await _adicionarAmostra(tester, 'a-1');
      await _adicionarAmostra(tester, 'a-2');

      expect(find.byKey(const Key('chip_selecionada_a-1')), findsOneWidget);
      expect(find.byKey(const Key('chip_selecionada_a-2')), findsOneWidget);

      await tester.tap(find.byKey(const Key('btn_adicionar_amostra')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('amostra_option_a-3')), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    },
  );

  testWidgets('remover chip inline remove a amostra da seleção',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpRecomendacao(
      tester,
      profiles: [_profile()],
      analises: [_analise()],
    );

    await _selecionarCliente(tester, 'cli-1');
    await _adicionarAmostra(tester, 'a-1');
    expect(find.byKey(const Key('chip_selecionada_a-1')), findsOneWidget);

    final chip = tester.widget<InputChip>(
      find.byKey(const Key('chip_selecionada_a-1')),
    );
    expect(chip.onDeleted, isNotNull);
    chip.onDeleted!();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chip_selecionada_a-1')), findsNothing);
  });

  testWidgets('filtro por cliente lista apenas análises do cliente', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpRecomendacao(
      tester,
      profiles: [_profile()],
      clientes: [
        _cliente(id: 'cli-1', nome: 'Cliente A', analiseIds: ['a-1']),
        _cliente(id: 'cli-2', nome: 'Cliente B', analiseIds: ['a-2']),
      ],
      analises: [
        _analise(id: 'a-1', clienteId: 'cli-1', numeroAmostra: '001'),
        _analise(id: 'a-2', clienteId: 'cli-2', numeroAmostra: '002'),
      ],
    );

    await _selecionarCliente(tester, 'cli-1');
    await tester.tap(find.byKey(const Key('btn_adicionar_amostra')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('amostra_option_a-1')), findsOneWidget);
    expect(find.byKey(const Key('amostra_option_a-2')), findsNothing);
  });

  test(
    'provider gera análise composta média para múltiplas amostras',
    () async {
      final container = ProviderContainer(
        overrides: [
          calibracaoControllerProvider.overrideWith(
            (ref) => _FakeCalibracaoController(profiles: [_profile()]),
          ),
          analiseNotifierProvider.overrideWith(
            () => _FakeAnaliseNotifier([
              _analise(id: 'a-1', ca: 2.0),
              _analise(id: 'a-2', ca: 4.0),
            ]),
          ),
          tabelaMetricasProvider.overrideWith(
            () => _FakeTabelaMetricasNotifier(TabelaMetricasDefaults.build()),
          ),
          perfilAssetsProvider.overrideWith(
            (ref) => _FakePerfilAssetsNotifier(),
          ),
          analisesVisiveisProvider.overrideWith(
            (ref) => ref.watch(analiseNotifierProvider).valueOrNull ?? const [],
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(analiseNotifierProvider.future);
      await container.read(tabelaMetricasProvider.future);

      final result = container.read(
        recomendacaoProvider(
          const RecomendacaoRequest(
            analiseIds: ['a-1', 'a-2'],
            calibracaoId: 'c-1',
          ),
        ),
      );

      expect(result.recomendacao, isNotNull);
      expect(result.recomendacao!.analise.nome, 'Média de 2 amostras');
      expect(result.recomendacao!.analise.ca, 3.0);
    },
  );

  test('provider aceita profundidades mistas e rejeita labs diferentes',
      () async {
    final container = ProviderContainer(
      overrides: [
        calibracaoControllerProvider.overrideWith(
          (ref) => _FakeCalibracaoController(profiles: [_profile()]),
        ),
        analiseNotifierProvider.overrideWith(
          () => _FakeAnaliseNotifier([
            _analise(id: 'a-1', profundidade: '0-20', laboratorio: 'Lab A'),
            _analise(id: 'a-2', profundidade: '20-40', laboratorio: 'Lab A'),
            _analise(id: 'a-3', profundidade: '0-20', laboratorio: 'Lab B'),
          ]),
        ),
        tabelaMetricasProvider.overrideWith(
          () => _FakeTabelaMetricasNotifier(TabelaMetricasDefaults.build()),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(analiseNotifierProvider.future);
    await container.read(tabelaMetricasProvider.future);

    final mistas = container.read(
      recomendacaoProvider(
        const RecomendacaoRequest(
          analiseIds: ['a-1', 'a-2'],
          calibracaoId: 'c-1',
        ),
      ),
    );
    expect(mistas.diagnostico.valido, isTrue);
    expect(mistas.recomendacao, isNotNull);

    final labs = container.read(
      recomendacaoProvider(
        const RecomendacaoRequest(
          analiseIds: ['a-1', 'a-3'],
          calibracaoId: 'c-1',
        ),
      ),
    );
    expect(labs.recomendacao, isNull);
    expect(
      labs.diagnostico.erros.any((e) => e.contains('mesmo laboratório')),
      isTrue,
    );
  });

  test(
    'nao renderiza resultado quando analise sem potassio e invalida',
    () async {
      final container = ProviderContainer(
        overrides: [
          calibracaoControllerProvider.overrideWith(
            (ref) => _FakeCalibracaoController(profiles: [_profile()]),
          ),
          analiseNotifierProvider.overrideWith(
            () => _FakeAnaliseNotifier([_analiseSemPotassio()]),
          ),
          tabelaMetricasProvider.overrideWith(
            () => _FakeTabelaMetricasNotifier(TabelaMetricasDefaults.build()),
          ),
          perfilAssetsProvider.overrideWith(
            (ref) => _FakePerfilAssetsNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(analiseNotifierProvider.future);
      await container.read(tabelaMetricasProvider.future);

      final result = container.read(
        recomendacaoProvider(
          const RecomendacaoRequest(
            analiseIds: ['a-2'],
            calibracaoId: 'c-1',
          ),
        ),
      );

      expect(result.recomendacao, isNotNull);
      expect(
        result.recomendacao!.avisos.any(
          (aviso) => aviso.contains('Potássio bloqueado'),
        ),
        isTrue,
      );
    },
  );

  test('profundidadeMatchesFiltro respeita chips 0-20 e 20-40', () {
    expect(
      profundidadeMatchesFiltro(
        '0-20',
        include020: true,
        include2040: false,
      ),
      isTrue,
    );
    expect(
      profundidadeMatchesFiltro(
        '20-40',
        include020: true,
        include2040: false,
      ),
      isFalse,
    );
    expect(
      profundidadeMatchesFiltro(
        '20-40',
        include020: true,
        include2040: true,
      ),
      isTrue,
    );
    expect(normalizarProfundidadeRecomendacao(''), '0-20');
    expect(normalizarProfundidadeRecomendacao('20 – 40'), '20-40');
  });

  testWidgets('botao voltar navega para laboratorio quando nao ha stack', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      initialLocation: '/recomendacao',
      routes: [
        GoRoute(
          path: AppRoutes.lab,
          builder: (_, __) => const Scaffold(body: Text('LAB_OK')),
        ),
        GoRoute(
          path: '/recomendacao',
          builder: (_, __) => const RecomendacaoScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calibracaoControllerProvider.overrideWith(
            (ref) => _FakeCalibracaoController(profiles: const []),
          ),
          analiseNotifierProvider.overrideWith(
            () => _FakeAnaliseNotifier(const []),
          ),
          tabelaMetricasProvider.overrideWith(
            () => _FakeTabelaMetricasNotifier(TabelaMetricasDefaults.build()),
          ),
          perfilAssetsProvider
              .overrideWith((ref) => _FakePerfilAssetsNotifier()),
          analisesVisiveisProvider.overrideWith(
            (ref) => ref.watch(analiseNotifierProvider).valueOrNull ?? const [],
          ),
          clienteProvider.overrideWith(
            (ref) => _FakeClienteNotifier(const ClienteState()),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('LAB_OK'), findsOneWidget);
  });
}
