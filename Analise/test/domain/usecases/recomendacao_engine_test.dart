import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/entities/analise_entity.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
import 'package:soloforte/domain/entities/resultado_gesso.dart';

// ─── Fixtures ────────────────────────────────────────────────────────────────

/// Análise padrão baseada no exemplo da Aula 10 Fancelli (ESALQ).
/// Ca=2.0, Mg=0.5, K=0.16, H+Al=3.38 → CTC=6.04, V%=43.7%, argila=35%
const _fancelli = AnaliseEntity(
  id: 'test-fancelli',
  nome: 'Fancelli Aula 10',
  consultor: 'Teste',
  fazenda: '',
  talhao: '',
  localizacao: '',
  cultura: 'Soja',
  ph: 5.2,
  mo: 30,
  p: 12,
  k: 0.16,
  ca: 2.0,
  mg: 0.5,
  hAl: 3.38,
  al: 0.3,
  s: 6,
  b: 0.2,
  cu: 0.5,
  fe: 30,
  mn: 4,
  zn: 1.2,
  sb: 2.66,
  ctc: 6.04, // SB + H+Al
  vPercent: 43.7,
  argila: 35,
);

/// Análise para método EMBRAPA: H+Al=2.0, resto padrão.
const _embrapa = AnaliseEntity(
  id: 'test-embrapa',
  nome: 'Embrapa Cerrado',
  consultor: 'Teste',
  fazenda: '',
  talhao: '',
  localizacao: '',
  cultura: 'Milho',
  ph: 5.0,
  mo: 25,
  p: 8,
  k: 0.15,
  ca: 1.8,
  mg: 0.4,
  hAl: 2.0,
  al: 0.5,
  s: 4,
  b: 0.18,
  cu: 0.3,
  fe: 22,
  mn: 3,
  zn: 0.9,
  sb: 2.35,
  ctc: 4.35,
  vPercent: 54.0,
  argila: 28,
);

