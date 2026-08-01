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
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_state.dart';

class CalibracaoSeletorPage extends ConsumerWidget {
  const CalibracaoSeletorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calibracaoControllerProvider);

    return Scaffold(
      appBar: AppBar(
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
      await ref
          .read(calibracaoControllerProvider.notifier)
          .excluirSelecionado();
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

  static const String _iconPath = 'assets/icons/calibracao.png';

  final CalibracaoProfile profile;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onDuplicar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final nome = profile.nome.isEmpty ? 'Sem nome' : profile.nome;
    final cultura = profile.cultura;

    return AppSurface(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppIconFrame(
            assetPath: _iconPath,
            size: AppDimens.cardIconSize,
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            nome,
            style: AppTextStyles.label.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (cultura.isNotEmpty) ...[
            const SizedBox(height: AppDimens.xs),
            Text(
              cultura,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: palette.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
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

  static const String _iconPath = 'assets/icons/nova_calibracao.png';

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AppSurface(
      onTap: onTap,
      showBorder: true,
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppIconFrame(
            assetPath: _iconPath,
            size: AppDimens.cardIconSize,
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(height: AppDimens.sm),
          Text(
            'Nova calibragem',
            style: AppTextStyles.caption.copyWith(
              fontSize: 13,
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
