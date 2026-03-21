class PotassioFormula {
  static const double _fatorCmolcParaK2O = 391.0 * 1.205 * 2.0; // 942.21

  static String classeTextural(double argilaPercent) {
    if (argilaPercent < 15) return 'arenoso';
    if (argilaPercent <= 35) return 'medio';
    if (argilaPercent <= 60) return 'argiloso';
    return 'muito_argiloso';
  }

  /// Retorna a participação atual do Potássio (K) na CTC (%)
  static double participacaoAtual({
    required double kAtual,
    required double ctc,
  }) {
    if (ctc == 0) return 0.0;
    return (kAtual / ctc) * 100.0;
  }

  static double kMgDm3ToCmolc(double kMgDm3) => kMgDm3 / 391.0;

  /// NC absoluto de K (mg/dm³) por textura.
  static double nivelCriticoTeorAbsoluto(double argilaPercent) {
    if (argilaPercent < 15) return 40.0;
    if (argilaPercent <= 35) return 60.0;
    if (argilaPercent <= 60) return 80.0;
    return 100.0;
  }

  /// FEK base por textura.
  static double fekBase(double argilaPercent) {
    final classe = classeTextural(argilaPercent);
    switch (classe) {
      case 'arenoso':
        return 50.0;
      case 'medio':
        return 60.0;
      case 'argiloso':
        return 65.0;
      default:
        return 70.0;
    }
  }

  /// FEK final com regra de algodão.
  static double fekFinal({
    required double argilaPercent,
    required String cultura,
  }) {
    final culturaNorm = cultura.trim().toLowerCase();
    if (culturaNorm == 'algodao' || culturaNorm == 'algodão') return 60.0;
    return fekBase(argilaPercent);
  }

  /// Correção por teor absoluto (opcional).
  static double recomendacaoPorTeorAbsoluto({
    required double kAtualMgDm3,
    required double argilaPercent,
    double percentualCorrecao = 100.0,
  }) {
    final nc = nivelCriticoTeorAbsoluto(argilaPercent);
    final deficitMgDm3 = (nc - kAtualMgDm3).clamp(0.0, double.infinity);
    if (deficitMgDm3 <= 0) return 0.0;
    final deficitCmolc = deficitMgDm3 / 391.0;
    return deficitCmolc * _fatorCmolcParaK2O * (percentualCorrecao / 100.0);
  }

  /// Calcula a recomendação de Potássio em kg/ha de K2O
  /// Para atingir a participação desejada na CTC
  static double recomendacao({
    required double ctc,
    required double kAtual,
    required double participacaoDesejada, // Ex: 3.0 para 3% a 5%
    String cultura = '',
    bool usarCriterioTeorAbsoluto = false,
    double? kAtualMgDm3,
    double? argilaPercent,
    double percentualCorrecaoTeor = 100.0,
  }) {
    final participacaoCorrente = participacaoAtual(kAtual: kAtual, ctc: ctc);
    final culturaNorm = cultura.trim().toLowerCase();
    final alvoPct = (culturaNorm == 'algodao' || culturaNorm == 'algodão')
        ? (participacaoDesejada < 5.0 ? 5.0 : participacaoDesejada)
        : participacaoDesejada;

    double doseSaturacao = 0.0;
    if (participacaoCorrente < alvoPct) {
      final kDesejado = (alvoPct / 100.0) * ctc;
      final deficitK = kDesejado - kAtual;
      doseSaturacao = deficitK * _fatorCmolcParaK2O;
    }

    if (!usarCriterioTeorAbsoluto ||
        kAtualMgDm3 == null ||
        argilaPercent == null) {
      return doseSaturacao;
    }

    final doseTeor = recomendacaoPorTeorAbsoluto(
      kAtualMgDm3: kAtualMgDm3,
      argilaPercent: argilaPercent,
      percentualCorrecao: percentualCorrecaoTeor,
    );
    return doseSaturacao > doseTeor ? doseSaturacao : doseTeor;
  }

  /// Modo 2 — extração.
  static double recomendacaoExtracao({
    required double kSolo,
    required double percentualUsoSolo,
    required double extracaoK2O,
    required double fek,
  }) {
    final kSoloUsado = kSolo * (percentualUsoSolo / 100.0);
    final kSoloKg = kSoloUsado * 2.0 * 1.205;
    final doseBase = (extracaoK2O - kSoloKg).clamp(0.0, double.infinity);
    if (fek <= 0) return 0.0;
    return doseBase / (fek / 100.0);
  }

  /// Aviso para dose alta de K2O no sulco.
  static bool avisoSulco({
    required String modoAplicacao,
    required double doseK2O,
  }) {
    return modoAplicacao.trim().toLowerCase() == 'sulco' && doseK2O > 40.0;
  }

  /// Saídas de antagonismo para recomendação.
  static ({
    double pctKCTC,
    double relKMg,
    double relKCa,
    bool avisoKCTC,
    bool avisoKMg,
    bool avisoKCa,
  }) calcularAntagonismos({
    required double kTotal,
    required double ctc,
    required double mgAtual,
    required double caAtual,
  }) {
    final pctKCTC = ctc > 0 ? (kTotal / ctc) * 100.0 : 0.0;
    final relKMg = mgAtual > 0 ? kTotal / mgAtual : 0.0;
    final relKCa = caAtual > 0 ? kTotal / caAtual : 0.0;
    return (
      pctKCTC: pctKCTC,
      relKMg: relKMg,
      relKCa: relKCa,
      avisoKCTC: pctKCTC > 7.0,
      avisoKMg: relKMg > 1.0,
      avisoKCa: relKCa > 0.4,
    );
  }
}
