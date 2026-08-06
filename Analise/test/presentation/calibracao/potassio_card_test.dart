import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart';

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
  });

  group('PotassioCard — Barra lateral', () {
    testWidgets('barra lateral laranja presente', (tester) async {
      await pumpCard(tester, potassioCard());
      expect(hasContainerColor(tester, const Color(0xFFFF9500)), isTrue);
    });
  });

  group('PotassioCard — Correção do solo', () {
    testWidgets('switch visível quando expandido', (tester) async {
      await pumpCard(tester, potassioCard(initialExpanded: true));
      expect(find.text('Correção do solo'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('correção OFF oculta método de correção', (tester) async {
      final data = mergeCard(potassioBase(), {'corrigirSolo': false});
      await pumpCard(
          tester, potassioCard(potassio: data, initialExpanded: true));

      expect(find.text('Método de correção'), findsNothing);
      expect(find.text('Nível crítico'), findsNothing);
    });

    testWidgets('correção ON exibe método de correção', (tester) async {
      await pumpCard(tester, potassioCard(initialExpanded: true));

      expect(find.text('Método de correção'), findsOneWidget);
      expect(find.text('Nível crítico'), findsOneWidget);
      expect(find.text('% K na CTC'), findsOneWidget);
    });
  });

  group('PotassioCard — Método de correção', () {
    testWidgets('nível crítico exibe NC', (tester) async {
      await pumpCard(tester, potassioCard(initialExpanded: true));

      expect(find.text('NC de K (mg/dm³)'), findsOneWidget);
      expect(find.text('% K objetivo na CTC'), findsNothing);
    });

    testWidgets('alternância para % K na CTC', (tester) async {
      await pumpCard(tester, potassioCard(initialExpanded: true));
      await tester.tap(find.text('% K na CTC'));
      await tester.pumpAndSettle();

      expect(find.text('% K objetivo na CTC'), findsOneWidget);
      expect(find.text('NC de K (mg/dm³)'), findsNothing);
    });

    testWidgets('preserva campos ao alternar métodos', (tester) async {
      await pumpCard(
        tester,
        potassioCard(
          potassio: mergeCard(potassioBase(), {
            'ncTeor': 55.0,
            'ncTeorManual': true,
            'ncPctCtc': 4.5,
            'ncCtcManual': true,
          }),
          initialExpanded: true,
        ),
      );

      await tester.tap(find.text('% K na CTC'));
      await tester.pumpAndSettle();
      expect(find.text('% K objetivo na CTC'), findsOneWidget);

      await tester.tap(find.text('Nível crítico'));
      await tester.pumpAndSettle();
      expect(find.text('NC de K (mg/dm³)'), findsOneWidget);
    });
  });

  group('PotassioCard — Reposição da planta', () {
    testWidgets('sem reposição oculta absorção e eficiência', (tester) async {
      await pumpCard(tester, potassioCard(initialExpanded: true));

      expect(find.text('Sem reposição'), findsOneWidget);
      expect(find.text('REFERÊNCIA DE ABSORÇÃO'), findsNothing);
      expect(find.text('Ajuste de eficiência no solo (%)'), findsNothing);
    });

    testWidgets('exportação exibe absorção e eficiência', (tester) async {
      final data =
          mergeCard(potassioBase(), {'reposicaoPotassio': 'exportacao'});
      await pumpCard(
          tester, potassioCard(potassio: data, initialExpanded: true));

      expect(find.text('REFERÊNCIA DE ABSORÇÃO'), findsOneWidget);
      expect(find.text('Ajuste de eficiência no solo (%)'), findsOneWidget);
      expect(find.textContaining('Índice de exportação'), findsOneWidget);
    });

    testWidgets('extração exibe % K do solo considerado', (tester) async {
      final data = mergeCard(potassioBase(), {'reposicaoPotassio': 'extracao'});
      await pumpCard(
          tester, potassioCard(potassio: data, initialExpanded: true));

      expect(find.textContaining('% K DO SOLO CONSIDERADO'), findsOneWidget);
      expect(find.textContaining('Índice de extração'), findsOneWidget);
    });
  });

  group('PotassioCard — Eficiência no solo', () {
    testWidgets('carrega ajusteEficienciaSolo salvo', (tester) async {
      final data = mergeCard(potassioBase(), {
        'reposicaoPotassio': 'exportacao',
        'ajusteEficienciaSolo': 45.0,
      });
      await pumpCard(
          tester, potassioCard(potassio: data, initialExpanded: true));

      expect(find.text('45'), findsOneWidget);
    });

    testWidgets('faz fallback para fekBase legado', (tester) async {
      final base = Map<String, dynamic>.from(potassioBase())
        ..remove('ajusteEficienciaSolo');
      final data = mergeCard(base, {
        'reposicaoPotassio': 'exportacao',
        'fekBase': 25.0,
      });
      await pumpCard(
          tester, potassioCard(potassio: data, initialExpanded: true));

      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('emite ajusteEficienciaSolo no payload', (tester) async {
      Map<String, dynamic>? emitted;
      await tester.pumpWidget(
        makeTestable(
          ExpandableCardHost(
            initialExpanded: true,
            builder: (expanded, toggle) => PotassioCard(
              initialData: mergeCard(potassioBase(), {
                'reposicaoPotassio': 'exportacao',
                'ajusteEficienciaSolo': 60.0,
              }),
              cultura: 'Soja',
              isExpanded: expanded,
              onToggle: toggle,
              onChanged: (map) => emitted = map,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exportação'));
      await tester.pumpAndSettle();

      expect(emitted, isNotNull);
      final payload = emitted!;
      expect(payload['ajusteEficienciaSolo'], 60.0);
      expect(payload['metodoCorrecao'], 'nivel_critico');
      expect(payload['reposicaoPotassio'], 'exportacao');
    });
  });

  group('PotassioCard — Camada e legado', () {
    testWidgets('exibe campo Camada', (tester) async {
      await pumpCard(tester, potassioCard(initialExpanded: true));
      expect(find.text('Camada'), findsOneWidget);
    });

    testWidgets('calibração antiga sem novos campos não quebra',
        (tester) async {
      final legado = {
        'extrator': 'Mehlich-1',
        'referencia': 'Embrapa Cerrado',
        'criterioNc': 'Ambos — usar o maior',
        'ncTeor': 46.0,
        'ncPctCtc': 3.0,
        'modoCalculo': 'Manutenção',
        'fekBase': 65.0,
      };
      await pumpCard(
          tester, potassioCard(potassio: legado, initialExpanded: true));

      expect(find.text('Potássio'), findsOneWidget);
      expect(find.text('Correção do solo'), findsOneWidget);
      expect(find.text('Exportação'), findsOneWidget);
    });
  });

  group('PotassioCard — Resumo', () {
    testWidgets('não exibe separador órfão', (tester) async {
      await pumpCard(tester, potassioCard());
      verificarSemSeparadorOrfao(tester);
    });
  });
}
