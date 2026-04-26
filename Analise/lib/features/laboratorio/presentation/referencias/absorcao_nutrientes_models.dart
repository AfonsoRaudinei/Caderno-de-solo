import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';

// Modelos de dados e enums da tela AbsorcaoNutrientesReferenciaPage.
// Extraído de absorcao_nutrientes_referencia_page.dart — FASE 2A.
// Nenhuma lógica de UI neste arquivo.

enum ReferenceSection {
  painel,
  tabelas,
}

enum ViewMode {
  perStage,
  accumulated,
}

class StagePoint {
  const StagePoint({
    required this.stage,
    required this.percentage,
    required this.value,
  });

  final String stage;
  final double percentage;
  final double value;
}

class SummaryCardData {
  const SummaryCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
}

class ReferenceTableCardData {
  const ReferenceTableCardData({
    required this.title,
    required this.description,
    required this.unit,
    required this.rows,
  });

  final String title;
  final String description;
  final String unit;
  final List<ReferenceTableRow> rows;
}

class ReferenceTableRow {
  const ReferenceTableRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class DataValue {
  const DataValue({
    required this.valuePerTon,
    required this.quality,
  });

  final double valuePerTon;
  final DataQuality quality;

  DataValue copyWith({
    double? valuePerTon,
    DataQuality? quality,
  }) {
    return DataValue(
      valuePerTon: valuePerTon ?? this.valuePerTon,
      quality: quality ?? this.quality,
    );
  }
}

class DataQuality {
  const DataQuality._({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  static const original = DataQuality._(
    title: 'Original',
    subtitle: 'Valor direto da fonte selecionada',
    color: Color(0xFF0D2818),
  );

  static const calculated = DataQuality._(
    title: 'Calculado',
    subtitle: 'Estimado por índice de exportação',
    color: Color(0xFF3DD68C),
  );

  static const unavailable = DataQuality._(
    title: 'Indisponível',
    subtitle: 'Sem base para calcular este nutriente',
    color: AppColors.warning,
  );

  final String title;
  final String subtitle;
  final Color color;
}
