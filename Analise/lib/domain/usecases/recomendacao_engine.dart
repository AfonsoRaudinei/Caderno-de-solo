// lib/domain/usecases/recomendacao_engine.dart
//
// RE0 — Contratos públicos (Freezed)
// RE1 — calcularDoseCalcario migrado de _doseCalcario
//
// Referências agronômicas:
//   Fancelli (2020), Caires/UEPG (2019), EMBRAPA, IAC Bol.100, ESALQ/Vitti

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloforte/domain/entities/analise_entity.dart';
import 'package:soloforte/domain/entities/resultado_gesso.dart';
import 'package:soloforte/domain/formulas/calcario_formula.dart';
import 'package:soloforte/domain/formulas/conversoes.dart';
import 'package:soloforte/domain/formulas/fosforo_formula.dart';
import 'package:soloforte/domain/formulas/gesso_engine.dart';
import 'package:soloforte/domain/formulas/potassio_formula.dart';
import 'package:soloforte/domain/usecases/calcular_micronutrientes_recomendacao_usecase.dart';
import 'package:soloforte/domain/formulas/types/calcario_input.dart';
import 'package:soloforte/domain/formulas/types/fosforo_input.dart';
import 'package:soloforte/domain/formulas/types/gesso_input.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';
import 'package:soloforte/features/laboratorio/domain/services/absorcao_nutrientes_resolver.dart';

part 'recomendacao_engine.freezed.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tipos públicos — espelhos tipados dos privados da recomendacao_screen.dart
// ─────────────────────────────────────────────────────────────────────────────

@freezed
class RelacoesK with _$RelacoesK {
  const factory RelacoesK({
    required double relKMg,
    required double relKCa,
    required List<String> alertas,
    required double kNaCTC,
  }) = _RelacoesK;
}

@freezed
class MicroResultado with _$MicroResultado {
  const factory MicroResultado({
    /// Símbolo do elemento (ex: 'Zn', 'B', 'Cu')
    required String elemento,

    /// Teor atual na análise
    required double valorAtual,

    /// Nível crítico de referência
    required double nc,

    /// Déficit (NC − teor atual), limitado a zero
    @Default(0) double deficit,

    /// Correção do solo (g/ha elemento), após eficiência solo
    @Default(0) double correcaoSolo,

    /// Produção esperada (t/ha)
    @Default(0) double producaoTha,

    /// Extração calculada (g/ha)
    @Default(0) double extracao,

    /// Exportação calculada (g/ha)
    @Default(0) double exportacao,

    /// Regra Planta ou Grão
    @Default('') String regraUtilizada,

    /// Eficiência da via aplicada (%)
    @Default(0) double eficienciaAplicada,

    /// Necessidade do nutriente (g/ha elemento)
    @Default(0) double necessidadeNutriente,

    /// Dose recomendada do nutriente puro
    required double dose,

    /// Unidade da dose (ex: 'kg/ha', 'g/ha')
    required String unidade,

    /// true quando valorAtual < nc
    required bool deficiente,

    // -- Dados migrados da tela (UI) --
    required String via,
    required String fonte,
    required double doseProduto,
    required String doseProdutoLabel,

    /// Citação científica da referência usada
    String? referencia,
    @Default([]) List<String> avisosNutriente,
    @Default([]) List<String> memoriaCalculo,
    @Default('') String grupoNome,
    String? grupoId,
    @Default('%') String concentracaoUnidade,
    @Default(0) double doseMinima,
    @Default(0) double doseMaxima,
  }) = _MicroResultado;
}

@freezed
class GrupoResultado with _$GrupoResultado {
  const factory GrupoResultado({
    /// Nome do grupo (ex: 'Grupo NPK', 'Micros solo')
    required String nomeGrupo,

    /// Elementos que compõem este grupo
    required List<MicroResultado> micros,
    // -- Dados migrados da tela (UI) --
    required String via,
    required String produto,
    required String doseProdutoKgLabel,
    required String fornecimento,
  }) = _GrupoResultado;
}

@freezed
class ResultadoRecomendacao with _$ResultadoRecomendacao {
  const factory ResultadoRecomendacao({
    required AnaliseEntity analise,
    required CalibracaoProfile calibracao,
    RecomendacaoModel? base,
    String? labelAnalise,
    DateTime? geradaEm,
    required String metodoCalagem,

    // ── Calcário ──────────────────────────────────────────────────────────
    required double doseCalcarioTHa,
    required double vEsperado,
    required double caEsperado,
    required double mgEsperado,
    required double relacaoCaMg,

    /// Parcelas de aplicação quando dose > 4 t/ha
    required List<String> parcelamento,

    // ── Gesso ─────────────────────────────────────────────────────────────
    required ResultadoGesso gesso,

    // ── Fósforo ───────────────────────────────────────────────────────────
    /// Modo de cálculo selecionado (ex: '① Correção do solo')
    required String modoFosforo,
    required double ncFosforo,
    required double doseP2O5KgHa,
    required bool legacyP,

    // ── Potássio ──────────────────────────────────────────────────────────
    /// Critério selecionado (ex: '% K na CTC', 'Teor absoluto')
    required String criterioPotassio,
    required double ncPotassio,
    required double doseK2OKgHa,
    required RelacoesK relacoesK,

    // ── Micronutrientes ───────────────────────────────────────────────────
    required List<MicroResultado> micros,
    required List<GrupoResultado> grupos,

    // ── Absorção / Exportação (T4 — informativo, NÃO somado à dose solo) ────
    /// Dose de P₂O₅ kg/ha necessária para repor o P absorvido/exportado pela cultura.
    /// null quando productividade ou referência de absorção não estão configuradas.
    @Default(null) double? doseAbsorcaoP,

    /// Dose de K₂O kg/ha necessária para repor o K absorvido/exportado pela cultura.
    /// null quando productividade ou referência de absorção não estão configuradas.
    @Default(null) double? doseAbsorcaoK,

    // ── Diagnóstico ───────────────────────────────────────────────────────
    required List<String> avisos,
    required String argumentos,

    /// Citações acadêmicas agrupadas por nutriente
    Map<String, String>? citacoes,
  }) = _ResultadoRecomendacao;
}

// ─────────────────────────────────────────────────────────────────────────────
// Engine — esqueleto. Cada método será implementado em RE1/RE2/RE3.
// ─────────────────────────────────────────────────────────────────────────────

