import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';

/// Hierarquia tipográfica do SoloForte — iOS/Apple Design System
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle _base = TextStyle(
    fontFamily: '.SF Pro Text', // iOS nativo; Roboto como fallback Android
    color: AppColors.textPrimary,
    decoration: TextDecoration.none,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Títulos de seção (uppercase, discreto) — 12px, w500
  static final TextStyle sectionLabel = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecond,
  );

  /// Texto normal — 15px, w400
  static final TextStyle body = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  /// Labels e subtítulos — 14px, w500
  static final TextStyle label = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// Valores destacados (resultados, ROI) — 17px, w600
  static final TextStyle value = _base.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  /// Título grande — resultado principal — 22px, w700
  static final TextStyle headline = _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  /// Título grande de tela — 28px, w700
  static final TextStyle largeTitle = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  /// Texto pequeno — branding, rodapé — 12px, w400
  static final TextStyle caption = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecond,
  );

  /// Texto de botão — 16px, w600
  static final TextStyle button = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  /// Texto de input — 15px, w400
  static final TextStyle input = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  /// Erro de validação — 12px, w400, vermelho
  static final TextStyle error = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
  );
}
