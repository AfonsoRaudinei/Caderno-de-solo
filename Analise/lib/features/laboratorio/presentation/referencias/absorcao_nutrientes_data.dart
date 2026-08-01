export 'package:soloforte/features/laboratorio/domain/data/absorcao_nutrientes_catalog.dart';

import 'package:flutter/material.dart';

/// Cores de marca da tela de absorção + helpers light/dark alinhados à
/// [AppThemePalette] (sem duplicar hex solto nas telas).
abstract class AbsorcaoNutrientesCores {
  static const Color greenDark = Color(0xFF0D2818);
  static const Color greenMid = Color(0xFF1A4A2E);
  static const Color greenAccent = Color(0xFF3DD68C);
  static const Color greenPale = Color(0xFFF0F7F2);
  static const Color textMuted = Color(0xFF8FA89A);

  /// Texto secundário / labels — WCAG ≥ 4.5:1 em dark.
  static Color mutedText({required bool isDark}) =>
      isDark ? const Color(0xFFAEAEB2) : textMuted;

  static Color titleColor({required bool isDark}) =>
      isDark ? const Color(0xFFF2F2F7) : greenDark;

  static Color valueColor({required bool isDark}) =>
      isDark ? const Color(0xFFF2F2F7) : greenDark;

  static Color inputFill({required bool isDark}) =>
      isDark ? const Color(0xFF1C1C1E) : greenPale;

  static Color sectionSwitcherBg({required bool isDark}) =>
      isDark ? const Color(0xFF1C1C1E) : greenPale;

  static Color sectionSwitcherBorder({required bool isDark}) =>
      isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5E7);
}
