/// Motor de recomendação de micronutrientes — lê parâmetros da calibração.
///
/// Nenhum NC, eficiência ou concentração fixa no código: tudo vem do cadastro.
library;

/// Converte produção de kg/ha para t/ha.
double producaoKgHaParaTha(double kgHa) => kgHa / 1000.0;

/// Déficit = max(0, NC − teor atual).
double calcularDeficitMicronutriente({
  required double nivelCritico,
  required double teorAtual,
}) {
  return (nivelCritico - teorAtual).clamp(0.0, double.infinity);
}

/// Correção solo (g/ha elemento): déficit × 2 × 1000, depois ÷ eficiência solo.
double calcularCorrecaoSoloMicronutriente({
  required double deficit,
  required double eficienciaSoloPercent,
}) {
  if (deficit <= 0) return 0;
  final bruta = deficit * 2.0 * 1000.0;
  if (eficienciaSoloPercent <= 0) return bruta;
  return bruta / (eficienciaSoloPercent / 100.0);
}

/// Extração (g/ha) = produção (t/ha) × extração cadastrada (g/t).
double calcularExtracaoMicronutriente({
  required double producaoTha,
  required double extracaoPlantaGt,
}) {
  if (producaoTha <= 0 || extracaoPlantaGt <= 0) return 0;
  return producaoTha * extracaoPlantaGt;
}

/// Exportação (g/ha) = produção (t/ha) × exportação cadastrada (g/t).
double calcularExportacaoMicronutriente({
  required double producaoTha,
  required double exportacaoGraosGt,
}) {
  if (producaoTha <= 0 || exportacaoGraosGt <= 0) return 0;
  return producaoTha * exportacaoGraosGt;
}

/// Regra individual por elemento.
String regraPlantaOuGrao({
  required double teorAtual,
  required double nivelCritico,
}) {
  return teorAtual < nivelCritico ? 'Planta' : 'Grão';
}

/// Necessidade do nutriente conforme regra Planta/Grão.
double calcularNecessidadeMicronutriente({
  required String regra,
  required double extracaoGHa,
  required double exportacaoGHa,
}) {
  return regra == 'Planta' ? extracaoGHa : exportacaoGHa;
}

/// Fração massa do nutriente no produto conforme unidade cadastrada.
double fracaoConcentracaoFonte({
  required double concentracao,
  required String unidade,
}) {
  switch (unidade) {
    case 'g/kg':
      return concentracao / 1000.0;
    case 'g/L':
      return concentracao / 1000.0;
    case '%':
    default:
      return concentracao / 100.0;
  }
}

/// Converte dose de elemento (g/ha) em dose comercial do produto (g/ha).
double converterDoseComercialGHa({
  required double doseElementoGHa,
  required double concentracao,
  required String unidadeConcentracao,
  required double eficienciaPercent,
}) {
  if (doseElementoGHa <= 0) return 0;
  final fracao = fracaoConcentracaoFonte(
    concentracao: concentracao,
    unidade: unidadeConcentracao,
  );
  if (fracao <= 0 || eficienciaPercent <= 0) return 0;
  return doseElementoGHa / fracao / (eficienciaPercent / 100.0);
}

/// Aplica limites cadastrados de dose comercial (g/ha).
double aplicarLimitesDoseComercial({
  required double doseComercialGHa,
  required double doseMinima,
  required double doseMaxima,
}) {
  var dose = doseComercialGHa;
  if (doseMinima > 0 && dose < doseMinima) dose = doseMinima;
  if (doseMaxima > 0 && dose > doseMaxima) dose = doseMaxima;
  return dose;
}

String rotuloDoseComercial(double doseGHa) {
  if (doseGHa >= 1000) {
    final kg = doseGHa / 1000.0;
    final texto = kg.toStringAsFixed(2).replaceAll('.', ',');
    return '$texto kg/ha produto';
  }
  final texto = doseGHa.toStringAsFixed(1).replaceAll('.', ',');
  return '$texto g/ha produto';
}

String unidadeDoseComercial(double doseGHa) {
  return doseGHa >= 1000 ? 'kg/ha' : 'g/ha';
}

/// Eficiência do grupo conforme via (nunca mistura vias).
double eficienciaGrupoPorVia({
  required String via,
  required double eficienciaSolo,
  required double eficienciaFoliar,
  required double eficienciaTs,
}) {
  switch (via) {
    case 'Foliar':
      return eficienciaFoliar;
    case 'TS':
      return eficienciaTs;
    case 'Solo':
    default:
      return eficienciaSolo;
  }
}

/// Escolhe via principal: primeira do grupo permitida no elemento.
String? viaPrincipalMicronutriente({
  required List<String> viasGrupo,
  required List<String> viasElemento,
}) {
  for (final via in viasGrupo) {
    if (viasElemento.contains(via)) return via;
  }
  return viasElemento.isNotEmpty ? viasElemento.first : null;
}

/// Dose de elemento (g/ha) conforme via e déficit.
double doseElementoPorVia({
  required String via,
  required double correcaoSoloGHa,
  required double necessidadeGHa,
  required double deficit,
}) {
  if (via == 'Solo' && deficit > 0) return correcaoSoloGHa;
  return necessidadeGHa;
}
