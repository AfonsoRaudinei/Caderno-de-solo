import 'package:soloforte/domain/formulas/conversoes.dart';
import 'package:soloforte/domain/formulas/types/calcario_input.dart';

enum ClasseRelacaoCaMg {
  estreita,
  adequada,
  larga,
  muitoLarga,
}

class CalcarioFormula {
  /// Metas padrão de saturação Albrecht por cultura (editáveis via override).
  ///
  /// Padrões:
  /// - Soja: Ca 65%, Mg 15%, K 4%
  /// - Milho: Ca 65%, Mg 15%, K 4%
  /// - Feijão: Ca 65%, Mg 15%, K 5%
  /// - Algodão: Ca 65%, Mg 12%, K 5%
  static ({double pctCa, double pctMg, double pctK}) metasAlbrechtPorCultura({
    required String cultura,
    double? pctCa,
    double? pctMg,
    double? pctK,
  }) {
    final culturaNorm = _normalizarCultura(cultura);
    var base = (pctCa: 65.0, pctMg: 15.0, pctK: 4.0); // fallback

    if (culturaNorm == 'soja') {
      base = (pctCa: 65.0, pctMg: 15.0, pctK: 4.0);
    } else if (culturaNorm == 'milho') {
      base = (pctCa: 65.0, pctMg: 15.0, pctK: 4.0);
    } else if (culturaNorm == 'feijao') {
      base = (pctCa: 65.0, pctMg: 15.0, pctK: 5.0);
    } else if (culturaNorm == 'algodao') {
      base = (pctCa: 65.0, pctMg: 12.0, pctK: 5.0);
    }

    return (
      pctCa: pctCa ?? base.pctCa,
      pctMg: pctMg ?? base.pctMg,
      pctK: pctK ?? base.pctK,
    );
  }

  /// Fator de profundidade com interpolação linear.
  /// Âncoras: 0cm→0, 20cm→1.0, 40cm→2.03, 60cm→3.0.
  static double fatorProfundidade(double profundidadeCm) {
    if (profundidadeCm <= 0) return 0.0;
    if (profundidadeCm <= 20) return profundidadeCm / 20.0;
    if (profundidadeCm <= 40) {
      return 1.0 + ((profundidadeCm - 20.0) / 20.0) * 1.03;
    }
    final p = 2.03 + ((profundidadeCm - 40.0) / 20.0) * 0.97;
    return p.clamp(0.0, 3.0);
  }

  /// Profundidade de incorporação estimada por geometria da grade.
  ///
  /// raioCm = diametroPol × 2.54 / 2
  /// profundidade = raioCm - (folgaMancalCm / 2)
  static double profundidadePorGrade({
    required double diametroPol,
    required double folgaMancalCm,
  }) {
    final raioCm = diametroPol * 2.54 / 2.0;
    final profundidade = raioCm - (folgaMancalCm / 2.0);
    return profundidade.clamp(0.0, double.infinity);
  }

  /// PRNT (%) = (PN × RE) / 100
  static double calcularPRNT({
    required double pn,
    required double re,
  }) {
    return (pn * re) / 100.0;
  }

  /// PRNT ponderado de mistura de 2 calcários.
  static double calcularPRNTPonderado({
    required double prnt1,
    required double prnt2,
    required double proporcao1,
    required double proporcao2,
  }) {
    return (proporcao1 / 100.0 * prnt1) + (proporcao2 / 100.0 * prnt2);
  }

  /// Fator de Ca disponível a partir de CaO (%).
  static double fatorCa({required double caO}) =>
      (caO / 100.0) * Conversoes.fatorCaO_Ca;

  /// Fator de Mg disponível a partir de MgO (%).
  static double fatorMg({required double mgO}) =>
      (mgO / 100.0) * Conversoes.fatorMgO_Mg;

