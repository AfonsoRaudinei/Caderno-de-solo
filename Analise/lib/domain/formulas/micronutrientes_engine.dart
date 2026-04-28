// ignore_for_file: constant_identifier_names

enum ElementoMicro { B, Cu, Fe, Mn, Zn, Mo, Co, Ni, Se }

enum ClasseMicro { muitoBaixo, baixo, medio, alto, muitoAlto }

class ResultadoMicro {
  const ResultadoMicro({
    required this.doseProduto,
    required this.unidade,
    required this.classe,
    this.doseElemento = 0.0,
    this.avisos = const <String>[],
  });

  final double doseProduto;
  final String unidade;
  final ClasseMicro classe;
  final double doseElemento;
  final List<String> avisos;
}

class MicronutrientesEngine {
  MicronutrientesEngine._();

  static const Map<
      ElementoMicro,
      ({
        double baixoMin,
        double baixoMax,
        double medioMin,
        double medioMax,
        double altoMin,
        double altoMax,
      })> _limites = {
    // Tabela Fancelli 2020:
    // B: MB<0.20, B:0.21-0.35, M:0.36-0.60, A:0.61-0.90, MA>0.90
    ElementoMicro.B: (
      baixoMin: 0.21,
      baixoMax: 0.35,
      medioMin: 0.36,
      medioMax: 0.60,
      altoMin: 0.61,
      altoMax: 0.90,
    ),
    // Cu: MB<0.30, B:0.31-0.70, M:0.71-1.20, A:1.21-1.80, MA>1.80
    ElementoMicro.Cu: (
      baixoMin: 0.31,
      baixoMax: 0.70,
      medioMin: 0.71,
      medioMax: 1.20,
      altoMin: 1.21,
      altoMax: 1.80,
    ),
    // Fe: MB<8, B:9-18, M:19-30, A:31-45, MA>45
    ElementoMicro.Fe: (
      baixoMin: 9.0,
      baixoMax: 18.0,
      medioMin: 19.0,
      medioMax: 30.0,
      altoMin: 31.0,
      altoMax: 45.0,
    ),
    // Mn: MB<2, B:3-5, M:6-8, A:9-12, MA>12
    ElementoMicro.Mn: (
      baixoMin: 3.0,
      baixoMax: 5.0,
      medioMin: 6.0,
      medioMax: 8.0,
      altoMin: 9.0,
      altoMax: 12.0,
    ),
    // Zn: MB<0.40, B:0.41-0.90, M:0.91-1.50, A:1.51-2.20, MA>2.20
    ElementoMicro.Zn: (
      baixoMin: 0.41,
      baixoMax: 0.90,
      medioMin: 0.91,
      medioMax: 1.50,
      altoMin: 1.51,
      altoMax: 2.20,
    ),
  };

  static bool _temNc(ElementoMicro e) => _limites.containsKey(e);

  static bool temReferenciaNc(ElementoMicro e) => _temNc(e);

  static double nivelCritico(ElementoMicro e) {
    final l = _limites[e];
    if (l == null) return 0.0;
    return l.medioMax;
  }

  static ClasseMicro classificar(ElementoMicro e, double teor) {
    final l = _limites[e];
    if (l == null) return ClasseMicro.medio;
    if (teor < l.baixoMin) return ClasseMicro.muitoBaixo;
    if (teor <= l.baixoMax) return ClasseMicro.baixo;
    if (teor <= l.medioMax) return ClasseMicro.medio;
    if (teor <= l.altoMax) return ClasseMicro.alto;
    return ClasseMicro.muitoAlto;
  }

  /// Via solo:
  /// dose_elem_g = deficit × 2 × 1000 × (pct/100)
  /// dose_produto = dose_elem_g / (teor/100) / (efic/100) / 1000
  static ResultadoMicro calcularViaSolo({
    required ElementoMicro elemento,
    required double teorSolo,
    required double percentualCorrecao,
    required double teorFonte,
    required double eficiencia,
  }) {
    final classe = classificar(elemento, teorSolo);
    final nc = nivelCritico(elemento);
    final avisos = <String>[];
    if (!_temNc(elemento)) {
      avisos.add('Micronutriente $elemento sem referência de NC.');
    }

    final deficit =
        _temNc(elemento) ? (nc - teorSolo).clamp(0.0, double.infinity) : 0.0;
    final doseElemG = deficit * 2.0 * 1000.0 * (percentualCorrecao / 100.0);
    final divisor = (teorFonte / 100.0) * (eficiencia / 100.0) * 1000.0;
    final doseProduto = divisor > 0 ? doseElemG / divisor : 0.0;

    return ResultadoMicro(
      doseProduto: doseProduto,
      unidade: 'kg/ha',
      classe: classe,
      doseElemento: doseElemG,
      avisos: avisos,
    );
  }

  /// Via foliar:
  /// dose_produto = dose_elemento / (teor/100) / (efic_foliar/100)
  static ResultadoMicro calcularViaFoliar({
    required ElementoMicro elemento,
    required double teorSolo,
    required double doseElemento,
    required double teorFonte,
    required double eficienciaFoliar,
  }) {
    final classe = classificar(elemento, teorSolo);
    final divisor = (teorFonte / 100.0) * (eficienciaFoliar / 100.0);
    final doseProduto = divisor > 0 ? doseElemento / divisor : 0.0;
    return ResultadoMicro(
      doseProduto: doseProduto,
      unidade: 'g/ha',
      classe: classe,
      doseElemento: doseElemento,
    );
  }

  /// Via grupo (produto formulado multimicro):
  /// dose_E = dose_elemento_E / (teor_E/100) / (efic_grupo/100)
  /// dose_grupo = max(dose_E)
  static ResultadoMicro calcularViaGrupo({
    required Map<ElementoMicro, double> doseElementoPorElemento,
    required Map<ElementoMicro, double> teorNoProdutoPorElemento,
    required double eficienciaGrupo,
  }) {
    double doseGrupo = 0.0;
    for (final entry in doseElementoPorElemento.entries) {
      final teor = teorNoProdutoPorElemento[entry.key] ?? 0.0;
      final divisor = (teor / 100.0) * (eficienciaGrupo / 100.0);
      if (divisor <= 0) continue;
      final doseE = entry.value / divisor;
      if (doseE > doseGrupo) doseGrupo = doseE;
    }
    return ResultadoMicro(
      doseProduto: doseGrupo,
      unidade: 'g/ha',
      classe: ClasseMicro.medio,
    );
  }
}
