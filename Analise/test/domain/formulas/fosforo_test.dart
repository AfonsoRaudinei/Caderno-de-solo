import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/fosforo_formula.dart';
import 'package:soloforte/domain/formulas/types/fosforo_input.dart';

void main() {
  group('Fósforo — monotonicidade e sanidade', () {
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

      final doseBaixo = FosforoFormula.recomendacaoCorrecao(baixoP).doseRecomendada;
      final doseAlto = FosforoFormula.recomendacaoCorrecao(altoP).doseRecomendada;

      expect(doseBaixo, greaterThan(doseAlto));
      expect(doseBaixo, greaterThan(0.0));
      expect(doseAlto, equals(0.0));
    });

    test('não retorna dose negativa em borda', () {
      const input = FosforoInput(
        argila: 25.0,
        pAtual: 999.0,
        nc: 20.0,
        referencia: 'teste',
      );
      final dose = FosforoFormula.recomendacaoCorrecao(input).doseRecomendada;
      expect(dose, greaterThanOrEqualTo(0.0));
    });
  });
}

