import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/calcario_formula.dart';
import 'package:soloforte/domain/formulas/types/calcario_input.dart';

void main() {
  group('Calcário — monotonicidade e sanidade', () {
    test('pH baixo (V% baixo) aumenta dose vs solo adequado', () {
      const soloRuim = CalcarioInput(
        vd: 70.0,
        va: 25.0,
        ctcPh7: 8.0,
        prnt: 80.0,
        profundidade: 20.0,
      );
      const soloAdequado = CalcarioInput(
        vd: 70.0,
        va: 68.0,
        ctcPh7: 8.0,
        prnt: 80.0,
        profundidade: 20.0,
      );

      final doseRuim = CalcarioFormula.metodoV(soloRuim).ncToneladas;
      final doseAdequada = CalcarioFormula.metodoV(soloAdequado).ncToneladas;

      expect(doseRuim, greaterThan(doseAdequada));
      expect(doseRuim, greaterThan(0.0));
      expect(doseAdequada, greaterThanOrEqualTo(0.0));
    });

    test('não retorna valor negativo em borda (V atual acima do desejado)', () {
      const input = CalcarioInput(
        vd: 60.0,
        va: 75.0,
        ctcPh7: 6.0,
        prnt: 80.0,
        profundidade: 20.0,
      );

      final dose = CalcarioFormula.metodoV(input).ncToneladas;
      expect(dose, greaterThanOrEqualTo(0.0));
    });
  });
}

