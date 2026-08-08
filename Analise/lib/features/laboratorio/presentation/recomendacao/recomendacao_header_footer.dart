import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/utils/image_source_resolver.dart';
import 'package:soloforte/features/config/application/providers/perfil_assets_provider.dart';

class RecomendacaoHeader extends ConsumerWidget {
  const RecomendacaoHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(perfilAssetsProvider);
    final logoProvider = ImageSourceResolver.imageProvider(assets.logoUrl);
    final hasLogo = logoProvider != null;
    final palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: palette.card,
        border: Border(
          bottom: BorderSide(color: palette.border, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: hasLogo
                ? ClipRRect(
                    key: const ValueKey('logo'),
                    borderRadius: BorderRadius.circular(8),
                    child: Image(
                      image: logoProvider,
                      height: 48,
                      width: 96,
                      fit: BoxFit.contain,
                    ),
                  )
                : const _LogoPlaceholder(key: ValueKey('placeholder')),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recomendação de Adubação',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'SoloForte · ESALQ/USP',
                  style: TextStyle(
                    fontSize: 11,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      height: 48,
      width: 96,
      decoration: BoxDecoration(
        color: palette.sectionHeader,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: palette.borderStrong,
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          CupertinoIcons.building_2_fill,
          size: 22,
          color: palette.textTertiary,
        ),
      ),
    );
  }
}

class AssinaturaWidget extends ConsumerWidget {
  final String nomeConsultor;
  final String? creaNumero;

  const AssinaturaWidget({
    super.key,
    required this.nomeConsultor,
    this.creaNumero,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(perfilAssetsProvider);
    final assinaturaProvider =
        ImageSourceResolver.imageProvider(assets.assinaturaUrl);
    final hasAssinatura = assinaturaProvider != null;
    final palette = context.appPalette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border, width: 0.5),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 64,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: hasAssinatura
                  ? Image(
                      image: assinaturaProvider,
                      key: const ValueKey('assinatura'),
                      height: 60,
                      fit: BoxFit.contain,
                    )
                  : const _AssinaturaPlaceholder(
                      key: ValueKey('placeholder'),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Divider(
              color: palette.textPrimary.withValues(alpha: 0.3),
              thickness: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nomeConsultor.isEmpty ? 'Eng. Responsável' : nomeConsultor,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: palette.textPrimary,
            ),
          ),
          if (creaNumero != null && creaNumero!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'CREA/CRQ nº $creaNumero',
              style: TextStyle(
                fontSize: 11,
                color: palette.textSecondary,
              ),
            ),
          ],
          if (!hasAssinatura) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => context.push(AppRoutes.config),
              child: Text(
                'Adicionar assinatura em Configurações →',
                style: TextStyle(
                  fontSize: 11,
                  color: palette.accent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AssinaturaPlaceholder extends StatelessWidget {
  const _AssinaturaPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Center(
      child: Text(
        '· · · · · · · · · · · · · · ·',
        style: TextStyle(
          fontSize: 16,
          color: palette.textTertiary,
          letterSpacing: 4,
        ),
      ),
    );
  }
}
