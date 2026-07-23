import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/laboratorio/domain/services/absorcao_nutrientes_resolver.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/absorcao_nutrientes_models.dart';

void main() {
  group('AbsorcaoNutrientesResolver', () {
    const resolver = AbsorcaoNutrientesResolver();

    test('retorna valor original da fonte selecionada', () {
      final resolved = resolver.resolve(
        sourceType: 'Autores',
        sourceName: 'Araújo (2023)',
        dataType: 'Exportação',
        nutrient: 'P',
      );

      expect(resolved.valuePerTon, 3.4);
      expect(resolved.quality, DataQuality.original);
    });

    test('calcula valor por índice quando o dado direto está ausente', () {
      final resolved = resolver.resolve(
        sourceType: 'Autores',
        sourceName: 'Kurihara et al. (2013)¹',
        dataType: 'Extração',
        nutrient: 'P',
      );

      expect(resolved.valuePerTon, closeTo(4.7875, 0.0001));
      expect(resolved.quality, DataQuality.calculated);
    });

    test('retorna indisponível para fonte inexistente', () {
      final resolved = resolver.resolve(
        sourceType: 'Autores',
        sourceName: 'Fonte inexistente',
        dataType: 'Exportação',
        nutrient: 'P',
      );

      expect(resolved.valuePerTon, 0);
      expect(resolved.quality, DataQuality.unavailable);
    });
  });
}
