import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/data/base_dados/referencias_tecnicas_data.dart';

class BaseDadosPage extends StatelessWidget {
  const BaseDadosPage({super.key});

  static const String _iconPath = 'assets/icons/referencias_tecnicas.png';

  @override
  Widget build(BuildContext context) {
    const referencias = referenciasTecnicasPadrao;
    final palette = context.appPalette;

    return Scaffold(
      backgroundColor: palette.background,
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
                  child: AppSurface(
                    onTap: () => context.push(
                      AppRoutes.labRefDetalhes,
                      extra: ref,
                    ),
                    showBorder: true,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppIconFrame(
                          assetPath: _iconPath,
                          size: AppDimens.listIconSize,
                          backgroundColor: Colors.transparent,
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ref.nome,
                                style: AppTextStyles.label.copyWith(
                                  fontSize: 16,
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${ref.tipo} • Ano: ${ref.ano} • Fórmula: ${ref.formulaAssociada}',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 14,
                                  color: palette.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ref.resumo,
                                style: AppTextStyles.body.copyWith(
                                  color: palette.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Toque para abrir o conteúdo completo',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 12,
                                  color: palette.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
