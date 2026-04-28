import 'package:soloforte/domain/value_objects/valor_nutriente.dart';

enum ExtratorP { mehlich, resina }

class AnaliseCompleta {
  const AnaliseCompleta({
    required this.id,
    required this.fazenda,
    required this.produtor,
    required this.talhao,
    required this.cultura,
    required this.laboratorio,
    required this.dataCadastro,
    required this.phAgua,
    required this.phSmp,
    required this.phCaCl2,
    required this.materiaOrganica,
    required this.argila,
    required this.pMehlich,
    required this.pResina,
    required this.pRem,
    required this.k,
    required this.ca,
    required this.mg,
    required this.al,
    required this.hAl,
    required this.na,
    required this.s020,
    required this.s2040,
    required this.b,
    required this.cu,
    required this.fe,
    required this.mn,
    required this.zn,
    required this.ni,
    required this.mo,
    required this.se,
    required this.co,
    this.descricaoLocal,
    this.extratorP,
  });

  final String id;
  final String fazenda;
  final String produtor;
  final String talhao;
  final String cultura;
  final String laboratorio;
  final DateTime dataCadastro;
  final String? descricaoLocal;

  final ValorNutriente phAgua;
  final ValorNutriente phSmp;
  final ValorNutriente phCaCl2;
  final ValorNutriente materiaOrganica;
  final ValorNutriente argila;

  final ValorNutriente pMehlich;
  final ValorNutriente pResina;
  final ValorNutriente pRem;
  final ExtratorP? extratorP;

  final ValorNutriente k;
  final ValorNutriente ca;
  final ValorNutriente mg;
  final ValorNutriente al;
  final ValorNutriente hAl;
  final ValorNutriente na;

  final ValorNutriente s020;
  final ValorNutriente s2040;

  final ValorNutriente b;
  final ValorNutriente cu;
  final ValorNutriente fe;
  final ValorNutriente mn;
  final ValorNutriente zn;
  final ValorNutriente ni;
  final ValorNutriente mo;
  final ValorNutriente se;
  final ValorNutriente co;

  ValorNutriente get phPrincipal {
    if (phAgua.isValido) return phAgua;
    if (phCaCl2.isValido) return phCaCl2;
    if (phSmp.isValido) return phSmp;
    return const ValorNutriente(valor: null, analisado: false);
  }
}
