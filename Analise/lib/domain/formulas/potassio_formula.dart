import 'package:soloforte/domain/formulas/conversoes.dart';
import 'package:soloforte/domain/formulas/types/potassio_calculo.dart';

export 'types/potassio_calculo.dart';

enum ReposicaoPotassio {
  nenhuma,
  exportacao,
  extracao,
}

enum MetodoCorrecaoPotassio {
  nivelCritico,
  percentualKCtc,
}

class PotassioComponentesResultado {
  const PotassioComponentesResultado({
    required this.doseTotal,
    required this.doseCorrecao,
    required this.doseReposicao,
    required this.doseReposicaoAjustada,
    required this.modoResumo,
    required this.metodoCorrecao,
    required this.ncResumo,
    this.detalhe,
  });

  final double doseTotal;
  final double doseCorrecao;
  final double doseReposicao;
  final double doseReposicaoAjustada;
  final String modoResumo;
  final MetodoCorrecaoPotassio metodoCorrecao;
  final double ncResumo;
  final PotassioCalculoResultado? detalhe;

  factory PotassioComponentesResultado.fromCalculo(
    PotassioCalculoResultado resultado,
  ) {
    return PotassioComponentesResultado(
      doseTotal: resultado.k2oFinal,
      doseCorrecao: resultado.correcaoK2O,
      doseReposicao: resultado.reposicaoBaseK2O,
      doseReposicaoAjustada: resultado.reposicaoAjustadaK2O,
      modoResumo: resultado.modoResumo,
      metodoCorrecao: resultado.metodoCorrecao,
      ncResumo: resultado.ncResumo,
      detalhe: resultado,
    );
  }
}

class PotassioFormula {
  /// cmolc/dm³ → kg K₂O/ha na camada de referência (0–20 cm).
  static double cmolcDeficitParaK2OKgHa(
    double deficitCmolc, {
    int profundidadeCm = 20,
  }) {
    final deficitMgDm3 = Conversoes.kCmolcToMgDm3(deficitCmolc);
    return mgDm3DeficitParaK2OKgHa(
      deficitMgDm3,
      profundidadeCm: profundidadeCm,
    );
  }

  static double mgDm3DeficitParaK2OKgHa(
    double deficitMgDm3, {
    int profundidadeCm = 20,
  }) {
    final fatorProf = profundidadeCm / 20.0;
    return deficitMgDm3 *
        Conversoes.mgDm3ToKgHa *
        Conversoes.kToK2O *
        fatorProf;
  }

  static double kCmolcSoloParaK2OKgHa(
    double kCmolc, {
    int profundidadeCm = 20,
  }) {
    return cmolcDeficitParaK2OKgHa(kCmolc, profundidadeCm: profundidadeCm);
  }

  static String classeTextural(double argilaPercent) {
    if (argilaPercent < 15) return 'arenoso';
    if (argilaPercent <= 35) return 'medio';
    if (argilaPercent <= 60) return 'argiloso';
    return 'muito_argiloso';
  }

  static double participacaoAtual({
    required double kAtual,
    required double ctc,
  }) {
    if (ctc <= 0) return 0.0;
    return ((kAtual / ctc) * 100.0).clamp(0.0, 100.0);
  }

  static double kMgDm3ToCmolc(double kMgDm3) =>
      Conversoes.kMgDm3ToCmolc(kMgDm3);

  static double kCmolcToMgDm3(double kCmolc) =>
      Conversoes.kCmolcToMgDm3(kCmolc);

  static double fatorProfundidade(int profundidadeCm) {
    if (profundidadeCm <= 20) return Conversoes.profFator020;
    if (profundidadeCm <= 40) return Conversoes.profFator040;
    return Conversoes.profFator060;
  }

