import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

  group('CorretivosCard — Toggle % CTC vs Nível Crítico', () {
    testWidgets('textos dos toggles presentes no expandido', (tester) async {
      await pumpCard(tester, corretivosCard());
      await expandCard(tester, 'Corretivos');

      expect(find.text('% da CTC'), findsOneWidget);
      expect(find.text('Nível Crítico'), findsOneWidget);
    });
  });

  group('CorretivosCard — Soma V%', () {
    testWidgets('texto V% aparece quando Ca/Mg/K estão preenchidos',
        (tester) async {
      final data = mergeCard(corretivosBase(), {
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
