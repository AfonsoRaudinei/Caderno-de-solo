// lib/data/base_dados/nc_por_referencia.dart
//
// Fonte: calibracao_padrao.dart + calibracao_controller.dart
// Valores de NC (mg/dm³) por referência bibliográfica e elemento.
//
// MANUTENÇÃO: ao adicionar nova referência, adicione bloco aqui também.
// "Personalizada" não está mapeada — usuário define NC manualmente.

/// Retorna o NC (mg/dm³) de um elemento para uma referência.
/// Retorna null se não houver mapeamento — campo não será sobrescrito.
double? getNcParaReferencia(String referenciaNome, String elemento) {
  return _ncPorReferencia[referenciaNome]?[elemento];
}

/// Nomes de referências com NC mapeado.
List<String> get referenciasComNc => _ncPorReferencia.keys.toList();

// Nomes IDÊNTICOS aos usados nos dropdowns.
const Map<String, Map<String, double>> _ncPorReferencia = {

  '06 — Micronutrientes: Motor de Cálculo': {
    'B':  0.36,
    'Cu': 0.71,
    'Fe': 19.0,  // calibracao_controller.dart
    'Mn': 6.0,
    'Zn': 0.91,
    'Mo': 0.1,
    'Co': 0.05,
    'Ni': 0.1,
    'Se': 0.05,
  },

  'EMBRAPA Soja': {
    'B':  1.0,
    'Cu': 0.8,
    'Fe': 0.0,  // TODO: verificar — não encontrado
    'Mn': 0.0,  // TODO: verificar — não encontrado
    'Zn': 0.0,  // TODO: verificar — não encontrado
    'Mo': 0.0,  // TODO: verificar — não encontrado
    'Co': 0.0,  // TODO: verificar — não encontrado
    'Ni': 0.0,  // TODO: verificar — não encontrado
    'Se': 0.0,  // TODO: verificar — não encontrado
  },

};
