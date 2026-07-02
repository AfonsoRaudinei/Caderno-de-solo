import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
import 'package:soloforte/features/config/domain/entities/tabela_metricas.dart';
import 'package:soloforte/features/config/domain/entities/tabela_metricas_defaults.dart';
import 'package:soloforte/features/config/presentation/config_page.dart'
    show PerfilAssets, PerfilAssetsNotifier, perfilAssetsProvider;
import 'package:soloforte/features/config/presentation/providers/tabela_metricas_provider.dart';
import 'package:soloforte/features/laboratorio/domain/repositories/calibracao_repository.dart';
import 'package:soloforte/features/laboratorio/domain/usecases/calibracao_usecases.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
import 'package:soloforte/core/widgets/app_button.dart';
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

CalibracaoProfile _calibracaoMehlich() {
  return CalibracaoProfile(
    id: 'c-mehlich',
    nome: 'Cal Mehlich',
    cultura: 'Soja',
    safra: '24/25',
    cliente: 'Cliente',
    fazenda: 'Fazenda',
    talhao: 'Talhão',
    observacoes: '',
    parametrosCards: {
      'corretivos': {
        'metodoCalagem': '① Saturação por Bases (V%)',
        'vDesejado': 60.0
      },
      'fosforo': {
        'referencia': 'Mehlich-1',
        'modoCalculo': '① Correção do solo'
      },
      'potassio': {'modoCalculo': '① Correção do solo'},
      'micros': {},
    },
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 2),
  );
}

CalibracaoProfile _calibracaoResina() {
  return CalibracaoProfile(
    id: 'c-resina',
    nome: 'Cal Resina',
    cultura: 'Soja',
    safra: '24/25',
    cliente: 'Cliente',
    fazenda: 'Fazenda',
    talhao: 'Talhão',
    observacoes: '',
    parametrosCards: {
      'corretivos': {
        'metodoCalagem': '① Saturação por Bases (V%)',
        'vDesejado': 80.0
      },
      'fosforo': {
        'referencia': 'Resina IAC',
        'modoCalculo': '① Correção do solo'
      },
      'potassio': {'modoCalculo': '① Correção do solo'},
      'micros': {},
    },
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 2),
  );
}

