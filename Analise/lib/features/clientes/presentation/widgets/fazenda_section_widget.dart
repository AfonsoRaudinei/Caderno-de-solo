import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';
import 'package:soloforte/features/clientes/presentation/widgets/talhao_row_widget.dart';

class FazendaSectionWidget extends StatelessWidget {
  const FazendaSectionWidget({
    super.key,
    required this.fazenda,
    required this.isExpanded,
    required this.onToggle,
    required this.onTapTalhao,
    required this.onAdicionarTalhao,
  });

  final FazendaEntity fazenda;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<TalhaoEntity> onTapTalhao;
  final VoidCallback onAdicionarTalhao;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AppSurface(
      margin: const EdgeInsets.only(bottom: 12),
      showBorder: true,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: Row(
              children: [
                const AppIconFrame(
                  icon: Icons.agriculture_outlined,
                  size: 44,
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fazenda.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label.copyWith(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimens.xs),
                      Text(
                        '${fazenda.talhoes.length} talhões',
                        style: AppTextStyles.caption.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.sm),
                Text(
                  '${_formatArea(fazenda.areaTotal)} ha',
                  style: AppTextStyles.caption.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  if (fazenda.talhoes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.sm),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Nenhum talhão cadastrado nesta fazenda.',
                          style: AppTextStyles.caption.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  for (var index = 0;
                      index < fazenda.talhoes.length;
                      index++) ...[
                    TalhaoRowWidget(
                      talhao: fazenda.talhoes[index],
                      onTap: () => onTapTalhao(fazenda.talhoes[index]),
                    ),
                    if (index != fazenda.talhoes.length - 1)
                      Divider(color: palette.border),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppButtonText(
                      label: '+ Adicionar Talhão',
                      onPressed: onAdicionarTalhao,
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  String _formatArea(double value) {
    return value
        .toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)
        .replaceAll('.', ',');
  }
}
