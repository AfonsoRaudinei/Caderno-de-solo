import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/absorcao_nutrientes_models.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/widgets/absorcao_card_wrapper.dart';

/// Card de tabela de referência da tela de absorção de nutrientes.
/// Extraído de absorcao_nutrientes_referencia_page.dart (_buildReferenceTableCard) — FASE 3.
class AbsorcaoReferenceTableCard extends StatelessWidget {
  const AbsorcaoReferenceTableCard({
    super.key,
    required this.card,
  });

  final ReferenceTableCardData card;

  @override
  Widget build(BuildContext context) {
    return AbsorcaoCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  card.title,
                  style: AppTextStyles.label.copyWith(fontSize: 15),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  card.unit,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            card.description,
            style: AppTextStyles.caption.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 10),
          ...card.rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: AppTextStyles.caption.copyWith(fontSize: 12),
                    ),
                  ),
                  Text(
                    row.value,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(
                Icons.table_rows_outlined,
                size: 14,
                color: AppColors.textSecond,
              ),
              const SizedBox(width: 4),
              Text(
                'Tabela de referência',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecond,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
