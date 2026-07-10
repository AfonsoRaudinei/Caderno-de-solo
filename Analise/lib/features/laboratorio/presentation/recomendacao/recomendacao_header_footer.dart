import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/features/config/application/providers/perfil_assets_provider.dart';

class RecomendacaoHeader extends ConsumerWidget {
  const RecomendacaoHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(perfilAssetsProvider);
    final hasLogo = assets.logoUrl != null && assets.logoUrl!.isNotEmpty;
    final palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
                    child: Image.network(
                      assets.logoUrl!,
                      height: 48,
                      width: 96,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const _LogoPlaceholder(),
                    ),
                  )
                : const _LogoPlaceholder(key: ValueKey('placeholder')),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recomendação de Adubação',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1F),
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
    final hasAssinatura =
        assets.assinaturaUrl != null && assets.assinaturaUrl!.isNotEmpty;
    final palette = context.appPalette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  ? Image.network(
                      assets.assinaturaUrl!,
                      key: const ValueKey('assinatura'),
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const _AssinaturaPlaceholder(),
                    )
                  : const _AssinaturaPlaceholder(
                      key: ValueKey('placeholder'),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Divider(
              color: const Color(0xFF1D1D1F).withValues(alpha: 0.3),
              thickness: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nomeConsultor.isEmpty ? 'Eng. Responsável' : nomeConsultor,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D1D1F),
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
              child: const Text(
                'Adicionar assinatura em Configurações →',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF007AFF),
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
