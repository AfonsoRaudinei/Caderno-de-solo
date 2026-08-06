import 'package:soloforte/domain/models/analise_model.dart';
import 'package:soloforte/domain/formulas/types/fosforo_input.dart';

class LegacyPResultado {
  const LegacyPResultado({
    required this.legacyP,
    required this.doseMinima,
  });

  final bool legacyP;
  final double doseMinima;
}

enum ReposicaoFosforo {
  nenhuma,
  exportacao,
  extracao,
}

class FosforoComponentesResultado {
  const FosforoComponentesResultado({
    required this.doseTotal,
    required this.doseCorrecao,
    required this.doseExportacao,
    required this.doseExtracao,
    required this.pSoloCreditadoP2O5,
    required this.modoResumo,
    required this.reposicaoBaseP2O5KgHa,
    required this.incrementoEficienciaP2O5KgHa,
    required this.reposicaoAjustadaP2O5KgHa,
    required this.eficienciaSoloPercent,
  });

  final double doseTotal;
  final double doseCorrecao;
  final double doseExportacao;
  final double doseExtracao;
  final double pSoloCreditadoP2O5;
  final String modoResumo;
  final double reposicaoBaseP2O5KgHa;
  final double incrementoEficienciaP2O5KgHa;
  final double reposicaoAjustadaP2O5KgHa;
  final double eficienciaSoloPercent;
}

class FosforoFormula {
  static String classeTextural(double argilaPercent) {
    if (argilaPercent < 15) return 'arenoso';
    if (argilaPercent <= 35) return 'medio';
    if (argilaPercent <= 60) return 'argiloso';
    return 'muito_argiloso';
  }

  /// NC para Resina (IAC): 12/20/30/40 mg/dm³.
  static double nivelCriticoResina(double argilaPercent,
      {double? overrideValue}) {
    if (overrideValue != null) return overrideValue;
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
  static double nivelCriticoMehlich1(double argilaPercent,
      {double? overrideValue}) {
    if (overrideValue != null) return overrideValue;
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
    double? overrideValue,
  }) {
    if (extrator == FonteP.resina) {
      return nivelCriticoResina(argilaPercent, overrideValue: overrideValue);
    }
    return nivelCriticoMehlich1(argilaPercent, overrideValue: overrideValue);
  }

