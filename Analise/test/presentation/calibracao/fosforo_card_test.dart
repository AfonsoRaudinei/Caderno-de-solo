import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart';

import 'helpers/fake_calibracao_notifier.dart';

void main() {
  group('FosforoCard — Título', () {
    testWidgets('título visível colapsado', (tester) async {
      await pumpCard(tester, fosforoCard());

      expect(find.text('Fósforo'), findsOneWidget);
    });

    testWidgets('título visível expandido', (tester) async {
      await pumpCard(tester, fosforoCard());
      await expandCard(tester, 'Fósforo');

      expect(find.text('Fósforo'), findsOneWidget);
    });

    testWidgets('título visível após recolher', (tester) async {
      await pumpCard(tester, fosforoCard());
      await expandCard(tester, 'Fósforo');
      await expandCard(tester, 'Fósforo');

      expect(find.text('Fósforo'), findsOneWidget);
    });
  });

  group('FosforoCard — Barra lateral', () {
    testWidgets('barra lateral vermelha #FF3B30 presente', (tester) async {
      await pumpCard(tester, fosforoCard());

      expect(hasContainerColor(tester, const Color(0xFFFF3B30)), isTrue);
    });
  });

  group('FosforoCard — NC editável', () {
    testWidgets('ícone lock presente no modo automático', (tester) async {
      await pumpCard(tester, fosforoCard());
      await expandCard(tester, 'Fósforo');

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('toque no lock mostra ícone edit e Restaurar', (tester) async {
      await pumpCard(tester, fosforoCard());
      await expandCard(tester, 'Fósforo');
      await tester.tap(find.byIcon(Icons.lock_outline));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.textContaining('Restaurar'), findsOneWidget);
    });
  });

  group('FosforoCard — Modo de cálculo', () {
    testWidgets('não exibe dropdown legado Manutenção / Extração',
        (tester) async {
      await pumpCard(tester, fosforoCard(initialExpanded: true));

      expect(find.textContaining('Composição do cálculo'), findsOneWidget);
      expect(find.textContaining('Manutenção / Extração'), findsNothing);
    });

    testWidgets('% P DO SOLO ausente no modo Correção do solo', (tester) async {
      final data =
          mergeCard(fosforoBase(), {'modoCalculo': 'Correção do solo'});
      await pumpCard(tester, fosforoCard(fosforo: data, initialExpanded: true));

      expect(find.textContaining('% P DO SOLO'), findsNothing);
    });

    testWidgets('legado Manutenção / Extração migra para Exportação',
        (tester) async {
      final data =
          mergeCard(fosforoBase(), {'modoCalculo': 'Manutenção / Extração'});
      await pumpCard(tester, fosforoCard(fosforo: data, initialExpanded: true));

      expect(find.text('Exportação'), findsOneWidget);
      expect(find.textContaining('% P DO SOLO'), findsNothing);
    });

    testWidgets('% P DO SOLO ausente no modo Exportação', (tester) async {
      final data = mergeCard(fosforoBase(), {'modoCalculo': 'Exportação'});
      await pumpCard(tester, fosforoCard(fosforo: data, initialExpanded: true));

      expect(find.textContaining('% P DO SOLO'), findsNothing);
    });

    testWidgets('% P DO SOLO presente no modo Extração', (tester) async {
      final data = mergeCard(fosforoBase(), {
        'corrigirSolo': true,
        'reposicaoFosforo': 'extracao',
      });
      await pumpCard(tester, fosforoCard(fosforo: data, initialExpanded: true));

      expect(find.textContaining('% P DO SOLO'), findsOneWidget);
    });
  });

  group('FosforoCard — Resumo', () {
    testWidgets('não exibe separador órfão', (tester) async {
      await pumpCard(tester, fosforoCard());

      verificarSemSeparadorOrfao(tester);
    });
  });

  group('FosforoCard — Eficiência no solo', () {
    testWidgets('campo visível quando expandido', (tester) async {
      await pumpCard(tester, fosforoCard(initialExpanded: true));

      expect(find.text('Eficiência no solo (%)'), findsOneWidget);
    });

    testWidgets('carrega eficienciaSolo salva', (tester) async {
      final data = mergeCard(fosforoBase(), {'eficienciaSolo': 45.0});
      await pumpCard(tester, fosforoCard(fosforo: data, initialExpanded: true));

      expect(find.text('45'), findsOneWidget);
    });

    testWidgets('faz fallback para fepBase legado', (tester) async {
      final data = mergeCard(fosforoBase(), {'fepBase': 25.0});
      await pumpCard(tester, fosforoCard(fosforo: data, initialExpanded: true));

      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('emite eficienciaSolo no payload', (tester) async {
      Map<String, dynamic>? emitted;
      await tester.pumpWidget(
        makeTestable(
          ExpandableCardHost(
            initialExpanded: true,
            builder: (expanded, toggle) => FosforoCard(
              initialData: mergeCard(fosforoBase(), {'eficienciaSolo': 60.0}),
              cultura: 'Soja',
              isExpanded: expanded,
              onToggle: toggle,
              onChanged: (map) => emitted = map,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, '75');
      await tester.pumpAndSettle();

      expect(emitted, isNotNull);
      expect(emitted!['eficienciaSolo'], 75.0);
    });
  });
}
