import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_calibracao_notifier.dart';

void main() {
  group('PotassioCard — Título', () {
    testWidgets('título visível colapsado', (tester) async {
      await pumpCard(tester, potassioCard());

      expect(find.text('Potássio'), findsOneWidget);
    });

    testWidgets('título visível expandido', (tester) async {
      await pumpCard(tester, potassioCard());
      await expandCard(tester, 'Potássio');

      expect(find.text('Potássio'), findsOneWidget);
    });

    testWidgets('título visível após recolher', (tester) async {
      await pumpCard(tester, potassioCard());
      await expandCard(tester, 'Potássio');
      await expandCard(tester, 'Potássio');

      expect(find.text('Potássio'), findsOneWidget);
    });
  });

  group('PotassioCard — Barra lateral', () {
    testWidgets('barra lateral laranja #FF9500 presente', (tester) async {
      await pumpCard(tester, potassioCard());

      expect(hasContainerColor(tester, const Color(0xFFFF9500)), isTrue);
    });
  });

  group('PotassioCard — NC editável', () {
    testWidgets('ícones lock presentes por padrão', (tester) async {
      await pumpCard(tester, potassioCard(initialExpanded: true));

      expect(find.byIcon(Icons.lock_outline), findsWidgets);
    });

    testWidgets('toque no primeiro lock mostra edit e Restaurar',
        (tester) async {
      await pumpCard(tester, potassioCard(initialExpanded: true));
      await tester.tap(find.byIcon(Icons.lock_outline).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.textContaining('Restaurar'), findsOneWidget);
    });
  });

  group('PotassioCard — Campo Camada removido', () {
    testWidgets('label Camada não está visível no expandido', (tester) async {
      await pumpCard(tester, potassioCard(initialExpanded: true));

      expect(find.text('Camada'), findsNothing);
    });
  });

  group('PotassioCard — Sufixo * no resumo', () {
    testWidgets('NC manual exibe asterisco no resumo colapsado',
        (tester) async {
      final data = mergeCard(potassioBase(), {
        'ncTeor': 80.0,
        'ncTeorManual': true,
      });
      await pumpCard(tester, potassioCard(potassio: data));

      expect(allText(tester).contains('*'), isTrue);
    });

    testWidgets('NC automático não exibe 46* no resumo', (tester) async {
      await pumpCard(tester, potassioCard());

      expect(allText(tester).contains('46*'), isFalse);
    });
  });

  group('PotassioCard — Resumo', () {
    testWidgets('não exibe separador órfão', (tester) async {
      await pumpCard(tester, potassioCard());

      verificarSemSeparadorOrfao(tester);
    });
  });
}
