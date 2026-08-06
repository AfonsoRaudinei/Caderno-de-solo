import 'package:soloforte/domain/entities/analise_entity.dart';
import 'package:soloforte/domain/entities/micronutrientes_calibracao.dart';
import 'package:soloforte/domain/formulas/micronutrientes_recomendacao_formula.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';

/// Calcula recomendação de micronutrientes a partir da calibração cadastrada.
class CalcularMicronutrientesRecomendacaoUsecase {
  const CalcularMicronutrientesRecomendacaoUsecase();

  ({List<MicroResultado> micros, List<GrupoResultado> grupos}) execute({
    required Map<String, dynamic> microsConfig,
    required AnaliseEntity analise,
    required double? producaoEsperadaTha,
    List<String>? gruposIdsSelecionados,
  }) {
    final micros = normalizarMicros(microsConfig);
    final gruposRaw = _asListMap(micros['grupos']);
    final elementosMap = _asMap(micros['elementos']);

    if (gruposRaw.isEmpty) {
      return _legadoSemGrupos(
        elementosRaw: _asMap(microsConfig['elementos']),
        analise: analise,
        producaoTha: producaoEsperadaTha,
      );
    }

    final gruposFiltrados =
        gruposIdsSelecionados == null || gruposIdsSelecionados.isEmpty
            ? gruposRaw
            : gruposRaw
                .where(
                  (g) => gruposIdsSelecionados.contains(g['id']?.toString()),
                )
                .toList();

    final microsResultado = <MicroResultado>[];
    final gruposResultado = <GrupoResultado>[];

    for (final grupo in gruposFiltrados) {
      final grupoNorm = normalizarGrupoMicros(grupo);
      final elementosGrupo = List<String>.from(
        (grupoNorm['elementos'] as List?)?.map((e) => e.toString()) ?? const [],
      );
      if (elementosGrupo.isEmpty) continue;

      final viasGrupo = List<String>.from(
        grupoNorm['viasAplicacaoGrupo'] as List? ?? const ['Foliar'],
      );
      final efSolo = _num(grupoNorm['eficienciaSoloGrupo'], 30);
      final efFoliar = _num(
        grupoNorm['eficienciaFoliarGrupo'] ?? grupoNorm['eficiencia'],
        70,
      );
      final efTs = _num(grupoNorm['eficienciaTsGrupo'], 80);
      final fonteGrupo = _string(grupoNorm['fonte'] ?? grupoNorm['produto']);
      final nomeGrupo = _string(grupoNorm['nome'], fallback: 'Grupo');
      final microsGrupo = <MicroResultado>[];

      for (final simbolo in elementosGrupo) {
        final elemento = normalizarElementoMicros(
          simbolo,
          _asMap(elementosMap[simbolo]),
        );
        final resultado = _calcularElemento(
          simbolo: simbolo,
          elemento: elemento,
          analise: analise,
          producaoTha: producaoEsperadaTha,
          viasGrupo: viasGrupo,
          eficienciaSolo: efSolo,
          eficienciaFoliar: efFoliar,
          eficienciaTs: efTs,
          fonteGrupo: fonteGrupo,
          nomeGrupo: nomeGrupo,
          grupoId: grupoNorm['id']?.toString(),
        );
        if (resultado == null) continue;
        microsGrupo.add(resultado);
        microsResultado.add(resultado);
      }

      if (microsGrupo.isEmpty) continue;

      final doseProdutoKg = microsGrupo.fold<double>(
            0,
            (sum, item) => sum + item.doseProduto,
          ) /
          1000;

      final fornecimento = microsGrupo
          .map((item) => '${item.elemento} ${_fmt(item.dose, 1)} g/ha')
          .join(' · ');

      gruposResultado.add(
        GrupoResultado(
          nomeGrupo: nomeGrupo,
          micros: microsGrupo,
          via: viasGrupo.join(' + '),
          produto: fonteGrupo.isEmpty ? 'Fonte do grupo' : fonteGrupo,
          doseProdutoKgLabel: '${_fmt(doseProdutoKg, 2)} kg/ha',
          fornecimento: fornecimento,
        ),
      );
    }

    return (micros: microsResultado, grupos: gruposResultado);
  }

