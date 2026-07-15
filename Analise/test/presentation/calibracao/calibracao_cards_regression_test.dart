// ══════════════════════════════════════════════════════════
// GUARDIÃO DOS CARDS DE CALIBRAÇÃO
// Falha aqui = regressão introduzida.
// NÃO alterar sem aprovação + atualizar SPEC_card_*.md
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_calibracao_notifier.dart';

void main() {
  final cards = <({String titulo, Widget Function() build, Color color})>[
    (
      titulo: 'Corretivos',
      build: () => corretivosCard(),
      color: const Color(0xFF007AFF),
    ),
    (
      titulo: 'Fósforo',
      build: () => fosforoCard(),
      color: const Color(0xFFFF3B30),
    ),
    (
      titulo: 'Potássio',
      build: () => potassioCard(),
      color: const Color(0xFFFF9500),
    ),
    (
      titulo: 'Micronutrientes',
      build: () => micronutrientesCard(),
      color: const Color(0xFFAF52DE),
    ),
  ];

  group('CONTRATO 1 — Títulos nunca somem', () {
    for (final card in cards) {
      testWidgets('${card.titulo}: título visível colapsado', (tester) async {
        await pumpCard(tester, card.build());

        expect(find.textContaining(card.titulo), findsOneWidget);
      });

      testWidgets('${card.titulo}: título visível após expandir',
          (tester) async {
        await pumpCard(tester, card.build());
        await expandCard(tester, card.titulo);

        expect(find.textContaining(card.titulo), findsOneWidget);
      });

      testWidgets('${card.titulo}: título visível após recolher',
          (tester) async {
        await pumpCard(tester, card.build());
        await expandCard(tester, card.titulo);
        await expandCard(tester, card.titulo);

        expect(find.textContaining(card.titulo), findsOneWidget);
      });
    }
  });

  group('CONTRATO 2 — Cores das barras laterais', () {
    for (final card in cards) {
      testWidgets('${card.titulo}: barra lateral correta', (tester) async {
        await pumpCard(tester, card.build());

        expect(hasContainerColor(tester, card.color), isTrue);
      });
    }
  });

  group('CONTRATO 3 — Sem separadores órfãos', () {
    for (final card in cards) {
      testWidgets('${card.titulo}: resumo sem separador órfão', (tester) async {
        await pumpCard(tester, card.build());

        verificarSemSeparadorOrfao(tester);
      });
    }
  });

  group('CONTRATO 4 — Chevron presente', () {
    for (final card in cards) {
      testWidgets('${card.titulo}: chevron existe', (tester) async {
        await pumpCard(tester, card.build());

        expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      });
    }
  });

  group('CONTRATO 5 — Campo Camada ausente do Potássio', () {
    testWidgets('Potássio expandido não mostra Camada', (tester) async {
      await pumpCard(tester, potassioCard(initialExpanded: true));

      expect(find.text('Camada'), findsNothing);
    });
  });

  group('CONTRATO 6 — Lock presente em NC editável', () {
    testWidgets('Fósforo expandido mostra lock', (tester) async {
      await pumpCard(tester, fosforoCard(initialExpanded: true));

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('Potássio expandido mostra locks', (tester) async {
      await pumpCard(tester, potassioCard(initialExpanded: true));

      expect(find.byIcon(Icons.lock_outline), findsWidgets);
    });
  });
}
