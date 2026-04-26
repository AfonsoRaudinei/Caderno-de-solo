import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_card.dart';

class CalibracaoFooterCard extends StatelessWidget {
  const CalibracaoFooterCard({
    super.key,
    required this.onSalvar,
    this.salvando = false,
    this.ultimaAtualizacao,
  });

  final VoidCallback onSalvar;
  final bool salvando;
  final DateTime? ultimaAtualizacao;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimens.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: AppDimens.buttonHeight,
            child: AppButton(
              label: 'Salvar',
              icon: Icons.save_outlined,
              isLoading: salvando,
              onPressed: onSalvar,
            ),
          ),
          const SizedBox(height: AppDimens.sm),
          if (ultimaAtualizacao != null)
            Text(
              'Última atualização: ${_formatDate(ultimaAtualizacao!)}',
              style: AppTextStyles.caption,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    return DateFormat('dd/MM/yyyy HH:mm').format(value);
  }
}
