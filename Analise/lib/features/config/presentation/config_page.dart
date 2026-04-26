import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/features/config/presentation/config_controller.dart';
import 'package:soloforte/features/config/application/providers/demo_mode_provider.dart';

class PerfilAssets {
  final String? logoUrl;
  final String? assinaturaUrl;
  final bool isUploadingLogo;
  final bool isUploadingAssinatura;

  const PerfilAssets({
    this.logoUrl,
    this.assinaturaUrl,
    this.isUploadingLogo = false,
    this.isUploadingAssinatura = false,
  });

  PerfilAssets copyWith({
    String? logoUrl,
    String? assinaturaUrl,
    bool? isUploadingLogo,
    bool? isUploadingAssinatura,
  }) {
    return PerfilAssets(
      logoUrl: logoUrl ?? this.logoUrl,
      assinaturaUrl: assinaturaUrl ?? this.assinaturaUrl,
      isUploadingLogo: isUploadingLogo ?? this.isUploadingLogo,
      isUploadingAssinatura:
          isUploadingAssinatura ?? this.isUploadingAssinatura,
    );
  }
}

class PerfilAssetsNotifier extends StateNotifier<PerfilAssets> {
  PerfilAssetsNotifier() : super(const PerfilAssets()) {
    _loadFromFirestore();
  }

  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _loadFromFirestore() async {
    if (_uid.isEmpty) return;

    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final logo = data['logoUrl'] as String?;
        final assinatura = data['assinaturaUrl'] as String?;

        state = state.copyWith(
          logoUrl: (logo == null || logo.isEmpty) ? null : _withCacheBust(logo),
          assinaturaUrl: (assinatura == null || assinatura.isEmpty)
              ? null
              : _withCacheBust(assinatura),
        );
      }
    } catch (_) {
      // no-op
    }
  }

  String _withCacheBust(String url) {
    final token = DateTime.now().millisecondsSinceEpoch;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}v=$token';
  }

  String _contentType(XFile file) {
    final mimeType = file.mimeType?.trim().toLowerCase();
    if (mimeType != null && mimeType.startsWith('image/')) return mimeType;

    final path = file.path.toLowerCase();
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.webp')) return 'image/webp';
    if (path.endsWith('.heic')) return 'image/heic';
    if (path.endsWith('.heif')) return 'image/heif';
    return 'image/jpeg';
  }

  Never _throwFriendlyError(Object error) {
    if (error is FirebaseException) {
      if (error.code == 'unauthorized') {
        throw Exception(
            'Sem permissão para enviar imagem. Verifique as regras do Storage.');
      }
      throw Exception('Falha no upload (${error.code}). Tente novamente.');
    }
    if (error is PlatformException) {
      throw Exception(
          'Não foi possível acessar a galeria. Verifique as permissões do app.');
    }
    throw Exception('Falha ao enviar imagem. Tente novamente.');
  }

  Future<String> _uploadImage(XFile file, String path) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Arquivo de imagem vazio.');
      }

      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(
          contentType: _contentType(file),
          cacheControl: 'no-cache',
        ),
      );
      return uploadTask.ref.getDownloadURL();
    } catch (error) {
      _throwFriendlyError(error);
    }
  }

  Future<void> _saveToFirestore(String field, String url) async {
    if (_uid.isEmpty) return;

    await _firestore.collection('users').doc(_uid).set(
      {field: url, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  Future<XFile?> _pickImage({
    required int imageQuality,
    required double maxWidth,
  }) async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
      );
    } on PlatformException {
      throw Exception('Permita acesso à galeria para selecionar a imagem.');
    }
  }

  Future<bool> uploadLogo() async {
    if (_uid.isEmpty) {
      throw Exception('Usuário não autenticado. Faça login novamente.');
    }

    final file = await _pickImage(imageQuality: 85, maxWidth: 800);
    if (file == null) return false;

    state = state.copyWith(isUploadingLogo: true);
    try {
      final url = await _uploadImage(file, 'users/$_uid/logo.jpg');
      await _saveToFirestore('logoUrl', url);
      state = state.copyWith(logoUrl: _withCacheBust(url));
      return true;
    } finally {
      state = state.copyWith(isUploadingLogo: false);
    }
  }

  Future<bool> uploadAssinatura() async {
    if (_uid.isEmpty) {
      throw Exception('Usuário não autenticado. Faça login novamente.');
    }

    final file = await _pickImage(imageQuality: 90, maxWidth: 600);
    if (file == null) return false;

    state = state.copyWith(isUploadingAssinatura: true);
    try {
      final url = await _uploadImage(file, 'users/$_uid/assinatura.jpg');
      await _saveToFirestore('assinaturaUrl', url);
      state = state.copyWith(assinaturaUrl: _withCacheBust(url));
      return true;
    } finally {
      state = state.copyWith(isUploadingAssinatura: false);
    }
  }

  Future<bool> removeLogo() async {
    if (_uid.isEmpty) {
      throw Exception('Usuário não autenticado. Faça login novamente.');
    }

    try {
      await _storage.ref().child('users/$_uid/logo.jpg').delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') {
        _throwFriendlyError(error);
      }
    }

    await _saveToFirestore('logoUrl', '');
    state = PerfilAssets(
      logoUrl: null,
      assinaturaUrl: state.assinaturaUrl,
      isUploadingLogo: state.isUploadingLogo,
      isUploadingAssinatura: state.isUploadingAssinatura,
    );
    return true;
  }

  Future<bool> removeAssinatura() async {
    if (_uid.isEmpty) {
      throw Exception('Usuário não autenticado. Faça login novamente.');
    }

    try {
      await _storage.ref().child('users/$_uid/assinatura.jpg').delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') {
        _throwFriendlyError(error);
      }
    }

    await _saveToFirestore('assinaturaUrl', '');
    state = PerfilAssets(
      logoUrl: state.logoUrl,
      assinaturaUrl: null,
      isUploadingLogo: state.isUploadingLogo,
      isUploadingAssinatura: state.isUploadingAssinatura,
    );
    return true;
  }
}

