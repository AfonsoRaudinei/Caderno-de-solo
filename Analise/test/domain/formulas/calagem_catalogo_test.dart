import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/calagem_catalogo.dart';

void main() {
  group('CalagemCatalogo.sanitizarCorretivos', () {
    test('migra tipo oculto para Dolomítico', () {
      final resultado = CalagemCatalogo.sanitizarCorretivos({
        'tipoCalcario': 'Magnesiano',
        'metodoCalagem': '① Saturação por Bases (V%)',
        'tipoCalagem': 'Corretiva',
      });

      expect(resultado['tipoCalcario'], 'Dolomítico');
      expect(resultado['metodoCalagem'], '① Saturação por Bases (V%)');
    });

    test('migra método oculto para Saturação por Bases (V%)', () {
      final resultado = CalagemCatalogo.sanitizarCorretivos({
        'tipoCalcario': 'Calcítico',
        'metodoCalagem': '② EMBRAPA (fator H+Al)',
        'tipoCalagem': 'Corretiva',
      });

      expect(resultado['tipoCalcario'], 'Calcítico');
      expect(resultado['metodoCalagem'], '① Saturação por Bases (V%)');
    });

    test('mantém CA+CD em corretiva', () {
      final original = {
        'tipoCalcario': 'Dolomítico',
        'metodoCalagem': '⑧ CA+CD',
        'tipoCalagem': 'Corretiva',
      };

      final resultado = CalagemCatalogo.sanitizarCorretivos(original);

      expect(identical(resultado, original), isTrue);
      expect(resultado['metodoCalagem'], '⑧ CA+CD');
    });

    test('CA+CD em Manutenção PD volta para V%', () {
      final resultado = CalagemCatalogo.sanitizarCorretivos({
        'tipoCalcario': 'Dolomítico',
        'metodoCalagem': '⑧ CA+CD',
        'tipoCalagem': 'Manutenção PD',
      });

      expect(resultado['metodoCalagem'], '① Saturação por Bases (V%)');
    });
  });
}
