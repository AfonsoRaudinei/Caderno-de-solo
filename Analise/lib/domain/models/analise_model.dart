import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'analise_model.freezed.dart';
part 'analise_model.g.dart';

enum FonteP {
  resina,
  mehlich,
}

@freezed
class FosforoData with _$FosforoData {
  const FosforoData._();

  const factory FosforoData({
    double? pResina,
    double? pMehlich,
    double? pRemanescente,
    @Default(FonteP.resina) FonteP fontePrincipal,
  }) = _FosforoData;

  /// Valor de P utilizado no cálculo de recomendação, respeitando a fonte
  /// principal e aplicando fallback automático para a outra fonte.
  double get valorParaCalculo {
    if (fontePrincipal == FonteP.resina) {
      return pResina ?? pMehlich ?? 0.0;
    }
    return pMehlich ?? pResina ?? 0.0;
  }

  factory FosforoData.fromJson(Map<String, dynamic> json) => FosforoData(
        pResina: (json['pResina'] ?? json['p_resina'] ?? json['resina'] as num?)
            ?.toDouble(),
        pMehlich:
            (json['pMehlich'] ?? json['p_mehlich'] ?? json['fosforo'] as num?)
                ?.toDouble(),
        pRemanescente:
            (json['pRemanescente'] ?? json['pRem'] ?? json['p_rem'] as num?)
                ?.toDouble(),
        fontePrincipal: json['fontePrincipal'] == 'resina' ||
                json['fontePrincipal'] == FonteP.resina.name
            ? FonteP.resina
            : FonteP.mehlich,
      );

  @override
  Map<String, dynamic> toJson() => {
        'pResina': pResina,
        'pMehlich': pMehlich,
        'pRemanescente': pRemanescente,
        'fontePrincipal': fontePrincipal.name,
      };
}

@freezed
class AnaliseModel with _$AnaliseModel {
  const AnaliseModel._();

  const factory AnaliseModel({
    required String id,
    required String userId,
    String? fazenda,
    String? produtor,
    String? talhao,
    @Default('') String numeroAmostra,
    @Default('') String laboratorio,
    @Default('') String profundidade,
    @Default('') String dataColeta,
    @Default('') String status,
    @Default('') String cultura,
    @Default('') String safra,
    double? latitude,
    double? longitude,
    String? descricaoLocal,
    String? pdfUrl,
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
    @Default(FonteP.mehlich) FonteP fontePrincipalP,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,

    // ── Acidez detalhada ───────────────────────────────────────────────────
    double? h,          // Hidrogenio puro (separado de H+Al)
    double? ctcEfetiva, // CTC efetiva (t) = SB + Al

    // ── Valores entregues pelo lab (NAO recalcular) ────────────────────────
    double? ctc,      // C.T.C. extraida do laudo
    double? sb,       // Soma de Bases extraida do laudo
    double? vPercent, // Saturacao por Bases V% extraida do laudo
    double? mPercent, // Saturacao por Al m% extraida do laudo

    // ── Metadados do laudo ─────────────────────────────────────────────────
    String? osLaboratorio,    // Numero da O.S. do laboratorio
    String? dataEmissao,      // Data de emissao do laudo
    String? consultor,        // Empresa consultora
    String? labTemplateId,    // ID do template usado na importacao

    // ── Unidades (para exibicao e conversao) ──────────────────────────────
    String? unidadeNutrientes, // "mmolc/dm3" ou "cmolc/dm3"
    String? unidadeMO,         // "g/dm3", "dag/kg" ou "%"
    String? unidadeTextura,    // "g/kg", "g/dm3" ou "%"

    // ── Textura detalhada (MB separa areia grossa/fina) ───────────────────
    double? cascalho,
    double? areiaGrossa,
    double? areiaFina,

    // ── Micronutrientes adicionais ─────────────────────────────────────────
    double? co,              // Cobalto (mg/dm3) -- MB

    // ── Metadados adicionais do laudo ──────────────────────────────────────
    String? municipio,
    String? responsavelTecnico,
    String? cnpjCliente,

    // ── Fosforo adicional ─────────────────────────────────────────────────
    double? pTotal,           // P Total em % -- Sellar

    // ── Textura adicional ─────────────────────────────────────────────
    String? classificacaoTextura,  // 'Media', 'Argilosa', 'Arenosa'
    int? tipoSoloMapa,             // Tipo MAPA (1, 2, 3) -- IN02/2008

    // ── Metadados adicionais Sellar ───────────────────────────────────────
    String? solicitante,
    String? convenio,
    String? creaResponsavel,
    String? cnpjLaboratorio,

    // ── Campos Solum ──────────────────────────────────────────────────────
    String? dataInicioEnsaio,       // Data de inicio dos ensaios
    String? dataFimEnsaio,          // Data de fim dos ensaios
    String? matriculaImovel,        // Matricula do imovel (SIGEF/SNCR)
    String? codigoInterno,          // Codigo interno Solum
    String? codigoExternoAmostra,   // Codigo externo da amostra

    // ── Campos Exata Brasil ───────────────────────────────────────────────
    double? caMaisMg,         // Ca+Mg somado (campo separado Exata)
    double? kMgDm3,           // K em mg/dm3 por NH4Cl (Exata)

    // Micronutrientes por Mehlich I
    double? cuMehlich,        // Cobre por Mehlich
    double? feMehlich,        // Ferro por Mehlich
    double? mnMehlich,        // Manganes por Mehlich
    double? znMehlich,        // Zinco por Mehlich

    // Micronutrientes por DTPA
    double? cuDtpa,           // Cobre por DTPA
    double? feDtpa,           // Ferro por DTPA
    double? mnDtpa,           // Manganes por DTPA
    double? znDtpa,           // Zinco por DTPA

    // Metadados adicionais do laudo (Exata)
    String? dataRecebimento,  // Data de recebimento da amostra no lab
    String? numeroRelatorio,  // No do relatorio (ex: 16738.2025.V0.U)
    String? codigoVerificacao,// Codigo de verificacao do laudo digital
    String? codigoTalhao,     // Codigo do talhao (T01, T02, 274)
    int? totalAmostras,       // Total de pontos amostrados no laudo
  }) = _AnaliseModel;