  static void validarEntrada(PotassioCalculoInput input) {
    if (input.kSoloOriginal < 0) {
      throw ArgumentError('K do solo não pode ser negativo.');
    }
    if (input.ctcCmolc < 0) {
      throw ArgumentError('CTC não pode ser negativa.');
    }
    if (input.nivelCriticoMgDm3 < 0) {
      throw ArgumentError('NC de K não pode ser negativo.');
    }
    if (input.percentualKObjetivoCtc < 0 ||
        input.percentualKObjetivoCtc > 100) {
      throw ArgumentError('% K objetivo deve estar entre 0 e 100.');
    }
    if (input.producaoEsperadaTha < 0) {
      throw ArgumentError('Produção esperada não pode ser negativa.');
    }
    if (input.indiceExportacaoK2OT < 0 || input.indiceExtracaoK2OT < 0) {
      throw ArgumentError(
          'Índices de exportação/extração não podem ser negativos.');
    }
    if (input.percentualKSoloConsiderado < 0 ||
        input.percentualKSoloConsiderado > 100) {
      throw ArgumentError('% K do solo considerado deve estar entre 0 e 100.');
    }
    if (input.ajusteEficienciaPercent < 0 ||
        input.ajusteEficienciaPercent > 100) {
      throw ArgumentError('Ajuste de eficiência deve estar entre 0 e 100.');
    }
    if (input.metodoCorrecao == MetodoCorrecaoPotassio.percentualKCtc &&
        input.corrigirSolo &&
        input.ctcCmolc <= 0) {
      throw ArgumentError('CTC deve ser maior que zero no método % K na CTC.');
    }
  }

  static ({
    double kCmolc,
    double kMgDm3,
  }) normalizarKSolo({
    required double kOriginal,
    required UnidadePotassioSolo unidade,
  }) {
    switch (unidade) {
      case UnidadePotassioSolo.mgDm3:
        return (
          kCmolc: kMgDm3ToCmolc(kOriginal),
          kMgDm3: kOriginal,
        );
      case UnidadePotassioSolo.cmolc:
        return (
          kCmolc: kOriginal,
          kMgDm3: kCmolcToMgDm3(kOriginal),
        );
    }
  }

  static double nivelCriticoTeorAbsoluto(
    double argilaPercent, {
    double? overrideValue,
  }) {
    if (overrideValue != null) return overrideValue;
    if (argilaPercent < 15) return 40.0;
    if (argilaPercent <= 35) return 60.0;
    if (argilaPercent <= 60) return 80.0;
    return 100.0;
  }

