import 'package:flutter/material.dart';

enum Cultura { soja, milho, feijao, algodao, arroz, sorgo }

/// Estado do vínculo hierárquico Cliente → Fazenda → Talhão.
enum AnaliseVinculoStatus {
  /// Vínculo escolhido explicitamente pelo usuário.
  manual,

  /// Vínculo inferido por correspondência de nomes em registros legados.
  inferido,

  /// Sem correspondência encontrada; análise permanece acessível por strings.
  pendente,
}

extension AnaliseVinculoStatusX on AnaliseVinculoStatus {
  String get firestoreValue => name;

  static AnaliseVinculoStatus? fromFirestore(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    for (final status in AnaliseVinculoStatus.values) {
      if (status.name == value) return status;
    }
    return null;
  }
}

extension CulturaExtension on Cultura {
  String get label {
    switch (this) {
      case Cultura.soja:
        return 'Soja';
      case Cultura.milho:
        return 'Milho';
      case Cultura.feijao:
        return 'Feijão';
      case Cultura.algodao:
        return 'Algodão';
      case Cultura.arroz:
        return 'Arroz';
      case Cultura.sorgo:
        return 'Sorgo';
    }
  }

  Color get color {
    switch (this) {
      case Cultura.soja:
        return const Color(0xFF34C759);
      case Cultura.milho:
        return const Color(0xFFFF9500);
      case Cultura.feijao:
        return const Color(0xFFFF3B30);
      case Cultura.algodao:
        return const Color(0xFF007AFF);
      case Cultura.arroz:
        return const Color(0xFF5AC8FA);
      case Cultura.sorgo:
        return const Color(0xFFAF52DE);
    }
  }

  String get emoji {
    switch (this) {
      case Cultura.soja:
        return '🌱';
      case Cultura.milho:
        return '🌽';
      case Cultura.feijao:
        return '🫘';
      case Cultura.algodao:
        return '☁️';
      case Cultura.arroz:
        return '🌾';
      case Cultura.sorgo:
        return '🌿';
    }
  }
}

class AnaliseSolo {
  final String id;
  final String fazenda;
  final String produtor;
  final String talhao;
  final String numeroAmostra;
  final Cultura cultura;
  final String safra; // ex: "2025/26"
  final String laboratorio;
  final DateTime dataCadastro;
  final String profundidade; // ex: "0-20"

  // Localização (infra)
  final double? latitude;
  final double? longitude;
  final String? descricaoLocal;

  // Composição física
  final double? argila; // g/kg
  final double? silte; // g/kg
  final double? areiaTotal; // g/kg

  // pH
  final double? phAgua;
  final double? phSmp;
  final double? phCaCl2;

  // Matéria orgânica
  final double? materiaOrganica; // dag/kg
  final double? carbonoOrganico; // dag/kg

  // Fósforo
  final double? pMehlich; // mg/dm³
  final double? pResina; // mg/dm³
  final double? pRem; // mg/L

  // Enxofre
  final double? s020; // mg/dm³
  final double? s2040; // mg/dm³

  // Macronutrientes
  final double? k; // cmolc/dm³
  final double? ca; // cmolc/dm³
  final double? mg; // cmolc/dm³
  final double? al; // cmolc/dm³
  final double? hMaisAl; // cmolc/dm³
  final double? na; // cmolc/dm³

  // Micronutrientes
  final double? b;
  final double? cu;
  final double? fe;
  final double? mn;
  final double? zn;
  final double? ni;
  final double? mo;
  final double? se;
  final double? co; // Cobalto -- MB

  // Textura detalhada -- MB
  final double? cascalho;
  final double? areiaGrossa;
  final double? areiaFina;

  // Metadados adicionais
  final String? municipio;
  final String? responsavelTecnico;
  final String? cnpjCliente;

  // Campos Sellar
  final double? pTotal;
  final String? classificacaoTextura;
  final int? tipoSoloMapa;
  final String? solicitante;
  final String? convenio;
  final String? creaResponsavel;
  final String? cnpjLaboratorio;

