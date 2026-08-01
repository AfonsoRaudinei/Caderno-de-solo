import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/features/mapa/providers/mapa_visivel_provider.dart';

class ModulosBottomSheet extends ConsumerWidget {
  const ModulosBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = <({String titulo, IconData icon, String route})>[
      (
        titulo: 'Mapa',
        icon: CupertinoIcons.map_fill,
        route: '',
      ),
      (
        titulo: 'Análise',
        icon: CupertinoIcons.chart_bar_alt_fill,
        route: AppRoutes.analise,
      ),
      (
        titulo: 'Lab',
        icon: CupertinoIcons.lab_flask,
        route: AppRoutes.lab,
      ),
      (
        titulo: 'Histórico',
        icon: CupertinoIcons.clock,
        route: AppRoutes.labHistorico,
      ),
      (
        titulo: 'Config',
        icon: CupertinoIcons.settings,
        route: AppRoutes.config,
      ),
    ];

    return Container(
      height: 430,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFE),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radius2xl),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(top: 12, bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.lg,
              0,
              AppDimens.lg,
              AppDimens.sm,
            ),
            child: Text(
              'Módulos',
              style: AppTextStyles.headline.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.lg,
                0,
                AppDimens.lg,
                AppDimens.xxl,
              ),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppDimens.sm),
              itemBuilder: (context, index) {
                final item = items[index];
                return AppSurface(
                  padding: EdgeInsets.zero,
                  borderRadius: AppDimens.radiusLg,
                  showBorder: true,
                  showShadow: false,
                  child: AppActionListRow(
                    title: item.titulo,
                    icon: item.icon,
                    trailing: const Icon(
                      CupertinoIcons.chevron_right,
                      color: AppColors.textTertiary,
                      size: 18,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (item.route.isEmpty) {
                        ref.read(mapaVisivelProvider.notifier).state = true;
                        return;
                      }
                      ref.read(mapaVisivelProvider.notifier).state = false;
                      context.go(item.route);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
