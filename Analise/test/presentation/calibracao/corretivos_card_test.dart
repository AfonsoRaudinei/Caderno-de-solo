import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/corretivos_card.dart';

import 'helpers/fake_calibracao_notifier.dart';

void main() {
  group('CorretivosCard — Título', () {
    testWidgets('título visível colapsado', (tester) async {
      await pumpCard(tester, corretivosCard());

      expect(find.text('Corretivos'), findsOneWidget);
    });

    testWidgets('título visível após expandir', (tester) async {
      await pumpCard(tester, corretivosCard());
      await expandCard(tester, 'Corretivos');

      expect(find.text('Corretivos'), findsOneWidget);
    });

    testWidgets('título visível após expandir e recolher', (tester) async {
      await pumpCard(tester, corretivosCard());
      await expandCard(tester, 'Corretivos');
      await expandCard(tester, 'Corretivos');

      expect(find.text('Corretivos'), findsOneWidget);
    });
  });

  group('CorretivosCard — Barra lateral', () {
    testWidgets('barra lateral azul #007AFF presente', (tester) async {
      await pumpCard(tester, corretivosCard());

      expect(hasContainerColor(tester, const Color(0xFF007AFF)), isTrue);
    });
  });

  group('CorretivosCard — Resumo colapsado', () {
    testWidgets('exibe tipoCalcario quando preenchido', (tester) async {
      await pumpCard(tester, corretivosCard());

      expect(find.textContaining('Dolomítico'), findsWidgets);
    });

    testWidgets('exibe PRNT quando preenchido', (tester) async {
      final data = mergeCard(corretivosBase(), {
        'prnt': 90.0,
        'calcario1': {
          ...Map<String, dynamic>.from(corretivosBase()['calcario1'] as Map),
          'prnt': 90.0,
        },
      });
      await pumpCard(tester, corretivosCard(corretivos: data));

      expect(find.textContaining('PRNT'), findsOneWidget);
    });

    testWidgets('exibe critério NC quando usarNivelCritico = true',
        (tester) async {
      final data = mergeCard(corretivosBase(), {
        'metodoCalagem': '⑤ Albrecht',
        'usarNivelCritico': true,
        'ncCa': 1.5,
        'ncMg': 0.7,
        'ncK': 0.08,
      });
      await pumpCard(tester, corretivosCard(corretivos: data));

      expect(find.textContaining('NC'), findsOneWidget);
      expect(find.textContaining('cmolc'), findsOneWidget);
    });

    testWidgets('exibe Meta quando usarNivelCritico = false', (tester) async {
      final data = mergeCard(corretivosBase(), {
        'metodoCalagem': '⑤ Albrecht',
        'usarNivelCritico': false,
        'caDesejadoPct': 65.0,
        'mgDesejadoPct': 15.0,
        'kDesejadoPct': 5.0,
      });
      await pumpCard(tester, corretivosCard(corretivos: data));

      expect(find.textContaining('Meta'), findsOneWidget);
      expect(find.textContaining('65%'), findsOneWidget);
    });

    testWidgets('não exibe separador órfão', (tester) async {
      await pumpCard(tester, corretivosCard());

      verificarSemSeparadorOrfao(tester);
    });
  });

  group('CorretivosCard — Método de calagem e metas', () {
    testWidgets('saturação por bases usa V₂ e não exibe nível crítico',
        (tester) async {
      await pumpCard(tester, corretivosCard());
      await expandCard(tester, 'Corretivos');

      expect(find.text('V₂ desejado (%)'), findsOneWidget);
      expect(find.text('% da CTC'), findsNothing);
      expect(find.text('Nível Crítico'), findsNothing);
    });

    testWidgets('Albrecht exibe alternância entre % CTC e nível crítico',
        (tester) async {
      final data = mergeCard(corretivosBase(), {
        'metodoCalagem': '⑤ Albrecht',
      });
      await pumpCard(tester, corretivosCard(corretivos: data));
      await expandCard(tester, 'Corretivos');

      expect(find.text('% da CTC'), findsOneWidget);
      expect(find.text('Nível Crítico'), findsOneWidget);
    });

    testWidgets('saturação por bases desabilita 2º calcário', (tester) async {
      final data = mergeCard(corretivosBase(), {
        'metodoCalagem': '① Saturação por Bases (V%)',
        'usarSegundoCalcario': true,
      });
      await pumpCard(tester, corretivosCard(corretivos: data));
      await expandCard(tester, 'Corretivos');

      expect(find.text('Usar 2º calcário?'), findsOneWidget);
      expect(find.text('CaO 2º (%)'), findsNothing);
      expect(find.text('MgO 2º (%)'), findsNothing);
    });

    testWidgets(
        'tipo de calcário oculta Magnesiano, Calcinado, Filler e Personalizado',
        (tester) async {
      await pumpCard(tester, corretivosCard());
      await expandCard(tester, 'Corretivos');
      await tester.tap(find.text('Dolomítico').last);
      await tester.pumpAndSettle();

      expect(find.text('Calcítico'), findsWidgets);
      expect(find.text('Magnesiano'), findsNothing);
      expect(find.text('Calcinado'), findsNothing);
      expect(find.text('Filler'), findsNothing);
      expect(find.text('Personalizado'), findsNothing);
    });

    testWidgets('CA+CD exibe legenda após selecionar', (tester) async {
      final data = mergeCard(corretivosBase(), {
        'metodoCalagem': '⑧ CA+CD',
      });
      await pumpCard(tester, corretivosCard(corretivos: data));
      await expandCard(tester, 'Corretivos');

      expect(find.text('CA+CD'), findsWidgets);
      expect(
        find.text(
            'Neutralização de Al³⁺ e elevação dos teores de Ca²⁺ e Mg²⁺.'),
        findsOneWidget,
      );
      expect(find.text('V₂ desejado (%)'), findsNothing);
    });

    testWidgets('dropdown corretiva não lista EMBRAPA, Ca+Mg nem Correção Mg',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpCard(tester, corretivosCard());
      await expandCard(tester, 'Corretivos');
      final metodoFinder = find.text('① Saturação por Bases (V%)').last;
      await tester.ensureVisible(metodoFinder);
      await tester.pumpAndSettle();
      await tester.tap(metodoFinder);
      await tester.pumpAndSettle();

      expect(find.text('④ Supercalagem'), findsWidgets);
      expect(find.text('⑤ Albrecht'), findsWidgets);
      expect(find.text('⑥ Albrecht + Y'), findsWidgets);
      expect(find.text('CA+CD'), findsWidgets);
      expect(find.text('② EMBRAPA (fator H+Al)'), findsNothing);
      expect(find.text('③ Ca+Mg'), findsNothing);
      expect(find.text('⑦ Correção Mg'), findsNothing);
    });

    testWidgets('CA+CD exibe Meta de Ca, Mg e K só em Nível Crítico',
        (tester) async {
      final data = mergeCard(corretivosBase(), {
        'metodoCalagem': '⑧ CA+CD',
        'usarNivelCritico': false,
        'ncCa': 1.5,
        'ncMg': 0.7,
        'ncK': 0.08,
      });
      await pumpCard(tester, corretivosCard(corretivos: data));
      await expandCard(tester, 'Corretivos');

      expect(find.text('META DE CA, MG E K'), findsOneWidget);
      expect(find.text('Nível Crítico'), findsOneWidget);
      expect(find.text('% da CTC'), findsNothing);
      expect(find.text('NC Ca'), findsOneWidget);
      expect(find.text('NC Mg'), findsOneWidget);
    });

    testWidgets('Albrecht mantém o toggle com as duas opções', (tester) async {
      final data = mergeCard(corretivosBase(), {
        'metodoCalagem': '⑤ Albrecht',
      });
      await pumpCard(tester, corretivosCard(corretivos: data));
      await expandCard(tester, 'Corretivos');

      expect(find.text('META DE CA, MG E K'), findsOneWidget);
      expect(find.text('% da CTC'), findsOneWidget);
      expect(find.text('Nível Crítico'), findsOneWidget);
    });

    testWidgets('trocar CA+CD → Albrecht destrava o toggle e voltar retrava',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final emitidos = <Map<String, dynamic>>[];
      final inicial = mergeCard(corretivosBase(), {
        'metodoCalagem': '⑧ CA+CD',
        'usarNivelCritico': false,
      });
      await tester.pumpWidget(
        makeTestable(
          _CorretivosCardHost(inicial: inicial, onChanged: emitidos.add),
        ),
      );
      await tester.pumpAndSettle();
      await expandCard(tester, 'Corretivos');

      // ⑧ trava em Nível Crítico mesmo com usarNivelCritico = false salvo.
      expect(find.text('Nível Crítico'), findsOneWidget);
      expect(find.text('% da CTC'), findsNothing);

      await _trocarMetodo(tester, 'CA+CD', '⑤ Albrecht');

      // ⑤ destrava: as duas opções voltam.
      expect(find.text('% da CTC'), findsOneWidget);
      expect(find.text('Nível Crítico'), findsOneWidget);
      expect(emitidos.last['metodoCalagem'], '⑤ Albrecht');
      expect(emitidos.last['usarNivelCritico'], isFalse);

      await _trocarMetodo(tester, '⑤ Albrecht', 'CA+CD');

      // De volta em ⑧: trava de novo e grava usarNivelCritico = true.
      expect(find.text('Nível Crítico'), findsOneWidget);
      expect(find.text('% da CTC'), findsNothing);
      expect(emitidos.last['metodoCalagem'], '⑧ CA+CD');
      expect(emitidos.last['usarNivelCritico'], isTrue);
    });
  });

  group('CorretivosCard — Soma V%', () {
    testWidgets('texto V% aparece quando Ca/Mg/K estão preenchidos',
        (tester) async {
      final data = mergeCard(corretivosBase(), {
        'metodoCalagem': '⑤ Albrecht',
        'usarNivelCritico': false,
        'caDesejadoPct': 65.0,
        'mgDesejadoPct': 15.0,
        'kDesejadoPct': 5.0,
      });
      await pumpCard(tester, corretivosCard(corretivos: data));
      await expandCard(tester, 'Corretivos');

      expect(find.textContaining('V% esperado'), findsOneWidget);
    });
  });

  group('CorretivosCard — Persistência das 7 chaves', () {
    for (final entry in const <String, dynamic>{
      'usarNivelCritico': true,
      'caDesejadoPct': 65.0,
      'mgDesejadoPct': 15.0,
      'kDesejadoPct': 5.0,
      'ncCa': 1.5,
      'ncMg': 0.7,
      'ncK': 0.08,
    }.entries) {
      testWidgets('${entry.key} renderiza sem erro', (tester) async {
        final data = mergeCard(corretivosBase(), {entry.key: entry.value});

        await pumpCard(tester, corretivosCard(corretivos: data));

        expect(tester.takeException(), isNull);
      });
    }
  });
}

