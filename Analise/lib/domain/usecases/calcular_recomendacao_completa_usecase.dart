import 'package:soloforte/domain/entities/analise_completa.dart';
import 'package:soloforte/domain/entities/analise_entity.dart';
import 'package:soloforte/domain/entities/resultado_gesso.dart';
import 'package:soloforte/domain/formulas/enxofre_formula.dart';
import 'package:soloforte/domain/formulas/micronutrientes_engine.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/models/diagnostico_recomendacao.dart';
import 'package:soloforte/domain/services/recommendation_input_normalizer.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
import 'package:soloforte/domain/value_objects/valor_nutriente.dart';

class CalcularRecomendacaoCompletaUsecase {
  const CalcularRecomendacaoCompletaUsecase();

  RecomendacaoResult execute({
    required AnaliseCompleta analise,
    required CalibracaoProfile calibracao,
    required List<Map<String, dynamic>> tabelas,
    String? labelAnalise,
  }) {
    final avisos = <String>[];
    final input = const RecommendationInputNormalizer().normalize(
      analise: analise,
      preferenciaP: _preferenciaExtrator(calibracao),
    );
    avisos.addAll(input.avisos);
    final status = <String, StatusNutriente>{...input.status};
    final analiseCompat = input.entity;

    ResultadoRecomendacao base;
    try {
      const engine = RecomendacaoEngine();
      base = engine.calcular(
        analise: analiseCompat,
        calibracao: calibracao,
        tabelas: tabelas,
        labelAnalise: labelAnalise,
      );
    } catch (e) {
      return RecomendacaoResult(
        recomendacao: null,
        diagnostico: DiagnosticoRecomendacao(
          erros: ['Falha interna ao calcular recomendação: $e'],
          avisos: avisos,
          statusNutrientes: status,
        ),
      );
    }

    final microsExtrasResult = _calcularMicrosExtras(
      analise: analise,
      calibracao: calibracao,
      status: status,
    );
    final doseEnxofre = EnxofreFormula.calcular(analise);

    if (doseEnxofre != null && doseEnxofre > 0) {
      avisos.add(
        'Enxofre (estrutura ativa): recomendação preliminar ${doseEnxofre.toStringAsFixed(1)} kg/ha.',
      );
    }
    if (doseEnxofre == null) {
      avisos.add(
        'Enxofre (estrutura ativa): sem S 0-20/20-40 na análise para cálculo.',
      );
    }

    final todosMicrosBase = <MicroResultado>[...base.micros];
    final calibracaoMicros =
        calibracao.parametrosCards['micros']?['elementos'] as Map?;
    if (calibracaoMicros != null) {
      for (final s in ['B', 'Cu', 'Fe', 'Mn', 'Zn']) {
        final cfg = calibracaoMicros[s];
        if (cfg is! Map) continue;

        final valNullable = _valorNutrienteByName(analise, s);
        if (!valNullable.analisado) {
          final jaExiste = todosMicrosBase.any((m) => m.elemento == s);
          if (!jaExiste) {
            final via = _string(cfg['viaAplicacao'], 'Solo');
            todosMicrosBase.add(MicroResultado(
              elemento: s,
              valorAtual: 0,
              nc: _numNullable(cfg['ncSolo']) ?? 0,
              dose: 0,
              unidade: 'g/ha',
              deficiente: false,
              via: via,
              fonte: '-',
              doseProduto: 0,
              doseProdutoLabel: 'Não analisado',
              avisosNutriente: ['$s não analisado — dose não calculada.'],
            ));
          } else {
            // Atualiza o existente que foi gerado com avisos
            final i = todosMicrosBase.indexWhere((m) => m.elemento == s);
            todosMicrosBase[i] = todosMicrosBase[i].copyWith(
              avisosNutriente: [
                ...todosMicrosBase[i].avisosNutriente,
                '$s não analisado — dose não calculada.'
              ],
              doseProdutoLabel: 'Não analisado',
            );
          }
        }
      }
    }

    final citacoes = <String, String>{
      ...?base.citacoes,
      'enxofre': '05 — Enxofre (S): Motor de Cálculo',
    };

    final avisosFinal = <String>[
      ...input.erros,
      ...base.avisos,
      ...avisos,
      ...microsExtrasResult.avisos,
      ..._avisosModulosBloqueados(input.blockedModules),
    ];
    final recomendacao = _aplicarBloqueios(
      base.copyWith(
        micros: [...todosMicrosBase, ...microsExtrasResult.micros],
        avisos: avisosFinal,
        citacoes: citacoes,
      ),
      input.blockedModules,
    );
    final diagnosticosAgronomicos = _diagnosticosAgronomicos(
      analise: analiseCompat,
      recomendacao: recomendacao,
      blockedModules: input.blockedModules,
    );

    return RecomendacaoResult(
      recomendacao: recomendacao,
      diagnostico: DiagnosticoRecomendacao(
        avisos: avisosFinal,
        statusNutrientes: status,
        diagnosticos: diagnosticosAgronomicos,
      ),
    );
  }

