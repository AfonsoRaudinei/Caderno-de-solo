import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/widgets/app_bottom_tab_bar.dart';

/// Shell de navegação principal do SoloForte.
class MainPage extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  static const List<AppBottomTabItem> _tabs = [
    AppBottomTabItem(
      icon: Icons.contacts_outlined,
      selectedIcon: Icons.contacts,
      label: 'Clientes',
    ),
    AppBottomTabItem(
      icon: Icons.science_outlined,
      selectedIcon: Icons.science,
      label: 'Análise',
    ),
    AppBottomTabItem(
      icon: Icons.biotech_outlined,
      selectedIcon: Icons.biotech,
      label: 'Lab',
    ),
    AppBottomTabItem(
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
      label: 'Mapa',
    ),
    AppBottomTabItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Config',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: navigationShell,
      bottomNavigationBar: AppBottomTabBar(
        items: _tabs,
        currentIndex: currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == currentIndex,
        ),
      ),
    );
  }
}