class RecomendacaoEngine {
  const RecomendacaoEngine();

  /// Ponto de entrada principal.
  /// Migração de _calcularResultado (RE1).
  ResultadoRecomendacao calcular({
    required AnaliseEntity analise,
    required CalibracaoProfile calibracao,
    required List<Map<String, dynamic>> tabelas,
    RecomendacaoModel? base,
    String? labelAnalise,
  }) {
    final corretivos = _asMap(calibracao.parametrosCards['corretivos']);
    final fosforo = _asMap(calibracao.parametrosCards['fosforo']);
    final potassio = _asMap(calibracao.parametrosCards['potassio']);
    final micros = _asMap(calibracao.parametrosCards['micros']);

    final metodoCalagem =
        _string(corretivos['metodoCalagem'], '① Saturação por Bases (V%)');
    final calcario1 = _asMap(corretivos['calcario1']);
    final albrecht = _asMap(corretivos['albrecht']);
    final prnt = _num(calcario1['prnt'], 80);
    final caO = _num(calcario1['caO'], 30);
    final mgO = _num(calcario1['mgO'], 16);
    final profundidade = _profundidade(corretivos);
    final sc = _num(corretivos['sc'], 1.0);

    final doseCalcario = calcularDoseCalcario(
      metodo: metodoCalagem,
      analise: analise,
      prnt: prnt,
      profundidade: profundidade,
      sc: sc,
      corretivos: corretivos,
      albrecht: albrecht,
      caO: caO,
      mgO: mgO,
      tabelas: tabelas,
    );

    final gessoConfig = _asMap(corretivos['gesso']);
    final usaGesso = _bool(gessoConfig['usarGesso']);
    final diagnostico = GessoEngine.diagnosticar(
      caSub: analise.ca * 0.4,
      alSub: analise.al * 0.8,
      mSub: _mSubEstimado(analise),
    );

    final resultadoGesso = usaGesso
        ? calcularGesso(
            metodo: _string(gessoConfig['metodo'],
                '① EMBRAPA / Souza et al. (2004) — argila %'),
            analise: analise,
            diagnostico: diagnostico,
          )
        : const ResultadoGesso(
            metodo: MetodoGesso.argilaEmbrapa,
            indicado: false,
            doseKgHa: 0,
            doseTHa: 0,
            sFornecidoKgHa: 0,
            caFornecidoKgHa: 0,
            caAumentoCmolcDm3: 0,
            observacoes: ['Gesso desativado na calibração.'],
          );

    final fosforoResult = calcularFosforo(
      fosforo: fosforo,
      analise: analise,
      cultura: calibracao.cultura,
      produtividadeEsperadaTha: calibracao.produtividadeEsperadaTha,
      tabelas: tabelas,
    );
    final ncP = fosforoResult.ncP;
    final doseP = fosforoResult.doseP;
    final legacyP = fosforoResult.legacyP;
    final modoP = fosforoResult.modoResumo;

    final potassioResult = calcularPotassio(
      potassio: potassio,
      analise: analise,
      cultura: calibracao.cultura,
      produtividadeEsperadaTha: calibracao.produtividadeEsperadaTha,
      tabelas: tabelas,
    );
    final criterioK = potassioResult.criterioResumo;
    final ncK = potassioResult.ncK;
    final doseK = potassioResult.doseK;

    final configAntagonismos = antagonismosTabela(tabelas);
    final antagonismos = PotassioFormula.calcularAntagonismos(
      kTotal: analise.k,
      ctc: analise.ctc,
      mgAtual: analise.mg,
      caAtual: analise.ca,
      limiteKCtc: configAntagonismos.limiteKCtc,
      limiteKMg: configAntagonismos.limiteKMg,
      limiteKCa: configAntagonismos.limiteKCa,
    );

    final microsCalculados =
        const CalcularMicronutrientesRecomendacaoUsecase().execute(
      microsConfig: micros,
      analise: analise,
      producaoEsperadaTha: calibracao.produtividadeEsperadaTha,
    );
    final microsResultado = microsCalculados.micros;
    final gruposResultado = microsCalculados.grupos;

    final relacaoCaMg = analise.mg > 0 ? analise.ca / analise.mg : 0.0;
    // Fórmula: CaO% × dose(t/ha) × 0.714(CaO→Ca) × (10/2) = cmolc/dm³ aportado
    // Simplificado: fator Ca = 0.0357 | fator Mg = 0.02479
    // Referência: Vale & Vitti (2015)
    final caAportado = (caO / 100) * doseCalcario * 0.714 * (10 / 2);
    final mgAportado = (mgO / 100) * doseCalcario * 0.603 * (10 / 2.43);
    final caEsperado = analise.ca + caAportado;
    final mgEsperado = analise.mg + mgAportado;
    final vEsperado =
        _vEsperado(caEsperado, mgEsperado, analise.k, analise.ctc);

    final avisos = <String>[
      if (legacyP) 'Fósforo acima do NC: aplicado piso de manutenção.',
      if (antagonismos.avisoKCTC)
        'K% na CTC acima de 7%. Risco de desequilíbrio.',
      if (antagonismos.avisoKMg) 'Relação K:Mg elevada. Monitorar antagonismo.',
      if (antagonismos.avisoKCa)
        'Relação K:Ca elevada. Avaliar parcelamento de K.',
      if (PotassioFormula.avisoSulco(
          modoAplicacao: _string(potassio['modoAplicacao'], 'Sulco'),
          doseK2O: doseK))
        'Dose de K₂O em sulco acima de 40 kg/ha.',
      ...resultadoGesso.observacoes.where((item) => item.contains('monitorar')),
    ];

    final argumentos =
        'A recomendação cruza a análise selecionada com as regras da calibração. '
        'Calcário foi calculado por $metodoCalagem com V% alvo de ${_fmt(vEsperado, 1)}. '
        'Fósforo foi calculado no modo $modoP com NC ${_fmt(ncP, 1)} mg/dm³ e FEP configurado. '
        'Potássio considerou o critério "$criterioK" e FEK da calibração. '
        'Micronutrientes foram gerados apenas para doses positivas e agrupados conforme os grupos ativos.';

    final parcelamento = doseCalcario > 4
        ? <String>[
            'Aplicação 1: 60% = ${_fmt(doseCalcario * 0.6, 2)} t/ha — ${_string(corretivos['mesAplicacao'], 'Setembro')}',
            'Aplicação 2: 40% = ${_fmt(doseCalcario * 0.4, 2)} t/ha — ${_mesSeguinte(_string(corretivos['mesAplicacao'], 'Setembro'))}',
          ]
        : <String>[];

    // T4 — Absorção / Exportação P e K (informativo, separado da dose solo)
    final prodTha = calibracao.produtividadeEsperadaTha;
    double? doseAbsorcaoP;
    double? doseAbsorcaoK;
    final doseAbsorcaoMicros = <String, double>{};
    if (prodTha != null && prodTha > 0) {
      // Fósforo
      final fTipoP = _string(fosforo['fosforoTipoFonte'], 'Autores');
      final fNomeP = _string(fosforo['fosforoFonteNome'], '');
      final fModoP = _string(fosforo['fosforoModoAbsorcao'], 'extracao');
      if (fNomeP.isNotEmpty) {
        final pKgT = _getAbsorcaoKgT(
            tipoFonte: fTipoP,
            fonteNome: fNomeP,
            modoAbsorcao: fModoP,
            nutriente: 'P');
        if (pKgT != null) {
          // P em kg/t × produtividade t/ha × fator P2O5 (2.29)
          doseAbsorcaoP = pKgT * prodTha * 2.29;
        }
      }
      // Potássio
      final fTipoK = _string(potassio['potassioTipoFonte'], 'Autores');
      final fNomeK = _string(potassio['potassioFonteNome'], '');
      final fModoK = _string(potassio['potassioModoAbsorcao'], 'extracao');
      if (fNomeK.isNotEmpty) {
        final kKgT = _getAbsorcaoKgT(
            tipoFonte: fTipoK,
            fonteNome: fNomeK,
            modoAbsorcao: fModoK,
            nutriente: 'K');
        if (kKgT != null) {
          // K em kg/t × produtividade t/ha × fator K2O (1.20)
          doseAbsorcaoK = kKgT * prodTha * 1.20;
        }
      }

      // Micronutrientes — extração cadastrada (informativo)
      for (final m in microsResultado) {
        if (m.extracao > 0) {
          doseAbsorcaoMicros[m.elemento] = m.extracao / 1000.0;
        }
      }
    }

    return ResultadoRecomendacao(
      analise: analise,
      calibracao: calibracao,
      base: base,
      labelAnalise: labelAnalise,
      geradaEm: DateTime.now(),
      metodoCalagem: metodoCalagem,
      doseCalcarioTHa: doseCalcario,
      vEsperado: vEsperado,
      caEsperado: caEsperado,
      mgEsperado: mgEsperado,
      relacaoCaMg: relacaoCaMg,
      parcelamento: parcelamento,
      gesso: resultadoGesso,
      modoFosforo: modoP,
      ncFosforo: ncP,
      doseP2O5KgHa: doseP,
      legacyP: legacyP,
      criterioPotassio: criterioK,
      ncPotassio: ncK,
      doseK2OKgHa: doseK,
      relacoesK: RelacoesK(
        relKMg: antagonismos.relKMg,
        relKCa: antagonismos.relKCa,
        alertas: [
          if (antagonismos.avisoKCTC) 'K% CTC elevado',
          if (antagonismos.avisoKMg) 'K:Mg crítico',
          if (antagonismos.avisoKCa) 'K:Ca crítico',
        ],
        kNaCTC: (analise.k / analise.ctc) * 100.0,
      ),
      micros: microsResultado,
      grupos: gruposResultado,
      doseAbsorcaoP: doseAbsorcaoP,
      doseAbsorcaoK: doseAbsorcaoK,
      avisos: avisos,
      argumentos: argumentos,
      citacoes: {
        'calagem':
            _string(corretivos['referencia'], '01 — Calagem: Motor de Cálculo'),
        'gesso':
            _string(corretivos['referencia'], '02 — Gesso: Motor de Cálculo'),
        'fosforo': _string(fosforo['referencia'], 'IAC Bol.100'),
        'potassio': _string(
            potassio['referencia'], '04 — Potássio (K): Motor de Cálculo'),
        'micros': _string(
            micros['referencia'], '06 — Micronutrientes: Motor de Cálculo'),
        ...doseAbsorcaoMicros.map(
          (simbolo, doseKgHa) =>
              MapEntry('doseAbsorcao_$simbolo', _fmt(doseKgHa, 4)),
        ),
      },
    );
  }