void main() {
  const engine = RecomendacaoEngine();

  // ── helper para evitar repetição nos testes ──────────────────────────────
  double doseV({
    required AnaliseEntity analise,
    required double v2,
    required double prnt,
    double profundidade = 20.0,
    double sc = 1.0,
  }) =>
      engine.calcularDoseCalcario(
        metodo: '① Saturação por Bases (V%)',
        analise: analise,
        prnt: prnt,
        profundidade: profundidade,
        sc: sc,
        corretivos: {'v2': v2},
        albrecht: {},
        caO: 30.0,
        mgO: 16.0,
        tabelas: [],
      );

  // ─────────────────────────────────────────────────────────────────────────
  // Método ① — Saturação por Bases (V%)
  // ─────────────────────────────────────────────────────────────────────────
  group('calcularDoseCalcario — ① Saturação por Bases (V%)', () {
    test('Fancelli Aula 10: vd=70, va=43.7, CTC=6.04, PRNT=80 → ~1.985 t/ha',
        () {
      // NC = (70 - 43.7) × 6.04 / 100 = 26.3 × 6.04 / 100 = 1.5885
      // Dose = 1.5885 / (80/100) = 1.9856 t/ha
      final dose = doseV(analise: _fancelli, v2: 70, prnt: 80);
      expect(dose, closeTo(1.985, 0.05));
    });

    test('Solo Cerrado Embrapa: vd=50, va=43.7, CTC=6.04, PRNT=80 → menor dose',
        () {
      // V% atual já é 43.7 < 50 → deve haver dose positiva mas menor
      final dose50 = doseV(analise: _fancelli, v2: 50, prnt: 80);
      final dose70 = doseV(analise: _fancelli, v2: 70, prnt: 80);
      expect(dose50, greaterThan(0));
      expect(dose50, lessThan(dose70));
    });

    test('V% atual >= V% desejado → dose zero', () {
      // Va=43.7, Vd=40 → sem necessidade de calcário
      final dose = doseV(analise: _fancelli, v2: 40, prnt: 80);
      expect(dose, equals(0.0));
    });

    test('PRNT menor aumenta dose (PRNT=70 > PRNT=100)', () {
      final dose70 = doseV(analise: _fancelli, v2: 70, prnt: 70);
      final dose100 = doseV(analise: _fancelli, v2: 70, prnt: 100);
      expect(dose70, greaterThan(dose100));
    });

    test('PRNT=0 lança ArgumentError', () {
      expect(
        () => doseV(analise: _fancelli, v2: 70, prnt: 0),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Método ② — EMBRAPA (H+Al × fator)
  // ─────────────────────────────────────────────────────────────────────────
  group('calcularDoseCalcario — ② EMBRAPA (H+Al × fator)', () {
    double doseEmbrapa({double fator = 0.5, double prnt = 100}) =>
        engine.calcularDoseCalcario(
          metodo: '② EMBRAPA (H+Al × fator)',
          analise: _embrapa,
          prnt: prnt,
          profundidade: 20.0,
          sc: 1.0,
          corretivos: {'fatorHAl': fator},
          albrecht: {},
          caO: 30.0,
          mgO: 16.0,
          tabelas: [],
        );

    test('H+Al=2.0, fator=0.5, PRNT=100 → NC_base=1.0 t/ha', () {
      // NC = 2.0 × 0.5 = 1.0; profFator=1.0 (20cm/20); dose = 1.0
      expect(doseEmbrapa(), closeTo(1.0, 0.01));
    });

    test('Fator=1.0 dobra a dose em relação a fator=0.5', () {
      final d05 = doseEmbrapa(fator: 0.5);
      final d10 = doseEmbrapa(fator: 1.0);
      expect(d10, closeTo(d05 * 2, 0.01));
    });

    test('PRNT=90% aumenta dose em relação a PRNT=100%', () {
      final d90 = doseEmbrapa(prnt: 90);
      final d100 = doseEmbrapa(prnt: 100);
      expect(d90, greaterThan(d100));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Método ③ — Ca + Mg
  // ─────────────────────────────────────────────────────────────────────────
  group('calcularDoseCalcario — ③ Ca + Mg', () {
    test('NC_base = Ca + Mg atuais (PRNT=100, prof=20cm)', () {
      // Ca=2.0, Mg=0.5 → NC_base=2.5; dose=2.5
      final dose = engine.calcularDoseCalcario(
        metodo: '③ Ca + Mg',
        analise: _fancelli,
        prnt: 100,
        profundidade: 20,
        sc: 1.0,
        corretivos: {},
        albrecht: {},
        caO: 30,
        mgO: 16,
        tabelas: [],
      );
      expect(dose, closeTo(2.5, 0.01));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Método ④ — Supercalagem (dose fixa)
  // ─────────────────────────────────────────────────────────────────────────
  group('calcularDoseCalcario — ④ Supercalagem (dose fixa)', () {
    test('Dose fixa=3.0, PRNT=100 → retorna 3.0 t/ha', () {
      final dose = engine.calcularDoseCalcario(
        metodo: '④ Supercalagem',
        analise: _fancelli,
        prnt: 100,
        profundidade: 20,
        sc: 1.0,
        corretivos: {'doseFixa': 3.0},
        albrecht: {},
        caO: 30,
        mgO: 16,
        tabelas: [],
      );
      expect(dose, closeTo(3.0, 0.01));
    });

    test('Dose fixa padrão de 1.5 quando sem config', () {
      final dose = engine.calcularDoseCalcario(
        metodo: '④ Supercalagem',
        analise: _fancelli,
        prnt: 100,
        profundidade: 20,
        sc: 1.0,
        corretivos: {}, // sem doseFixa → fallback 1.5
        albrecht: {},
        caO: 30,
        mgO: 16,
        tabelas: [],
      );
      expect(dose, closeTo(1.5, 0.01));
    });
  });

  group('calcularDoseCalcario — ⑤/⑥ Albrecht', () {
    test('⑤ Albrecht calcula dose usando metas padrão quando sem tabela', () {
      final dose = engine.calcularDoseCalcario(
        metodo: '⑤ Albrecht (equilíbrio de bases)',
        analise: _fancelli,
        prnt: 90,
        profundidade: 20,
        sc: 1.0,
        corretivos: {},
        albrecht: {},
        caO: 30,
        mgO: 16,
        tabelas: const [],
      );

      expect(dose, greaterThanOrEqualTo(0));
    });

    test('⑥ Albrecht + Tampão Y retorna dose válida', () {
      final dose = engine.calcularDoseCalcario(
        metodo: '⑥ Albrecht + Tampão Y',
        analise: _fancelli,
        prnt: 80,
        profundidade: 20,
        sc: 1.0,
        corretivos: {},
        albrecht: {},
        caO: 30,
        mgO: 16,
        tabelas: const [],
      );

      expect(dose, greaterThanOrEqualTo(0));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Método fallback — SMP (nenhum ① a ⑦)
  // ─────────────────────────────────────────────────────────────────────────
  group('calcularDoseCalcario — SMP (fallback)', () {
    test('pH ácido com tabelas vazias retorna > 0 (usa tabela interna SMP)',
        () {
      // Sem tabelas → ncBaseSmp=0 → usa tabela interna do metodoSMP
      // pH=5.2 → ncBase interno = 5.0 t/ha
      final dose = engine.calcularDoseCalcario(
        metodo: 'SMP — Sem prefixo numérico',
        analise: _fancelli, // pH=5.2
        prnt: 90,
        profundidade: 20,
        sc: 1.0,
        corretivos: {},
        albrecht: {},
        caO: 30,
        mgO: 16,
        tabelas: [],
      );
      expect(dose, greaterThan(0));
    });

    test('PRNT maior → dose SMP menor', () {
      double doseSmp(double prnt) => engine.calcularDoseCalcario(
            metodo: 'SMP fallback',
            analise: _fancelli,
            prnt: prnt,
            profundidade: 20,
            sc: 1.0,
            corretivos: {},
            albrecht: {},
            caO: 30,
            mgO: 16,
            tabelas: [],
          );
      expect(doseSmp(90), greaterThan(doseSmp(100)));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // calcularGesso
  // ─────────────────────────────────────────────────────────────────────────
  group('calcularGesso', () {
    const diagnostico = DiagnosticoGesso(
      indicado: true,
      caSubBaixo: true,
      alSubAlto: false,
      mSubAlto: false,
      motivos: [],
    );

    test('Critério ESALQ (Vitti et al., 2004) - método ③', () {
      // ctcm = 45.0, vamos simular va = 21.5 / 0.75 e ctc = 45.0 / 0.7
      final analiseGesso = _fancelli.copyWith(
        vPercent: 21.5 / 0.75,
        ctc: 45.0 / 0.7,
      );

      final res = engine.calcularGesso(
        metodo: '③ Critério ESALQ (Vitti et al., 2004)',
        analise: analiseGesso,
        diagnostico: diagnostico,
      );

      expect(res.doseTHa, closeTo(2.565, 0.05));
    });

    test('Critério UEPG/Caires - método ④', () {
      // ctcEfetivaSub = 7.0, caSub = 2.5
      // ctcEfetiva = 10.0, ca = 6.25, mg=0, k=0, al=0
      final analiseUepg = _fancelli.copyWith(
        ca: 6.25,
        mg: 0.0,
        k: 0.0,
        al: 3.75, // ctcEfetiva = 10.0
      );

      final res = engine.calcularGesso(
        metodo: '④ Critério UEPG/Caires',
        analise: analiseUepg,
        diagnostico: diagnostico,
      );

      // (0.6 * 7.0 - 2.5) * 6.4 = 1.7 * 6.4 = 10.88
      expect(res.doseTHa, closeTo(10.88, 0.01));
    });

    test('Critério textura - método ② retorna resultado', () {
      final res = engine.calcularGesso(
        metodo: '② Critério textura',
        analise: _fancelli,
        diagnostico: diagnostico,
      );

      expect(res.doseTHa, greaterThanOrEqualTo(0));
    });

    test('Método desconhecido usa fallback ① EMBRAPA', () {
      final res = engine.calcularGesso(
        metodo: 'método não mapeado',
        analise: _fancelli,
        diagnostico: diagnostico,
      );

      expect(res.metodo, MetodoGesso.argilaEmbrapa);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // calcularFosforo
  // ─────────────────────────────────────────────────────────────────────────
  group('calcularFosforo', () {
    test('IAC Bol.100, argila <15%, P_Resina atual < NC', () {
      final analiseFosforo = _fancelli.copyWith(
        argila: 10.0,
        p: 8.0,
      );

      final res = engine.calcularFosforo(
        fosforo: {
          'modoCalculo': '① Correção do solo',
          'referencia': 'IAC Bol.100',
          'nc': 12.0, // fallback
        },
        analise: analiseFosforo,
        cultura: 'Milho',
        tabelas: [],
      );

      expect(res.doseP, greaterThan(0.0));
      expect(res.legacyP, isFalse);
    });

    test(
        'P atual já acima do NC: doseP deve ser igual exportacao (extracao) se legacyP, senao zero ou minimo',
        () {
      final analiseFosforo = _fancelli.copyWith(
        argila: 25.0,
        p: 30.0, // alto!
      );

      final res = engine.calcularFosforo(
        fosforo: {
          'modoCalculo': '① Correção do solo',
          'referencia': 'IAC Bol.100',
        },
        analise: analiseFosforo,
        cultura: 'Milho',
        tabelas: [],
      );

      // P > NC -> manutencao
      expect(res.legacyP, isTrue);
      // Dose de milho exportacao = 110, e exportação manutenção = exportacao * 0.3 = 33.0
      expect(res.doseP, closeTo(33.0, 0.01));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // calcularMicros
  // ─────────────────────────────────────────────────────────────────────────
  group('calcularMicros', () {
    test('elemento deficiente retorna dose > 0', () {
      final res = engine.calcularMicros(
        micros: {
          'elementos': {
            'Zn': {
              'viaAplicacao': 'Solo (correção)',
              'ncSolo': 2.0,
              'teorFonteSolo': 20.0,
              'eficienciaSolo': 100.0,
              'percentualCorrecaoSolo': 100.0,
            }
          }
        },
        analise: _fancelli.copyWith(zn: 1.0), // defi: 2 - 1 = 1g/dm3 = 200g/ha
      );
      expect(res.length, 1);
      expect(res.first.elemento, 'Zn');
      expect(res.first.dose, closeTo(200.0, 0.1));
      expect(res.first.deficiente, isTrue);
    });

    test('elemento acima do NC retorna dose = 0 (vazio na lista)', () {
      final res = engine.calcularMicros(
        micros: {
          'elementos': {
            'Zn': {
              'viaAplicacao': 'Solo (correção)',
              'ncSolo': 2.0,
            }
          }
        },
        analise: _fancelli.copyWith(zn: 3.0),
      );
      expect(res, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Método Orquestrador: calcular()
  // ─────────────────────────────────────────────────────────────────────────
  group('RecomendacaoEngine.calcular', () {
    final perfil = CalibracaoProfile(
      id: 'test-p1',
      nome: 'Perfil Teste',
      cultura: 'Soja',
      safra: '2024',
      cliente: 'Cliente',
      fazenda: 'Fazenda',
      talhao: 'T1',
      observacoes: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      parametrosCards: {
        'corretivos': {
          'metodoCalagem': '① Saturação por Bases (V%)',
          'v2': 70.0,
          'calcario1': {'prnt': 80.0, 'caO': 30.0, 'mgO': 16.0},
          'sc': 1.0,
          'gesso': {'usarGesso': false},
        },
        'fosforo': {
          'modoCalculo': '① Correção do solo',
        },
        'potassio': {
          'modoCalculo': '① Correção do solo',
          'criterioNc': 'Ambos — usar o maior',
        },
        'micros': {
          'elementos': {},
          'grupos': [],
        },
      },
    );

    test('Integração básica: retorna objeto completo com doses coerentes', () {
      final resultado = engine.calcular(
        analise: _fancelli,
        calibracao: perfil,
        tabelas: [],
      );

      expect(resultado.analise.id, _fancelli.id);
      expect(resultado.doseCalcarioTHa, greaterThan(0));
      expect(resultado.relacoesK.relKMg, isNotNull);
      expect(resultado.relacoesK.relKCa, isNotNull);
      expect(resultado.avisos, isA<List<String>>());
    });

    test('calcula doses informativas de absorção/exportação quando configuradas',
        () {
      final perfilComAbsorcao = perfil.copyWith(
        produtividadeEsperadaTha: 4.0,
        parametrosCards: {
          ...perfil.parametrosCards,
          'fosforo': {
            ...Map<String, dynamic>.from(perfil.parametrosCards['fosforo'] as Map),
            'fosforoTipoFonte': 'Autores',
            'fosforoFonteNome': 'EMBRAPA',
            'fosforoModoAbsorcao': 'extracao',
          },
          'potassio': {
            ...Map<String, dynamic>.from(
                perfil.parametrosCards['potassio'] as Map),
            'potassioTipoFonte': 'Autores',
            'potassioFonteNome': 'EMBRAPA',
            'potassioModoAbsorcao': 'exportacao',
          },
        },
      );

      final resultado = engine.calcular(
        analise: _fancelli,
        calibracao: perfilComAbsorcao,
        tabelas: const [],
      );

      expect(resultado.doseAbsorcaoP, isNotNull);
      expect(resultado.doseAbsorcaoK, isNotNull);
      expect(resultado.doseAbsorcaoP!, greaterThan(0));
      expect(resultado.doseAbsorcaoK!, greaterThan(0));
    });
  });

  group('helpers de tabelas dinâmicas', () {
    final tabelas = <Map<String, dynamic>>[
      {
        'chave': 'fosforo_nc_resina',
        'linhas': [
          {'argilaMin': 0, 'argilaMax': 15, 'valor': 12.0},
          {'argilaMin': 15, 'argilaMax': 60, 'valor': 30.0},
        ],
      },
      {
        'chave': 'fosforo_nc_cerrado',
        'linhas': [
          {'argilaMin': 0, 'argilaMax': 20, 'valor': 15.0},
          {'argilaMin': 20, 'argilaMax': 60, 'valor': 8.0},
        ],
      },
      {
        'chave': 'fosforo_nc_rssc',
        'linhas': [
          {'argilaMin': 0, 'argilaMax': 20, 'valor': 21.0},
          {'argilaMin': 20, 'argilaMax': 60, 'valor': 12.0},
        ],
      },
      {
        'chave': 'fosforo_nc_ufla',
        'linhas': [
          {'argilaMin': 0, 'argilaMax': 20, 'valor': 20.0},
          {'argilaMin': 20, 'argilaMax': 60, 'valor': 10.0},
        ],
      },
      {
        'chave': 'fosforo_fep',
        'linhas': [
          {'argilaMin': 0, 'argilaMax': 20, 'valor': 30.0},
          {'argilaMin': 20, 'argilaMax': 60, 'valor': 15.0},
        ],
      },
      {
        'chave': 'potassio_nc_teor',
        'linhas': [
          {'argilaMin': 0, 'argilaMax': 20, 'valor': 40.0},
          {'argilaMin': 20, 'argilaMax': 60, 'valor': 80.0},
        ],
      },
      {
        'chave': 'potassio_fek',
        'linhas': [
          {'argilaMin': 0, 'argilaMax': 20, 'valor': 50.0},
          {'argilaMin': 20, 'argilaMax': 60, 'valor': 65.0},
        ],
      },
      {
        'chave': 'potassio_antagonismos',
        'linhas': [
          {'chaveValor': 'limite_k_ctc', 'valor': 7.5},
          {'chaveValor': 'limite_k_mg', 'valor': 1.2},
          {'chaveValor': 'limite_k_ca', 'valor': 0.45},
        ],
      },
      {
        'chave': 'calagem_metas_albrecht',
        'linhas': [
          {'chaveValor': 'pct_ca', 'valor': 62.0},
          {'chaveValor': 'pct_mg', 'valor': 16.0},
          {'chaveValor': 'pct_k', 'valor': 4.5},
        ],
      },
      {
        'chave': 'calagem_smp',
        'linhas': [
          {'phMin': 0.0, 'phMax': 5.0, 'valor': 10.0},
          {'phMin': 5.0, 'phMax': 6.0, 'valor': 5.0},
          {'phMin': 6.0, 'phMax': 9.9, 'valor': 0.0},
        ],
      },
    ];

    test('ncFosforoPorReferencia usa tabela por referência', () {
      expect(
        ncFosforoPorReferencia(
          referencia: 'IAC Bol.100',
          argilaPercent: 10,
          tabelas: tabelas,
        ),
        12.0,
      );
      expect(
        ncFosforoPorReferencia(
          referencia: 'Embrapa Cerrado',
          argilaPercent: 30,
          tabelas: tabelas,
        ),
        8.0,
      );
      expect(
        ncFosforoPorReferencia(
          referencia: 'Embrapa RS/SC',
          argilaPercent: 30,
          tabelas: tabelas,
        ),
        12.0,
      );
      expect(
        ncFosforoPorReferencia(
          referencia: 'UFLA / CFSEMG',
          argilaPercent: 30,
          tabelas: tabelas,
        ),
        10.0,
      );
    });

    test('helpers de K e FEP usam tabela e fallback padrão', () {
      expect(fepBaseTabela(argilaPercent: 30, tabelas: tabelas), 15.0);
      expect(ncPotassioTeorTabela(argilaPercent: 30, tabelas: tabelas), 80.0);
      expect(fekBaseTabela(argilaPercent: 30, tabelas: tabelas), 65.0);

      // Sem tabela, deve usar fallback padrão interno por argila.
      expect(ncPotassioTeorTabela(argilaPercent: 10, tabelas: const []), 40.0);
      expect(fekBaseTabela(argilaPercent: 10, tabelas: const []), 50.0);
    });

    test('antagonismos e metas Albrecht leem chaves dinâmicas', () {
      final ant = antagonismosTabela(tabelas);
      expect(ant.limiteKCtc, 7.5);
      expect(ant.limiteKMg, 1.2);
      expect(ant.limiteKCa, 0.45);

      final metas = metasAlbrechtTabela(tabelas);
      expect(metas.pctCa, 62.0);
      expect(metas.pctMg, 16.0);
      expect(metas.pctK, 4.5);
    });

    test('ncSmpTabela usa tabela e fallback interno', () {
      expect(ncSmpTabela(phSmp: 5.2, tabelas: tabelas), 5.0);
      expect(ncSmpTabela(phSmp: 4.8, tabelas: const []), 10.0);
      expect(ncSmpTabela(phSmp: 6.5, tabelas: const []), 0.0);
    });
  });
}
