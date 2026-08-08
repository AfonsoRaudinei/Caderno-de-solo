import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';

/// Célula esquerda (sticky) da tabela de análise.
/// Exibe nome do parâmetro + unidade.
class AnaliseLabelCell extends StatelessWidget {
  final String label;
  final String? unit;
  final double width;

  const AnaliseLabelCell({
    super.key,
    required this.label,
    this.unit,
    this.width = 152,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        border: Border(
          right: BorderSide(color: palette.border, width: 0.5),
          bottom: BorderSide(color: palette.border, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
              height: 1.2,
            ),
          ),
          if (unit != null && unit!.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              unit!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: palette.textSecondary.withValues(alpha: 0.8),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
