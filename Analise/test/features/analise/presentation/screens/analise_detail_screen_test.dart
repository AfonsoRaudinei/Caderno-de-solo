import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/application/providers/analise_persistence_gateway.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
import 'package:soloforte/features/analise/presentation/screens/analise_detail_screen.dart';

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
  testWidgets('icone de editar mantem detalhe e habilita edicao por linha', (
    tester,
  ) async {
    final analise = makeAnalise(
      id: 'det-1',
      talhao: 'T01',
      numeroAmostra: 'SBA25.147294',
      fazenda: 'MOEMA',
      produtor: 'ANDRE LUIZ DE SIQUEIRA',
      laboratorio: 'Exata Brasil',
      k: 0.31,
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

    expect(find.text('IDENTIFICAÇÃO DO LAUDO'), findsNothing);
    expect(find.byKey(const ValueKey('edit_row_k')), findsNothing);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.text('IDENTIFICAÇÃO DO LAUDO'), findsNothing);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byKey(const ValueKey('edit_row_k')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('edit_row_k')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('edit_row_k')));
    await tester.pumpAndSettle();

    expect(find.text('Potássio (cmolc/dm³)'), findsWidgets);
    final input = tester.widget<TextField>(find.byType(TextField));
    expect(input.controller?.text, '0.310');
  });

  testWidgets('localizacao usa Lat/Long unico e acao de mapa', (tester) async {
    final analise = makeAnalise(
      id: 'det-1',
      talhao: 'T01',
      numeroAmostra: 'SBA25.147294',
      fazenda: 'MOEMA',
      produtor: 'ANDRE LUIZ DE SIQUEIRA',
      laboratorio: 'Exata Brasil',
      latitude: -10.510193,
      longitude: -48.315852,
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

    expect(find.text('Lat/Long'), findsOneWidget);
    expect(find.text('-10.510193, -48.315852'), findsOneWidget);
    expect(find.text('Ir ao mapa'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('select_location_on_map')), findsOneWidget);
    expect(find.text('Latitude'), findsNothing);
    expect(find.text('Longitude'), findsNothing);
  });

  testWidgets('concluir edicao volta ao modo visualizacao', (tester) async {
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
    expect(find.byKey(const ValueKey('edit_row_profundidade')), findsOneWidget);
    expect(find.text('IDENTIFICAÇÃO DO LAUDO'), findsNothing);

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(find.text('Composição Física'), findsOneWidget);
    expect(find.byKey(const ValueKey('edit_row_profundidade')), findsNothing);
  });
}
