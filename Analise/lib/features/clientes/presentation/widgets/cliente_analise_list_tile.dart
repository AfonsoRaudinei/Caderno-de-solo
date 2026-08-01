import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/presentation/utils/analise_card_labels.dart';
import 'package:soloforte/features/clientes/presentation/widgets/analise_vinculo_badge.dart';

class ClienteAnaliseListTile extends StatelessWidget {
  const ClienteAnaliseListTile({
    super.key,
    required this.analise,
    required this.onTap,
  });

  final AnaliseSolo analise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final labels = buildAmostraCardLabels(analise);
    final showBadge = analiseExibeVinculoPendente(analise);

    return AppSurface(
      margin: const EdgeInsets.only(bottom: 10),
      showBorder: true,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconFrame(
            icon: Icons.science_outlined,
            size: 44,
            iconColor: analise.cultura.color,
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        labels.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (showBadge) ...[
                      const SizedBox(width: 8),
                      const AnaliseVinculoBadge(),
                    ],
                  ],
                ),
                if (labels.subtitulo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    labels.subtitulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ],
                if (labels.detalhe.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    labels.detalhe,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: palette.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: palette.textTertiary,
          ),
        ],
      ),
    );
  }
}
