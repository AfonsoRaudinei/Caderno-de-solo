import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';

/// Card padrão do SoloForte com sombra iOS sutil
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.showShadow = true,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? color;
  final bool showShadow;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final radius = borderRadius ?? AppDimens.radiusMd;

    final container = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? palette.card,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : Border.all(color: palette.border, width: 0.5),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: palette.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppDimens.cardPadding),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}

/// Seção de card com título discreto estilo iOS
class AppCardSection extends StatelessWidget {
  const AppCardSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.padding,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final contentPadding = padding ?? const EdgeInsets.all(AppDimens.cardPadding);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.lg,
                  AppDimens.md,
                  AppDimens.lg,
                  AppDimens.sm,
                ),
                decoration: BoxDecoration(
                  color: palette.sectionHeader,
                  border: Border(
                    bottom: BorderSide(
                      color: palette.border,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: AppTextStyles.sectionLabel.copyWith(
                        color: palette.textSecondary,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (trailing != null) ...[
                      const Spacer(),
                      trailing!,
                    ],
                  ],
                ),
              ),
              Padding(
                padding: contentPadding,
                child: child,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Linha de informação em card — label + valor
class AppCardRow extends StatelessWidget {
  const AppCardRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.label.copyWith(color: palette.textPrimary),
              ),
              Text(
                value,
                style: AppTextStyles.value.copyWith(
                  color: valueColor ?? palette.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: palette.border,
          ),
      ],
    );
  }
}
