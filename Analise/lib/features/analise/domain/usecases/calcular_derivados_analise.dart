class CalcularDerivadosAnalise {
  const CalcularDerivadosAnalise();

  Map<String, double> call(Map<String, dynamic> analise) {
    double n(String key) => (analise[key] as num?)?.toDouble() ?? 0.0;

    final ca = n('ca');
    final mg = n('mg');
    final k = n('k');
    final na = n('na');
    final al = n('al');
    final hMaisAl = n('hMaisAl');

    final sb = ca + mg + k + na;
    final ctcTotal = sb + hMaisAl;
    final ctcEfetiva = sb + al;

    double pct(double part, double total) {
      if (total == 0) return 0.0;
      return (part / total) * 100.0;
    }

    double rel(double a, double b) {
      if (b == 0) return 0.0;
      return a / b;
    }

    final vPct = pct(sb, ctcTotal);
    final mPct = pct(al, ctcEfetiva);

    final caPctT = pct(ca, ctcTotal);
    final mgPctT = pct(mg, ctcTotal);
    final kPctT = pct(k, ctcTotal);
    final hAlPctT = pct(hMaisAl, ctcTotal);

    final relCaMg = rel(ca, mg);
    final relCaK = rel(ca, k);
    final relMgK = rel(mg, k);
    final relCaMgT = pct(ca + mg, ctcTotal);

    return {
      'sb': sb,
      'ctcTotal': ctcTotal,
      'ctcEfetiva': ctcEfetiva,
      'vPct': vPct,
      'mPct': mPct,
      'caPctT': caPctT,
      'mgPctT': mgPctT,
      'kPctT': kPctT,
      'hAlPctT': hAlPctT,
      'relCaMg': relCaMg,
      'relCaK': relCaK,
      'relMgK': relMgK,
      'relCaMgT': relCaMgT,
    };
  }
}
