import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/features/laboratorio/application/providers/calibracao_controller.dart';
import 'package:soloforte/features/laboratorio/application/providers/calibracao_state.dart';
import 'package:soloforte/features/laboratorio/domain/repositories/calibracao_repository.dart';
import 'package:soloforte/features/laboratorio/domain/usecases/calibracao_usecases.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/corretivos_card.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/micronutrientes_card.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart';

class MockCardChanged extends Mock {
  void call(Map<String, dynamic> value);
}

class FakeCalibracaoController extends CalibracaoController {
  FakeCalibracaoController(CalibracaoState initialState)
      : super(
          carregarCalibracoes: CarregarCalibracoesUsecase(
            _FakeCalibracaoRepository([initialState.draft]),
          ),
          salvarCalibracao: SalvarCalibracaoUsecase(
            _FakeCalibracaoRepository([initialState.draft]),
          ),
          excluirCalibracao: ExcluirCalibracaoUsecase(
            _FakeCalibracaoRepository([initialState.draft]),
          ),
        ) {
    state = initialState;
  }

  @override
  Future<void> load() async {}

  @override
  Future<bool> salvar({bool salvarComoNovo = false}) async => true;
}

class _FakeCalibracaoRepository implements CalibracaoRepository {
  _FakeCalibracaoRepository(this._profiles);

  List<CalibracaoProfile> _profiles;

  @override
  Future<List<CalibracaoProfile>> carregarPerfis() async => _profiles;

  @override
  Future<void> salvarPerfis({
    required List<CalibracaoProfile> perfis,
    required CalibracaoProfile perfilSincronizar,
  }) async {
    _profiles = perfis;
  }

  @override
  Future<void> excluirPerfil({
    required List<CalibracaoProfile> perfisRestantes,
    required String perfilId,
  }) async {
    _profiles = perfisRestantes;
  }
}

Widget makeTestable(Widget child, {CalibracaoState? state}) {
  final testState = state ?? estadoBase();
  return ProviderScope(
    overrides: [
      calibracaoControllerProvider.overrideWith(
        (_) => FakeCalibracaoController(testState),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    ),
  );
}

class ExpandableCardHost extends StatefulWidget {
  const ExpandableCardHost({
    super.key,
    required this.builder,
    this.initialExpanded = false,
  });

  final bool initialExpanded;
  final Widget Function(bool isExpanded, VoidCallback toggle) builder;

  @override
  State<ExpandableCardHost> createState() => _ExpandableCardHostState();
}

class _ExpandableCardHostState extends State<ExpandableCardHost> {
  late bool _expanded = widget.initialExpanded;

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      _expanded,
      () => setState(() => _expanded = !_expanded),
    );
  }
}

CalibracaoProfile perfilBase({
  Map<String, dynamic>? parametrosCards,
}) {
  return CalibracaoProfile(
    id: 'test-profile',
    nome: 'Perfil teste',
    cultura: 'Soja',
    safra: '2026',
    cliente: 'Cliente',
    fazenda: 'Fazenda',
    talhao: 'Talhão',
    observacoes: '',
    parametrosCards: parametrosCards ?? parametrosCardsBase(),
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 2),
    produtividadeEsperadaTha: 3.6,
  );
}

CalibracaoState estadoBase({
  Map<String, dynamic>? parametrosCards,
}) {
  final draft = perfilBase(parametrosCards: parametrosCards);
  return CalibracaoState(
    loading: false,
    saving: false,
    profiles: [draft],
    selectedProfileId: draft.id,
    draft: draft,
  );
}

Map<String, dynamic> parametrosCardsBase() {
  return {
    'corretivos': corretivosBase(),
    'fosforo': fosforoBase(),
    'potassio': potassioBase(),
    'micros': microsBase(),
  };
}

Map<String, dynamic> corretivosBase() {
  return {
    'tipoCalagem': 'Corretiva',
    'metodoCalagem': 'saturacaoV',
    'tipoCalcario': 'Dolomítico',
    'cao': null,
    'mgo': null,
    'pn': null,
    're': null,
    'prnt': null,
    'calcario1': {
      'tipo': 'Dolomítico',
      'caO': null,
      'mgO': null,
      'pn': null,
      're': null,
      'prnt': null,
    },
    'usarNivelCritico': false,
    'caDesejadoPct': null,
    'mgDesejadoPct': null,
    'kDesejadoPct': null,
    'ncCa': null,
    'ncMg': null,
    'ncK': null,
    'albrecht': {
      'caAlvo': null,
      'mgAlvo': null,
      'kAlvo': null,
      'ncCa': 2.0,
      'ncMg': 0.8,
      'ncK': 0.15,
    },
    'metodoIncorporacao': 'Grade pesada',
    'mesAplicacao': 'Fevereiro',
    'usarGesso': false,
  };
}

Map<String, dynamic> fosforoBase() {
  return {
    'extrator': 'Mehlich-1',
    'referencia': 'Embrapa Cerrado',
    'nc': 15.0,
    'ncModoManual': false,
    'camada': '0–20 cm',
    'modoCalculo': 'Correção do solo',
    'percentualUsoPSolo': 100.0,
  };
}

Map<String, dynamic> potassioBase() {
  return {
    'extrator': 'Mehlich-1',
    'referencia': 'Embrapa Cerrado',
    'camada': '0–20 cm',
    'corrigirSolo': true,
    'metodoCorrecao': 'nivel_critico',
    'criterioNc': 'Teor absoluto',
    'ncTeor': 46.0,
    'ncTeorManual': false,
    'ncPctCtc': 3.0,
    'percentualKObjetivoCtc': 3.0,
    'ncCtcManual': false,
    'reposicaoPotassio': 'nenhuma',
    'modoCalculo': 'Correção do solo',
    'ajusteEficienciaSolo': 15.0,
    'fekBase': 15.0,
  };
}

