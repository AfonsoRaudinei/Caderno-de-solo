import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';
import 'package:soloforte/features/historico/presentation/historico_card_widget.dart';
import 'package:soloforte/features/historico/presentation/historico_provider.dart';

class HistoricoPage extends ConsumerWidget {
  const HistoricoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historicoAsync = ref.watch(historicoProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune),
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: SafeArea(
        child: historicoAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: AppCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 36,
                    ),
                    const SizedBox(height: AppDimens.sm),
                    Text(
                      'Erro ao carregar histórico',
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: AppDimens.xs),
                    Text(
                      '$err',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppDimens.sm),
                    TextButton(
                      onPressed: () => ref.invalidate(historicoProvider),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data: (itens) {
            if (itens.isEmpty) {
              return _EmptyState();
            }

            final grupos = _agruparPorMes(itens);
            final chaves = grupos.keys.toList(growable: false);

            return RefreshIndicator(
              onRefresh: () => ref.read(historicoProvider.notifier).refresh(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.lg,
                  AppDimens.md,
                  AppDimens.lg,
                  AppDimens.xl,
                ),
                itemCount: chaves.length,
                itemBuilder: (context, index) {
                  final chave = chaves[index];
                  final lista = grupos[chave] ?? const <RecomendacaoModel>[];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppDimens.sm),
                        child: Text(
                          chave.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            letterSpacing: 0.5,
                            color: const Color(0xFF86868B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ...lista.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppDimens.md),
                          child: HistoricoCardWidget(recomendacao: item),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Map<String, List<RecomendacaoModel>> _agruparPorMes(
    List<RecomendacaoModel> itens,
  ) {
    final grupos = <String, List<RecomendacaoModel>>{};

    for (final item in itens) {
      final data = item.createdAt ?? DateTime.now();
      final chave = '${_mesPtBr(data.month)} ${data.year}';
      grupos.putIfAbsent(chave, () => <RecomendacaoModel>[]).add(item);
    }

    return grupos;
  }

  String _mesPtBr(int mes) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    if (mes < 1 || mes > 12) return 'Mês';
    return meses[mes - 1];
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 72,
              color: AppColors.textTertiary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppDimens.md),
            Text(
              'Nenhuma recomendação salva ainda',
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(fontSize: 18),
            ),
            const SizedBox(height: AppDimens.xs),
            Text(
              'Gere uma recomendação na aba Lab',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecond),
            ),
          ],
        ),
      ),
    );
  }
}