  /// Fatores ponderados de Ca e Mg para mistura de 2 calcários.
  static ({double fatorCaFinal, double fatorMgFinal})
      fatoresPonderadosCalcarios({
    required double fatorCa1,
    required double fatorCa2,
    required double fatorMg1,
    required double fatorMg2,
    required double proporcao1,
    required double proporcao2,
  }) {
    final fatorCaFinal =
        (proporcao1 / 100.0 * fatorCa1) + (proporcao2 / 100.0 * fatorCa2);
    final fatorMgFinal =
        (proporcao1 / 100.0 * fatorMg1) + (proporcao2 / 100.0 * fatorMg2);
    return (fatorCaFinal: fatorCaFinal, fatorMgFinal: fatorMgFinal);
  }

  /// Y = 0.0302 + 0.06532×Arg − 0.000257×Arg²
  static double calcularY(double argilaPercent) {
    final y = 0.0302 +
        (0.06532 * argilaPercent) -
        (0.000257 * argilaPercent * argilaPercent);
    return y.clamp(0.0, 4.0);
  }

  /// Y por P-rem com interpolação linear entre os intervalos da referência.
  static double calcularYPorPrem(double prem) {
    if (prem <= 0) return 4.0;
    if (prem <= 4) return _lerp(prem, 0, 4, 4.0, 3.5);
    if (prem <= 10) return _lerp(prem, 4, 10, 3.5, 2.9);
    if (prem <= 19) return _lerp(prem, 10, 19, 2.9, 2.0);
    if (prem <= 30) return _lerp(prem, 19, 30, 2.0, 1.2);
    if (prem <= 44) return _lerp(prem, 30, 44, 1.2, 0.5);
    if (prem <= 60) return _lerp(prem, 44, 60, 0.5, 0.0);
    return 0.0;
  }

  /// Critério completo de uso de Y:
  /// - apenas P-rem -> Y por P-rem (prioritário quando só ele existe)
  /// - apenas argila -> equação contínua
  /// - ambos -> média ponderada 60/40 (argila/prem)
  static double calcularYCriterio({
    double? argilaPercent,
    double? prem,
  }) {
    if (argilaPercent == null && prem == null) return 0.0;
    if (argilaPercent == null) return calcularYPorPrem(prem!);
    if (prem == null) return calcularY(argilaPercent);
    return (calcularY(argilaPercent) * 0.6) + (calcularYPorPrem(prem) * 0.4);
  }

  /// Parâmetros derivados da análise.
  static double calcularSB({
    required double ca,
    required double mg,
    required double k,
  }) =>
      ca + mg + k;

  static double calcularCTC({
    required double ca,
    required double mg,
    required double k,
    required double hAl,
  }) =>
      calcularSB(ca: ca, mg: mg, k: k) + hAl;

  static double calcularCTCEfetiva({
    required double ca,
    required double mg,
    required double k,
    required double al,
  }) =>
      calcularSB(ca: ca, mg: mg, k: k) + al;

  static double calcularVPercent({
    required double ca,
    required double mg,
    required double k,
    required double hAl,
  }) {
    final ctc = calcularCTC(ca: ca, mg: mg, k: k, hAl: hAl);
    if (ctc <= 0) return 0.0;
    return (calcularSB(ca: ca, mg: mg, k: k) / ctc) * 100.0;
  }

  static double calcularMPercent({
    required double ca,
    required double mg,
    required double k,
    required double al,
  }) {
    final t = calcularCTCEfetiva(ca: ca, mg: mg, k: k, al: al);
    if (t <= 0) return 0.0;
    return (al / t) * 100.0;
  }

  /// Sequência padrão:
  /// NC_prof = NC_base × p
  /// NC_prnt = NC_prof / (PRNT / 100)
  /// Dose_final = NC_prnt / SC
  static ({double p, double ncProf, double ncPrnt, double doseFinal})
      aplicarCorrecoes({
    required double ncBase,
    required double profundidadeCm,
    required double prnt,
    required double sc,
  }) {
    final p = fatorProfundidade(profundidadeCm);
    final ncProf = ncBase * p;
    final ncPrnt = prnt > 0 ? ncProf / (prnt / 100.0) : 0.0;
    final doseFinal = sc > 0 ? ncPrnt / sc : 0.0;
    return (p: p, ncProf: ncProf, ncPrnt: ncPrnt, doseFinal: doseFinal);
  }

