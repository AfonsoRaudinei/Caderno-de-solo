import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

bool analiseExibeVinculoPendente(AnaliseSolo analise) {
  return !analise.possuiVinculoHierarquico ||
      analise.vinculoStatus == AnaliseVinculoStatus.pendente;
}

int contarAnalisesComVinculoPendente(List<AnaliseSolo> analises) {
  return analises.where(analiseExibeVinculoPendente).length;
}

class AnaliseVinculoBadge extends StatelessWidget {
  const AnaliseVinculoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Vínculo pendente',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.warning,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
