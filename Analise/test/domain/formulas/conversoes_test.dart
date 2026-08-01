import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/conversoes.dart';

void main() {
  group('Conversoes', () {
    test('fator K mg/dm³ → cmolc/dm³ é 391', () {
      expect(Conversoes.kMgDm3Factor, 391.0);
    });

    test('kMgDm3ToCmolc usa divisão por 391', () {
      expect(Conversoes.kMgDm3ToCmolc(391.0), closeTo(1.0, 1e-9));
      expect(Conversoes.kMgDm3ToCmolc(78.2), closeTo(0.2, 1e-9));
    });

    test('kCmolcToMgDm3 é inverso', () {
      expect(Conversoes.kCmolcToMgDm3(1.0), 391.0);
    });

    test('tHaToKgHa e kgHaToTHa são inversos', () {
      expect(Conversoes.tHaToKgHa(2.5), 2500.0);
      expect(Conversoes.kgHaToTHa(2500.0), 2.5);
    });

    test('mmolcToCmolcFn divide por 10', () {
      expect(Conversoes.mmolcToCmolcFn(45), 4.5);
    });
  });
}