  static double fekBase(double argilaPercent, {double? overrideValue}) {
    if (overrideValue != null) return overrideValue;
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

  static double fekFinal({
    required double argilaPercent,
    required String cultura,
    double? overrideValue,
  }) {
    final culturaNorm = cultura.trim().toLowerCase();
    if (culturaNorm == 'algodao' || culturaNorm == 'algodão') return 60.0;
    return fekBase(argilaPercent, overrideValue: overrideValue);
  }

  static double correcaoPorNivelCritico({
    required double kAtualMgDm3,
    required double nivelCriticoMgDm3,
    int profundidadeCm = 20,
  }) {
    final deficitMgDm3 =
        (nivelCriticoMgDm3 - kAtualMgDm3).clamp(0.0, double.infinity);
    if (deficitMgDm3 <= 0) return 0.0;
    return mgDm3DeficitParaK2OKgHa(
      deficitMgDm3,
      profundidadeCm: profundidadeCm,
    );
  }

  static double correcaoPorPercentualCtc({
    required double ctcCmolc,
    required double kAtualCmolc,
    required double percentualKObjetivo,
    String cultura = '',
    int profundidadeCm = 20,
  }) {
    if (ctcCmolc <= 0) return 0.0;

    final culturaNorm = cultura.trim().toLowerCase();
    final alvoPct = (culturaNorm == 'algodao' || culturaNorm == 'algodão')
        ? (percentualKObjetivo < 5.0 ? 5.0 : percentualKObjetivo)
        : percentualKObjetivo;

    final kAlvoCmolc = ctcCmolc * (alvoPct / 100.0);
    final deficitCmolc = (kAlvoCmolc - kAtualCmolc).clamp(0.0, double.infinity);
    if (deficitCmolc <= 0) return 0.0;

    return cmolcDeficitParaK2OKgHa(
      deficitCmolc,
      profundidadeCm: profundidadeCm,
    );
  }

  static double recomendacaoPorTeorAbsoluto({
    required double kAtualMgDm3,
    required double argilaPercent,
    double percentualCorrecao = 100.0,
    double? ncOverride,
    int profundidadeCm = 20,
  }) {
    final nc =
        nivelCriticoTeorAbsoluto(argilaPercent, overrideValue: ncOverride);
    final dose = correcaoPorNivelCritico(
      kAtualMgDm3: kAtualMgDm3,
      nivelCriticoMgDm3: nc,
      profundidadeCm: profundidadeCm,
    );
    return dose * (percentualCorrecao.clamp(0.0, 100.0) / 100.0);
  }

  static double aplicarAjusteEficiencia(
    double necessidadeBase,
    double ajustePercent,
  ) {
    final ajuste = ajustePercent.clamp(0.0, 100.0);
    return necessidadeBase * (1 + ajuste / 100.0);
  }

  static double incrementoEficiencia(
    double reposicaoBase,
    double ajustePercent,
  ) {
    final ajuste = ajustePercent.clamp(0.0, 100.0);
    return reposicaoBase * (ajuste / 100.0);
  }

  static double recomendacaoPorCtc({
    required double ctc,
    required double kAtual,
    required double participacaoDesejada,
    String cultura = '',
    int profundidadeCm = 20,
  }) {
    return correcaoPorPercentualCtc(
      ctcCmolc: ctc,
      kAtualCmolc: kAtual,
      percentualKObjetivo: participacaoDesejada,
      cultura: cultura,
      profundidadeCm: profundidadeCm,
    );
  }

  static double reposicaoExportacao({
    required double producaoEsperadaTha,
    required double indiceExportacaoK2OT,
  }) {
    if (producaoEsperadaTha <= 0 || indiceExportacaoK2OT <= 0) return 0.0;
    return producaoEsperadaTha * indiceExportacaoK2OT;
  }

  /// Reposição por extração com crédito do K do solo.
  ///
  /// Regra do projeto (alinhada ao Fósforo): o % do solo considerado modula
  /// quanto do K analisado (cmolc/dm³) é convertido em kg K₂O/ha disponível.
  /// Diverge de abordagens que aplicam o percentual sobre a demanda total.
  static ({
    double demandaTotalK2O,
    double contribuicaoSoloK2O,
    double reposicaoBaseK2O,
  }) reposicaoExtracao({
    required double producaoEsperadaTha,
    required double indiceExtracaoK2OT,
    required double kSoloCmolc,
    required double percentualKSoloConsiderado,
    int profundidadeCm = 20,
  }) {
    final demandaTotalK2O = producaoEsperadaTha > 0 && indiceExtracaoK2OT > 0
        ? producaoEsperadaTha * indiceExtracaoK2OT
        : 0.0;

    final kSoloUsado =
        kSoloCmolc * (percentualKSoloConsiderado.clamp(0.0, 100.0) / 100.0);
    final contribuicaoSoloK2O = kCmolcSoloParaK2OKgHa(
      kSoloUsado,
      profundidadeCm: profundidadeCm,
    );
    final reposicaoBaseK2O =
        (demandaTotalK2O - contribuicaoSoloK2O).clamp(0.0, double.infinity);

    return (
      demandaTotalK2O: demandaTotalK2O,
      contribuicaoSoloK2O: contribuicaoSoloK2O,
      reposicaoBaseK2O: reposicaoBaseK2O,
    );
  }

  static PotassioCalculoResultado calcular(PotassioCalculoInput input) {
    validarEntrada(input);

    final avisos = <String>[];
    final kNormalizado = normalizarKSolo(
      kOriginal: input.kSoloOriginal,
      unidade: input.kSoloUnidade,
    );
    final participacaoAtualCtc = participacaoAtual(
      kAtual: kNormalizado.kCmolc,
      ctc: input.ctcCmolc,
    );

    final culturaNorm = input.cultura.trim().toLowerCase();
    final alvoPct =
        input.metodoCorrecao == MetodoCorrecaoPotassio.percentualKCtc
            ? ((culturaNorm == 'algodao' || culturaNorm == 'algodão') &&
                    input.percentualKObjetivoCtc < 5.0
                ? 5.0
                : input.percentualKObjetivoCtc)
            : input.percentualKObjetivoCtc;
    final kAlvoCmolc =
        input.ctcCmolc > 0 ? input.ctcCmolc * (alvoPct / 100) : 0.0;

    double deficitKCmolc = 0.0;
    double deficitKMgDm3 = 0.0;
    double correcaoK2O = 0.0;

    if (input.corrigirSolo) {
      if (input.metodoCorrecao == MetodoCorrecaoPotassio.nivelCritico) {
        deficitKMgDm3 = (input.nivelCriticoMgDm3 - kNormalizado.kMgDm3)
            .clamp(0.0, double.infinity);
        correcaoK2O = correcaoPorNivelCritico(
          kAtualMgDm3: kNormalizado.kMgDm3,
          nivelCriticoMgDm3: input.nivelCriticoMgDm3,
          profundidadeCm: input.profundidadeCm,
        );
      } else {
        deficitKCmolc =
            (kAlvoCmolc - kNormalizado.kCmolc).clamp(0.0, double.infinity);
        correcaoK2O = correcaoPorPercentualCtc(
          ctcCmolc: input.ctcCmolc,
          kAtualCmolc: kNormalizado.kCmolc,
          percentualKObjetivo: input.percentualKObjetivoCtc,
          cultura: input.cultura,
          profundidadeCm: input.profundidadeCm,
        );
      }
    }

    double demandaTotalK2O = 0.0;
    double contribuicaoSoloK2O = 0.0;
    double reposicaoBaseK2O = 0.0;

    switch (input.reposicao) {
      case ReposicaoPotassio.exportacao:
        demandaTotalK2O = input.exportacaoK2OTotal ??
            reposicaoExportacao(
              producaoEsperadaTha: input.producaoEsperadaTha,
              indiceExportacaoK2OT: input.indiceExportacaoK2OT,
            );
        reposicaoBaseK2O = demandaTotalK2O;
      case ReposicaoPotassio.extracao:
        if (input.extracaoK2OTotal != null) {
          demandaTotalK2O = input.extracaoK2OTotal!;
          final kSoloUsado = kNormalizado.kCmolc *
              (input.percentualKSoloConsiderado.clamp(0.0, 100.0) / 100.0);
          contribuicaoSoloK2O = kCmolcSoloParaK2OKgHa(
            kSoloUsado,
            profundidadeCm: input.profundidadeCm,
          );
          reposicaoBaseK2O = (demandaTotalK2O - contribuicaoSoloK2O)
              .clamp(0.0, double.infinity);
        } else {
          final extracao = reposicaoExtracao(
            producaoEsperadaTha: input.producaoEsperadaTha,
            indiceExtracaoK2OT: input.indiceExtracaoK2OT,
            kSoloCmolc: kNormalizado.kCmolc,
            percentualKSoloConsiderado: input.percentualKSoloConsiderado,
            profundidadeCm: input.profundidadeCm,
          );
          demandaTotalK2O = extracao.demandaTotalK2O;
          contribuicaoSoloK2O = extracao.contribuicaoSoloK2O;
          reposicaoBaseK2O = extracao.reposicaoBaseK2O;
        }
      case ReposicaoPotassio.nenhuma:
        break;
    }

    final incrementoEficienciaK2O = input.reposicao == ReposicaoPotassio.nenhuma
        ? 0.0
        : incrementoEficiencia(
            reposicaoBaseK2O,
            input.ajusteEficienciaPercent,
          );
    final reposicaoAjustadaK2O = input.reposicao == ReposicaoPotassio.nenhuma
        ? 0.0
        : reposicaoBaseK2O + incrementoEficienciaK2O;
    final k2oFinal = correcaoK2O + reposicaoAjustadaK2O;

    return PotassioCalculoResultado(
      metodoCorrecao: input.metodoCorrecao,
      reposicao: input.reposicao,
      kSoloOriginal: input.kSoloOriginal,
      kSoloUnidade: input.kSoloUnidade,
      kSoloCmolc: kNormalizado.kCmolc,
      kSoloMgDm3: kNormalizado.kMgDm3,
      participacaoAtualCtcPercent: participacaoAtualCtc,
      nivelCriticoMgDm3: input.nivelCriticoMgDm3,
      percentualKObjetivoCtc: input.percentualKObjetivoCtc,
      kAlvoCmolc: kAlvoCmolc,
      deficitKCmolc: deficitKCmolc,
      deficitKMgDm3: deficitKMgDm3,
      correcaoK2O: correcaoK2O,
      producaoEsperadaTha: input.producaoEsperadaTha,
      indiceExportacaoK2OT: input.indiceExportacaoK2OT,
      indiceExtracaoK2OT: input.indiceExtracaoK2OT,
      demandaTotalK2O: demandaTotalK2O,
      contribuicaoSoloK2O: contribuicaoSoloK2O,
      reposicaoBaseK2O: reposicaoBaseK2O,
      ajusteEficienciaPercent: input.ajusteEficienciaPercent,
      incrementoEficienciaK2O: incrementoEficienciaK2O,
      reposicaoAjustadaK2O: reposicaoAjustadaK2O,
      k2oFinal: k2oFinal,
      modoResumo: _modoResumo(input.corrigirSolo, input.reposicao),
      avisos: avisos,
    );
  }

  static PotassioComponentesResultado recomendacaoComponentes({
    required bool corrigirSolo,
    required MetodoCorrecaoPotassio metodoCorrecao,
    required ReposicaoPotassio reposicao,
    required double ctc,
    required double kAtualCmolc,
    required double kAtualMgDm3,
    required double argilaPercent,
    required double ncTeorMgDm3,
    required double percentualKObjetivoCtc,
    required String cultura,
    required double percentualUsoKSolo,
    required double exportacaoK2O,
    required double extracaoK2O,
    required double ajusteEficienciaSolo,
    int profundidadeCm = 20,
    double producaoEsperadaTha = 0,
  }) {
    final resultado = calcular(
      PotassioCalculoInput(
        corrigirSolo: corrigirSolo,
        metodoCorrecao: metodoCorrecao,
        reposicao: reposicao,
        kSoloOriginal: kAtualCmolc,
        kSoloUnidade: UnidadePotassioSolo.cmolc,
        ctcCmolc: ctc,
        nivelCriticoMgDm3: ncTeorMgDm3,
        percentualKObjetivoCtc: percentualKObjetivoCtc,
        producaoEsperadaTha: producaoEsperadaTha,
        indiceExportacaoK2OT:
            producaoEsperadaTha > 0 ? exportacaoK2O / producaoEsperadaTha : 0,
        indiceExtracaoK2OT:
            producaoEsperadaTha > 0 ? extracaoK2O / producaoEsperadaTha : 0,
        percentualKSoloConsiderado: percentualUsoKSolo,
        ajusteEficienciaPercent: ajusteEficienciaSolo,
        cultura: cultura,
        profundidadeCm: profundidadeCm,
        exportacaoK2OTotal:
            reposicao == ReposicaoPotassio.exportacao ? exportacaoK2O : null,
        extracaoK2OTotal:
            reposicao == ReposicaoPotassio.extracao ? extracaoK2O : null,
      ),
    );

    return PotassioComponentesResultado.fromCalculo(resultado);
  }

  static String _modoResumo(
    bool corrigirSolo,
    ReposicaoPotassio reposicao,
  ) {
    final partes = <String>[
      if (corrigirSolo) 'Correção do solo',
      if (reposicao == ReposicaoPotassio.exportacao) 'Exportação',
      if (reposicao == ReposicaoPotassio.extracao) 'Extração',
    ];
    return partes.isEmpty ? 'Sem potássio' : partes.join(' + ');
  }

  /// Legado — combina saturação e teor (não usar em fluxos novos).
  static double recomendacao({
    required double ctc,
    required double kAtual,
    required double participacaoDesejada,
    String cultura = '',
    bool usarCriterioTeorAbsoluto = false,
    double? kAtualMgDm3,
    double? argilaPercent,
    double percentualCorrecaoTeor = 100.0,
  }) {
    final doseSaturacao = recomendacaoPorCtc(
      ctc: ctc,
      kAtual: kAtual,
      participacaoDesejada: participacaoDesejada,
      cultura: cultura,
    );

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

  /// Legado — divisão por FEK (não usar em fluxos novos).
  static double recomendacaoExtracao({
    required double kSolo,
    required double percentualUsoSolo,
    required double extracaoK2O,
    required double fek,
  }) {
    final extracao = reposicaoExtracao(
      producaoEsperadaTha: 1.0,
      indiceExtracaoK2OT: extracaoK2O,
      kSoloCmolc: kSolo,
      percentualKSoloConsiderado: percentualUsoSolo,
    );
    final doseBase = extracao.reposicaoBaseK2O;
    if (fek <= 0) return 0.0;
    return doseBase / (fek / 100.0);
  }

  static bool avisoSulco({
    required String modoAplicacao,
    required double doseK2O,
  }) {
    return modoAplicacao.trim().toLowerCase() == 'sulco' && doseK2O > 40.0;
  }

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
    double limiteKCtc = 7.0,
    double limiteKMg = 1.0,
    double limiteKCa = 0.4,
  }) {
    final pctKCTC = ctc > 0 ? (kTotal / ctc) * 100.0 : 0.0;
    final relKMg = mgAtual > 0 ? kTotal / mgAtual : 0.0;
    final relKCa = caAtual > 0 ? kTotal / caAtual : 0.0;
    return (
      pctKCTC: pctKCTC,
      relKMg: relKMg,
      relKCa: relKCa,
      avisoKCTC: pctKCTC > limiteKCtc,
      avisoKMg: relKMg > limiteKMg,
      avisoKCa: relKCa > limiteKCa,
    );
  }
}
