import 'package:soloforte/domain/entities/analise_completa.dart';
import 'package:soloforte/domain/entities/analise_entity.dart';
import 'package:soloforte/domain/guards/limites_agronomicos.dart';
import 'package:soloforte/domain/models/diagnostico_recomendacao.dart';
import 'package:soloforte/domain/utils/unidade_converter.dart';
import 'package:soloforte/domain/value_objects/valor_nutriente.dart';

enum RecommendationModule {
  calagem,
  fosforo,
  potassio,
  gesso,
}

class AnaliseRecomendacaoInput {
  const AnaliseRecomendacaoInput({
    required this.entity,
    required this.avisos,
    required this.erros,
    required this.status,
    required this.blockedModules,
    required this.camposDerivados,
  });

  final AnaliseEntity entity;
  final List<String> avisos;
  final List<String> erros;
  final Map<String, StatusNutriente> status;
  final Set<RecommendationModule> blockedModules;
  final Set<String> camposDerivados;

  bool get hasFatalErrors => erros.isNotEmpty;
}

class RecommendationInputNormalizer {
  const RecommendationInputNormalizer();

  AnaliseRecomendacaoInput normalize({
    required AnaliseCompleta analise,
    ExtratorP? preferenciaP,
    double? argilaFallback,
  }) {
    final avisos = <String>[];
    final erros = <String>[];
    final status = <String, StatusNutriente>{};
    final blocked = <RecommendationModule>{};
    final derived = <String>{};

    void setStatus(String key, ValorNutriente valor) {
      status[key] = _statusDoValor(valor);
    }

    setStatus('PMehlich', analise.pMehlich);
    setStatus('PResina', analise.pResina);
    setStatus('PRem', analise.pRem);
    setStatus('K', analise.k);
    setStatus('Ca', analise.ca);
    setStatus('Mg', analise.mg);
    setStatus('Al', analise.al);
    setStatus('H+Al', analise.hAl);
    setStatus('Na', analise.na);
    setStatus('S020', analise.s020);
    setStatus('S2040', analise.s2040);
    setStatus('B', analise.b);
    setStatus('Cu', analise.cu);
    setStatus('Fe', analise.fe);
    setStatus('Mn', analise.mn);
    setStatus('Zn', analise.zn);
    setStatus('Ni', analise.ni);
    setStatus('Mo', analise.mo);
    setStatus('Se', analise.se);
    setStatus('Co', analise.co);
    setStatus('pH', analise.phPrincipal);
    setStatus('MO', analise.materiaOrganica);
    setStatus('Argila', analise.argila);

    final ph = _requiredValue(
      nome: 'pH',
      valor: analise.phPrincipal,
      erros: erros,
      blocked: blocked,
      modules: const {RecommendationModule.calagem},
    );

    final k = _requiredCation(
      nome: 'K',
      valor: analise.k,
      unidade: analise.kUnidadeOriginal,
      avisos: avisos,
      erros: erros,
      blocked: blocked,
      modules: const {
        RecommendationModule.calagem,
        RecommendationModule.potassio,
      },
      inferK: true,
    );
    final ca = _requiredCation(
      nome: 'Ca',
      valor: analise.ca,
      unidade: analise.caUnidadeOriginal,
      avisos: avisos,
      erros: erros,
      blocked: blocked,
      modules: const {RecommendationModule.calagem},
    );
    final mg = _requiredCation(
      nome: 'Mg',
      valor: analise.mg,
      unidade: analise.mgUnidadeOriginal,
      avisos: avisos,
      erros: erros,
      blocked: blocked,
      modules: const {RecommendationModule.calagem},
    );
    final al = _optionalCation(
      nome: 'Al',
      valor: analise.al,
      unidade: analise.alUnidadeOriginal,
      avisos: avisos,
    );
    final na = _optionalCation(
      nome: 'Na',
      valor: analise.na,
      unidade: null,
      avisos: avisos,
    );

    final sbCalculada = ca + mg + k + na;
    derived.add('SB');

    var hAl = _optionalCation(
      nome: 'H+Al',
      valor: analise.hAl,
      unidade: analise.hAlUnidadeOriginal,
      avisos: avisos,
      silentWhenMissing: true,
    );
    if (!_isValid(analise.hAl) && _isValidNullable(analise.ctc)) {
      final ctcLab = _normalizeOptionalCationValue(
        analise.ctc!.valor!,
        analise.ctcUnidadeOriginal,
      );
      hAl = (ctcLab - sbCalculada).clamp(0.0, double.infinity);
      derived.add('H+Al');
      avisos.add('H+Al ausente; derivado por CTC - SB.');
    }
    if (hAl <= 0 && !_isValid(analise.hAl) && !_isValidNullable(analise.ctc)) {
      blocked
        ..add(RecommendationModule.calagem)
        ..add(RecommendationModule.potassio);
      status['H+Al'] = StatusNutriente.ausente;
      avisos.add(
          'H+Al/CTC ausente; calagem e potássio por CTC foram bloqueados.');
    }

    final ctc = sbCalculada + hAl;
    final vPercent = ctc > 0 ? (sbCalculada / ctc) * 100.0 : 0.0;
    derived
      ..add('CTC')
      ..add('V%')
      ..add('m%');

    final pResult = _selectP(
      analise: analise,
      preferencia: preferenciaP,
      avisos: avisos,
      blocked: blocked,
      status: status,
    );

    final s = _selectS(analise, avisos);
    final mo = _normalizeMO(analise, avisos);
    final argila = _normalizeArgila(
      analise: analise,
      fallback: argilaFallback,
      avisos: avisos,
      blocked: blocked,
      derived: derived,
    );

    return AnaliseRecomendacaoInput(
      entity: AnaliseEntity(
        id: analise.id,
        nome: analise.talhao,
        consultor: 'Consultor',
        fazenda: analise.fazenda,
        talhao: analise.talhao,
        localizacao: analise.descricaoLocal ?? '-',
        cultura: analise.cultura,
        ph: ph,
        mo: mo,
        p: LimitesAgronomicos.limitarP(pResult.valorParaEngine),
        k: LimitesAgronomicos.limitarK(k),
        ca: ca,
        mg: mg,
        hAl: hAl,
        al: al,
        s: s,
        b: _optionalNutrient('B', analise.b, avisos),
        cu: _optionalNutrient('Cu', analise.cu, avisos),
        fe: _optionalNutrient('Fe', analise.fe, avisos),
        mn: _optionalNutrient('Mn', analise.mn, avisos),
        zn: _optionalNutrient('Zn', analise.zn, avisos),
        sb: sbCalculada,
        ctc: ctc,
        vPercent: vPercent,
        argila: argila,
        pMehlich: analise.pMehlich.isValido ? analise.pMehlich.valor : null,
        pResina: analise.pResina.isValido ? analise.pResina.valor : null,
        pRem: analise.pRem.isValido ? analise.pRem.valor : null,
        s2040: analise.s2040.isValido ? analise.s2040.valor : null,
      ),
      avisos: avisos,
      erros: erros,
      status: status,
      blockedModules: blocked,
      camposDerivados: derived,
    );
  }

