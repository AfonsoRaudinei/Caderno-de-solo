import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
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
    final palette = context.appPalette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.crop_square_rounded,
              size: 18,
              color: palette.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    talhao.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if ((talhao.culturaPrincipal ?? '').isNotEmpty)
                    Text(
                      talhao.culturaPrincipal!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_formatArea(talhao.area)} ha',
              style: AppTextStyles.caption.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w700,
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
