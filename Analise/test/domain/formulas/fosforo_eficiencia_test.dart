import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/fosforo_formula.dart';

void main() {
  group('FosforoFormula.aplicarAjusteEficienciaSolo', () {
    const base = 64.68;

    test('ajuste 0% não altera necessidade', () {
      expect(
        FosforoFormula.aplicarAjusteEficienciaSolo(
          necessidadeBase: base,
          ajustePercentual: 0,
        ),
        closeTo(base, 0.01),
      );
    });

    test('ajuste 50% acrescenta metade', () {
      expect(
        FosforoFormula.aplicarAjusteEficienciaSolo(
          necessidadeBase: base,
          ajustePercentual: 50,
        ),
        closeTo(97.02, 0.01),
      );
    });

    test('ajuste 100% dobra necessidade', () {
      expect(
        FosforoFormula.aplicarAjusteEficienciaSolo(
          necessidadeBase: base,
          ajustePercentual: 100,
        ),
        closeTo(base * 2, 0.01),
      );
    });

    test('não divide por eficiência (50% ≠ base/0.5)', () {
      final ajustado = FosforoFormula.aplicarAjusteEficienciaSolo(
        necessidadeBase: base,
        ajustePercentual: 50,
      );
      expect(ajustado, isNot(closeTo(base / 0.5, 0.01)));
    });
  });

  group('FosforoFormula.recomendacaoExportacao', () {
    test('exportação pura sem desconto de solo', () {
      final dose = FosforoFormula.recomendacaoExportacao(
        exportacaoP2O5: 70.0,
        fepFinal: 15.0,
      );
      expect(dose, closeTo(466.67, 0.1));
    });
  });
}
