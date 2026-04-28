import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/potassio_formula.dart';

void main() {
  group('Potássio — monotonicidade e sanidade', () {
    test('K baixo gera dose maior que K alto', () {
      final doseBaixo = PotassioFormula.recomendacao(
        ctc: 10.0,
        kAtual: 0.1,
        participacaoDesejada: 5.0,
      );
      final doseAlto = PotassioFormula.recomendacao(
        ctc: 10.0,
        kAtual: 0.7,
        participacaoDesejada: 5.0,
      );

      expect(doseBaixo, greaterThan(doseAlto));
      expect(doseBaixo, greaterThan(0.0));
      expect(doseAlto, equals(0.0));
    });

    test('não retorna valor negativo em bordas', () {
      final dose = PotassioFormula.recomendacao(
        ctc: 0.0,
        kAtual: 0.0,
        participacaoDesejada: 5.0,
      );
      expect(dose, greaterThanOrEqualTo(0.0));
    });
  });
}

