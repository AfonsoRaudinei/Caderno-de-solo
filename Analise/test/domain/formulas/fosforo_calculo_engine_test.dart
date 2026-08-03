import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/fosforo_calculo_engine.dart';
import 'package:soloforte/domain/formulas/fosforo_calibracao_config.dart';
import 'package:soloforte/domain/formulas/fosforo_formula.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
import 'package:soloforte/domain/entities/analise_entity.dart';

void main() {
  group('FosforoCalculoEngine — correção do solo', () {
    const base = FosforoCalculoInput(
      soilP: 8,
      criticalLevel: 12,
      correcaoSoloAtiva: true,
      fatorCorrecao: 3,
      replacementMode: ModoReposicaoP.semReposicao,
      productionExpected: 0,
      percentualSolo: 0,
      efficiencyAdjustmentPercent: 0,
    );

    test('P abaixo do NC gera correção positiva', () {
      final r = FosforoCalculoEngine.calcular(base);
      expect(r.deficitP, 4);
      expect(r.correctionP2O5, 12);
      expect(r.finalP2O5, 12);
    });

    test('P igual ao NC → déficit e correção zero', () {
      final r = FosforoCalculoEngine.calcular(
        FosforoCalculoInput(
          soilP: 12,
          criticalLevel: 12,
          correcaoSoloAtiva: true,
          fatorCorrecao: 3,
          replacementMode: ModoReposicaoP.semReposicao,
          productionExpected: 0,
          percentualSolo: 0,
          efficiencyAdjustmentPercent: 0,
        ),
      );
      expect(r.deficitP, 0);
      expect(r.correctionP2O5, 0);
    });

    test('P acima do NC → déficit e correção zero', () {
      final r = FosforoCalculoEngine.calcular(
        base.copyWith(soilP: 20),
      );
      expect(r.deficitP, 0);
      expect(r.correctionP2O5, 0);
    });

    test('correção OFF zera correção mesmo com déficit', () {
      final r = FosforoCalculoEngine.calcular(
        base.copyWith(correcaoSoloAtiva: false),
      );
      expect(r.deficitP, 4);
      expect(r.correctionP2O5, 0);
      expect(r.finalP2O5, 0);
    });
  });

  group('FosforoCalculoEngine — sem reposição', () {
    test('reposição e eficiência zeradas', () {
      final r = FosforoCalculoEngine.calcular(
        const FosforoCalculoInput(
          soilP: 5,
          criticalLevel: 12,
          correcaoSoloAtiva: true,
          fatorCorrecao: 4,
          replacementMode: ModoReposicaoP.semReposicao,
          productionExpected: 4.2,
          extractionRate: 15.4,
          percentualSolo: 0,
          efficiencyAdjustmentPercent: 50,
        ),
      );
      expect(r.replacementBaseP2O5, 0);
      expect(r.efficiencyIncrementP2O5, 0);
      expect(r.replacementAdjustedP2O5, 0);
      expect(r.finalP2O5, r.correctionP2O5);
    });
  });

  group('FosforoCalculoEngine — exportação', () {
    test('fixture 4,2 t/ha × 10 kg/t com ajuste 50% = 63', () {
      final r = FosforoCalculoEngine.calcular(
        const FosforoCalculoInput(
          soilP: 20,
          criticalLevel: 12,
          correcaoSoloAtiva: false,
          fatorCorrecao: 4,
          replacementMode: ModoReposicaoP.exportacao,
          productionExpected: 4.2,
          exportRate: 10,
          percentualSolo: 0,
          efficiencyAdjustmentPercent: 50,
        ),
      );
      expect(r.totalDemandP2O5, closeTo(42, 0.01));
      expect(r.replacementBaseP2O5, closeTo(42, 0.01));
      expect(r.efficiencyIncrementP2O5, closeTo(21, 0.01));
      expect(r.replacementAdjustedP2O5, closeTo(63, 0.01));
      expect(r.finalP2O5, closeTo(63, 0.01));
    });

    test('produção zero usa fallbackDemand', () {
      final r = FosforoCalculoEngine.calcular(
        const FosforoCalculoInput(
          soilP: 10,
          criticalLevel: 12,
          correcaoSoloAtiva: false,
          fatorCorrecao: 4,
          replacementMode: ModoReposicaoP.exportacao,
          productionExpected: 0,
          exportRate: 10,
          fallbackDemandP2O5: 80,
          percentualSolo: 0,
          efficiencyAdjustmentPercent: 0,
        ),
      );
      expect(r.replacementBaseP2O5, 80);
    });

    test('exportação zero → reposição zero', () {
      final r = FosforoCalculoEngine.calcular(
        const FosforoCalculoInput(
          soilP: 10,
          criticalLevel: 12,
          correcaoSoloAtiva: false,
          fatorCorrecao: 4,
          replacementMode: ModoReposicaoP.exportacao,
          productionExpected: 4.2,
          exportRate: 0,
          percentualSolo: 0,
          efficiencyAdjustmentPercent: 50,
        ),
      );
      expect(r.replacementBaseP2O5, 0);
    });
  });

  group('FosforoCalculoEngine — extração', () {
    test('REGRESSÃO OBRIGATÓRIA: 4,2 × 15,4 com 0% solo e 50% eficiência', () {
      final r = FosforoCalculoEngine.calcular(
        const FosforoCalculoInput(
          soilP: 10,
          criticalLevel: 12,
          correcaoSoloAtiva: false,
          fatorCorrecao: 4,
          replacementMode: ModoReposicaoP.extracao,
          productionExpected: 4.2,
          extractionRate: 15.4,
          percentualSolo: 0,
          efficiencyAdjustmentPercent: 50,
        ),
      );

      expect(r.totalDemandP2O5, closeTo(64.68, 0.01));
      expect(r.soilContributionP2O5, closeTo(0, 0.01));
      expect(r.replacementBaseP2O5, closeTo(64.68, 0.01));
      expect(r.efficiencyIncrementP2O5, closeTo(32.34, 0.01));
      expect(r.replacementAdjustedP2O5, closeTo(97.02, 0.01));
      expect(r.finalP2O5, closeTo(97.02, 0.01));
    });

    test('percentual solo 100% zera reposição base', () {
      final r = FosforoCalculoEngine.calcular(
        const FosforoCalculoInput(
          soilP: 10,
          criticalLevel: 12,
          correcaoSoloAtiva: false,
          fatorCorrecao: 4,
          replacementMode: ModoReposicaoP.extracao,
          productionExpected: 4.2,
          extractionRate: 15.4,
          percentualSolo: 100,
          efficiencyAdjustmentPercent: 50,
        ),
      );
      expect(r.totalDemandP2O5, closeTo(64.68, 0.01));
      expect(r.soilContributionP2O5, closeTo(64.68, 0.01));
      expect(r.replacementBaseP2O5, 0);
      expect(r.finalP2O5, 0);
    });

    test('extração zero → reposição zero', () {
      final r = FosforoCalculoEngine.calcular(
        const FosforoCalculoInput(
          soilP: 10,
          criticalLevel: 12,
          correcaoSoloAtiva: false,
          fatorCorrecao: 4,
          replacementMode: ModoReposicaoP.extracao,
          productionExpected: 4.2,
          extractionRate: 0,
          percentualSolo: 0,
          efficiencyAdjustmentPercent: 50,
        ),
      );
      expect(r.replacementBaseP2O5, 0);
    });
  });

  group('FosforoCalculoEngine — ajuste de eficiência', () {
    const extracaoBase = FosforoCalculoInput(
      soilP: 10,
      criticalLevel: 12,
      correcaoSoloAtiva: false,
      fatorCorrecao: 4,
      replacementMode: ModoReposicaoP.extracao,
      productionExpected: 4.2,
      extractionRate: 15.4,
      percentualSolo: 0,
      efficiencyAdjustmentPercent: 0,
    );

    test('ajuste 0% não incrementa', () {
      final r = FosforoCalculoEngine.calcular(extracaoBase);
      expect(r.efficiencyIncrementP2O5, 0);
      expect(r.replacementAdjustedP2O5, closeTo(64.68, 0.01));
    });

    test('ajuste 100% dobra reposição base', () {
      final r = FosforoCalculoEngine.calcular(
        extracaoBase.copyWith(efficiencyAdjustmentPercent: 100),
      );
      expect(r.replacementAdjustedP2O5, closeTo(64.68 * 2, 0.01));
    });

    test('eficiência aplica só na reposição, não na correção', () {
      final r = FosforoCalculoEngine.calcular(
        extracaoBase.copyWith(
          correcaoSoloAtiva: true,
          soilP: 8,
          criticalLevel: 12,
          fatorCorrecao: 3,
          efficiencyAdjustmentPercent: 50,
        ),
      );
      expect(r.correctionP2O5, 12);
      expect(r.replacementAdjustedP2O5, closeTo(97.02, 0.01));
      expect(r.finalP2O5, closeTo(12 + 97.02, 0.01));
    });

    test('percentuais >100 são limitados na engine via input clamp', () {
      final r = FosforoCalculoEngine.calcular(
        extracaoBase.copyWith(efficiencyAdjustmentPercent: 150),
      );
      expect(r.efficiencyAdjustmentPercent, 100);
      expect(r.replacementAdjustedP2O5, closeTo(64.68 * 2, 0.01));
    });
  });

  group('FosforoCalculoEngine — resultado final por modo', () {
    test('sem reposição: final = correção', () {
      final r = FosforoCalculoEngine.calcular(
        const FosforoCalculoInput(
          soilP: 8,
          criticalLevel: 12,
          correcaoSoloAtiva: true,
          fatorCorrecao: 2,
          replacementMode: ModoReposicaoP.semReposicao,
          productionExpected: 4.2,
          extractionRate: 15.4,
          percentualSolo: 0,
          efficiencyAdjustmentPercent: 50,
        ),
      );
      expect(r.finalP2O5, r.correctionP2O5);
    });
  });

  group('FosforoCalculoEngine — dose produto comercial', () {
    test('conversão matemática exemplo spec', () {
      final dose = FosforoCalculoEngine.doseProdutoComercial(
        p2o5Final: 217.02,
        teorP2O5Percent: 52,
      );
      expect(dose, closeTo(417.35, 0.01));
    });
  });

  group('Integração Calibração → Cálculo', () {
    final engine = RecomendacaoEngine();

    const analise = AnaliseEntity(
      id: 'a1',
      nome: 'Teste P',
      consultor: 'Teste',
      fazenda: '',
      talhao: 'T1',
      localizacao: '',
      cultura: 'Soja',
      ph: 5.2,
      mo: 30,
      p: 8,
      k: 0.16,
      ca: 2.0,
      mg: 0.5,
      hAl: 3.38,
      al: 0.3,
      s: 6,
      b: 0.2,
      cu: 0.5,
      fe: 30,
      mn: 4,
      zn: 1.2,
      sb: 2.66,
      ctc: 6.04,
      vPercent: 43.7,
      argila: 25,
    );

    test('calcularFosforo retorna parcelas auditáveis', () {
      final result = engine.calcularFosforo(
        fosforo: {
          'correcaoSoloAtiva': true,
          'modoReposicao': 'Extração',
          'referencia': 'IAC Bol.100',
          'nc': 12,
          'fatorSolo': 4,
          'percentualUsoPSolo': 0,
          'ajusteEficienciaSolo': 50,
          'fosforoTipoFonte': 'Autores',
          'fosforoFonteNome': '',
        },
        analise: analise,
        cultura: 'Soja',
        tabelas: [],
        produtividadeTha: 4.2,
      );

      expect(result.criticalLevel, greaterThan(0));
      expect(result.replacementMode, ModoReposicaoP.extracao);
      expect(result.doseP, greaterThanOrEqualTo(0));
    });
  });

  group('Divergência documentada — fórmula legada de extração', () {
    test('legado descontava P da análise, não % da demanda', () {
      const demandaTotal = 64.68;
      final legado = FosforoFormula.recomendacaoExtracao(
        pSolo: 15,
        percentualUsoSolo: 50,
        profundidadeCm: 20,
        extracaoP2O5: demandaTotal,
        fepFinal: 100,
      );

      final novo = FosforoCalculoEngine.calcular(
        const FosforoCalculoInput(
          soilP: 15,
          criticalLevel: 12,
          correcaoSoloAtiva: false,
          fatorCorrecao: 4,
          replacementMode: ModoReposicaoP.extracao,
          productionExpected: 4.2,
          extractionRate: 15.4,
          percentualSolo: 50,
          efficiencyAdjustmentPercent: 0,
        ),
      );

      expect(novo.replacementBaseP2O5, closeTo(32.34, 0.01));
      expect(legado, isNot(closeTo(novo.replacementBaseP2O5, 0.5)));
    });
  });
}