  // ── T4: Helper de Absorção bibliográfica ─────────────────────────────────
  /// Retorna o valor de absorção (kg/t) para um dado [nutriente] ('P', 'K',
  /// 'B', 'Cu', 'Fe', 'Mn', 'Zn') conforme a fonte bibliográfica selecionada.
  /// Macronutrientes (P, K) retornam kg/t; micros retornam g/t.
  /// Retorna null quando a fonte não é encontrada.
  double? _getAbsorcaoKgT({
    required String tipoFonte,
    required String fonteNome,
    required String modoAbsorcao,
    required String nutriente,
  }) {
    final sourceType = switch (tipoFonte) {
      'Guidorizzi' => 'Guidorizzi',
      'Cultivar' => 'Cultivar',
      _ => 'Autores',
    };
    final resolved = const AbsorcaoNutrientesResolver().resolve(
      sourceType: sourceType,
      sourceName: fonteNome,
      dataType: modoAbsorcao == 'exportacao' ? 'Exportação' : 'Extração',
      nutrient: nutriente,
    );
    return resolved.valuePerTon > 0 ? resolved.valuePerTon : null;
  }

  /// Despacha para o método de calcário correto conforme string do metodo.
  /// Lógica migrada de _doseCalcario da recomendacao_screen.dart — RE1.
  ///
  /// [metodo] começa com ①…⑦ ou com 'smp' (fallback para SMP).
  double calcularDoseCalcario({
    required String metodo,
    required AnaliseEntity analise,
    required double prnt,
    required double profundidade,
    required double sc,
    required Map<String, dynamic> corretivos,
    required Map<String, dynamic> albrecht,
    required double caO,
    required double mgO,
    required List<Map<String, dynamic>> tabelas,
  }) {
    // ① Saturação por Bases (V%)
    if (metodo.startsWith('①')) {
      final vAlvo = _num(corretivos['v2'], 70);
      return CalcarioFormula.metodoV(
        CalcarioInput(
          ctcPh7: analise.ctc,
          va: analise.vPercent,
          vd: vAlvo,
          prnt: prnt,
          profundidade: profundidade,
        ),
      ).ncToneladas;
    }
    // ② EMBRAPA (H+Al × fator)
    if (metodo.startsWith('②')) {
      return CalcarioFormula.metodoEmbrapa(
        hAl: analise.hAl,
        fator: _num(corretivos['fatorHAl'], 0.5),
        prnt: prnt,
        profundidadeCm: profundidade,
        sc: sc,
      );
    }
    // ③ Ca + Mg
    if (metodo.startsWith('③')) {
      return CalcarioFormula.metodoCaMg(
        caAtual: analise.ca,
        mgAtual: analise.mg,
        prnt: prnt,
        profundidadeCm: profundidade,
        sc: sc,
      );
    }
    // ④ Supercalagem (dose fixa)
    if (metodo.startsWith('④')) {
      return CalcarioFormula.metodoSupercalagem(
        doseFixa: _num(corretivos['doseFixa'], 1.5),
        prnt: prnt,
        profundidadeCm: profundidade,
        sc: sc,
      );
    }
    // ⑤ Albrecht (equilíbrio de bases)
    if (metodo.startsWith('⑤')) {
      final metas = metasAlbrechtTabela(tabelas);
      return CalcarioFormula.metodoAlbrecht(
        ctc: analise.ctc,
        caAtual: analise.ca,
        mgAtual: analise.mg,
        kAtual: analise.k,
        pctCaAlvo: _num(albrecht['caAlvo'], metas.pctCa),
        pctMgAlvo: _num(albrecht['mgAlvo'], metas.pctMg),
        pctKAlvo: _num(albrecht['kAlvo'], metas.pctK),
        caO: caO,
        prnt: prnt,
        pisoCaCmolc: _num(albrecht['ncCa'], 2.0),
        pisoMgCmolc: _num(albrecht['ncMg'], 0.8),
        pisoKCmolc: _num(albrecht['ncK'], 0.15),
        profundidadeCm: profundidade,
        sc: sc,
      );
    }
    // ⑥ Albrecht + Tampão Y
    if (metodo.startsWith('⑥')) {
      final metas = metasAlbrechtTabela(tabelas);
      final ncAlbrecht = CalcarioFormula.metodoAlbrecht(
        ctc: analise.ctc,
        caAtual: analise.ca,
        mgAtual: analise.mg,
        kAtual: analise.k,
        pctCaAlvo: _num(albrecht['caAlvo'], metas.pctCa),
        pctMgAlvo: _num(albrecht['mgAlvo'], metas.pctMg),
        pctKAlvo: _num(albrecht['kAlvo'], metas.pctK),
        caO: caO,
        prnt: 100.0,
        pisoCaCmolc: _num(albrecht['ncCa'], 2.0),
        pisoMgCmolc: _num(albrecht['ncMg'], 0.8),
        pisoKCmolc: _num(albrecht['ncK'], 0.15),
        profundidadeCm: 20,
        sc: 1.0,
      );
      final y = CalcarioFormula.calcularY(analise.argila);
      final ncBase = ncAlbrecht > y ? ncAlbrecht : y;
      return CalcarioFormula.aplicarCorrecoes(
        ncBase: ncBase,
        profundidadeCm: profundidade,
        prnt: prnt,
        sc: sc,
      ).doseFinal;
    }
    // ⑧ CA+CD — NC = CA + CD (fórmula única em CalcarioFormula).
    if (metodo.startsWith('⑧') || metodo.contains('CA+CD')) {
      return CalcarioFormula.metodoCaCd(
        al3: analise.al,
        ca2: analise.ca,
        mg2: analise.mg,
        ncCa: _num(corretivos['ncCa'], _num(albrecht['ncCa'], 2.0)),
        ncMg: _num(corretivos['ncMg'], _num(albrecht['ncMg'], 0.8)),
        argilaPercent: analise.argila,
        prem: analise.pRem,
        prnt: prnt,
        profundidadeCm: profundidade,
        sc: sc,
      );
    }
    // Fallback: SMP
    final ncBaseSmp = ncSmpTabela(phSmp: analise.ph, tabelas: tabelas);
    return CalcarioFormula.metodoSMP(
      phSmp: analise.ph,
      prnt: prnt,
      profundidadeCm: profundidade,
      sc: sc,
      overrideNcBase: ncBaseSmp > 0 ? ncBaseSmp : null,
    );
  }

