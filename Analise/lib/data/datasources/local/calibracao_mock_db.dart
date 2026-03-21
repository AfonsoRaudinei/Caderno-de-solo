/// Representa um nível crítico retornado pelo banco ao escolher método + referência
class NivelCritico {
  final String label;
  final String valor;
  final bool
      dependeDeAnalise; // true = depende de argila ou outro dado da análise
  final String? estimativaMedia; // exibida quando dependeDeAnalise == true

  const NivelCritico({
    required this.label,
    required this.valor,
    this.dependeDeAnalise = false,
    this.estimativaMedia,
  });
}

class CalibracaoMockDB {
  // ─── CALAGEM ─────────────────────────────────────────────────────────────────

  static const List<String> metodosCalagem = [
    'Saturação de Bases (V%)',
    'Neutralização do Alumínio (Al³⁺)',
    'Tampão SMP',
    'Ca + Mg (Albrecht)',
  ];

  static const List<String> referenciasCalagem = [
    '01 — Calagem: Motor de Cálculo',
  ];

  static const List<String> estadosBrasil = [
    'SP',
    'MG',
    'MT',
    'MS',
    'GO',
    'PR',
    'RS',
    'SC',
    'BA',
    'TO',
    'MA',
    'PI',
  ];

  static const List<String> tiposSolo = [
    'Latossolo Vermelho',
    'Latossolo Vermelho-Amarelo',
    'Argissolo',
    'Nitossolo',
    'Gleissolo',
  ];

  /// Busca os níveis críticos de calagem conforme método + referência selecionados
  static List<NivelCritico> getCalagemNiveisCriticos({
    required String metodo,
    required String referencia,
  }) {
    if (metodo == 'Saturação de Bases (V%)') {
      return [
        const NivelCritico(label: 'V% alvo', valor: '70%', dependeDeAnalise: false),
        const NivelCritico(
            label: 'pH alvo', valor: '6,0 – 6,5', dependeDeAnalise: false),
        const NivelCritico(
            label: 'CTC pH 7 (camada 0–20 cm)',
            valor: 'Da análise',
            dependeDeAnalise: true,
            estimativaMedia: '≈ 60 mmolc/dm³ (média)'),
        const NivelCritico(
            label: 'Fator p (profundidade)',
            valor: '1,0 (0–20 cm)  |  2,0 (0–40 cm)',
            dependeDeAnalise: false),
      ];
    }
    if (metodo == 'Neutralização do Alumínio (Al³⁺)') {
      return [
        const NivelCritico(
            label: 'Fator f',
            valor: '1,5 ou 2,0 (conforme cultura)',
            dependeDeAnalise: false),
        const NivelCritico(
            label: 'Ca + Mg mínimo',
            valor: '2,0 cmolc/dm³',
            dependeDeAnalise: false),
        const NivelCritico(
            label: 'Al³⁺ (da análise)',
            valor: 'Da análise',
            dependeDeAnalise: true,
            estimativaMedia: '≈ 0,5 mmolc/dm³ (média)'),
      ];
    }
    if (metodo == 'Tampão SMP') {
      return [
        const NivelCritico(
            label: 'pH SMP alvo', valor: '6,0', dependeDeAnalise: false),
        const NivelCritico(
            label: 'pHSMP (da análise)',
            valor: 'Da análise',
            dependeDeAnalise: true,
            estimativaMedia: '≈ 5,8 (média)'),
        const NivelCritico(
            label: 'Correção por PRNT',
            valor: 'NC × (100 ÷ PRNT)',
            dependeDeAnalise: false),
      ];
    }
    // Albrecht default
    return [
      const NivelCritico(
          label: 'Ca mínimo', valor: '1,7 cmolc/dm³', dependeDeAnalise: false),
      const NivelCritico(
          label: 'Mg mínimo', valor: '0,7 cmolc/dm³', dependeDeAnalise: false),
      const NivelCritico(
          label: 'Relação Ca:Mg ideal',
          valor: '> 2,5',
          dependeDeAnalise: false),
    ];
  }

  // ─── GESSAGEM ────────────────────────────────────────────────────────────────

  static const List<String> metodosGessagem = [
    'Critério ESALQ (Vitti et al., 2004)',
    'Critério EMBRAPA (Souza et al., 2004)',
    'Teor de Argila (50 × argila%)',
  ];

  static const List<String> referenciasGessagem = [
    'ESALQ/USP',
    'EMBRAPA Soja',
    'EMBRAPA Cerrados',
  ];

