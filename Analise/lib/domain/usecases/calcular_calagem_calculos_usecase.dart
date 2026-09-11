import 'package:soloforte/domain/formulas/calcario_formula.dart';
import 'package:soloforte/domain/formulas/types/calcario_input.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';

class CalculoCalagemAnaliseInput {
  const CalculoCalagemAnaliseInput({
    required this.id,
    required this.label,
    required this.talhao,
    required this.laboratorio,
    this.phCaCl2,
    this.materiaOrganica,
    this.ca,
    this.mg,
    this.k,
    this.hAl,
    this.al,
    this.ctc,
    this.vPercent,
    this.p,
    this.argila,
    this.pRem,
  });

  final String id;
  final String label;
  final String talhao;
  final String laboratorio;
  final double? phCaCl2;
  final double? materiaOrganica;
  final double? ca;
  final double? mg;
  final double? k;
  final double? hAl;
  final double? al;
  final double? ctc;
  final double? vPercent;
  final double? p;
  final double? argila;
  final double? pRem;
}

class CalculoCalagemResultado {
  const CalculoCalagemResultado({
    required this.metodo,
    required this.referencia,
    required this.tipoCalcario,
    required this.doseFinalTHa,
    required this.ncBase,
    required this.profundidadeCm,
    required this.fatorProfundidade,
    required this.prnt,
    required this.superficieContato,
    required this.vAtual,
    required this.vAlvo,
    required this.y,
    required this.usaSegundoCalcario,
    required this.resumoCalculo,
  });

  final String metodo;
  final String referencia;
  final String tipoCalcario;
  final double doseFinalTHa;
  final double ncBase;
  final double profundidadeCm;
  final double fatorProfundidade;
  final double prnt;
  final double superficieContato;
  final double vAtual;
  final double? vAlvo;
  final double? y;
  final bool usaSegundoCalcario;
  final String resumoCalculo;
}

class CalcularCalagemCalculosUsecase {
  const CalcularCalagemCalculosUsecase();

