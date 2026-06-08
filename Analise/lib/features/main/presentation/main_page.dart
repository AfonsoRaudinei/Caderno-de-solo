import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/theme/app_colors.dart';

/// Shell de navegação principal do SoloForte.
class MainPage extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.science_outlined,
                selectedIcon: Icons.science,
                label: 'Análise',
                selected: currentIndex == 0,
                onTap: () => navigationShell.goBranch(
                  0,
                  initialLocation: true,
                ),
              ),
              _NavItem(
                icon: Icons.biotech_outlined,
                selectedIcon: Icons.biotech,
                label: 'Lab',
                selected: currentIndex == 1,
                onTap: () => navigationShell.goBranch(
                  1,
                  initialLocation: true,
                ),
              ),
              _NavItem(
                icon: Icons.map_outlined,
                selectedIcon: Icons.map,
                label: 'Mapa',
                selected: currentIndex == 2,
                onTap: () => navigationShell.goBranch(
                  2,
                  initialLocation: true,
                ),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                label: 'Config',
                selected: currentIndex == 3,
                onTap: () => navigationShell.goBranch(
                  3,
                  initialLocation: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              selected ? selectedIcon : icon,
              key: ValueKey(selected),
              color: selected ? AppColors.primary : AppColors.textSecond,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