/// Host com estado real: aplica o `onChanged` do card de volta no mapa, para
/// permitir testar troca de método (o helper compartilhado usa no-op).
class _CorretivosCardHost extends StatefulWidget {
  const _CorretivosCardHost({required this.inicial, required this.onChanged});

  final Map<String, dynamic> inicial;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  State<_CorretivosCardHost> createState() => _CorretivosCardHostState();
}

class _CorretivosCardHostState extends State<_CorretivosCardHost> {
  late Map<String, dynamic> _corretivos = widget.inicial;
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return CorretivosCard(
      draft: perfilBase(),
      draftKey: 'test-corretivos',
      corretivos: _corretivos,
      isExpanded: _expandido,
      onToggle: () => setState(() => _expandido = !_expandido),
      onChanged: (value) {
        widget.onChanged(value);
        setState(() => _corretivos = value);
      },
    );
  }
}

Future<void> _trocarMetodo(
  WidgetTester tester,
  String labelAtual,
  String labelNovo,
) async {
  final atual = find.text(labelAtual).last;
  await tester.ensureVisible(atual);
  await tester.pumpAndSettle();
  await tester.tap(atual);
  await tester.pumpAndSettle();
  await tester.tap(find.text(labelNovo).last);
  await tester.pumpAndSettle();
}
