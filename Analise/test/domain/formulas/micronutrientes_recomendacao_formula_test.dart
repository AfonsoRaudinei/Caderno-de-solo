import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/micronutrientes_recomendacao_formula.dart';

void main() {
  group('MicronutrientesRecomendacaoFormula', () {
    test('déficit abaixo do NC', () {
      expect(
        calcularDeficitMicronutriente(nivelCritico: 0.9, teorAtual: 0.5),
        closeTo(0.4, 0.001),
      );
    });

    test('déficit igual ao NC', () {
      expect(
        calcularDeficitMicronutriente(nivelCritico: 0.9, teorAtual: 0.9),
        0,
      );
    });

    test('déficit acima do NC', () {
      expect(
        calcularDeficitMicronutriente(nivelCritico: 0.9, teorAtual: 1.2),
        0,
      );
    });

    test('correção solo aplica déficit × 2 × 1000 e eficiência', () {
      final correcao = calcularCorrecaoSoloMicronutriente(
        deficit: 0.5,
        eficienciaSoloPercent: 50,
      );
      // 0.5 * 2000 = 1000 / 0.5 = 2000
      expect(correcao, closeTo(2000, 0.01));
    });

    test('nunca usa apenas NC × 2000 sem déficit', () {
      final comDeficit = calcularCorrecaoSoloMicronutriente(
        deficit: 0.5,
        eficienciaSoloPercent: 100,
      );
      final semDeficit = calcularCorrecaoSoloMicronutriente(
        deficit: 0,
        eficienciaSoloPercent: 100,
      );
      expect(comDeficit, closeTo(1000, 0.01));
      expect(semDeficit, 0);
      expect(comDeficit, isNot(closeTo(0.9 * 2000, 0.01)));
    });

    test('extração e exportação por produção', () {
      expect(
        calcularExtracaoMicronutriente(
          producaoTha: 4,
          extracaoPlantaGt: 70,
        ),
        closeTo(280, 0.01),
      );
      expect(
        calcularExportacaoMicronutriente(
          producaoTha: 4,
          exportacaoGraosGt: 30,
        ),
        closeTo(120, 0.01),
      );
    });

    test('regra planta quando teor < NC', () {
      expect(
        regraPlantaOuGrao(teorAtual: 0.5, nivelCritico: 0.9),
        'Planta',
      );
    });

    test('regra grão quando teor >= NC', () {
      expect(
        regraPlantaOuGrao(teorAtual: 1.0, nivelCritico: 0.9),
        'Grão',
      );
    });

    test('conversão para fonte em %', () {
      final dose = converterDoseComercialGHa(
        doseElementoGHa: 200,
        concentracao: 20,
        unidadeConcentracao: '%',
        eficienciaPercent: 80,
      );
      // 200 / 0.2 / 0.8 = 1250
      expect(dose, closeTo(1250, 0.01));
    });

    test('conversão para fonte em g/kg', () {
      final dose = converterDoseComercialGHa(
        doseElementoGHa: 100,
        concentracao: 50,
        unidadeConcentracao: 'g/kg',
        eficienciaPercent: 100,
      );
      // 100 / 0.05 = 2000
      expect(dose, closeTo(2000, 0.01));
    });

    test('limites mínimo e máximo', () {
      expect(
        aplicarLimitesDoseComercial(
          doseComercialGHa: 50,
          doseMinima: 100,
          doseMaxima: 0,
        ),
        100,
      );
      expect(
        aplicarLimitesDoseComercial(
          doseComercialGHa: 500,
          doseMinima: 0,
          doseMaxima: 300,
        ),
        300,
      );
    });

    test('eficiência por via sem mistura', () {
      expect(
        eficienciaGrupoPorVia(
          via: 'Solo',
          eficienciaSolo: 30,
          eficienciaFoliar: 70,
          eficienciaTs: 80,
        ),
        30,
      );
      expect(
        eficienciaGrupoPorVia(
          via: 'Foliar',
          eficienciaSolo: 30,
          eficienciaFoliar: 70,
          eficienciaTs: 80,
        ),
        70,
      );
    });

    test('produção kg/ha para t/ha', () {
      expect(producaoKgHaParaTha(3500), closeTo(3.5, 0.001));
    });
  });
}
