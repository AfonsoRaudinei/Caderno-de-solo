import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';

class ClienteCardWidget extends StatelessWidget {
  const ClienteCardWidget({
    super.key,
    required this.cliente,
    required this.onTap,
  });

  final ClienteEntity cliente;
  final VoidCallback onTap;

  String get _displayName {
    final nome = cliente.nome.trim();
    return nome.isEmpty ? 'Cliente sem nome' : nome;
  }

  String get _displayLocation {
    final cidade = cliente.cidade.trim();
    final estado = cliente.estado.trim();
    if (cidade.isEmpty && estado.isEmpty) {
      return 'Localização não informada';
    }
    if (cidade.isEmpty) return estado;
    if (estado.isEmpty) return cidade;
    return '$cidade — $estado';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final analisesCount = cliente.analiseIds.length;

    return AppSurface(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      showBorder: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppIconFrame(
            icon: Icons.person_outline_rounded,
            size: AppDimens.listIconSize,
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  style: AppTextStyles.label.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _displayLocation,
                  style: AppTextStyles.caption.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cliente.fazendas.length} fazendas · token ${cliente.token}',
                  style: AppTextStyles.caption.copyWith(
                    color: palette.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _AnalisesCountBadge(count: analisesCount),
              const SizedBox(height: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: palette.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalisesCountBadge extends StatelessWidget {
  const _AnalisesCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(
        '$count',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
