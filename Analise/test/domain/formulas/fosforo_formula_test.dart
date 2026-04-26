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
  });
}
