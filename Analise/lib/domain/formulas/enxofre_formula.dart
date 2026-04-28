import 'package:soloforte/domain/entities/analise_completa.dart';

class EnxofreFormula {
  const EnxofreFormula._();

  static double? calcular(AnaliseCompleta analise) {
    final s = analise.s020.isValido
        ? analise.s020.valor
        : (analise.s2040.isValido ? analise.s2040.valor : null);
    if (s == null) return null;
    if (s < 10) return 20;
    if (s < 20) return 10;
    return 0;
  }
}
