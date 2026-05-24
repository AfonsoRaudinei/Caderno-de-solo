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
import 'package:soloforte/domain/formulas/fosforo_formula.dart';
import 'package:soloforte/domain/formulas/gesso_engine.dart';
import 'package:soloforte/domain/formulas/potassio_formula.dart';
import 'package:soloforte/domain/formulas/types/calcario_input.dart';
import 'package:soloforte/domain/formulas/types/fosforo_input.dart';
import 'package:soloforte/domain/formulas/types/gesso_input.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';
import 'package:soloforte/data/culturas_data.dart';

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
      tabelas: tabelas,
    );
    final ncP = fosforoResult.ncP;
    final doseP = fosforoResult.doseP;
    final legacyP = fosforoResult.legacyP;
    final modoP = _string(fosforo['modoCalculo'], '① Correção do solo');

    final modoK = _string(potassio['modoCalculo'], '① Correção do solo');
    final criterioK = _string(potassio['criterioNc'], 'Ambos — usar o maior');
    final ncK = criterioK == '% K na CTC'
        ? _num(potassio['ncPctCtc'], 4)
        : _num(
            potassio['ncTeor'],
            ncPotassioTeorTabela(
                argilaPercent: analise.argila, tabelas: tabelas));

    final doseK = modoK.startsWith('①')
        ? PotassioFormula.recomendacao(
            ctc: analise.ctc,
            kAtual: analise.k,
            participacaoDesejada: _num(potassio['ncPctCtc'],
                calibracao.cultura.toLowerCase().contains('algod') ? 5 : 4),
            cultura: calibracao.cultura,
            usarCriterioTeorAbsoluto: criterioK != '% K na CTC',
            kAtualMgDm3: analise.k * 391.0,
            argilaPercent: analise.argila,
            percentualCorrecaoTeor: _num(potassio['percentualCorrecao'], 100),
          )
        : PotassioFormula.recomendacaoExtracao(
            kSolo: analise.k,
            percentualUsoSolo: _num(potassio['percentualUsoKSolo'], 0),
            extracaoK2O: _extracaoK2O(calibracao.cultura),
            fek: _num(potassio['fekBase'],
                fekBaseTabela(argilaPercent: analise.argila, tabelas: tabelas)),
          );

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

    final microsResultado = calcularMicros(micros: micros, analise: analise);
    final gruposMicros = _asListMap(micros['grupos']);
    final gruposResultado = calcularGrupos(
        grupos: gruposMicros, micros: microsResultado);

    final relacaoCaMg = analise.mg > 0 ? analise.ca / analise.mg : 0.0;
    // Fórmula: CaO% × dose(t/ha) × 0.714(CaO→Ca) × (10/2) = cmolc/dm³ aportado
    // Simplificado: fator Ca = 0.0357 | fator Mg = 0.02479
    // Referência: Vale & Vitti (2015)
    final caAportado = (caO / 100) * doseCalcario * 0.714 * (10 / 2);
    final mgAportado = (mgO / 100) * doseCalcario * 0.603 * (10 / 2.43);
    final caEsperado = analise.ca + caAportado;
    final mgEsperado = analise.mg + mgAportado;
    final vEsperado = _vEsperado(caEsperado, mgEsperado, analise.k, analise.ctc);

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

      // Micronutrientes por grupo (informativo; não soma na dose solo)
      for (final grupo in gruposMicros) {
        final gMap = _asMap(grupo);
        final tipoFonte = _string(gMap['microGrupoTipoFonte'], '');
        final fonteNome = _string(gMap['microGrupoFonteNome'], '');
        final elementosGrupo = (gMap['elementos'] as List?)
                ?.map((e) => e.toString())
                .toList(growable: false) ??
            const <String>[];
        if (tipoFonte.isEmpty || fonteNome.isEmpty) continue;
        for (final simbolo in elementosGrupo) {
          final absValor = _getAbsorcaoKgT(
            tipoFonte: tipoFonte,
            fonteNome: fonteNome,
            modoAbsorcao: 'extracao',
            nutriente: simbolo,
          );
          if (absValor == null) continue;
          final doseGrupoKgHa = (absValor / 1000) * prodTha;
          doseAbsorcaoMicros[simbolo] =
              (doseAbsorcaoMicros[simbolo] ?? 0) + doseGrupoKgHa;
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
      'Guidorizzi' => SourceType.tecnologia,
      'Cultivar' => SourceType.cultivar,
      _ => SourceType.autor,
    };
    final dataset = datasetFor(sourceType);
    final entry = dataset[fonteNome];
    if (entry == null) return null;
    final record =
        modoAbsorcao == 'exportacao' ? entry.exportacao : entry.extracao;
    return switch (nutriente) {
      'P' => record.P,
      'K' => record.K,
      'B' => record.B,
      'Cu' => record.Cu,
      'Fe' => record.Fe,
      'Mn' => record.Mn,
      'Zn' => record.Zn,
      _ => null,
    };
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

  /// Calcula a dose de fósforo conforme as calibrações de correção ou manutenção (extrativa).
  /// Lógica migrada de _calcularResultado (RE2).
  ({double ncP, double doseP, bool legacyP}) calcularFosforo({
    required Map<String, dynamic> fosforo,
    required AnaliseEntity analise,
    required String cultura,
    required List<Map<String, dynamic>> tabelas,
  }) {
    final modoP = _string(fosforo['modoCalculo'], '① Correção do solo');
    final referenciaP = _string(fosforo['referencia'], 'IAC Bol.100');

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

    // FEP e Fator Solo (Dinâmicos)
    final fepBaseLocal = _num(fosforo['fepBase'],
        fepBaseTabela(argilaPercent: analise.argila, tabelas: tabelas));

    var doseP = modoP.startsWith('①')
        ? FosforoFormula.recomendacaoCorrecao(
            FosforoInput(
              pAtual: analise.p,
              nc: ncP,
              argila: analise.argila,
              referencia: referenciaP,
            ),
          ).doseRecomendada
        : FosforoFormula.recomendacaoExtracao(
            pSolo: analise.p,
            percentualUsoSolo: _num(fosforo['percentualUsoPSolo'], 0),
            profundidadeCm: 20,
            extracaoP2O5: _extracaoP2O5(cultura),
            fepFinal: fepBaseLocal,
          );
    final legacyInfo = FosforoFormula.avaliarLegacyP(
      pSolo: analise.p,
      nivelCritico: ncP,
      exportacaoGrao: _extracaoP2O5(cultura),
    );
    if (legacyInfo.legacyP && doseP < legacyInfo.doseMinima) {
      doseP = legacyInfo.doseMinima;
    }

    return (ncP: ncP, doseP: doseP, legacyP: legacyInfo.legacyP);
  }

  /// Calcula doses de micronutrientes elemento a elemento.
  /// Migração de _calcularMicros (RE3).
  List<MicroResultado> calcularMicros({
    required Map<String, dynamic> micros,
    required AnaliseEntity analise,
  }) {
    final elementos = _asMap(micros['elementos']);
    final resultados = <MicroResultado>[];
    for (final entry in elementos.entries) {
      final simbolo = entry.key;
      final config = _asMap(entry.value);
      final via = _string(config['viaAplicacao'], 'Solo (correção)');

      final teor = via.contains('Solo')
          ? _num(config['teorFonteSolo'], 0)
          : _num(config['teorFonteFoliar'], 0);

      final eficiencia = via.contains('Solo')
          ? _num(config['eficienciaSolo'], 0)
          : _num(config['eficienciaFoliar'], 0);

      final nc = _num(config['ncSolo']);
      final valorAtual = _valorMicroAnalise(simbolo, analise);

      final doseElemento = via.contains('Solo')
          ? ((nc - valorAtual).clamp(0, double.infinity) *
              200 *
              (_num(config['percentualCorrecaoSolo'], 100) / 100))
          : _num(config['doseElementoFoliar'], 0);

      if (doseElemento <= 0) continue;

      final doseProdutoCalc = (teor > 0 && eficiencia > 0)
          ? doseElemento / (teor / 100) / (eficiencia / 100)
          : 0.0;

      final doseProdutoLabelText = doseProdutoCalc >= 1000
          ? '${_fmt(doseProdutoCalc / 1000, 2)} kg/ha produto'
          : '${_fmt(doseProdutoCalc, 1)} g/ha produto';

      resultados.add(
        MicroResultado(
          elemento: simbolo,
          valorAtual: valorAtual,
          nc: nc,
          dose: doseElemento,
          unidade: 'g/ha',
          deficiente: valorAtual < nc,
          via: via,
          fonte: via.contains('Solo')
              ? _string(config['fonteSolo'], 'Fonte solo')
              : _string(config['fonteFoliar'], 'Fonte foliar'),
          doseProduto: doseProdutoCalc,
          doseProdutoLabel: doseProdutoLabelText,
        ),
      );
    }
    return resultados;
  }

  /// Agrupa micronutrientes em grupos de aplicação.
  /// Migração de _calcularGrupos (RE3).
  List<GrupoResultado> calcularGrupos({
    required List<Map<String, dynamic>> grupos,
    required List<MicroResultado> micros,
  }) {
    final resultados = <GrupoResultado>[];
    for (final grupo in grupos) {
      final elementosGrupo = List<String>.from(
          (grupo['elementos'] as List?)?.map((e) => e.toString()) ?? const []);

      final microsGrupo = micros
          .where((item) => elementosGrupo.contains(item.elemento))
          .toList();
      if (microsGrupo.isEmpty) continue;

      final doseProdutoKg =
          microsGrupo.fold<double>(0, (sum, item) => sum + item.doseProduto) /
              1000;

      final fornecimento = microsGrupo
          .map((item) => '${item.elemento} ${_fmt(item.dose, 1)}g/ha')
          .join(' · ');

      resultados.add(
        GrupoResultado(
          nomeGrupo: _string(grupo['nome'], 'Grupo'),
          micros: microsGrupo,
          via: _string(grupo['via'], 'Foliar'),
          produto: _string(grupo['produto'], 'Mistura manual'),
          doseProdutoKgLabel: '${_fmt(doseProdutoKg, 2)} kg/ha',
          fornecimento: fornecimento,
        ),
      );
    }
    return resultados;
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}

double _valorMicroAnalise(String simbolo, AnaliseEntity analise) {
  switch (simbolo) {
    case 'B':
      return analise.b;
    case 'Cu':
      return analise.cu;
    case 'Fe':
      return analise.fe;
    case 'Mn':
      return analise.mn;
    case 'Zn':
      return analise.zn;
    default:
      return 0;
  }
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

List<Map<String, dynamic>> _asListMap(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((entry) => entry.map((key, val) => MapEntry(key.toString(), val)))
        .toList();
  }
  return <Map<String, dynamic>>[];
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
