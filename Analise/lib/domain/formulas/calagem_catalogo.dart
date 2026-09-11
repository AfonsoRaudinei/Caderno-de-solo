/// Catálogo visível de calcário e métodos de calagem na Calibração.
///
/// Métodos ② EMBRAPA, ③ Ca+Mg e ⑦ Correção Mg permanecem no motor,
/// mas saíram do dropdown. A fórmula de ⑧ CA+CD vive em
/// CalcarioFormula.calcularNcCaCd / CalcarioFormula.metodoCaCd.
class CalagemCatalogo {
  const CalagemCatalogo._();

  static const tipoDolomitico = 'Dolomítico';
  static const tipoCalcitico = 'Calcítico';

  static const tiposCalcarioVisiveis = [
    tipoDolomitico,
    tipoCalcitico,
  ];

  static const metodoSaturacaoV = '① Saturação por Bases (V%)';
  static const metodoSupercalagem = '④ Supercalagem';
  static const metodoAlbrecht = '⑤ Albrecht';
  static const metodoAlbrechtY = '⑥ Albrecht + Y';
  static const metodoCaCd = '⑧ CA+CD';

  static const legendaCaCd =
      'Neutralização de Al³⁺ e elevação dos teores de Ca²⁺ e Mg²⁺.';

  static const metodosCorretiva = [
    metodoSaturacaoV,
    metodoSupercalagem,
    metodoAlbrecht,
    metodoAlbrechtY,
    metodoCaCd,
  ];

  static const metodosManutencaoPd = [
    metodoSaturacaoV,
    metodoAlbrecht,
    metodoAlbrechtY,
  ];

  static bool isCaCd(String metodo) {
    final texto = metodo.trim();
    return texto.startsWith('⑧') || texto.contains('CA+CD');
  }

  /// Migra tipo/método ocultos para Dolomítico e Saturação por Bases (V%).
  static Map<String, dynamic> sanitizarCorretivos(
    Map<String, dynamic> corretivos,
  ) {
    final atualizado = Map<String, dynamic>.from(corretivos);
    var mudou = false;

    final tipoCalcario = atualizado['tipoCalcario']?.toString() ?? '';
    if (!tiposCalcarioVisiveis.contains(tipoCalcario)) {
      atualizado['tipoCalcario'] = tipoDolomitico;
      mudou = true;
    }

    final tipoCalagem = atualizado['tipoCalagem']?.toString() ?? 'Corretiva';
    final metodos =
        tipoCalagem == 'Manutenção PD' ? metodosManutencaoPd : metodosCorretiva;
    final metodo = atualizado['metodoCalagem']?.toString() ?? '';
    if (!metodos.contains(metodo)) {
      atualizado['metodoCalagem'] = metodoSaturacaoV;
      mudou = true;
    }

    return mudou ? atualizado : corretivos;
  }
}
