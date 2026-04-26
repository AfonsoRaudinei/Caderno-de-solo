import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/presentation/formatters/analise_number_formatter.dart';

void main() {
  group('AnaliseNumberFormatter.formatDecimal', () {
    test('retorna "-" para null', () {
      expect(AnaliseNumberFormatter.formatDecimal(null), '-');
    });

    test('formata decimais com 3 casas', () {
      expect(AnaliseNumberFormatter.formatDecimal(0.0645012787), '0.065');
      expect(AnaliseNumberFormatter.formatDecimal(1.72), '1.720');
    });

    test('mantém inteiros quando keepIntegers=true', () {
      expect(AnaliseNumberFormatter.formatDecimal(2.0), '2');
      expect(AnaliseNumberFormatter.formatDecimal(10), '10');
    });

    test('força casas mesmo para inteiro quando keepIntegers=false', () {
      expect(
        AnaliseNumberFormatter.formatDecimal(2.0, keepIntegers: false),
        '2.000',
      );
    });
  });
}
