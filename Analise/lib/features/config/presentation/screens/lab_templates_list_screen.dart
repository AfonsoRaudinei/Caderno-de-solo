import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/domain/entities/lab_template.dart';
import 'package:soloforte/features/config/presentation/controllers/lab_template_controller.dart';

class LabTemplatesListScreen extends ConsumerWidget {
  const LabTemplatesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(labTemplatesProvider);
    final palette = context.appPalette;

    return Scaffold(
      backgroundColor: palette.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: palette.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 96,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
              title: Text(
                'Modelos de Laboratório',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              background: ColoredBox(color: palette.background),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => context.push(AppRoutes.configLabTemplateEdit),
                icon: const Icon(CupertinoIcons.add, size: 16),
                label: const Text('Novo'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _buildContent(context, ref, state),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    WidgetRef ref,
    LabTemplatesState state,
  ) {
    if (state.isLoading) {
      return [
        const SizedBox(height: 80),
        const Center(child: CupertinoActivityIndicator()),
      ];
    }

    if (state.error != null) {
      return [
        const SizedBox(height: 80),
        Center(child: Text('Erro: ${state.error}')),
      ];
    }

    final padrao = state.templates.where((t) => t.isDefault).toList();
    final custom = state.templates.where((t) => !t.isDefault).toList();

    return [
      // Banner explicativo
      AppSurface(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(14),
        color: AppColors.primary.withValues(alpha: 0.08),
        showBorder: true,
        child: const Row(
          children: [
            Icon(CupertinoIcons.info_circle,
                size: 18, color: AppColors.primary),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Templates definem unidades e campos esperados de cada '
                'laboratório, garantindo importação correta dos PDFs.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),

      // Templates padrão
      _sectionHeader('PADRÃO'),
      const SizedBox(height: 8),
      ...padrao.map((t) => _TemplateCard(
            template: t,
            onTap: () => context.push(
              AppRoutes.configLabTemplateEdit,
              extra: t,
            ),
          )),

      // Templates personalizados
      if (custom.isNotEmpty) ...[
        const SizedBox(height: 20),
        _sectionHeader('PERSONALIZADOS'),
        const SizedBox(height: 8),
        ...custom.map((t) => _TemplateCard(
              template: t,
              onTap: () => context.push(
                AppRoutes.configLabTemplateEdit,
                extra: t,
              ),
              onDelete: () => _confirmarExclusao(context, ref, t),
            )),
      ],

      const SizedBox(height: 20),

      // Botão adicionar
      _BotaoNovoTemplate(
        onTap: () => context.push(AppRoutes.configLabTemplateEdit),
      ),
    ];
  }

  Widget _sectionHeader(String titulo) => Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Text(
          titulo,
          style: AppTextStyles.sectionLabel.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      );

  Future<void> _confirmarExclusao(
    BuildContext context,
    WidgetRef ref,
    LabTemplate template,
  ) async {
    final confirmar = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Excluir template?'),
        content: Text(
          'O template "${template.nome}" será removido permanentemente. '
          'Análises já importadas não serão afetadas.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await ref.read(labTemplatesProvider.notifier).delete(template.id);
    }
  }
}

// ── Cards ────────────────────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  final LabTemplate template;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _TemplateCard({
    required this.template,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppSurface(
        onTap: onTap,
        showBorder: true,
        child: Row(
          children: [
            const AppIconFrame(
              icon: CupertinoIcons.lab_flask,
              size: AppDimens.listIconSize,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        template.nome,
                        style: AppTextStyles.label.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                      if (template.isDefault) const _Badge(label: 'Padrão'),
                      if (!template.ativo)
                        const _Badge(
                          label: 'Inativo',
                          color: Color(0xFF86868B),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _descricaoUnidades(template),
                    style: AppTextStyles.caption.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onDelete != null && !template.isDefault)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onDelete,
                    minimumSize: const Size(32, 32),
                    child: const Icon(
                      CupertinoIcons.delete,
                      color: Color(0xFFFF3B30),
                      size: 18,
                    ),
                  ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: palette.textTertiary,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _descricaoUnidades(LabTemplate t) {
    final nutrientes = t.unidadeK.label;
    final mo = t.unidadeMO.label;
    return 'K, Ca, Mg: $nutrientes  •  M.O.: $mo';
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color? color;

  const _Badge({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: c,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BotaoNovoTemplate extends StatelessWidget {
  final VoidCallback onTap;
  const _BotaoNovoTemplate({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      onTap: onTap,
      showBorder: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.add_circled,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Adicionar Modelo Personalizado',
            style: AppTextStyles.label.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