  double _requiredValue({
    required String nome,
    required ValorNutriente valor,
    required List<String> erros,
    required Set<RecommendationModule> blocked,
    required Set<RecommendationModule> modules,
  }) {
    final status = _statusDoValor(valor);
    if (status == StatusNutriente.ok) return valor.valor!;
    blocked.addAll(modules);
    erros.add('$nome não analisado.');
    return 0.0;
  }

  double _requiredCation({
    required String nome,
    required ValorNutriente valor,
    required String? unidade,
    required List<String> avisos,
    required List<String> erros,
    required Set<RecommendationModule> blocked,
    required Set<RecommendationModule> modules,
    bool inferK = false,
  }) {
    final raw = _requiredValue(
      nome: nome,
      valor: valor,
      erros: erros,
      blocked: blocked,
      modules: modules,
    );
    if (!_isValid(valor)) return 0.0;
    return _normalizeCation(
      nome: nome,
      valor: raw,
      unidade: unidade,
      avisos: avisos,
      inferK: inferK,
    );
  }

  double _optionalCation({
    required String nome,
    required ValorNutriente valor,
    required String? unidade,
    required List<String> avisos,
    bool silentWhenMissing = false,
  }) {
    if (!_isValid(valor)) {
      if (!silentWhenMissing) {
        avisos.add('$nome não analisado; cálculo seguirá com $nome=0,0.');
      }
      return 0.0;
    }
    return _normalizeCation(
      nome: nome,
      valor: valor.valor!,
      unidade: unidade,
      avisos: avisos,
    );
  }

  double _normalizeCation({
    required String nome,
    required double valor,
    required String? unidade,
    required List<String> avisos,
    bool inferK = false,
  }) {
    if (unidade != null && unidade.trim().isNotEmpty) {
      final normalizedUnit = unidade.trim().toLowerCase();
      if (inferK && normalizedUnit.contains('mg')) {
        return valor / 391.0;
      }
      return UnidadeConverter.normalizarCation(valor, unidade);
    }
    if (inferK) {
      final result = UnidadeConverter.inferirEConverterK(valor);
      if (result.unidadeDetectada != 'cmolc/dm³') {
        avisos.add(result.aviso);
      }
      return result.valorNormalizado;
    }
    return valor;
  }

