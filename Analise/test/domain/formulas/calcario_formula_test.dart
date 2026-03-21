import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/calcario_formula.dart';

void main() {
  group('CalcarioFormula - Necessidade de Calagem', () {
    group('Método SMP', () {
      test('Deve recomendar calcário corretamente para pH SMP muito baixo', () {
        final dose = CalcarioFormula.metodoSMP(phSmp: 4.5, prnt: 100);
        expect(dose, 15.0);
      });

      test('Deve recomendar calcário ajustado pelo PRNT', () {
        final dose = CalcarioFormula.metodoSMP(phSmp: 4.5, prnt: 80);
        expect(dose, 18.75);
      });

      test('Não deve recomendar calcário para pH SMP ideal', () {
        final dose = CalcarioFormula.metodoSMP(phSmp: 6.5, prnt: 100);
        expect(dose, 0.0);
      });
    });

    group('Método V%', () {
      test('Deve calcular corretamente quando V atual é menor que V desejado',
          () {
        // Formúla: (10.0 * (70 - 40)) / 100 = 3.0 t/ha
        final dose = CalcarioFormula.metodoV(
            ctc: 10.0, vAtual: 40, vDesejado: 70, prnt: 100);
        expect(dose, 3.0);
      });

      test('Deve retornar 0 quando V atual é maior ou igual ao V desejado', () {
        final dose = CalcarioFormula.metodoV(
            ctc: 10.0, vAtual: 75, vDesejado: 70, prnt: 100);
        expect(dose, 0.0);
      });
    });

    group('Método IAC', () {
      test('Deve calcular elevação de Ca corretamente', () {
        final dose =
            CalcarioFormula.metodoIAC(caDesejado: 5.0, caAtual: 2.0, prnt: 100);
        expect(dose, 3.0);
      });

      test('Deve retornar 0 se o Ca atual já for suficiente', () {
        final dose =
            CalcarioFormula.metodoIAC(caDesejado: 5.0, caAtual: 6.0, prnt: 100);
        expect(dose, 0.0);
      });
    });

    group('Novos métodos', () {
      test('metas Albrecht padrão por cultura', () {
        final soja = CalcarioFormula.metasAlbrechtPorCultura(cultura: 'soja');
        final milho = CalcarioFormula.metasAlbrechtPorCultura(cultura: 'milho');
        final feijao =
            CalcarioFormula.metasAlbrechtPorCultura(cultura: 'feijão');
        final algodao =
            CalcarioFormula.metasAlbrechtPorCultura(cultura: 'algodão');

        expect((soja.pctCa, soja.pctMg, soja.pctK), (65.0, 15.0, 4.0));
        expect((milho.pctCa, milho.pctMg, milho.pctK), (65.0, 15.0, 4.0));
        expect((feijao.pctCa, feijao.pctMg, feijao.pctK), (65.0, 15.0, 5.0));
        expect((algodao.pctCa, algodao.pctMg, algodao.pctK), (65.0, 12.0, 5.0));
      });

      test('metas Albrecht permitem override editável', () {
        final metas = CalcarioFormula.metasAlbrechtPorCultura(
          cultura: 'soja',
          pctCa: 66.0,
          pctK: 4.5,
        );
        expect(metas.pctCa, 66.0);
        expect(metas.pctMg, 15.0);
        expect(metas.pctK, 4.5);
      });

      test('Método EMBRAPA: NC = H+Al × fator', () {
        final dose = CalcarioFormula.metodoEmbrapa(
          hAl: 4.0,
          fator: 0.5,
          prnt: 100,
        );
        expect(dose, 2.0);
      });

      test('Método Supercalagem usa dose fixa', () {
        final dose = CalcarioFormula.metodoSupercalagem(
          doseFixa: 1.75,
          prnt: 100,
        );
        expect(dose, 1.75);
      });

      test('calcularY aplica equação contínua', () {
        final y = CalcarioFormula.calcularY(40.0);
        expect(y, closeTo(2.2318, 0.001));
      });

      test('fator de profundidade interpolado em 30 cm', () {
        final p = CalcarioFormula.fatorProfundidade(30.0);
        expect(p, closeTo(1.515, 0.001));
      });

      test('profundidade por grade usa raio e folga do mancal', () {
        final prof = CalcarioFormula.profundidadePorGrade(
          diametroPol: 32.0,
          folgaMancalCm: 25.0,
        );
        // raio=40.64; prof=40.64-12.5=28.14
        expect(prof, closeTo(28.14, 0.01));
      });

      test('PRNT = PN × RE / 100', () {
        final prnt = CalcarioFormula.calcularPRNT(pn: 100, re: 80);
        expect(prnt, 80.0);
      });

      test('PRNT ponderado com dois calcários', () {
        final prnt = CalcarioFormula.calcularPRNTPonderado(
          prnt1: 80.0,
          prnt2: 60.0,
          proporcao1: 70.0,
          proporcao2: 30.0,
        );
        expect(prnt, 74.0);
      });

      test('fatores ponderados Ca/Mg com dois calcários', () {
        final r = CalcarioFormula.fatoresPonderadosCalcarios(
          fatorCa1: 0.50,
          fatorCa2: 0.80,
          fatorMg1: 0.40,
          fatorMg2: 0.10,
          proporcao1: 60.0,
          proporcao2: 40.0,
        );
        expect(r.fatorCaFinal, closeTo(0.62, 0.0001));
        expect(r.fatorMgFinal, closeTo(0.28, 0.0001));
      });

      test('calcularY por P-rem', () {
        final y = CalcarioFormula.calcularYPorPrem(19.0);
        expect(y, closeTo(2.0, 0.001));
      });

      test('calcularY critério 60/40 quando ambos existem', () {
        final y = CalcarioFormula.calcularYCriterio(
          argilaPercent: 40.0,
          prem: 19.0,
        );
        final yArg = CalcarioFormula.calcularY(40.0);
        expect(y, closeTo(yArg * 0.6 + 2.0 * 0.4, 0.001));
      });

      test('metodoCaMg aplica correções padrão', () {
        final dose = CalcarioFormula.metodoCaMg(
          caAtual: 2.0,
          mgAtual: 1.0,
          prnt: 80.0,
          profundidadeCm: 40.0,
          sc: 0.9,
        );
        // nc=3; p=2.03; nc_prof=6.09; nc_prnt=7.6125; dose=8.4583
        expect(dose, closeTo(8.4583, 0.001));
      });

      test('metodo3CaMg (alias) mantém compatibilidade', () {
        final doseAlias = CalcarioFormula.metodo3CaMg(
          caAtual: 2.0,
          mgAtual: 1.0,
          prnt: 80.0,
          profundidadeCm: 40.0,
          sc: 0.9,
        );
        final doseNovo = CalcarioFormula.metodoCaMg(
          caAtual: 2.0,
          mgAtual: 1.0,
          prnt: 80.0,
          profundidadeCm: 40.0,
          sc: 0.9,
        );
        expect(doseAlias, closeTo(doseNovo, 0.000001));
      });

      test('Albrecht com déficit de Ca gera dose > 0', () {
        final dose = CalcarioFormula.metodoAlbrecht(
          ctc: 10.0,
          caAtual: 2.0,
          mgAtual: 1.0,
          kAtual: 0.2,
          pctCaAlvo: 60.0,
          pctMgAlvo: 12.0,
          pctKAlvo: 4.0,
          caO: 30.0,
          prnt: 100,
        );
        expect(dose, closeTo(3.734, 0.001));
      });

      test('Albrecht aplica piso absoluto de Ca (2.0 cmolc/dm³)', () {
        final doseComPiso = CalcarioFormula.metodoAlbrecht(
          ctc: 2.0,
          caAtual: 1.0,
          mgAtual: 0.3,
          kAtual: 0.05,
          pctCaAlvo: 60.0, // alvo percentual = 1.2 (abaixo do piso 2.0)
          pctMgAlvo: 10.0,
          pctKAlvo: 3.0,
          caO: 30.0,
          prnt: 100,
        );

        final doseSemPisoCa = CalcarioFormula.metodoAlbrecht(
          ctc: 2.0,
          caAtual: 1.0,
          mgAtual: 0.3,
          kAtual: 0.05,
          pctCaAlvo: 60.0,
          pctMgAlvo: 10.0,
          pctKAlvo: 3.0,
          caO: 30.0,
          prnt: 100,
          pisoCaCmolc: 0.0,
        );

        expect(doseComPiso, greaterThan(doseSemPisoCa));
      });

      test('Albrecht por cultura respeita pisos absolutos editáveis', () {
        final dosePadrao = CalcarioFormula.metodoAlbrechtPorCultura(
          cultura: 'soja',
          ctc: 2.0,
          caAtual: 1.0,
          mgAtual: 0.3,
          kAtual: 0.05,
          caO: 30.0,
          prnt: 100.0,
        );
        final dosePisoMenor = CalcarioFormula.metodoAlbrechtPorCultura(
          cultura: 'soja',
          ctc: 2.0,
          caAtual: 1.0,
          mgAtual: 0.3,
          kAtual: 0.05,
          caO: 30.0,
          prnt: 100.0,
          pisoCaCmolc: 0.0,
        );

        expect(dosePadrao, greaterThan(dosePisoMenor));
      });

      test('Albrecht por cultura usa metas padrão de cada cultura', () {
        final doseSoja = CalcarioFormula.metodoAlbrechtPorCultura(
          cultura: 'soja',
          ctc: 10.0,
          caAtual: 2.0,
          mgAtual: 1.0,
          kAtual: 0.2,
          caO: 30.0,
          prnt: 100.0,
        );
        final doseSojaEsperada = CalcarioFormula.metodoAlbrecht(
          ctc: 10.0,
          caAtual: 2.0,
          mgAtual: 1.0,
          kAtual: 0.2,
          pctCaAlvo: 65.0,
          pctMgAlvo: 15.0,
          pctKAlvo: 4.0,
          caO: 30.0,
          prnt: 100.0,
        );
        final doseFeijao = CalcarioFormula.metodoAlbrechtPorCultura(
          cultura: 'feijao',
          ctc: 10.0,
          caAtual: 2.0,
          mgAtual: 1.0,
          kAtual: 0.2,
          caO: 30.0,
          prnt: 100.0,
        );
        final doseFeijaoEsperada = CalcarioFormula.metodoAlbrecht(
          ctc: 10.0,
          caAtual: 2.0,
          mgAtual: 1.0,
          kAtual: 0.2,
          pctCaAlvo: 65.0,
          pctMgAlvo: 15.0,
          pctKAlvo: 5.0,
          caO: 30.0,
          prnt: 100.0,
        );

        expect(doseSoja, closeTo(doseSojaEsperada, 0.000001));
        expect(doseFeijao, closeTo(doseFeijaoEsperada, 0.000001));
      });

      test('AlbrechtY usa max(NC_Albrecht, Y)', () {
        final dose = CalcarioFormula.metodoAlbrechtY(
          ctc: 10.0,
          caAtual: 3.0,
          mgAtual: 1.0,
          kAtual: 0.2,
          pctCaAlvo: 60.0,
          pctMgAlvo: 12.0,
          pctKAlvo: 4.0,
          caO: 30.0,
          argilaPercent: 40.0,
          prnt: 100,
        );
        // NC Albrecht ~2.80 e Y~2.25 => prevalece NC Albrecht.
        expect(dose, closeTo(2.80, 0.01));
      });

      test('Correção de Mg = déficit / fatorMgCalcario', () {
        final dose = CalcarioFormula.metodoCorrecaoMg(
          mgDesejado: 1.2,
          mgAtual: 0.6,
          fatorMgCalcario: 0.3,
          prnt: 100,
        );
        expect(dose, closeTo(2.0, 0.001));
      });

      test('Saturações finais retornam relação Ca/Mg', () {
        final r = CalcarioFormula.calcularSaturacoesFinais(
          caAtual: 2.0,
          mgAtual: 1.0,
          kAtual: 0.2,
          ctcAtual: 10.0,
          doseFinal: 2.0,
          caO: 30.0,
          mgO: 16.0,
        );
        expect(r.caTotal, greaterThan(2.0));
        expect(r.mgTotal, greaterThan(1.0));
        expect(r.relCaMg, greaterThan(1.0));
        expect(r.classeRelCaMg, equals(ClasseRelacaoCaMg.adequada));
      });

      test('classificação da relação Ca:Mg', () {
        expect(CalcarioFormula.classificarRelacaoCaMg(1.2),
            equals(ClasseRelacaoCaMg.estreita));
        expect(CalcarioFormula.classificarRelacaoCaMg(2.0),
            equals(ClasseRelacaoCaMg.adequada));
        expect(CalcarioFormula.classificarRelacaoCaMg(4.0),
            equals(ClasseRelacaoCaMg.larga));
        expect(CalcarioFormula.classificarRelacaoCaMg(5.2),
            equals(ClasseRelacaoCaMg.muitoLarga));
      });
    });
  });
}
