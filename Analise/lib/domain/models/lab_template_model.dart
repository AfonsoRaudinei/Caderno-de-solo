import 'package:soloforte/domain/entities/lab_template.dart';

/// Model serializado para persistencia no Hive.
/// Nao usa freezed/build_runner -- serializa manualmente.
class LabTemplateModel {
  final String id;
  final String nome;
  final List<String> keywords;
  final UnidadeNutriente unidadeK;
  final UnidadeNutriente unidadeCa;
  final UnidadeNutriente unidadeMg;
  final UnidadeNutriente unidadeAl;
  final UnidadeNutriente unidadeHAl;
  final UnidadeNutriente unidadeNa;
  final UnidadeNutriente unidadeCTC;
  final UnidadeNutriente unidadeSB;
  final UnidadeMO unidadeMO;
  final UnidadeMO unidadeCOT;
  final UnidadeTextura unidadeTextura;
  final bool entregaCTC;
  final bool entregaSB;
  final bool entregaVPercent;
  final bool entregaMPercent;
  final bool entregaHidrogenioPuro;
  final bool entregaH;
  final bool entregaCtcEfetiva;
  final bool entregaMicroMehlich;
  final bool entregaMicroDtpa;
  final bool entregaPhAgua;
  final bool entregaPhSMP;
  final bool entregaCaMaisMg;
  final bool entregaKNH4Cl;
  final bool entregaMo;
  final bool entregaCo;
  final bool entregaPTotal;
  final bool entregaClassificacaoTextura;
  final bool entregaTipoSoloMapa;
  final bool separaSolicitanteProprietario;
  final bool entregaTextura;
  final bool micronutrientesPorAmostra;
  final bool identificacaoComposta;
  final bool umAmostraPorLaudo;
  final bool entregaAreiasDetalhadas;
  final bool entregaCascalho;
  final bool ativo;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LabTemplateModel({
    required this.id,
    required this.nome,
    required this.keywords,
    this.unidadeK = UnidadeNutriente.cmolcDm3,
    this.unidadeCa = UnidadeNutriente.cmolcDm3,
    this.unidadeMg = UnidadeNutriente.cmolcDm3,
    this.unidadeAl = UnidadeNutriente.cmolcDm3,
    this.unidadeHAl = UnidadeNutriente.cmolcDm3,
    this.unidadeNa = UnidadeNutriente.cmolcDm3,
    this.unidadeCTC = UnidadeNutriente.cmolcDm3,
    this.unidadeSB = UnidadeNutriente.cmolcDm3,
    this.unidadeMO = UnidadeMO.dagKg,
    this.unidadeCOT = UnidadeMO.dagKg,
    this.unidadeTextura = UnidadeTextura.gKg,
    this.entregaCTC = true,
    this.entregaSB = true,
    this.entregaVPercent = true,
    this.entregaMPercent = true,
    this.entregaHidrogenioPuro = false,
    this.entregaH = false,
    this.entregaCtcEfetiva = false,
    this.entregaMicroMehlich = false,
    this.entregaMicroDtpa = false,
    this.entregaPhAgua = true,
    this.entregaPhSMP = true,
    this.entregaCaMaisMg = false,
    this.entregaKNH4Cl = false,
    this.entregaMo = false,
    this.entregaCo = false,
    this.entregaPTotal = false,
    this.entregaClassificacaoTextura = false,
    this.entregaTipoSoloMapa = false,
    this.separaSolicitanteProprietario = false,
    this.entregaTextura = true,
    this.micronutrientesPorAmostra = false,
    this.identificacaoComposta = false,
    this.umAmostraPorLaudo = false,
    this.entregaAreiasDetalhadas = false,
    this.entregaCascalho = false,
    this.ativo = true,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  LabTemplate toEntity() => LabTemplate(
        id: id,
        nome: nome,
        keywords: keywords,
        unidadeK: unidadeK,
        unidadeCa: unidadeCa,
        unidadeMg: unidadeMg,
        unidadeAl: unidadeAl,
        unidadeHAl: unidadeHAl,
        unidadeNa: unidadeNa,
        unidadeCTC: unidadeCTC,
        unidadeSB: unidadeSB,
        unidadeMO: unidadeMO,
        unidadeCOT: unidadeCOT,
        unidadeTextura: unidadeTextura,
        entregaCTC: entregaCTC,
        entregaSB: entregaSB,
        entregaVPercent: entregaVPercent,
        entregaMPercent: entregaMPercent,
        entregaHidrogenioPuro: entregaHidrogenioPuro,
        entregaH: entregaH,
        entregaCtcEfetiva: entregaCtcEfetiva,
        entregaMicroMehlich: entregaMicroMehlich,
        entregaMicroDtpa: entregaMicroDtpa,
        entregaPhAgua: entregaPhAgua,
        entregaPhSMP: entregaPhSMP,
        entregaCaMaisMg: entregaCaMaisMg,
        entregaKNH4Cl: entregaKNH4Cl,
        entregaMo: entregaMo,
        entregaCo: entregaCo,
        entregaPTotal: entregaPTotal,
        entregaClassificacaoTextura: entregaClassificacaoTextura,
        entregaTipoSoloMapa: entregaTipoSoloMapa,
        separaSolicitanteProprietario: separaSolicitanteProprietario,
        entregaTextura: entregaTextura,
        micronutrientesPorAmostra: micronutrientesPorAmostra,
        identificacaoComposta: identificacaoComposta,
        umAmostraPorLaudo: umAmostraPorLaudo,
        entregaAreiasDetalhadas: entregaAreiasDetalhadas,
        entregaCascalho: entregaCascalho,
        ativo: ativo,
        isDefault: isDefault,
        createdAt: createdAt ?? DateTime.now(),
        updatedAt: updatedAt,
      );

  factory LabTemplateModel.fromEntity(LabTemplate e) => LabTemplateModel(
        id: e.id,
        nome: e.nome,
        keywords: e.keywords,
        unidadeK: e.unidadeK,
        unidadeCa: e.unidadeCa,
        unidadeMg: e.unidadeMg,
        unidadeAl: e.unidadeAl,
        unidadeHAl: e.unidadeHAl,
        unidadeNa: e.unidadeNa,
        unidadeCTC: e.unidadeCTC,
        unidadeSB: e.unidadeSB,
        unidadeMO: e.unidadeMO,
        unidadeCOT: e.unidadeCOT,
        unidadeTextura: e.unidadeTextura,
        entregaCTC: e.entregaCTC,
        entregaSB: e.entregaSB,
        entregaVPercent: e.entregaVPercent,
        entregaMPercent: e.entregaMPercent,
        entregaHidrogenioPuro: e.entregaHidrogenioPuro,
        entregaH: e.entregaH,
        entregaCtcEfetiva: e.entregaCtcEfetiva,
        entregaMicroMehlich: e.entregaMicroMehlich,
        entregaMicroDtpa: e.entregaMicroDtpa,
        entregaPhAgua: e.entregaPhAgua,
        entregaPhSMP: e.entregaPhSMP,
        entregaCaMaisMg: e.entregaCaMaisMg,
        entregaKNH4Cl: e.entregaKNH4Cl,
        entregaMo: e.entregaMo,
        entregaCo: e.entregaCo,
        entregaPTotal: e.entregaPTotal,
        entregaClassificacaoTextura: e.entregaClassificacaoTextura,
        entregaTipoSoloMapa: e.entregaTipoSoloMapa,
        separaSolicitanteProprietario: e.separaSolicitanteProprietario,
        entregaTextura: e.entregaTextura,
        micronutrientesPorAmostra: e.micronutrientesPorAmostra,
        identificacaoComposta: e.identificacaoComposta,
        umAmostraPorLaudo: e.umAmostraPorLaudo,
        entregaAreiasDetalhadas: e.entregaAreiasDetalhadas,
        entregaCascalho: e.entregaCascalho,
        ativo: e.ativo,
        isDefault: e.isDefault,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  static UnidadeNutriente _nutriente(String? name) =>
      UnidadeNutriente.values.firstWhere(
        (e) => e.name == name,
        orElse: () => UnidadeNutriente.cmolcDm3,
      );

  static UnidadeMO _mo(String? name) => UnidadeMO.values.firstWhere(
        (e) => e.name == name,
        orElse: () => UnidadeMO.dagKg,
      );

  static UnidadeTextura _textura(String? name) =>
      UnidadeTextura.values.firstWhere(
        (e) => e.name == name,
        orElse: () => UnidadeTextura.gKg,
      );

  factory LabTemplateModel.fromJson(Map<String, dynamic> j) =>
      LabTemplateModel(
        id: j['id'] as String,
        nome: j['nome'] as String,
        keywords: List<String>.from(j['keywords'] as List? ?? []),
        unidadeK: _nutriente(j['unidadeK'] as String?),
        unidadeCa: _nutriente(j['unidadeCa'] as String?),
        unidadeMg: _nutriente(j['unidadeMg'] as String?),
        unidadeAl: _nutriente(j['unidadeAl'] as String?),
        unidadeHAl: _nutriente(j['unidadeHAl'] as String?),
        unidadeNa: _nutriente(j['unidadeNa'] as String?),
        unidadeCTC: _nutriente(j['unidadeCTC'] as String?),
        unidadeSB: _nutriente(j['unidadeSB'] as String?),
        unidadeMO: _mo(j['unidadeMO'] as String?),
        unidadeCOT: _mo(j['unidadeCOT'] as String?),
        unidadeTextura: _textura(j['unidadeTextura'] as String?),
        entregaCTC: j['entregaCTC'] as bool? ?? true,
        entregaSB: j['entregaSB'] as bool? ?? true,
        entregaVPercent: j['entregaVPercent'] as bool? ?? true,
        entregaMPercent: j['entregaMPercent'] as bool? ?? true,
        entregaHidrogenioPuro: j['entregaHidrogenioPuro'] as bool? ?? false,
        entregaH: j['entregaH'] as bool? ?? false,
        entregaCtcEfetiva: j['entregaCtcEfetiva'] as bool? ?? false,
        entregaMicroMehlich: j['entregaMicroMehlich'] as bool? ?? false,
        entregaMicroDtpa: j['entregaMicroDtpa'] as bool? ?? false,
        entregaPhAgua: j['entregaPhAgua'] as bool? ?? true,
        entregaPhSMP: j['entregaPhSMP'] as bool? ?? true,
        entregaCaMaisMg: j['entregaCaMaisMg'] as bool? ?? false,
        entregaKNH4Cl: j['entregaKNH4Cl'] as bool? ?? false,
        entregaMo: j['entregaMo'] as bool? ?? false,
        entregaCo: j['entregaCo'] as bool? ?? false,
        entregaPTotal: j['entregaPTotal'] as bool? ?? false,
        entregaClassificacaoTextura: j['entregaClassificacaoTextura'] as bool? ?? false,
        entregaTipoSoloMapa: j['entregaTipoSoloMapa'] as bool? ?? false,
        separaSolicitanteProprietario: j['separaSolicitanteProprietario'] as bool? ?? false,
        entregaTextura: j['entregaTextura'] as bool? ?? true,
        micronutrientesPorAmostra: j['micronutrientesPorAmostra'] as bool? ?? false,
        identificacaoComposta: j['identificacaoComposta'] as bool? ?? false,
        umAmostraPorLaudo: j['umAmostraPorLaudo'] as bool? ?? false,
        entregaAreiasDetalhadas: j['entregaAreiasDetalhadas'] as bool? ?? false,
        entregaCascalho: j['entregaCascalho'] as bool? ?? false,
        ativo: j['ativo'] as bool? ?? true,
        isDefault: j['isDefault'] as bool? ?? false,
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'] as String)
            : null,
        updatedAt: j['updatedAt'] != null
            ? DateTime.tryParse(j['updatedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'keywords': keywords,
        'unidadeK': unidadeK.name,
        'unidadeCa': unidadeCa.name,
        'unidadeMg': unidadeMg.name,
        'unidadeAl': unidadeAl.name,
        'unidadeHAl': unidadeHAl.name,
        'unidadeNa': unidadeNa.name,
        'unidadeCTC': unidadeCTC.name,
        'unidadeSB': unidadeSB.name,
        'unidadeMO': unidadeMO.name,
        'unidadeCOT': unidadeCOT.name,
        'unidadeTextura': unidadeTextura.name,
        'entregaCTC': entregaCTC,
        'entregaSB': entregaSB,
        'entregaVPercent': entregaVPercent,
        'entregaMPercent': entregaMPercent,
        'entregaHidrogenioPuro': entregaHidrogenioPuro,
        'entregaH': entregaH,
        'entregaCtcEfetiva': entregaCtcEfetiva,
        'entregaMicroMehlich': entregaMicroMehlich,
        'entregaMicroDtpa': entregaMicroDtpa,
        'entregaPhAgua': entregaPhAgua,
        'entregaPhSMP': entregaPhSMP,
        'entregaCaMaisMg': entregaCaMaisMg,
        'entregaKNH4Cl': entregaKNH4Cl,
        'entregaMo': entregaMo,
        'entregaCo': entregaCo,
        'entregaPTotal': entregaPTotal,
        'entregaClassificacaoTextura': entregaClassificacaoTextura,
        'entregaTipoSoloMapa': entregaTipoSoloMapa,
        'separaSolicitanteProprietario': separaSolicitanteProprietario,
        'entregaTextura': entregaTextura,
        'micronutrientesPorAmostra': micronutrientesPorAmostra,
        'identificacaoComposta': identificacaoComposta,
        'umAmostraPorLaudo': umAmostraPorLaudo,
        'entregaAreiasDetalhadas': entregaAreiasDetalhadas,
        'entregaCascalho': entregaCascalho,
        'ativo': ativo,
        'isDefault': isDefault,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