  factory AnaliseModel.fromJson(Map<String, dynamic> json) =>
      AnaliseModel(
        id: (json['id'] ?? '') as String,
        userId: (json['userId'] ?? json['user_id'] ?? '') as String,
        fazenda: (json['fazenda'] ??
                json['fazenda_nome'] ??
                json['fazendaNome'] ??
                json['propriedade'] ??
                '') as String,
        produtor: (json['produtor'] ?? '') as String,
        talhao: (json['talhao'] ??
                json['talhao_nome'] ??
                json['talhaoNome'] ??
                '') as String,
        numeroAmostra:
            (json['numeroAmostra'] ?? json['numero_amostra'] ?? '') as String,
        laboratorio: (json['laboratorio'] ?? '') as String,
        profundidade: (json['profundidade'] ?? '') as String,
        dataColeta: (json['dataColeta'] ?? json['data_coleta'] ?? '') as String,
        status: (json['status'] ?? '') as String,
        cultura: (json['cultura'] ?? '') as String,
        safra: (json['safra'] ?? '') as String,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        descricaoLocal: (json['descricao_local'] ?? json['descricaoLocal']) as String?,
        pdfUrl: (json['pdf_url'] ?? json['pdfUrl']) as String?,
        argila: (json['argila'] as num?)?.toDouble(),
        silte: (json['silte'] as num?)?.toDouble(),
        areiaTotal: (json['areiaTotal'] as num?)?.toDouble(),
        phAgua: ((json['phAgua'] ?? json['ph']) as num?)?.toDouble(),
        phSmp: (json['phSmp'] as num?)?.toDouble(),
        phCaCl2: (json['phCaCl2'] as num?)?.toDouble(),
        materiaOrganica: (json['materiaOrganica'] as num?)?.toDouble(),
        carbonoOrganico: (json['carbonoOrganico'] as num?)?.toDouble(),
        pMehlich: ((json['p_mehlich'] ?? json['pMehlich'] ?? json['fosforo'])
                as num?)
            ?.toDouble(),
        pResina: (json['pResina'] as num?)?.toDouble(),
        pRem: (json['pRem'] as num?)?.toDouble(),
        s020: (json['s020'] as num?)?.toDouble(),
        s2040: (json['s2040'] as num?)?.toDouble(),
        k: ((json['k'] ?? json['potassio']) as num?)?.toDouble(),
        ca: ((json['ca'] ?? json['calcio']) as num?)?.toDouble(),
        mg: ((json['mg'] ?? json['magnesio']) as num?)?.toDouble(),
        al: (json['al'] as num?)?.toDouble(),
        hMaisAl: (json['hMaisAl'] as num?)?.toDouble(),
        na: (json['na'] as num?)?.toDouble(),
        b: (json['b'] as num?)?.toDouble(),
        cu: (json['cu'] as num?)?.toDouble(),
        fe: (json['fe'] as num?)?.toDouble(),
        mn: (json['mn'] as num?)?.toDouble(),
        zn: (json['zn'] as num?)?.toDouble(),
        ni: (json['ni'] as num?)?.toDouble(),
        mo: (json['mo'] as num?)?.toDouble(),
        se: (json['se'] as num?)?.toDouble(),
        fontePrincipalP: json['fontePrincipalP'] == FonteP.resina.name ||
                json['fontePrincipalP'] == 'resina'
            ? FonteP.resina
            : FonteP.mehlich,
        createdAt: const TimestampConverter().fromJson(json['createdAt']),
        updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
        h: ((json['h'] ?? json['hidrogenio']) as num?)?.toDouble(),
        ctcEfetiva: ((json['ctcEfetiva'] ?? json['ctc_efetiva']) as num?)?.toDouble(),
        ctc: ((json['ctc'] ?? json['CTC'] ?? json['ctcTotal']) as num?)?.toDouble(),
        sb: ((json['sb'] ?? json['SB'] ?? json['somaBasesLaudo']) as num?)?.toDouble(),
        vPercent: ((json['vPercent'] ?? json['v%'] ?? json['saturacaoBases']) as num?)?.toDouble(),
        mPercent: ((json['mPercent'] ?? json['m%'] ?? json['saturacaoAl']) as num?)?.toDouble(),
        osLaboratorio: json['osLaboratorio'] as String?,
        dataEmissao: json['dataEmissao'] as String?,
        consultor: json['consultor'] as String?,
        labTemplateId: json['labTemplateId'] as String?,
        unidadeNutrientes: json['unidadeNutrientes'] as String?,
        unidadeMO: json['unidadeMO'] as String?,
        unidadeTextura: json['unidadeTextura'] as String?,
        cascalho: (json['cascalho'] as num?)?.toDouble(),
        areiaGrossa: ((json['areiaGrossa'] ?? json['areia_grossa']) as num?)?.toDouble(),
        areiaFina: ((json['areiaFina'] ?? json['areia_fina']) as num?)?.toDouble(),
        co: ((json['co'] ?? json['cobalto']) as num?)?.toDouble(),
        municipio: json['municipio'] as String?,
        responsavelTecnico: json['responsavelTecnico'] as String?,
        cnpjCliente: json['cnpjCliente'] as String?,
        pTotal: ((json['pTotal'] ?? json['p_total']) as num?)?.toDouble(),
        classificacaoTextura: json['classificacaoTextura'] as String?,
        tipoSoloMapa: json['tipoSoloMapa'] as int?,
        solicitante: json['solicitante'] as String?,
        convenio: json['convenio'] as String?,
        creaResponsavel: json['creaResponsavel'] as String?,
        cnpjLaboratorio: json['cnpjLaboratorio'] as String?,
        dataInicioEnsaio: json['dataInicioEnsaio'] as String?,
        dataFimEnsaio: json['dataFimEnsaio'] as String?,
        matriculaImovel: json['matriculaImovel'] as String?,
        codigoInterno: json['codigoInterno'] as String?,
        codigoExternoAmostra: json['codigoExternoAmostra'] as String?,
        caMaisMg: ((json['caMaisMg'] ?? json['ca_mais_mg'] ?? json['caMg']) as num?)?.toDouble(),
        kMgDm3: ((json['kMgDm3'] ?? json['k_nh4cl'] ?? json['kNH4Cl']) as num?)?.toDouble(),
        cuMehlich: ((json['cuMehlich'] ?? json['cu_mehlich']) as num?)?.toDouble(),
        feMehlich: ((json['feMehlich'] ?? json['fe_mehlich']) as num?)?.toDouble(),
        mnMehlich: ((json['mnMehlich'] ?? json['mn_mehlich']) as num?)?.toDouble(),
        znMehlich: ((json['znMehlich'] ?? json['zn_mehlich']) as num?)?.toDouble(),
        cuDtpa: ((json['cuDtpa'] ?? json['cu_dtpa'] ?? json['cuDTPA']) as num?)?.toDouble(),
        feDtpa: ((json['feDtpa'] ?? json['fe_dtpa'] ?? json['feDTPA']) as num?)?.toDouble(),
        mnDtpa: ((json['mnDtpa'] ?? json['mn_dtpa'] ?? json['mnDTPA']) as num?)?.toDouble(),
        znDtpa: ((json['znDtpa'] ?? json['zn_dtpa'] ?? json['znDTPA']) as num?)?.toDouble(),
        dataRecebimento: json['dataRecebimento'] as String?,
        numeroRelatorio: json['numeroRelatorio'] as String?,
        codigoVerificacao: json['codigoVerificacao'] as String?,
        codigoTalhao: json['codigoTalhao'] as String?,
        totalAmostras: json['totalAmostras'] as int?,
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'fazenda_nome': fazenda,
        'fazendaNome': fazenda,
        'propriedade': fazenda,
        'produtor': produtor,
        'talhao': talhao,
        'talhao_nome': talhao,
        'talhaoNome': talhao,
        'numeroAmostra': numeroAmostra,
        'laboratorio': laboratorio,
        'profundidade': profundidade,
        'dataColeta': dataColeta,
        'status': status,
        'cultura': cultura,
        'safra': safra,
        'latitude': latitude,
        'longitude': longitude,
        'descricao_local': descricaoLocal,
        'pdf_url': pdfUrl,
        'argila': argila,
        'silte': silte,
        'areiaTotal': areiaTotal,
        'phAgua': phAgua,
        'phSmp': phSmp,
        'phCaCl2': phCaCl2,
        'materiaOrganica': materiaOrganica,
        'carbonoOrganico': carbonoOrganico,
        'p_mehlich': pMehlich,
        'pResina': pResina,
        'pRem': pRem,
        's020': s020,
        's2040': s2040,
        'k': k,
        'ca': ca,
        'mg': mg,
        'al': al,
        'hMaisAl': hMaisAl,
        'na': na,
        'b': b,
        'cu': cu,
        'fe': fe,
        'mn': mn,
        'zn': zn,
        'ni': ni,
        'mo': mo,
        'se': se,
        'fontePrincipalP': fontePrincipalP.name,
        'createdAt': const TimestampConverter().toJson(createdAt),
        'updatedAt': const TimestampConverter().toJson(updatedAt),
        'fosforo': pMehlich,
        'potassio': k,
        'calcio': ca,
        'magnesio': mg,
        'h': h,
        'hidrogenio': h,
        'ctcEfetiva': ctcEfetiva,
        'ctc': ctc,
        'sb': sb,
        'vPercent': vPercent,
        'mPercent': mPercent,
        'osLaboratorio': osLaboratorio,
        'dataEmissao': dataEmissao,
        'consultor': consultor,
        'labTemplateId': labTemplateId,
        'unidadeNutrientes': unidadeNutrientes,
        'unidadeMO': unidadeMO,
        'unidadeTextura': unidadeTextura,
        'cascalho': cascalho,
        'areiaGrossa': areiaGrossa,
        'areia_grossa': areiaGrossa,
        'areiaFina': areiaFina,
        'areia_fina': areiaFina,
        'co': co,
        'cobalto': co,
        'municipio': municipio,
        'responsavelTecnico': responsavelTecnico,
        'cnpjCliente': cnpjCliente,
        'pTotal': pTotal,
        'p_total': pTotal,
        'classificacaoTextura': classificacaoTextura,
        'tipoSoloMapa': tipoSoloMapa,
        'solicitante': solicitante,
        'convenio': convenio,
        'creaResponsavel': creaResponsavel,
        'cnpjLaboratorio': cnpjLaboratorio,
        'dataInicioEnsaio': dataInicioEnsaio,
        'dataFimEnsaio': dataFimEnsaio,
        'matriculaImovel': matriculaImovel,
        'codigoInterno': codigoInterno,
        'codigoExternoAmostra': codigoExternoAmostra,
        'caMaisMg': caMaisMg,
        'ca_mais_mg': caMaisMg,
        'kMgDm3': kMgDm3,
        'kNH4Cl': kMgDm3,
        'cuMehlich': cuMehlich,
        'feMehlich': feMehlich,
        'mnMehlich': mnMehlich,
        'znMehlich': znMehlich,
        'cuDtpa': cuDtpa,
        'feDtpa': feDtpa,
        'mnDtpa': mnDtpa,
        'znDtpa': znDtpa,
        'dataRecebimento': dataRecebimento,
        'numeroRelatorio': numeroRelatorio,
        'codigoVerificacao': codigoVerificacao,
        'codigoTalhao': codigoTalhao,
        'totalAmostras': totalAmostras,
      };