  // Campos Solum
  final String? dataInicioEnsaio;
  final String? dataFimEnsaio;
  final String? matriculaImovel;
  final String? codigoInterno;
  final String? codigoExternoAmostra;

  // Campos Exata Brasil
  final double? caMaisMg;
  final double? kMgDm3;
  final double? cuMehlich;
  final double? feMehlich;
  final double? mnMehlich;
  final double? znMehlich;
  final double? cuDtpa;
  final double? feDtpa;
  final double? mnDtpa;
  final double? znDtpa;
  final String? dataRecebimento;
  final String? numeroRelatorio;
  final String? codigoVerificacao;
  final String? codigoTalhao;
  final int? totalAmostras;

  // Infra
  final String? pdfUrl;
  final Map<String, dynamic>? laudoMetadata;

  // Acidez detalhada
  final double? h; // Hidrogenio puro (separado de H+Al)
  final double? ctcEfetiva; // CTC efetiva (t) = SB + Al

  // Valores entregues pelo lab (extraidos, nao recalculados)
  final double? ctc;
  final double? sb;
  final double? vPercent;
  final double? mPercent;

  // Metadados do laudo
  final String? osLaboratorio;
  final String? dataEmissao;
  final String? consultor;
  final String? labTemplateId;

  // Unidades
  final String? unidadeNutrientes;
  final String? unidadeMO;
  final String? unidadeTextura;

  /// FK opcional para `clientes/{clienteId}`.
  final String? clienteId;

  /// FK opcional para `clientes/{clienteId}/fazendas/{fazendaId}`.
  final String? fazendaId;

  /// FK opcional para
  /// `clientes/{clienteId}/fazendas/{fazendaId}/talhoes/{talhaoId}`.
  final String? talhaoId;

  /// Indica como a análise foi vinculada à hierarquia de clientes.
  final AnaliseVinculoStatus? vinculoStatus;

  const AnaliseSolo({
    required this.id,
    required this.fazenda,
    required this.produtor,
    required this.talhao,
    required this.numeroAmostra,
    required this.cultura,
    required this.safra,
    required this.laboratorio,
    required this.dataCadastro,
    required this.profundidade,
    this.latitude,
    this.longitude,
    this.descricaoLocal,
    this.argila,
    this.silte,
    this.areiaTotal,
    this.phAgua,
    this.phSmp,
    this.phCaCl2,
    this.materiaOrganica,
    this.carbonoOrganico,
    this.pMehlich,
    this.pResina,
    this.pRem,
    this.s020,
    this.s2040,
    this.k,
    this.ca,
    this.mg,
    this.al,
    this.hMaisAl,
    this.na,
    this.b,
    this.cu,
    this.fe,
    this.mn,
    this.zn,
    this.ni,
    this.mo,
    this.se,
    this.co,
    this.cascalho,
    this.areiaGrossa,
    this.areiaFina,
    this.municipio,
    this.responsavelTecnico,
    this.cnpjCliente,
    this.pTotal,
    this.classificacaoTextura,
    this.tipoSoloMapa,
    this.solicitante,
    this.convenio,
    this.creaResponsavel,
    this.cnpjLaboratorio,
    // Solum
    this.dataInicioEnsaio,
    this.dataFimEnsaio,
    this.matriculaImovel,
    this.codigoInterno,
    this.codigoExternoAmostra,
    // Exata Brasil
    this.caMaisMg,
    this.kMgDm3,
    this.cuMehlich,
    this.feMehlich,
    this.mnMehlich,
    this.znMehlich,
    this.cuDtpa,
    this.feDtpa,
    this.mnDtpa,
    this.znDtpa,
    this.dataRecebimento,
    this.numeroRelatorio,
    this.codigoVerificacao,
    this.codigoTalhao,
    this.totalAmostras,
    this.pdfUrl,
    this.laudoMetadata,
    // Acidez detalhada
    this.h,
    this.ctcEfetiva,
    // Valores do laudo
    this.ctc,
    this.sb,
    this.vPercent,
    this.mPercent,
    // Metadados do laudo
    this.osLaboratorio,
    this.dataEmissao,
    this.consultor,
    this.labTemplateId,
    // Unidades
    this.unidadeNutrientes,
    this.unidadeMO,
    this.unidadeTextura,
    this.clienteId,
    this.fazendaId,
    this.talhaoId,
    this.vinculoStatus,
  });

