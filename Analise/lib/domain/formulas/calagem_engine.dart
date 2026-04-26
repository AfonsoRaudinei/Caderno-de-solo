import 'package:soloforte/domain/entities/resultado_calagem.dart';

/// Motor de Calagem do SoloForte — 7 Métodos
/// Fonte: PROMPT/01_calagem.md · Março 2026
/// Referências: Fancelli (2020), Caires/UEPG (2019), EMBRAPA, Albrecht, UFLA, IAC

class CalagemEngine {
  CalagemEngine._();

  // ─────────────────────────────────────────────────────────────────────────
  // SEÇÃO 2 — PARÂMETROS CALCULADOS DA ANÁLISE
  // ─────────────────────────────────────────────────────────────────────────

  /// SB = Ca + Mg + K  (cmolc/dm³)
  static double calcularSB(dynamic a) =>
      (a.ca ?? 0.0) + (a.mg ?? 0.0) + (a.k ?? 0.0);

  /// CTC = SB + H+Al  (cmolc/dm³)
  static double calcularCTC(dynamic a) => calcularSB(a) + (a.hMaisAl ?? 0.0);

  /// t = SB + Al  (CTC efetiva)
  static double calcularCTCEfetiva(dynamic a) => calcularSB(a) + (a.al ?? 0.0);

  /// V% = (SB / CTC) × 100
  static double calcularV(dynamic a) {
    final ctc = calcularCTC(a);
    if (ctc <= 0) return 0.0;
    return (calcularSB(a) / ctc) * 100.0;
  }

