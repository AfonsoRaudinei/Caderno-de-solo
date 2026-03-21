import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/presentation/config/config_page.dart';

class RecomendacaoHeader extends ConsumerWidget {
  const RecomendacaoHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(perfilAssetsProvider);
    final hasLogo = assets.logoUrl != null && assets.logoUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E7), width: 0.5),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recomendação de Adubação',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'SoloForte · ESALQ/USP',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF86868B),
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
    return Container(
      height: 48,
      width: 96,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD1D1D6),
          width: 1,
        ),
      ),
      child: const Center(
        child: Icon(
          CupertinoIcons.building_2_fill,
          size: 22,
          color: Color(0xFFC7C7CC),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E7), width: 0.5),
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
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF86868B),
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
    return const Center(
      child: Text(
        '· · · · · · · · · · · · · · ·',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFFC7C7CC),
          letterSpacing: 4,
        ),
      ),
    );
  }
}
