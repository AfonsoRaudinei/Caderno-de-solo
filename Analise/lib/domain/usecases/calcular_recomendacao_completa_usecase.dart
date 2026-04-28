import 'package:soloforte/domain/entities/analise_completa.dart';
import 'package:soloforte/domain/entities/analise_entity.dart';
import 'package:soloforte/domain/formulas/enxofre_formula.dart';
import 'package:soloforte/domain/formulas/micronutrientes_engine.dart';
import 'package:soloforte/domain/guards/limites_agronomicos.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/models/diagnostico_recomendacao.dart';
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
    final erros = <String>[];
    final avisos = <String>[];
    final status = _statusBase(analise);

    final pSelecionado = obterFosforo(
      analise,
      preferencia: _preferenciaExtrator(calibracao),
    );
    if (pSelecionado == null) {
      erros.add('Fósforo indisponível: Mehlich/Resina não analisado.');
      status['P'] = StatusNutriente.ausente;
    } else {
      status['P'] = StatusNutriente.ok;
    }

    _validarCritico(nome: 'pH', valor: analise.phPrincipal, erros: erros);
    _validarCritico(
      nome: 'Matéria Orgânica',
      valor: analise.materiaOrganica,
      erros: erros,
    );
    _validarCritico(nome: 'Argila', valor: analise.argila, erros: erros);
    _validarCritico(nome: 'K', valor: analise.k, erros: erros);
    _validarCritico(nome: 'Ca', valor: analise.ca, erros: erros);
    _validarCritico(nome: 'Mg', valor: analise.mg, erros: erros);
    _validarCritico(nome: 'Al', valor: analise.al, erros: erros);
    _validarCritico(nome: 'H+Al', valor: analise.hAl, erros: erros);
    _validarCritico(nome: 'S', valor: _preferirS(analise), erros: erros);
    _validarCritico(nome: 'B', valor: analise.b, erros: erros);
    _validarCritico(nome: 'Cu', valor: analise.cu, erros: erros);
    _validarCritico(nome: 'Fe', valor: analise.fe, erros: erros);
    _validarCritico(nome: 'Mn', valor: analise.mn, erros: erros);
    _validarCritico(nome: 'Zn', valor: analise.zn, erros: erros);

    if (erros.isNotEmpty) {
      return RecomendacaoResult(
        recomendacao: null,
        diagnostico: DiagnosticoRecomendacao(
          erros: erros,
          avisos: avisos,
          statusNutrientes: status,
        ),
      );
    }

    final analiseCompat = _toAnaliseEntity(
      analise: analise,
      pSelecionado: pSelecionado!,
    );

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

    final citacoes = <String, String>{
      ...?base.citacoes,
      'enxofre': '05 — Enxofre (S): Motor de Cálculo',
    };

    final recomendacao = base.copyWith(
      micros: [...base.micros, ...microsExtrasResult.micros],
      avisos: [...base.avisos, ...avisos, ...microsExtrasResult.avisos],
      citacoes: citacoes,
    );
    final diagnosticosAgronomicos = _diagnosticosAgronomicos(
      analise: analiseCompat,
      recomendacao: recomendacao,
    );

    return RecomendacaoResult(
      recomendacao: recomendacao,
      diagnostico: DiagnosticoRecomendacao(
        erros: erros,
        avisos: [...avisos, ...microsExtrasResult.avisos],
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

  AnaliseEntity _toAnaliseEntity({
    required AnaliseCompleta analise,
    required double pSelecionado,
  }) {
    double sb = 0;
    if (analise.ca.isValido) sb += analise.ca.valor!;
    if (analise.mg.isValido) sb += analise.mg.valor!;
    if (analise.k.isValido) sb += analise.k.valor!;
    if (analise.na.isValido) sb += analise.na.valor!;

    final ctc = sb + analise.hAl.valor!;
    final vPercent = ctc > 0 ? (sb / ctc) * 100 : 0.0;

    return AnaliseEntity(
      id: analise.id,
      nome: analise.talhao,
      consultor: 'Consultor',
      fazenda: analise.fazenda,
      talhao: analise.talhao,
      localizacao: analise.descricaoLocal ?? '-',
      cultura: analise.cultura,
      ph: analise.phPrincipal.valor!,
      mo: analise.materiaOrganica.valor!,
      p: LimitesAgronomicos.limitarP(pSelecionado),
      k: LimitesAgronomicos.limitarK(analise.k.valor!),
      ca: analise.ca.valor!,
      mg: analise.mg.valor!,
      hAl: analise.hAl.valor!,
      al: analise.al.valor!,
      s: _preferirS(analise).valor!,
      b: analise.b.valor!,
      cu: analise.cu.valor!,
      fe: analise.fe.valor!,
      mn: analise.mn.valor!,
      zn: analise.zn.valor!,
      sb: sb,
      ctc: ctc,
      vPercent: vPercent,
      argila: analise.argila.valor!,
    );
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
      if (!valorAtual.isValido) {
        avisos.add('Micronutriente $simbolo sem teor na análise.');
        continue;
      }
      if (nc == null) {
        avisos.add('Micronutriente $simbolo sem referência de NC.');
        continue;
      }

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

      avisos.addAll(resultado.avisos);
      if (resultado.doseElemento <= 0) continue;

      final doseProdutoLabel = resultado.unidade == 'kg/ha'
          ? '${resultado.doseProduto.toStringAsFixed(2)} kg/ha produto'
          : '${resultado.doseProduto.toStringAsFixed(1)} g/ha produto';

      extras.add(
        MicroResultado(
          elemento: simbolo,
          valorAtual: valorAtual.valor!,
          nc: nc,
          dose: resultado.doseElemento,
          unidade: 'g/ha',
          deficiente: valorAtual.valor! < nc,
          via: via,
          fonte: via.contains('Solo')
              ? _string(cfg['fonteSolo'], 'Fonte solo')
              : _string(cfg['fonteFoliar'], 'Fonte foliar'),
          doseProduto: resultado.doseProduto,
          doseProdutoLabel: doseProdutoLabel,
          referencia:
              resultado.avisos.isEmpty ? null : resultado.avisos.join(' '),
        ),
      );
    }

    return (micros: extras, avisos: avisos);
  }

  Map<String, StatusNutriente> _statusBase(AnaliseCompleta analise) {
    return <String, StatusNutriente>{
      'PMehlich': _statusDoValor(analise.pMehlich),
      'PResina': _statusDoValor(analise.pResina),
      'PRem': _statusDoValor(analise.pRem),
      'K': _statusDoValor(analise.k),
      'Ca': _statusDoValor(analise.ca),
      'Mg': _statusDoValor(analise.mg),
      'Al': _statusDoValor(analise.al),
      'H+Al': _statusDoValor(analise.hAl),
      'Na': _statusDoValor(analise.na),
      'S020': _statusDoValor(analise.s020),
      'S2040': _statusDoValor(analise.s2040),
      'B': _statusDoValor(analise.b),
      'Cu': _statusDoValor(analise.cu),
      'Fe': _statusDoValor(analise.fe),
      'Mn': _statusDoValor(analise.mn),
      'Zn': _statusDoValor(analise.zn),
      'Ni': _statusDoValor(analise.ni),
      'Mo': _statusDoValor(analise.mo),
      'Se': _statusDoValor(analise.se),
      'Co': _statusDoValor(analise.co),
      'pH': _statusDoValor(analise.phPrincipal),
      'MO': _statusDoValor(analise.materiaOrganica),
      'Argila': _statusDoValor(analise.argila),
    };
  }

  StatusNutriente _statusDoValor(ValorNutriente valor) {
    if (!valor.analisado || valor.valor == null) return StatusNutriente.ausente;
    if (valor.valor!.isNaN || valor.valor! < 0) return StatusNutriente.invalido;
    return StatusNutriente.ok;
  }

  void _validarCritico({
    required String nome,
    required ValorNutriente valor,
    required List<String> erros,
  }) {
    final status = _statusDoValor(valor);
    if (status == StatusNutriente.ausente) {
      erros.add('$nome não analisado.');
      return;
    }
    if (status == StatusNutriente.invalido) {
      erros.add('$nome inválido na análise.');
    }
  }

  ValorNutriente _preferirS(AnaliseCompleta analise) {
    if (analise.s020.isValido) return analise.s020;
    if (analise.s2040.isValido) return analise.s2040;
    return const ValorNutriente(valor: null, analisado: false);
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
  }) {
    return <String, DiagnosticoNutriente>{
      'calagem': _diagnosticoCalagem(analise, recomendacao),
      'fosforo': _diagnosticoFosforo(analise, recomendacao),
      'potassio': _diagnosticoPotassio(analise, recomendacao),
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
