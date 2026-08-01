import 'package:soloforte/features/laboratorio/domain/data/absorcao_nutrientes_catalog.dart';
import 'package:soloforte/features/laboratorio/domain/models/absorcao_data_quality.dart';

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
  final AbsorcaoDataQuality quality;
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
        quality: AbsorcaoDataQuality.unavailable,
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
        quality: AbsorcaoDataQuality.original,
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
        quality: AbsorcaoDataQuality.unavailable,
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
      quality: AbsorcaoDataQuality.calculated,
      sourceType: sourceType,
      sourceName: sourceName,
      dataType: dataType,
      nutrient: nutrient,
    );
  }
}