  MicroResultado? _calcularElemento({
    required String simbolo,
    required Map<String, dynamic> elemento,
    required AnaliseEntity analise,
    required double? producaoTha,
    required List<String> viasGrupo,
    required double eficienciaSolo,
    required double eficienciaFoliar,
    required double eficienciaTs,
    required String fonteGrupo,
    required String nomeGrupo,
    String? grupoId,
  }) {
    final valorAtual = _valorMicroAnalise(simbolo, analise);
    final nc = _num(elemento[legacyNcKey]);
    final deficit = calcularDeficitMicronutriente(
      nivelCritico: nc,
      teorAtual: valorAtual,
    );
    final prod = producaoTha ?? 0;
    final extracao = calcularExtracaoMicronutriente(
      producaoTha: prod,
      extracaoPlantaGt: _num(elemento['extracaoPlanta']),
    );
    final exportacao = calcularExportacaoMicronutriente(
      producaoTha: prod,
      exportacaoGraosGt: _num(elemento['exportacaoGraos']),
    );
    final regra = regraPlantaOuGrao(teorAtual: valorAtual, nivelCritico: nc);
    final necessidade = calcularNecessidadeMicronutriente(
      regra: regra,
      extracaoGHa: extracao,
      exportacaoGHa: exportacao,
    );
    final correcaoSolo = calcularCorrecaoSoloMicronutriente(
      deficit: deficit,
      eficienciaSoloPercent: eficienciaSolo,
    );

    final viasElemento = List<String>.from(
      (elemento['viasAplicacao'] as List?)?.map((e) => e.toString()) ??
          const ['Solo'],
    );
    final via = viaPrincipalMicronutriente(
          viasGrupo: viasGrupo,
          viasElemento: viasElemento,
        ) ??
        viasGrupo.first;

    final eficienciaAplicada = eficienciaGrupoPorVia(
      via: via,
      eficienciaSolo: eficienciaSolo,
      eficienciaFoliar: eficienciaFoliar,
      eficienciaTs: eficienciaTs,
    );

    final doseElemento = doseElementoPorVia(
      via: via,
      correcaoSoloGHa: correcaoSolo,
      necessidadeGHa: necessidade,
      deficit: deficit,
    );

    final concentracao = _num(elemento['concentracaoFonte']);
    final unidadeConc = _string(elemento['concentracaoUnidade'], fallback: '%');
    final doseMin = _num(elemento['doseMinima']);
    final doseMax = _num(elemento['doseMaxima']);
    final limiteTox = _num(elemento['limiteToxicidade']);

    var doseComercial = converterDoseComercialGHa(
      doseElementoGHa: doseElemento,
      concentracao: concentracao,
      unidadeConcentracao: unidadeConc,
      eficienciaPercent: eficienciaAplicada,
    );

    final avisos = <String>[];
    final memoria = <String>[
      'Grupo: $nomeGrupo',
      'NC: ${_fmt(nc)} ${_string(elemento['ncUnidade'], fallback: 'mg/dm³')}',
      'Teor atual: ${_fmt(valorAtual)} mg/dm³',
      'Déficit: ${_fmt(deficit)} mg/dm³',
      'Correção solo (elem.): ${_fmt(correcaoSolo)} g/ha',
      'Produção: ${_fmt(prod)} t/ha',
      'Extração: ${_fmt(extracao)} g/ha',
      'Exportação: ${_fmt(exportacao)} g/ha',
      'Regra: $regra',
      'Via: $via | Eficiência: ${_fmt(eficienciaAplicada)}%',
      'Necessidade: ${_fmt(necessidade)} g/ha',
      'Dose elemento: ${_fmt(doseElemento)} g/ha',
    ];

    if (prod <= 0) {
      avisos.add(
          'Produção esperada não configurada — extração/exportação zeradas.');
    }
    if (concentracao <= 0) {
      avisos.add('Concentração da fonte não cadastrada.');
    }
    if (eficienciaAplicada <= 0) {
      avisos.add('Eficiência da via $via não cadastrada.');
    }

    final doseAntesLimites = doseComercial;
    doseComercial = aplicarLimitesDoseComercial(
      doseComercialGHa: doseComercial,
      doseMinima: doseMin,
      doseMaxima: doseMax,
    );
    if (doseMin > 0 && doseAntesLimites < doseMin) {
      avisos.add('Dose ajustada ao mínimo cadastrado (${_fmt(doseMin)} g/ha).');
      memoria.add('Ajuste dose mínima: ${_fmt(doseMin)} g/ha');
    }
    if (doseMax > 0 && doseAntesLimites > doseMax) {
      avisos.add('Dose limitada ao máximo cadastrado (${_fmt(doseMax)} g/ha).');
      memoria.add('Ajuste dose máxima: ${_fmt(doseMax)} g/ha');
    }
    if (limiteTox > 0 && doseElemento > limiteTox) {
      avisos.add(
        'Dose de elemento (${_fmt(doseElemento)} g/ha) acima do limite de toxicidade (${_fmt(limiteTox)} g/ha).',
      );
    }

    if (doseElemento <= 0 && doseComercial <= 0) {
      return MicroResultado(
        elemento: simbolo,
        valorAtual: valorAtual,
        nc: nc,
        deficit: deficit,
        correcaoSolo: correcaoSolo,
        producaoTha: prod,
        extracao: extracao,
        exportacao: exportacao,
        regraUtilizada: regra,
        eficienciaAplicada: eficienciaAplicada,
        necessidadeNutriente: necessidade,
        dose: 0,
        unidade: 'g/ha',
        deficiente: valorAtual < nc,
        via: via,
        fonte: fonteGrupo.isNotEmpty
            ? fonteGrupo
            : _string(elemento['fonteSolo'] ?? elemento['fonteFoliar']),
        doseProduto: 0,
        doseProdutoLabel: 'Sem necessidade',
        referencia: _string(elemento['referenciaNc']),
        avisosNutriente: avisos,
        memoriaCalculo: memoria,
        grupoNome: nomeGrupo,
        grupoId: grupoId,
        concentracaoUnidade: unidadeConc,
        doseMinima: doseMin,
        doseMaxima: doseMax,
      );
    }

    memoria.add(
      'Dose comercial: ${rotuloDoseComercial(doseComercial)}',
    );

    return MicroResultado(
      elemento: simbolo,
      valorAtual: valorAtual,
      nc: nc,
      deficit: deficit,
      correcaoSolo: correcaoSolo,
      producaoTha: prod,
      extracao: extracao,
      exportacao: exportacao,
      regraUtilizada: regra,
      eficienciaAplicada: eficienciaAplicada,
      necessidadeNutriente: necessidade,
      dose: doseElemento,
      unidade: 'g/ha',
      deficiente: valorAtual < nc,
      via: via,
      fonte: fonteGrupo.isNotEmpty
          ? fonteGrupo
          : _string(elemento['fonteSolo'] ?? elemento['fonteFoliar']),
      doseProduto: doseComercial,
      doseProdutoLabel: rotuloDoseComercial(doseComercial),
      referencia: _string(elemento['referenciaNc']),
      avisosNutriente: avisos,
      memoriaCalculo: memoria,
      grupoNome: nomeGrupo,
      grupoId: grupoId,
      concentracaoUnidade: unidadeConc,
      doseMinima: doseMin,
      doseMaxima: doseMax,
    );
  }

