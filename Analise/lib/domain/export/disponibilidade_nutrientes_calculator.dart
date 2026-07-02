/// Calcula scores de disponibilidade de nutrientes por pH (0–100).
/// Espelha a lógica de [NutrientPhBarChart] para exportação HTML.
class DisponibilidadeNutrientesCalculator {
  const DisponibilidadeNutrientesCalculator._();

  static const _groups = <_NutrientGroup>[
    _NutrientGroup(
      id: 'micros',
      label: 'Micros',
      sublabel: 'Mn Cu Fe Zn',
      color: '#7ED321',
      referenceData: {
        4.0: 100,
        4.5: 93,
        5.0: 87,
        5.5: 76,
        6.0: 67,
        6.5: 60,
        7.0: 51,
        7.5: 40,
        8.0: 27,
        8.5: 13,
      },
    ),
    _NutrientGroup(
      id: 'p',
      label: 'P',
      sublabel: 'Fosforo',
      color: '#34C759',
      referenceData: {
        4.0: 33,
        4.5: 42,
        5.0: 50,
        5.5: 67,
        6.0: 92,
        6.5: 100,
        7.0: 97,
        7.5: 87,
        8.0: 67,
        8.5: 58,
      },
    ),
    _NutrientGroup(
      id: 'nsb',
      label: 'N S B',
      sublabel: 'N · Enxofre · Boro',
      color: '#5AC8FA',
      referenceData: {
        4.0: 24,
        4.5: 37,
        5.0: 61,
        5.5: 85,
        6.0: 95,
        6.5: 100,
        7.0: 100,
        7.5: 98,
        8.0: 88,
        8.5: 73,
      },
    ),
    _NutrientGroup(
      id: 'bases',
      label: 'Bases',
      sublabel: 'K · Ca · Mg',
      color: '#007AFF',
      referenceData: {
        4.0: 0,
        4.5: 12,
        5.0: 71,
        5.5: 100,
        6.0: 100,
        6.5: 100,
        7.0: 100,
        7.5: 98,
        8.0: 100,
        8.5: 100,
      },
    ),
    _NutrientGroup(
      id: 'moCl',
      label: 'Mo Cl',
      sublabel: 'Molibdenio',
      color: '#5856D6',
      referenceData: {
        4.0: 10,
        4.5: 20,
        5.0: 35,
        5.5: 45,
        6.0: 65,
        6.5: 75,
        7.0: 85,
        7.5: 90,
        8.0: 93,
        8.5: 95,
      },
    ),
    _NutrientGroup(
      id: 'al',
      label: 'Al',
      sublabel: 'Toxicidade',
      color: '#FF3B30',
      referenceData: {
        4.0: 90,
        4.5: 70,
        5.0: 50,
        5.5: 30,
        6.0: 10,
        6.5: 5,
        7.0: 2,
        7.5: 0,
        8.0: 0,
        8.5: 0,
      },
    ),
  ];

  /// Ordem dos eixos no radar HTML (sentido horário a partir do topo).
  static const radarAxisOrder = [
    'bases',
    'p',
    'micros',
    'al',
    'moCl',
    'nsb',
  ];

  static List<DisponibilidadeEixo> calcular(double ph) {
    final safePh = ph.clamp(4.0, 8.5);
    final phValues = _groups.first.referenceData.keys.toList()..sort();

    double interpolate(Map<double, double> data) {
      if (data.containsKey(safePh)) return data[safePh]!;
      var prev = phValues.first;
      var next = phValues.last;
      for (final v in phValues) {
        if (v <= safePh) prev = v;
        if (v >= safePh) {
          next = v;
          break;
        }
      }
      if (next == prev) return data[prev]!;
      final factor = (safePh - prev) / (next - prev);
      return data[prev]! + factor * (data[next]! - data[prev]!);
    }

    final byId = <String, DisponibilidadeEixo>{};
    for (final g in _groups) {
      final value = interpolate(g.referenceData);
      byId[g.id] = DisponibilidadeEixo(
        id: g.id,
        label: g.label,
        sublabel: g.sublabel,
        color: g.color,
        value: value,
      );
    }

    return radarAxisOrder.map((id) => byId[id]!).toList(growable: false);
  }
}

class DisponibilidadeEixo {
  const DisponibilidadeEixo({
    required this.id,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.value,
  });

  final String id;
  final String label;
  final String sublabel;
  final String color;
  final double value;
}

class _NutrientGroup {
  const _NutrientGroup({
    required this.id,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.referenceData,
  });

  final String id;
  final String label;
  final String sublabel;
  final String color;
  final Map<double, double> referenceData;
}