  double? obterFosforo(AnaliseCompleta a, {ExtratorP? preferencia}) {
    final extrator = a.extratorP ?? preferencia;
    if (extrator == ExtratorP.mehlich) {
      return a.pMehlich.isValido ? a.pMehlich.valor : null;
    }
    if (extrator == ExtratorP.resina) {
      return a.pResina.isValido ? a.pResina.valor : null;
    }
    if (a.pMehlich.isValido) return a.pMehlich.valor;
    if (a.pResina.isValido) return a.pResina.valor;
    return null;
  }

  ResultadoGesso _gessoBloqueadoPorArgilaAusente() {
    return const ResultadoGesso(
      metodo: MetodoGesso.argilaEmbrapa,
      indicado: false,
      doseKgHa: 0,
      doseTHa: 0,
      sFornecidoKgHa: 0,
      caFornecidoKgHa: 0,
      caAumentoCmolcDm3: 0,
      observacoes: [
        'Textura não informada pelo laboratório Solum. Cálculo de gessagem indisponível. Informe argila (%) manualmente.',
      ],
    );
  }

  ResultadoRecomendacao _aplicarBloqueios(
    ResultadoRecomendacao recomendacao,
    Set<RecommendationModule> blockedModules,
  ) {
    var result = recomendacao;
    if (blockedModules.contains(RecommendationModule.calagem)) {
      result = result.copyWith(
        doseCalcarioTHa: 0,
        vEsperado: recomendacao.analise.vPercent,
        caEsperado: recomendacao.analise.ca,
        mgEsperado: recomendacao.analise.mg,
        parcelamento: const <String>[],
      );
    }
    if (blockedModules.contains(RecommendationModule.fosforo)) {
      result = result.copyWith(
        doseP2O5KgHa: 0,
        legacyP: false,
      );
    }
    if (blockedModules.contains(RecommendationModule.potassio)) {
      result = result.copyWith(
        doseK2OKgHa: 0,
        relacoesK: const RelacoesK(
          relKMg: 0,
          relKCa: 0,
          alertas: <String>[],
          kNaCTC: 0,
        ),
      );
    }
    if (blockedModules.contains(RecommendationModule.gesso)) {
      result = result.copyWith(gesso: _gessoBloqueadoPorArgilaAusente());
    }
    return result;
  }

  List<String> _avisosModulosBloqueados(
    Set<RecommendationModule> blockedModules,
  ) {
    return <String>[
      if (blockedModules.contains(RecommendationModule.calagem))
        'Calagem bloqueada por ausência de dados canônicos suficientes.',
      if (blockedModules.contains(RecommendationModule.fosforo))
        'Fósforo bloqueado por ausência de P Mehlich/Resina.',
      if (blockedModules.contains(RecommendationModule.potassio))
        'Potássio bloqueado por ausência de K/CTC canônicos suficientes.',
      if (blockedModules.contains(RecommendationModule.gesso))
        'Gessagem bloqueada por ausência de argila/textura.',
    ];
  }

  ExtratorP? _preferenciaExtrator(CalibracaoProfile calibracao) {
    final fosforo = calibracao.parametrosCards['fosforo'];
    if (fosforo is! Map) return null;
    final referencia = (fosforo['referencia'] ?? '').toString().toLowerCase();
    if (referencia.contains('resina')) return ExtratorP.resina;
    if (referencia.contains('mehlich')) return ExtratorP.mehlich;
    return null;
  }

