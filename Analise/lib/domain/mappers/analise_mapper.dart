import 'package:soloforte/domain/entities/analise_completa.dart';
import 'package:soloforte/domain/value_objects/valor_nutriente.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

class AnaliseMapper {
  const AnaliseMapper._();

  static AnaliseCompleta fromSolo(AnaliseSolo analise) {
    return AnaliseCompleta(
      id: analise.id,
      fazenda: analise.fazenda,
      produtor: analise.produtor,
      talhao: analise.talhao,
      cultura: analise.cultura.label,
      laboratorio: analise.laboratorio,
      dataCadastro: analise.dataCadastro,
      descricaoLocal: analise.descricaoLocal,
      phAgua: _valor(analise.phAgua),
      phSmp: _valor(analise.phSmp),
      phCaCl2: _valor(analise.phCaCl2),
      materiaOrganica: _valor(analise.materiaOrganica),
      argila: _valor(_toArgilaPercent(analise.argila)),
      pMehlich: _valor(analise.pMehlich),
      pResina: _valor(analise.pResina),
      pRem: _valor(analise.pRem),
      extratorP: _resolverExtrator(analise),
      k: _valor(analise.k),
      ca: _valor(analise.ca),
      mg: _valor(analise.mg),
      al: _valor(analise.al),
      hAl: _valor(analise.hMaisAl),
      na: _valor(analise.na),
      s020: _valor(analise.s020),
      s2040: _valor(analise.s2040),
      b: _valor(analise.b),
      cu: _valor(analise.cu),
      fe: _valor(analise.fe),
      mn: _valor(analise.mn),
      zn: _valor(analise.zn),
      ni: _valor(analise.ni),
      mo: _valor(analise.mo),
      se: _valor(analise.se),
      co: _valor(_parseDouble(analise.laudoMetadata?['co'])),
      sb: _valor(analise.sb),
      ctc: _valor(analise.ctc),
      vPercent: _valor(analise.vPercent),
      mPercent: _valor(analise.mPercent),
    );
  }

  static ExtratorP? _resolverExtrator(AnaliseSolo analise) {
    final metadata = analise.laudoMetadata ?? const <String, dynamic>{};
    final raw = (metadata['extratorP'] ??
            metadata['fontePrincipalP'] ??
            metadata['fonteP'] ??
            '')
        .toString()
        .trim()
        .toLowerCase();

    if (raw.contains('resina')) return ExtratorP.resina;
    if (raw.contains('mehlich')) return ExtratorP.mehlich;

    final hasMehlich = analise.pMehlich != null;
    final hasResina = analise.pResina != null;
    if (hasMehlich && !hasResina) return ExtratorP.mehlich;
    if (hasResina && !hasMehlich) return ExtratorP.resina;
    return null;
  }

  static double? _toArgilaPercent(double? argilaGKg) {
    if (argilaGKg == null) return null;
    return argilaGKg / 10.0;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.'));
    return null;
  }

  static ValorNutriente _valor(double? valor) {
    return ValorNutriente(
      valor: valor,
      analisado: valor != null,
    );
  }
}
