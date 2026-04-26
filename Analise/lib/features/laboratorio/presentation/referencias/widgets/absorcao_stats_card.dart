import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/absorcao_nutrientes_data.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/absorcao_nutrientes_models.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/widgets/absorcao_card_wrapper.dart';

/// Card de estatísticas da tela de absorção de nutrientes.
/// Extraído de absorcao_nutrientes_referencia_page.dart (_buildStatsCard) — FASE 3.
class AbsorcaoStatsCard extends StatelessWidget {
  const AbsorcaoStatsCard({
    super.key,
    required this.total,
    required this.unit,
    required this.quality,
    required this.expectedYield,
    required this.selectedNutrient,
  });

  final double total;
  final String unit;
  final DataQuality quality;
  final double expectedYield;
  final String selectedNutrient;

  @override
  Widget build(BuildContext context) {
    final cards = <SummaryCardData>[
      SummaryCardData(
        title: 'Total',
        value: total.toStringAsFixed(2),
        subtitle: unit,
        color: AbsorcaoNutrientesCores.greenDark,
      ),
      SummaryCardData(
        title: 'Produtividade',
        value: expectedYield.toStringAsFixed(1),
        subtitle: 't/ha',
        color: AbsorcaoNutrientesCores.greenAccent,
      ),
      SummaryCardData(
        title: 'Nutriente',
        value: selectedNutrient,
        subtitle: AbsorcaoNutrientesData.nutrientNames[selectedNutrient] ?? selectedNutrient,
        color: AbsorcaoNutrientesCores.greenMid,
      ),
      SummaryCardData(
        title: 'Qualidade do Dado',
        value: quality.title,
        subtitle: quality.subtitle,
        color: quality.color,
      ),
    ];

    return AbsorcaoCardWrapper(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: cards
            .map(
              (card) => SizedBox(
                width: 156,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E5E7)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x080D2818),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 3,
                        width: 56,
                        decoration: BoxDecoration(
                          color: card.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card.title,
                        style: AppTextStyles.caption.copyWith(
                          color: AbsorcaoNutrientesCores.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.value,
                        style: AppTextStyles.value.copyWith(
                          color: AbsorcaoNutrientesCores.greenDark,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.subtitle,
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