  ({List<MicroResultado> micros, List<String> avisos}) _calcularMicrosExtras({
    required AnaliseCompleta analise,
    required CalibracaoProfile calibracao,
    required Map<String, StatusNutriente> status,
  }) {
    final microsCard = calibracao.parametrosCards['micros'];
    if (microsCard is! Map) {
      return (micros: const <MicroResultado>[], avisos: const <String>[]);
    }
    final elementosRaw = microsCard['elementos'];
    if (elementosRaw is! Map) {
      return (micros: const <MicroResultado>[], avisos: const <String>[]);
    }

    final extras = <MicroResultado>[];
    final avisos = <String>[];
    for (final simbolo in const <String>['Ni', 'Mo', 'Se']) {
      final cfgRaw = elementosRaw[simbolo];
      if (cfgRaw is! Map) continue;
      final cfg = Map<String, dynamic>.from(
        cfgRaw.map((key, value) => MapEntry(key.toString(), value)),
      );

      final valorAtual = _microValor(analise, simbolo);
      status[simbolo] = _statusDoValor(valorAtual);

      final via = _string(cfg['viaAplicacao'], 'Solo (correção)');
      final nc = _numNullable(cfg['ncSolo']);

      final avisosDoNutriente = <String>[];

      if (!valorAtual.isValido) {
        avisosDoNutriente.add('Micronutriente $simbolo sem teor na análise.');
      }
      if (nc == null) {
        avisosDoNutriente.add('Micronutriente $simbolo sem referência de NC.');
      }

      double doseProdutoCalc = 0.0;
      double doseElemento = 0.0;
      String unidade = 'g/ha';
      String refStr = '';
      String lbl = 'Dose não calculada';

      if (valorAtual.isValido && nc != null) {
        final resultado = via.contains('Solo')
            ? MicronutrientesEngine.calcularViaSolo(
                elemento: _toElemento(simbolo),
                teorSolo: valorAtual.valor!,
                percentualCorrecao: _num(cfg['percentualCorrecaoSolo'], 100),
                teorFonte: _num(cfg['teorFonteSolo'], 0),
                eficiencia: _num(cfg['eficienciaSolo'], 0),
              )
            : MicronutrientesEngine.calcularViaFoliar(
                elemento: _toElemento(simbolo),
                teorSolo: valorAtual.valor!,
                doseElemento: _num(cfg['doseElementoFoliar'], 0),
                teorFonte: _num(cfg['teorFonteFoliar'], 0),
                eficienciaFoliar: _num(cfg['eficienciaFoliar'], 0),
              );

        doseProdutoCalc = resultado.doseProduto;
        doseElemento = resultado.doseElemento;
        unidade = resultado.unidade;

        if (resultado.avisos.isNotEmpty) refStr = resultado.avisos.join(' ');

        if (doseElemento > 0) {
          lbl = unidade == 'kg/ha'
              ? '${doseProdutoCalc.toStringAsFixed(2)} kg/ha produto'
              : '${doseProdutoCalc.toStringAsFixed(1)} g/ha produto';
        }
      }

      final addAny = doseElemento > 0 || avisosDoNutriente.isNotEmpty;
      if (!addAny) continue;

      extras.add(
        MicroResultado(
          elemento: simbolo,
          valorAtual: valorAtual.isValido ? valorAtual.valor! : 0.0,
          nc: nc ?? 0.0,
          dose: doseElemento,
          unidade: unidade,
          deficiente: (nc != null && valorAtual.isValido)
              ? valorAtual.valor! < nc
              : false,
          via: via,
          fonte: via.contains('Solo')
              ? _string(cfg['fonteSolo'], 'Fonte solo')
              : _string(cfg['fonteFoliar'], 'Fonte foliar'),
          doseProduto: doseProdutoCalc,
          doseProdutoLabel: lbl,
          referencia: refStr.isEmpty ? null : refStr,
          avisosNutriente: avisosDoNutriente,
        ),
      );
    }

    return (micros: extras, avisos: avisos);
  }

  StatusNutriente _statusDoValor(ValorNutriente valor) {
    if (!valor.analisado || valor.valor == null) return StatusNutriente.ausente;
    if (valor.valor!.isNaN || valor.valor! < 0) return StatusNutriente.invalido;
    return StatusNutriente.ok;
  }

