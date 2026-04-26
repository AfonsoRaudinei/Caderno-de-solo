// calibracao_seletor_page.dart
//
// Tela de seleção de calibração — exibe um grid estilo iOS com cards para cada
// perfil salvo, mais um card fixo "Nova calibragem" ao final.
// Ao tocar em um card, navega para CalibracaoPage (formulário de edição).
// Long press exibe menu contextual: Editar, Duplicar, Excluir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_state.dart';

class CalibracaoSeletorPage extends ConsumerWidget {
  const CalibracaoSeletorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calibracaoControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        backgroundColor: AppColors.bgSecondary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Calibração',
          style: AppTextStyles.headline.copyWith(color: AppColors.primary),
        ),
        centerTitle: false,
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : _buildGrid(context, ref, state),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    WidgetRef ref,
    CalibracaoState state,
  ) {
    // Lista de itens: perfis salvos + sentinela "nova calibragem" ao final
    final profiles = state.profiles;
    final itemCount = profiles.length + 1; // +1 para o card "Nova calibragem"

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < profiles.length) {
          return _CalibracaoCard(
            profile: profiles[index],
            onTap: () => _abrirEdicao(context, ref, profiles[index]),
            onEditar: () => _abrirEdicao(context, ref, profiles[index]),
            onDuplicar: () => _duplicar(ref, profiles[index]),
            onExcluir: () => _confirmarExclusao(context, ref, profiles[index]),
          );
        }
        // Último card: "Nova calibragem"
        return _NovaCalibracaoCard(
          onTap: () => _novaCalibracaoEBranco(context, ref),
        );
      },
    );
  }

  void _abrirEdicao(
    BuildContext context,
    WidgetRef ref,
    CalibracaoProfile profile,
  ) {
    ref.read(calibracaoControllerProvider.notifier).carregarPerfil(profile);
    context.push(AppRoutes.labCalibracaoEditar);
  }

  void _novaCalibracaoEBranco(BuildContext context, WidgetRef ref) {
    ref.read(calibracaoControllerProvider.notifier).novaCalibracaoEmBranco();
    context.push(AppRoutes.labCalibracaoEditar);
  }

  void _duplicar(WidgetRef ref, CalibracaoProfile profile) {
    ref.read(calibracaoControllerProvider.notifier).carregarPerfil(profile);
    ref.read(calibracaoControllerProvider.notifier).duplicarSelecionado();
  }

  Future<void> _confirmarExclusao(
    BuildContext context,
    WidgetRef ref,
    CalibracaoProfile profile,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir calibração'),
        content: Text(
          'Tem certeza que deseja excluir "${profile.nome.isEmpty ? 'Sem nome' : profile.nome}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      ref.read(calibracaoControllerProvider.notifier).carregarPerfil(profile);
      await ref.read(calibracaoControllerProvider.notifier).excluirSelecionado();
    }
  }
}

// ─── Card de calibração salva ───────────────────────────────────────────────

class _CalibracaoCard extends StatelessWidget {
  const _CalibracaoCard({
    required this.profile,
    required this.onTap,
    required this.onEditar,
    required this.onDuplicar,
    required this.onExcluir,
  });

  final CalibracaoProfile profile;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onDuplicar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final nome = profile.nome.isEmpty ? 'Sem nome' : profile.nome;
    final cultura = profile.cultura;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.extension,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                nome,
                style: AppTextStyles.label.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (cultura.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  cultura,
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showContextMenu(BuildContext context) async {
    final RenderBox card = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        card.localToGlobal(Offset.zero, ancestor: overlay),
        card.localToGlobal(
          card.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      items: const [
        PopupMenuItem(value: 'editar', child: Text('Editar')),
        PopupMenuItem(value: 'duplicar', child: Text('Duplicar')),
        PopupMenuItem(
          value: 'excluir',
          child: Text('Excluir', style: TextStyle(color: Colors.red)),
        ),
      ],
    );

    if (result == 'editar') onEditar();
    if (result == 'duplicar') onDuplicar();
    if (result == 'excluir') onExcluir();
  }
}

// ─── Card "Nova calibragem" ─────────────────────────────────────────────────

class _NovaCalibracaoCard extends StatelessWidget {
  const _NovaCalibracaoCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD1D1D6),
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle,
                size: 48,
                color: Color(0xFF34C759), // verde iOS
              ),
              const SizedBox(height: 8),
              Text(
                'Nova calibragem',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF86868B),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
