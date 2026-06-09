import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';

/// ThemeData principal do SoloForte — Material 3 com estética iOS/Apple
class AppTheme {
  AppTheme._();

  static ThemeData get black {
    return light.copyWith(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primary,
        onSecondary: Colors.white,
        surface: Color(0xFF1C1C1E),
        onSurface: Color(0xFFF2F2F7),
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: light.appBarTheme.copyWith(
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFF2F2F7),
        shadowColor: const Color(0xFF2C2C2E),
        titleTextStyle: AppTextStyles.value.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF2F2F7),
        ),
      ),
      navigationBarTheme: light.navigationBarTheme.copyWith(
        backgroundColor: const Color(0xFF1C1C1E),
        shadowColor: const Color(0xFF2C2C2E),
        indicatorColor: AppColors.primary.withValues(alpha: 0.18),
      ),
      cardTheme: light.cardTheme.copyWith(
        color: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2C2C2E)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2C2C2E),
        thickness: 0.5,
        space: 0,
      ),
      inputDecorationTheme: light.inputDecorationTheme.copyWith(
        fillColor: const Color(0xFF1C1C1E),
      ),
      snackBarTheme: light.snackBarTheme.copyWith(
        backgroundColor: const Color(0xFF2C2C2E),
        contentTextStyle: AppTextStyles.body.copyWith(
          color: const Color(0xFFF2F2F7),
        ),
      ),
      dialogTheme: light.dialogTheme.copyWith(
        backgroundColor: const Color(0xFF1C1C1E),
        titleTextStyle: AppTextStyles.headline.copyWith(
          fontSize: 18,
          color: const Color(0xFFF2F2F7),
        ),
        contentTextStyle: AppTextStyles.body.copyWith(
          color: const Color(0xFFF2F2F7),
        ),
      ),
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryDark,
        onSecondary: Colors.white,
        surface: AppColors.bgPrimary,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.bgSecondary,
      fontFamily: '.SF Pro Text',

      // ─── APP BAR ────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.border,
        centerTitle: true,
        titleTextStyle: AppTextStyles.value.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.primary,
          size: 22,
        ),
      ),

      // ─── BOTTOM NAVIGATION BAR ──────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgPrimary,
        indicatorColor: AppColors.primary.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTextStyles.caption.copyWith(
            color: AppColors.textSecond,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecond, size: 24);
        }),
        elevation: 0,
        shadowColor: AppColors.border,
        surfaceTintColor: Colors.transparent,
      ),

      // ─── TAB BAR ────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecond,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: AppTextStyles.label.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.label.copyWith(
          color: AppColors.textSecond,
          fontWeight: FontWeight.w400,
        ),
        dividerColor: AppColors.border,
      ),

      // ─── INPUT DECORATION ───────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTextStyles.label.copyWith(
          color: AppColors.textSecond,
        ),
        errorStyle: AppTextStyles.error,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
      ),

      // ─── ELEVATED BUTTON ────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // ─── TEXT BUTTON ────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.label,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
      ),

      // ─── OUTLINED BUTTON ────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: AppTextStyles.button,
        ),
      ),

      // ─── CARD ───────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.bgPrimary,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderSoft),
        ),
      ),

      // ─── DIVIDER ────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSoft,
        thickness: 0.5,
        space: 0,
      ),

      // ─── CHIP ───────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgSecondary,
        labelStyle: AppTextStyles.caption,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ─── SNACK BAR ──────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ─── DIALOG ─────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: AppTextStyles.headline.copyWith(fontSize: 18),
        contentTextStyle: AppTextStyles.body,
      ),

      // ─── LIST TILE ──────────────────────────────────────
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.primary,
        titleTextStyle: AppTextStyles.body,
        subtitleTextStyle: AppTextStyles.caption,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ─── SWITCH ─────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.borderSoft;
        }),
      ),

      // ─── FLOATING ACTION BUTTON ─────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ─── PROGRESS INDICATOR ─────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }
}

/// Extensão de espaçamento — tokens de design
extension AppSpacing on double {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double section = 32.0;
}

/// Constantes de espaçamento para uso direto
class AppDimens {
  AppDimens._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double section = 32.0;

  // Bordas
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;

  // Tamanhos fixos
  static const double buttonHeight = 50.0;
  static const double inputHeight = 44.0;
  static const double cardPadding = 20.0;
  static const double screenPadding = 16.0;
  static const double iconSize = 24.0;
  static const double iconSizeSm = 20.0;
  static const double avatarSize = 48.0;
}
