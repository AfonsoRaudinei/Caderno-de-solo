import 'package:soloforte/domain/formulas/potassio_formula.dart';
import 'package:soloforte/domain/mappers/analise_mapper.dart';
import 'package:soloforte/domain/services/recommendation_input_normalizer.dart';
import 'package:soloforte/domain/utils/unidade_converter.dart';
import 'package:soloforte/domain/models/diagnostico_recomendacao.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/config/presentation/calculos/analise_normalizada.dart';

class CalculosNormalizador {
  const CalculosNormalizador();

  AnaliseNormalizada normalizar(
    AnaliseSolo analise, {
    required String label,
    required int index,
  }) {
    final effectiveLabel = label.trim().isEmpty ? 'Amostra $index' : label;
    final completa = AnaliseMapper.fromSolo(analise);
    final recomendacao = const RecommendationInputNormalizer().normalize(
      analise: completa,
    );
    final isExata = _ehExata(analise);

    final k = _valorNumerico(
          raw: analise.k,
          fallback: recomendacao.entity.k,
          status: recomendacao.status['K'],
        ) ??
        _kDerivadoPorMgDm3(analise);
    final ca = _valorNumerico(
      raw: analise.ca,
      fallback: recomendacao.entity.ca,
      status: recomendacao.status['Ca'],
    );
    final mg = _valorNumerico(
      raw: analise.mg,
      fallback: recomendacao.entity.mg,
      status: recomendacao.status['Mg'],
    );
    final al = _valorNumerico(
      raw: analise.al,
      fallback: recomendacao.entity.al,
      status: recomendacao.status['Al'],
    );
    final hAl = _valorNumerico(
          raw: analise.hMaisAl,
          fallback: recomendacao.entity.hAl,
          status: recomendacao.status['H+Al'],
        ) ??
        _derivarHAl(analise.ctc, analise.sb, ca, mg, k);
    final na = _valorNumerico(
      raw: analise.na,
      fallback: null,
      status: recomendacao.status['Na'],
    );

    final sb = _valorOpcional(
      analise.sb,
      _somarBases(ca: ca, mg: mg, k: k, na: na),
    );
    final ctcEfetiva = _valorOpcional(
      analise.ctcEfetiva,
      _derivarCtcEfetiva(sb, al),
    );
    final ctc = _valorOpcional(
      analise.ctc,
      _derivarCtc(sb, hAl),
    );
    final vPercent = _valorOpcional(
      analise.vPercent,
      _derivarPercentual(sb, ctc),
    );
    final mPercent = _valorOpcional(
      analise.mPercent,
      _derivarPercentual(al, ctcEfetiva),
    );

    final argila = _valorNumerico(
      raw: analise.argila == null
          ? null
          : UnidadeConverter.normalizarGranulometria(analise.argila!, 'g/kg'),
      fallback: recomendacao.entity.argila,
      status: recomendacao.status['Argila'],
    );
    final silte = _normalizarGranulometria(analise.silte);
    final areiaTotal = _normalizarGranulometria(analise.areiaTotal);
    final classificacaoTextura = _classificacaoTextural(
      analise.classificacaoTextura,
      argila,
    );

    final phAgua = analise.phAgua;
    final phSmp = analise.phSmp;
    final phCaCl2 = analise.phCaCl2;
    final materiaOrganica = _valorNumerico(
      raw: analise.materiaOrganica,
      fallback: recomendacao.entity.mo,
      status: recomendacao.status['MO'],
    );
    final carbonoOrganico = analise.carbonoOrganico;
    final pMehlich = _valorNumerico(
      raw: analise.pMehlich,
      fallback: recomendacao.entity.pMehlich,
      status: recomendacao.status['PMehlich'],
    );
    final pResina = _valorNumerico(
      raw: analise.pResina,
      fallback: recomendacao.entity.pResina,
      status: recomendacao.status['PResina'],
    );
    final pRem = _valorNumerico(
      raw: analise.pRem,
      fallback: recomendacao.entity.pRem,
      status: recomendacao.status['PRem'],
    );
    final s020 = _valorNumerico(
      raw: analise.s020,
      fallback: recomendacao.entity.s,
      status: recomendacao.status['S020'],
    );
    final s2040 = _valorNumerico(
      raw: analise.s2040,
      fallback: recomendacao.entity.s2040,
      status: recomendacao.status['S2040'],
    );
    final b = _valorNumerico(
      raw: analise.b,
      fallback: recomendacao.entity.b,
      status: recomendacao.status['B'],
    );
    final cu = _valorNumerico(
      raw: analise.cu,
      fallback: recomendacao.entity.cu,
      status: recomendacao.status['Cu'],
    );
    final fe = _valorNumerico(
      raw: analise.fe,
      fallback: recomendacao.entity.fe,
      status: recomendacao.status['Fe'],
    );
    final mn = _valorNumerico(
      raw: analise.mn,
      fallback: recomendacao.entity.mn,
      status: recomendacao.status['Mn'],
    );
    final zn = _valorNumerico(
      raw: analise.zn,
      fallback: recomendacao.entity.zn,
      status: recomendacao.status['Zn'],
    );
    final cuMehlich = analise.cuMehlich;
    final feMehlich = analise.feMehlich;
    final mnMehlich = analise.mnMehlich;
    final znMehlich = analise.znMehlich;
    final ni = _valorNumerico(
      raw: analise.ni,
      fallback: null,
      status: recomendacao.status['Ni'],
    );
    final molibdenio = _valorNumerico(
      raw: analise.mo,
      fallback: recomendacao.entity.mo,
      status: recomendacao.status['Mo'],
    );
    final se = _valorNumerico(
      raw: analise.se,
      fallback: null,
      status: recomendacao.status['Se'],
    );
    final co = _valorNumerico(
      raw: analise.co,
      fallback: null,
      status: recomendacao.status['Co'],
    );

    final cuDtpa = analise.cuDtpa;
    final feDtpa = analise.feDtpa;
    final mnDtpa = analise.mnDtpa;
    final znDtpa = analise.znDtpa;
    final kMgDm3 = _kMgDm3(analise, k, isExata: isExata);

    return AnaliseNormalizada(
      id: analise.id,
      label: effectiveLabel,
      talhao: analise.talhao,
      laboratorio: analise.laboratorio,
      phAgua: phAgua,
      phSmp: phSmp,
      phCaCl2: phCaCl2,
      materiaOrganica: materiaOrganica,
      carbonoOrganico: carbonoOrganico,
      pMehlich: pMehlich,
      pResina: pResina,
      pRem: pRem,
      k: k,
      kMgDm3: kMgDm3,
      ca: ca,
      mg: mg,
      al: al,
      hAl: hAl,
      na: na,
      sb: sb,
      ctc: ctc,
      ctcEfetiva: ctcEfetiva,
      vPercent: vPercent,
      mPercent: mPercent,
      caMgRel: _ratio(ca, mg),
      caKRel: _ratio(ca, k),
      mgKRel: _ratio(mg, k),
      s020: s020,
      s2040: s2040,
      b: b,
      cu: cu,
      fe: fe,
      mn: mn,
      zn: zn,
      cuMehlich: cuMehlich,
      feMehlich: feMehlich,
      mnMehlich: mnMehlich,
      znMehlich: znMehlich,
      cuDtpa: cuDtpa,
      feDtpa: feDtpa,
      mnDtpa: mnDtpa,
      znDtpa: znDtpa,
      ni: ni,
      molibdenio: molibdenio,
      se: se,
      co: co,
      argila: argila,
      silte: silte,
      areiaTotal: areiaTotal,
      classificacaoTextura: classificacaoTextura,
    );
  }

