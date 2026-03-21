import 'package:soloforte/domain/models/analise_model.dart';

class LegacyPResultado {
  const LegacyPResultado({
    required this.legacyP,
    required this.doseMinima,
  });

  final bool legacyP;
  final double doseMinima;
}

class FosforoFormula {
  static String classeTextural(double argilaPercent) {
    if (argilaPercent < 15) return 'arenoso';
    if (argilaPercent <= 35) return 'medio';
    if (argilaPercent <= 60) return 'argiloso';
    return 'muito_argiloso';
  }

  /// NC para Resina (IAC): 12/20/30/40 mg/dm³.
  static double nivelCriticoResina(double argilaPercent) {
    final classe = classeTextural(argilaPercent);
    switch (classe) {
      case 'arenoso':
        return 12.0;
      case 'medio':
        return 20.0;
      case 'argiloso':
        return 30.0;
      default:
        return 40.0;
    }
  }

  /// NC para Mehlich-1: 8/12/18/25 mg/dm³.
  static double nivelCriticoMehlich1(double argilaPercent) {
    final classe = classeTextural(argilaPercent);
    switch (classe) {
      case 'arenoso':
        return 8.0;
      case 'medio':
        return 12.0;
      case 'argiloso':
        return 18.0;
      default:
        return 25.0;
    }
  }

  static double nivelCritico({
    required FonteP extrator,
    required double argilaPercent,
  }) {
    if (extrator == FonteP.resina) {
      return nivelCriticoResina(argilaPercent);
    }
    return nivelCriticoMehlich1(argilaPercent);
  }

  /// fator_solo: arenoso=2, médio=3, argiloso=4, muito argiloso=5.
  static double fatorSolo(double argilaPercent) {
    final classe = classeTextural(argilaPercent);
    switch (classe) {
      case 'arenoso':
        return 2.0;
      case 'medio':
        return 3.0;
      case 'argiloso':
        return 4.0;
      default:
        return 5.0;
    }
  }

  /// FEP base: arenoso=30, médio=20, argiloso=15, muito argiloso=10.
  static double fepBase(double argilaPercent) {
    final classe = classeTextural(argilaPercent);
    switch (classe) {
      case 'arenoso':
        return 30.0;
      case 'medio':
        return 20.0;
      case 'argiloso':
        return 15.0;
      default:
        return 10.0;
    }
  }

  /// Ajuste do FEP conforme modo de aplicação.
  static double ajustarFepPorModo({
    required double fepBase,
    required String modoAplicacao,
  }) {
    final modo = modoAplicacao.trim().toLowerCase();
    double fator = 1.0;
    if (modo == 'sulco') fator = 1.5;
    if (modo == 'lanco_incorp' || modo == 'lancio_incorp') fator = 1.0;
    if (modo == 'lanco_sem') fator = 0.7;
    if (modo == 'fertirrigacao') fator = 1.3;
    return fepBase * fator;
  }

  /// Modo 1 (correção):
  /// deficit = max(0, NC - Psolo)
  /// dose_base = deficit × fator_solo × (pct_correcao/100)
  /// dose_final = dose_base / (FEP/100)
  static double recomendacaoCorrecao({
    required double pSolo,
    required double nivelCritico,
    required double argilaPercent,
    double percentualCorrecao = 100.0,
    double? fep,
  }) {
    final deficit = (nivelCritico - pSolo).clamp(0.0, double.infinity);
    if (deficit <= 0) return 0.0;

    final fator = fatorSolo(argilaPercent);
    final doseBase = deficit * fator * (percentualCorrecao / 100.0);
    final fepUsado = (fep ?? fepBase(argilaPercent));
    if (fepUsado <= 0) return 0.0;
    return doseBase / (fepUsado / 100.0);
  }

  /// Modo 2 (extração).
  static double recomendacaoExtracao({
    required double pSolo,
    required double percentualUsoSolo,
    required double profundidadeCm,
    required double extracaoP2O5,
    required double fepFinal,
  }) {
    final pSoloUsado = pSolo * (percentualUsoSolo / 100.0);
    final pSoloKg =
        pSoloUsado * 2.0 * (profundidadeCm / 20.0) * 2.291; // P -> P2O5
    final doseBase = (extracaoP2O5 - pSoloKg).clamp(0.0, double.infinity);
    if (fepFinal <= 0) return 0.0;
    return doseBase / (fepFinal / 100.0);
  }

  /// Regra Legacy P:
  /// Se P_solo > NC, aplica piso de manutenção (exportacao × fator).
  static LegacyPResultado avaliarLegacyP({
    required double pSolo,
    required double nivelCritico,
    required double exportacaoGrao,
    double fatorManutencao = 0.30,
  }) {
    if (pSolo <= nivelCritico) {
      return const LegacyPResultado(legacyP: false, doseMinima: 0.0);
    }
    return LegacyPResultado(
      legacyP: true,
      doseMinima: exportacaoGrao * fatorManutencao,
    );
  }

  /// Mantida para integração existente da recomendação.
  /// Quando a textura não é informada, assume classe média (argila=25%).
  static double recomendacao(
    FosforoData fosforo,
    double pCritico, {
    double argilaPercent = 25.0,
    double percentualCorrecao = 100.0,
    double? fep,
  }) {
    final pAtual = fosforo.valorParaCalculo;
    return recomendacaoCorrecao(
      pSolo: pAtual,
      nivelCritico: pCritico,
      argilaPercent: argilaPercent,
      percentualCorrecao: percentualCorrecao,
      fep: fep,
    );
  }
}
