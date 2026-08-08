import 'package:flutter/material.dart';

/// Paleta de cores do SoloForte — iOS/Apple Design System
class AppColors {
  AppColors._();

  // ─── PRIMÁRIAS ────────────────────────────────────────────
  static const Color primary = Color(0xFF007AFF); // Azul iOS
  static const Color primaryDark = Color(0xFF0051D5); // Azul escuro (gradient)

  // ─── MODO BLACK (contrato soloforte-blackmode) ────────────
  static const Color blackBackground = Color(0xFF0D0D0D);
  static const Color blackSurface = Color(0xFF1C1C1E);
  static const Color blackSurfaceAlt = Color(0xFF242426);
  static const Color blackBorder = Color(0xFF2C2C2E);
  static const Color blackTextPrimary = Color(0xFFFFFFFF);
  static const Color blackTextSecondary = Color(0xFFA0A0A5);
  static const Color blackTextDisabled = Color(0xFF5C5C5E);
  static const Color accentSecondary = Color(0xFF1428A0); // Azul Samsung
  static const Color accentSecondaryVariant = Color(0xFF0F1E7A);

  // ─── BACKGROUNDS ─────────────────────────────────────────
  static const Color bgPrimary = Color(0xFFFFFFFF); // Branco
  static const Color bgSecondary = Color(0xFFF5F5F7); // Cinza muito claro
  static const List<Color> bgGradient = [
    Color(0xFFF5F5F7),
    Color(0xFFE5E5E7),
  ];

  // ─── TEXTO ───────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1D1D1F); // Preto suave
  static const Color textSecond = Color(0xFF86868B); // Cinza médio
  static const Color textTertiary = Color(0xFFC7C7CC); // Cinza claro

  // ─── ESTADO ──────────────────────────────────────────────
  static const Color success = Color(0xFF34C759); // Verde iOS
  static const Color error = Color(0xFFFF3B30); // Vermelho iOS
  static const Color warning = Color(0xFFFF9500); // Laranja iOS
  static const Color bgSuccess = Color(0xFFE8F5E9); // Fundo positivo
  static const Color bgError = Color(0xFFFFEBEE); // Fundo negativo
  static const Color bgWarning = Color(0xFFFFF3E0); // Fundo alerta

  // ─── BORDAS ──────────────────────────────────────────────
  static const Color border = Color(0xFFD1D1D6); // Borda padrão
  static const Color borderSoft = Color(0xFFE5E5E7); // Borda suave

  // ─── NUTRIENTES (cards de calibração) ───────────────────
  static const Color calcario = Color(0xFF5AC8FA); // Azul claro
  static const Color gesso = Color(0xFFFFCC00); // Amarelo
  static const Color potassio = Color(0xFFFF9500); // Laranja
  static const Color fosforo = Color(0xFFFF3B30); // Vermelho
  static const Color enxofre = Color(0xFF34C759); // Verde
  static const Color micronut = Color(0xFFAF52DE); // Roxo

  // ─── GRADIENTES ──────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient blackAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentSecondary, accentSecondaryVariant],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: bgGradient,
  );
}