  ({List<MicroResultado> micros, List<GrupoResultado> grupos})
      _legadoSemGrupos({
    required Map<String, dynamic> elementosRaw,
    required AnaliseEntity analise,
    required double? producaoTha,
  }) {
    final micros = <MicroResultado>[];
    for (final simbolo in elementosRaw.keys) {
      final elemento = normalizarElementoMicros(
        simbolo,
        _asMap(elementosRaw[simbolo]),
      );
      final resultado = _calcularElemento(
        simbolo: simbolo,
        elemento: elemento,
        analise: analise,
        producaoTha: producaoTha,
        viasGrupo: List<String>.from(
          (elemento['viasAplicacao'] as List?)?.map((e) => e.toString()) ??
              const ['Solo'],
        ),
        eficienciaSolo: _num(elemento['eficienciaSolo'], 30),
        eficienciaFoliar: _num(elemento['eficienciaFoliar'], 70),
        eficienciaTs: 80,
        fonteGrupo: '',
        nomeGrupo: 'Legado',
        grupoId: null,
      );
      if (resultado != null) micros.add(resultado);
    }
    return (micros: micros, grupos: const <GrupoResultado>[]);
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
      case 'Mo':
        return 0;
      case 'Co':
        return 0;
      case 'Ni':
        return 0;
      case 'Se':
        return 0;
      default:
        return 0;
    }
  }

  String _fmt(double value, [int decimals = 2]) {
    return value.toStringAsFixed(decimals).replaceAll('.', ',');
  }

  double _num(dynamic value, [double fallback = 0]) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(',', '.').trim());
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asListMap(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }
}
