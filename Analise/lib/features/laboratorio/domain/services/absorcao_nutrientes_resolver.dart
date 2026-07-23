import 'package:soloforte/features/laboratorio/presentation/referencias/absorcao_nutrientes_data.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/absorcao_nutrientes_models.dart';

class AbsorcaoNutrientesResolvedValue {
  const AbsorcaoNutrientesResolvedValue({
    required this.valuePerTon,
    required this.quality,
    required this.sourceType,
    required this.sourceName,
    required this.dataType,
    required this.nutrient,
  });

  final double valuePerTon;
  final DataQuality quality;
  final String sourceType;
  final String sourceName;
  final String dataType;
  final String nutrient;

  double totalKgHa(double produtividadeTha) => valuePerTon * produtividadeTha;
}

class AbsorcaoNutrientesResolver {
  const AbsorcaoNutrientesResolver();

  static List<String> sourceNames(String sourceType) {
    return AbsorcaoNutrientesData.nutrientData[sourceType]?.keys.toList() ??
        const <String>[];
  }

  AbsorcaoNutrientesResolvedValue resolve({
    required String sourceType,
    required String sourceName,
    required String dataType,
    required String nutrient,
  }) {
    final source = AbsorcaoNutrientesData.nutrientData[sourceType]?[sourceName];
    if (source == null) {
      return AbsorcaoNutrientesResolvedValue(
        valuePerTon: 0,
        quality: DataQuality.unavailable,
        sourceType: sourceType,
        sourceName: sourceName,
        dataType: dataType,
        nutrient: nutrient,
      );
    }

    final selectedValue = source[dataType]?[nutrient] ?? 0;
    if (selectedValue > 0) {
      return AbsorcaoNutrientesResolvedValue(
        valuePerTon: selectedValue,
        quality: DataQuality.original,
        sourceType: sourceType,
        sourceName: sourceName,
        dataType: dataType,
        nutrient: nutrient,
      );
    }

    final oppositeType = dataType == 'Extração' ? 'Exportação' : 'Extração';
    final oppositeValue = source[oppositeType]?[nutrient] ?? 0;
    final index = AbsorcaoNutrientesData.exportIndexes[nutrient] ?? 0;
    if (oppositeValue <= 0 || index <= 0) {
      return AbsorcaoNutrientesResolvedValue(
        valuePerTon: 0,
        quality: DataQuality.unavailable,
        sourceType: sourceType,
        sourceName: sourceName,
        dataType: dataType,
        nutrient: nutrient,
      );
    }

    final calculated = dataType == 'Exportação'
        ? oppositeValue * index
        : oppositeValue / index;
    return AbsorcaoNutrientesResolvedValue(
      valuePerTon: calculated,
      quality: DataQuality.calculated,
      sourceType: sourceType,
      sourceName: sourceName,
      dataType: dataType,
      nutrient: nutrient,
    );
  }
}
