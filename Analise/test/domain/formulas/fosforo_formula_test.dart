import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/fosforo_formula.dart';
import 'package:soloforte/domain/formulas/types/fosforo_input.dart';

void main() {
  group('FosforoFormula', () {
    test('CASO 1 — IAC Bol.100, argila <15%, P_Resina atual < NC', () {
      const input = FosforoInput(
        argila: 10.0,
        pAtual: 8.0,
        nc: 12.0,
        referencia: 'IAC',
      );
      final result = FosforoFormula.recomendacaoCorrecao(input);
      expect(result.doseRecomendada, greaterThan(0.0));
    });

    test('CASO 2 — P atual já acima do NC: dose = 0 (sem necessidade)', () {
      const input = FosforoInput(
        argila: 25.0,
        pAtual: 30.0,
        nc: 20.0,
        referencia: 'IAC',
      );
      final result = FosforoFormula.recomendacaoCorrecao(input);
      expect(result.doseRecomendada, equals(0.0));
    });

    test('componentes soma correção e exportação sem abater P do solo', () {
      const input = FosforoInput(
        argila: 25.0,
        pAtual: 10.0,
        nc: 20.0,
        referencia: 'IAC',
      );

      final result = FosforoFormula.recomendacaoComponentes(
        corrigirSolo: true,
        reposicao: ReposicaoFosforo.exportacao,
        correcaoInput: input,
        pSolo: 10.0,
        percentualUsoSoloExtracao: 100.0,
        profundidadeCm: 20.0,
        exportacaoP2O5: 70.0,
        extracaoP2O5: 100.0,
        fepFinal: 20.0,
      );

      expect(result.doseCorrecao, greaterThan(0.0));
      expect(result.doseExportacao, closeTo(350.0, 0.01));
      expect(result.doseExtracao, equals(0.0));
      expect(result.pSoloCreditadoP2O5, equals(0.0));
      expect(
        result.doseTotal,
        closeTo(result.doseCorrecao + result.doseExportacao, 0.01),
      );
    });

    test('extração abate percentual do P do solo', () {
      const input = FosforoInput(
        argila: 25.0,
        pAtual: 10.0,
        nc: 20.0,
        referencia: 'IAC',
      );

      final result = FosforoFormula.recomendacaoComponentes(
        corrigirSolo: false,
        reposicao: ReposicaoFosforo.extracao,
        correcaoInput: input,
        pSolo: 10.0,
        percentualUsoSoloExtracao: 100.0,
        profundidadeCm: 20.0,
        exportacaoP2O5: 70.0,
        extracaoP2O5: 100.0,
        fepFinal: 20.0,
      );

      expect(result.doseCorrecao, equals(0.0));
      expect(result.doseExportacao, equals(0.0));
      expect(result.pSoloCreditadoP2O5, closeTo(45.82, 0.01));
      expect(result.doseExtracao, closeTo(270.9, 0.1));
      expect(result.doseTotal, closeTo(result.doseExtracao, 0.01));
    });
  });
}
