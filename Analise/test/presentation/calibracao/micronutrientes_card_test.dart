import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_calibracao_notifier.dart';

void main() {
  group('MicronutrientesCard — Título', () {
    testWidgets('título visível colapsado', (tester) async {
      await pumpCard(tester, micronutrientesCard());

      expect(find.text('Micronutrientes'), findsOneWidget);
    });

    testWidgets('título visível expandido', (tester) async {
      await pumpCard(tester, micronutrientesCard());
      await expandCard(tester, 'Micronutrientes');

      expect(find.text('Micronutrientes'), findsOneWidget);
    });
  });

  group('MicronutrientesCard — Barra lateral', () {
    testWidgets('barra lateral roxa #AF52DE presente', (tester) async {
      await pumpCard(tester, micronutrientesCard());

      expect(hasContainerColor(tester, const Color(0xFFAF52DE)), isTrue);
    });
  });

  group('MicronutrientesCard — Bloco duplicado removido', () {
    testWidgets('sem grupos não mostra REFERÊNCIA DE ABSORÇÃO', (tester) async {
      await pumpCard(tester, micronutrientesCard(initialExpanded: true));

      expect(find.text('REFERÊNCIA DE ABSORÇÃO'), findsNothing);
    });
  });

  group('MicronutrientesCard — Toggles via do grupo', () {
    testWidgets('Foliar/Solo/TS visíveis com grupo criado', (tester) async {
      final data = microsBase(
        grupos: [
          {
            'id': 'g1',
            'nome': 'Metálico',
            'viasAplicacaoGrupo': ['Foliar'],
            'extrator': 'DTPA-TEA',
            'elementos': <String>[],
          },
        ],
      );
      await pumpCard(
        tester,
        micronutrientesCard(micros: data, initialExpanded: true),
      );

      expect(find.text('Foliar'), findsWidgets);
      expect(find.text('Solo'), findsWidgets);
      expect(find.text('TS'), findsWidgets);
    });

    testWidgets('Foliar e Solo podem estar ativos juntos', (tester) async {
      final data = microsBase(
        grupos: [
          {
            'id': 'g1',
            'nome': 'Misto',
            'viasAplicacaoGrupo': ['Foliar', 'Solo'],
            'extrator': 'DTPA-TEA',
            'elementos': <String>[],
          },
        ],
      );
      await pumpCard(
        tester,
        micronutrientesCard(micros: data, initialExpanded: true),
      );

      expect(find.textContaining('Fonte foliar'), findsOneWidget);
      expect(find.textContaining('Fonte solo'), findsOneWidget);
    });
  });

  group('MicronutrientesCard — Extrator no grupo', () {
    testWidgets('DTPA-TEA aparece no grupo', (tester) async {
      final data = microsBase(
        grupos: [
          {
            'id': 'g1',
            'nome': 'Metálico',
            'viasAplicacaoGrupo': ['Foliar'],
            'extrator': 'DTPA-TEA',
            'elementos': <String>[],
          },
        ],
      );
      await pumpCard(
        tester,
        micronutrientesCard(micros: data, initialExpanded: true),
      );

      expect(find.textContaining('DTPA-TEA'), findsWidgets);
    });
  });
}