  /// Saturações finais pós-calagem.
  static ({
    double caAdicionado,
    double mgAdicionado,
    double caTotal,
    double mgTotal,
    double ctcNova,
    double pctCa,
    double pctMg,
    double vPctFinal,
    double relCaMg,
    ClasseRelacaoCaMg classeRelCaMg,
  }) calcularSaturacoesFinais({
    required double caAtual,
    required double mgAtual,
    required double kAtual,
    required double ctcAtual,
    required double doseFinal,
    required double caO,
    required double mgO,
  }) {
    final fCa = fatorCa(caO: caO);
    final fMg = fatorMg(mgO: mgO);

    final caAdicionado = doseFinal * fCa;
    final mgAdicionado = doseFinal * fMg;
    final caTotal = caAtual + caAdicionado;
    final mgTotal = mgAtual + mgAdicionado;
    final ctcNova = ctcAtual + caAdicionado + mgAdicionado;

    double pctCa = 0.0;
    double pctMg = 0.0;
    double vPctFinal = 0.0;
    if (ctcNova > 0) {
      pctCa = (caTotal / ctcNova) * 100.0;
      pctMg = (mgTotal / ctcNova) * 100.0;
      vPctFinal = ((caTotal + mgTotal + kAtual) / ctcNova) * 100.0;
    }
    final relCaMg = mgTotal > 0 ? (caTotal / mgTotal) : 0.0;

    return (
      caAdicionado: caAdicionado,
      mgAdicionado: mgAdicionado,
      caTotal: caTotal,
      mgTotal: mgTotal,
      ctcNova: ctcNova,
      pctCa: pctCa,
      pctMg: pctMg,
      vPctFinal: vPctFinal,
      relCaMg: relCaMg,
      classeRelCaMg: classificarRelacaoCaMg(relCaMg),
    );
  }

  static ClasseRelacaoCaMg classificarRelacaoCaMg(double relCaMg) {
    if (relCaMg < 1.5) return ClasseRelacaoCaMg.estreita;
    if (relCaMg <= 3.0) return ClasseRelacaoCaMg.adequada;
    if (relCaMg <= 5.0) return ClasseRelacaoCaMg.larga;
    return ClasseRelacaoCaMg.muitoLarga;
  }

  /// Método SMP
  /// Calcula a Necessidade de Calagem (NC) baseada no índice SMP
  /// NC = (pH ideal - pH atual) * Fator
  static double metodoSMP({
    required double phSmp,
    required double prnt,
    double profundidadeCm = 20.0,
    double sc = 1.0,
    double? overrideNcBase,
  }) {
    double ncBase = 0;
    if (overrideNcBase != null) {
      ncBase = overrideNcBase;
    } else {
      if (phSmp <= 4.5) {
        ncBase = 15.0;
      } else if (phSmp <= 5.0) {
        ncBase = 10.0;
      } else if (phSmp <= 5.5) {
        ncBase = 5.0;
      } else if (phSmp <= 6.0) {
        ncBase = 2.5;
      } else {
        ncBase = 0.0;
      }
    }
    return aplicarCorrecoes(
      ncBase: ncBase,
      profundidadeCm: profundidadeCm,
      prnt: prnt,
      sc: sc,
    ).doseFinal;
  }


  /// Método saturação por bases (V%)
  /// NC = (CTC * (V2 - V1)) / PRNT
  static CalcarioResult metodoV(CalcarioInput input) {
    if (input.prnt <= 0) {
      throw ArgumentError('PRNT deve ser maior que zero para compor a fração calcário.');
    }
    if (input.va >= input.vd) return const CalcarioResult(ncToneladas: 0.0, formula: 'V%');
    final ncBase = ((input.vd - input.va) * input.ctcPh7) / 100.0;
    final doseFinal = aplicarCorrecoes(
      ncBase: ncBase,
      profundidadeCm: input.profundidade,
      prnt: input.prnt,
      sc: 1.0,
    ).doseFinal;
    return CalcarioResult(ncToneladas: doseFinal, formula: 'V%');
  }

