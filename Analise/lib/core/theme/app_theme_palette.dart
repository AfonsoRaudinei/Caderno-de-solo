import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';

/// Fonte de verdade para tokens de superfície/texto sensíveis ao tema.
///
/// Light e dark/black compartilham a mesma API. Cores semânticas fixas
/// (success, error, nutrientes) continuam em [AppColors].
///
/// Uso: `final palette = context.appPalette;`
class AppThemePalette {
  const AppThemePalette._({
    required this.isDark,
    required this.background,
    required this.card,
    required this.cardStrong,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.border,
    required this.borderStrong,
    required this.inputFill,
    required this.sectionHeader,
    required this.shadow,
    required this.accent,
    required this.accentVariant,
  });

  final bool isDark;

  /// Fundo de scaffold / tela.
  final Color background;

  /// Superfície de card padrão.
  final Color card;

  /// Superfície elevada (menus, dropdown, header forte).
  final Color cardStrong;

  /// Superfície secundária (linhas alternadas, chips).
  final Color surfaceAlt;

  /// Texto principal — contraste ≥ 4.5:1 sobre [background]/[card].
  final Color textPrimary;

  /// Labels e texto secundário — contraste ≥ 4.5:1.
  final Color textSecondary;

  /// Hints / placeholders (ainda legível em dark).
  final Color textTertiary;

  /// Texto desabilitado.
  final Color textDisabled;

  /// Bordas suaves / divisores.
  final Color border;

  /// Bordas de input e contornos mais visíveis.
  final Color borderStrong;

  /// Fill de TextField / dropdown.
  final Color inputFill;

  /// Faixa de título de seção em cards.
  final Color sectionHeader;

  /// Sombra de elevação.
  final Color shadow;

  /// Cor de acento do tema ativo (Azul Samsung no Black, iOS blue no light).
  final Color accent;

  /// Variante pressed/hover do acento.
  final Color accentVariant;

  static AppThemePalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const AppThemePalette._(
        isDark: true,
        background: AppColors.blackBackground,
        card: AppColors.blackSurface,
        cardStrong: AppColors.blackSurface,
        surfaceAlt: AppColors.blackSurfaceAlt,
        textPrimary: AppColors.blackTextPrimary,
        textSecondary: AppColors.blackTextSecondary,
        textTertiary: AppColors.blackTextSecondary,
        textDisabled: AppColors.blackTextDisabled,
        border: AppColors.blackBorder,
        borderStrong: AppColors.blackBorder,
        inputFill: AppColors.blackSurface,
        sectionHeader: AppColors.blackSurfaceAlt,
        shadow: Color(0x73000000),
        accent: AppColors.accentSecondary,
        accentVariant: AppColors.accentSecondaryVariant,
      );
    }

    return AppThemePalette._(
      isDark: false,
      background: AppColors.bgSecondary,
      card: Colors.white.withValues(alpha: 0.95),
      cardStrong: Colors.white,
      surfaceAlt: AppColors.bgSecondary,
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecond,
      textTertiary: AppColors.textTertiary,
      textDisabled: AppColors.textTertiary,
      border: AppColors.borderSoft,
      borderStrong: AppColors.border,
      inputFill: AppColors.bgPrimary,
      sectionHeader: const Color(0xFFF9FAFB),
      shadow: Colors.black.withValues(alpha: 0.06),
      accent: AppColors.primary,
      accentVariant: AppColors.primaryDark,
    );
  }
}

extension AppThemePaletteContext on BuildContext {
  AppThemePalette get appPalette => AppThemePalette.of(this);
}
