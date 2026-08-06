import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/presentation/formatters/coordinate_formatter.dart';

void main() {
  group('CoordinateFormatter', () {
    test('parseia coordenada decimal combinada com virgula', () {
      final parsed = CoordinateFormatter.parseCombined(
        '-10.510193, -48.315852',
      );

      expect(parsed, isNotNull);
      expect(parsed!.latitude, -10.510193);
      expect(parsed.longitude, -48.315852);
    });

    test('parseia coordenada decimal combinada com separador ponto e virgula',
        () {
      final parsed = CoordinateFormatter.parseCombined(
        '-10.510193; -48.315852',
      );

      expect(parsed, isNotNull);
      expect(parsed!.latitude, -10.510193);
      expect(parsed.longitude, -48.315852);
    });

    test('rejeita coordenada invalida', () {
      expect(CoordinateFormatter.parseCombined('100, -48'), isNull);
      expect(CoordinateFormatter.parseCombined('-10, -200'), isNull);
      expect(CoordinateFormatter.parseCombined('texto qualquer'), isNull);
    });

    test('campo vazio representa limpeza de coordenadas', () {
      expect(CoordinateFormatter.parseCombined(''), isNull);
      expect(CoordinateFormatter.formatCombined(null, null), isEmpty);
    });
  });
}
