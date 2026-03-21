import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_card.dart';

class HistoricoPage extends HookConsumerWidget {
  const HistoricoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usamos state local (useState) para mockar a lista de historico e conseguir excluir.
    final mockData = useState<List<Map<String, dynamic>>>([
      {
        'id': '1',
        'titulo': 'Talhão 3 - Norte',
        'cultura': 'Soja',
        'data': '10/03/2026',
        'status': 'Completo',
      },
      {
        'id': '2',
        'titulo': 'Talhão 1 - Base',
        'cultura': 'Milho',
        'data': '01/03/2026',
        'status': 'Rascunho',
      },
    ]);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Histórico'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filtros no topo (igual tela Analise)
            Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecond),
                          const SizedBox(width: 8),
                          Text('Todas as datas', style: AppTextStyles.body),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.filter_list, color: AppColors.primary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.md),

            // Lista 
            Expanded(
              child: mockData.value.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
                      itemCount: mockData.value.length,
                      itemBuilder: (context, index) {
                        final item = mockData.value[index];
                        final isCompleto = item['status'] == 'Completo';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimens.md),
                          child: Dismissible(
                            key: Key(item['id'] as String),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Excluir Análise?'),
                                  content: const Text('Essa ação não pode ser desfeita.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => ctx.pop(false),
                                      child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecond)),
                                    ),
                                    TextButton(
                                      onPressed: () => ctx.pop(true),
                                      child: const Text('Excluir', style: TextStyle(color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) {
                              final current = List<Map<String, dynamic>>.from(mockData.value);
                              current.removeAt(index);
                              mockData.value = current;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Análise excluída.', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.primaryDark),
                              );
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            child: AppCard(
                              onTap: () {
                                // Exemplo de navegação mockada ao dar Tap - vai pro LAB testar
                                context.push(AppRoutes.lab);
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['titulo'] as String, style: AppTextStyles.label.copyWith(fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item['cultura']} • ${item['data']}',
                                          style: AppTextStyles.caption.copyWith(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isCompleto ? AppColors.success.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      item['status'] as String,
                                      style: AppTextStyles.caption.copyWith(
                                        color: isCompleto ? AppColors.success : AppColors.textSecond,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 80,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppDimens.section),
          Text(
            'Histórico vazio',
            style: AppTextStyles.headline.copyWith(color: AppColors.textSecond),
          ),
          const SizedBox(height: 8),
          Text(
            'Você ainda não possui análises salvas.',
            style: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