  /// Despacha para o motor de gesso correto conforme string de metodo.
  /// Migração de _calcularGesso (RE2).
  ResultadoGesso calcularGesso({
    required String metodo,
    required AnaliseEntity analise,
    required DiagnosticoGesso diagnostico,
  }) {
    if (metodo.startsWith('②')) {
      return GessoEngine.metodo2Textura(
        argilaPercent: analise.argila,
        diagnostico: diagnostico,
      );
    }
    if (metodo.startsWith('③')) {
      return GessoEngine.metodo3VSubCTC(
        vaSub: analise.vPercent * 0.75,
        ctcSubMmolcDm3: analise.ctc * 0.7,
        diagnostico: diagnostico,
      );
    }
    if (metodo.startsWith('④')) {
      final ctcEfetiva = analise.ca + analise.mg + analise.k + analise.al;
      return GessoEngine.metodo4CTCeCa(
        GessoInput(
          ctcEfetiva: ctcEfetiva * 0.7,
          ca: analise.ca * 0.4,
          metodo: MetodoGesso.ctcEfetivaCaUepg.nome,
        ),
        diagnostico: diagnostico,
      );
    }
    return GessoEngine.metodo1Argila(
      argilaPercent: analise.argila,
      culturaPerena: false,
      diagnostico: diagnostico,
    );
  }

