import 'package:soloforte/domain/formulas/potassio_formula.dart';

enum UnidadePotassioSolo {
  mgDm3,
  cmolc,
}

/// Entrada normalizada para o motor de cálculo de Potássio.
class PotassioCalculoInput {
  const PotassioCalculoInput({
    required this.corrigirSolo,
    required this.metodoCorrecao,
    required this.reposicao,
    required this.kSoloOriginal,
    required this.kSoloUnidade,
    required this.ctcCmolc,
    required this.nivelCriticoMgDm3,
    required this.percentualKObjetivoCtc,
    required this.producaoEsperadaTha,
    required this.indiceExportacaoK2OT,
    required this.indiceExtracaoK2OT,
    required this.percentualKSoloConsiderado,
    required this.ajusteEficienciaPercent,
    this.cultura = '',
    this.profundidadeCm = 20,
    this.exportacaoK2OTotal,
    this.extracaoK2OTotal,
  });

  final bool corrigirSolo;
  final MetodoCorrecaoPotassio metodoCorrecao;
  final ReposicaoPotassio reposicao;
  final double kSoloOriginal;
  final UnidadePotassioSolo kSoloUnidade;
  final double ctcCmolc;
  final double nivelCriticoMgDm3;
  final double percentualKObjetivoCtc;
  final double producaoEsperadaTha;
  final double indiceExportacaoK2OT;
  final double indiceExtracaoK2OT;
  final double percentualKSoloConsiderado;
  final double ajusteEficienciaPercent;
  final String cultura;
  final int profundidadeCm;
  final double? exportacaoK2OTotal;
  final double? extracaoK2OTotal;
}

/// Resultado auditável do cálculo de Potássio (kg K₂O/ha).
class PotassioCalculoResultado {
  const PotassioCalculoResultado({
    required this.metodoCorrecao,
    required this.reposicao,
    required this.kSoloOriginal,
    required this.kSoloUnidade,
    required this.kSoloCmolc,
    required this.kSoloMgDm3,
    required this.participacaoAtualCtcPercent,
    required this.nivelCriticoMgDm3,
    required this.percentualKObjetivoCtc,
    required this.kAlvoCmolc,
    required this.deficitKCmolc,
    required this.deficitKMgDm3,
    required this.correcaoK2O,
    required this.producaoEsperadaTha,
    required this.indiceExportacaoK2OT,
    required this.indiceExtracaoK2OT,
    required this.demandaTotalK2O,
    required this.contribuicaoSoloK2O,
    required this.reposicaoBaseK2O,
    required this.ajusteEficienciaPercent,
    required this.incrementoEficienciaK2O,
    required this.reposicaoAjustadaK2O,
    required this.k2oFinal,
    required this.modoResumo,
    this.avisos = const [],
  });

  final MetodoCorrecaoPotassio metodoCorrecao;
  final ReposicaoPotassio reposicao;
  final double kSoloOriginal;
  final UnidadePotassioSolo kSoloUnidade;
  final double kSoloCmolc;
  final double kSoloMgDm3;
  final double participacaoAtualCtcPercent;
  final double nivelCriticoMgDm3;
  final double percentualKObjetivoCtc;
  final double kAlvoCmolc;
  final double deficitKCmolc;
  final double deficitKMgDm3;
  final double correcaoK2O;
  final double producaoEsperadaTha;
  final double indiceExportacaoK2OT;
  final double indiceExtracaoK2OT;
  final double demandaTotalK2O;
  final double contribuicaoSoloK2O;
  final double reposicaoBaseK2O;
  final double ajusteEficienciaPercent;
  final double incrementoEficienciaK2O;
  final double reposicaoAjustadaK2O;
  final double k2oFinal;
  final String modoResumo;
  final List<String> avisos;

  double get ncResumo => metodoCorrecao == MetodoCorrecaoPotassio.percentualKCtc
      ? percentualKObjetivoCtc
      : nivelCriticoMgDm3;
}
