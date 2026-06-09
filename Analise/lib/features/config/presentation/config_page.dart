import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/features/config/application/providers/app_theme_mode_provider.dart';
import 'package:soloforte/features/config/domain/entities/config_action_exception.dart';
import 'package:soloforte/features/config/presentation/config_controller.dart';
import 'package:soloforte/features/config/application/providers/perfil_assets_provider.dart';

export 'package:soloforte/features/config/application/providers/perfil_assets_provider.dart'
    show PerfilAssets, PerfilAssetsNotifier, perfilAssetsProvider;

class _ConfigPalette {
  const _ConfigPalette({
    required this.background,
    required this.card,
    required this.cardStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderStrong,
    required this.shadow,
  });

  final Color background;
  final Color card;
  final Color cardStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color borderStrong;
  final Color shadow;

  static _ConfigPalette of(BuildContext context) {
    final isBlack = Theme.of(context).brightness == Brightness.dark;
    if (isBlack) {
      return _ConfigPalette(
        background: Colors.black,
        card: const Color(0xFF1C1C1E),
        cardStrong: const Color(0xFF2C2C2E),
        textPrimary: const Color(0xFFF2F2F7),
        textSecondary: const Color(0xFFAEAEB2),
        textTertiary: const Color(0xFF636366),
        border: const Color(0xFF2C2C2E),
        borderStrong: const Color(0xFF3A3A3C),
        shadow: Colors.black.withValues(alpha: 0.45),
      );
    }

    return _ConfigPalette(
      background: const Color(0xFFF5F5F7),
      card: Colors.white.withValues(alpha: 0.95),
      cardStrong: Colors.white,
      textPrimary: const Color(0xFF1D1D1F),
      textSecondary: const Color(0xFF86868B),
      textTertiary: const Color(0xFFC7C7CC),
      border: const Color(0xFFE5E5E7),
      borderStrong: const Color(0xFFD1D1D6),
      shadow: Colors.black.withValues(alpha: 0.06),
    );
  }
}

/// Bottom sheet iOS para edição de campo de texto.
Future<void> _showEditSheet(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String currentValue,
  required String firestoreField,
  String? placeholder,
}) async {
  final palette = _ConfigPalette.of(context);
  final controller =
      TextEditingController(text: currentValue == '—' ? '' : currentValue);

  await showCupertinoModalPopup<void>(
    context: context,
    builder: (sheetContext) => Container(
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ).copyWith(color: palette.textPrimary),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Color(0xFF86868B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: controller,
            autofocus: true,
            placeholder: placeholder ?? 'Digite $title',
            clearButtonMode: OverlayVisibilityMode.editing,
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: palette.borderStrong),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onSubmitted: (_) async {
              Navigator.of(sheetContext).pop();
              await ref
                  .read(configControllerProvider.notifier)
                  .updateProfileField(firestoreField, controller.text);
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                await ref
                    .read(configControllerProvider.notifier)
                    .updateProfileField(firestoreField, controller.text);
              },
              child: const Text('Salvar'),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showTipoPerfilSheet(BuildContext context, WidgetRef ref) async {
  const opcoes = [
    'Agrônomo',
    'Técnico Agrícola',
    'Produtor Rural',
    'Consultor',
  ];

  await showCupertinoModalPopup<void>(
    context: context,
    builder: (sheetContext) => CupertinoActionSheet(
      title: const Text('Tipo de Perfil'),
      actions: opcoes
          .map(
            (op) => CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.of(sheetContext).pop();
                await ref
                    .read(configControllerProvider.notifier)
                    .updateProfileField('tipoPerfil', op);
              },
              child: Text(op),
            ),
          )
          .toList(),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(sheetContext).pop(),
        child: const Text('Cancelar'),
      ),
    ),
  );
}