  /// Calcula a dose de fósforo por componentes independentes:
  /// correção do solo + uma reposição da planta (exportação ou extração).
  /// Lógica migrada de _calcularResultado (RE2).
  ({
    double ncP,
    double doseP,
    bool legacyP,
    String modoResumo,
    double doseCorrecao,
    double doseExportacao,
    double doseExtracao,
    double pSoloCreditadoP2O5,
  }) calcularFosforo({
    required Map<String, dynamic> fosforo,
    required AnaliseEntity analise,
    required String cultura,
    double? produtividadeEsperadaTha,
    required List<Map<String, dynamic>> tabelas,
  }) {
    final referenciaP = _string(fosforo['referencia'], 'IAC Bol.100');
    final corrigirSolo = _corrigirSoloFosforo(fosforo);
    final reposicao = _reposicaoFosforo(fosforo);

    // Nível Crítico de Fósforo (Dinâmico)
    final ncP = ncFosforoPorReferencia(
      referencia: referenciaP,
      argilaPercent: analise.argila,
      tabelas: tabelas,
      fallback: _num(
        fosforo['nc'],
        ncFosforoResina(argilaPercent: analise.argila, tabelas: tabelas),
      ),
    );

    final fepCorrecao = _fepCorrecaoFosforo(
      fosforo,
      argilaPercent: analise.argila,
      tabelas: tabelas,
    );
    final eficienciaSolo = _eficienciaSoloReposicao(fosforo);

    final exportacaoP2O5 = _p2O5PorAbsorcao(
          fosforo: fosforo,
          modoAbsorcao: 'exportacao',
          produtividadeEsperadaTha: produtividadeEsperadaTha,
        ) ??
        _exportacaoP2O5(cultura);
    final extracaoP2O5 = _p2O5PorAbsorcao(
          fosforo: fosforo,
          modoAbsorcao: 'extracao',
          produtividadeEsperadaTha: produtividadeEsperadaTha,
        ) ??
        _extracaoP2O5(cultura);

    final resultado = FosforoFormula.recomendacaoComponentes(
      corrigirSolo: corrigirSolo,
      reposicao: reposicao,
      correcaoInput: FosforoInput(
        pAtual: analise.p,
        nc: ncP,
        argila: analise.argila,
        referencia: referenciaP,
      ),
      pSolo: analise.p,
      percentualUsoSoloExtracao: _num(fosforo['percentualUsoPSolo'], 100),
      profundidadeCm: 20,
      exportacaoP2O5: exportacaoP2O5,
      extracaoP2O5: extracaoP2O5,
      eficienciaSoloPercent: eficienciaSolo,
      fepCorrecao: fepCorrecao,
    );
    var doseP = resultado.doseTotal;
    final legacyInfo = FosforoFormula.avaliarLegacyP(
      pSolo: analise.p,
      nivelCritico: ncP,
      exportacaoGrao: exportacaoP2O5,
    );
    if (reposicao == ReposicaoFosforo.nenhuma &&
        legacyInfo.legacyP &&
        doseP < legacyInfo.doseMinima) {
      doseP = legacyInfo.doseMinima;
    }

    return (
      ncP: ncP,
      doseP: doseP,
      legacyP: reposicao == ReposicaoFosforo.nenhuma && legacyInfo.legacyP,
      modoResumo: resultado.modoResumo,
      doseCorrecao: resultado.doseCorrecao,
      doseExportacao: resultado.doseExportacao,
      doseExtracao: resultado.doseExtracao,
      pSoloCreditadoP2O5: resultado.pSoloCreditadoP2O5,
    );
  }

  bool _corrigirSoloFosforo(Map<String, dynamic> fosforo) {
    final explicit = fosforo['corrigirSolo'];
    if (explicit is bool) return explicit;
    final modo = _string(fosforo['modoCalculo'], '① Correção do solo');
    return modo.contains('Correção');
  }

  ReposicaoFosforo _reposicaoFosforo(Map<String, dynamic> fosforo) {
    final explicit = _string(fosforo['reposicaoFosforo'], '');
    if (explicit == 'exportacao') return ReposicaoFosforo.exportacao;
    if (explicit == 'extracao') return ReposicaoFosforo.extracao;
    if (explicit == 'nenhuma') return ReposicaoFosforo.nenhuma;

    final modo = _string(fosforo['modoCalculo'], '');
    if (modo.contains('Manutenção') || modo.contains('Exportação')) {
      return ReposicaoFosforo.exportacao;
    }
    if (modo.contains('Extração')) return ReposicaoFosforo.extracao;
    return ReposicaoFosforo.nenhuma;
  }

  ({
    double ncK,
    double doseK,
    String modoResumo,
    String criterioResumo,
    double doseCorrecao,
    double doseReposicao,
  }) calcularPotassio({
    required Map<String, dynamic> potassio,
    required AnaliseEntity analise,
    required String cultura,
    double? produtividadeEsperadaTha,
    required List<Map<String, dynamic>> tabelas,
  }) {
    final corrigirSolo = _corrigirSoloPotassio(potassio);
    final reposicao = _reposicaoPotassio(potassio);
    final metodoCorrecao = _metodoCorrecaoPotassio(potassio);
    final isAlgodao = cultura.toLowerCase().contains('algod');
    final ncTeor = _num(
      potassio['ncTeor'],
      ncPotassioTeorTabela(argilaPercent: analise.argila, tabelas: tabelas),
    );
    final percentualKObjetivo = _num(
      potassio['percentualKObjetivoCtc'] ?? potassio['ncPctCtc'],
      isAlgodao ? 5.0 : 4.0,
    );
    final ajusteEficiencia = _eficienciaSoloPotassio(potassio);

    final exportacaoK2O = _num(potassio['indiceExportacaoK2O'], 0) > 0
        ? _num(potassio['indiceExportacaoK2O'], 0) *
            (produtividadeEsperadaTha ?? 0)
        : (_k2OPorAbsorcao(
              potassio: potassio,
              modoAbsorcao: 'exportacao',
              produtividadeEsperadaTha: produtividadeEsperadaTha,
            ) ??
            _exportacaoK2O(cultura));

    final extracaoK2O = _num(potassio['indiceExtracaoK2O'], 0) > 0
        ? _num(potassio['indiceExtracaoK2O'], 0) *
            (produtividadeEsperadaTha ?? 0)
        : (_k2OPorAbsorcao(
              potassio: potassio,
              modoAbsorcao: 'extracao',
              produtividadeEsperadaTha: produtividadeEsperadaTha,
            ) ??
            _extracaoK2O(cultura));

    final profundidadeCm = _profundidadePotassioCm(potassio);

    final resultado = PotassioFormula.recomendacaoComponentes(
      corrigirSolo: corrigirSolo,
      metodoCorrecao: metodoCorrecao,
      reposicao: reposicao,
      ctc: analise.ctc,
      kAtualCmolc: analise.k,
      kAtualMgDm3: analise.k * Conversoes.kMgDm3Factor,
      argilaPercent: analise.argila,
      ncTeorMgDm3: ncTeor,
      percentualKObjetivoCtc: percentualKObjetivo,
      cultura: cultura,
      percentualUsoKSolo: _num(
        potassio['percentualKSoloConsiderado'] ??
            potassio['percentualUsoKSolo'],
        100,
      ),
      exportacaoK2O: exportacaoK2O,
      extracaoK2O: extracaoK2O,
      ajusteEficienciaSolo: ajusteEficiencia,
      profundidadeCm: profundidadeCm,
      producaoEsperadaTha: produtividadeEsperadaTha ?? 0,
    );

    final criterioResumo =
        metodoCorrecao == MetodoCorrecaoPotassio.percentualKCtc
            ? '% K na CTC'
            : 'Teor absoluto';

    return (
      ncK: resultado.ncResumo,
      doseK: resultado.doseTotal,
      modoResumo: resultado.modoResumo,
      criterioResumo: criterioResumo,
      doseCorrecao: resultado.doseCorrecao,
      doseReposicao: resultado.doseReposicaoAjustada,
    );
  }

