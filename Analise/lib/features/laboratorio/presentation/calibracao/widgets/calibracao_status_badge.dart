import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';

/// Badge com ícone, cor e label.
/// Extraído de calibracao_page.dart (_Badge).
/// Nota: recomendacao_screen.dart tem sua própria _Badge local — são independentes.
class CalibracaoStatusBadge extends StatelessWidget {
  const CalibracaoStatusBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