  /// m% = (Al / t) × 100
  static double calcularM(dynamic a) {
    final t = calcularCTCEfetiva(a);
    if (t <= 0) return 0.0;
    return ((a.al ?? 0.0) / t) * 100.0;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEÇÃO 3 — VALOR Y (PODER TAMPÃO DO SOLO)
  // ─────────────────────────────────────────────────────────────────────────

  /// Calcula Y pela equação contínua da 5ª Aproximação MG:
  /// Ŷ = 0,0302 + 0,06532 × Arg − 0,000257 × Arg²   (R² = 0,9996)
  static double yPorArgila(double argila) {
    final y = 0.0302 + 0.06532 * argila - 0.000257 * argila * argila;
    return y.clamp(0.0, 4.0);
  }

  /// Calcula Y por P-rem usando interpolação linear da tabela do 01_calagem.md
  ///
  /// Tabela (seção 3.2):
  ///   P-rem 0–4   → Y 4,0–3,5
  ///   P-rem 4–10  → Y 3,5–2,9
  ///   P-rem 10–19 → Y 2,9–2,0
  ///   P-rem 19–30 → Y 2,0–1,2
  ///   P-rem 30–44 → Y 1,2–0,5
  ///   P-rem 44–60 → Y 0,5–0,0
  static double yPorPrem(double prem) {
    if (prem <= 0) return 4.0;
    if (prem <= 4) return _lerp(prem, 0, 4, 4.0, 3.5);
    if (prem <= 10) return _lerp(prem, 4, 10, 3.5, 2.9);
    if (prem <= 19) return _lerp(prem, 10, 19, 2.9, 2.0);
    if (prem <= 30) return _lerp(prem, 19, 30, 2.0, 1.2);
    if (prem <= 44) return _lerp(prem, 30, 44, 1.2, 0.5);
    if (prem <= 60) return _lerp(prem, 44, 60, 0.5, 0.0);
    return 0.0; // P-rem > 60: solo com baixíssima capacidade de fixação
  }

  /// Calcula Y selon a regra do 01_calagem.md seção 3.3:
  /// - Só P-rem disponível → Y por P-rem
  /// - Só argila disponível → Y por equação contínua
  /// - Ambos → média ponderada 60% argila + 40% P-rem
  static double calcularY({required double argila, double? prem}) {
    final yArg = yPorArgila(argila);
    if (prem == null) return yArg;
    final yPr = yPorPrem(prem);
    return (yArg * 0.6) + (yPr * 0.4);
  }

  /// Seleciona V2 conforme cultura e MO (seção 6.1 do 01_calagem.md).
  ///
  /// Regras:
  /// - Soja: 65% (MO>4) / 70% (MO<=4)
  /// - Milho: 60% / 70%
  /// - Feijão: 60% / 70%
  /// - Algodão: 65% / 70%
  /// - Demais culturas (cerrado geral): 55% / 65%
  static double v2PorCulturaEMO({
    required String cultura,
    required double moPercent,
  }) {
    final culturaNorm = cultura.trim().toLowerCase();
    final moAlta = moPercent > 4.0;
    if (culturaNorm == 'soja') return moAlta ? 65.0 : 70.0;
    if (culturaNorm == 'milho') return moAlta ? 60.0 : 70.0;
    if (culturaNorm == 'feijão' || culturaNorm == 'feijao') {
      return moAlta ? 60.0 : 70.0;
    }
    if (culturaNorm == 'algodão' || culturaNorm == 'algodao') {
      return moAlta ? 65.0 : 70.0;
    }
    return moAlta ? 55.0 : 65.0;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEÇÃO 5 — SEQUÊNCIA DE CORREÇÕES
  // ─────────────────────────────────────────────────────────────────────────

  /// Aplica a sequência de correções de todos os métodos (seção 5):
  ///
  ///   NC_prof    = NC_base × profFator
  ///   NC_prnt    = NC_prof ÷ (prnt/100)
  ///   Dose_final = NC_prnt ÷ SC
  static ({
    double ncProfundidade,
    double ncPRNT,
    double doseFinal,
  }) aplicarCorrecoes({
    required double ncBase,
    required double profFator,
    required double prnt,
    required double scFator,
  }) {
    if (prnt <= 0 || scFator <= 0) {
      return (ncProfundidade: ncBase * profFator, ncPRNT: 0.0, doseFinal: 0.0);
    }
    final ncProf = ncBase * profFator;
    final ncPrnt = ncProf / (prnt / 100.0);
    final dose = ncPrnt / scFator;
    return (ncProfundidade: ncProf, ncPRNT: ncPrnt, doseFinal: dose);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEÇÃO 7 — NUTRIENTES ADICIONADOS E SATURAÇÕES FINAIS
  // ─────────────────────────────────────────────────────────────────────────

  /// Calcula nutrientes adicionados e novas saturações (seção 7 do 01_calagem.md).
  ///
  ///   Ca_adicionado = Dose_final × FatorCa
  ///   Mg_adicionado = Dose_final × FatorMg
  ///   Ca_total  = Ca_atual + Ca_adicionado
  ///   Mg_total  = Mg_atual + Mg_adicionado
  ///   CTC_nova  = CTC_atual + Ca_adicionado + Mg_adicionado
  ///   %Ca  = (Ca_total / CTC_nova) × 100
  ///   %Mg  = (Mg_total / CTC_nova) × 100
  ///   %K   = (K / CTC_nova) × 100
  ///   V%_final = ((Ca_total + Mg_total + K) / CTC_nova) × 100
  static ({
    double caAdicionado,
    double mgAdicionado,
    double ctcNova,
    double pctCa,
    double pctMg,
    double pctK,
    double vPctFinal,
  }) calcularNutrientesAdicionados({
    required dynamic analise,
    required double doseFinalTHa,
    required String tipoCalcario,
  }) {
    final fatorCa = FatoresCalcario.getFatorCa(tipoCalcario);
    final fatorMg = FatoresCalcario.getFatorMg(tipoCalcario);

    final caAdicionado = doseFinalTHa * fatorCa;
    final mgAdicionado = doseFinalTHa * fatorMg;

    final caTotal = (analise.ca ?? 0.0) + caAdicionado;
    final mgTotal = (analise.mg ?? 0.0) + mgAdicionado;
    final ctcAtual = calcularCTC(analise);
    final ctcNova = ctcAtual + caAdicionado + mgAdicionado;

    double pctCa = 0.0, pctMg = 0.0, pctK = 0.0, vPctFinal = 0.0;
    if (ctcNova > 0) {
      pctCa = (caTotal / ctcNova) * 100.0;
      pctMg = (mgTotal / ctcNova) * 100.0;
      pctK = ((analise.k ?? 0.0) / ctcNova) * 100.0;
      vPctFinal = ((caTotal + mgTotal + (analise.k ?? 0.0)) / ctcNova) * 100.0;
    }

    return (
      caAdicionado: caAdicionado,
      mgAdicionado: mgAdicionado,
      ctcNova: ctcNova,
      pctCa: pctCa,
      pctMg: pctMg,
      pctK: pctK,
      vPctFinal: vPctFinal,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER — constrói ResultadoCalagem a partir dos valores calculados
  // ─────────────────────────────────────────────────────────────────────────
  static ResultadoCalagem _buildResultado({
    required MetodoCalagem metodo,
    required dynamic analise,
    required double ncBase,
    required double profFator,
    required double prnt,
    required double scFator,
    required String tipoCalcario,
    required double yUtilizado,
    required double v2Desejado,
    required List<String> observacoes,
  }) {
    final corr = aplicarCorrecoes(
      ncBase: ncBase,
      profFator: profFator,
      prnt: prnt,
      scFator: scFator,
    );

    final nut = calcularNutrientesAdicionados(
      analise: analise,
      doseFinalTHa: corr.doseFinal,
      tipoCalcario: tipoCalcario,
    );

    return ResultadoCalagem(
      metodo: metodo,
      ncBase: ncBase,
      ncProfundidade: corr.ncProfundidade,
      ncPRNT: corr.ncPRNT,
      doseFinal: corr.doseFinal,
      caAdicionado: nut.caAdicionado,
      mgAdicionado: nut.mgAdicionado,
      CTCnova: nut.ctcNova,
      pctCa: nut.pctCa,
      pctMg: nut.pctMg,
      pctK: nut.pctK,
      vPctFinal: nut.vPctFinal,
      v2Desejado: v2Desejado,
      prntAplicado: prnt,
      profFator: profFator,
      scFator: scFator,
      tipoCalcario: tipoCalcario,
      yUtilizado: yUtilizado,
      observacoes: observacoes,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTODO ① — SATURAÇÃO POR BASES (V%)
  // ─────────────────────────────────────────────────────────────────────────
  ///
  /// Fonte: Fancelli (2020), IAC — Método preferencial para Cerrado
  ///
  ///   NC_base = ((V2 − V1) × CTC) / 100
  ///
  /// V2 por cultura e MO (seção 6.1 do 01_calagem.md):
  ///   Soja: MO>4% → 65%, MO<4% → 70%
  ///   Milho: 60–70%  | Feijão: 60–70%  | Algodão: 65–70%
  ///   Cerrado geral: 50–55% (com MO alta) ou 60–70%
  static ResultadoCalagem metodo1SaturacaoBases({
    required dynamic analise,
    required double v2,
    required double profFator,
    required double prnt,
    required double scFator,
    String tipoCalcario = 'Dolomítico',
  }) {
    final v1 = calcularV(analise);
    final ctc = calcularCTC(analise);

    final ncBase = v2 > v1 && ctc > 0 ? ((v2 - v1) / 100.0) * ctc : 0.0;

    final obs = <String>[];
    if (v1 >= v2) {
      obs.add(
          'V% atual (${v1.toStringAsFixed(1)}%) ≥ V2 desejado (${v2.toStringAsFixed(1)}%) — sem calagem.');
    }
    if ((analise.hMaisAl ?? 0.0) > 3.0) {
      obs.add(
          'H+Al > 3 cmolc/dm³ — solo de alto tampão. Parcelar calagem em 2 aplicações (Fancelli).');
    }
    obs.add(
        'V1 = ${v1.toStringAsFixed(1)}% | V2 = ${v2.toStringAsFixed(1)}% | CTC = ${ctc.toStringAsFixed(2)} cmolc/dm³');

    return _buildResultado(
      metodo: MetodoCalagem.saturacaoBases,
      analise: analise,
      ncBase: ncBase,
      profFator: profFator,
      prnt: prnt,
      scFator: scFator,
      tipoCalcario: tipoCalcario,
      yUtilizado: 0.0,
      v2Desejado: v2,
      observacoes: obs,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTODO ② — TRADICIONAL EMBRAPA (H+Al × Fator)
  // ─────────────────────────────────────────────────────────────────────────
  ///
  /// Fonte: EMBRAPA — Usado em solos com alta acidez potencial
  ///
  ///   NC_base = H+Al × Fator
  ///
  /// Fator padrão = 0,5 (configurável: 0,3 a 1,0 conforme textura/cultura)
  static ResultadoCalagem metodo2Embrapa({
    required dynamic analise,
    required double fator,
    required double profFator,
    required double prnt,
    required double scFator,
    String tipoCalcario = 'Dolomítico',
  }) {
    final ncBase = (analise.hMaisAl ?? 0.0) * fator;

    final obs = <String>[];
    obs.add(
        'H+Al = ${(analise.hMaisAl ?? 0.0).toStringAsFixed(2)} cmolc/dm³ × Fator = $fator');
    obs.add('NC base = ${ncBase.toStringAsFixed(2)} t/ha');
    if (fator < 0.3 || fator > 1.0) {
      obs.add(
          '⚠️ Fator fora da faixa recomendada (0,3 a 1,0). Verificar escolha.');
    }

    return _buildResultado(
      metodo: MetodoCalagem.embrapa,
      analise: analise,
      ncBase: ncBase,
      profFator: profFator,
      prnt: prnt,
      scFator: scFator,
      tipoCalcario: tipoCalcario,
      yUtilizado: 0.0,
      v2Desejado: 0.0,
      observacoes: obs,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTODO ③ — NC = Ca + Mg
  // ─────────────────────────────────────────────────────────────────────────
  ///
  /// Fonte: Clássico — Uso limitado (não recomendado isoladamente — Fancelli)
  ///
  ///   NC_base = Ca_atual + Mg_atual
  ///
  /// Lógica: repõe toda a fração Ca+Mg atual do solo.
  /// Limitação: não considera V%, CTC nem poder tampão.
  static ResultadoCalagem metodo3CaMg({
    required dynamic analise,
    required double profFator,
    required double prnt,
    required double scFator,
    String tipoCalcario = 'Dolomítico',
  }) {
    // NC base = Ca + Mg atuais (Fancelli)
    final ncBase = (analise.ca ?? 0.0) + (analise.mg ?? 0.0);

    final obs = <String>[];
    obs.add(
        'NC = Ca (${(analise.ca ?? 0.0).toStringAsFixed(2)}) + Mg (${(analise.mg ?? 0.0).toStringAsFixed(2)}) = ${ncBase.toStringAsFixed(2)} cmolc/dm³ → t/ha');
    obs.add(
        '⚠️ Fancelli: não utilizar isoladamente. Use como referência comparativa.');

    return _buildResultado(
      metodo: MetodoCalagem.caMg,
      analise: analise,
      ncBase: ncBase,
      profFator: profFator,
      prnt: prnt,
      scFator: scFator,
      tipoCalcario: tipoCalcario,
      yUtilizado: 0.0,
      v2Desejado: 0.0,
      observacoes: obs,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTODO ④ — SUPERCALAGEM (Dose Fixa)
  // ─────────────────────────────────────────────────────────────────────────
  ///
  /// Fonte: Fancelli (2020) — Para solos muito ácidos (pH < 4,5)
  ///
  ///   NC_base = Dose fixa (padrão 1,75 t/ha)
  ///
  /// Dose fixa independe da análise — intervenção de correção estrutural.
  /// Geralmente parcelada em 2 aplicações.
  static ResultadoCalagem metodo4Supercalagem({
    required dynamic analise,
    required double doseFixa, // padrão 1,75 t/ha
    required double profFator,
    required double prnt,
    required double scFator,
    String tipoCalcario = 'Calcítico',
  }) {
    final obs = <String>[];
    obs.add('Dose fixa de choque: ${doseFixa.toStringAsFixed(2)} t/ha.');
    if ((analise.phCaCl2 ?? 0.0) >= 4.5) {
      obs.add(
          'pH = ${(analise.phCaCl2 ?? 0.0).toStringAsFixed(1)} ≥ 4,5 — supercalagem pode ser excessiva. Verificar indicação.');
    }
    if ((analise.phCaCl2 ?? 0.0) < 4.5) {
      obs.add(
          'pH < 4,5 — solo muito ácido. Parcelar em 2 aplicações (Fancelli).');
    }

    return _buildResultado(
      metodo: MetodoCalagem.supercalagem,
      analise: analise,
      ncBase: doseFixa,
      profFator: profFator,
      prnt: prnt,
      scFator: scFator,
      tipoCalcario: tipoCalcario,
      yUtilizado: 0.0,
      v2Desejado: 0.0,
      observacoes: obs,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTODO ⑤ — ALBRECHT (Equilíbrio de Bases)
  // ─────────────────────────────────────────────────────────────────────────
  ///
  /// Fonte: Albrecht (1930–1940s), Gismonti/Braga (2021)
  ///
  /// Calcula quanto de Ca, Mg e K precisa ser adicionado para atingir
  /// as saturações-alvo na CTC.
  ///
  /// Saturações-alvo padrão SoloForte:
  ///   Ca = 60–70% da CTC
  ///   Mg = 10–20% da CTC
  ///   K  = 3–5% da CTC
  ///
  /// NC_base = dose calculada para suprir déficit de Ca (componente principal).
  static ResultadoCalagem metodo5Albrecht({
    required dynamic analise,
    required double pctCaAlvo, // ex: 60.0 (%)
    required double pctMgAlvo, // ex: 10.0 (%)
    required double pctKAlvo, // ex: 3.0 (%)
    required double profFator,
    required double prnt,
    required double scFator,
    String tipoCalcario = 'Dolomítico',

    /// % CaO no calcário (para conversão do déficit)
    double caOPct = 38.0,

    /// % MgO no calcário (para conversão do déficit)
    double mgOPct = 13.0,
  }) {
    final ctc = calcularCTC(analise);

    // Passo 1 — Teores necessários (cmolc/dm³)
    final caAlvo = (pctCaAlvo / 100.0) * ctc;
    final mgAlvo = (pctMgAlvo / 100.0) * ctc;
    final kAlvo = (pctKAlvo / 100.0) * ctc;

    // Passo 2 — Déficits
    final deficitCa =
        (caAlvo - (analise.ca ?? 0.0)).clamp(0.0, double.infinity);
    final deficitMg =
        (mgAlvo - (analise.mg ?? 0.0)).clamp(0.0, double.infinity);
    final deficitK = (kAlvo - (analise.k ?? 0.0)).clamp(0.0, double.infinity);

    // Passo 3a — Ca déficit → dose calcário
    // Ca_kg_ha = deficit_Ca × 200   (1 cmolc Ca = 200 mg/dm³; × 2 = kg/ha)
    // Dose_Ca (kg/ha) = Ca_kg_ha / (CaO% × 0,71428)
    // CaO → Ca: ÷ 1,399 = × 0,71428
    double ncBase = 0.0;
    if (caOPct > 0 && deficitCa > 0) {
      final caKgHa = deficitCa * 200.0;
      final doseEquivCaKgHa = caKgHa / (caOPct / 100.0 * 0.71428);
      ncBase = doseEquivCaKgHa / 1000.0; // kg/ha → t/ha
    }

    // Passo 3b — Mg déficit → dose equivalente (referência técnica)
    double doseEquivMgKgHa = 0.0;
    if (mgOPct > 0 && deficitMg > 0) {
      final mgKgHa = deficitMg * 120.0;
      doseEquivMgKgHa = mgKgHa / (mgOPct / 100.0 * 0.602);
    }

    // Passo 3c — K déficit → KCl (kg/ha) como recomendação auxiliar
    final kKgHa = deficitK * 391.0;
    final k2OKgHa = kKgHa * 1.205;
    final kclKgHa = k2OKgHa / 0.50;

    final obs = <String>[];
    obs.add(
        'Ca alvo: ${caAlvo.toStringAsFixed(2)} cmolc/dm³ (${pctCaAlvo.toStringAsFixed(0)}% CTC) | atual: ${(analise.ca ?? 0.0).toStringAsFixed(2)}');
    obs.add(
        'Mg alvo: ${mgAlvo.toStringAsFixed(2)} cmolc/dm³ (${pctMgAlvo.toStringAsFixed(0)}% CTC) | atual: ${(analise.mg ?? 0.0).toStringAsFixed(2)}');
    obs.add(
        'K alvo: ${kAlvo.toStringAsFixed(2)} cmolc/dm³ (${pctKAlvo.toStringAsFixed(0)}% CTC) | atual: ${(analise.k ?? 0.0).toStringAsFixed(2)}');
    if (deficitCa <= 0) obs.add('Ca já na faixa ideal — sem deficit de Ca.');
    if (deficitMg > 0) {
      obs.add(
          'Mg com déficit (${deficitMg.toStringAsFixed(2)} cmolc/dm³) — dose equivalente Mg: ${doseEquivMgKgHa.toStringAsFixed(0)} kg/ha.');
    }
    if (deficitK > 0) {
      obs.add(
          'K com déficit (${deficitK.toStringAsFixed(2)} cmolc/dm³) — KCl estimado: ${kclKgHa.toStringAsFixed(0)} kg/ha.');
    }
    if (deficitCa <= 0 && deficitMg <= 0) {
      obs.add(
          'Ca e Mg já na faixa ideal — sem necessidade de calcário pelo Albrecht.');
    }

    return _buildResultado(
      metodo: MetodoCalagem.albrecht,
      analise: analise,
      ncBase: ncBase,
      profFator: profFator,
      prnt: prnt,
      scFator: scFator,
      tipoCalcario: tipoCalcario,
      yUtilizado: 0.0,
      v2Desejado: 0.0,
      observacoes: obs,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTODO ⑥ — ALBRECHT com TAMPÃO Y
  // ─────────────────────────────────────────────────────────────────────────
  ///
  /// Fonte: Formulação própria SoloForte
  ///
  /// Idêntico ao Método ⑤ (Albrecht puro), mas com proteção pelo valor Y:
  ///   NC_base = max(NC_albrecht, Y)
  ///
  /// Razão: solo de alto tampão resiste à mudança de pH.
  /// Se a dose Albrecht for menor que Y, o pH não muda e o equilíbrio não é atingido.
  ///
  /// Usar em: solos argilosos, alta MO, H+Al > 3 cmolc/dm³.
  static ResultadoCalagem metodo6AlbrechtY({
    required dynamic analise,
    required double pctCaAlvo,
    required double pctMgAlvo,
    required double pctKAlvo,
    required double profFator,
    required double prnt,
    required double scFator,
    String tipoCalcario = 'Dolomítico',
    double caOPct = 38.0,
    double mgOPct = 13.0,
  }) {
    // Primeiro calcula o Albrecht puro
    final albrecht = metodo5Albrecht(
      analise: analise,
      pctCaAlvo: pctCaAlvo,
      pctMgAlvo: pctMgAlvo,
      pctKAlvo: pctKAlvo,
      profFator: 1.0, // aplicar profFator depois do max
      prnt: 100.0, // aplicar prnt depois do max
      scFator: 1.0, // aplicar scFator depois do max
      tipoCalcario: tipoCalcario,
      caOPct: caOPct,
      mgOPct: mgOPct,
    );

    // Calcula Y
    final y = calcularY(argila: (analise.argila ?? 0.0), prem: analise.pRem);

    // NC_base = max(NC_albrecht, Y)
    final ncAlbrecht = albrecht.ncBase;
    final ncBase = ncAlbrecht >= y ? ncAlbrecht : y;

    final obs = List<String>.from(albrecht.observacoes);
    obs.add(
        'Y calculado: ${y.toStringAsFixed(3)} t/ha (argila=${(analise.argila ?? 0.0).toStringAsFixed(0)}%)');
    if (ncAlbrecht < y) {
      obs.add(
          'Albrecht (${ncAlbrecht.toStringAsFixed(2)} t/ha) < Y (${y.toStringAsFixed(2)} t/ha) → Y prevalece como dose mínima.');
    } else {
      obs.add(
          'Albrecht (${ncAlbrecht.toStringAsFixed(2)} t/ha) ≥ Y (${y.toStringAsFixed(2)} t/ha) → Albrecht governa.');
    }

    return _buildResultado(
      metodo: MetodoCalagem.albrechtY,
      analise: analise,
      ncBase: ncBase,
      profFator: profFator,
      prnt: prnt,
      scFator: scFator,
      tipoCalcario: tipoCalcario,
      yUtilizado: y,
      v2Desejado: 0.0,
      observacoes: obs,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTODO ⑦ — CORREÇÃO DIRECIONADA DE Mg
  // ─────────────────────────────────────────────────────────────────────────
  ///
  /// Fonte: Fancelli (2020) — Quando Ca está adequado mas Mg é insuficiente.
  ///
  ///   Deficit_Mg = Mg_desejado − Mg_atual
  ///   NC_base    = Deficit_Mg / FatorMg_calcario
  ///
  /// Evita superdose de Ca por excesso de calcário calcítico.
  static ResultadoCalagem metodo7CorrecaoMg({
    required dynamic analise,
    required double mgDesejado, // cmolc/dm³ de Mg alvo
    required double profFator,
    required double prnt,
    required double scFator,
    String tipoCalcario = 'Magnesiano',
  }) {
    final deficitMg =
        (mgDesejado - (analise.mg ?? 0.0)).clamp(0.0, double.infinity);

    final fatorMg = FatoresCalcario.getFatorMg(tipoCalcario);

    // NC_base (t/ha): calcário fornece fatorMg cmolc/dm³ de Mg por t/ha
    final ncBase = fatorMg > 0 ? deficitMg / fatorMg : 0.0;

    final obs = <String>[];
    obs.add(
        'Mg atual: ${(analise.mg ?? 0.0).toStringAsFixed(2)} | Desejado: ${mgDesejado.toStringAsFixed(2)} cmolc/dm³');
    obs.add(
        'Deficit Mg: ${deficitMg.toStringAsFixed(2)} cmolc/dm³ | Fator Mg ($tipoCalcario): ${fatorMg.toStringAsFixed(3)}');
    if ((analise.mg ?? 0.0) >= mgDesejado) {
      obs.add('Mg já satisfatório — sem necessidade de correção.');
    }
    obs.add('Usar calcário magnesiano (MgO ≥ 12%) para eficiência máxima.');

    return _buildResultado(
      metodo: MetodoCalagem.correcaoMg,
      analise: analise,
      ncBase: ncBase,
      profFator: profFator,
      prnt: prnt,
      scFator: scFator,
      tipoCalcario: tipoCalcario,
      yUtilizado: 0.0,
      v2Desejado: 0.0,
      observacoes: obs,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER PRIVADO — interpolação linear
  // ─────────────────────────────────────────────────────────────────────────
  static double _lerp(double x, double x0, double x1, double y0, double y1) {
    return y0 + (y1 - y0) * (x - x0) / (x1 - x0);
  }
}