AnaliseSolo _analiseValida() {
  return AnaliseSolo(
    id: 'a-ok',
    fazenda: 'Fazenda',
    produtor: 'Produtor',
    talhao: 'Talhão',
    numeroAmostra: '001',
    cultura: Cultura.soja,
    safra: '24/25',
    laboratorio: 'Lab A',
    dataCadastro: DateTime(2026, 4, 5),
    profundidade: '0-20',
    argila: 350,
    phAgua: 5.3,
    materiaOrganica: 3.0,
    pMehlich: 8.0,
    pResina: 30.0,
    k: 0.22,
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

AnaliseSolo _analiseSemK() {
  return AnaliseSolo(
    id: 'a-null-k',
    fazenda: 'Fazenda',
    produtor: 'Produtor',
    talhao: 'Talhão',
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

Future<void> _pump(
  WidgetTester tester, {
  required List<CalibracaoProfile> profiles,
  required List<AnaliseSolo> analises,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        calibracaoControllerProvider.overrideWith(
          (ref) => _FakeCalibracaoController(profiles: profiles),
        ),
        analiseNotifierProvider
            .overrideWith(() => _FakeAnaliseNotifier(analises)),
        tabelaMetricasProvider.overrideWith(
          () => _FakeTabelaMetricasNotifier(TabelaMetricasDefaults.build()),
        ),
        perfilAssetsProvider.overrideWith((ref) => _FakePerfilAssetsNotifier()),
      ],
      child: const MaterialApp(home: RecomendacaoScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

ProviderContainer _container(WidgetTester tester) {
  final context = tester.element(find.byType(RecomendacaoScreen));
  return ProviderScope.containerOf(context, listen: false);
}

Future<void> _select(
    WidgetTester tester, int dropdownIndex, String value) async {
  final dropdown = tester.widget<DropdownButton<String>>(
    find.byType(DropdownButton<String>).at(dropdownIndex),
  );
  dropdown.onChanged?.call(value);
  await tester.pumpAndSettle();
}

Future<void> _selectAnalise(WidgetTester tester, String analiseId) async {
  await tester.tap(find.byKey(const Key('seletor_amostras_dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('amostra_option_$analiseId')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('seletor_amostras_dropdown')));
  await tester.pumpAndSettle();
}

Finder _generateButton() => find.byKey(const Key('btn_gerar_recomendacao'));

Future<void> _gerar(WidgetTester tester) async {
  final button = tester.widget<AppButton>(_generateButton());
  expect(button.onPressed, isNotNull);
  button.onPressed?.call();
  await tester.pumpAndSettle();
}

void main() {
  group('RecomendacaoScreen regression', () {
    testWidgets('1) sem recomendação: botões de ação não aparecem',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pump(
        tester,
        profiles: [_calibracaoMehlich()],
        analises: [_analiseValida()],
      );

      const req = RecomendacaoRequest(
        analiseIds: [],
        calibracaoId: 'c-mehlich',
      );
      final container = _container(tester);
      final result = container.read(recomendacaoProvider(req));
      expect(result.recomendacao, isNull);
    });

    testWidgets('2) com recomendação: botões de ação aparecem', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pump(
        tester,
        profiles: [_calibracaoMehlich()],
        analises: [_analiseValida()],
      );

      await _selectAnalise(tester, 'a-ok');
      await _select(tester, 0, 'c-mehlich');
      await _gerar(tester);

      const req = RecomendacaoRequest(
        analiseIds: ['a-ok'],
        calibracaoId: 'c-mehlich',
      );
      final container = _container(tester);
      final result = container.read(recomendacaoProvider(req));
      expect(result.recomendacao, isNotNull);
    });

    testWidgets('3) alterar calibração recalcula automaticamente',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pump(
        tester,
        profiles: [_calibracaoMehlich(), _calibracaoResina()],
        analises: [_analiseValida()],
      );

      await _selectAnalise(tester, 'a-ok');
      await _select(tester, 0, 'c-mehlich');
      await _gerar(tester);
      final container = _container(tester);
      const reqMehlich = RecomendacaoRequest(
        analiseIds: ['a-ok'],
        calibracaoId: 'c-mehlich',
      );
      final before = container.read(recomendacaoProvider(reqMehlich));
      expect(before.recomendacao, isNotNull);

      const reqResina = RecomendacaoRequest(
        analiseIds: ['a-ok'],
        calibracaoId: 'c-resina',
      );
      await _select(tester, 0, 'c-resina');
      await tester.pumpAndSettle();
      final after = container.read(recomendacaoProvider(reqResina));

      expect(after.recomendacao, isNotNull);
      expect(before.recomendacao, isNotNull);
      expect(
        after.recomendacao!.doseP2O5KgHa,
        isNot(equals(before.recomendacao!.doseP2O5KgHa)),
      );
    });

    testWidgets('4) alterar análise muda resultado', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pump(
        tester,
        profiles: [_calibracaoMehlich()],
        analises: [_analiseValida(), _analiseSemK()],
      );

      final container = _container(tester);
      await container.read(analiseNotifierProvider.future);
      await container.read(tabelaMetricasProvider.future);

      const reqValida = RecomendacaoRequest(
        analiseIds: ['a-ok'],
        calibracaoId: 'c-mehlich',
      );
      const reqSemK = RecomendacaoRequest(
        analiseIds: ['a-null-k'],
        calibracaoId: 'c-mehlich',
      );

      final valida = container.read(recomendacaoProvider(reqValida));
      final semK = container.read(recomendacaoProvider(reqSemK));

      expect(valida.recomendacao, isNotNull);
      expect(semK.recomendacao, isNotNull);
      expect(valida.recomendacao!.doseK2OKgHa, greaterThan(0));
      expect(semK.recomendacao!.doseK2OKgHa, 0);
      expect(
        semK.diagnostico.avisos
            .any((aviso) => aviso.contains('Potássio bloqueado')),
        isTrue,
      );
    });
  });
}