  /// Método IAC (cálcio e magnésio)
  static double metodoIAC({
    required double caDesejado,
    required double caAtual,
    required double prnt,
    double profundidadeCm = 20.0,
    double sc = 1.0,
  }) {
    if (caAtual >= caDesejado) return 0.0;
    // simplificação do método IAC para elevar calcário
    final ncBase = (caDesejado - caAtual);
    return aplicarCorrecoes(
      ncBase: ncBase,
      profundidadeCm: profundidadeCm,
      prnt: prnt,
      sc: sc,
    ).doseFinal;
  }

  /// Método ③ — Ca + Mg.
  static double metodoCaMg({
    required double caAtual,
    required double mgAtual,
    required double prnt,
    double profundidadeCm = 20.0,
    double sc = 1.0,
  }) {
    final ncBase = caAtual + mgAtual;
    return aplicarCorrecoes(
      ncBase: ncBase,
      profundidadeCm: profundidadeCm,
      prnt: prnt,
      sc: sc,
    ).doseFinal;
  }

  /// Alias legado para compatibilidade.
  static double metodo3CaMg({
    required double caAtual,
    required double mgAtual,
    required double prnt,
    double profundidadeCm = 20.0,
    double sc = 1.0,
  }) {
    return metodoCaMg(
      caAtual: caAtual,
      mgAtual: mgAtual,
      prnt: prnt,
      profundidadeCm: profundidadeCm,
      sc: sc,
    );
  }

  /// Método EMBRAPA: NC = H+Al × fator.
  static double metodoEmbrapa({
    required double hAl,
    double fator = 0.5,
    required double prnt,
    double profundidadeCm = 20.0,
    double sc = 1.0,
  }) {
    final ncBase = hAl * fator;
    return aplicarCorrecoes(
      ncBase: ncBase,
      profundidadeCm: profundidadeCm,
      prnt: prnt,
      sc: sc,
    ).doseFinal;
  }

  /// Método Supercalagem: NC_base = dose fixa.
  static double metodoSupercalagem({
    required double doseFixa,
    required double prnt,
    double profundidadeCm = 20.0,
    double sc = 1.0,
  }) {
    return aplicarCorrecoes(
      ncBase: doseFixa,
      profundidadeCm: profundidadeCm,
      prnt: prnt,
      sc: sc,
    ).doseFinal;
  }

  /// Método Albrecht (componente Ca).
  static double metodoAlbrecht({
    required double ctc,
    required double caAtual,
    required double mgAtual,
    required double kAtual,
    required double pctCaAlvo,
    required double pctMgAlvo,
    required double pctKAlvo,
    required double caO,
    required double prnt,
    double pisoCaCmolc = 2.0,
    double pisoMgCmolc = 0.8,
    double pisoKCmolc = 0.15,
    double profundidadeCm = 20.0,
    double sc = 1.0,
    double? overrideNcBase,
  }) {
    double ncBase = 0.0;
    if (overrideNcBase != null) {
      ncBase = overrideNcBase;
    } else {
      final caNecessario = ((pctCaAlvo / 100.0) * ctc) > pisoCaCmolc
          ? ((pctCaAlvo / 100.0) * ctc)
          : pisoCaCmolc;
      final mgNecessario = ((pctMgAlvo / 100.0) * ctc) > pisoMgCmolc
          ? ((pctMgAlvo / 100.0) * ctc)
          : pisoMgCmolc;
      final kNecessario = ((pctKAlvo / 100.0) * ctc) > pisoKCmolc
          ? ((pctKAlvo / 100.0) * ctc)
          : pisoKCmolc;

      final deficitCa = (caNecessario - caAtual).clamp(0.0, double.infinity);
      final deficitMg = (mgNecessario - mgAtual).clamp(0.0, double.infinity);
      final deficitK = (kNecessario - kAtual).clamp(0.0, double.infinity);
      // Mantidos para documentação técnica do método:
      // ignore: unused_local_variable
      final _ = deficitMg + deficitK;

      if (deficitCa > 0 && caO > 0) {
        final caKgHa = deficitCa * 200.0;
        ncBase = (caKgHa / ((caO / 100.0) * Conversoes.fatorCaO_Ca)) / 1000.0;
      }
    }

    return aplicarCorrecoes(
      ncBase: ncBase,
      profundidadeCm: profundidadeCm,
      prnt: prnt,
      sc: sc,
    ).doseFinal;
  }

