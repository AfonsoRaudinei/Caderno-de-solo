import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_card.dart';
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
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Row(
              children: [
                const Icon(
                  Icons.agriculture_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fazenda.nome,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${_formatArea(fazenda.areaTotal)} ha',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecond,
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
                  for (var index = 0;
                      index < fazenda.talhoes.length;
                      index++) ...[
                    TalhaoRowWidget(
                      talhao: fazenda.talhoes[index],
                      onTap: () => onTapTalhao(fazenda.talhoes[index]),
                    ),
                    if (index != fazenda.talhoes.length - 1)
                      const Divider(color: AppColors.borderSoft),
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