  /// fator_solo: arenoso=2, médio=3, argiloso=4, muito argiloso=5.
  static double fatorSolo(double argilaPercent, {double? overrideValue}) {
    if (overrideValue != null) return overrideValue;
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

  /// FEP base para correção do solo: arenoso=30, médio=20, argiloso=15, muito argiloso=10.
  static double fepBase(double argilaPercent, {double? overrideValue}) {
    if (overrideValue != null) return overrideValue;
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

  /// Reposição base (kg P₂O₅/ha) = produtividade (t/ha) × taxa (kg P₂O₅/t).
  static double reposicaoBaseKgHa({
    required double produtividadeTha,
    required double taxaP2O5PorT,
  }) {
    if (produtividadeTha <= 0 || taxaP2O5PorT < 0) return 0.0;
    return produtividadeTha * taxaP2O5PorT;
  }

  /// Incremento por eficiência no solo sobre a reposição base.
  static double incrementoEficienciaSolo({
    required double reposicaoBase,
    required double eficienciaSoloPercent,
  }) {
    if (reposicaoBase <= 0) return 0.0;
    final pct = eficienciaSoloPercent.clamp(0.0, 100.0);
    if (pct <= 0) return 0.0;
    return reposicaoBase * (pct / 100.0);
  }

  /// Reposição ajustada = base + incremento por eficiência.
  static double reposicaoAjustada({
    required double reposicaoBase,
    required double eficienciaSoloPercent,
  }) {
    final incremento = incrementoEficienciaSolo(
      reposicaoBase: reposicaoBase,
      eficienciaSoloPercent: eficienciaSoloPercent,
    );
    return reposicaoBase + incremento;
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
  /// dose_base = deficit × fator_solo
  /// dose_final = dose_base / (FEP/100)
  static FosforoResult recomendacaoCorrecao(
    FosforoInput input, {
    double? fepCorrecao,
  }) {
    final deficit = (input.nc - input.pAtual).clamp(0.0, double.infinity);
    if (deficit <= 0) {
      return FosforoResult(doseRecomendada: 0.0, formula: input.referencia);
    }

    final fator = fatorSolo(input.argila);
    final doseBase = deficit * fator;
    final fepUsado = fepCorrecao ?? fepBase(input.argila);
    if (fepUsado <= 0) {
      return FosforoResult(doseRecomendada: 0.0, formula: input.referencia);
    }
    return FosforoResult(
      doseRecomendada: doseBase / (fepUsado / 100.0),
      formula: input.referencia,
    );
  }

  static double pSoloDisponivelP2O5({
    required double pSolo,
    required double percentualUsoSolo,
    required double profundidadeCm,
  }) {
    final usoSolo = percentualUsoSolo.clamp(0.0, 100.0);
    final pSoloUsado = pSolo * (usoSolo / 100.0);
    return pSoloUsado * 2.0 * (profundidadeCm / 20.0) * 2.291;
  }

  /// Exportação: reposição base (kg P₂O₅/ha) + incremento por eficiência.
  static ({
    double reposicaoBase,
    double incremento,
    double reposicaoAjustada,
  }) componentesExportacao({
    required double exportacaoP2O5KgHa,
    required double eficienciaSoloPercent,
  }) {
    final base = exportacaoP2O5KgHa.clamp(0.0, double.infinity);
    final incremento = incrementoEficienciaSolo(
      reposicaoBase: base,
      eficienciaSoloPercent: eficienciaSoloPercent,
    );
    return (
      reposicaoBase: base,
      incremento: incremento,
      reposicaoAjustada: base + incremento,
    );
  }

  /// Extração: abate P do solo, depois aplica eficiência sobre a base líquida.
  static ({
    double reposicaoBase,
    double incremento,
    double reposicaoAjustada,
    double pSoloCreditadoP2O5,
  }) componentesExtracao({
    required double extracaoP2O5KgHa,
    required double pSolo,
    required double percentualUsoSolo,
    required double profundidadeCm,
    required double eficienciaSoloPercent,
  }) {
    final pSoloCreditado = pSoloDisponivelP2O5(
      pSolo: pSolo,
      percentualUsoSolo: percentualUsoSolo,
      profundidadeCm: profundidadeCm,
    );
    final base =
        (extracaoP2O5KgHa - pSoloCreditado).clamp(0.0, double.infinity);
    final incremento = incrementoEficienciaSolo(
      reposicaoBase: base,
      eficienciaSoloPercent: eficienciaSoloPercent,
    );
    return (
      reposicaoBase: base,
      incremento: incremento,
      reposicaoAjustada: base + incremento,
      pSoloCreditadoP2O5: pSoloCreditado,
    );
  }

  static FosforoComponentesResultado recomendacaoComponentes({
    required bool corrigirSolo,
    required ReposicaoFosforo reposicao,
    required FosforoInput correcaoInput,
    required double pSolo,
    required double percentualUsoSoloExtracao,
    required double profundidadeCm,
    required double exportacaoP2O5,
    required double extracaoP2O5,
    required double eficienciaSoloPercent,
    double? fepCorrecao,
  }) {
    final eficiencia = eficienciaSoloPercent.clamp(0.0, 100.0);
    final doseCorrecao = corrigirSolo
        ? recomendacaoCorrecao(
            correcaoInput,
            fepCorrecao: fepCorrecao,
          ).doseRecomendada
        : 0.0;

    var reposicaoBase = 0.0;
    var incremento = 0.0;
    var reposicaoAjustada = 0.0;
    var doseExportacao = 0.0;
    var doseExtracao = 0.0;
    var pSoloCreditado = 0.0;

    switch (reposicao) {
      case ReposicaoFosforo.exportacao:
        final comp = componentesExportacao(
          exportacaoP2O5KgHa: exportacaoP2O5,
          eficienciaSoloPercent: eficiencia,
        );
        reposicaoBase = comp.reposicaoBase;
        incremento = comp.incremento;
        reposicaoAjustada = comp.reposicaoAjustada;
        doseExportacao = comp.reposicaoAjustada;
      case ReposicaoFosforo.extracao:
        final comp = componentesExtracao(
          extracaoP2O5KgHa: extracaoP2O5,
          pSolo: pSolo,
          percentualUsoSolo: percentualUsoSoloExtracao,
          profundidadeCm: profundidadeCm,
          eficienciaSoloPercent: eficiencia,
        );
        reposicaoBase = comp.reposicaoBase;
        incremento = comp.incremento;
        reposicaoAjustada = comp.reposicaoAjustada;
        pSoloCreditado = comp.pSoloCreditadoP2O5;
        doseExtracao = comp.reposicaoAjustada;
      case ReposicaoFosforo.nenhuma:
        break;
    }

    return FosforoComponentesResultado(
      doseTotal: doseCorrecao + doseExportacao + doseExtracao,
      doseCorrecao: doseCorrecao,
      doseExportacao: doseExportacao,
      doseExtracao: doseExtracao,
      pSoloCreditadoP2O5: pSoloCreditado,
      modoResumo: _modoResumo(corrigirSolo, reposicao),
      reposicaoBaseP2O5KgHa: reposicaoBase,
      incrementoEficienciaP2O5KgHa: incremento,
      reposicaoAjustadaP2O5KgHa: reposicaoAjustada,
      eficienciaSoloPercent: eficiencia,
    );
  }

  static String _modoResumo(
    bool corrigirSolo,
    ReposicaoFosforo reposicao,
  ) {
    final partes = <String>[
      if (corrigirSolo) 'Correção do solo',
      if (reposicao == ReposicaoFosforo.exportacao) 'Exportação',
      if (reposicao == ReposicaoFosforo.extracao) 'Extração',
    ];
    return partes.isEmpty ? 'Sem fósforo' : partes.join(' + ');
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
  static FosforoResult recomendacao(
    FosforoData fosforo,
    double pCritico, {
    double argilaPercent = 25.0,
    double percentualCorrecao = 100.0,
    double? fep,
  }) {
    final pAtual = fosforo.valorParaCalculo;
    return recomendacaoCorrecao(
      FosforoInput(
        argila: argilaPercent,
        pAtual: pAtual,
        nc: pCritico,
        referencia: 'Metodo Correcao',
      ),
      fepCorrecao: fep,
    );
  }
}
