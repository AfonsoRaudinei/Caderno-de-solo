// ignore_for_file: non_constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';

part 'analise_solo.freezed.dart';
part 'analise_solo.g.dart';

/// Entidade principal de análise de solo (PROMPT 07)
/// Todas as grandezas em cmolc/dm³ (exceto P, S, micro em mg/dm³, argila em %)
@freezed
class AnaliseSolo with _$AnaliseSolo {
  const factory AnaliseSolo({
    required String id,

    // ─── Identificação ───────────────────────────────────────
    @Default('') String clienteNome,
    @Default('') String fazendaNome,
    @Default('') String talhaoNome,
    @Default('') String cultura,
    @Default('') String laboratorio,
    String? data,

    // ─── pH ──────────────────────────────────────────────────
    /// pH em CaCl₂ 0,01 mol/L
    @Default(0.0) double pH,

    /// pH em água
    @Default(0.0) double phAgua,

    /// pH tampão SMP (para calcular H+Al)
    @Default(0.0) double phSmp,

    // ─── Matéria Orgânica ─────────────────────────────────────
    /// MO em g/dm³
    @Default(0.0) double MO,

    // ─── Macronutrientes (cmolc/dm³) ─────────────────────────
    /// Cálcio trocável (cmolc/dm³)
    @Default(0.0) double Ca,

    /// Magnésio trocável (cmolc/dm³)
    @Default(0.0) double Mg,

    /// Potássio trocável (cmolc/dm³ — converter de mg/dm³ se necessário)
    @Default(0.0) double K,

    /// Acidez potencial H+Al (cmolc/dm³)
    @Default(0.0) double HAl,

    /// Alumínio trocável (cmolc/dm³)
    @Default(0.0) double Al,

    // ─── Fósforo e P-rem ─────────────────────────────────────
    /// Fósforo disponível (mg/dm³)
    @Default(0.0) double P,

    /// Fósforo remanescente (P-rem) em mg/L — para calcular Y
    double? Prem,

    /// Extrator de fósforo utilizado
    @Default('Resina') String extrator,

    // ─── Textura ──────────────────────────────────────────────
    /// Argila em % (0–100)
    @Default(0.0) double argila,

    // ─── Enxofre (mg/dm³) ────────────────────────────────────
    @Default(0.0) double S,

    // ─── Micronutrientes (mg/dm³) ────────────────────────────
    @Default(0.0) double B,
    @Default(0.0) double Cu,
    @Default(0.0) double Fe,
    @Default(0.0) double Mn,
    @Default(0.0) double Zn,

    // ─── Geolocalização ──────────────────────────────────────
    @Default(0.0) double latitude,
    @Default(0.0) double longitude,
    @Default('') String endereco,

    // ─── Calculados automaticamente ───────────────────────────
    // Nota: SB, CTC, Vat, mat calculados pelo motor dinamicamente.
    // Podem ser cacheados aqui após o cálculo.
    @Default(0.0) double SB, // Soma de Bases = Ca + Mg + K
    @Default(0.0) double CTC, // Capacidade de Troca = SB + H+Al
    @Default(0.0) double Vat, // Saturação por bases V% = SB/CTC × 100
    @Default(0.0) double mat, // Saturação por Al m% = Al/(SB+Al) × 100
    @Default(0.0) double Y, // Buffer Y calculado pela argila/P-rem
  }) = _AnaliseSolo;

  factory AnaliseSolo.fromJson(Map<String, dynamic> json) =>
      _$AnaliseSoloFromJson(json);

  /// Cria AnaliseSolo vazia para formulário novo
  factory AnaliseSolo.empty() => const AnaliseSolo(id: '');
}
