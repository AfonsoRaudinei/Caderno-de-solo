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

  group('CalcarioFormula — ⑧ CA+CD', () {
    test('CA positivo e CD positivo (caso normal, só argila)', () {
      final y = CalcarioFormula.calcularYCriterio(argilaPercent: 35);
      final bruto = CalcarioFormula.calcularNcCaCd(
        al3: 0.3,
        ca2: 2.0,
        mg2: 0.5,
        ncCa: 2.0,
        ncMg: 0.8,
        argilaPercent: 35,
      );

      expect(bruto.y, closeTo(y, 0.0001));
      expect(bruto.ca, closeTo(y * 0.3, 0.0001));
      expect(bruto.cd, closeTo(0.3, 0.0001));
      expect(bruto.nc, closeTo(bruto.ca + bruto.cd, 0.0001));
      expect(bruto.ca, greaterThan(0));
      expect(bruto.cd, greaterThan(0));
    });

    test('Y com argila + P-rem usa calcularYCriterio', () {
      final y = CalcarioFormula.calcularYCriterio(
        argilaPercent: 35,
        prem: 18,
      );
      final bruto = CalcarioFormula.calcularNcCaCd(
        al3: 0.3,
        ca2: 2.0,
        mg2: 0.5,
        ncCa: 2.0,
        ncMg: 0.8,
        argilaPercent: 35,
        prem: 18,
      );

      expect(bruto.y, closeTo(y, 0.0001));
      expect(bruto.ca, closeTo(y * 0.3, 0.0001));
      expect(
        bruto.y,
        isNot(closeTo(
          CalcarioFormula.calcularYCriterio(argilaPercent: 35),
          0.0001,
        )),
      );
    });

    test('CA negativo é clampado a 0', () {
      final bruto = CalcarioFormula.calcularNcCaCd(
        al3: -1.0,
        ca2: 2.0,
        mg2: 0.5,
        ncCa: 2.0,
        ncMg: 0.8,
        argilaPercent: 35,
      );

      expect(bruto.ca, 0.0);
      expect(bruto.cd, closeTo(0.3, 0.0001));
      expect(bruto.nc, closeTo(0.3, 0.0001));
    });

    test('CD negativo é clampado a 0 quando Ca+Mg já está acima de X', () {
      final bruto = CalcarioFormula.calcularNcCaCd(
        al3: 0.3,
        ca2: 3.0,
        mg2: 1.0,
        ncCa: 2.0,
        ncMg: 0.8,
        argilaPercent: 35,
      );

      expect(bruto.cd, 0.0);
      expect(bruto.ca, greaterThan(0));
      expect(bruto.nc, closeTo(bruto.ca, 0.0001));
    });

    test('NC = 0 quando CA e CD são clampados', () {
      final bruto = CalcarioFormula.calcularNcCaCd(
        al3: -1.0,
        ca2: 5.0,
        mg2: 5.0,
        ncCa: 2.0,
        ncMg: 0.8,
        argilaPercent: 35,
      );

      expect(bruto.ca, 0.0);
      expect(bruto.cd, 0.0);
      expect(bruto.nc, 0.0);
    });

    test('metodoCaCd aplica aplicarCorrecoes sobre o NC', () {
      const prnt = 80.0;
      const profundidade = 20.0;
      const sc = 1.0;
      final bruto = CalcarioFormula.calcularNcCaCd(
        al3: 0.3,
        ca2: 2.0,
        mg2: 0.5,
        ncCa: 2.0,
        ncMg: 0.8,
        argilaPercent: 35,
      );
      final esperado = CalcarioFormula.aplicarCorrecoes(
        ncBase: bruto.nc,
        profundidadeCm: profundidade,
        prnt: prnt,
        sc: sc,
      ).doseFinal;
      final dose = CalcarioFormula.metodoCaCd(
        al3: 0.3,
        ca2: 2.0,
        mg2: 0.5,
        ncCa: 2.0,
        ncMg: 0.8,
        argilaPercent: 35,
        prnt: prnt,
        profundidadeCm: profundidade,
        sc: sc,
      );

      expect(dose, closeTo(esperado, 0.0001));
      expect(dose, closeTo(bruto.nc / (prnt / 100.0), 0.0001));
    });
  });
}