  AnaliseNormalizada calcularMedia(List<AnaliseNormalizada> analises) {
    if (analises.isEmpty) {
      return const AnaliseNormalizada(
        id: 'media',
        label: 'Média',
        talhao: 'Média',
        laboratorio: 'Média',
      );
    }

    double? mediaNumerica(Iterable<double?> valores) {
      final validos = valores.whereType<double>().toList(growable: false);
      if (validos.isEmpty) return null;
      final soma = validos.fold<double>(0.0, (acc, valor) => acc + valor);
      return soma / validos.length;
    }

    String? primeiroTexto(Iterable<String?> valores) {
      for (final valor in valores) {
        final texto = valor?.trim();
        if (texto != null && texto.isNotEmpty) return texto;
      }
      return null;
    }

    final mediaArgila = mediaNumerica(analises.map((a) => a.argila));
    final classificacao = primeiroTexto(
          analises.map((a) => a.classificacaoTextura),
        ) ??
        _classificacaoTextural(null, mediaArgila);

    return AnaliseNormalizada(
      id: 'media',
      label: 'Média',
      talhao: 'Média',
      laboratorio: primeiroTexto(analises.map((a) => a.laboratorio)) ?? 'Média',
      phAgua: mediaNumerica(analises.map((a) => a.phAgua)),
      phSmp: mediaNumerica(analises.map((a) => a.phSmp)),
      phCaCl2: mediaNumerica(analises.map((a) => a.phCaCl2)),
      materiaOrganica: mediaNumerica(analises.map((a) => a.materiaOrganica)),
      carbonoOrganico: mediaNumerica(analises.map((a) => a.carbonoOrganico)),
      pMehlich: mediaNumerica(analises.map((a) => a.pMehlich)),
      pResina: mediaNumerica(analises.map((a) => a.pResina)),
      pRem: mediaNumerica(analises.map((a) => a.pRem)),
      k: mediaNumerica(analises.map((a) => a.k)),
      kMgDm3: mediaNumerica(analises.map((a) => a.kMgDm3)),
      ca: mediaNumerica(analises.map((a) => a.ca)),
      mg: mediaNumerica(analises.map((a) => a.mg)),
      al: mediaNumerica(analises.map((a) => a.al)),
      hAl: mediaNumerica(analises.map((a) => a.hAl)),
      na: mediaNumerica(analises.map((a) => a.na)),
      sb: mediaNumerica(analises.map((a) => a.sb)),
      ctc: mediaNumerica(analises.map((a) => a.ctc)),
      ctcEfetiva: mediaNumerica(analises.map((a) => a.ctcEfetiva)),
      vPercent: mediaNumerica(analises.map((a) => a.vPercent)),
      mPercent: mediaNumerica(analises.map((a) => a.mPercent)),
      caMgRel: mediaNumerica(analises.map((a) => a.caMgRel)),
      caKRel: mediaNumerica(analises.map((a) => a.caKRel)),
      mgKRel: mediaNumerica(analises.map((a) => a.mgKRel)),
      s020: mediaNumerica(analises.map((a) => a.s020)),
      s2040: mediaNumerica(analises.map((a) => a.s2040)),
      b: mediaNumerica(analises.map((a) => a.b)),
      cu: mediaNumerica(analises.map((a) => a.cu)),
      fe: mediaNumerica(analises.map((a) => a.fe)),
      mn: mediaNumerica(analises.map((a) => a.mn)),
      zn: mediaNumerica(analises.map((a) => a.zn)),
      cuMehlich: mediaNumerica(analises.map((a) => a.cuMehlich)),
      feMehlich: mediaNumerica(analises.map((a) => a.feMehlich)),
      mnMehlich: mediaNumerica(analises.map((a) => a.mnMehlich)),
      znMehlich: mediaNumerica(analises.map((a) => a.znMehlich)),
      cuDtpa: mediaNumerica(analises.map((a) => a.cuDtpa)),
      feDtpa: mediaNumerica(analises.map((a) => a.feDtpa)),
      mnDtpa: mediaNumerica(analises.map((a) => a.mnDtpa)),
      znDtpa: mediaNumerica(analises.map((a) => a.znDtpa)),
      ni: mediaNumerica(analises.map((a) => a.ni)),
      molibdenio: mediaNumerica(analises.map((a) => a.molibdenio)),
      se: mediaNumerica(analises.map((a) => a.se)),
      co: mediaNumerica(analises.map((a) => a.co)),
      argila: mediaArgila,
      silte: mediaNumerica(analises.map((a) => a.silte)),
      areiaTotal: mediaNumerica(analises.map((a) => a.areiaTotal)),
      classificacaoTextura: classificacao,
    );
  }