final perfilAssetsProvider =
    StateNotifierProvider<PerfilAssetsNotifier, PerfilAssets>(
  (ref) => PerfilAssetsNotifier(),
);

/// Bottom sheet iOS para edição de campo de texto.
Future<void> _showEditSheet(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String currentValue,
  required String firestoreField,
  String? placeholder,
}) async {
  final controller =
      TextEditingController(text: currentValue == '—' ? '' : currentValue);

  await showCupertinoModalPopup<void>(
    context: context,
    builder: (sheetContext) => Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  color: Color(0xFF1D1D1F),
                ),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD1D1D6)),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            backgroundColor: Color(0xFFF5F5F7),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 96,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20, bottom: 14),
              title: Text(
                'Configurações',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1F),
                  letterSpacing: -0.3,
                ),
              ),
              background: ColoredBox(color: Color(0xFFF5F5F7)),
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
                            content: Text('Dados locais removidos com sucesso.'),
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

                          // Passo 2: digitar EXCLUIR para confirmar
                          final confirmController = TextEditingController();
                          final confirmado = await showCupertinoDialog<bool>(
                            context: context,
                            builder: (dialogContext) => CupertinoAlertDialog(
                              title: const Text('Confirmação final'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Digite EXCLUIR para confirmar:'),
                                  const SizedBox(height: 12),
                                  CupertinoTextField(
                                    controller: confirmController,
                                    placeholder: 'EXCLUIR',
                                    autofocus: true,
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
                                    final ok =
                                        confirmController.text.trim() ==
                                            'EXCLUIR';
                                    Navigator.of(dialogContext).pop(ok);
                                  },
                                  child: const Text('Excluir conta'),
                                ),
                              ],
                            ),
                          );
                          if (confirmado != true || !context.mounted) return;

                          try {
                            await ref
                                .read(configControllerProvider.notifier)
                                .excluirConta();
                            if (context.mounted) context.go(AppRoutes.login);
                          } on FirebaseAuthException catch (e) {
                            if (!context.mounted) return;
                            final msg = e.code == 'requires-recent-login'
                                ? 'Por segurança, faça logout e login novamente antes de excluir a conta.'
                                : 'Erro ao excluir conta. Tente novamente.';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(msg),
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
                const _SectionLabel('SISTEMA'),
                _CardSection(
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        final isDemoAsync = ref.watch(demoModeNotifierProvider);
                        return isDemoAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (isDemo) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Análises de Demonstração',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF1C1C1E),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Exibe laudos reais de exemplo na lista',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF86868B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                CupertinoSwitch(
                                  value: isDemo,
                                  activeTrackColor: AppColors.primary,
                                  onChanged: (_) async {
                                    await ref
                                        .read(demoModeNotifierProvider.notifier)
                                        .toggle();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E7), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Color(0xFFE5E5E7)),
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
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: hasImage
                      ? const Color(0xFF007AFF).withValues(alpha: 0.3)
                      : const Color(0xFFD1D1D6),
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
                              color: const Color(0xFFC7C7CC),
                            ),
                          )
                        : Icon(
                            icon,
                            size: 22,
                            color: const Color(0xFFC7C7CC),
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF86868B),
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
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6, top: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF86868B),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E7), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1D1D1F),
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF86868B),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: Color(0xFFC7C7CC),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1D1D1F),
              ),
            ),
            const Spacer(),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Color(0xFFC7C7CC),
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
    return const Padding(
      padding: EdgeInsets.only(left: 16),
      child: Divider(height: 1, color: Color(0xFFE5E5E7)),
    );
  }
}
