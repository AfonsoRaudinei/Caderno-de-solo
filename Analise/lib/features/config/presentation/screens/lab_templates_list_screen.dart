import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/domain/entities/lab_template.dart';
import 'package:soloforte/features/config/presentation/controllers/lab_template_controller.dart';

class LabTemplatesListScreen extends ConsumerWidget {
  const LabTemplatesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(labTemplatesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFF5F5F7),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 96,
            flexibleSpace: const FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20, bottom: 14),
              title: Text(
                'Modelos de Laboratório',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1F),
                  letterSpacing: -0.3,
                ),
              ),
              background: ColoredBox(color: Color(0xFFF5F5F7)),
            ),
            actions: [
              TextButton.icon(
                onPressed: () =>
                    context.push(AppRoutes.configLabTemplateEdit),
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
      Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(CupertinoIcons.info_circle, size: 18, color: AppColors.primary),
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
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Color(0xFF86868B),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Ícone
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.lab_flask,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),

              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          template.nome,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D1D1F),
                          ),
                        ),
                        if (template.isDefault) ...[
                          const SizedBox(width: 6),
                          const _Badge(label: 'Padrão'),
                        ],
                        if (!template.ativo) ...[
                          const SizedBox(width: 6),
                          const _Badge(
                            label: 'Inativo',
                            color: Color(0xFF86868B),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _descricaoUnidades(template),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF86868B),
                      ),
                    ),
                  ],
                ),
              ),

              // Ações
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onDelete != null && !template.isDefault)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: onDelete, minimumSize: const Size(32, 32),
                      child: const Icon(
                        CupertinoIcons.delete,
                        color: Color(0xFFFF3B30),
                        size: 18,
                      ),
                    ),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    color: Color(0xFFC7C7CC),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
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
        color: c.withOpacity(0.10),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withOpacity(0.30),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.add_circled, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              'Adicionar Modelo Personalizado',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
