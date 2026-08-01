import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';

class HistoricoCardWidget extends StatelessWidget {
  const HistoricoCardWidget({super.key, required this.recomendacao});

  final RecomendacaoModel recomendacao;

  @override
  Widget build(BuildContext context) {
    final isCompleto = recomendacao.createdAt != null;
    final dataFmt = DateFormat('dd/MM/yyyy HH:mm')
        .format(recomendacao.createdAt ?? DateTime.now());

    return AppSurface(
      borderRadius: AppDimens.radiusXl,
      padding: const EdgeInsets.all(AppDimens.lg),
      onTap: () => context.push('/historico/detalhe', extra: recomendacao),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIconFrame(
                icon: Icons.receipt_long_rounded,
                size: 40,
                iconSize: 22,
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Text(
                  'Talhão não informado',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StatusPill(isCompleto: isCompleto),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Text(
              '${recomendacao.cultura.isEmpty ? 'Cultura n/d' : recomendacao.cultura} · Safra n/d',
              style: AppTextStyles.caption.copyWith(
                fontSize: 13,
                color: AppColors.textSecond,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              _DoseChip(
                label: 'Calcário',
                valor: '${recomendacao.doseCalcario.toStringAsFixed(1)} t/ha',
                fg: AppColors.primary,
              ),
              const SizedBox(width: AppDimens.sm),
              _DoseChip(
                label: 'P₂O₅',
                valor: '${recomendacao.p2o5.toStringAsFixed(1)} kg/ha',
                fg: AppColors.success,
              ),
              const SizedBox(width: AppDimens.sm),
              _DoseChip(
                label: 'K₂O',
                valor: '${recomendacao.k2o.toStringAsFixed(1)} kg/ha',
                fg: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            'Gerado em $dataFmt · Calibração: ${recomendacao.citacaoCalagem.metodo}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecond,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isCompleto});

  final bool isCompleto;

  @override
  Widget build(BuildContext context) {
    final fg = isCompleto ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isCompleto ? 'Completo' : 'Rascunho',
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DoseChip extends StatelessWidget {
  const _DoseChip({
    required this.label,
    required this.valor,
    required this.fg,
  });

  final String label;
  final String valor;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: fg.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: fg,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              valor,
              style: AppTextStyles.label.copyWith(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
