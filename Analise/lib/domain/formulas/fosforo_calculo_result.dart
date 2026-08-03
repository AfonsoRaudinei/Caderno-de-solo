import 'package:soloforte/domain/formulas/fosforo_calibracao_config.dart';

/// Resultado auditável do cálculo completo de Fósforo (kg P₂O₅/ha).
///
/// Todas as parcelas intermediárias são expostas para rastreabilidade.
/// Unidades:
/// - [soilP], [criticalLevel], [deficitP] → mg/dm³ de P
/// - Demais campos de dose → kg P₂O₅/ha
class FosforoCalculoResult {
  const FosforoCalculoResult({
    required this.soilP,
    required this.criticalLevel,
    required this.deficitP,
    required this.correcaoSoloAtiva,
    required this.correctionP2O5,
    required this.replacementMode,
    required this.productionExpected,
    required this.extractionRate,
    required this.exportRate,
    required this.totalDemandP2O5,
    required this.percentualSolo,
    required this.soilContributionP2O5,
    required this.replacementBaseP2O5,
    required this.efficiencyAdjustmentPercent,
    required this.efficiencyIncrementP2O5,
    required this.replacementAdjustedP2O5,
    required this.finalP2O5,
    required this.legacyP,
    required this.legacyFloorP2O5,
    required this.fatorCorrecao,
  });

  final double soilP;
  final double criticalLevel;
  final double deficitP;
  final bool correcaoSoloAtiva;
  final double correctionP2O5;
  final ModoReposicaoP replacementMode;
  final double productionExpected;
  final double? extractionRate;
  final double? exportRate;
  final double totalDemandP2O5;
  final double percentualSolo;
  final double soilContributionP2O5;
  final double replacementBaseP2O5;
  final double efficiencyAdjustmentPercent;
  final double efficiencyIncrementP2O5;
  final double replacementAdjustedP2O5;
  final double finalP2O5;
  final bool legacyP;
  final double legacyFloorP2O5;
  final double fatorCorrecao;

  /// Alias para integração existente (`ncFosforo`).
  double get ncP => criticalLevel;

  /// Alias para integração existente (`doseP2O5KgHa`).
  double get doseP => finalP2O5;
}
