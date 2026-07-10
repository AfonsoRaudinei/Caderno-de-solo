import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';

/// Fonte de verdade para tokens de superfície/texto sensíveis ao tema.
///
/// Light e dark/black compartilham a mesma API. Cores semânticas fixas
/// (primary, success, error, nutrientes) continuam em [AppColors].
///
/// Uso: `final palette = context.appPalette;`
class AppThemePalette {
  const AppThemePalette._({
    required this.isDark,
    required this.background,
    required this.card,
    required this.cardStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.borderStrong,
    required this.inputFill,
    required this.sectionHeader,
    required this.shadow,
  });

  final bool isDark;

  /// Fundo de scaffold / tela.
  final Color background;

  /// Superfície de card padrão.
  final Color card;

  /// Superfície elevada (menus, dropdown, header forte).
  final Color cardStrong;

  /// Texto principal — contraste ≥ 4.5:1 sobre [background]/[card].
  final Color textPrimary;

  /// Labels e texto secundário — contraste ≥ 4.5:1.
  final Color textSecondary;

  /// Hints / placeholders (ainda legível em dark).
  final Color textTertiary;

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

  static AppThemePalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      // Black theme: fundo #000000, cards iOS system gray.
      // textTertiary #8E8E93 ≈ 5.5:1 sobre preto (WCAG AA).
      return const AppThemePalette._(
        isDark: true,
        background: Color(0xFF000000),
        card: Color(0xFF1C1C1E),
        cardStrong: Color(0xFF2C2C2E),
        textPrimary: Color(0xFFF2F2F7),
        textSecondary: Color(0xFFAEAEB2),
        textTertiary: Color(0xFF8E8E93),
        border: Color(0xFF2C2C2E),
        borderStrong: Color(0xFF3A3A3C),
        inputFill: Color(0xFF1C1C1E),
        sectionHeader: Color(0xFF2C2C2E),
        shadow: Color(0x73000000),
      );
    }

    return AppThemePalette._(
      isDark: false,
      background: AppColors.bgSecondary,
      card: Colors.white.withValues(alpha: 0.95),
      cardStrong: Colors.white,
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecond,
      textTertiary: AppColors.textTertiary,
      border: AppColors.borderSoft,
      borderStrong: AppColors.border,
      inputFill: AppColors.bgPrimary,
      sectionHeader: const Color(0xFFF9FAFB),
      shadow: Colors.black.withValues(alpha: 0.06),
    );
  }
}

extension AppThemePaletteContext on BuildContext {
  AppThemePalette get appPalette => AppThemePalette.of(this);
}