  ValorNutriente _valorNutrienteByName(AnaliseCompleta analise, String nome) {
    return switch (nome) {
      'B' => analise.b,
      'Cu' => analise.cu,
      'Fe' => analise.fe,
      'Mn' => analise.mn,
      'Zn' => analise.zn,
      _ => const ValorNutriente(valor: null, analisado: false)
    };
  }

  ElementoMicro _toElemento(String simbolo) {
    return switch (simbolo) {
      'Ni' => ElementoMicro.Ni,
      'Mo' => ElementoMicro.Mo,
      'Se' => ElementoMicro.Se,
      _ => ElementoMicro.B,
    };
  }

  ValorNutriente _microValor(AnaliseCompleta analise, String simbolo) {
    return switch (simbolo) {
      'Ni' => analise.ni,
      'Mo' => analise.mo,
      'Se' => analise.se,
      _ => const ValorNutriente(valor: null, analisado: false),
    };
  }

  Map<String, DiagnosticoNutriente> _diagnosticosAgronomicos({
    required AnaliseEntity analise,
    required ResultadoRecomendacao recomendacao,
    required Set<RecommendationModule> blockedModules,
  }) {
    return <String, DiagnosticoNutriente>{
      'calagem': blockedModules.contains(RecommendationModule.calagem)
          ? _diagnosticoBloqueado(
              'Calagem não calculada por ausência de dados de acidez/CTC.',
            )
          : _diagnosticoCalagem(analise, recomendacao),
      'fosforo': blockedModules.contains(RecommendationModule.fosforo)
          ? _diagnosticoBloqueado(
              'Fósforo não calculado por ausência de P Mehlich/Resina.',
            )
          : _diagnosticoFosforo(analise, recomendacao),
      'potassio': blockedModules.contains(RecommendationModule.potassio)
          ? _diagnosticoBloqueado(
              'Potássio não calculado por ausência de K/CTC.',
            )
          : _diagnosticoPotassio(analise, recomendacao),
      if (recomendacao.gesso.indicado)
        'gesso': DiagnosticoNutriente(
          status: DiagnosticoStatus.baixo,
          mensagemTecnica:
              'Subsolo com indicativo de limitação química para aprofundamento radicular.',
          recomendacao:
              'Aplicar gesso agrícola conforme dose calculada de ${recomendacao.gesso.doseKgHa.toStringAsFixed(0)} kg/ha.',
        )
      else
        'gesso': const DiagnosticoNutriente(
          status: DiagnosticoStatus.adequado,
          mensagemTecnica:
              'Sem indicação agronômica de gessagem para os critérios configurados.',
          recomendacao: 'Não aplicar gesso corretivo neste cenário.',
        ),
      for (final micro in recomendacao.micros)
        micro.elemento.toLowerCase(): _diagnosticoMicro(micro),
    };
  }

  DiagnosticoNutriente _diagnosticoBloqueado(String mensagem) {
    return DiagnosticoNutriente(
      status: DiagnosticoStatus.adequado,
      mensagemTecnica: mensagem,
      recomendacao: 'Informe o dado ausente para habilitar este módulo.',
    );
  }

  DiagnosticoNutriente _diagnosticoCalagem(
    AnaliseEntity analise,
    ResultadoRecomendacao recomendacao,
  ) {
    if (analise.vPercent > recomendacao.vEsperado + 10) {
      return const DiagnosticoNutriente(
        status: DiagnosticoStatus.alto,
        mensagemTecnica:
            'Saturação por bases acima da meta configurada para a cultura.',
        recomendacao:
            'Não aplicar calcário; monitorar Ca, Mg e risco de supercalagem.',
      );
    }
    if (recomendacao.doseCalcarioTHa > 0) {
      return DiagnosticoNutriente(
        status: DiagnosticoStatus.baixo,
        mensagemTecnica:
            'Saturação por bases abaixo da meta e acidez corrigível por calagem.',
        recomendacao:
            'Aplicar calcário na dose de ${recomendacao.doseCalcarioTHa.toStringAsFixed(2)} t/ha.',
      );
    }
    return const DiagnosticoNutriente(
      status: DiagnosticoStatus.adequado,
      mensagemTecnica:
          'Saturação por bases atende à meta configurada para a cultura.',
      recomendacao: 'Manter monitoramento e não aplicar calcário corretivo.',
    );
  }

