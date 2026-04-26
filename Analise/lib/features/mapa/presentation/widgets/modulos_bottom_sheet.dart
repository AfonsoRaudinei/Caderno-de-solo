import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
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
      height: 390,
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(items.length, (index) {
                final item = items[index];
                return Column(
                  children: [
                    SizedBox(
                      height: 56,
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 0),
                        leading: Icon(
                          item.icon,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        title: Text(item.titulo),
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
                    ),
                    if (index < items.length - 1)
                      const Divider(
                        height: 0.5,
                        thickness: 0.5,
                        color: AppColors.borderSoft,
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
