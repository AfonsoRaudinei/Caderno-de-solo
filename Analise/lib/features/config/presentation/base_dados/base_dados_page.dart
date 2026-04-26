import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/data/base_dados/referencias_tecnicas_data.dart';

class BaseDadosPage extends StatelessWidget {
  const BaseDadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    const referencias = referenciasTecnicasPadrao;

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Referências Técnicas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(AppRoutes.labRefNova),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: referencias.isEmpty
          ? const Center(child: Text('Nenhuma referência.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: referencias.length,
              itemBuilder: (context, index) {
                final ref = referencias[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push(
                      AppRoutes.labRefDetalhes,
                      extra: ref,
                    ),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref.nome,
                            style: AppTextStyles.label.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${ref.tipo} • Ano: ${ref.ano} • Fórmula: ${ref.formulaAssociada}',
                            style: AppTextStyles.caption.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(ref.resumo, style: AppTextStyles.body),
                          const SizedBox(height: 10),
                          Text(
                            'Toque para abrir o conteúdo completo',
                            style: AppTextStyles.caption.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
