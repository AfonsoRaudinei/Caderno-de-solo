import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/fosforo_formula.dart';
import 'package:soloforte/domain/formulas/types/fosforo_input.dart';

void main() {
  const input = FosforoInput(
    argila: 25.0,
    pAtual: 10.0,
    nc: 20.0,
    referencia: 'IAC',
  );

  group('FosforoFormula — correção do solo', () {
    test('P baixo gera dose maior que P alto', () {
      const baixoP = FosforoInput(
        argila: 45.0,
        pAtual: 4.0,
        nc: 18.0,
        referencia: 'teste',
      );
      const altoP = FosforoInput(
        argila: 45.0,
        pAtual: 22.0,
        nc: 18.0,
        referencia: 'teste',
      );

      final doseBaixo =
          FosforoFormula.recomendacaoCorrecao(baixoP).doseRecomendada;
      final doseAlto =
          FosforoFormula.recomendacaoCorrecao(altoP).doseRecomendada;

      expect(doseBaixo, greaterThan(doseAlto));
      expect(doseBaixo, greaterThan(0.0));
      expect(doseAlto, equals(0.0));
    });

    test('P acima do NC retorna dose zero', () {
      const alto = FosforoInput(
        argila: 25.0,
        pAtual: 30.0,
        nc: 20.0,
        referencia: 'IAC',
      );
      expect(
        FosforoFormula.recomendacaoCorrecao(alto).doseRecomendada,
        equals(0.0),
      );
    });
  });

  group('FosforoFormula — reposição sem eficiência', () {
    test('sem reposição zera componentes de reposição', () {
      final result = FosforoFormula.recomendacaoComponentes(
        corrigirSolo: true,
        reposicao: ReposicaoFosforo.nenhuma,
        correcaoInput: input,
        pSolo: 10.0,
        percentualUsoSoloExtracao: 100.0,
        profundidadeCm: 20.0,
        exportacaoP2O5: 70.0,
        extracaoP2O5: 100.0,
        eficienciaSoloPercent: 50.0,
        fepCorrecao: 20.0,
      );

      expect(result.doseCorrecao, greaterThan(0.0));
      expect(result.reposicaoBaseP2O5KgHa, equals(0.0));
      expect(result.incrementoEficienciaP2O5KgHa, equals(0.0));
      expect(result.reposicaoAjustadaP2O5KgHa, equals(0.0));
      expect(result.doseExportacao, equals(0.0));
      expect(result.doseExtracao, equals(0.0));
    });

    test('exportação com eficiência 0% mantém reposição base', () {
      final result = FosforoFormula.recomendacaoComponentes(
        corrigirSolo: false,
        reposicao: ReposicaoFosforo.exportacao,
        correcaoInput: input,
        pSolo: 10.0,
        percentualUsoSoloExtracao: 0.0,
        profundidadeCm: 20.0,
        exportacaoP2O5: 70.0,
        extracaoP2O5: 100.0,
        eficienciaSoloPercent: 0.0,
        fepCorrecao: 20.0,
      );

      expect(result.reposicaoBaseP2O5KgHa, closeTo(70.0, 0.01));
      expect(result.incrementoEficienciaP2O5KgHa, equals(0.0));
      expect(result.reposicaoAjustadaP2O5KgHa, closeTo(70.0, 0.01));
      expect(result.doseExportacao, closeTo(70.0, 0.01));
    });
  });

  group('FosforoFormula — eficiência no solo', () {
    test('exportação com eficiência 50% aplica incremento aditivo', () {
      final result = FosforoFormula.recomendacaoComponentes(
        corrigirSolo: false,
        reposicao: ReposicaoFosforo.exportacao,
        correcaoInput: input,
        pSolo: 10.0,
        percentualUsoSoloExtracao: 0.0,
        profundidadeCm: 20.0,
        exportacaoP2O5: 70.0,
        extracaoP2O5: 100.0,
        eficienciaSoloPercent: 50.0,
        fepCorrecao: 20.0,
      );

      expect(result.reposicaoBaseP2O5KgHa, closeTo(70.0, 0.01));
      expect(result.incrementoEficienciaP2O5KgHa, closeTo(35.0, 0.01));
      expect(result.reposicaoAjustadaP2O5KgHa, closeTo(105.0, 0.01));
      expect(result.doseExportacao, closeTo(105.0, 0.01));
    });

    test('exemplo planilha 4,2 × 15,4 com eficiência 50%', () {
      const prod = 4.2;
      const taxa = 15.4;
      final base = FosforoFormula.reposicaoBaseKgHa(
        produtividadeTha: prod,
        taxaP2O5PorT: taxa,
      );

      expect(base, closeTo(64.68, 0.01));

      final result = FosforoFormula.recomendacaoComponentes(
        corrigirSolo: false,
        reposicao: ReposicaoFosforo.extracao,
        correcaoInput: input,
        pSolo: 0.0,
        percentualUsoSoloExtracao: 0.0,
        profundidadeCm: 20.0,
        exportacaoP2O5: 0.0,
        extracaoP2O5: base,
        eficienciaSoloPercent: 50.0,
        fepCorrecao: 15.0,
      );

      expect(result.reposicaoBaseP2O5KgHa, closeTo(64.68, 0.01));
      expect(result.incrementoEficienciaP2O5KgHa, closeTo(32.34, 0.01));
      expect(result.reposicaoAjustadaP2O5KgHa, closeTo(97.02, 0.01));
      expect(result.doseExtracao, closeTo(97.02, 0.01));
      expect(result.doseTotal, closeTo(97.02, 0.01));
    });

    test('extração abate P do solo antes da eficiência', () {
      final result = FosforoFormula.recomendacaoComponentes(
        corrigirSolo: false,
        reposicao: ReposicaoFosforo.extracao,
        correcaoInput: input,
        pSolo: 10.0,
        percentualUsoSoloExtracao: 100.0,
        profundidadeCm: 20.0,
        exportacaoP2O5: 70.0,
        extracaoP2O5: 100.0,
        eficienciaSoloPercent: 0.0,
        fepCorrecao: 20.0,
      );

      expect(result.pSoloCreditadoP2O5, closeTo(45.82, 0.01));
      expect(result.reposicaoBaseP2O5KgHa, closeTo(54.18, 0.01));
      expect(result.incrementoEficienciaP2O5KgHa, equals(0.0));
      expect(result.doseExtracao, closeTo(54.18, 0.01));
    });

    test('correção permanece independente da reposição', () {
      final result = FosforoFormula.recomendacaoComponentes(
        corrigirSolo: true,
        reposicao: ReposicaoFosforo.exportacao,
        correcaoInput: input,
        pSolo: 10.0,
        percentualUsoSoloExtracao: 0.0,
        profundidadeCm: 20.0,
        exportacaoP2O5: 70.0,
        extracaoP2O5: 100.0,
        eficienciaSoloPercent: 50.0,
        fepCorrecao: 20.0,
      );

      expect(result.doseCorrecao, greaterThan(0.0));
      expect(result.doseExportacao, closeTo(105.0, 0.01));
      expect(
        result.doseTotal,
        closeTo(result.doseCorrecao + result.doseExportacao, 0.01),
      );
    });
  });

  group('FosforoFormula — validação e unidades', () {
    test('eficiência inválida é limitada entre 0 e 100%', () {
      final incremento = FosforoFormula.incrementoEficienciaSolo(
        reposicaoBase: 100.0,
        eficienciaSoloPercent: 150.0,
      );
      expect(incremento, closeTo(100.0, 0.01));
    });

    test('produtividade ou taxa inválidas retornam reposição base zero', () {
      expect(
        FosforoFormula.reposicaoBaseKgHa(
          produtividadeTha: 0.0,
          taxaP2O5PorT: 15.4,
        ),
        equals(0.0),
      );
      expect(
        FosforoFormula.reposicaoBaseKgHa(
          produtividadeTha: -1.0,
          taxaP2O5PorT: 15.4,
        ),
        equals(0.0),
      );
    });

    test('P do solo convertido para P₂O₅ usa fator 2,291', () {
      final credito = FosforoFormula.pSoloDisponivelP2O5(
        pSolo: 10.0,
        percentualUsoSolo: 100.0,
        profundidadeCm: 20.0,
      );
      expect(credito, closeTo(45.82, 0.01));
    });
  });
}