  bool _corrigirSoloPotassio(Map<String, dynamic> potassio) {
    final explicit = potassio['corrigirSolo'];
    if (explicit is bool) return explicit;
    final modo = _string(potassio['modoCalculo'], 'Correção do solo');
    if (modo.contains('Manutenção') ||
        modo.contains('Exportação') ||
        modo.contains('Extração')) {
      return false;
    }
    return modo.contains('Correção') || modo.startsWith('①');
  }

  ReposicaoPotassio _reposicaoPotassio(Map<String, dynamic> potassio) {
    final explicit = _string(
      potassio['reposicaoPotassio'] ?? potassio['reposicaoKalium'],
      '',
    );
    if (explicit == 'exportacao') return ReposicaoPotassio.exportacao;
    if (explicit == 'extracao') return ReposicaoPotassio.extracao;
    if (explicit == 'nenhuma') return ReposicaoPotassio.nenhuma;

    final modo = _string(potassio['modoCalculo'], '');
    if (modo.contains('Manutenção') || modo.contains('Exportação')) {
      return ReposicaoPotassio.exportacao;
    }
    if (modo.contains('Extração')) return ReposicaoPotassio.extracao;
    return ReposicaoPotassio.nenhuma;
  }

  MetodoCorrecaoPotassio _metodoCorrecaoPotassio(
    Map<String, dynamic> potassio,
  ) {
    final explicit = _string(potassio['metodoCorrecao'], '');
    if (explicit == 'percentual_k_ctc') {
      return MetodoCorrecaoPotassio.percentualKCtc;
    }
    if (explicit == 'nivel_critico') {
      return MetodoCorrecaoPotassio.nivelCritico;
    }

    final criterio = _string(potassio['criterioNc'], 'Teor absoluto');
    if (criterio == '% K na CTC') {
      return MetodoCorrecaoPotassio.percentualKCtc;
    }
    return MetodoCorrecaoPotassio.nivelCritico;
  }

  int _profundidadePotassioCm(Map<String, dynamic> potassio) {
    final camada = _string(potassio['camada'], '0-20');
    final match = RegExp(r'(\d+)\s*-\s*(\d+)').firstMatch(camada);
    if (match != null) {
      final fim = int.tryParse(match.group(2) ?? '');
      if (fim != null && fim > 0) return fim;
    }
    return 20;
  }

  double _eficienciaSoloPotassio(Map<String, dynamic> potassio) {
    if (potassio.containsKey('ajusteEficienciaSolo') &&
        potassio['ajusteEficienciaSolo'] != null) {
      return _num(potassio['ajusteEficienciaSolo'], 15.0).clamp(0.0, 100.0);
    }
    if (potassio.containsKey('eficienciaSolo') &&
        potassio['eficienciaSolo'] != null) {
      return _num(potassio['eficienciaSolo'], 15.0).clamp(0.0, 100.0);
    }
    if (potassio.containsKey('fekBase') && potassio['fekBase'] != null) {
      return _num(potassio['fekBase'], 15.0).clamp(0.0, 100.0);
    }
    return 15.0;
  }

  double? _k2OPorAbsorcao({
    required Map<String, dynamic> potassio,
    required String modoAbsorcao,
    required double? produtividadeEsperadaTha,
  }) {
    final prodTha = produtividadeEsperadaTha;
    if (prodTha == null || prodTha <= 0) return null;
    final tipoFonte = _string(potassio['potassioTipoFonte'], 'Autores');
    final fonteNome = _string(potassio['potassioFonteNome'], '');
    if (fonteNome.isEmpty) return null;
    final kKgT = _getAbsorcaoKgT(
      tipoFonte: tipoFonte,
      fonteNome: fonteNome,
      modoAbsorcao: modoAbsorcao,
      nutriente: 'K',
    );
    if (kKgT == null) return null;
    return kKgT * prodTha * 1.205;
  }

  double? _p2O5PorAbsorcao({
    required Map<String, dynamic> fosforo,
    required String modoAbsorcao,
    required double? produtividadeEsperadaTha,
  }) {
    final prodTha = produtividadeEsperadaTha;
    if (prodTha == null || prodTha <= 0) return null;
    final tipoFonte = _string(fosforo['fosforoTipoFonte'], 'Autores');
    final fonteNome = _string(fosforo['fosforoFonteNome'], '');
    if (fonteNome.isEmpty) return null;
    final pKgT = _getAbsorcaoKgT(
      tipoFonte: tipoFonte,
      fonteNome: fonteNome,
      modoAbsorcao: modoAbsorcao,
      nutriente: 'P',
    );
    if (pKgT == null) return null;
    return pKgT * prodTha * 2.29;
  }

  /// Calcula doses de micronutrientes a partir da calibração cadastrada.
  List<MicroResultado> calcularMicros({
    required Map<String, dynamic> micros,
    required AnaliseEntity analise,
    double? producaoEsperadaTha,
    List<String>? gruposIdsSelecionados,
  }) {
    return const CalcularMicronutrientesRecomendacaoUsecase()
        .execute(
          microsConfig: micros,
          analise: analise,
          producaoEsperadaTha: producaoEsperadaTha,
          gruposIdsSelecionados: gruposIdsSelecionados,
        )
        .micros;
  }