  // ── Fallbacks calculados (usam laudo quando disponivel) ─────────────────

  /// Soma de Bases: usa valor do laudo se disponivel, senao calcula
  double get sbFinal => sb ?? ((ca ?? 0) + (mg ?? 0) + (k ?? 0));

  /// CTC: usa valor do laudo se disponivel, senao calcula
  double get ctcFinal => ctc ?? (sbFinal + (hMaisAl ?? 0));

  /// V%: usa valor do laudo se disponivel, senao calcula
  double get vPercentFinal {
    if (vPercent != null) return vPercent!;
    if (ctcFinal == 0) return 0;
    return (sbFinal / ctcFinal) * 100;
  }

  // Aliases de compatibilidade para codigo legado
  double get ctcTotal => ctcFinal;
  double get vPct => vPercentFinal;

  double get argilaPercent => (argila ?? 0) / 10.0;

  // ── Saturacao das bases na CTC ────────────────────────────────────────────
  double get kNaCTC   => ctcFinal > 0 && k        != null ? (k!        / ctcFinal) * 100 : 0;
  double get caNaCTC  => ctcFinal > 0 && ca       != null ? (ca!       / ctcFinal) * 100 : 0;
  double get mgNaCTC  => ctcFinal > 0 && mg       != null ? (mg!       / ctcFinal) * 100 : 0;
  double get naNaCTC  => ctcFinal > 0 && na       != null ? (na!       / ctcFinal) * 100 : 0;
  double get alNaCTC  => ctcFinal > 0 && al       != null ? (al!       / ctcFinal) * 100 : 0;
  double get hNaCTC   => ctcFinal > 0 && hMaisAl  != null ? (hMaisAl!  / ctcFinal) * 100 : 0;