  double? _valorNumerico({
    required double? raw,
    required double? fallback,
    required StatusNutriente? status,
  }) {
    if (raw != null) return raw;
    if (status == StatusNutriente.ok) return fallback;
    return null;
  }

  double? _valorOpcional(double? raw, double? derived) {
    if (raw != null) return raw;
    return derived;
  }

  double? _somarBases({
    required double? ca,
    required double? mg,
    required double? k,
    required double? na,
  }) {
    if (ca == null || mg == null || k == null) return null;
    return ca + mg + k + (na ?? 0.0);
  }

  double? _derivarHAl(
    double? ctc,
    double? sb,
    double? ca,
    double? mg,
    double? k,
  ) {
    if (ctc != null && sb != null) {
      return (ctc - sb).clamp(0.0, double.infinity);
    }
    if (ca != null && mg != null && k != null) {
      return null;
    }
    return null;
  }

  double? _derivarCtc(double? sb, double? hAl) {
    if (sb == null || hAl == null) return null;
    return sb + hAl;
  }

  double? _derivarCtcEfetiva(double? sb, double? al) {
    if (sb == null || al == null) return null;
    return sb + al;
  }

  double? _derivarPercentual(double? numerador, double? denominador) {
    if (numerador == null || denominador == null || denominador <= 0) {
      return null;
    }
    return (numerador / denominador) * 100.0;
  }

  double? _ratio(double? numerador, double? denominador) {
    if (numerador == null || denominador == null || denominador <= 0) {
      return null;
    }
    return numerador / denominador;
  }

  double? _normalizarGranulometria(double? valor) {
    if (valor == null) return null;
    return UnidadeConverter.normalizarGranulometria(valor, 'g/kg');
  }

  double? _kDerivadoPorMgDm3(AnaliseSolo analise) {
    if (analise.kMgDm3 == null) return null;
    return analise.kMgDm3! / 391.0;
  }

  double? _kMgDm3(
    AnaliseSolo analise,
    double? k, {
    required bool isExata,
  }) {
    if (analise.kMgDm3 != null) return analise.kMgDm3;
    if (isExata && k != null) {
      return k * 391.0;
    }
    return null;
  }

  bool _ehExata(AnaliseSolo analise) {
    final id = analise.labTemplateId?.toLowerCase() ?? '';
    final laboratorio = analise.laboratorio.toLowerCase();
    return id.contains('exata') || laboratorio.contains('exata');
  }

  String? _classificacaoTextural(String? existente, double? argilaPercent) {
    final texto = existente?.trim();
    if (texto != null && texto.isNotEmpty) return texto;
    if (argilaPercent == null) return null;

    final classe = PotassioFormula.classeTextural(argilaPercent);
    switch (classe) {
      case 'arenoso':
        return 'Arenoso';
      case 'medio':
        return 'Médio';
      case 'argiloso':
        return 'Argiloso';
      case 'muito_argiloso':
        return 'Muito argiloso';
      default:
        return classe;
    }
  }
}
