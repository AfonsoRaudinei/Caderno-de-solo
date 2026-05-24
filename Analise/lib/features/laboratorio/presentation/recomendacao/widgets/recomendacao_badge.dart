import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';

/// Badge visual reutilizável nas seções de recomendação.
/// Extraído de _Badge (calcario_gesso_section, fosforo_section, potassio_section).
class RecomendacaoBadge extends StatelessWidget {
  const RecomendacaoBadge({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
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
