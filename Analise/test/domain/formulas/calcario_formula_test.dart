import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/calcario_formula.dart';
import 'package:soloforte/domain/formulas/types/calcario_input.dart';

void main() {
  group('CalcarioFormula', () {
    test('CASO 1 — Exemplo exato da Aula 10 Fancelli', () {
      const input = CalcarioInput(vd: 70, va: 43.7, ctcPh7: 6.04,
                                  prnt: 80, profundidade: 20.0);
      final result = CalcarioFormula.metodoV(input);
      expect(result.ncToneladas, closeTo(1.985, 0.01));
    });

    test('CASO 2 — Solo do cerrado (Embrapa Sousa & Lobato)', () {
      const input = CalcarioInput(vd: 50, va: 30, ctcPh7: 5.0,
                                  prnt: 75, profundidade: 20.0);
      final result = CalcarioFormula.metodoV(input);
      expect(result.ncToneladas, closeTo(1.33, 0.01));
    });

    test('CASO 3 — Borda: vd == va (sem necessidade de calcário)', () {
      const input = CalcarioInput(vd: 40, va: 40, ctcPh7: 5.0,
                                  prnt: 100, profundidade: 20.0);
      final result = CalcarioFormula.metodoV(input);
      expect(result.ncToneladas, equals(0.0));
    });

    test('CASO 4 — PRNT zero: deve lançar ArgumentError', () {
      const input = CalcarioInput(vd: 50, va: 30, ctcPh7: 5.0,
                                  prnt: 0, profundidade: 20.0);
      expect(() => CalcarioFormula.metodoV(input), throwsArgumentError);
    });
  });
}
