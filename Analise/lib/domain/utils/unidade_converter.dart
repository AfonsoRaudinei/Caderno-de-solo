/// Centraliza toda normalização de unidades do sistema Caderno de Solo.
///
/// Unidades padrão internas:
///   - Cátions (K, Ca, Mg, Al, H+Al, CTC, SB) → cmolc/dm³
///   - Nutrientes (P, S, Zn, B, Cu, Fe, Mn)   → mg/dm³
///   - Matéria Orgânica (MO)                   → g/dm³
///   - Granulometria (Argila, Silte, Areia)    → %
class UnidadeConverter {

  // ═══════════════════════════════════════════════════════
  // CÁTIONS — normalizar para cmolc/dm³
  // ═══════════════════════════════════════════════════════

  /// Normaliza um cátion (K, Ca, Mg, Al, H+Al, CTC, SB) para cmolc/dm³.
  ///
  /// Unidades aceitas (case-insensitive):
  ///   'cmolc/dm3', 'cmolc/dm³', 'cmolc', 'cmol' → sem conversão
  ///   'mmolc/dm3', 'mmolc/dm³', 'mmolc', 'mmol' → divide por 10
  ///
  /// Lança [ArgumentError] se a unidade for desconhecida.
  static double normalizarCation(double valor, String unidade) {
    final u = unidade.trim().toLowerCase();
    if (u.contains('cmolc') || u == 'cmol') {
      return valor;
    }
    if (u.contains('mmolc') || u == 'mmol') {
      return valor / 10.0;
    }
    throw ArgumentError(
      'UnidadeConverter: unidade de cátion desconhecida → "$unidade". '
      'Esperado: cmolc/dm³ ou mmolc/dm³.',
    );
  }

  // ═══════════════════════════════════════════════════════
  // NUTRIENTES — normalizar para mg/dm³
  // ═══════════════════════════════════════════════════════

  /// Normaliza P, S, Zn, B, Cu, Fe, Mn para mg/dm³.
  ///
  /// Unidades aceitas (tratadas como equivalentes 1:1):
  ///   'mg/dm3', 'mg/dm³', 'ppm', 'mg/l', 'mg/kg'
  ///
  /// Nota técnica: ppm em solo e mg/dm³ são equivalentes na prática
  /// laboratorial brasileira (densidade bulk ≈ 1 g/cm³).
  static double normalizarNutriente(double valor, String unidade) {
    final u = unidade.trim().toLowerCase();
    if (u.contains('mg') || u == 'ppm') {
      return valor;
    }
    throw ArgumentError(
      'UnidadeConverter: unidade de nutriente desconhecida → "$unidade". '
      'Esperado: mg/dm³ ou ppm.',
    );
  }

  // ═══════════════════════════════════════════════════════
  // MATÉRIA ORGÂNICA — normalizar para g/dm³
  // ═══════════════════════════════════════════════════════

  /// Normaliza Matéria Orgânica (MO) para g/dm³.
  ///
  /// Conversões:
  ///   %      → g/dm³ = valor × 10    (ex: 3%     = 30 g/dm³)
  ///   g/kg   → g/dm³ = valor ÷ 10   (ex: 30 g/kg = 3 g/dm³... ver nota)
  ///   dag/kg → g/dm³ = valor × 1     (ex: 3 dag/kg = 30 g/dm³)
  ///   g/dm³  → sem conversão
  ///
  /// Nota: em solo brasileiro, 1 g/dm³ ≈ 1 g/kg quando density bulk ≈ 1.
  /// A conversão segue tabelas da EMBRAPA/IAC para coerência com as
  /// fórmulas já existentes em `conversoes.dart`.
  static double normalizarMO(double valor, String unidade) {
    final u = unidade.trim().toLowerCase();
    switch (u) {
      case '%':
        return valor * 10.0;
      case 'g/kg':
        return valor / 10.0;
      case 'dag/kg':
        return valor;
      case 'g/dm3':
      case 'g/dm³':
        return valor;
      default:
        throw ArgumentError(
          'UnidadeConverter: unidade de MO desconhecida → "$unidade". '
          'Esperado: %, g/dm³, g/kg ou dag/kg.',
        );
    }
  }