  double _normalizeOptionalCationValue(double value, String? unidade) {
    if (unidade != null && unidade.trim().isNotEmpty) {
      return UnidadeConverter.normalizarCation(value, unidade);
    }
    return value;
  }

  ({double valorParaEngine, ExtratorP? extrator}) _selectP({
    required AnaliseCompleta analise,
    required ExtratorP? preferencia,
    required List<String> avisos,
    required Set<RecommendationModule> blocked,
    required Map<String, StatusNutriente> status,
  }) {
    final extrator = analise.extratorP ?? preferencia;
    if (extrator == ExtratorP.mehlich && analise.pMehlich.isValido) {
      status['P'] = StatusNutriente.ok;
      return (valorParaEngine: analise.pMehlich.valor!, extrator: extrator);
    }
    if (extrator == ExtratorP.resina && analise.pResina.isValido) {
      status['P'] = StatusNutriente.ok;
      return (valorParaEngine: analise.pResina.valor!, extrator: extrator);
    }
    if (analise.pMehlich.isValido) {
      if (extrator == ExtratorP.resina) {
        avisos.add('Fósforo Resina indisponível; usado P Mehlich disponível.');
      }
      status['P'] = StatusNutriente.ok;
      return (
        valorParaEngine: analise.pMehlich.valor!,
        extrator: ExtratorP.mehlich
      );
    }
    if (analise.pResina.isValido) {
      if (extrator == ExtratorP.mehlich) {
        avisos.add('Fósforo Mehlich indisponível; usado P Resina disponível.');
      }
      status['P'] = StatusNutriente.ok;
      return (
        valorParaEngine: analise.pResina.valor!,
        extrator: ExtratorP.resina
      );
    }
    blocked.add(RecommendationModule.fosforo);
    status['P'] = StatusNutriente.ausente;
    avisos.add('Fósforo indisponível; módulo de fósforo bloqueado.');
    return (valorParaEngine: 0.0, extrator: null);
  }

  double _selectS(AnaliseCompleta analise, List<String> avisos) {
    if (analise.s020.isValido) return analise.s020.valor!;
    if (analise.s2040.isValido) return analise.s2040.valor!;
    avisos.add('Enxofre (S) não analisado; cálculo seguirá com S=0,0 mg/dm³.');
    return 0.0;
  }

  double _normalizeMO(AnaliseCompleta analise, List<String> avisos) {
    if (!analise.materiaOrganica.isValido) {
      avisos
          .add('Matéria orgânica não analisada; cálculo seguirá com M.O.=0,0.');
      return 0.0;
    }
    final unidade = analise.moUnidadeOriginal;
    if (unidade != null && unidade.trim().isNotEmpty) {
      return UnidadeConverter.normalizarMOPercent(
        analise.materiaOrganica.valor!,
        unidade,
      );
    }
    return analise.materiaOrganica.valor!;
  }

  double _normalizeArgila({
    required AnaliseCompleta analise,
    required double? fallback,
    required List<String> avisos,
    required Set<RecommendationModule> blocked,
    required Set<String> derived,
  }) {
    if (analise.argila.isValido) {
      final unidade = analise.argilaUnidadeOriginal;
      if (unidade != null && unidade.trim().isNotEmpty) {
        return UnidadeConverter.normalizarGranulometria(
          analise.argila.valor!,
          unidade,
        );
      }
      return analise.argila.valor!;
    }
    if (fallback != null) {
      derived.add('Argila');
      avisos.add(
          'Argila ausente; usado fallback ${fallback.toStringAsFixed(1)}%.');
      return fallback;
    }
    blocked.add(RecommendationModule.gesso);
    avisos.add(
        'Argila ausente; gessagem e critérios por textura foram bloqueados.');
    return 0.0;
  }

  double _optionalNutrient(
    String nome,
    ValorNutriente valor,
    List<String> avisos,
  ) {
    if (valor.isValido) return valor.valor!;
    avisos.add('$nome não analisado — dose não calculada.');
    return 0.0;
  }

  StatusNutriente _statusDoValor(ValorNutriente valor) {
    if (!valor.analisado || valor.valor == null) return StatusNutriente.ausente;
    if (valor.valor!.isNaN || valor.valor! < 0) return StatusNutriente.invalido;
    return StatusNutriente.ok;
  }

  bool _isValid(ValorNutriente valor) =>
      _statusDoValor(valor) == StatusNutriente.ok;

  bool _isValidNullable(ValorNutriente? valor) =>
      valor != null && _statusDoValor(valor) == StatusNutriente.ok;
}
