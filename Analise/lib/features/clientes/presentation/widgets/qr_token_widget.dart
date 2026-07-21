import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_card.dart';

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
    return AppCard(
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: token,
              size: 160,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(color: AppColors.textPrimary),
              dataModuleStyle:
                  const QrDataModuleStyle(color: AppColors.textPrimary),
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
