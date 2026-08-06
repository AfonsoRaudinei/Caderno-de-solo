import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/conversoes.dart';
import 'package:soloforte/domain/formulas/potassio_formula.dart';

PotassioCalculoInput _input({
  bool corrigirSolo = false,
  MetodoCorrecaoPotassio metodoCorrecao = MetodoCorrecaoPotassio.nivelCritico,
  ReposicaoPotassio reposicao = ReposicaoPotassio.nenhuma,
  double kSolo = 0.2,
  UnidadePotassioSolo kUnidade = UnidadePotassioSolo.cmolc,
  double ctc = 10.0,
  double ncMgDm3 = 60.0,
  double percentualKObjetivo = 5.0,
  double producao = 0,
  double indiceExport = 20,
  double indiceExtracao = 31,
  double percentualKSolo = 100,
  double eficiencia = 0,
  int profundidadeCm = 20,
  double? exportacaoTotal,
  double? extracaoTotal,
}) {
  return PotassioCalculoInput(
    corrigirSolo: corrigirSolo,
    metodoCorrecao: metodoCorrecao,
    reposicao: reposicao,
    kSoloOriginal: kSolo,
    kSoloUnidade: kUnidade,
    ctcCmolc: ctc,
    nivelCriticoMgDm3: ncMgDm3,
    percentualKObjetivoCtc: percentualKObjetivo,
    producaoEsperadaTha: producao,
    indiceExportacaoK2OT: indiceExport,
    indiceExtracaoK2OT: indiceExtracao,
    percentualKSoloConsiderado: percentualKSolo,
    ajusteEficienciaPercent: eficiencia,
    profundidadeCm: profundidadeCm,
    exportacaoK2OTotal: exportacaoTotal,
    extracaoK2OTotal: extracaoTotal,
  );
}