  bool get possuiVinculoHierarquico =>
      (clienteId?.trim().isNotEmpty ?? false) &&
      (fazendaId?.trim().isNotEmpty ?? false) &&
      (talhaoId?.trim().isNotEmpty ?? false);

  AnaliseSolo copyWith({
    String? id,
    String? fazenda,
    String? produtor,
    String? talhao,
    String? numeroAmostra,
    Cultura? cultura,
    String? safra,
    String? laboratorio,
    DateTime? dataCadastro,
    String? profundidade,
    double? latitude,
    double? longitude,
    String? descricaoLocal,
    double? argila,
    double? silte,
    double? areiaTotal,
    double? phAgua,
    double? phSmp,
    double? phCaCl2,
    double? materiaOrganica,
    double? carbonoOrganico,
    double? pMehlich,
    double? pResina,
    double? pRem,
    double? s020,
    double? s2040,
    double? k,
    double? ca,
    double? mg,
    double? al,
    double? hMaisAl,
    double? na,
    double? b,
    double? cu,
    double? fe,
    double? mn,
    double? zn,
    double? ni,
    double? mo,
    double? se,
    double? co,
    double? cascalho,
    double? areiaGrossa,
    double? areiaFina,
    String? municipio,
    String? responsavelTecnico,
    String? cnpjCliente,
    double? pTotal,
    String? classificacaoTextura,
    int? tipoSoloMapa,
    String? solicitante,
    String? convenio,
    String? creaResponsavel,
    String? cnpjLaboratorio,
    String? dataInicioEnsaio,
    String? dataFimEnsaio,
    String? matriculaImovel,
    String? codigoInterno,
    String? codigoExternoAmostra,
    double? caMaisMg,
    double? kMgDm3,
    double? cuMehlich,
    double? feMehlich,
    double? mnMehlich,
    double? znMehlich,
    double? cuDtpa,
    double? feDtpa,
    double? mnDtpa,
    double? znDtpa,
    String? dataRecebimento,
    String? numeroRelatorio,
    String? codigoVerificacao,
    String? codigoTalhao,
    int? totalAmostras,
    String? pdfUrl,
    Map<String, dynamic>? laudoMetadata,
    double? h,
    double? ctcEfetiva,
    double? ctc,
    double? sb,
    double? vPercent,
    double? mPercent,
    String? osLaboratorio,
    String? dataEmissao,
    String? consultor,
    String? labTemplateId,
    String? unidadeNutrientes,
    String? unidadeMO,
    String? unidadeTextura,
    String? clienteId,
    String? fazendaId,
    String? talhaoId,
    AnaliseVinculoStatus? vinculoStatus,
  }) {
    return AnaliseSolo(
      id: id ?? this.id,
      fazenda: fazenda ?? this.fazenda,
      produtor: produtor ?? this.produtor,
      talhao: talhao ?? this.talhao,
      numeroAmostra: numeroAmostra ?? this.numeroAmostra,
      cultura: cultura ?? this.cultura,
      safra: safra ?? this.safra,
      laboratorio: laboratorio ?? this.laboratorio,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      profundidade: profundidade ?? this.profundidade,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      descricaoLocal: descricaoLocal ?? this.descricaoLocal,
      argila: argila ?? this.argila,
      silte: silte ?? this.silte,
      areiaTotal: areiaTotal ?? this.areiaTotal,
      phAgua: phAgua ?? this.phAgua,
      phSmp: phSmp ?? this.phSmp,
      phCaCl2: phCaCl2 ?? this.phCaCl2,
      materiaOrganica: materiaOrganica ?? this.materiaOrganica,
      carbonoOrganico: carbonoOrganico ?? this.carbonoOrganico,
      pMehlich: pMehlich ?? this.pMehlich,
      pResina: pResina ?? this.pResina,
      pRem: pRem ?? this.pRem,
      s020: s020 ?? this.s020,
      s2040: s2040 ?? this.s2040,
      k: k ?? this.k,
      ca: ca ?? this.ca,
      mg: mg ?? this.mg,
      al: al ?? this.al,
      hMaisAl: hMaisAl ?? this.hMaisAl,
      na: na ?? this.na,
      b: b ?? this.b,
      cu: cu ?? this.cu,
      fe: fe ?? this.fe,
      mn: mn ?? this.mn,
      zn: zn ?? this.zn,
      ni: ni ?? this.ni,
      mo: mo ?? this.mo,
      se: se ?? this.se,
      co: co ?? this.co,
      cascalho: cascalho ?? this.cascalho,
      areiaGrossa: areiaGrossa ?? this.areiaGrossa,
      areiaFina: areiaFina ?? this.areiaFina,
      municipio: municipio ?? this.municipio,
      responsavelTecnico: responsavelTecnico ?? this.responsavelTecnico,
      cnpjCliente: cnpjCliente ?? this.cnpjCliente,
      pTotal: pTotal ?? this.pTotal,
      classificacaoTextura: classificacaoTextura ?? this.classificacaoTextura,
      tipoSoloMapa: tipoSoloMapa ?? this.tipoSoloMapa,
      solicitante: solicitante ?? this.solicitante,
      convenio: convenio ?? this.convenio,
      creaResponsavel: creaResponsavel ?? this.creaResponsavel,
      cnpjLaboratorio: cnpjLaboratorio ?? this.cnpjLaboratorio,
      dataInicioEnsaio: dataInicioEnsaio ?? this.dataInicioEnsaio,
      dataFimEnsaio: dataFimEnsaio ?? this.dataFimEnsaio,
      matriculaImovel: matriculaImovel ?? this.matriculaImovel,
      codigoInterno: codigoInterno ?? this.codigoInterno,
      codigoExternoAmostra: codigoExternoAmostra ?? this.codigoExternoAmostra,
      caMaisMg: caMaisMg ?? this.caMaisMg,
      kMgDm3: kMgDm3 ?? this.kMgDm3,
      cuMehlich: cuMehlich ?? this.cuMehlich,
      feMehlich: feMehlich ?? this.feMehlich,
      mnMehlich: mnMehlich ?? this.mnMehlich,
      znMehlich: znMehlich ?? this.znMehlich,
      cuDtpa: cuDtpa ?? this.cuDtpa,
      feDtpa: feDtpa ?? this.feDtpa,
      mnDtpa: mnDtpa ?? this.mnDtpa,
      znDtpa: znDtpa ?? this.znDtpa,
      dataRecebimento: dataRecebimento ?? this.dataRecebimento,
      numeroRelatorio: numeroRelatorio ?? this.numeroRelatorio,
      codigoVerificacao: codigoVerificacao ?? this.codigoVerificacao,
      codigoTalhao: codigoTalhao ?? this.codigoTalhao,
      totalAmostras: totalAmostras ?? this.totalAmostras,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      laudoMetadata: laudoMetadata ?? this.laudoMetadata,
      h: h ?? this.h,
      ctcEfetiva: ctcEfetiva ?? this.ctcEfetiva,
      ctc: ctc ?? this.ctc,
      sb: sb ?? this.sb,
      vPercent: vPercent ?? this.vPercent,
      mPercent: mPercent ?? this.mPercent,
      osLaboratorio: osLaboratorio ?? this.osLaboratorio,
      dataEmissao: dataEmissao ?? this.dataEmissao,
      consultor: consultor ?? this.consultor,
      labTemplateId: labTemplateId ?? this.labTemplateId,
      unidadeNutrientes: unidadeNutrientes ?? this.unidadeNutrientes,
      unidadeMO: unidadeMO ?? this.unidadeMO,
      unidadeTextura: unidadeTextura ?? this.unidadeTextura,
      clienteId: clienteId ?? this.clienteId,
      fazendaId: fazendaId ?? this.fazendaId,
      talhaoId: talhaoId ?? this.talhaoId,
      vinculoStatus: vinculoStatus ?? this.vinculoStatus,
    );
  }
}
