import 'package:flutter/material.dart';
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
          Icon(
            Icons.chevron_right_rounded,
            color: palette.textTertiary,
          ),
        ],
      ),
    );
  }
}
