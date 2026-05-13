// ignore_for_file: constant_identifier_names

/// Conversões de unidade do motor do SoloForte
/// Fonte: PROMPT/00_conversoes.md — Fancelli (2020), EMBRAPA, IAC, química analítica
library;

/// Todas as conversões e constantes usadas pelo motor agronômico
class Conversoes {
  Conversoes._();

  // ─── Fósforo ────────────────────────────────────────────────────────────
  /// P → P₂O₅ (fator de conversão)
  static const double pToP2O5 = 2.291;

  /// P₂O₅ → P (fator de conversão)
  static const double p2O5ToP = 0.437;

  // ─── Potássio ────────────────────────────────────────────────────────────
  /// K (mg/dm³) → cmolc/dm³: dividir por 391
  static const double kMgDm3Factor = 391.0;

  /// K → K₂O (fator de conversão)
  static const double kToK2O = 1.205;

  /// K₂O → K (fator de conversão)
  static const double k2OToK = 0.830;

  // ─── Cálcio ─────────────────────────────────────────────────────────────
  /// Ca → CaO (fator de conversão)
  static const double caToCaO = 1.399;

  /// CaO → Ca (fator de conversão)
  static const double caOToCa = 0.715;

  /// CaO → Ca (precisão de cálculo para calagem)
  static const double fatorCaO_Ca = 0.71428;

  // ─── Magnésio ────────────────────────────────────────────────────────────
  /// Mg → MgO (fator de conversão)
  static const double mgToMgO = 1.658;

  /// MgO → Mg (fator de conversão)
  static const double mgOToMg = 0.602;

  /// MgO → Mg (precisão de cálculo para calagem)
  static const double fatorMgO_Mg = 0.60199;

  // ─── Enxofre ─────────────────────────────────────────────────────────────
  /// S → SO₃ (fator de conversão)
  static const double sToSO3 = 2.500;

  /// SO₃ → S (fator de conversão)
  static const double sO3ToS = 0.400;

  /// S → SO₄ (fator de conversão)
  static const double sToSO4 = 2.996;

  /// SO₄ → S (fator de conversão)
  static const double sO4ToS = 0.334;

  // ─── Unidades gerais ─────────────────────────────────────────────────────
  // TODO: migrar para UnidadeConverter
  /// cmolc/dm³ → mmolc/dm³
  static const double cmolcToMmolc = 10.0;

  // TODO: migrar para UnidadeConverter
  /// mmolc/dm³ → cmolc/dm³
  static const double mmolcToCmolc = 0.1;

  /// mg/dm³ → kg/ha (camada 0-20 cm, aprovação)
  static const double mgDm3ToKgHa = 2.0;

  // ─── Profundidade/calagem ─────────────────────────────────────────────────
  /// Fator profundidade 0-20 cm
  static const double profFator020 = 1.0;

  /// Fator profundidade 0-40 cm
  static const double profFator040 = 2.03;

  /// Fator profundidade 0-60 cm
  static const double profFator060 = 3.0;

  // ─── MO ────────────────────────────────────────────────────────────────
  /// MO → Carbono Orgânico (Van Bemmelen)
  static const double moToCo = 0.580;

  /// Carbono Orgânico → MO
  static const double coToMo = 1.724;

  // ─── Equivalente-grama do gesso ──────────────────────────────────────────
  /// CaSO₄·2H₂O — peso equivalente = 87 g/eq
  static const double gessoEquivalenteGrama = 86.0;

  // ─── Poder de neutralização (PN) ─────────────────────────────────────────
  /// CaO → PN
  static const double fatorPN_CaO = 1.79;

  /// MgO → PN
  static const double fatorPN_MgO = 2.48;

  // ─── Conversões calculadas ───────────────────────────────────────────────

  /// Converte K de mg/dm³ para cmolc/dm³
  static double kMgDm3ToCmolc(double kMg) => kMg / kMgDm3Factor;

  /// Converte K de cmolc/dm³ para mg/dm³
  static double kCmolcToMgDm3(double kCmolc) => kCmolc * kMgDm3Factor;

  // TODO: migrar para UnidadeConverter
  /// Converte Ca ou Mg de mmolc/dm³ para cmolc/dm³
  static double mmolcToCmolcFn(double mmolc) => mmolc / 10.0;

  /// Converte t/ha para kg/ha
  static double tHaToKgHa(double t) => t * 1000.0;

  /// Converte kg/ha para t/ha
  static double kgHaToTHa(double kg) => kg / 1000.0;
}
