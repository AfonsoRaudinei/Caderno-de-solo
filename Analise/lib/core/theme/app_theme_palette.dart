import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';

/// Tokens visuais sensíveis ao tema (light / black).
///
/// Use via [BuildContext.appPalette] em widgets que ainda não consomem
/// exclusivamente [ThemeData], evitando cores fixas de [AppColors].
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
  final Color background;
  final Color card;
  final Color cardStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color borderStrong;
  final Color inputFill;
  final Color sectionHeader;
  final Color shadow;

  static AppThemePalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return AppThemePalette._(
        isDark: true,
        background: Colors.black,
        card: const Color(0xFF1C1C1E),
        cardStrong: const Color(0xFF2C2C2E),
        textPrimary: const Color(0xFFF2F2F7),
        textSecondary: const Color(0xFFAEAEB2),
        textTertiary: const Color(0xFF636366),
        border: const Color(0xFF2C2C2E),
        borderStrong: const Color(0xFF3A3A3C),
        inputFill: const Color(0xFF1C1C1E),
        sectionHeader: const Color(0xFF2C2C2E),
        shadow: Colors.black.withValues(alpha: 0.45),
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