  /// Agrupa micronutrientes em grupos de aplicação.
  List<GrupoResultado> calcularGrupos({
    required List<Map<String, dynamic>> grupos,
    required List<MicroResultado> micros,
    required Map<String, dynamic> microsConfig,
    required AnaliseEntity analise,
    double? producaoEsperadaTha,
  }) {
    return const CalcularMicronutrientesRecomendacaoUsecase()
        .execute(
          microsConfig: microsConfig,
          analise: analise,
          producaoEsperadaTha: producaoEsperadaTha,
        )
        .grupos;
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}

String _fmt(double value, [int decimals = 2]) {
  final text = value.toStringAsFixed(decimals);
  return text.replaceAll('.', ',');
}

bool _bool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

// V% calculado a partir dos novos teores estimados pós-calcário
// caDepois e mgDepois já calculados na CORREÇÃO 3
// kAtual = analise.k (sem alteração pelo calcário)
// ctc = analise.ctc (campo já existente na AnaliseEntity)
double _vEsperado(double caDepois, double mgDepois, double kAtual, double ctc) {
  if (ctc <= 0) return 0;
  return ((caDepois + mgDepois + kAtual) / ctc) * 100;
}

double _profundidade(Map<String, dynamic> corretivos) {
  final metodo = _string(corretivos['metodoIncorporacao'], 'Sem incorporação');
  if (metodo.contains('Grade')) {
    final diametro = _num(corretivos['diametroGradePol'], 32);
    final folga = _num(corretivos['folgaMancal'], 25);
    final raio = diametro * 2.54 / 2;
    return (raio - folga / 2).clamp(0, 40);
  }
  return _num(corretivos['profundidadeManual'], 20);
}

double _mSubEstimado(AnaliseEntity analise) {
  final t = analise.ca + analise.mg + analise.k + analise.al;
  if (t <= 0) return 0;
  return (analise.al / t) * 100;
}

double _exportacaoK2O(String cultura) {
  final c = cultura.toLowerCase();
  if (c.contains('milho')) return 50;
  if (c.contains('algod')) return 80;
  if (c.contains('feij')) return 45;
  return 90;
}

double _extracaoK2O(String cultura) {
  final c = cultura.toLowerCase();
  if (c.contains('milho')) return 120;
  if (c.contains('algod')) return 150;
  if (c.contains('feij')) return 100;
  return 110;
}

String _mesSeguinte(String mes) {
  const meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];
  final index = meses.indexOf(mes);
  if (index == -1) return meses.first;
  return meses[(index + 1) % 12];
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers privados do arquivo (não exportados)
// ─────────────────────────────────────────────────────────────────────────────

/// Converte [value] para double, aceitando num, String ou null.
/// Retorna [fallback] quando a conversão falha.
/// Migrado de _num da recomendacao_screen.dart.
double _num(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value.replaceAll(',', '.')) ?? fallback;
  }
  return fallback;
}

/// Fallback para quando o valor num mapa pode ser vazio
String _string(dynamic value, String fallback) {
  final text = value?.toString() ?? '';
  if (text.isEmpty) return fallback;
  return text;
}

/// Extração P2O5 baseado no nome da cultura
double _extracaoP2O5(String cultura) {
  final c = cultura.toLowerCase();
  if (c.contains('milho')) return 110.0;
  if (c.contains('algod')) return 130.0;
  if (c.contains('feij')) return 90.0;
  return 100.0;
}

/// Exportação P2O5 baseado no nome da cultura.
double _exportacaoP2O5(String cultura) {
  final c = cultura.toLowerCase();
  if (c.contains('milho')) return 60.0;
  if (c.contains('algod')) return 60.0;
  if (c.contains('feij')) return 30.0;
  return 70.0;
}

const String _kFosforoNcResina = 'fosforo_nc_resina';
const String _kFosforoNcCerrado = 'fosforo_nc_cerrado';
const String _kFosforoNcRsSc = 'fosforo_nc_rssc';
const String _kFosforoNcUfla = 'fosforo_nc_ufla';
const String _kFosforoFep = 'fosforo_fep';
const String _kPotassioNcTeor = 'potassio_nc_teor';
const String _kPotassioFek = 'potassio_fek';
const String _kPotassioAntagonismos = 'potassio_antagonismos';
const String _kCalagemMetasAlbrecht = 'calagem_metas_albrecht';
const String _kCalagemSmp = 'calagem_smp';

Map<String, dynamic>? _tabelaPorChave(
  List<Map<String, dynamic>> tabelas,
  String chave,
) {
  for (final tabela in tabelas) {
    if (_string(tabela['chave'], '') == chave) {
      return tabela;
    }
  }
  return null;
}

List<Map<String, dynamic>> _linhasTabela(Map<String, dynamic>? tabela) {
  final linhasRaw = tabela?['linhas'];
  if (linhasRaw is! List) return const [];
  return linhasRaw
      .whereType<Map>()
      .map((linha) => linha.map((k, v) => MapEntry(k.toString(), v)))
      .toList(growable: false);
}

double _valorTabelaPorArgila(
  List<Map<String, dynamic>> tabelas, {
  required String chave,
  required double argilaPercent,
  required double fallback,
}) {
  final tabela = _tabelaPorChave(tabelas, chave);
  if (tabela == null) {
    return _valorPadraoPorArgila(
      chave: chave,
      argilaPercent: argilaPercent,
      fallback: fallback,
    );
  }
  final linhas = _linhasTabela(tabela);
  if (linhas.isEmpty) {
    return _valorPadraoPorArgila(
      chave: chave,
      argilaPercent: argilaPercent,
      fallback: fallback,
    );
  }
  for (final linha in linhas) {
    final min = _num(linha['argilaMin'], double.negativeInfinity);
    final max = _num(linha['argilaMax'], double.infinity);
    if (argilaPercent >= min && argilaPercent < max) {
      return _num(linha['valor'], fallback);
    }
  }
  if (linhas.isNotEmpty) {
    return _num(linhas.last['valor'], fallback);
  }
  return fallback;
}