void main() {
  group('PotassioFormula.calcular — correção do solo', () {
    test('correção desligada retorna k2oCorrecao = 0', () {
      final r = PotassioFormula.calcular(
        _input(
          corrigirSolo: false,
          metodoCorrecao: MetodoCorrecaoPotassio.nivelCritico,
          kSolo: 0.05,
          ncMgDm3: 60,
        ),
      );
      expect(r.correcaoK2O, 0);
      expect(r.deficitKMgDm3, 0);
    });

    test('correção por nível crítico com K abaixo do NC', () {
      final r = PotassioFormula.calcular(
        _input(
          corrigirSolo: true,
          metodoCorrecao: MetodoCorrecaoPotassio.nivelCritico,
          kSolo: 30,
          kUnidade: UnidadePotassioSolo.mgDm3,
          ncMgDm3: 60,
        ),
      );
      expect(r.deficitKMgDm3, 30);
      expect(r.correcaoK2O, greaterThan(0));
      expect(
        r.correcaoK2O,
        closeTo(
          PotassioFormula.correcaoPorNivelCritico(
            kAtualMgDm3: 30,
            nivelCriticoMgDm3: 60,
          ),
          0.0001,
        ),
      );
    });

    test('K acima do NC gera déficit e correção zero', () {
      final r = PotassioFormula.calcular(
        _input(
          corrigirSolo: true,
          kSolo: 80,
          kUnidade: UnidadePotassioSolo.mgDm3,
          ncMgDm3: 60,
        ),
      );
      expect(r.deficitKMgDm3, 0);
      expect(r.correcaoK2O, 0);
    });

    test('K igual ao NC gera déficit e correção zero', () {
      final r = PotassioFormula.calcular(
        _input(
          corrigirSolo: true,
          kSolo: 60,
          kUnidade: UnidadePotassioSolo.mgDm3,
          ncMgDm3: 60,
        ),
      );
      expect(r.deficitKMgDm3, 0);
      expect(r.correcaoK2O, 0);
    });

    test('correção por % K na CTC com déficit', () {
      final r = PotassioFormula.calcular(
        _input(
          corrigirSolo: true,
          metodoCorrecao: MetodoCorrecaoPotassio.percentualKCtc,
          kSolo: 0.2,
          ctc: 10,
          percentualKObjetivo: 5,
        ),
      );
      expect(r.deficitKCmolc, closeTo(0.3, 0.0001));
      expect(r.correcaoK2O, closeTo(282.693, 0.01));
    });

    test('K atual acima do alvo percentual na CTC', () {
      final r = PotassioFormula.calcular(
        _input(
          corrigirSolo: true,
          metodoCorrecao: MetodoCorrecaoPotassio.percentualKCtc,
          kSolo: 0.6,
          ctc: 10,
          percentualKObjetivo: 5,
        ),
      );
      expect(r.deficitKCmolc, 0);
      expect(r.correcaoK2O, 0);
    });

    test('K atual abaixo do alvo percentual na CTC', () {
      final r = PotassioFormula.calcular(
        _input(
          corrigirSolo: true,
          metodoCorrecao: MetodoCorrecaoPotassio.percentualKCtc,
          kSolo: 0.1,
          ctc: 10,
          percentualKObjetivo: 5,
        ),
      );
      expect(r.deficitKCmolc, closeTo(0.4, 0.0001));
      expect(r.correcaoK2O, greaterThan(0));
    });

    test('CTC zero no método % K na CTC lança ArgumentError', () {
      expect(
        () => PotassioFormula.calcular(
          _input(
            corrigirSolo: true,
            metodoCorrecao: MetodoCorrecaoPotassio.percentualKCtc,
            ctc: 0,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('não soma correção por NC e por % CTC — usa método ativo', () {
      final porNc = PotassioFormula.calcular(
        _input(
          corrigirSolo: true,
          metodoCorrecao: MetodoCorrecaoPotassio.nivelCritico,
          kSolo: 30,
          kUnidade: UnidadePotassioSolo.mgDm3,
          ncMgDm3: 60,
          ctc: 10,
          percentualKObjetivo: 5,
        ),
      );
      final porCtc = PotassioFormula.calcular(
        _input(
          corrigirSolo: true,
          metodoCorrecao: MetodoCorrecaoPotassio.percentualKCtc,
          kSolo: 30,
          kUnidade: UnidadePotassioSolo.mgDm3,
          ncMgDm3: 60,
          ctc: 10,
          percentualKObjetivo: 5,
        ),
      );
      expect(porNc.correcaoK2O, isNot(closeTo(porCtc.correcaoK2O, 0.01)));
      expect(porNc.correcaoK2O, isNot(porNc.correcaoK2O + porCtc.correcaoK2O));
    });
  });

  group('PotassioFormula.calcular — normalização de unidades', () {
    test('conversão mg/dm³ → cmolc/dm³ usa fator 391', () {
      final r = PotassioFormula.calcular(
        _input(kSolo: 391, kUnidade: UnidadePotassioSolo.mgDm3),
      );
      expect(r.kSoloCmolc, closeTo(1.0, 0.0001));
      expect(r.kSoloMgDm3, 391);
      expect(r.kSoloUnidade, UnidadePotassioSolo.mgDm3);
    });

    test('entrada em cmolc preserva unidade original', () {
      final r = PotassioFormula.calcular(
        _input(kSolo: 0.25, kUnidade: UnidadePotassioSolo.cmolc),
      );
      expect(r.kSoloOriginal, 0.25);
      expect(r.kSoloUnidade, UnidadePotassioSolo.cmolc);
      expect(r.kSoloMgDm3, closeTo(Conversoes.kCmolcToMgDm3(0.25), 0.0001));
    });
  });

  group('PotassioFormula.calcular — reposição', () {
    test('sem reposição: final = correção', () {
      final r = PotassioFormula.calcular(
        _input(
          corrigirSolo: true,
          kSolo: 30,
          kUnidade: UnidadePotassioSolo.mgDm3,
          ncMgDm3: 60,
          reposicao: ReposicaoPotassio.nenhuma,
          eficiencia: 15,
        ),
      );
      expect(r.reposicaoBaseK2O, 0);
      expect(r.incrementoEficienciaK2O, 0);
      expect(r.reposicaoAjustadaK2O, 0);
      expect(r.k2oFinal, r.correcaoK2O);
    });

    test('exportação: produção × índice', () {
      final r = PotassioFormula.calcular(
        _input(
          reposicao: ReposicaoPotassio.exportacao,
          producao: 4.2,
          indiceExport: 20,
        ),
      );
      expect(r.reposicaoBaseK2O, closeTo(84, 0.0001));
      expect(r.demandaTotalK2O, closeTo(84, 0.0001));
      expect(r.contribuicaoSoloK2O, 0);
    });

    test('extração com demanda total e crédito do solo', () {
      final r = PotassioFormula.calcular(
        _input(
          reposicao: ReposicaoPotassio.extracao,
          producao: 4.2,
          indiceExtracao: 31,
          kSolo: 0.1,
          percentualKSolo: 50,
        ),
      );
      expect(r.demandaTotalK2O, closeTo(130.2, 0.0001));
      expect(r.contribuicaoSoloK2O, greaterThan(0));
      expect(r.reposicaoBaseK2O, lessThan(r.demandaTotalK2O));
    });

    test('solo considerado 0% não credita K do solo', () {
      final r = PotassioFormula.calcular(
        _input(
          reposicao: ReposicaoPotassio.extracao,
          extracaoTotal: 130.2,
          percentualKSolo: 0,
          kSolo: 0.5,
        ),
      );
      expect(r.contribuicaoSoloK2O, 0);
      expect(r.reposicaoBaseK2O, closeTo(130.2, 0.0001));
    });

    test('solo considerado 100% maximiza crédito do K analisado', () {
      final r0 = PotassioFormula.calcular(
        _input(
          reposicao: ReposicaoPotassio.extracao,
          extracaoTotal: 500,
          percentualKSolo: 0,
          kSolo: 0.2,
        ),
      );
      final r100 = PotassioFormula.calcular(
        _input(
          reposicao: ReposicaoPotassio.extracao,
          extracaoTotal: 500,
          percentualKSolo: 100,
          kSolo: 0.2,
        ),
      );
      expect(r100.contribuicaoSoloK2O, greaterThan(r0.contribuicaoSoloK2O));
      expect(r100.reposicaoBaseK2O, lessThan(r0.reposicaoBaseK2O));
    });

    test('produção zero zera exportação e extração por índice', () {
      final exportacao = PotassioFormula.calcular(
        _input(
          reposicao: ReposicaoPotassio.exportacao,
          producao: 0,
          indiceExport: 20,
        ),
      );
      final extracao = PotassioFormula.calcular(
        _input(
          reposicao: ReposicaoPotassio.extracao,
          producao: 0,
          indiceExtracao: 31,
        ),
      );
      expect(exportacao.reposicaoBaseK2O, 0);
      expect(extracao.reposicaoBaseK2O, 0);
    });

    test('índices zero zeram reposição', () {
      final r = PotassioFormula.calcular(
        _input(
          reposicao: ReposicaoPotassio.exportacao,
          producao: 5,
          indiceExport: 0,
        ),
      );
      expect(r.reposicaoBaseK2O, 0);
    });
  });

  group('PotassioFormula.calcular — eficiência aditiva', () {
    test('eficiência 0% mantém reposição base', () {
      final r = PotassioFormula.calcular(
        _input(
          reposicao: ReposicaoPotassio.extracao,
          extracaoTotal: 130.2,
          percentualKSolo: 0,
          eficiencia: 0,
        ),
      );
      expect(r.incrementoEficienciaK2O, 0);
      expect(r.reposicaoAjustadaK2O, closeTo(130.2, 0.0001));
    });

    test('regressão planilha: 130,2 + 15% = 149,73', () {
      final r = PotassioFormula.calcular(
        _input(
          reposicao: ReposicaoPotassio.extracao,
          extracaoTotal: 130.2,
          percentualKSolo: 0,
          eficiencia: 15,
        ),
      );
      expect(r.reposicaoBaseK2O, closeTo(130.2, 0.0001));
      expect(r.incrementoEficienciaK2O, closeTo(19.53, 0.01));
      expect(r.reposicaoAjustadaK2O, closeTo(149.73, 0.01));
      expect(r.k2oFinal, closeTo(149.73, 0.01));
    });

    test('eficiência 100% dobra a reposição base', () {
      final r = PotassioFormula.calcular(
        _input(
          reposicao: ReposicaoPotassio.exportacao,
          exportacaoTotal: 100,
          eficiencia: 100,
        ),
      );
      expect(r.incrementoEficienciaK2O, closeTo(100, 0.0001));
      expect(r.reposicaoAjustadaK2O, closeTo(200, 0.0001));
    });
  });

  group('PotassioFormula.calcular — resultado final auditável', () {
    test('k2oFinal = correcao + reposicaoAjustada', () {
      final r = PotassioFormula.calcular(
        _input(
          corrigirSolo: true,
          kSolo: 30,
          kUnidade: UnidadePotassioSolo.mgDm3,
          ncMgDm3: 60,
          reposicao: ReposicaoPotassio.exportacao,
          exportacaoTotal: 84,
          eficiencia: 15,
        ),
      );
      expect(
        r.k2oFinal,
        closeTo(r.correcaoK2O + r.reposicaoAjustadaK2O, 0.0001),
      );
    });

    test('recomendacaoComponentes expõe detalhe auditável', () {
      final componentes = PotassioFormula.recomendacaoComponentes(
        corrigirSolo: false,
        metodoCorrecao: MetodoCorrecaoPotassio.nivelCritico,
        reposicao: ReposicaoPotassio.extracao,
        ctc: 8,
        kAtualCmolc: 0.15,
        kAtualMgDm3: 58.65,
        argilaPercent: 25,
        ncTeorMgDm3: 60,
        percentualKObjetivoCtc: 4,
        cultura: 'Soja',
        percentualUsoKSolo: 0,
        exportacaoK2O: 0,
        extracaoK2O: 130.2,
        ajusteEficienciaSolo: 15,
        producaoEsperadaTha: 4.2,
      );
      expect(componentes.detalhe, isNotNull);
      expect(componentes.detalhe!.reposicaoBaseK2O, closeTo(130.2, 0.0001));
      expect(
          componentes.detalhe!.incrementoEficienciaK2O, closeTo(19.53, 0.01));
      expect(
        componentes.detalhe!.reposicaoAjustadaK2O,
        closeTo(149.73, 0.01),
      );
    });
  });

  group('PotassioFormula.calcular — validações', () {
    test('rejeita K negativo', () {
      expect(
        () => PotassioFormula.calcular(_input(kSolo: -1)),
        throwsArgumentError,
      );
    });

    test('rejeita CTC negativa', () {
      expect(
        () => PotassioFormula.calcular(_input(ctc: -1)),
        throwsArgumentError,
      );
    });

    test('rejeita NC negativo', () {
      expect(
        () => PotassioFormula.calcular(_input(ncMgDm3: -1)),
        throwsArgumentError,
      );
    });

    test('rejeita % K objetivo fora de 0–100', () {
      expect(
        () => PotassioFormula.calcular(_input(percentualKObjetivo: -1)),
        throwsArgumentError,
      );
      expect(
        () => PotassioFormula.calcular(_input(percentualKObjetivo: 101)),
        throwsArgumentError,
      );
    });

    test('rejeita eficiência fora de 0–100', () {
      expect(
        () => PotassioFormula.calcular(_input(eficiencia: -1)),
        throwsArgumentError,
      );
      expect(
        () => PotassioFormula.calcular(_input(eficiencia: 101)),
        throwsArgumentError,
      );
    });

    test('rejeita produção negativa', () {
      expect(
        () => PotassioFormula.calcular(_input(producao: -1)),
        throwsArgumentError,
      );
    });

    test('rejeita índices negativos', () {
      expect(
        () => PotassioFormula.calcular(_input(indiceExport: -1)),
        throwsArgumentError,
      );
      expect(
        () => PotassioFormula.calcular(_input(indiceExtracao: -1)),
        throwsArgumentError,
      );
    });
  });
}
