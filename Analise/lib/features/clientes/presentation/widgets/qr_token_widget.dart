import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';

class QrTokenWidget extends StatelessWidget {
  const QrTokenWidget({
    super.key,
    required this.token,
    required this.onCompartilhar,
    required this.onCopiar,
  });

  final String token;
  final VoidCallback onCompartilhar;
  final VoidCallback onCopiar;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final qrBackground = palette.isDark ? palette.card : Colors.white;
    final qrModuleColor =
        palette.isDark ? palette.textPrimary : AppColors.textPrimary;

    return AppSurface(
      showBorder: true,
      child: Column(
        children: [
          Text(
            'TOKEN DE ACESSO',
            style: AppTextStyles.sectionLabel.copyWith(
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            token,
            style: AppTextStyles.value.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: qrBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: token,
              size: 160,
              backgroundColor: qrBackground,
              eyeStyle: QrEyeStyle(color: qrModuleColor),
              dataModuleStyle: QrDataModuleStyle(color: qrModuleColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButtonText(
                label: 'Compartilhar',
                onPressed: onCompartilhar,
              ),
              const SizedBox(width: 16),
              AppButtonText(
                label: 'Copiar',
                onPressed: onCopiar,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
