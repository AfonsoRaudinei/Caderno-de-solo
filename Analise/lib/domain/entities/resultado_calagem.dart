// ignore_for_file: non_constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';

part 'resultado_calagem.freezed.dart';
part 'resultado_calagem.g.dart';

/// Método de calagem — 7 métodos do SoloForte
/// Fonte: PROMPT/01_calagem.md · Março 2026
enum MetodoCalagem {
  /// ① Saturação por Bases (V%) — Método preferencial Cerrado
  saturacaoBases,

  /// ② Tradicional EMBRAPA (H+Al × Fator)
  embrapa,

  /// ③ NC = Ca + Mg (clássico, uso limitado)
  caMg,

  /// ④ Supercalagem — Dose fixa para solos muito ácidos
  supercalagem,

  /// ⑤ Albrecht — Equilíbrio de bases Ca/Mg/K na CTC
  albrecht,

  /// ⑥ Albrecht com Tampão Y — Albrecht com dose mínima = Y
  albrechtY,

  /// ⑦ Correção Direcionada de Mg
  correcaoMg,
}

extension MetodoCalagemExt on MetodoCalagem {
  String get nome {
    switch (this) {
      case MetodoCalagem.saturacaoBases:
        return 'Saturação por Bases (V%)';
      case MetodoCalagem.embrapa:
        return 'EMBRAPA (H+Al × Fator)';
      case MetodoCalagem.caMg:
        return 'Ca + Mg';
      case MetodoCalagem.supercalagem:
        return 'Supercalagem (Dose Fixa)';
      case MetodoCalagem.albrecht:
        return 'Albrecht (Equilíbrio de Bases)';
      case MetodoCalagem.albrechtY:
        return 'Albrecht com Tampão Y';
      case MetodoCalagem.correcaoMg:
        return 'Correção Direcionada de Mg';
    }
  }
}

/// Fatores Ca e Mg por tipo de calcário
/// Fonte: 01_calagem.md seção 4.3
class FatoresCalcario {
  const FatoresCalcario._();

  /// Dolomítico — Ca=0,536 | Mg=0,443
  static const double dolomiticoCa = 0.536;
  static const double dolomiticoMg = 0.443;

  /// Calcítico — Ca=0,800 | Mg=0,050
  static const double calciticoCa = 0.800;
  static const double calciticoMg = 0.050;

  /// Magnesiano — Ca=0,600 | Mg=0,300
  static const double magnesianoCA = 0.600;
  static const double magnesianoMg = 0.300;

  static double getFatorCa(String tipo) {
    switch (tipo) {
      case 'Calcítico':
        return calciticoCa;
      case 'Magnesiano':
        return magnesianoCA;
      case 'Dolomítico':
      default:
        return dolomiticoCa;
    }
  }

  static double getFatorMg(String tipo) {
    switch (tipo) {
      case 'Calcítico':
        return calciticoMg;
      case 'Magnesiano':
        return magnesianoMg;
      case 'Dolomítico':
      default:
        return dolomiticoMg;
    }
  }
}

/// Resultado completo de calagem
/// Fonte: PROMPT/01_calagem.md seção 7
@freezed
class ResultadoCalagem with _$ResultadoCalagem {
  const factory ResultadoCalagem({
    required MetodoCalagem metodo,

    // ─── Dose calculada ──────────────────────────────────────
    /// NC base, sem correções (t/ha)
    @Default(0.0) double ncBase,

    /// NC ajustada pela profundidade (t/ha)
    @Default(0.0) double ncProfundidade,

    /// NC ajustada por PRNT (t/ha)
    @Default(0.0) double ncPRNT,

    /// Dose final após todas as correções (t/ha)
    @Default(0.0) double doseFinal,

    // ─── Nutrientes adicionados pelo calcário ─────────────────
    /// Ca adicionado (cmolc/dm³)  — Dose × FatorCa
    @Default(0.0) double caAdicionado,

    /// Mg adicionado (cmolc/dm³)  — Dose × FatorMg
    @Default(0.0) double mgAdicionado,

    // ─── Novas saturações após calagem (Seção 7 do 01_calagem.md) ───
    /// Nova CTC estimada após calagem
    @Default(0.0) double CTCnova,

    /// % Ca na CTC após calagem
    @Default(0.0) double pctCa,

    /// % Mg na CTC após calagem
    @Default(0.0) double pctMg,

    /// % K na CTC após calagem
    @Default(0.0) double pctK,

    /// V% final estimada após calagem
    @Default(0.0) double vPctFinal,

    // ─── Metadados ─────────────────────────────────────────────
    /// V2 desejado (Método 1 - Saturação por Bases)
    @Default(0.0) double v2Desejado,

    /// PRNT % do calcário utilizado
    @Default(100.0) double prntAplicado,

    /// Fator de profundidade
    @Default(1.0) double profFator,

    /// Fator de superfície de contato
    @Default(1.0) double scFator,

    /// Tipo de calcário (Dolomítico / Calcítico / Magnesiano)
    @Default('Dolomítico') String tipoCalcario,

    /// Valor Y usado no cálculo
    @Default(0.0) double yUtilizado,

    /// Mensagens diagnósticas
    @Default([]) List<String> observacoes,
  }) = _ResultadoCalagem;

  factory ResultadoCalagem.fromJson(Map<String, dynamic> json) =>
      _$ResultadoCalagemFromJson(json);
}