double _valorPadraoPorArgila({
  required String chave,
  required double argilaPercent,
  required double fallback,
}) {
  if (chave == _kFosforoNcResina) {
    if (argilaPercent < 15) return 12.0;
    if (argilaPercent < 35) return 20.0;
    if (argilaPercent < 60) return 30.0;
    return 40.0;
  }
  if (chave == _kFosforoNcCerrado) {
    if (argilaPercent < 10) return 15.0;
    if (argilaPercent < 20) return 15.0;
    if (argilaPercent < 40) return 8.0;
    if (argilaPercent < 60) return 4.0;
    return 3.0;
  }
  if (chave == _kFosforoNcRsSc) {
    if (argilaPercent < 10) return 21.0;
    if (argilaPercent < 20) return 18.0;
    if (argilaPercent < 40) return 12.0;
    if (argilaPercent < 60) return 9.0;
    return 6.0;
  }
  if (chave == _kFosforoNcUfla) {
    if (argilaPercent < 10) return 20.0;
    if (argilaPercent < 20) return 16.0;
    if (argilaPercent < 40) return 10.0;
    if (argilaPercent < 60) return 6.0;
    return 4.0;
  }
  if (chave == _kFosforoFep) {
    if (argilaPercent < 15) return 30.0;
    if (argilaPercent < 35) return 20.0;
    if (argilaPercent < 60) return 15.0;
    return 10.0;
  }
  if (chave == _kPotassioNcTeor) {
    if (argilaPercent < 15) return 40.0;
    if (argilaPercent < 35) return 60.0;
    if (argilaPercent < 60) return 80.0;
    return 100.0;
  }
  if (chave == _kPotassioFek) {
    if (argilaPercent < 15) return 50.0;
    if (argilaPercent < 35) return 60.0;
    if (argilaPercent < 60) return 65.0;
    return 70.0;
  }
  return fallback;
}

double ncFosforoPorReferencia({
  required String referencia,
  required double argilaPercent,
  required List<Map<String, dynamic>> tabelas,
  double fallback = 8.0,
}) {
  String? chave;
  switch (referencia) {
    case 'IAC Bol.100':
      chave = _kFosforoNcResina;
      break;
    case 'Embrapa Cerrado':
      chave = _kFosforoNcCerrado;
      break;
    case 'Embrapa RS/SC':
      chave = _kFosforoNcRsSc;
      break;
    case 'UFLA / CFSEMG':
      chave = _kFosforoNcUfla;
      break;
    default:
      return fallback;
  }
  return _valorTabelaPorArgila(
    tabelas,
    chave: chave,
    argilaPercent: argilaPercent,
    fallback: fallback,
  );
}

double ncFosforoResina({
  required double argilaPercent,
  required List<Map<String, dynamic>> tabelas,
}) {
  return _valorTabelaPorArgila(
    tabelas,
    chave: _kFosforoNcResina,
    argilaPercent: argilaPercent,
    fallback: 30.0,
  );
}

double fepBaseTabela({
  required double argilaPercent,
  required List<Map<String, dynamic>> tabelas,
}) {
  return _valorTabelaPorArgila(
    tabelas,
    chave: _kFosforoFep,
    argilaPercent: argilaPercent,
    fallback: 15.0,
  );
}

double _fepCorrecaoFosforo(
  Map<String, dynamic> fosforo, {
  required double argilaPercent,
  required List<Map<String, dynamic>> tabelas,
}) {
  if (fosforo.containsKey('fepBase') && fosforo['fepBase'] != null) {
    return _num(fosforo['fepBase'], 15.0).clamp(0.0, 100.0);
  }
  return fepBaseTabela(
    argilaPercent: argilaPercent,
    tabelas: tabelas,
  ).clamp(0.0, 100.0);
}

double _eficienciaSoloReposicao(Map<String, dynamic> fosforo) {
  if (fosforo.containsKey('eficienciaSolo') &&
      fosforo['eficienciaSolo'] != null) {
    return _num(fosforo['eficienciaSolo'], 0.0).clamp(0.0, 100.0);
  }
  return 0.0;
}

double ncPotassioTeorTabela({
  required double argilaPercent,
  required List<Map<String, dynamic>> tabelas,
}) {
  return _valorTabelaPorArgila(
    tabelas,
    chave: _kPotassioNcTeor,
    argilaPercent: argilaPercent,
    fallback: 80.0,
  );
}

double fekBaseTabela({
  required double argilaPercent,
  required List<Map<String, dynamic>> tabelas,
}) {
  return _valorTabelaPorArgila(
    tabelas,
    chave: _kPotassioFek,
    argilaPercent: argilaPercent,
    fallback: 65.0,
  );
}

({double limiteKCtc, double limiteKMg, double limiteKCa}) antagonismosTabela(
    List<Map<String, dynamic>> tabelas) {
  final linhas =
      _linhasTabela(_tabelaPorChave(tabelas, _kPotassioAntagonismos));

  double buscar(String chaveValor, double fallback) {
    for (final linha in linhas) {
      if (_string(linha['chaveValor'], '') == chaveValor) {
        return _num(linha['valor'], fallback);
      }
    }
    return fallback;
  }

  return (
    limiteKCtc: buscar('limite_k_ctc', 7.0),
    limiteKMg: buscar('limite_k_mg', 1.0),
    limiteKCa: buscar('limite_k_ca', 0.4),
  );
}

({double pctCa, double pctMg, double pctK}) metasAlbrechtTabela(
    List<Map<String, dynamic>> tabelas) {
  final linhas =
      _linhasTabela(_tabelaPorChave(tabelas, _kCalagemMetasAlbrecht));

  double buscar(String chaveValor, double fallback) {
    for (final linha in linhas) {
      if (_string(linha['chaveValor'], '') == chaveValor) {
        return _num(linha['valor'], fallback);
      }
    }
    return fallback;
  }

  return (
    pctCa: buscar('pct_ca', 65.0),
    pctMg: buscar('pct_mg', 15.0),
    pctK: buscar('pct_k', 4.0),
  );
}

double ncSmpTabela({
  required double phSmp,
  required List<Map<String, dynamic>> tabelas,
}) {
  final linhas = _linhasTabela(_tabelaPorChave(tabelas, _kCalagemSmp));
  if (linhas.isEmpty) {
    return _ncSmpPadrao(phSmp);
  }
  for (final linha in linhas) {
    final min = _num(linha['phMin'], 0.0);
    final max = _num(linha['phMax'], 9.9);
    if (phSmp >= min && phSmp < max) {
      return _num(linha['valor'], 0.0);
    }
  }
  return 0.0;
}

double _ncSmpPadrao(double phSmp) {
  if (phSmp < 4.5) return 15.0;
  if (phSmp < 5.0) return 10.0;
  if (phSmp < 5.5) return 5.0;
  if (phSmp < 6.0) return 2.5;
  return 0.0;
}
