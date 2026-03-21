import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/entities/analise_solo.dart';
import 'package:soloforte/domain/entities/resultado_calagem.dart';
import 'package:soloforte/domain/formulas/calagem_engine.dart';

/// Testes unitários do CalagemEngine — 7 métodos
/// Fonte: PROMPT/01_calagem.md · Março 2026
///
/// Valores de exemplo:
///   Ca=2.0, Mg=0.5, K=0.16, HAl=2.0, Al=0.3, argila=42, PRNT=90

void main() {
  // ─── Análise padrão ────────────────────────────────────────────────────────
  const analise = AnaliseSolo(
    id: 'test-001',
    Ca: 2.0,
    Mg: 0.5,
    K: 0.16,
    HAl: 2.0,
    Al: 0.3,
    argila: 42.0,
    pH: 5.2,
    MO: 35.0,
    P: 12.0,
    S: 8.0,
  );
  // SB = 2.0 + 0.5 + 0.16 = 2.66
  // CTC = 2.66 + 2.0 = 4.66
  // V% = (2.66 / 4.66) × 100 = 57.08%
  // m% = (0.3 / (2.66+0.3)) × 100 = 10.14%

  // ─────────────────────────────────────────────────────────────────────────
  // SEÇÃO 2 — Parâmetros calculados
  // ─────────────────────────────────────────────────────────────────────────
  group('Seção 2 — Parâmetros calculados', () {
    test('SB = Ca + Mg + K', () {
      expect(CalagemEngine.calcularSB(analise), closeTo(2.66, 0.01));
    });

    test('CTC = SB + H+Al', () {
      expect(CalagemEngine.calcularCTC(analise), closeTo(4.66, 0.01));
    });

    test('CTCefetiva = SB + Al', () {
      expect(CalagemEngine.calcularCTCEfetiva(analise), closeTo(2.96, 0.01));
    });

    test('V% = (SB/CTC) × 100 ≈ 57.1%', () {
      expect(CalagemEngine.calcularV(analise), closeTo(57.08, 0.5));
    });

    test('m% = (Al/t) × 100 ≈ 10.1%', () {
      expect(CalagemEngine.calcularM(analise), closeTo(10.14, 0.5));
    });

    test('V% = 0 quando CTC = 0', () {
      const vazio = AnaliseSolo(id: 'z', Ca: 0, Mg: 0, K: 0, HAl: 0);
      expect(CalagemEngine.calcularV(vazio), equals(0.0));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // SEÇÃO 3 — Valor Y
  // ─────────────────────────────────────────────────────────────────────────
  group('Seção 3 — Valor Y (poder tampão)', () {
    test('Y por argila=42 segue equação contínua', () {
      // Ŷ = 0.0302 + 0.06532×42 − 0.000257×42² = 0.0302 + 2.74344 − 0.45318 ≈ 2.32
      expect(CalagemEngine.yPorArgila(42.0), closeTo(2.32, 0.15));
    });

    test('Y por argila: solo mais argiloso tem Y maior', () {
      expect(CalagemEngine.yPorArgila(70.0),
          greaterThan(CalagemEngine.yPorArgila(15.0)));
    });

    test('Y por P-rem=0 retorna 4.0 (máximo)', () {
      expect(CalagemEngine.yPorPrem(0.0), equals(4.0));
    });

    test('Y por P-rem=60+ retorna 0 (mínimo)', () {
      expect(CalagemEngine.yPorPrem(60.0), closeTo(0.0, 0.01));
    });

    test('Y por P-rem=19 retorna ~2.0 (ponto da tabela)', () {
      // P-rem 19-30 → Y 2.0-1.2; prem=19 → Y=2.0
      expect(CalagemEngine.yPorPrem(19.0), closeTo(2.0, 0.15));
    });

    test('Y sem P-rem usa apenas argila', () {
      final y1 = CalagemEngine.calcularY(argila: 42.0);
      final y2 = CalagemEngine.calcularY(argila: 42.0, prem: null);
      expect(y1, equals(y2));
    });

    test('Y com ambos = média ponderada 60/40', () {
      final yArg = CalagemEngine.yPorArgila(42.0);
      final yPrem = CalagemEngine.yPorPrem(30.0);
      final yEsperado = yArg * 0.6 + yPrem * 0.4;
      final yCalculado = CalagemEngine.calcularY(argila: 42.0, prem: 30.0);
      expect(yCalculado, closeTo(yEsperado, 0.001));
    });

    test('V2 por cultura e MO: soja MO baixa -> 70%', () {
      final v2 = CalagemEngine.v2PorCulturaEMO(cultura: 'Soja', moPercent: 3.5);
      expect(v2, equals(70.0));
    });

    test('V2 por cultura e MO: milho MO alta -> 60%', () {
      final v2 =
          CalagemEngine.v2PorCulturaEMO(cultura: 'Milho', moPercent: 5.0);
      expect(v2, equals(60.0));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // SEÇÃO 5 — Correções
  // ─────────────────────────────────────────────────────────────────────────
  group('Seção 5 — Sequência de correções', () {
    test('NC_prof = NC_base × profFator', () {
      final corr = CalagemEngine.aplicarCorrecoes(
        ncBase: 2.0,
        profFator: 2.03,
        prnt: 100.0,
        scFator: 1.0,
      );
      expect(corr.ncProfundidade, closeTo(4.06, 0.01));
    });

    test('NC_prnt = NC_prof ÷ (PRNT/100)', () {
      final corr = CalagemEngine.aplicarCorrecoes(
        ncBase: 2.0,
        profFator: 1.0,
        prnt: 90.0,
        scFator: 1.0,
      );
      // NC_prnt = 2.0 / 0.9 ≈ 2.222
      expect(corr.ncPRNT, closeTo(2.222, 0.01));
    });

    test('Dose_final = NC_prnt ÷ SC', () {
      final corr = CalagemEngine.aplicarCorrecoes(
        ncBase: 2.0,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 0.8,
      );
      // Dose = 2.0 / 0.8 = 2.5
      expect(corr.doseFinal, closeTo(2.5, 0.01));
    });

    test('PRNT=0 retorna doseFinal=0', () {
      final corr = CalagemEngine.aplicarCorrecoes(
        ncBase: 2.0,
        profFator: 1.0,
        prnt: 0.0,
        scFator: 1.0,
      );
      expect(corr.doseFinal, equals(0.0));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // SEÇÃO 7 — Nutrientes adicionados e saturações finais
  // ─────────────────────────────────────────────────────────────────────────
  group('Seção 7 — Nutrientes adicionados', () {
    test('FatoresCalcario Dolomítico: Ca=0.536, Mg=0.443', () {
      expect(FatoresCalcario.getFatorCa('Dolomítico'), equals(0.536));
      expect(FatoresCalcario.getFatorMg('Dolomítico'), equals(0.443));
    });

    test('FatoresCalcario Calcítico: Ca=0.800, Mg=0.050', () {
      expect(FatoresCalcario.getFatorCa('Calcítico'), equals(0.800));
      expect(FatoresCalcario.getFatorMg('Calcítico'), equals(0.050));
    });

    test('FatoresCalcario Magnesiano: Ca=0.600, Mg=0.300', () {
      expect(FatoresCalcario.getFatorCa('Magnesiano'), equals(0.600));
      expect(FatoresCalcario.getFatorMg('Magnesiano'), equals(0.300));
    });

    test('Ca adicionado = dose × FatorCa', () {
      final nut = CalagemEngine.calcularNutrientesAdicionados(
        analise: analise,
        doseFinalTHa: 2.0,
        tipoCalcario: 'Dolomítico',
      );
      // Ca = 2.0 × 0.536 = 1.072 cmolc/dm³
      expect(nut.caAdicionado, closeTo(1.072, 0.01));
    });

    test('Mg adicionado = dose × FatorMg', () {
      final nut = CalagemEngine.calcularNutrientesAdicionados(
        analise: analise,
        doseFinalTHa: 2.0,
        tipoCalcario: 'Dolomítico',
      );
      // Mg = 2.0 × 0.443 = 0.886 cmolc/dm³
      expect(nut.mgAdicionado, closeTo(0.886, 0.01));
    });

    test('V% final maior que V% original quando dose > 0', () {
      final nut = CalagemEngine.calcularNutrientesAdicionados(
        analise: analise,
        doseFinalTHa: 3.0,
        tipoCalcario: 'Dolomítico',
      );
      final vOriginal = CalagemEngine.calcularV(analise);
      expect(nut.vPctFinal, greaterThan(vOriginal));
    });

    test('%K calculado na nova CTC', () {
      final nut = CalagemEngine.calcularNutrientesAdicionados(
        analise: analise,
        doseFinalTHa: 2.0,
        tipoCalcario: 'Dolomítico',
      );
      expect(nut.pctK, greaterThan(0));
      expect(nut.pctCa + nut.pctMg + nut.pctK, lessThanOrEqualTo(100.0 + 0.5));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTODO ① — Saturação por Bases
  // ─────────────────────────────────────────────────────────────────────────
  group('Método ① — Saturação por Bases (V%)', () {
    test('NC_base = ((V2-V1) × CTC) / 100 para V2=70%', () {
      final r = CalagemEngine.metodo1SaturacaoBases(
        analise: analise,
        v2: 70.0,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
      );
      // V1 = 57.08%, V2 = 70%, CTC = 4.66
      // NC = (70-57.08)/100 × 4.66 = 0.1292 × 4.66 ≈ 0.602 t/ha
      expect(r.ncBase, closeTo(0.602, 0.05));
      expect(r.metodo, equals(MetodoCalagem.saturacaoBases));
    });

    test('Dose = 0 quando V% atual >= V2', () {
      final r = CalagemEngine.metodo1SaturacaoBases(
        analise: analise,
        v2: 50.0,
        profFator: 1.0,
        prnt: 90.0,
        scFator: 1.0,
      );
      expect(r.doseFinal, equals(0.0));
    });

    test('ProfFator 2.03 dobra a dose em relação a 1.0', () {
      final r1 = CalagemEngine.metodo1SaturacaoBases(
        analise: analise,
        v2: 70.0,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
      );
      final r2 = CalagemEngine.metodo1SaturacaoBases(
        analise: analise,
        v2: 70.0,
        profFator: 2.03,
        prnt: 100.0,
        scFator: 1.0,
      );
      expect(r2.doseFinal, closeTo(r1.doseFinal * 2.03, 0.05));
    });

    test('PRNT=90% aumenta dose em relação a PRNT=100%', () {
      final r90 = CalagemEngine.metodo1SaturacaoBases(
        analise: analise,
        v2: 70.0,
        profFator: 1.0,
        prnt: 90.0,
        scFator: 1.0,
      );
      final r100 = CalagemEngine.metodo1SaturacaoBases(
        analise: analise,
        v2: 70.0,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
      );
      expect(r90.doseFinal, greaterThan(r100.doseFinal));
    });

    test('Aviso de H+Al > 3 quando H+Al = 4', () {
      final analiseHAl4 = analise.copyWith(HAl: 4.0);
      final r = CalagemEngine.metodo1SaturacaoBases(
        analise: analiseHAl4,
        v2: 70.0,
        profFator: 1.0,
        prnt: 90.0,
        scFator: 1.0,
      );
      expect(r.observacoes.any((o) => o.contains('alto tampão')), isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTODO ② — EMBRAPA (H+Al × Fator)
  // ─────────────────────────────────────────────────────────────────────────
  group('Método ② — EMBRAPA (H+Al × Fator)', () {
    test('NC_base = H+Al × fator com fator=0.5', () {
      final r = CalagemEngine.metodo2Embrapa(
        analise: analise,
        fator: 0.5,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
      );
      // NC = 2.0 × 0.5 = 1.0 t/ha
      expect(r.ncBase, closeTo(1.0, 0.01));
      expect(r.metodo, equals(MetodoCalagem.embrapa));
    });

    test('NC_base = H+Al × fator com fator=1.0', () {
      final r = CalagemEngine.metodo2Embrapa(
        analise: analise,
        fator: 1.0,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
      );
      expect(r.ncBase, closeTo(2.0, 0.01));
    });

    test('Fator fora de 0.3-1.0 gera aviso', () {
      final r = CalagemEngine.metodo2Embrapa(
        analise: analise,
        fator: 1.5,
        profFator: 1.0,
        prnt: 90.0,
        scFator: 1.0,
      );
      expect(r.observacoes.any((o) => o.contains('fora da faixa')), isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTODO ③ — NC = Ca + Mg
  // ─────────────────────────────────────────────────────────────────────────
  group('Método ③ — Ca + Mg', () {
    test('NC_base = Ca + Mg atuais', () {
      final r = CalagemEngine.metodo3CaMg(
        analise: analise,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
      );
      // NC = 2.0 + 0.5 = 2.5
      expect(r.ncBase, closeTo(2.5, 0.01));
      expect(r.metodo, equals(MetodoCalagem.caMg));
    });

    test('Observação menciona limitação do método', () {
      final r = CalagemEngine.metodo3CaMg(
        analise: analise,
        profFator: 1.0,
        prnt: 90.0,
        scFator: 1.0,
      );
      expect(r.observacoes.any((o) => o.contains('Fancelli')), isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTODO ④ — Supercalagem (Dose Fixa)
  // ─────────────────────────────────────────────────────────────────────────
  group('Método ④ — Supercalagem (dose fixa)', () {
    test('NC_base = dose fixa fornecida (1.75 t/ha)', () {
      final r = CalagemEngine.metodo4Supercalagem(
        analise: analise,
        doseFixa: 1.75,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
      );
      expect(r.ncBase, equals(1.75));
      expect(r.metodo, equals(MetodoCalagem.supercalagem));
    });

    test('NC_base independe da análise — dose diferente para mesma análise',
        () {
      final r1 = CalagemEngine.metodo4Supercalagem(
        analise: analise,
        doseFixa: 1.75,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
      );
      final r2 = CalagemEngine.metodo4Supercalagem(
        analise: analise,
        doseFixa: 3.0,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
      );
      expect(r2.ncBase, greaterThan(r1.ncBase));
    });

    test('pH < 4.5 gera aviso de parcelamento', () {
      final analisePH4 = analise.copyWith(pH: 4.2);
      final r = CalagemEngine.metodo4Supercalagem(
        analise: analisePH4,
        doseFixa: 1.75,
        profFator: 1.0,
        prnt: 90.0,
        scFator: 1.0,
      );
      expect(r.observacoes.any((o) => o.contains('Parcelar')), isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTODO ⑤ — Albrecht (Equilíbrio de Bases)
  // ─────────────────────────────────────────────────────────────────────────
  group('Método ⑤ — Albrecht (equilíbrio de bases)', () {
    test('Calcula dose positiva para Ca deficiente', () {
      final r = CalagemEngine.metodo5Albrecht(
        analise: analise,
        pctCaAlvo: 60.0,
        pctMgAlvo: 10.0,
        pctKAlvo: 3.0,
        profFator: 1.0,
        prnt: 90.0,
        scFator: 1.0,
        caOPct: 38.0,
        mgOPct: 13.0,
      );
      expect(r.metodo, equals(MetodoCalagem.albrecht));
      // Ca atual = 2.0, CTC = 4.66, Ca alvo (60%) = 2.796 → deficit > 0
      expect(r.ncBase, greaterThan(0));
    });

    test('Dose = 0 quando Ca já na faixa ideal', () {
      const analiseRicaMax = AnaliseSolo(
        id: 'rica2',
        Ca: 8.0,
        Mg: 2.0,
        K: 0.3,
        HAl: 1.0,
        argila: 20.0,
      );
      final r = CalagemEngine.metodo5Albrecht(
        analise: analiseRicaMax,
        pctCaAlvo: 60.0,
        pctMgAlvo: 10.0,
        pctKAlvo: 3.0,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
        caOPct: 38.0,
        mgOPct: 13.0,
      );
      // CTC = 11.3; Ca alvo = 6.78 → Ca atual (8.0) > alvo → deficit = 0
      expect(r.ncBase, equals(0.0));
    });

    test('Observações incluem recomendação de KCl quando há déficit de K', () {
      final r = CalagemEngine.metodo5Albrecht(
        analise: analise,
        pctCaAlvo: 60.0,
        pctMgAlvo: 10.0,
        pctKAlvo: 5.0,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
        caOPct: 38.0,
        mgOPct: 13.0,
      );
      expect(r.observacoes.any((o) => o.contains('KCl estimado')), isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTODO ⑥ — Albrecht com Tampão Y
  // ─────────────────────────────────────────────────────────────────────────
  group('Método ⑥ — Albrecht com Tampão Y', () {
    test('NC = max(Albrecht, Y)', () {
      final r = CalagemEngine.metodo6AlbrechtY(
        analise: analise,
        pctCaAlvo: 60.0,
        pctMgAlvo: 10.0,
        pctKAlvo: 3.0,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
        caOPct: 38.0,
        mgOPct: 13.0,
      );
      final y = CalagemEngine.calcularY(argila: analise.argila);
      expect(r.metodo, equals(MetodoCalagem.albrechtY));
      expect(r.yUtilizado, closeTo(y, 0.01));
      // NC deve ser >= Y
      expect(r.ncBase, greaterThanOrEqualTo(r.yUtilizado));
    });

    test('Observação menciona qual componente governa (Y ou Albrecht)', () {
      final r = CalagemEngine.metodo6AlbrechtY(
        analise: analise,
        pctCaAlvo: 60.0,
        pctMgAlvo: 10.0,
        pctKAlvo: 3.0,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
        caOPct: 38.0,
        mgOPct: 13.0,
      );
      expect(
        r.observacoes
            .any((o) => o.contains('governa') || o.contains('prevalece')),
        isTrue,
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTODO ⑦ — Correção Direcionada de Mg
  // ─────────────────────────────────────────────────────────────────────────
  group('Método ⑦ — Correção Direcionada de Mg', () {
    test('NC = Deficit_Mg / FatorMg (Magnesiano=0.300)', () {
      final r = CalagemEngine.metodo7CorrecaoMg(
        analise: analise,
        mgDesejado: 1.5,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
        tipoCalcario: 'Magnesiano',
      );
      // Deficit = 1.5 - 0.5 = 1.0 cmolc/dm³
      // NC = 1.0 / 0.300 ≈ 3.33 t/ha
      expect(r.ncBase, closeTo(3.33, 0.1));
      expect(r.metodo, equals(MetodoCalagem.correcaoMg));
      expect(r.tipoCalcario, equals('Magnesiano'));
    });

    test('NC = 0 quando Mg já satisfatório', () {
      final r = CalagemEngine.metodo7CorrecaoMg(
        analise: analise,
        mgDesejado: 0.3,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
      );
      expect(r.doseFinal, equals(0.0));
    });

    test('NC com Dolomítico usa fator 0.443', () {
      final r = CalagemEngine.metodo7CorrecaoMg(
        analise: analise,
        mgDesejado: 1.5,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
        tipoCalcario: 'Dolomítico',
      );
      // Deficit = 1.5 - 0.5 = 1.0
      // NC = 1.0 / 0.443 ≈ 2.257
      expect(r.ncBase, closeTo(2.257, 0.05));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // CONSISTÊNCIA ENTRE MÉTODOS
  // ─────────────────────────────────────────────────────────────────────────
  group('Consistência entre métodos', () {
    test('Método ⑥ (Albrecht+Y) sempre >= Método ⑤ (Albrecht puro)', () {
      final m5 = CalagemEngine.metodo5Albrecht(
        analise: analise,
        pctCaAlvo: 60,
        pctMgAlvo: 10,
        pctKAlvo: 3,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
      );
      final m6 = CalagemEngine.metodo6AlbrechtY(
        analise: analise,
        pctCaAlvo: 60,
        pctMgAlvo: 10,
        pctKAlvo: 3,
        profFator: 1.0,
        prnt: 100.0,
        scFator: 1.0,
      );
      expect(m6.ncBase, greaterThanOrEqualTo(m5.ncBase));
    });

    test('Todos os métodos retornam vPctFinal >= vPctAtual quando dose > 0',
        () {
      final vOriginal = CalagemEngine.calcularV(analise);

      final r1 = CalagemEngine.metodo1SaturacaoBases(
        analise: analise,
        v2: 70,
        profFator: 1,
        prnt: 90,
        scFator: 1,
      );
      final r2 = CalagemEngine.metodo2Embrapa(
        analise: analise,
        fator: 0.5,
        profFator: 1,
        prnt: 90,
        scFator: 1,
      );
      final r3 = CalagemEngine.metodo3CaMg(
        analise: analise,
        profFator: 1,
        prnt: 90,
        scFator: 1,
      );

      for (final r in [r1, r2, r3]) {
        if (r.doseFinal > 0) {
          expect(r.vPctFinal, greaterThan(vOriginal),
              reason:
                  '${r.metodo.nome}: vPctFinal deve ser > vAtual quando dose > 0');
        }
      }
    });
  });
}