class ConfigPage extends ConsumerWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(configControllerProvider);
    final palette = _ConfigPalette.of(context);

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
                'Configurações',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              background: ColoredBox(color: palette.background),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _SectionLabel('PERFIL'),
                _CardSection(
                  children: [
                    profileAsync.when(
                      loading: () => const _ProfileSkeleton(),
                      error: (_, __) => _ProfileRows(
                        nome: '—',
                        email: '—',
                        tipo: '—',
                        empresa: '—',
                        pageContext: context,
                        ref: ref,
                      ),
                      data: (profile) => _ProfileRows(
                        nome: profile.nome,
                        email: profile.email,
                        tipo: profile.tipoPerfil,
                        empresa: profile.empresa,
                        pageContext: context,
                        ref: ref,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionLabel('IDENTIDADE VISUAL'),
                const _IdentidadeVisualCard(),
                const SizedBox(height: 24),
                const _SectionLabel('GERENCIAMENTO'),
                _CardSection(
                  children: [
                    const _ThemeModeRow(),
                    const _Divider(),
                    _ProfileChevronRow(
                      label: 'Modelos de Laboratório',
                      onTap: () => context.push(AppRoutes.configLabTemplates),
                    ),
                    const _Divider(),
                    _ProfileChevronRow(
                      label: 'Enviar Feedback',
                      onTap: () => context.push(AppRoutes.feedback),
                    ),
                    const _Divider(),
                    _ProfileChevronRow(
                      label: 'Limpar Dados Locais',
                      onTap: () async {
                        final confirmar = await showCupertinoDialog<bool>(
                          context: context,
                          builder: (dialogContext) => CupertinoAlertDialog(
                            title: const Text('Limpar dados locais?'),
                            content: const Text(
                              'Remove calibrações, laudos e preferências salvas no dispositivo. Seus dados na nuvem não serão afetados.',
                            ),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              CupertinoDialogAction(
                                isDestructiveAction: true,
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                child: const Text('Limpar'),
                              ),
                            ],
                          ),
                        );
                        if (confirmar != true || !context.mounted) return;
                        await ref
                            .read(configControllerProvider.notifier)
                            .limparDadosLocais();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Dados locais removidos com sucesso.'),
                            backgroundColor: Color(0xFF34C759),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionLabel('ZONA DE PERIGO'),
                _CardSection(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          // Passo 1: alerta de consequências
                          final prosseguir = await showCupertinoDialog<bool>(
                            context: context,
                            builder: (dialogContext) => CupertinoAlertDialog(
                              title:
                                  const Text('Excluir conta permanentemente?'),
                              content: const Text(
                                'Todos os seus dados, análises e configurações serão deletados e não poderão ser recuperados.',
                              ),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  child: const Text('Continuar'),
                                ),
                              ],
                            ),
                          );
                          if (prosseguir != true || !context.mounted) return;

                          // Passo 2: senha + EXCLUIR para confirmar
                          final confirmController = TextEditingController();
                          final passwordController = TextEditingController();
                          final confirmado = await showCupertinoDialog<bool>(
                            context: context,
                            builder: (dialogContext) => CupertinoAlertDialog(
                              title: const Text('Confirmação final'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Digite sua senha atual e EXCLUIR para confirmar:',
                                  ),
                                  const SizedBox(height: 12),
                                  CupertinoTextField(
                                    controller: passwordController,
                                    placeholder: 'Senha atual',
                                    obscureText: true,
                                    autofocus: true,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('Digite EXCLUIR para confirmar:'),
                                  const SizedBox(height: 12),
                                  CupertinoTextField(
                                    controller: confirmController,
                                    placeholder: 'EXCLUIR',
                                  ),
                                ],
                              ),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  onPressed: () {
                                    final ok = confirmController.text.trim() ==
                                            'EXCLUIR' &&
                                        passwordController.text.isNotEmpty;
                                    Navigator.of(dialogContext).pop(ok);
                                  },
                                  child: const Text('Excluir conta'),
                                ),
                              ],
                            ),
                          );
                          final password = passwordController.text;
                          confirmController.dispose();
                          passwordController.dispose();
                          if (confirmado != true || !context.mounted) return;

                          try {
                            await ref
                                .read(configControllerProvider.notifier)
                                .excluirConta(
                                  password: password,
                                );
                            if (context.mounted) context.go(AppRoutes.login);
                          } on ConfigActionException catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.message),
                                backgroundColor: const Color(0xFFFF3B30),
                              ),
                            );
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Erro ao excluir conta. Tente novamente.',
                                ),
                                backgroundColor: Color(0xFFFF3B30),
                              ),
                            );
                          }
                        },
                        child: const Row(
                          children: [
                            Icon(
                              CupertinoIcons.delete,
                              size: 18,
                              color: Color(0xFFFF3B30),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Excluir Conta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFFF3B30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _CardSection(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          final confirmar = await showCupertinoDialog<bool>(
                            context: context,
                            builder: (dialogContext) => CupertinoAlertDialog(
                              title: const Text('Sair da conta?'),
                              content: const Text(
                                'Você será desconectado do aplicativo.',
                              ),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  child: const Text('Sair'),
                                ),
                              ],
                            ),
                          );

                          if (confirmar != true) return;

                          try {
                            await ref
                                .read(configControllerProvider.notifier)
                                .logout();
                            if (context.mounted) {
                              context.go(AppRoutes.login);
                            }
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Erro ao sair. Tente novamente.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Sair da Conta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFF3B30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Analise v1.0.1',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentidadeVisualCard extends ConsumerWidget {
  const _IdentidadeVisualCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(perfilAssetsProvider);
    final notifier = ref.read(perfilAssetsProvider.notifier);
    final palette = _ConfigPalette.of(context);

    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _ImageUploadRow(
            title: 'Logomarca',
            subtitle: 'Aparece no cabeçalho das Recomendações',
            icon: CupertinoIcons.building_2_fill,
            imageUrl: assets.logoUrl,
            isUploading: assets.isUploadingLogo,
            onUpload: notifier.uploadLogo,
            onRemove: notifier.removeLogo,
            shape: _ImageShape.rectangle,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: palette.border),
          ),
          _ImageUploadRow(
            title: 'Assinatura',
            subtitle: 'Foto da assinatura manuscrita para o Laudo',
            icon: CupertinoIcons.signature,
            imageUrl: assets.assinaturaUrl,
            isUploading: assets.isUploadingAssinatura,
            onUpload: notifier.uploadAssinatura,
            onRemove: notifier.removeAssinatura,
            shape: _ImageShape.wide,
          ),
        ],
      ),
    );
  }
}

