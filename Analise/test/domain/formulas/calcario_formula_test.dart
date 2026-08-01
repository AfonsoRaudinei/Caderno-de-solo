import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/calcario_formula.dart';
import 'package:soloforte/domain/formulas/types/calcario_input.dart';

void main() {
  group('CalcarioFormula', () {
    test('CASO 1 — Exemplo exato da Aula 10 Fancelli', () {
      const input = CalcarioInput(
          vd: 70, va: 43.7, ctcPh7: 6.04, prnt: 80, profundidade: 20.0);
      final result = CalcarioFormula.metodoV(input);
      expect(result.ncToneladas, closeTo(1.985, 0.01));
    });

    test('CASO 2 — Solo do cerrado (Embrapa Sousa & Lobato)', () {
      const input = CalcarioInput(
          vd: 50, va: 30, ctcPh7: 5.0, prnt: 75, profundidade: 20.0);
      final result = CalcarioFormula.metodoV(input);
      expect(result.ncToneladas, closeTo(1.33, 0.01));
    });

    test('CASO 3 — Borda: vd == va (sem necessidade de calcário)', () {
      const input = CalcarioInput(
          vd: 40, va: 40, ctcPh7: 5.0, prnt: 100, profundidade: 20.0);
      final result = CalcarioFormula.metodoV(input);
      expect(result.ncToneladas, equals(0.0));
    });

    test('CASO 4 — PRNT zero: deve lançar ArgumentError', () {
      const input = CalcarioInput(
          vd: 50, va: 30, ctcPh7: 5.0, prnt: 0, profundidade: 20.0);
      expect(() => CalcarioFormula.metodoV(input), throwsArgumentError);
    });

    test('metodoIAC retorna 0 quando Ca já adequado', () {
      final dose = CalcarioFormula.metodoIAC(
        caDesejado: 2.0,
        caAtual: 2.5,
        prnt: 100,
      );
      expect(dose, 0.0);
    });

    test('metodoIAC aplica correção de PRNT e profundidade', () {
      // ncBase = 1.0; p=1 (20 cm); PRNT 100 → dose 1.0
      final dose = CalcarioFormula.metodoIAC(
        caDesejado: 3.0,
        caAtual: 2.0,
        prnt: 100,
      );
      expect(dose, closeTo(1.0, 0.01));
    });

    test('metodoEmbrapa NC = H+Al × fator com PRNT 100', () {
      final dose = CalcarioFormula.metodoEmbrapa(
        hAl: 4.0,
        fator: 0.5,
        prnt: 100,
      );
      expect(dose, closeTo(2.0, 0.01));
    });

    test('metodoSupercalagem aplica dose fixa', () {
      final dose = CalcarioFormula.metodoSupercalagem(
        doseFixa: 3.0,
        prnt: 100,
      );
      expect(dose, closeTo(3.0, 0.01));
    });

    test('aplicarCorrecoes com PRNT/SC inválidos zera dose', () {
      final zeroPrnt = CalcarioFormula.aplicarCorrecoes(
        ncBase: 2.0,
        profundidadeCm: 20,
        prnt: 0,
        sc: 1,
      );
      expect(zeroPrnt.doseFinal, 0.0);

      final zeroSc = CalcarioFormula.aplicarCorrecoes(
        ncBase: 2.0,
        profundidadeCm: 20,
        prnt: 100,
        sc: 0,
      );
      expect(zeroSc.doseFinal, 0.0);
    });

    test('calcularVPercent e calcularMPercent protegem divisão por zero', () {
      expect(
        CalcarioFormula.calcularVPercent(ca: 0, mg: 0, k: 0, hAl: 0),
        0.0,
      );
      expect(
        CalcarioFormula.calcularMPercent(ca: 0, mg: 0, k: 0, al: 0),
        0.0,
      );
    });
  });
}
