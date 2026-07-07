import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';
import 'package:soloforte/features/historico/presentation/historico_provider.dart';

class HistoricoDetalheScreen extends ConsumerWidget {
  const HistoricoDetalheScreen({super.key, required this.recomendacao});

  final RecomendacaoModel recomendacao;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const titulo = 'Talhão não informado';
    final data = recomendacao.createdAt ?? DateTime.now();
    final dataFmt = DateFormat('dd/MM/yyyy HH:mm').format(data);

    return Scaffold(
      appBar: AppBar(
        title: const Text(titulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => Share.share(_buildShareText(recomendacao, titulo)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: const Color(0xFFFF3B30),
            onPressed: () => _confirmarExclusao(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NutrienteCard(
                titulo: 'Calcário',
                valor:
                    '${recomendacao.doseCalcario.toStringAsFixed(1)} t/ha (PRNT: ${recomendacao.prnt.toStringAsFixed(0)}%)',
              ),
              const SizedBox(height: AppDimens.md),
              _NutrienteCard(
                titulo: 'P₂O₅',
                valor: '${recomendacao.p2o5.toStringAsFixed(1)} kg/ha',
              ),
              const SizedBox(height: AppDimens.md),
              _NutrienteCard(
                titulo: 'K₂O',
                valor: '${recomendacao.k2o.toStringAsFixed(1)} kg/ha',
              ),
              const SizedBox(height: AppDimens.md),
              _NutrienteCard(
                titulo: 'Micronutrientes',
                valor: recomendacao.citacaoMicronutrientes.metodo,
              ),
              const SizedBox(height: AppDimens.lg),
              Text(
                'Calibração: ${recomendacao.citacaoCalagem.metodo} · Gerado em: $dataFmt',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.textSecond),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarExclusao(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir recomendação?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await ref.read(historicoProvider.notifier).deletar(recomendacao.id);

    if (!context.mounted) return;
    context.pop();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recomendação excluída')),
    );
  }

  String _buildShareText(RecomendacaoModel item, String talhao) {
    final dataFmt =
        DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt ?? DateTime.now());

    return '📋 Recomendação — $talhao\n'
        'Cultura: ${item.cultura.isEmpty ? 'N/D' : item.cultura}\n'
        '─────────────────────\n'
        '🪨 Calcário: ${item.doseCalcario.toStringAsFixed(1)} t/ha (PRNT: ${item.prnt.toStringAsFixed(0)}%)\n'
        '🌿 P₂O₅: ${item.p2o5.toStringAsFixed(1)} kg/ha\n'
        '🔶 K₂O: ${item.k2o.toStringAsFixed(1)} kg/ha\n'
        '─────────────────────\n'
        'Calibração: ${item.citacaoCalagem.metodo}\n'
        'Gerado em $dataFmt\n'
        'Caderno de Solo';
  }
}

class _NutrienteCard extends StatelessWidget {
  const _NutrienteCard({required this.titulo, required this.valor});

  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimens.xs),
          Text(valor, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