Map<String, dynamic> microsBase({
  List<Map<String, dynamic>> grupos = const [],
}) {
  return {
    'pH': 5.8,
    'elementos': <String, dynamic>{
      for (final simbolo in [
        'B',
        'Cu',
        'Fe',
        'Mn',
        'Zn',
        'Mo',
        'Co',
        'Ni',
        'Se'
      ])
        simbolo: {
          'simbolo': simbolo,
          'extrator': 'DTPA-TEA',
          'referencia': '06 — Micronutrientes: Motor de Cálculo',
          'referenciaNc': '06 — Micronutrientes: Motor de Cálculo',
          'ncSolo': 1.0,
          'ncUnidade': 'mg/dm³',
          'viaAplicacao': 'Solo (correção)',
          'viasAplicacao': ['Solo'],
          'referenciaAbsorcaoTipo': 'Autores',
          'referenciaAbsorcaoNome': 'Malavolta (1997)',
          'tipoFonte': 'Autores',
          'autor': 'Malavolta (1997)',
          'extracaoPlanta': 0.0,
          'exportacaoGraos': 0.0,
          'concentracaoFonte': 0.0,
          'concentracaoUnidade': '%',
          'doseMinima': 0.0,
          'doseMaxima': 0.0,
          'limiteToxicidade': 0.0,
          'percentualCorrecaoSolo': 100.0,
          'fonteSolo': '',
          'teorFonteSolo': 0.0,
          'eficienciaSolo': 30.0,
          'fonteFoliar': '',
          'eficienciaFoliar': 70.0,
          'fonteTs': '',
          'doseTs': 0.0,
        },
    },
    'grupos': grupos,
  };
}

Map<String, dynamic> mergeCard(
  Map<String, dynamic> base,
  Map<String, dynamic> patch,
) {
  return {...base, ...patch};
}

Widget corretivosCard({
  Map<String, dynamic>? corretivos,
  bool initialExpanded = false,
}) {
  final draft = perfilBase();
  final data = corretivos ?? corretivosBase();
  return ExpandableCardHost(
    initialExpanded: initialExpanded,
    builder: (expanded, toggle) => CorretivosCard(
      draft: draft,
      draftKey: 'test-corretivos',
      corretivos: data,
      isExpanded: expanded,
      onToggle: toggle,
      onChanged: (_) {},
    ),
  );
}

Widget fosforoCard({
  Map<String, dynamic>? fosforo,
  bool initialExpanded = false,
}) {
  return ExpandableCardHost(
    initialExpanded: initialExpanded,
    builder: (expanded, toggle) => FosforoCard(
      key: ValueKey('fosforo-${fosforo.hashCode}-$expanded'),
      initialData: fosforo ?? fosforoBase(),
      cultura: 'Soja',
      isExpanded: expanded,
      onToggle: toggle,
      onChanged: (_) {},
    ),
  );
}

Widget potassioCard({
  Map<String, dynamic>? potassio,
  bool initialExpanded = false,
}) {
  return ExpandableCardHost(
    initialExpanded: initialExpanded,
    builder: (expanded, toggle) => PotassioCard(
      key: ValueKey('potassio-${potassio.hashCode}-$expanded'),
      initialData: potassio ?? potassioBase(),
      cultura: 'Soja',
      isExpanded: expanded,
      onToggle: toggle,
      onChanged: (_) {},
    ),
  );
}

Widget micronutrientesCard({
  Map<String, dynamic>? micros,
  bool initialExpanded = false,
}) {
  final data = micros ?? microsBase();
  final elementos = Map<String, dynamic>.from(data['elementos'] as Map);
  final grupos = ((data['grupos'] as List?) ?? const [])
      .whereType<Map>()
      .map(
          (entry) => entry.map((key, value) => MapEntry(key.toString(), value)))
      .toList();
  return ExpandableCardHost(
    initialExpanded: initialExpanded,
    builder: (expanded, toggle) => MicronutrientesCard(
      draftKey: 'test-micros',
      micros: data,
      elementos: elementos,
      grupos: grupos,
      isExpanded: expanded,
      onToggle: toggle,
      onChanged: (_) {},
    ),
  );
}

Future<void> pumpCard(WidgetTester tester, Widget card) async {
  await tester.pumpWidget(makeTestable(card));
  await tester.pumpAndSettle();
}

Future<void> expandCard(WidgetTester tester, String title) async {
  await tester.tap(find.textContaining(title).first);
  await tester.pumpAndSettle();
}

bool hasContainerColor(WidgetTester tester, Color color) {
  return tester.widgetList<Container>(find.byType(Container)).any((container) {
    final decoration = container.decoration;
    return decoration is BoxDecoration && decoration.color == color;
  });
}

String allText(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data ?? text.textSpan?.toPlainText() ?? '')
      .where((text) => text.isNotEmpty)
      .join(' ');
}

void verificarSemSeparadorOrfao(WidgetTester tester) {
  final textos = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data?.trim() ?? t.textSpan?.toPlainText().trim() ?? '')
      .where((t) => t.isNotEmpty)
      .toList();
  for (final t in textos) {
    expect(
      t.startsWith('·'),
      isFalse,
      reason: 'Separador órfão no início: "$t"',
    );
    expect(
      t.endsWith('·'),
      isFalse,
      reason: 'Separador órfão no fim: "$t"',
    );
  }
}