  // ═══════════════════════════════════════════════════════
  // GRANULOMETRIA — normalizar para %
  // ═══════════════════════════════════════════════════════

  /// Normaliza Argila, Silte ou Areia para %.
  ///
  /// Conversões:
  ///   %      → sem conversão
  ///   g/kg   → % = valor ÷ 10   (ex: 600 g/kg = 60%)
  ///   dag/kg → % = valor         (ex: 60 dag/kg = 60%)
  static double normalizarGranulometria(double valor, String unidade) {
    final u = unidade.trim().toLowerCase();
    switch (u) {
      case '%':
        return valor;
      case 'g/kg':
        return valor / 10.0;
      case 'dag/kg':
        return valor;
      default:
        throw ArgumentError(
          'UnidadeConverter: unidade de granulometria desconhecida → "$unidade". '
          'Esperado: %, g/kg ou dag/kg.',
        );
    }
  }

  // ═══════════════════════════════════════════════════════
  // INFERÊNCIA INTELIGENTE — K sem unidade declarada
  // ═══════════════════════════════════════════════════════

  /// Infere a unidade do K quando ela não está declarada na análise.
  ///
  /// Regra heurística agrícola:
  ///   K > 1,5 → muito alto para cmolc (solo muito fértil tem até 1,2).
  ///             Provavelmente está em mmolc/dm³ → converte dividindo por 10.
  ///   K ≤ 1,5 → faixa plausível para cmolc/dm³ → usa diretamente.
  ///
  /// ATENÇÃO: Retorna [InferenciaUnidadeResult] com o valor normalizado
  /// e um flag [unidadeInferida] = true para que a camada de apresentação
  /// possa exibir aviso ao usuário.
  static InferenciaUnidadeResult inferirEConverterK(double valor) {
    if (valor > 1.5) {
      return InferenciaUnidadeResult(
        valorNormalizado: valor / 10.0,
        unidadeInferida: true,
        unidadeDetectada: 'mmolc/dm³',
        aviso:
            'K = $valor recebido sem unidade declarada. '
            'Valor acima de 1,5 indica mmolc/dm³. '
            'Convertido automaticamente para ${valor / 10.0} cmolc/dm³. '
            'Verifique o laudo do laboratório.',
      );
    }
    return InferenciaUnidadeResult(
      valorNormalizado: valor,
      unidadeInferida: true,
      unidadeDetectada: 'cmolc/dm³',
      aviso:
          'K = $valor recebido sem unidade declarada. '
          'Valor dentro da faixa cmolc/dm³ (≤ 1,5). '
          'Usado diretamente. Verifique o laudo do laboratório.',
    );
  }

  // ═══════════════════════════════════════════════════════
  // HELPER — Converter g/dm³ para exibição em %
  // ═══════════════════════════════════════════════════════

  /// Converte MO de g/dm³ para % apenas para exibição na UI.
  ///
  /// Uso: mostrar "28 g/dm³ (Médio — 2,8%)" na barra de granulometria.
  /// Não altera o valor armazenado internamente.
  static double moGdm3ParaPercentual(double valorGdm3) {
    return valorGdm3 / 10.0;
  }
}

// ═══════════════════════════════════════════════════════
// RESULTADO DE INFERÊNCIA
// ═══════════════════════════════════════════════════════

/// Carrega o resultado de uma inferência automática de unidade.
///
/// Usado quando o laboratório não declara a unidade do nutriente.
class InferenciaUnidadeResult {
  final double valorNormalizado;
  final bool unidadeInferida;
  final String unidadeDetectada;
  final String aviso;

  const InferenciaUnidadeResult({
    required this.valorNormalizado,
    required this.unidadeInferida,
    required this.unidadeDetectada,
    required this.aviso,
  });
}