import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/models/diagnostico_recomendacao.dart';
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

AnaliseSolo _analiseValida() {
  return AnaliseSolo(
    id: 'a-1',
    fazenda: 'Fazenda A',
    produtor: 'Produtor A',
    talhao: 'Talhão A',
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
        analisesVisiveisProvider.overrideWith(
          (ref) => ref.watch(analiseNotifierProvider).valueOrNull ?? const [],
        ),
      ],
      child: const MaterialApp(home: RecomendacaoScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectAnalise(WidgetTester tester, String analiseId) async {
  await tester.tap(find.byKey(const Key('seletor_amostras_dropdown')));
  await tester.pumpAndSettle();

  final checked = find.byIcon(Icons.check_circle);
  for (var i = checked.evaluate().length - 1; i >= 0; i--) {
    await tester.tap(checked.at(i));
    await tester.pumpAndSettle();
  }

  await tester.tap(find.byKey(Key('amostra_option_$analiseId')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('seletor_amostras_dropdown')));
  await tester.pumpAndSettle();
}

Future<void> _selectCalibracao(WidgetTester tester, String value) async {
  final dropdown = tester.widget<DropdownButton<String>>(
    find.byType(DropdownButton<String>),
  );
  final onChanged = dropdown.onChanged;
  expect(onChanged, isNotNull);
  onChanged?.call(value);
  await tester.pumpAndSettle();
}

Future<void> _generate(WidgetTester tester) async {
  final button = tester.widget<AppButton>(
    find.byKey(const Key('btn_gerar_recomendacao')),
  );
  expect(button.onPressed, isNotNull);
  button.onPressed?.call();
  await tester.pumpAndSettle();
}

RecomendacaoResult _readResult(
  WidgetTester tester, {
  List<String> analiseIds = const [],
  String? analiseId,
  required String calibracaoId,
}) {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(RecomendacaoScreen)),
  );
  return container.read(
    recomendacaoProvider(
      RecomendacaoRequest(
        analiseIds: analiseIds,
        analiseId: analiseId,
        calibracaoId: calibracaoId,
      ),
    ),
  );
}

void main() {
  group('Recomendacao flow integration', () {
    void Function(FlutterErrorDetails details)? previousErrorHandler;

    setUp(() {
      previousErrorHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        previousErrorHandler?.call(details);
      };
    });

    tearDown(() {
      FlutterError.onError = previousErrorHandler;
    });

    testWidgets('sucesso: análise + calibração renderiza ações',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pump(tester, profiles: [_profile()], analises: [_analiseValida()]);

      await _selectAnalise(tester, 'a-1');
      await _selectCalibracao(tester, 'c-1');

      final result = _readResult(
        tester,
        analiseIds: ['a-1'],
        calibracaoId: 'c-1',
      );
      expect(result.recomendacao, isNotNull);
      expect(result.diagnostico.valido, isTrue);
      expect(find.text('Compartilhar'), findsNothing);
      expect(find.text('Exportar HTML'), findsNothing);
      expect(find.text('Exportar PDF'), findsNothing);
    });

    testWidgets('analise sem potassio gera aviso e oculta acoes invalidas', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pump(tester, profiles: [_profile()], analises: [_analiseSemK()]);

      await _selectAnalise(tester, 'a-2');
      await _selectCalibracao(tester, 'c-1');

      final result = _readResult(
        tester,
        analiseIds: ['a-2'],
        calibracaoId: 'c-1',
      );
      expect(result.recomendacao, isNotNull);
      expect(
        result.recomendacao!.avisos.any(
          (aviso) => aviso.contains('Potássio bloqueado'),
        ),
        isTrue,
      );
      expect(find.text('Compartilhar'), findsNothing);
      expect(find.text('Exportar HTML'), findsNothing);
      expect(find.text('Exportar PDF'), findsNothing);
    });
  });
}
