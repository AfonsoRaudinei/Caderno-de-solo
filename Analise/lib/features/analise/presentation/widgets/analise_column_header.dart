import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';

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
    final palette = context.appPalette;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        border: Border(
          left: BorderSide(color: palette.border, width: 0.5),
          bottom: BorderSide(color: palette.border, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'A${index + 1}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (canRemove && onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 14,
                color: palette.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
