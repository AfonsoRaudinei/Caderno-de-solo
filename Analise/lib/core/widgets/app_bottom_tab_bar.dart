import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';

class AppBottomTabItem {
  const AppBottomTabItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Tab bar principal: flutuante, discreta e sem rótulos para não competir com o conteúdo.
class AppBottomTabBar extends StatelessWidget {
  const AppBottomTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AppBottomTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return SafeArea(
      minimum: EdgeInsets.fromLTRB(
        AppDimens.xxl,
        0,
        AppDimens.xxl,
        bottomInset > 0 ? AppDimens.sm : AppDimens.lg,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.cardStrong,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          border: Border.all(
            color: palette.isDark ? palette.borderStrong : Colors.transparent,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: palette.shadow.withValues(alpha: palette.isDark ? 1 : 0.9),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            if (!palette.isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: SizedBox(
          height: AppDimens.bottomTabBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var index = 0; index < items.length; index++)
                _AppBottomTabButton(
                  item: items[index],
                  selected: currentIndex == index,
                  onTap: () => onTap(index),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBottomTabButton extends StatelessWidget {
  const _AppBottomTabButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomTabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final color = selected ? palette.accent : palette.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Tooltip(
        message: item.label,
        child: InkResponse(
          onTap: onTap,
          radius: 30,
          containedInkWell: false,
          child: SizedBox(
            width: AppDimens.bottomTabItemWidth,
            height: AppDimens.bottomTabBarHeight,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: selected ? 44 : 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selected
                      ? palette.accent.withValues(
                          alpha: palette.isDark ? 0.18 : 0.10,
                        )
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: Icon(
                    selected ? item.selectedIcon : item.icon,
                    key: ValueKey('${item.label}-$selected'),
                    color: color,
                    size: selected ? 25 : 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
