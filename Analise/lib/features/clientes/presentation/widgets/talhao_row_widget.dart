import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';

class TalhaoRowWidget extends StatelessWidget {
  const TalhaoRowWidget({
    super.key,
    required this.talhao,
    required this.onTap,
  });

  final TalhaoEntity talhao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasGps = talhao.latitude != null && talhao.longitude != null;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(
              Icons.crop_square_rounded,
              size: 18,
              color: AppColors.textSecond,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    talhao.nome,
                    style: AppTextStyles.label,
                  ),
                  if ((talhao.culturaPrincipal ?? '').isNotEmpty)
                    Text(
                      talhao.culturaPrincipal!,
                      style: AppTextStyles.caption,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_formatArea(talhao.area)} ha',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.circle,
              size: 10,
              color: hasGps ? AppColors.success : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatArea(double value) {
    return value
        .toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)
        .replaceAll('.', ',');
  }
}
