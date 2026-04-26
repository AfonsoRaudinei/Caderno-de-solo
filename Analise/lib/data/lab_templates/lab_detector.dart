class LabDetectionCandidate {
  final String labId;
  final double score;
  final double confidence;
  final List<String> matchedSignals;

  const LabDetectionCandidate({
    required this.labId,
    required this.score,
    required this.confidence,
    required this.matchedSignals,
  });
}

class LabDetectionResult {
  final String? labId;
  final double confidence;
  final List<LabDetectionCandidate> ranking;
  final bool needsFallback;

  const LabDetectionResult({
    required this.labId,
    required this.confidence,
    required this.ranking,
    required this.needsFallback,
  });
}

class _SignalRule {
  final RegExp regex;
  final double weight;
  final String label;

  const _SignalRule(this.regex, this.weight, this.label);
}

class LabDetector {
  const LabDetector._();

  static const Set<String> supportedLabs = {
    'sellar',
    'exata_brasil',
    'ibra',
    'mb',
  };

  static final Map<String, List<_SignalRule>> _rules = {
    'sellar': [
      _SignalRule(
          RegExp(r'sellar\s+an[aá]lises\s+agr[íi]colas', caseSensitive: false),
          0.35,
          'brand_sellar'),
      _SignalRule(RegExp(r'laudo\s+n[ºo]\s*\d+/\d{4}', caseSensitive: false),
          0.12, 'laudo_numero'),
      _SignalRule(RegExp(r'n[úu]mero\s+sellar', caseSensitive: false), 0.22,
          'numero_sellar'),
      _SignalRule(
          RegExp(r'an[aá]lise\s+granulom[ée]trica', caseSensitive: false),
          0.16,
          'granulometrica'),
      _SignalRule(RegExp(r'extratores:.*mehlich', caseSensitive: false), 0.12,
          'extratores'),
    ],
    'exata_brasil': [
      _SignalRule(
          RegExp(r'exata\s+brasil', caseSensitive: false), 0.26, 'brand_exata'),
      _SignalRule(RegExp(r'software\s+ultra\s+lims', caseSensitive: false),
          0.18, 'ultra_lims'),
      _SignalRule(RegExp(r'relat[oó]rio\s+de\s+ensaio', caseSensitive: false),
          0.14, 'relatorio_ensaio'),
      _SignalRule(RegExp(r'sba\d{2}\.\d{5}', caseSensitive: false), 0.25,
          'sample_id_sba'),
      _SignalRule(
          RegExp(r'k\s*\(nh4cl\)', caseSensitive: false), 0.14, 'k_nh4cl'),
      _SignalRule(RegExp(r'contato@exatabrasil\.com\.br', caseSensitive: false),
          0.1, 'domain_exata'),
    ],
    'ibra': [
      _SignalRule(
          RegExp(r'instituto\s+brasileiro\s+de\s+an[áa]lises',
              caseSensitive: false),
          0.3,
          'brand_ibra'),
      _SignalRule(
          RegExp(r'ibra\.com\.br', caseSensitive: false), 0.22, 'domain_ibra'),
      _SignalRule(RegExp(r'o\.s\.\s*:\s*\d+', caseSensitive: false), 0.12,
          'ordem_servico'),
      _SignalRule(
          RegExp(r'n[ºo]\s*lab', caseSensitive: false), 0.12, 'numero_lab'),
      _SignalRule(RegExp(r'f[oó]sforo\s*\(resina\)', caseSensitive: false),
          0.14, 'fosforo_resina'),
      _SignalRule(RegExp(r'agrofarm', caseSensitive: false), 0.1, 'agrofarm'),
    ],
    'mb': [
      _SignalRule(
          RegExp(r'an[aá]lise\s+de\s+solo\s*-\s*n[ºo]\s*\d+',
              caseSensitive: false),
          0.24,
          'analise_solo'),
      _SignalRule(
          RegExp(r'mb\s+agroneg[oó]cios|mb\s+agronegocios',
              caseSensitive: false),
          0.28,
          'brand_mb'),
      _SignalRule(
          RegExp(r'grupomb\.agr\.br', caseSensitive: false), 0.18, 'domain_mb'),
      _SignalRule(
          RegExp(r'par[âa]metros\s+estrat[ée]gicos', caseSensitive: false),
          0.12,
          'parametros_estrategicos'),
      _SignalRule(
          RegExp(r'teores\s+qu[íi]micos\s+dos\s+elementos',
              caseSensitive: false),
          0.12,
          'teores_quimicos'),
      _SignalRule(RegExp(r'p-meh', caseSensitive: false), 0.1, 'p_meh'),
    ],
  };

  static LabDetectionResult detectarComConfianca(String textoPdf) {
    final text = _normalize(textoPdf);
    if (text.trim().isEmpty) {
      return const LabDetectionResult(
        labId: null,
        confidence: 0,
        ranking: [],
        needsFallback: true,
      );
    }

    final ranking = <LabDetectionCandidate>[];

    for (final entry in _rules.entries) {
      final labId = entry.key;
      final rules = entry.value;
      final totalWeight = rules.fold<double>(0, (sum, r) => sum + r.weight);

      var matchedWeight = 0.0;
      final signals = <String>[];
      for (final rule in rules) {
        if (rule.regex.hasMatch(text)) {
          matchedWeight += rule.weight;
          signals.add(rule.label);
        }
      }

      final confidence = totalWeight <= 0 ? 0.0 : (matchedWeight / totalWeight);
      ranking.add(
        LabDetectionCandidate(
          labId: labId,
          score: matchedWeight,
          confidence: confidence.clamp(0.0, 1.0).toDouble(),
          matchedSignals: signals,
        ),
      );
    }

    ranking.sort((a, b) => b.score.compareTo(a.score));
    if (ranking.isEmpty || ranking.first.score <= 0) {
      return const LabDetectionResult(
        labId: null,
        confidence: 0,
        ranking: [],
        needsFallback: true,
      );
    }

    final best = ranking.first;
    final second = ranking.length > 1 ? ranking[1] : null;
    final margin = second == null ? best.score : (best.score - second.score);
    final needsFallback = best.confidence < 0.58 || margin < 0.12;

    return LabDetectionResult(
      labId: best.labId,
      confidence: best.confidence,
      ranking: ranking,
      needsFallback: needsFallback,
    );
  }

  static String? detectar(String textoPdf) {
    final result = detectarComConfianca(textoPdf);
    if (result.needsFallback) return null;
    return result.labId;
  }

  static String _normalize(String input) {
    return input.replaceAll('ﬁ', 'fi').replaceAll('ﬂ', 'fl').toLowerCase();
  }
}
