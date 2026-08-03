import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart';

Future<void> _pumpCard(
  WidgetTester tester, {
  Map<String, dynamic>? initialData,
  void Function(Map<String, dynamic> payload)? onChanged,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FosforoCardWidget(
              initialData: initialData,
              cultura: 'Soja',
              onChanged: onChanged ?? (_) {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Card 2 — Fósforo'));
  await tester.pumpAndSettle();
}

void main() {
  group('FosforoCardWidget', () {
    testWidgets('carrega calibração antiga sem ajusteEficienciaSolo', (
      tester,
    ) async {
      Map<String, dynamic>? payload;
      await _pumpCard(
        tester,
        initialData: {
          'referencia': 'IAC Bol.100',
          'modoCalculo': '① Correção do solo',
          'percentualUsoPSolo': 30.0,
        },
        onChanged: (map) => payload = map,
      );

      expect(find.text('Correção do solo'), findsOneWidget);
      expect(find.text('Sem reposição'), findsOneWidget);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(payload?['ajusteEficienciaSolo'], 0.0);
      expect(payload?['correcaoSoloAtiva'], isFalse);
    });

    testWidgets('Sem reposição oculta controles de reposição', (tester) async {
      await _pumpCard(
        tester,
        initialData: {
          'correcaoSoloAtiva': true,
          'modoReposicao': 'Sem reposição',
        },
      );

      expect(find.text('REFERÊNCIA DE ABSORÇÃO'), findsNothing);
      expect(find.text('Ajuste de eficiência no solo (%)'), findsNothing);
      expect(find.text('% P do solo considerado'), findsNothing);
    });

    testWidgets('Exportação exibe absorção e eficiência, oculta % P solo', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        initialData: {
          'correcaoSoloAtiva': true,
          'modoReposicao': 'Exportação',
          'ajusteEficienciaSolo': 25.0,
        },
      );

      expect(find.text('Cultura: Soja'), findsOneWidget);
      expect(find.text('REFERÊNCIA DE ABSORÇÃO'), findsOneWidget);
      expect(find.text('Ajuste de eficiência no solo (%)'), findsOneWidget);
      expect(find.text('% P do solo considerado'), findsNothing);
    });

    testWidgets('Extração exibe % P solo e eficiência', (tester) async {
      await _pumpCard(
        tester,
        initialData: {
          'correcaoSoloAtiva': true,
          'modoReposicao': 'Extração',
          'percentualUsoPSolo': 40.0,
          'ajusteEficienciaSolo': 10.0,
        },
      );

      expect(find.text('% P do solo considerado'), findsOneWidget);
      expect(find.text('Ajuste de eficiência no solo (%)'), findsOneWidget);
    });

    testWidgets('alternar para Sem reposição preserva valores no payload', (
      tester,
    ) async {
      Map<String, dynamic>? payload;
      await _pumpCard(
        tester,
        initialData: {
          'modoReposicao': 'Extração',
          'percentualUsoPSolo': 55.0,
          'ajusteEficienciaSolo': 30.0,
        },
        onChanged: (map) => payload = map,
      );

      await tester.tap(find.text('Sem reposição'));
      await tester.pumpAndSettle();

      expect(payload?['percentualUsoPSolo'], 55.0);
      expect(payload?['ajusteEficienciaSolo'], 30.0);
      expect(payload?['modoReposicao'], 'Sem reposição');
    });

    testWidgets('persiste ajuste de eficiência no payload', (tester) async {
      Map<String, dynamic>? payload;
      await _pumpCard(
        tester,
        initialData: {
          'modoReposicao': 'Exportação',
          'ajusteEficienciaSolo': 0.0,
        },
        onChanged: (map) => payload = map,
      );

      final field = find.descendant(
        of: find
            .ancestor(
              of: find.text('Ajuste de eficiência no solo (%)'),
              matching: find.byType(Column),
            )
            .first,
        matching: find.byType(TextField),
      );

      await tester.enterText(field, '50');
      await tester.pumpAndSettle();

      expect(payload?['ajusteEficienciaSolo'], 50.0);
    });
  });
}
