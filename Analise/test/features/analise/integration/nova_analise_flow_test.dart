import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/features/analise/presentation/controllers/nova_analise_controller.dart';
import 'package:soloforte/features/analise/presentation/screens/nova_analise_screen.dart';
import 'package:soloforte/features/analise/presentation/widgets/analise_table_widget.dart';

import '../../../support/analise_test_harness.dart';
import '../../../support/analise_test_factories.dart';

void _fillMin(NovaAnaliseController notifier, int index,
    {required String talhao}) {
  notifier.atualizarCampo(index, 'talhao', talhao);
  notifier.atualizarCampo(index, 'profundidade', '0-20');
  notifier.atualizarCampo(index, 'phCaCl2', '5.4');
  notifier.atualizarCampo(index, 'k', '0.31');
  notifier.atualizarCampo(index, 'ca', '3.1');
  notifier.atualizarCampo(index, 'mg', '1.2');
}

void _fillCabecalho(NovaAnaliseController notifier) {
  notifier.atualizarLaudoProdutor('Produtor');
  notifier.atualizarLaudoFazenda('Fazenda');
  notifier.atualizarLaudoLaboratorio('Sellar');
  notifier.atualizarLaudoSafra('2025/2026');
}

Widget _buildApp(ProviderContainer container) {
  final router = GoRouter(
    initialLocation: '/nova',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(body: SizedBox.shrink()),
      ),
      GoRoute(
        path: '/nova',
        builder: (_, __) => const NovaAnaliseScreen(),
      ),
    ],
  );

  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('NovaAnálise fluxo completo (integração headless)', () {
    testWidgets(
        'A1 válido + A2 incompleto salva com warning sem meio estado',
        (tester) async {
      final gateway = InMemoryBatchGateway();
      final container = makeAnaliseContainer(gateway: gateway);
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();
      expect(find.byType(AnaliseTableWidget), findsOneWidget);

      final notifier =
          container.read(novaAnaliseControllerProvider(null).notifier);
      _fillCabecalho(notifier);
      _fillMin(notifier, 0, talhao: 'T-01');
      notifier.adicionarAnalise(); // A2 incompleta (warning)
      await tester.pumpAndSettle();

      final ok = await notifier.salvar();
      expect(ok, isTrue);
      expect(gateway.committed, hasLength(2));
      expect(gateway.committed.map((e) => e.talhao).toSet(), {'T-01', ''});
    });

    testWidgets('falha com compensação não deixa estado parcial visível',
        (tester) async {
      final gateway = InMemoryBatchGateway()..failWithCompensation = true;
      final container = makeAnaliseContainer(gateway: gateway);
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      final notifier =
          container.read(novaAnaliseControllerProvider(null).notifier);
      _fillCabecalho(notifier);
      _fillMin(notifier, 0, talhao: 'T-01');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar Análise'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('compensação evitou estado parcial'),
        findsOneWidget,
      );
      expect(gateway.committed, isEmpty);
    });

    testWidgets('retry idempotente não duplica', (tester) async {
      final gateway = InMemoryBatchGateway();
      final container = makeAnaliseContainer(gateway: gateway);
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      final notifier =
          container.read(novaAnaliseControllerProvider(null).notifier);
      final existente =
          makeAnalise(id: 'idem-01', talhao: 'T-IDEM', numeroAmostra: 'A-IDEM');
      notifier.carregarDeAnaliseSolo([existente]);
      await tester.pumpAndSettle();

      final ok1 = await notifier.salvar();
      final ok2 = await notifier.salvar();
      expect(ok1, isTrue);
      expect(ok2, isTrue);
      expect(gateway.committed, hasLength(1));
      expect(gateway.committed.first.id, 'idem-01');
    });
  });
}
