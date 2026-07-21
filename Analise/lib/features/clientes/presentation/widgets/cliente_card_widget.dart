import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';

class ClienteCardWidget extends StatelessWidget {
  const ClienteCardWidget({
    super.key,
    required this.cliente,
    required this.onTap,
  });

  final ClienteEntity cliente;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cliente.nome,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cliente.cidade} — ${cliente.estado}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecond,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cliente.fazendas.length} fazendas · token ${cliente.token}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecond,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecond,
          ),
        ],
      ),
    );
  }
}
