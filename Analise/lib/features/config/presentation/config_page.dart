import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/config/app_config.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/utils/image_source_resolver.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/analise/domain/value_objects/migracao_vinculos_result.dart';
import 'package:soloforte/features/config/application/providers/app_theme_mode_provider.dart';
import 'package:soloforte/features/config/domain/entities/config_action_exception.dart';
import 'package:soloforte/features/config/presentation/config_controller.dart';
import 'package:soloforte/features/config/application/providers/perfil_assets_provider.dart';

export 'package:soloforte/features/config/application/providers/perfil_assets_provider.dart'
    show PerfilAssets, PerfilAssetsNotifier, perfilAssetsProvider;

/// Bottom sheet iOS para edição de campo de texto.
Future<void> _showEditSheet(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String currentValue,
  required String firestoreField,
  String? placeholder,
}) async {
  final AppThemePalette palette = context.appPalette;
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
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: palette.textSecondary),
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
    final AppThemePalette palette = context.appPalette;

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
                const _SectionLabel('APARÊNCIA'),
                const _CardSection(
                  children: [
                    _ThemeModeRow(),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionLabel('MODELOS E COMUNICAÇÃO'),
                _CardSection(
                  children: [
                    _ProfileChevronRow(
                      label: 'Modelos de Laboratório',
                      subtitle: 'Unidades, campos e leitura de PDFs',
                      icon: CupertinoIcons.lab_flask,
                      onTap: () => context.push(AppRoutes.configLabTemplates),
                    ),
                    const _Divider(),
                    _ProfileChevronRow(
                      label: 'Enviar Feedback',
                      subtitle: 'Bug, sugestão, elogio ou melhoria',
                      icon: CupertinoIcons.chat_bubble_text,
                      onTap: () => context.push(AppRoutes.feedback),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionLabel('SINCRONIZAÇÃO DE DADOS'),
                const _CardSection(
                  children: [
                    _MigracaoVinculosRow(),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionLabel('DADOS DO DISPOSITIVO'),
                _CardSection(
                  children: [
                    _ProfileChevronRow(
                      label: 'Limpar Dados Locais',
                      subtitle: 'Remove apenas dados salvos neste aparelho',
                      icon: CupertinoIcons.trash,
                      isDestructive: true,
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
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
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
                    _ProfileChevronRow(
                      label: 'Excluir Conta',
                      subtitle: 'Remove conta e dados permanentemente',
                      icon: CupertinoIcons.delete,
                      isDestructive: true,
                      onTap: () async {
                        // Passo 1: alerta de consequências
                        final prosseguir = await showCupertinoDialog<bool>(
                          context: context,
                          builder: (dialogContext) => CupertinoAlertDialog(
                            title: const Text('Excluir conta permanentemente?'),
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
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Erro ao excluir conta. Tente novamente.',
                              ),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                    const _Divider(),
                    _ProfileChevronRow(
                      label: 'Sair da Conta',
                      subtitle: 'Desconecta este dispositivo',
                      icon: CupertinoIcons.square_arrow_right,
                      isDestructive: true,
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
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Center(
                  child: _CalculosAccessVersion(
                    versionLabel: 'Analise v1.0.1',
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
    final AppThemePalette palette = context.appPalette;

    return AppSurface(
      padding: EdgeInsets.zero,
      showBorder: true,
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
    final AppThemePalette palette = context.appPalette;
    final imageProvider = ImageSourceResolver.imageProvider(imageUrl);
    final hasRenderableImage = hasImage && imageProvider != null;

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
                      ? AppColors.primary.withValues(alpha: 0.3)
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
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : hasRenderableImage
                        ? Image(
                            image: imageProvider,
                            fit: shape == _ImageShape.wide
                                ? BoxFit.contain
                                : BoxFit.cover,
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
                color: AppColors.primary,
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
                  color: AppColors.error,
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
    final AppThemePalette palette = context.appPalette;

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
    return AppSurface(
      padding: EdgeInsets.zero,
      showBorder: true,
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
    final AppThemePalette palette = context.appPalette;
    final themeMode = ref.watch(appThemeModeProvider).valueOrNull;
    final isBlack = themeMode?.isBlack ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.moon_fill,
            size: 20,
            color: isBlack ? palette.accent : palette.textSecondary,
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
            activeTrackColor: palette.accent,
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
    final AppThemePalette palette = context.appPalette;

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
  final String? subtitle;
  final IconData? icon;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _ProfileChevronRow({
    required this.label,
    this.subtitle,
    this.icon,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppThemePalette palette = context.appPalette;
    final color = isDestructive ? AppColors.error : palette.textPrimary;
    final iconColor = isDestructive ? AppColors.error : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (icon != null) ...[
              AppIconFrame(
                icon: icon,
                size: 38,
                iconSize: 19,
                backgroundColor: iconColor.withValues(alpha: 0.10),
                iconColor: iconColor,
              ),
              const SizedBox(width: AppDimens.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
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
    final AppThemePalette palette = context.appPalette;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Divider(height: 1, color: palette.border),
    );
  }
}

class _CalculosAccessVersion extends StatefulWidget {
  const _CalculosAccessVersion({
    required this.versionLabel,
  });

  final String versionLabel;

  @override
  State<_CalculosAccessVersion> createState() => _CalculosAccessVersionState();
}

class _CalculosAccessVersionState extends State<_CalculosAccessVersion> {
  void _abrirCalculos() {
    if (!AppConfig.requiresCalculosAccessPassword) {
      context.go(AppRoutes.calculos);
      return;
    }
    _mostrarDialogSenha(context);
  }

  void _mostrarDialogSenha(BuildContext context) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Acesso restrito'),
          content: TextField(
            controller: controller,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            maxLength: 20,
            decoration: const InputDecoration(
              hintText: 'Senha de acesso',
              counterText: '',
            ),
            autofocus: true,
            onSubmitted: (_) => _validarSenha(
              dialogContext,
              controller.text,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => _validarSenha(
                dialogContext,
                controller.text,
              ),
              child: const Text('Entrar'),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _validarSenha(BuildContext dialogContext, String senha) {
    Navigator.of(dialogContext).pop();

    const expected = AppConfig.calculosAccessPassword;
    if (expected.isNotEmpty && senha == expected) {
      context.go(AppRoutes.calculos, extra: true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          expected.isEmpty
              ? 'Acesso ao módulo Cálculos não configurado neste build.'
              : 'Senha incorreta',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _abrirCalculos,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
        child: Text(
          widget.versionLabel,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecond,
          ),
        ),
      ),
    );
  }
}

class _MigracaoVinculosRow extends ConsumerStatefulWidget {
  const _MigracaoVinculosRow();

  @override
  ConsumerState<_MigracaoVinculosRow> createState() =>
      _MigracaoVinculosRowState();
}

class _MigracaoVinculosRowState extends ConsumerState<_MigracaoVinculosRow> {
  bool _isRunning = false;

  Future<void> _executar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vincular análises legadas'),
        content: const Text(
          'Tenta associar análises antigas aos clientes cadastrados por '
          'correspondência de nomes. Análises sem match recebem status '
          '"Vínculo pendente". Nenhum registro será apagado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Executar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    setState(() => _isRunning = true);
    MigracaoVinculosResult result;
    try {
      result = await ref
          .read(analiseNotifierProvider.notifier)
          .executarMigracaoVinculosLegados();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRunning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha na migração: $e')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isRunning = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_mensagemResultado(result))),
    );
  }

  String _mensagemResultado(MigracaoVinculosResult result) {
    if (!result.executada) {
      return 'Migração não executada. Verifique login e cadastro de clientes.';
    }
    if (!result.teveAlteracao && result.falhas == 0) {
      return 'Nenhuma análise precisou de migração (${result.jaVinculadas} já vinculadas).';
    }
    final partes = <String>[
      if (result.reparadas > 0) '${result.reparadas} vinculada(s)',
      if (result.marcadasPendentes > 0)
        '${result.marcadasPendentes} pendente(s)',
      if (result.falhas > 0) '${result.falhas} falha(s)',
    ];
    return 'Migração concluída: ${partes.join(', ')}.';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return InkWell(
      onTap: _isRunning ? null : _executar,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vincular análises legadas',
                    style: TextStyle(
                      fontSize: 15,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Associa laudos antigos aos clientes por nome',
                    style: AppTextStyles.caption.copyWith(
                      color: palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (_isRunning)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else
              Icon(
                Icons.sync_rounded,
                size: 20,
                color: palette.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