enum _ImageShape { rectangle, wide }

class _ImageUploadRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? imageUrl;
  final bool isUploading;
  final Future<bool> Function() onUpload;
  final Future<bool> Function() onRemove;
  final _ImageShape shape;

  const _ImageUploadRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.imageUrl,
    required this.isUploading,
    required this.onUpload,
    required this.onRemove,
    required this.shape,
  });

  void _showSnack(BuildContext context, String message,
      {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  Future<void> _runAction(
    BuildContext context,
    Future<bool> Function() action, {
    required String successMessage,
  }) async {
    try {
      final changed = await action();
      if (!context.mounted || !changed) return;
      _showSnack(context, successMessage);
    } catch (error) {
      if (!context.mounted) return;
      final raw = error.toString();
      final msg = raw.startsWith('Exception: ') ? raw.substring(11) : raw;
      _showSnack(context, msg, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final palette = _ConfigPalette.of(context);

    final double thumbW = shape == _ImageShape.wide ? 80 : 52;
    final double thumbH = shape == _ImageShape.wide ? 40 : 52;
    final double radius = shape == _ImageShape.wide ? 6 : 8;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: isUploading
                ? null
                : () => _runAction(
                      context,
                      onUpload,
                      successMessage: '$title enviada com sucesso.',
                    ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: thumbW,
              height: thumbH,
              decoration: BoxDecoration(
                color: palette.cardStrong,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: hasImage
                      ? const Color(0xFF007AFF).withValues(alpha: 0.3)
                      : palette.borderStrong,
                  width: hasImage ? 1.5 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius - 1),
                child: isUploading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      )
                    : hasImage
                        ? Image.network(
                            imageUrl!,
                            fit: shape == _ImageShape.wide
                                ? BoxFit.contain
                                : BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              icon,
                              size: 22,
                              color: palette.textTertiary,
                            ),
                          )
                        : Icon(
                            icon,
                            size: 22,
                            color: palette.textTertiary,
                          ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionChip(
                label: hasImage ? 'Trocar' : 'Adicionar',
                color: const Color(0xFF007AFF),
                onTap: isUploading
                    ? null
                    : () => _runAction(
                          context,
                          onUpload,
                          successMessage: '$title enviada com sucesso.',
                        ),
              ),
              if (hasImage) ...[
                const SizedBox(width: 6),
                _ActionChip(
                  label: 'Remover',
                  color: const Color(0xFFFF3B30),
                  onTap: isUploading
                      ? null
                      : () => _runAction(
                            context,
                            onRemove,
                            successMessage: '$title removida com sucesso.',
                          ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final palette = _ConfigPalette.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: palette.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final List<Widget> children;

  const _CardSection({required this.children});

  @override
  Widget build(BuildContext context) {
    final palette = _ConfigPalette.of(context);

    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileRows extends StatelessWidget {
  final String nome;
  final String email;
  final String tipo;
  final String empresa;
  final BuildContext pageContext;
  final WidgetRef ref;

  const _ProfileRows({
    required this.nome,
    required this.email,
    required this.tipo,
    required this.empresa,
    required this.pageContext,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileRow(
          label: 'Nome',
          value: nome,
          onTap: () => _showEditSheet(
            pageContext,
            ref,
            title: 'Nome',
            currentValue: nome,
            firestoreField: 'nome',
          ),
        ),
        const _Divider(),
        _ProfileRow(label: 'E-mail', value: email),
        const _Divider(),
        _ProfileRow(
          label: 'Tipo de Perfil',
          value: tipo,
          onTap: () => _showTipoPerfilSheet(pageContext, ref),
        ),
        const _Divider(),
        _ProfileRow(
          label: 'Empresa',
          value: empresa,
          onTap: () => _showEditSheet(
            pageContext,
            ref,
            title: 'Empresa',
            currentValue: empresa,
            firestoreField: 'empresa',
          ),
        ),
        const _Divider(),
        const _ProfileChevronRow(label: 'Alterar senha'),
      ],
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ThemeModeRow extends ConsumerWidget {
  const _ThemeModeRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = _ConfigPalette.of(context);
    final themeMode = ref.watch(appThemeModeProvider).valueOrNull;
    final isBlack = themeMode?.isBlack ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.moon_fill,
            size: 20,
            color: isBlack ? AppColors.primary : palette.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Modo Black',
              style: TextStyle(
                fontSize: 15,
                color: palette.textPrimary,
              ),
            ),
          ),
          CupertinoSwitch(
            value: isBlack,
            activeTrackColor: AppColors.primary,
            onChanged: (value) {
              ref.read(appThemeModeProvider.notifier).setBlackMode(value);
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ProfileRow({
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ConfigPalette.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: palette.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: palette.textSecondary,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: palette.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileChevronRow extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _ProfileChevronRow({
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ConfigPalette.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: palette.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: palette.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final palette = _ConfigPalette.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(height: 1, color: palette.border),
    );
  }
}
