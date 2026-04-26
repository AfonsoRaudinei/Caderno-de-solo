import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/presentation/controllers/nova_analise_controller.dart';
import 'package:soloforte/features/analise/presentation/screens/nova_analise_screen.dart';
import 'package:soloforte/features/analise/presentation/widgets/analise_table_widget.dart';
import '../../../../support/analise_test_harness.dart';
import '../../../../support/analise_test_factories.dart';

Future<void> _setGoldenSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void _preencherMinimo(NovaAnaliseController notifier, int index,
    {required String talhao}) {
  notifier.atualizarCampo(index, 'talhao', talhao);
  notifier.atualizarCampo(index, 'profundidade', '0-20');
  notifier.atualizarCampo(index, 'phCaCl2', '5.4');
  notifier.atualizarCampo(index, 'k', '0.31');
  notifier.atualizarCampo(index, 'ca', '3.1');
  notifier.atualizarCampo(index, 'mg', '1.2');
}

Future<void> _setupValidCabecalho(
  ProviderContainer container,
  NovaAnaliseController notifier,
) async {
  notifier.atualizarLaudoProdutor('Produtor');
  notifier.atualizarLaudoFazenda('Fazenda');
  notifier.atualizarLaudoLaboratorio('Sellar');
  notifier.atualizarLaudoSafra('2025/2026');
}

typedef _StateBuilder = Future<void> Function(
  WidgetTester tester,
  ProviderContainer container,
  InMemoryBatchGateway gateway,
);

const _goldenDir = '../../goldens';

void main() {
  final breakpoints = <String, Size>{
    'compact': const Size(375, 812),
    'standard': const Size(430, 932),
  };

  final states = <String, _StateBuilder>{
    'initial': (tester, container, gateway) async {},
    'two_columns': (tester, container, gateway) async {
      final notifier =
          container.read(novaAnaliseControllerProvider(null).notifier);
      await _setupValidCabecalho(container, notifier);
      _preencherMinimo(notifier, 0, talhao: 'T-01');
      notifier.adicionarAnalise();
      _preencherMinimo(notifier, 1, talhao: 'T-02');
      await tester.pumpAndSettle();
    },
    'errors_warnings': (tester, container, gateway) async {
      final notifier =
          container.read(novaAnaliseControllerProvider(null).notifier);
      notifier.atualizarLaudoLaboratorio('Sellar');
      notifier.atualizarLaudoProdutor('Produtor');
      notifier.atualizarLaudoFazenda('Fazenda');
      notifier.atualizarLaudoSafra('2025/2026');
      _preencherMinimo(notifier, 0, talhao: 'T-01');
      notifier.atualizarCampo(0, 'argila', '500');
      notifier.atualizarCampo(0, 'silte', '400');
      notifier.atualizarCampo(0, 'areiaTotal', '50'); // warning de soma
      notifier.adicionarAnalise(); // A2 inválida (sem talhão/numero)
      await tester.pumpAndSettle();
    },
    'highlight': (tester, container, gateway) async {
      final notifier =
          container.read(novaAnaliseControllerProvider(null).notifier);
      notifier.atualizarLaudoLaboratorio('Sellar');
      notifier.atualizarLaudoProdutor('Produtor');
      notifier.atualizarLaudoFazenda('Fazenda');
      notifier.atualizarLaudoSafra('2025/2026');
      _preencherMinimo(notifier, 0, talhao: 'T-01');
      notifier.adicionarAnalise();
      notifier.destacarProximaCelulaInvalida();
      await tester.pumpAndSettle();
    },
    'saving': (tester, container, gateway) async {
      final notifier =
          container.read(novaAnaliseControllerProvider(null).notifier);
      await _setupValidCabecalho(container, notifier);
      _preencherMinimo(notifier, 0, talhao: 'T-01');
      await tester.pumpAndSettle();
      // ignore: invalid_use_of_protected_member
      notifier.state =
          notifier.state.copyWith(isSaving: true, clearError: true);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  };

  for (final bp in breakpoints.entries) {
    for (final state in states.entries) {
      testWidgets(
        'golden nova_analise_${state.key}_${bp.key}',
        (tester) async {
          await _setGoldenSurface(tester, bp.value);
          final gateway = InMemoryBatchGateway();
          final container = makeAnaliseContainer(gateway: gateway);
          addTearDown(container.dispose);

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: const MaterialApp(
                locale: Locale('pt', 'BR'),
                debugShowCheckedModeBanner: false,
                builder: _fixedTextScaleBuilder,
                home: NovaAnaliseScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await state.value(tester, container, gateway);
          await tester.pump(const Duration(milliseconds: 40));

          expect(find.byType(AnaliseTableWidget), findsOneWidget);
          await expectLater(
            find.byType(Scaffold),
            matchesGoldenFile(
              '$_goldenDir/nova_analise_${state.key}_${bp.key}.png',
            ),
          );
          if (state.key == 'saving') {
            await tester.pump(const Duration(milliseconds: 16));
          } else {
            await tester.pumpAndSettle();
          }
        },
      );
    }
  }

  testWidgets('golden preenchido por importação simulada', (tester) async {
    await _setGoldenSurface(tester, const Size(430, 932));
    final gateway = InMemoryBatchGateway();
    final container = makeAnaliseContainer(gateway: gateway);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          builder: _fixedTextScaleBuilder,
          home: NovaAnaliseScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final notifier =
        container.read(novaAnaliseControllerProvider(null).notifier);
    notifier.carregarDeAnaliseSolo([
      makeAnalise(id: 'imp-a1', talhao: 'IMP-01', numeroAmostra: 'A1'),
      makeAnalise(id: 'imp-a2', talhao: 'IMP-02', numeroAmostra: 'A2'),
    ]);
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile(
        '$_goldenDir/nova_analise_imported_standard.png',
      ),
    );
    await tester.pumpAndSettle();
  });
}

Widget _fixedTextScaleBuilder(BuildContext context, Widget? child) {
  final mediaQuery = MediaQuery.of(context);
  return MediaQuery(
    data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1.0)),
    child: child ?? const SizedBox.shrink(),
  );
}
