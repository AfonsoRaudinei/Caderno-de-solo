import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/potassio_formula.dart';

void main() {
  group('PotassioFormula - Participação na CTC e Recomendação', () {
    test('Deve calcular a participação percentual atual de K na CTC', () {
      // 0.3 de CTC 10.0 é 3.0%
      final participacao =
          PotassioFormula.participacaoAtual(kAtual: 0.3, ctc: 10.0);
      expect(participacao, 3.0);
    });

    test('Deve retornar 0 de participação na CTC se a CTC for 0', () {
      final participacao =
          PotassioFormula.participacaoAtual(kAtual: 0.3, ctc: 0.0);
      expect(participacao, 0.0);
    });

    test('Deve calcular recomendação de K2O quando déficit existe', () {
      // CTC = 10.0, K Atual = 0.2 (2%), Desejado = 5.0 (5%)
      // K Desejado = 0.5. Déficit = 0.3 cmolc/dm3.
      // Dose = 0.3 * 942.31 = 282.693 kg/ha de K2O
      final dose = PotassioFormula.recomendacao(
          ctc: 10.0, kAtual: 0.2, participacaoDesejada: 5.0);
      expect(dose, closeTo(282.693, 0.01));
    });

    test('Deve retornar 0 se a participação atual já for superior ao desejado',
        () {
      final dose = PotassioFormula.recomendacao(
          ctc: 10.0, kAtual: 0.6, participacaoDesejada: 5.0); // 6%
      expect(dose, 0.0);
    });

    test('Para algodão, alvo mínimo deve ser 5% de CTC', () {
      final dose = PotassioFormula.recomendacao(
        ctc: 10.0,
        kAtual: 0.4, // 4%
        participacaoDesejada: 4.0,
        cultura: 'algodao',
      );
      // ajuste para 5% => déficit 0.1 * 942.21
      expect(dose, closeTo(94.221, 0.01));
    });

    test('Critério de teor absoluto opcional deve atuar como segundo critério',
        () {
      final dose = PotassioFormula.recomendacao(
        ctc: 10.0,
        kAtual: 0.5, // 5% => sem déficit por saturação
        participacaoDesejada: 5.0,
        usarCriterioTeorAbsoluto: true,
        kAtualMgDm3: 30.0,
        argilaPercent: 10.0, // nc absoluto 40
      );
      expect(dose, greaterThan(0));
    });

    test('Modo 1 por teor aplica percentual de correção (pct/100)', () {
      final dose100 = PotassioFormula.recomendacaoPorTeorAbsoluto(
        kAtualMgDm3: 30.0,
        argilaPercent: 10.0, // NC = 40, déficit = 10
        percentualCorrecao: 100.0,
      );
      final dose50 = PotassioFormula.recomendacaoPorTeorAbsoluto(
        kAtualMgDm3: 30.0,
        argilaPercent: 10.0,
        percentualCorrecao: 50.0,
      );
      expect(dose50, closeTo(dose100 * 0.5, 0.0001));
    });

    test('FEK base por textura e override algodão', () {
      expect(PotassioFormula.fekBase(10.0), 50.0);
      expect(PotassioFormula.fekBase(30.0), 60.0);
      expect(PotassioFormula.fekBase(50.0), 65.0);
      expect(PotassioFormula.fekBase(70.0), 70.0);
      expect(
        PotassioFormula.fekFinal(argilaPercent: 70.0, cultura: 'algodao'),
        60.0,
      );
    });

    test('Modo 2 — extração calcula dose final', () {
      final dose = PotassioFormula.recomendacaoExtracao(
        kSolo: 80.0,
        percentualUsoSolo: 50.0,
        extracaoK2O: 150.0,
        fek: 60.0,
      );
      // kSoloUsado=40; kSoloKg=96.4; base=53.6; final=89.33
      expect(dose, closeTo(89.33, 0.01));
    });

    test('aviso de sulco quando dose > 40 kg/ha', () {
      expect(
        PotassioFormula.avisoSulco(modoAplicacao: 'sulco', doseK2O: 41.0),
        isTrue,
      );
      expect(
        PotassioFormula.avisoSulco(modoAplicacao: 'sulco', doseK2O: 40.0),
        isFalse,
      );
    });

    test('saídas de antagonismo e flags', () {
      final r = PotassioFormula.calcularAntagonismos(
        kTotal: 1.0,
        ctc: 10.0,
        mgAtual: 0.8,
        caAtual: 2.0,
      );
      expect(r.pctKCTC, 10.0);
      expect(r.avisoKCTC, isTrue);
      expect(r.relKMg, 1.25);
      expect(r.avisoKMg, isTrue);
      expect(r.relKCa, 0.5);
      expect(r.avisoKCa, isTrue);
    });

    test('utilitário K mg/dm3 -> cmolc/dm3', () {
      expect(PotassioFormula.kMgDm3ToCmolc(391.0), 1.0);
    });
  });
}