  /// Método Albrecht usando metas padrão por cultura, com overrides editáveis.
  static double metodoAlbrechtPorCultura({
    required String cultura,
    required double ctc,
    required double caAtual,
    required double mgAtual,
    required double kAtual,
    required double caO,
    required double prnt,
    double profundidadeCm = 20.0,
    double sc = 1.0,
    double? pctCaAlvo,
    double? pctMgAlvo,
    double? pctKAlvo,
    double pisoCaCmolc = 2.0,
    double pisoMgCmolc = 0.8,
    double pisoKCmolc = 0.15,
  }) {
    final metas = metasAlbrechtPorCultura(
      cultura: cultura,
      pctCa: pctCaAlvo,
      pctMg: pctMgAlvo,
      pctK: pctKAlvo,
    );
    return metodoAlbrecht(
      ctc: ctc,
      caAtual: caAtual,
      mgAtual: mgAtual,
      kAtual: kAtual,
      pctCaAlvo: metas.pctCa,
      pctMgAlvo: metas.pctMg,
      pctKAlvo: metas.pctK,
      caO: caO,
      prnt: prnt,
      pisoCaCmolc: pisoCaCmolc,
      pisoMgCmolc: pisoMgCmolc,
      pisoKCmolc: pisoKCmolc,
      profundidadeCm: profundidadeCm,
      sc: sc,
    );
  }

  /// Método Albrecht + Y: max(NC_Albrecht, Y).
  static double metodoAlbrechtY({
    required double ctc,
    required double caAtual,
    required double mgAtual,
    required double kAtual,
    required double pctCaAlvo,
    required double pctMgAlvo,
    required double pctKAlvo,
    required double caO,
    required double argilaPercent,
    required double prnt,
    double pisoCaCmolc = 2.0,
    double pisoMgCmolc = 0.8,
    double pisoKCmolc = 0.15,
    double profundidadeCm = 20.0,
    double sc = 1.0,
  }) {
    final ncAlbrecht = metodoAlbrecht(
      ctc: ctc,
      caAtual: caAtual,
      mgAtual: mgAtual,
      kAtual: kAtual,
      pctCaAlvo: pctCaAlvo,
      pctMgAlvo: pctMgAlvo,
      pctKAlvo: pctKAlvo,
      caO: caO,
      prnt: 100.0, // cálculo de NC base antes das correções
      pisoCaCmolc: pisoCaCmolc,
      pisoMgCmolc: pisoMgCmolc,
      pisoKCmolc: pisoKCmolc,
      profundidadeCm: 20.0,
      sc: 1.0,
    );
    final y = calcularY(argilaPercent);
    final ncBase = ncAlbrecht > y ? ncAlbrecht : y;
    return aplicarCorrecoes(
      ncBase: ncBase,
      profundidadeCm: profundidadeCm,
      prnt: prnt,
      sc: sc,
    ).doseFinal;
  }

  /// Método correção específica de Mg.
  static double metodoCorrecaoMg({
    required double mgDesejado,
    required double mgAtual,
    required double fatorMgCalcario,
    required double prnt,
    double profundidadeCm = 20.0,
    double sc = 1.0,
  }) {
    if (fatorMgCalcario <= 0) return 0.0;
    final deficitMg = (mgDesejado - mgAtual).clamp(0.0, double.infinity);
    final ncBase = deficitMg / fatorMgCalcario;
    return aplicarCorrecoes(
      ncBase: ncBase,
      profundidadeCm: profundidadeCm,
      prnt: prnt,
      sc: sc,
    ).doseFinal;
  }

  static double _lerp(double x, double x0, double x1, double y0, double y1) {
    if (x1 == x0) return y0;
    final t = (x - x0) / (x1 - x0);
    return y0 + (y1 - y0) * t;
  }

  static String _normalizarCultura(String cultura) {
    return cultura
        .trim()
        .toLowerCase()
        .replaceAll('ã', 'a')
        .replaceAll('á', 'a')
        .replaceAll('â', 'a')
        .replaceAll('à', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }
}
