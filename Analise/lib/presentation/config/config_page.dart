import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';

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
          logoUrl: (logo == null || logo.isEmpty) ? null : logo,
          assinaturaUrl:
              (assinatura == null || assinatura.isEmpty) ? null : assinatura,
        );
      }
    } catch (_) {
      // no-op
    }
  }

  Future<String?> _uploadImage(XFile file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(
        File(file.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> _saveToFirestore(String field, String url) async {
    if (_uid.isEmpty) return;

    await _firestore.collection('users').doc(_uid).set(
      {field: url, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  Future<void> uploadLogo() async {
    if (_uid.isEmpty) return;

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (file == null) return;

    state = state.copyWith(isUploadingLogo: true);
    final url = await _uploadImage(file, 'users/$_uid/logo.jpg');

    if (url != null) {
      await _saveToFirestore('logoUrl', url);
      state = state.copyWith(logoUrl: url, isUploadingLogo: false);
    } else {
      state = state.copyWith(isUploadingLogo: false);
    }
  }

  Future<void> uploadAssinatura() async {
    if (_uid.isEmpty) return;

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 600,
    );
    if (file == null) return;

    state = state.copyWith(isUploadingAssinatura: true);
    final url = await _uploadImage(file, 'users/$_uid/assinatura.jpg');

    if (url != null) {
      await _saveToFirestore('assinaturaUrl', url);
      state = state.copyWith(assinaturaUrl: url, isUploadingAssinatura: false);
    } else {
      state = state.copyWith(isUploadingAssinatura: false);
    }
  }

  Future<void> removeLogo() async {
    if (_uid.isEmpty) return;

    try {
      await _storage.ref().child('users/$_uid/logo.jpg').delete();
    } catch (_) {
      // no-op
    }

    await _saveToFirestore('logoUrl', '');
    state = PerfilAssets(
      logoUrl: null,
      assinaturaUrl: state.assinaturaUrl,
      isUploadingLogo: state.isUploadingLogo,
      isUploadingAssinatura: state.isUploadingAssinatura,
    );
  }

  Future<void> removeAssinatura() async {
    if (_uid.isEmpty) return;

    try {
      await _storage.ref().child('users/$_uid/assinatura.jpg').delete();
    } catch (_) {
      // no-op
    }

    await _saveToFirestore('assinaturaUrl', '');
    state = PerfilAssets(
      logoUrl: state.logoUrl,
      assinaturaUrl: null,
      isUploadingLogo: state.isUploadingLogo,
      isUploadingAssinatura: state.isUploadingAssinatura,
    );
  }
}

final perfilAssetsProvider =
    StateNotifierProvider<PerfilAssetsNotifier, PerfilAssets>(
  (ref) => PerfilAssetsNotifier(),
);

class ConfigPage extends ConsumerWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                const _CardSection(
                  children: [
                    _ProfileRow(label: 'Nome', value: 'João Produtor'),
                    _Divider(),
                    _ProfileRow(label: 'E-mail', value: 'joao@soloforte.com.br'),
                    _Divider(),
                    _ProfileRow(label: 'Tipo de Perfil', value: 'Produtor'),
                    _Divider(),
                    _ProfileRow(label: 'Empresa', value: 'Fazenda Boa Esperança'),
                    _Divider(),
                    _ProfileChevronRow(label: 'Alterar senha'),
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
                      label: 'Base de Dados (Referências Técnicas)',
                      onTap: () => context.push(AppRoutes.baseDados),
                    ),
                    const _Divider(),
                    _ProfileChevronRow(
                      label: 'Enviar Feedback',
                      onTap: () => context.push(AppRoutes.feedback),
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
                        onTap: () => context.go(AppRoutes.login),
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
  final VoidCallback onUpload;
  final VoidCallback onRemove;
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
            onTap: isUploading ? null : onUpload,
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
                onTap: isUploading ? null : onUpload,
              ),
              if (hasImage) ...[
                const SizedBox(width: 6),
                _ActionChip(
                  label: 'Remover',
                  color: const Color(0xFFFF3B30),
                  onTap: onRemove,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
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

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
        ],
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