  CalculoCalagemResultado call({
    required CalculoCalagemAnaliseInput analise,
    required CalibracaoProfile calibracao,
  }) {
    final corretivos = _asMap(calibracao.parametrosCards['corretivos']);
    final metodo =
        _asString(corretivos['metodoCalagem'], '① Saturação por Bases (V%)');
    final referencia = _asString(
      corretivos['referencia'],
      '01 — Calagem: Motor de Cálculo',
    );
    final tipoCalcario = _asString(corretivos['tipoCalcario'], 'Dolomítico');
    final usarSegundoCalcario = _asBool(corretivos['usarSegundoCalcario']);
    final calcario1 = _asMap(corretivos['calcario1']);
    final calcario2 = _asMap(corretivos['calcario2']);
    final albrecht = _asMap(corretivos['albrecht']);

    final proporcao1 =
        _asNum(corretivos['proporcaoCalcario1'], 50.0).clamp(0.0, 100.0);
    final proporcao2 = 100.0 - proporcao1;
    final caO1 = _asNum(calcario1['caO'], 30.0);
    final mgO1 = _asNum(calcario1['mgO'], 16.0);
    final prnt1 = _asNum(calcario1['prnt'], 81.0);
    final caO2 = _asNum(calcario2['caO'], 42.0);
    final mgO2 = _asNum(calcario2['mgO'], 3.0);
    final prnt2 = _asNum(calcario2['prnt'], 75.0);

    final prnt = usarSegundoCalcario
        ? CalcarioFormula.calcularPRNTPonderado(
            prnt1: prnt1,
            prnt2: prnt2,
            proporcao1: proporcao1,
            proporcao2: proporcao2,
          )
        : prnt1;
    if (prnt <= 0) {
      throw StateError('PRNT inválido na calibração.');
    }

    final caO = usarSegundoCalcario
        ? ((proporcao1 / 100.0) * caO1) + ((proporcao2 / 100.0) * caO2)
        : caO1;
    final mgO = usarSegundoCalcario
        ? ((proporcao1 / 100.0) * mgO1) + ((proporcao2 / 100.0) * mgO2)
        : mgO1;

    final profundidadeCm = _profundidade(corretivos);
    final fatorProfundidade = CalcarioFormula.fatorProfundidade(profundidadeCm);
    final superficieContato = _asNum(corretivos['sc'], 1.0);
    final vAtual = _required(analise.vPercent, 'V% atual');

    late final double ncBase;
    late final double doseFinalTHa;
    double? vAlvo;
    double? y;

    if (metodo.startsWith('①')) {
      final ctc = _required(analise.ctc, 'CTC');
      vAlvo = _numOrNull(corretivos['v2']) ??
          _v2Padrao(calibracao.cultura, analise.materiaOrganica);
      if (vAtual >= vAlvo) {
        ncBase = 0.0;
        doseFinalTHa = 0.0;
      } else {
        ncBase = ((vAlvo - vAtual) * ctc) / 100.0;
        doseFinalTHa = CalcarioFormula.metodoV(
              CalcarioInput(
                vd: vAlvo,
                va: vAtual,
                ctcPh7: ctc,
                prnt: prnt,
                profundidade: profundidadeCm,
              ),
            ).ncToneladas /
            superficieContato;
      }
    } else if (metodo.startsWith('②')) {
      final hAl = _required(analise.hAl, 'H+Al');
      final fatorHAl = _asNum(corretivos['fatorHAl'], 0.5);
      ncBase = hAl * fatorHAl;
      doseFinalTHa = CalcarioFormula.metodoEmbrapa(
        hAl: hAl,
        fator: fatorHAl,
        prnt: prnt,
        profundidadeCm: profundidadeCm,
        sc: superficieContato,
      );
    } else if (metodo.startsWith('③')) {
      final ca = _required(analise.ca, 'Ca');
      final mg = _required(analise.mg, 'Mg');
      ncBase = ca + mg;
      doseFinalTHa = CalcarioFormula.metodoCaMg(
        caAtual: ca,
        mgAtual: mg,
        prnt: prnt,
        profundidadeCm: profundidadeCm,
        sc: superficieContato,
      );
    } else if (metodo.startsWith('④')) {
      ncBase = _asNum(corretivos['doseFixa'], 1.75);
      doseFinalTHa = CalcarioFormula.metodoSupercalagem(
        doseFixa: ncBase,
        prnt: prnt,
        profundidadeCm: profundidadeCm,
        sc: superficieContato,
      );
    } else if (metodo.startsWith('⑤')) {
      final ctc = _required(analise.ctc, 'CTC');
      final ca = _required(analise.ca, 'Ca');
      final mg = _required(analise.mg, 'Mg');
      final k = _required(analise.k, 'K');
      final pctCaAlvo = _asNum(albrecht['caAlvo'], 65.0);
      final pctMgAlvo = _asNum(albrecht['mgAlvo'], 15.0);
      final pctKAlvo = _asNum(albrecht['kAlvo'], 4.0);
      vAlvo = pctCaAlvo + pctMgAlvo + pctKAlvo;
      ncBase = CalcarioFormula.metodoAlbrecht(
        ctc: ctc,
        caAtual: ca,
        mgAtual: mg,
        kAtual: k,
        pctCaAlvo: pctCaAlvo,
        pctMgAlvo: pctMgAlvo,
        pctKAlvo: pctKAlvo,
        caO: caO,
        prnt: 100.0,
        profundidadeCm: 20.0,
        sc: 1.0,
        pisoCaCmolc: _asNum(albrecht['ncCa'], 2.0),
        pisoMgCmolc: _asNum(albrecht['ncMg'], 0.8),
        pisoKCmolc: _asNum(albrecht['ncK'], 0.15),
      );
      doseFinalTHa = CalcarioFormula.metodoAlbrecht(
        ctc: ctc,
        caAtual: ca,
        mgAtual: mg,
        kAtual: k,
        pctCaAlvo: pctCaAlvo,
        pctMgAlvo: pctMgAlvo,
        pctKAlvo: pctKAlvo,
        caO: caO,
        prnt: prnt,
        profundidadeCm: profundidadeCm,
        sc: superficieContato,
        pisoCaCmolc: _asNum(albrecht['ncCa'], 2.0),
        pisoMgCmolc: _asNum(albrecht['ncMg'], 0.8),
        pisoKCmolc: _asNum(albrecht['ncK'], 0.15),
      );
    } else if (metodo.startsWith('⑥')) {
      final ctc = _required(analise.ctc, 'CTC');
      final ca = _required(analise.ca, 'Ca');
      final mg = _required(analise.mg, 'Mg');
      final k = _required(analise.k, 'K');
      final pctCaAlvo = _asNum(albrecht['caAlvo'], 65.0);
      final pctMgAlvo = _asNum(albrecht['mgAlvo'], 15.0);
      final pctKAlvo = _asNum(albrecht['kAlvo'], 4.0);
      vAlvo = pctCaAlvo + pctMgAlvo + pctKAlvo;
      y = CalcarioFormula.calcularYCriterio(
        argilaPercent: analise.argila,
        prem: analise.pRem,
      );
      if (y <= 0) {
        throw StateError('Argila ou P-rem ausente para calcular o Y.');
      }
      final ncAlbrecht = CalcarioFormula.metodoAlbrecht(
        ctc: ctc,
        caAtual: ca,
        mgAtual: mg,
        kAtual: k,
        pctCaAlvo: pctCaAlvo,
        pctMgAlvo: pctMgAlvo,
        pctKAlvo: pctKAlvo,
        caO: caO,
        prnt: 100.0,
        profundidadeCm: 20.0,
        sc: 1.0,
        pisoCaCmolc: _asNum(albrecht['ncCa'], 2.0),
        pisoMgCmolc: _asNum(albrecht['ncMg'], 0.8),
        pisoKCmolc: _asNum(albrecht['ncK'], 0.15),
      );
      ncBase = ncAlbrecht > y ? ncAlbrecht : y;
      doseFinalTHa = CalcarioFormula.aplicarCorrecoes(
        ncBase: ncBase,
        profundidadeCm: profundidadeCm,
        prnt: prnt,
        sc: superficieContato,
      ).doseFinal;
    } else if (metodo.startsWith('⑦')) {
      final mgAtual = _required(analise.mg, 'Mg');
      final mgDesejado = _asNum(corretivos['mgDesejado'], 0.8);
      final fatorMgCalcario = usarSegundoCalcario
          ? ((proporcao1 / 100.0) * CalcarioFormula.fatorMg(mgO: mgO1)) +
              ((proporcao2 / 100.0) * CalcarioFormula.fatorMg(mgO: mgO2))
          : CalcarioFormula.fatorMg(mgO: mgO);
      if (fatorMgCalcario <= 0) {
        throw StateError('MgO inválido para o método Correção Mg.');
      }
      ncBase =
          (mgDesejado - mgAtual).clamp(0.0, double.infinity) / fatorMgCalcario;
      doseFinalTHa = CalcarioFormula.metodoCorrecaoMg(
        mgDesejado: mgDesejado,
        mgAtual: mgAtual,
        fatorMgCalcario: fatorMgCalcario,
        prnt: prnt,
        profundidadeCm: profundidadeCm,
        sc: superficieContato,
      );
    } else if (metodo.startsWith('⑧') || metodo.contains('CA+CD')) {
      final al = _required(analise.al, 'Al');
      final ca = _required(analise.ca, 'Ca');
      final mg = _required(analise.mg, 'Mg');
      final ncCa =
          _numOrNull(corretivos['ncCa']) ?? _asNum(albrecht['ncCa'], 2.0);
      final ncMg =
          _numOrNull(corretivos['ncMg']) ?? _asNum(albrecht['ncMg'], 0.8);
      final bruto = CalcarioFormula.calcularNcCaCd(
        al3: al,
        ca2: ca,
        mg2: mg,
        ncCa: ncCa,
        ncMg: ncMg,
        argilaPercent: analise.argila,
        prem: analise.pRem,
      );
      y = bruto.y;
      ncBase = bruto.nc;
      doseFinalTHa = CalcarioFormula.aplicarCorrecoes(
        ncBase: ncBase,
        profundidadeCm: profundidadeCm,
        prnt: prnt,
        sc: superficieContato,
      ).doseFinal;
    } else {
      throw StateError('Método de calagem não suportado: $metodo');
    }

    return CalculoCalagemResultado(
      metodo: metodo,
      referencia: referencia,
      tipoCalcario: tipoCalcario,
      doseFinalTHa: doseFinalTHa,
      ncBase: ncBase,
      profundidadeCm: profundidadeCm,
      fatorProfundidade: fatorProfundidade,
      prnt: prnt,
      superficieContato: superficieContato,
      vAtual: vAtual,
      vAlvo: vAlvo,
      y: y,
      usaSegundoCalcario: usarSegundoCalcario,
      resumoCalculo: _resumo(
        metodo: metodo,
        vAlvo: vAlvo,
        y: y,
        prnt: prnt,
        profundidadeCm: profundidadeCm,
        superficieContato: superficieContato,
      ),
    );
  }