  DiagnosticoNutriente _diagnosticoFosforo(
    AnaliseEntity analise,
    ResultadoRecomendacao recomendacao,
  ) {
    final nc = recomendacao.ncFosforo;
    if (analise.p < nc) {
      return DiagnosticoNutriente(
        status: DiagnosticoStatus.baixo,
        mensagemTecnica: 'Fósforo abaixo do nível crítico.',
        recomendacao:
            'Aplicar P2O5 na dose de ${recomendacao.doseP2O5KgHa.toStringAsFixed(1)} kg/ha.',
      );
    }
    if (analise.p > nc * 1.5) {
      return const DiagnosticoNutriente(
        status: DiagnosticoStatus.alto,
        mensagemTecnica:
            'Fósforo acima da faixa crítica, com baixo retorno esperado para correção.',
        recomendacao:
            'Evitar adubação corretiva de P2O5 e usar apenas manutenção quando necessário.',
      );
    }
    return const DiagnosticoNutriente(
      status: DiagnosticoStatus.adequado,
      mensagemTecnica: 'Fósforo dentro da faixa adequada.',
      recomendacao: 'Manter reposição conforme exportação da cultura.',
    );
  }

  DiagnosticoNutriente _diagnosticoPotassio(
    AnaliseEntity analise,
    ResultadoRecomendacao recomendacao,
  ) {
    if (recomendacao.relacoesK.alertas.isNotEmpty) {
      return DiagnosticoNutriente(
        status: DiagnosticoStatus.alto,
        mensagemTecnica:
            'Potássio em condição de antagonismo: ${recomendacao.relacoesK.alertas.join(', ')}.',
        recomendacao:
            'Reduzir ou suspender K2O corretivo e reequilibrar relações Ca:Mg:K.',
      );
    }

    final teorBaixo = recomendacao.criterioPotassio.contains('%')
        ? recomendacao.relacoesK.kNaCTC < recomendacao.ncPotassio
        : analise.k < recomendacao.ncPotassio;
    if (teorBaixo || recomendacao.doseK2OKgHa > 0) {
      return DiagnosticoNutriente(
        status: DiagnosticoStatus.baixo,
        mensagemTecnica: 'Potássio abaixo do nível crítico configurado.',
        recomendacao:
            'Aplicar K2O na dose de ${recomendacao.doseK2OKgHa.toStringAsFixed(1)} kg/ha.',
      );
    }

    return const DiagnosticoNutriente(
      status: DiagnosticoStatus.adequado,
      mensagemTecnica:
          'Potássio em faixa adequada e sem antagonismos críticos.',
      recomendacao: 'Manter reposição conforme exportação e monitoramento.',
    );
  }

  DiagnosticoNutriente _diagnosticoMicro(MicroResultado micro) {
    if (micro.valorAtual > micro.nc * 1.5) {
      return DiagnosticoNutriente(
        status: DiagnosticoStatus.alto,
        mensagemTecnica:
            '${micro.elemento} acima do nível crítico de referência.',
        recomendacao:
            'Não aplicar ${micro.elemento}; monitorar risco de excesso/toxidez.',
      );
    }
    if (micro.deficiente) {
      return DiagnosticoNutriente(
        status: DiagnosticoStatus.baixo,
        mensagemTecnica:
            '${micro.elemento} abaixo do nível crítico de referência.',
        recomendacao:
            'Aplicar ${micro.elemento} via ${micro.via} usando ${micro.fonte}.',
      );
    }
    return DiagnosticoNutriente(
      status: DiagnosticoStatus.adequado,
      mensagemTecnica:
          '${micro.elemento} dentro da faixa adequada para o critério configurado.',
      recomendacao: 'Manter monitoramento de ${micro.elemento}.',
    );
  }

  double _num(dynamic value, double fallback) {
    final parsed = _numNullable(value);
    return parsed ?? fallback;
  }

  String _string(dynamic value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  double? _numNullable(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.'));
    return null;
  }
}
