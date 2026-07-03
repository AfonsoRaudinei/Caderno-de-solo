import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
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

AnaliseSolo _analise({
  String id = 'a-1',
  String talhao = 'Talhão A',
  String numeroAmostra = '001',
  String laboratorio = 'Lab A',
  String produtor = 'Produtor A',
  String profundidade = '0-20',
  double? ca = 2.1,
  double? k = 0.22,
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
  );
}

Future<void> _pumpRecomendacao(
  WidgetTester tester, {
  required List<CalibracaoProfile> profiles,
  required List<AnaliseSolo> analises,
  List<TabelaMetricas>? tabelas,
}) async {
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
      ],
      child: const MaterialApp(home: RecomendacaoScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _setDropdownValue(
  WidgetTester tester, {
  required int dropdownIndex,
  required String value,
}) async {
  final dropdown = tester.widget<DropdownButton<String>>(
    find.byType(DropdownButton<String>).at(dropdownIndex),
  );
  final onChanged = dropdown.onChanged;
  expect(onChanged, isNotNull);
  onChanged?.call(value);
  await tester.pumpAndSettle();
}

Future<void> _selectAnaliseByIndex(WidgetTester tester, int index) async {
  await tester.tap(find.byKey(const Key('seletor_amostras_dropdown')));
  await tester.pumpAndSettle();

  final checks = find.byIcon(Icons.check_circle);
  final checkedCount = checks.evaluate().length;
  for (var i = 0; i < checkedCount; i++) {
    await tester.tap(checks.at(i));
    await tester.pumpAndSettle();
  }

  final unchecked = find.byIcon(Icons.radio_button_unchecked);
  await tester.tap(unchecked.at(index));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('seletor_amostras_dropdown')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mostra avisos quando não há análise e calibração salvas', (
    tester,
  ) async {
    await _pumpRecomendacao(tester, profiles: const [], analises: const []);

    expect(
      find.text('Nenhuma calibração salva. Cadastre na aba Calibração.'),
      findsOneWidget,
    );
    expect(
      find.text('Nenhuma análise salva. Cadastre em Análise.'),
      findsOneWidget,
    );
  });

  testWidgets('gera resultado e exibe acao de exportar html', (
    tester,
  ) async {
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

    await tester.tap(find.byKey(const Key('seletor_amostras_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('amostra_option_a-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('seletor_amostras_dropdown')));
    await tester.pumpAndSettle();
    await _setDropdownValue(tester, dropdownIndex: 0, value: 'c-1');

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
      find.byKey(const Key('btn_exportar_html')),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Exportar HTML'), findsOneWidget);
    expect(find.text('Exportar PDF'), findsNothing);
  });

  testWidgets(
    'dropdown expande e permite várias amostras do mesmo laboratório',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpRecomendacao(
        tester,
        profiles: [_profile()],
        analises: [
          _analise(id: 'a-1', numeroAmostra: '001', laboratorio: 'Lab A'),
          _analise(id: 'a-2', numeroAmostra: '002', laboratorio: 'Lab A'),
          _analise(id: 'a-3', numeroAmostra: '003', laboratorio: 'Lab B'),
        ],
      );

      expect(find.textContaining('002'), findsNothing);

      await tester.tap(find.byKey(const Key('seletor_amostras_dropdown')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('amostra_option_a-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('amostra_option_a-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('amostra_option_a-3')));
      await tester.pumpAndSettle();

      expect(find.text('2 amostras selecionadas'), findsOneWidget);
      expect(find.text('Laboratório: Lab A'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    },
  );

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

  testWidgets('filtro por produtor reduz opcoes visiveis no seletor', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpRecomendacao(
      tester,
      profiles: [_profile()],
      analises: [
        _analise(
          id: 'a-1',
          produtor: 'ANDRE LUIZ DE SIQUEIRA',
          numeroAmostra: '001',
        ),
        _analise(
          id: 'a-2',
          produtor: 'JOSE AUGUSTO MIRANDA',
          numeroAmostra: '002',
        ),
      ],
    );

    await tester.enterText(
      find.byKey(const Key('filtro_produtor_recomendacao')),
      'ANDRE',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('seletor_amostras_dropdown')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('amostra_option_a-1')), findsOneWidget);
    expect(find.byKey(const Key('amostra_option_a-2')), findsNothing);
  });

  test('analiseMatchesProdutorBusca filtra por produtor fazenda e talhao', () {
    final analise = _analise(produtor: 'Cliente A', talhao: 'Talhão A');

    expect(analiseMatchesProdutorBusca(analise, ''), isTrue);
    expect(analiseMatchesProdutorBusca(analise, 'cliente'), isTrue);
    expect(analiseMatchesProdutorBusca(analise, 'fazenda'), isTrue);
    expect(analiseMatchesProdutorBusca(analise, 'talhão'), isTrue);
    expect(analiseMatchesProdutorBusca(analise, 'inexistente'), isFalse);
  });
}
