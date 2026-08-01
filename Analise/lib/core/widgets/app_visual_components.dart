import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';

/// Superfície visual padrão para cards, painéis e blocos clicáveis.
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.showBorder = false,
    this.showShadow = true,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showBorder;
  final bool showShadow;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final radius = borderRadius ?? AppDimens.radiusLg;

    final surface = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? palette.card,
        borderRadius: BorderRadius.circular(radius),
        border:
            showBorder ? Border.all(color: palette.border, width: 0.5) : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: palette.shadow,
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppDimens.lg),
          child: child,
        ),
      ),
    );

    if (onTap == null && onLongPress == null) return surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(radius),
        child: surface,
      ),
    );
  }
}

/// Moldura para ícones 3D ou símbolos simples dentro de listas e cards.
class AppIconFrame extends StatelessWidget {
  const AppIconFrame({
    super.key,
    this.assetPath,
    this.icon,
    this.size = AppDimens.listIconSize,
    this.iconSize,
    this.backgroundColor,
    this.iconColor,
  }) : assert(assetPath != null || icon != null);

  final String? assetPath;
  final IconData? icon;
  final double size;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final bgColor = backgroundColor ??
        (palette.isDark
            ? AppColors.primary.withValues(alpha: 0.16)
            : AppColors.primary.withValues(alpha: 0.08));

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Padding(
          padding: EdgeInsets.all(assetPath == null ? 0 : size * 0.08),
          child: assetPath == null
              ? Icon(
                  icon,
                  color: iconColor ?? AppColors.primary,
                  size: iconSize ?? size * 0.56,
                )
              : Image.asset(
                  assetPath!,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.circle_outlined,
                    color: iconColor ?? AppColors.primary,
                    size: iconSize ?? size * 0.52,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Linha de ação para menus e listas com ícone, título, subtítulo e chevron.
class AppActionListRow extends StatelessWidget {
  const AppActionListRow({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.assetPath,
    this.icon,
    this.trailing,
    this.showChevron = true,
  });

  final String title;
  final String? subtitle;
  final String? assetPath;
  final IconData? icon;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.lg,
          vertical: AppDimens.md,
        ),
        child: Row(
          children: [
            if (assetPath != null || icon != null) ...[
              AppIconFrame(assetPath: assetPath, icon: icon),
              const SizedBox(width: AppDimens.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppDimens.xs),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppDimens.md),
              trailing!,
            ] else if (showChevron) ...[
              const SizedBox(width: AppDimens.md),
              Icon(
                Icons.chevron_right_rounded,
                color: palette.textTertiary,
                size: AppDimens.iconSize,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado vazio reutilizável, discreto e compatível com a linguagem iOS.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.assetPath,
    this.action,
  });

  final String title;
  final String message;
  final IconData? icon;
  final String? assetPath;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (assetPath != null || icon != null) ...[
                AppIconFrame(
                  assetPath: assetPath,
                  icon: icon,
                  size: AppDimens.cardIconSize,
                ),
                const SizedBox(height: AppDimens.lg),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.headline.copyWith(
                  color: palette.textPrimary,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: AppDimens.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: palette.textSecondary,
                ),
              ),
              if (action != null) ...[
                const SizedBox(height: AppDimens.xl),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
