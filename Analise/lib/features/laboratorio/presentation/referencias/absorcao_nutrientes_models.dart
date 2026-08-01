import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/features/laboratorio/domain/models/absorcao_data_quality.dart';

export 'package:soloforte/features/laboratorio/domain/models/absorcao_data_quality.dart';

// Modelos de dados e enums da tela AbsorcaoNutrientesReferenciaPage.
// Extraído de absorcao_nutrientes_referencia_page.dart — FASE 2A.

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
  final AbsorcaoDataQuality quality;

  DataValue copyWith({
    double? valuePerTon,
    AbsorcaoDataQuality? quality,
  }) {
    return DataValue(
      valuePerTon: valuePerTon ?? this.valuePerTon,
      quality: quality ?? this.quality,
    );
  }
}

/// Alias de UI para a qualidade de domínio (mantém API antiga nas telas).
typedef DataQuality = AbsorcaoDataQuality;

extension AbsorcaoDataQualityUi on AbsorcaoDataQuality {
  Color get color => switch (this) {
        AbsorcaoDataQuality.original => const Color(0xFF0D2818),
        AbsorcaoDataQuality.calculated => const Color(0xFF3DD68C),
        AbsorcaoDataQuality.unavailable => AppColors.warning,
      };
}