  static List<NivelCritico> getGessagemNiveisCriticos({
    required String metodo,
  }) {
    if (metodo == 'Critério ESALQ (Vitti et al., 2004)') {
      return [
        const NivelCritico(
            label: 'V% alvo (20–40 cm)', valor: '50%', dependeDeAnalise: false),
        const NivelCritico(
            label: 'CTC (20–40 cm)',
            valor: 'Da análise',
            dependeDeAnalise: true,
            estimativaMedia: '≈ 45 mmolc/dm³ (média)'),
        const NivelCritico(
            label: 'Fórmula',
            valor: 'NG = (50 − Va) × CTC ÷ 500',
            dependeDeAnalise: false),
      ];
    }
    if (metodo == 'Critério EMBRAPA (Souza et al., 2004)') {
      return [
        const NivelCritico(
            label: 'Fórmula',
            valor: 'NG = 50 × argila (%)',
            dependeDeAnalise: false),
        const NivelCritico(
            label: 'Argila (da análise)',
            valor: 'Da análise',
            dependeDeAnalise: true,
            estimativaMedia: '≈ 30% (média Cerrado)'),
        const NivelCritico(
            label: 'Dose estimada (média)',
            valor: '≈ 1,5 t/ha',
            dependeDeAnalise: true,
            estimativaMedia: '≈ 1,5 t/ha'),
      ];
    }
    return [
      const NivelCritico(
          label: 'Fórmula',
          valor: 'NG (kg/ha) = 50 × argila (%)',
          dependeDeAnalise: false),
      const NivelCritico(
          label: 'Argila',
          valor: 'Da análise',
          dependeDeAnalise: true,
          estimativaMedia: '≈ 1,1 t/ha (220 g/kg)'),
    ];
  }

  // ─── FÓSFORO ─────────────────────────────────────────────────────────────────

  static const List<String> metodosPosforo = [
    'Resina (IAC)',
    'Mehlich-1 (Duplo Ácido)',
    'Bray-1',
  ];

  static const List<String> referenciasPosforo = [
    'IAC/SP — Boletim 100',
    'EMBRAPA Soja',
    'ESALQ/USP',
  ];

  static List<NivelCritico> getPosforoNiveisCriticos({
    required String metodo,
  }) {
    if (metodo == 'Resina (IAC)') {
      return [
        const NivelCritico(
            label: 'Nível crítico (Argila < 15%)',
            valor: '> 30 mg/dm³',
            dependeDeAnalise: true,
            estimativaMedia: '> 30 mg/dm³'),
        const NivelCritico(
            label: 'Nível crítico (Argila 15–35%)',
            valor: '> 20 mg/dm³',
            dependeDeAnalise: true,
            estimativaMedia: '> 20 mg/dm³'),
        const NivelCritico(
            label: 'Nível crítico (Argila > 35%)',
            valor: '> 12 mg/dm³',
            dependeDeAnalise: true,
            estimativaMedia: '> 12 mg/dm³'),
      ];
    }
    return [
      const NivelCritico(
          label: 'Nível crítico',
          valor: 'Da análise + argila',
          dependeDeAnalise: true,
          estimativaMedia: '≈ 15 mg/dm³ (média)'),
    ];
  }

  // ─── POTÁSSIO ────────────────────────────────────────────────────────────────

  static const List<String> metodosKalium = [
    'Saturação de K na CTC (K/CTC %)',
    'Teor absoluto (mmolc/dm³)',
  ];

  static const List<String> referenciasKalium = [
    'ESALQ/USP — Fancelli',
    'EMBRAPA Soja',
    'IAC/SP',
  ];

  static List<NivelCritico> getKaliumNiveisCriticos({
    required String metodo,
  }) {
    if (metodo == 'Saturação de K na CTC (K/CTC %)') {
      return [
        const NivelCritico(
            label: 'K/CTC mínimo', valor: '≥ 2,5%', dependeDeAnalise: false),
        const NivelCritico(
            label: 'K/CTC ótimo', valor: '3,5 – 5,0%', dependeDeAnalise: false),
        const NivelCritico(
            label: 'CTC (da análise)',
            valor: 'Da análise',
            dependeDeAnalise: true,
            estimativaMedia: '≈ 60 mmolc/dm³ (média)'),
      ];
    }
    return [
      const NivelCritico(
          label: 'Nível crítico K⁺',
          valor: '≥ 2,0 mmolc/dm³',
          dependeDeAnalise: false),
      const NivelCritico(
          label: 'Deficiência',
          valor: '< 1,5 mmolc/dm³',
          dependeDeAnalise: false),
    ];
  }

  // ─── MICRONUTRIENTES ─────────────────────────────────────────────────────────

  static const List<String> metodosmicro = [
    'DTPA-TEA (Zn, Cu, Fe, Mn)',
    'Água Quente (B)',
    'Resina (B)',
  ];

  static const List<String> referenciasmicro = [
    'ESALQ/USP',
    'EMBRAPA Soja',
    'IAC/SP',
  ];

  static List<NivelCritico> getMicroNiveisCriticos() {
    return [
      const NivelCritico(
          label: 'Boro (B) — nível crítico',
          valor: '≥ 0,6 mg/dm³',
          dependeDeAnalise: false),
      const NivelCritico(
          label: 'Cobre (Cu) — nível crítico',
          valor: '≥ 0,4 mg/dm³',
          dependeDeAnalise: false),
      const NivelCritico(
          label: 'Ferro (Fe) — nível crítico',
          valor: '≥ 5,0 mg/dm³',
          dependeDeAnalise: false),
      const NivelCritico(
          label: 'Manganês (Mn) — nível crítico',
          valor: '≥ 1,2 mg/dm³',
          dependeDeAnalise: false),
      const NivelCritico(
          label: 'Zinco (Zn) — nível crítico',
          valor: '≥ 1,0 mg/dm³',
          dependeDeAnalise: false),
    ];
  }
}
