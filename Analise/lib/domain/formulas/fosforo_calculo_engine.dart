import 'package:soloforte/domain/formulas/fosforo_calibracao_config.dart';
import 'package:soloforte/domain/formulas/fosforo_calculo_result.dart';
import 'package:soloforte/domain/formulas/fosforo_formula.dart';

/// Entrada pura para o motor de cálculo de Fósforo.
class FosforoCalculoInput {
  const FosforoCalculoInput({
    required this.soilP,
    required this.criticalLevel,
    required this.correcaoSoloAtiva,
    required this.fatorCorrecao,
    required this.replacementMode,
    required this.productionExpected,
    required this.percentualSolo,
    required this.efficiencyAdjustmentPercent,
    this.extractionRate,
    this.exportRate,
    this.fallbackDemandP2O5,
    this.legacyExportacaoGrao,
    this.legacyManutencaoFactor = 0.30,
  });

  /// P atual da análise (mg/dm³ de P).
  final double soilP;

  /// NC configurado (mg/dm³ de P).
  final double criticalLevel;

  final bool correcaoSoloAtiva;

  /// Fator de correção (kg P₂O₅/ha por mg/dm³ de déficit) — da referência/calibração.
  final double fatorCorrecao;

  final ModoReposicaoP replacementMode;

  /// Produtividade esperada (t/ha).
  final double productionExpected;

  /// Índice de extração (kg P₂O₅/t) — da referência agronômica.
  final double? extractionRate;

  /// Índice de exportação (kg P₂O₅/t) — da referência agronômica.
  final double? exportRate;

  /// % P do solo considerado (0–100) — apenas extração.
  final double percentualSolo;

  /// Ajuste de eficiência no solo (0–100) — acréscimo sobre reposição base.
  final double efficiencyAdjustmentPercent;

  /// Demanda total em kg P₂O₅/ha quando produtividade/índice não estão disponíveis.
  final double? fallbackDemandP2O5;

  /// Exportação de referência (kg P₂O₅/ha) para regra Legacy P.
  final double? legacyExportacaoGrao;

  final double legacyManutencaoFactor;
}

/// Motor de cálculo completo de Fósforo.
///
/// ## Divergência documentada — contribuição do solo na extração
///
/// A implementação legada em [FosforoFormula.recomendacaoExtracao] descontava
/// o P da análise (mg/dm³) convertido para kg P₂O₅/ha, multiplicado pelo
/// percentual informado.
///
/// Este motor segue a regra do card de calibração e da especificação atual:
/// `contribuicaoSolo = demandaTotal × (percentualSolo / 100)`.
///
/// Quando produtividade/índice não estão disponíveis, usa [fallbackDemandP2O5]
/// como demanda total legada (sem desconto analítico de P).
class FosforoCalculoEngine {
  const FosforoCalculoEngine._();

  static FosforoCalculoResult calcular(FosforoCalculoInput input) {
    final soilP = input.soilP.clamp(0.0, double.infinity);
    final nc = input.criticalLevel.clamp(0.0, double.infinity);
    final deficitP = (nc - soilP).clamp(0.0, double.infinity);

    final correctionP2O5 = input.correcaoSoloAtiva && deficitP > 0
        ? deficitP * input.fatorCorrecao
        : 0.0;

    final percentualSolo = input.percentualSolo.clamp(0.0, 100.0).toDouble();
    final ajuste =
        input.efficiencyAdjustmentPercent.clamp(0.0, 100.0).toDouble();

    var totalDemand = 0.0;
    var soilContribution = 0.0;
    var replacementBase = 0.0;
    var efficiencyIncrement = 0.0;
    var replacementAdjusted = 0.0;

    switch (input.replacementMode) {
      case ModoReposicaoP.semReposicao:
        break;
      case ModoReposicaoP.exportacao:
        totalDemand = _demandaPorProducao(
          productionExpected: input.productionExpected,
          indiceP2O5PorT: input.exportRate,
          fallbackDemand: input.fallbackDemandP2O5,
        );
        replacementBase = totalDemand;
        break;
      case ModoReposicaoP.extracao:
        totalDemand = _demandaPorProducao(
          productionExpected: input.productionExpected,
          indiceP2O5PorT: input.extractionRate,
          fallbackDemand: input.fallbackDemandP2O5,
        );
        soilContribution = totalDemand * (percentualSolo / 100.0);
        replacementBase =
            (totalDemand - soilContribution).clamp(0.0, double.infinity);
        break;
    }

    if (input.replacementMode != ModoReposicaoP.semReposicao) {
      efficiencyIncrement = replacementBase * (ajuste / 100.0);
      replacementAdjusted = replacementBase + efficiencyIncrement;
    }

    var finalP2O5 = correctionP2O5 + replacementAdjusted;

    var legacyP = false;
    var legacyFloor = 0.0;
    final exportacaoLegacy = input.legacyExportacaoGrao;
    if (exportacaoLegacy != null && exportacaoLegacy > 0) {
      final legacyInfo = FosforoFormula.avaliarLegacyP(
        pSolo: soilP,
        nivelCritico: nc,
        exportacaoGrao: exportacaoLegacy,
        fatorManutencao: input.legacyManutencaoFactor,
      );
      legacyP = legacyInfo.legacyP;
      legacyFloor = legacyInfo.doseMinima;
      if (legacyP && finalP2O5 < legacyFloor) {
        finalP2O5 = legacyFloor;
      }
    }

    return FosforoCalculoResult(
      soilP: soilP,
      criticalLevel: nc,
      deficitP: deficitP,
      correcaoSoloAtiva: input.correcaoSoloAtiva,
      correctionP2O5: correctionP2O5,
      replacementMode: input.replacementMode,
      productionExpected: input.productionExpected,
      extractionRate: input.extractionRate,
      exportRate: input.exportRate,
      totalDemandP2O5: totalDemand,
      percentualSolo: percentualSolo,
      soilContributionP2O5: soilContribution,
      replacementBaseP2O5: replacementBase,
      efficiencyAdjustmentPercent: ajuste,
      efficiencyIncrementP2O5: efficiencyIncrement,
      replacementAdjustedP2O5: replacementAdjusted,
      finalP2O5: finalP2O5,
      legacyP: legacyP,
      legacyFloorP2O5: legacyFloor,
      fatorCorrecao: input.fatorCorrecao,
    );
  }

  static double _demandaPorProducao({
    required double productionExpected,
    required double? indiceP2O5PorT,
    required double? fallbackDemand,
  }) {
    if (productionExpected > 0 &&
        indiceP2O5PorT != null &&
        indiceP2O5PorT > 0) {
      return productionExpected * indiceP2O5PorT;
    }
    return (fallbackDemand ?? 0).clamp(0.0, double.infinity);
  }

  /// Conversão para dose de produto comercial (quando aplicável em outro módulo).
  static double doseProdutoComercial({
    required double p2o5Final,
    required double teorP2O5Percent,
  }) {
    if (p2o5Final <= 0 || teorP2O5Percent <= 0) return 0.0;
    return p2o5Final / (teorP2O5Percent / 100.0);
  }
}
