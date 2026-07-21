class AnaliseNormalizada {
  const AnaliseNormalizada({
    required this.id,
    required this.label,
    required this.talhao,
    required this.laboratorio,
    this.phAgua,
    this.phSmp,
    this.phCaCl2,
    this.materiaOrganica,
    this.carbonoOrganico,
    this.pMehlich,
    this.pResina,
    this.pRem,
    this.k,
    this.kMgDm3,
    this.ca,
    this.mg,
    this.al,
    this.hAl,
    this.na,
    this.sb,
    this.ctc,
    this.ctcEfetiva,
    this.vPercent,
    this.mPercent,
    this.caMgRel,
    this.caKRel,
    this.mgKRel,
    this.s020,
    this.s2040,
    this.b,
    this.cu,
    this.fe,
    this.mn,
    this.zn,
    this.cuMehlich,
    this.feMehlich,
    this.mnMehlich,
    this.znMehlich,
    this.cuDtpa,
    this.feDtpa,
    this.mnDtpa,
    this.znDtpa,
    this.ni,
    this.molibdenio,
    this.se,
    this.co,
    this.argila,
    this.silte,
    this.areiaTotal,
    this.classificacaoTextura,
  });

  final String id;
  final String label;
  final String talhao;
  final String laboratorio;

  final double? phAgua;
  final double? phSmp;
  final double? phCaCl2;

  final double? materiaOrganica;
  final double? carbonoOrganico;

  final double? pMehlich;
  final double? pResina;
  final double? pRem;

  final double? k;
  final double? kMgDm3;
  final double? ca;
  final double? mg;
  final double? al;
  final double? hAl;
  final double? na;
  final double? sb;
  final double? ctc;
  final double? ctcEfetiva;
  final double? vPercent;
  final double? mPercent;
  final double? caMgRel;
  final double? caKRel;
  final double? mgKRel;

  final double? s020;
  final double? s2040;

  final double? b;
  final double? cu;
  final double? fe;
  final double? mn;
  final double? zn;
  final double? cuMehlich;
  final double? feMehlich;
  final double? mnMehlich;
  final double? znMehlich;
  final double? cuDtpa;
  final double? feDtpa;
  final double? mnDtpa;
  final double? znDtpa;
  final double? ni;
  final double? molibdenio;
  final double? se;
  final double? co;

  final double? argila;
  final double? silte;
  final double? areiaTotal;
  final String? classificacaoTextura;

  bool get hasTextura =>
      argila != null ||
      silte != null ||
      areiaTotal != null ||
      (classificacaoTextura?.trim().isNotEmpty ?? false);

  AnaliseNormalizada copyWith({
    String? id,
    String? label,
    String? talhao,
    String? laboratorio,
    double? phAgua,
    double? phSmp,
    double? phCaCl2,
    double? materiaOrganica,
    double? carbonoOrganico,
    double? pMehlich,
    double? pResina,
    double? pRem,
    double? k,
    double? kMgDm3,
    double? ca,
    double? mg,
    double? al,
    double? hAl,
    double? na,
    double? sb,
    double? ctc,
    double? ctcEfetiva,
    double? vPercent,
    double? mPercent,
    double? caMgRel,
    double? caKRel,
    double? mgKRel,
    double? s020,
    double? s2040,
    double? b,
    double? cu,
    double? fe,
    double? mn,
    double? zn,
    double? cuMehlich,
    double? feMehlich,
    double? mnMehlich,
    double? znMehlich,
    double? cuDtpa,
    double? feDtpa,
    double? mnDtpa,
    double? znDtpa,
    double? ni,
    double? molibdenio,
    double? se,
    double? co,
    double? argila,
    double? silte,
    double? areiaTotal,
    String? classificacaoTextura,
  }) {
    return AnaliseNormalizada(
      id: id ?? this.id,
      label: label ?? this.label,
      talhao: talhao ?? this.talhao,
      laboratorio: laboratorio ?? this.laboratorio,
      phAgua: phAgua ?? this.phAgua,
      phSmp: phSmp ?? this.phSmp,
      phCaCl2: phCaCl2 ?? this.phCaCl2,
      materiaOrganica: materiaOrganica ?? this.materiaOrganica,
      carbonoOrganico: carbonoOrganico ?? this.carbonoOrganico,
      pMehlich: pMehlich ?? this.pMehlich,
      pResina: pResina ?? this.pResina,
      pRem: pRem ?? this.pRem,
      k: k ?? this.k,
      kMgDm3: kMgDm3 ?? this.kMgDm3,
      ca: ca ?? this.ca,
      mg: mg ?? this.mg,
      al: al ?? this.al,
      hAl: hAl ?? this.hAl,
      na: na ?? this.na,
      sb: sb ?? this.sb,
      ctc: ctc ?? this.ctc,
      ctcEfetiva: ctcEfetiva ?? this.ctcEfetiva,
      vPercent: vPercent ?? this.vPercent,
      mPercent: mPercent ?? this.mPercent,
      caMgRel: caMgRel ?? this.caMgRel,
      caKRel: caKRel ?? this.caKRel,
      mgKRel: mgKRel ?? this.mgKRel,
      s020: s020 ?? this.s020,
      s2040: s2040 ?? this.s2040,
      b: b ?? this.b,
      cu: cu ?? this.cu,
      fe: fe ?? this.fe,
      mn: mn ?? this.mn,
      zn: zn ?? this.zn,
      cuMehlich: cuMehlich ?? this.cuMehlich,
      feMehlich: feMehlich ?? this.feMehlich,
      mnMehlich: mnMehlich ?? this.mnMehlich,
      znMehlich: znMehlich ?? this.znMehlich,
      cuDtpa: cuDtpa ?? this.cuDtpa,
      feDtpa: feDtpa ?? this.feDtpa,
      mnDtpa: mnDtpa ?? this.mnDtpa,
      znDtpa: znDtpa ?? this.znDtpa,
      ni: ni ?? this.ni,
      molibdenio: molibdenio ?? this.molibdenio,
      se: se ?? this.se,
      co: co ?? this.co,
      argila: argila ?? this.argila,
      silte: silte ?? this.silte,
      areiaTotal: areiaTotal ?? this.areiaTotal,
      classificacaoTextura: classificacaoTextura ?? this.classificacaoTextura,
    );
  }
}
