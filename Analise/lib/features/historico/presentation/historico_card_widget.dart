import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';

class HistoricoCardWidget extends StatelessWidget {
  const HistoricoCardWidget({super.key, required this.recomendacao});

  final RecomendacaoModel recomendacao;

  @override
  Widget build(BuildContext context) {
    final isCompleto = recomendacao.createdAt != null;
    final dataFmt = DateFormat('dd/MM/yyyy HH:mm')
        .format(recomendacao.createdAt ?? DateTime.now());

    return AppCard(
      borderRadius: 12,
      onTap: () => context.push('/historico/detalhe', extra: recomendacao),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleto
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isCompleto ? 'Completo' : 'Rascunho',
                  style: AppTextStyles.caption.copyWith(
                    color: isCompleto
                        ? const Color(0xFF34C759)
                        : const Color(0xFFD97706),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${recomendacao.cultura.isEmpty ? 'Cultura n/d' : recomendacao.cultura} · Safra n/d',
            style: AppTextStyles.caption.copyWith(
              fontSize: 13,
              color: const Color(0xFF86868B),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _DoseChip(
                label: 'Calcário',
                valor: '${recomendacao.doseCalcario.toStringAsFixed(1)} t/ha',
                bg: const Color(0xFFEEF4FF),
                fg: const Color(0xFF007AFF),
              ),
              const SizedBox(width: 8),
              _DoseChip(
                label: 'P₂O₅',
                valor: '${recomendacao.p2o5.toStringAsFixed(1)} kg/ha',
                bg: const Color(0xFFE8F5E9),
                fg: const Color(0xFF34C759),
              ),
              const SizedBox(width: 8),
              _DoseChip(
                label: 'K₂O',
                valor: '${recomendacao.k2o.toStringAsFixed(1)} kg/ha',
                bg: const Color(0xFFFFF3E0),
                fg: const Color(0xFFD97706),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Gerado em $dataFmt · Calibração: ${recomendacao.citacaoCalagem.metodo}',
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF86868B),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoseChip extends StatelessWidget {
  const _DoseChip({
    required this.label,
    required this.valor,
    required this.bg,
    required this.fg,
  });

  final String label;
  final String valor;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
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
