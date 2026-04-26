import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';

/// Header de cada coluna de análise (amostra N).
/// Exibe título e botão de remover.
class AnaliseColumnHeader extends StatelessWidget {
  final double width;
  final int index;
  final bool canRemove;
  final VoidCallback? onRemove;

  const AnaliseColumnHeader({
    super.key,
    required this.width,
    required this.index,
    this.canRemove = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          left: BorderSide(color: AppColors.border, width: 0.5),
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'A${index + 1}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (canRemove && onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close,
                size: 14,
                color: Color(0xFF86868B),
              ),
            ),
        ],
      ),
    );
  }
}
