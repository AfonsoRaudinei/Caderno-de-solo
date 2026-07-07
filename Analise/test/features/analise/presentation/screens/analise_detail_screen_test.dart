import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/application/providers/analise_persistence_gateway.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
import 'package:soloforte/features/analise/presentation/screens/analise_detail_screen.dart';
import 'package:soloforte/features/analise/presentation/widgets/analise_form_content.dart';

import '../../../../support/analise_test_factories.dart';
import '../../../../support/analise_test_harness.dart';

class _FakeAnaliseNotifier extends AnaliseNotifier {
  _FakeAnaliseNotifier(this._analises);

  final List<AnaliseSolo> _analises;

  @override
  Stream<List<AnaliseSolo>> build() async* {
    yield _analises;
  }
}

Widget _buildApp({
  required ProviderContainer container,
  required String analiseId,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: AnaliseDetailScreen(analiseId: analiseId),
    ),
  );
}

void main() {
  testWidgets('icone de editar ativa formulario inline na mesma tela', (
    tester,
  ) async {
    final analise = makeAnalise(
      id: 'det-1',
      talhao: 'T01',
      numeroAmostra: 'SBA25.147294',
      fazenda: 'MOEMA',
      produtor: 'ANDRE LUIZ DE SIQUEIRA',
      laboratorio: 'Exata Brasil',
    );

    final container = ProviderContainer(
      overrides: [
        analiseNotifierProvider.overrideWith(
          () => _FakeAnaliseNotifier([analise]),
        ),
        analisePersistenceGatewayProvider.overrideWithValue(
          InMemoryBatchGateway(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester
        .pumpWidget(_buildApp(container: container, analiseId: 'det-1'));
    await tester.pumpAndSettle();

    expect(find.byType(AnaliseFormContent), findsNothing);
    expect(find.text('IDENTIFICAÇÃO DO LAUDO'), findsNothing);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.byType(AnaliseFormContent), findsOneWidget);
    expect(find.text('IDENTIFICAÇÃO DO LAUDO'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('cancelar edicao volta ao modo visualizacao', (tester) async {
    final analise = makeAnalise(id: 'det-1', talhao: 'T01');
    final container = ProviderContainer(
      overrides: [
        analiseNotifierProvider.overrideWith(
          () => _FakeAnaliseNotifier([analise]),
        ),
        analisePersistenceGatewayProvider.overrideWithValue(
          InMemoryBatchGateway(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester
        .pumpWidget(_buildApp(container: container, analiseId: 'det-1'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    expect(find.text('IDENTIFICAÇÃO DO LAUDO'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Composição Física'), findsOneWidget);
    expect(find.text('IDENTIFICAÇÃO DO LAUDO'), findsNothing);
  });

  testWidgets('salvar edicao retorna ao modo visualizacao', (tester) async {
    final gateway = InMemoryBatchGateway();
    final analise = makeAnalise(id: 'det-1', talhao: 'T01');
    final container = ProviderContainer(
      overrides: [
        analiseNotifierProvider.overrideWith(
          () => _FakeAnaliseNotifier([analise]),
        ),
        analisePersistenceGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);

    await tester
        .pumpWidget(_buildApp(container: container, analiseId: 'det-1'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(find.text('Composição Física'), findsOneWidget);
    expect(find.text('IDENTIFICAÇÃO DO LAUDO'), findsNothing);
    expect(gateway.saveCalls, 1);
  });
}
