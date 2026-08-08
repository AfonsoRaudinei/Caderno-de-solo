import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/features/mapa/domain/map_engine.dart';

class FerramentasDesenhoBottomSheet extends StatefulWidget {
  const FerramentasDesenhoBottomSheet({super.key});

  static Future<MapDrawingMode?> show(BuildContext context) {
    return showModalBottomSheet<MapDrawingMode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FerramentasDesenhoBottomSheet(),
    );
  }

  @override
  State<FerramentasDesenhoBottomSheet> createState() =>
      _FerramentasDesenhoBottomSheetState();
}

class _FerramentasDesenhoBottomSheetState
    extends State<FerramentasDesenhoBottomSheet> {
  var _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      height: 520,
      decoration: BoxDecoration(
        color: palette.cardStrong,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radius2xl),
        ),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(top: 12, bottom: 14),
            decoration: BoxDecoration(
              color: palette.textSecondary.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
            child: Row(
              children: [
                _TabChip(
                  label: 'Desenho',
                  icon: CupertinoIcons.pencil,
                  selected: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
                const SizedBox(width: AppDimens.sm),
                _TabChip(
                  label: 'Visualização',
                  icon: CupertinoIcons.eye,
                  selected: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
            child: Text(
              'Ferramentas de Desenho',
              style: AppTextStyles.headline.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.md),
          Expanded(
            child: _tabIndex == 0
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.lg,
                      0,
                      AppDimens.lg,
                      AppDimens.xxl,
                    ),
                    children: [
                      _ToolRow(
                        title: 'Polígono',
                        icon: CupertinoIcons.hexagon,
                        onTap: () => Navigator.pop(
                          context,
                          MapDrawingMode.polygon,
                        ),
                      ),
                      const SizedBox(height: AppDimens.sm),
                      _ToolRow(
                        title: 'Livre',
                        icon: CupertinoIcons.scribble,
                        onTap: () => Navigator.pop(
                          context,
                          MapDrawingMode.freehand,
                        ),
                      ),
                      const SizedBox(height: AppDimens.sm),
                      const _ToolRow(
                        title: 'Pivô',
                        icon: CupertinoIcons.circle,
                        enabled: false,
                      ),
                      const SizedBox(height: AppDimens.sm),
                      const _ToolRow(
                        title: 'Importar (KML)',
                        icon: CupertinoIcons.doc_text,
                        enabled: false,
                      ),
                      const SizedBox(height: AppDimens.sm),
                      const _ToolRow(
                        title: 'GPS (caminhar)',
                        icon: CupertinoIcons.person,
                        enabled: false,
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      'Camadas de visualização em breve',
                      style: AppTextStyles.body.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final onAccent = palette.isDark ? palette.textPrimary : palette.cardStrong;

    return Expanded(
      child: Material(
        color: selected ? AppColors.success : palette.surfaceAlt,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? onAccent : palette.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? onAccent : palette.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({
    required this.title,
    required this.icon,
    this.onTap,
    this.enabled = true,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: AppSurface(
        padding: EdgeInsets.zero,
        borderRadius: AppDimens.radiusLg,
        showBorder: true,
        showShadow: false,
        child: AppActionListRow(
          title: title,
          icon: icon,
          trailing: Icon(
            CupertinoIcons.chevron_right,
            color: palette.textTertiary,
            size: 18,
          ),
          onTap: enabled ? onTap! : () {},
        ),
      ),
    );
  }
}