  static double _v2Padrao(String cultura, double? materiaOrganica) {
    final mo = materiaOrganica ?? 0.0;
    final moAlta = mo > 4.0;
    final culturaNormalizada = cultura.toLowerCase();
    if (culturaNormalizada.contains('soja')) return moAlta ? 65.0 : 70.0;
    if (culturaNormalizada.contains('milho')) return moAlta ? 60.0 : 70.0;
    if (culturaNormalizada.contains('feij')) return moAlta ? 60.0 : 70.0;
    if (culturaNormalizada.contains('algod')) return moAlta ? 65.0 : 70.0;
    return moAlta ? 55.0 : 65.0;
  }

  static double _profundidade(Map<String, dynamic> corretivos) {
    final metodo = _asString(
      corretivos['metodoIncorporacao'],
      'Sem incorporação',
    );
    if (metodo.contains('Grade')) {
      return CalcarioFormula.profundidadePorGrade(
        diametroPol: _asNum(corretivos['diametroGradePol'], 32.0),
        folgaMancalCm: _asNum(corretivos['folgaMancal'], 25.0),
      );
    }
    return _asNum(corretivos['profundidadeManual'], 20.0);
  }

  static String _resumo({
    required String metodo,
    required double? vAlvo,
    required double? y,
    required double prnt,
    required double profundidadeCm,
    required double superficieContato,
  }) {
    final buffer = StringBuffer();
    buffer.write('PRNT ${prnt.toStringAsFixed(1)}%');
    buffer.write(' · Prof. ${profundidadeCm.toStringAsFixed(1)} cm');
    buffer.write(' · SC ${superficieContato.toStringAsFixed(2)}');
    if (vAlvo != null) {
      buffer.write(' · V alvo ${vAlvo.toStringAsFixed(1)}%');
    }
    if (y != null && metodo.startsWith('⑥')) {
      buffer.write(' · Y ${y.toStringAsFixed(2)}');
    }
    return buffer.toString();
  }

  static double _required(double? value, String field) {
    if (value == null) {
      throw StateError('$field ausente na análise para calcular a calagem.');
    }
    return value;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }

  static String _asString(dynamic value, String fallback) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return fallback;
    return text;
  }

  static double _asNum(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return fallback;
  }

  static double? _numOrNull(dynamic value) {
    return value is num ? value.toDouble() : null;
  }

  static bool _asBool(dynamic value) {
    return value is bool ? value : false;
  }
}