extension on FosforoCalculoInput {
  FosforoCalculoInput copyWith({
    double? soilP,
    double? criticalLevel,
    bool? correcaoSoloAtiva,
    double? fatorCorrecao,
    ModoReposicaoP? replacementMode,
    double? productionExpected,
    double? extractionRate,
    double? exportRate,
    double? percentualSolo,
    double? efficiencyAdjustmentPercent,
    double? fallbackDemandP2O5,
  }) {
    return FosforoCalculoInput(
      soilP: soilP ?? this.soilP,
      criticalLevel: criticalLevel ?? this.criticalLevel,
      correcaoSoloAtiva: correcaoSoloAtiva ?? this.correcaoSoloAtiva,
      fatorCorrecao: fatorCorrecao ?? this.fatorCorrecao,
      replacementMode: replacementMode ?? this.replacementMode,
      productionExpected: productionExpected ?? this.productionExpected,
      extractionRate: extractionRate ?? this.extractionRate,
      exportRate: exportRate ?? this.exportRate,
      percentualSolo: percentualSolo ?? this.percentualSolo,
      efficiencyAdjustmentPercent:
          efficiencyAdjustmentPercent ?? this.efficiencyAdjustmentPercent,
      fallbackDemandP2O5: fallbackDemandP2O5 ?? this.fallbackDemandP2O5,
      legacyExportacaoGrao: legacyExportacaoGrao,
      legacyManutencaoFactor: legacyManutencaoFactor,
    );
  }
}