  // ── Relacoes entre bases ──────────────────────────────────────────────────
  double get relCaK  => k  != null && k!  > 0 && ca != null ? ca! / k!  : 0;
  double get relCaMg => mg != null && mg! > 0 && ca != null ? ca! / mg! : 0;
  double get relMgK  => k  != null && k!  > 0 && mg != null ? mg! / k!  : 0;

  // ── CTC efetiva ────────────────────────────────────────────────────────────
  /// CTCt extraida do laudo (Sellar), ou calculada como SB + Al
  double get ctcEfetivaFinal {
    if (ctcEfetiva != null) return ctcEfetiva!;
    return sbFinal + (al ?? 0);
  }

  // Alias para compatibilidade
  double get ctcEfetivaCalc => ctcEfetivaFinal;

  // ── Resolucao de micronutrientes ─────────────────────────────────────────
  // REGRA: prioridade DTPA > Mehlich > campo legado
  // Parser IBRA  → preenche cuDtpa, feDtpa, mnDtpa, znDtpa
  // Parser Exata → preenche cuMehlich/feMehlich/mnMehlich/znMehlich + Dtpa
  // Tela         → usa *Resolvido para valor padrao
  double? get cuResolvido => cuDtpa ?? cuMehlich ?? cu;
  double? get feResolvido => feDtpa ?? feMehlich ?? fe;
  double? get mnResolvido => mnDtpa ?? mnMehlich ?? mn;
  double? get znResolvido => znDtpa ?? znMehlich ?? zn;

  // (Ca+Mg)/K — entregue pela Exata, calculado para outros
  double get relCaMgK {
    if (k != null && k! > 0 && ca != null && mg != null) {
      return (ca! + mg!) / k!;
    }
    return 0;
  }

  FosforoData get fosforoData => FosforoData(
        pResina: pResina,
        pMehlich: pMehlich,
        pRemanescente: pRem,
        fontePrincipal: fontePrincipalP,
      );
}

class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json);
    return null;
  }

  @override
  Object? toJson(DateTime? object) {
    if (object == null) return null;
    return Timestamp.fromDate(object);
  }
}
