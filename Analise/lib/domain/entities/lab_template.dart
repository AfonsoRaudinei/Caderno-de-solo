/// Entidade pura que define um template de laboratorio.
/// Nao depende de Flutter nem de bibliotecas externas.
class LabTemplate {
  final String id;
  final String nome;
  final List<String> keywords;

  // Unidades padrao -- macronutrientes e acidez
  final UnidadeNutriente unidadeK;
  final UnidadeNutriente unidadeCa;
  final UnidadeNutriente unidadeMg;
  final UnidadeNutriente unidadeAl;
  final UnidadeNutriente unidadeHAl;
  final UnidadeNutriente unidadeNa;
  final UnidadeNutriente unidadeCTC;
  final UnidadeNutriente unidadeSB;

  // Unidades -- materia organica e carbono
  final UnidadeMO unidadeMO;
  final UnidadeMO unidadeCOT;

  // Unidades -- textura
  final UnidadeTextura unidadeTextura;

  // Campos que o lab entrega prontos (extrair, nao recalcular)
  final bool entregaCTC;
  final bool entregaSB;
  final bool entregaVPercent;
  final bool entregaMPercent;
  final bool entregaHidrogenioPuro; // H separado de H+Al
  final bool entregaH;              // H puro entregue (alias/flag)
  final bool entregaCtcEfetiva;     // Sellar extrai CTCt -- outros calculam

  // Micronutrientes -- qual metodo o lab usa
  final bool entregaMicroMehlich;
  final bool entregaMicroDtpa;

  // Campos opcionais que o lab pode ou nao entregar
  final bool entregaPhAgua;       // pH em agua
  final bool entregaPhSMP;        // pH SMP
  final bool entregaCaMaisMg;     // Ca+Mg somado (Exata)
  final bool entregaKNH4Cl;       // K em NH4Cl / mg/dm3 (Exata, MB)
  final bool entregaMo;           // Molibdenio no layout
  final bool entregaCo;           // Cobalto no layout

  // Campos exclusivos Sellar
  final bool entregaPTotal;              // P Total em % -- Sellar
  final bool entregaClassificacaoTextura;// Classificacao textural -- Sellar
  final bool entregaTipoSoloMapa;        // Tipo Solo MAPA IN02/2008 -- Sellar
  final bool separaSolicitanteProprietario; // Solicitante != Proprietario

  // Campos exclusivos Solum
  final bool entregaTextura;              // Entrega textura -- Solum (false = sem textura)
  final bool micronutrientesPorAmostra;   // Micros por amostra -- Solum
  final bool identificacaoComposta;       // ID composta (codigo interno + externo) -- Solum

  // Layout do laudo
  final bool umAmostraPorLaudo;       // MB = true, outros = false
  final bool entregaAreiasDetalhadas; // Areia grossa + fina separadas
  final bool entregaCascalho;         // Campo cascalho no layout

  // Metadados
  final bool ativo;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LabTemplate({
    required this.id,
    required this.nome,
    required this.keywords,
    required this.unidadeK,
    required this.unidadeCa,
    required this.unidadeMg,
    required this.unidadeAl,
    required this.unidadeHAl,
    required this.unidadeNa,
    required this.unidadeCTC,
    required this.unidadeSB,
    required this.unidadeMO,
    required this.unidadeCOT,
    required this.unidadeTextura,
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
    required this.createdAt,
    this.updatedAt,
  });

  /// Detecta se o texto do PDF corresponde a este template
  bool matches(String text) {
    final lower = text.toLowerCase();
    return keywords.any((kw) => lower.contains(kw.toLowerCase()));
  }

  LabTemplate copyWith({
    String? id,
    String? nome,
    List<String>? keywords,
    UnidadeNutriente? unidadeK,
    UnidadeNutriente? unidadeCa,
    UnidadeNutriente? unidadeMg,
    UnidadeNutriente? unidadeAl,
    UnidadeNutriente? unidadeHAl,
    UnidadeNutriente? unidadeNa,
    UnidadeNutriente? unidadeCTC,
    UnidadeNutriente? unidadeSB,
    UnidadeMO? unidadeMO,
    UnidadeMO? unidadeCOT,
    UnidadeTextura? unidadeTextura,
    bool? entregaCTC,
    bool? entregaSB,
    bool? entregaVPercent,
    bool? entregaMPercent,
    bool? entregaHidrogenioPuro,
    bool? entregaH,
    bool? entregaCtcEfetiva,
    bool? entregaMicroMehlich,
    bool? entregaMicroDtpa,
    bool? entregaPhAgua,
    bool? entregaPhSMP,
    bool? entregaCaMaisMg,
    bool? entregaKNH4Cl,
    bool? entregaMo,
    bool? entregaCo,
    bool? entregaPTotal,
    bool? entregaClassificacaoTextura,
    bool? entregaTipoSoloMapa,
    bool? separaSolicitanteProprietario,
    bool? entregaTextura,
    bool? micronutrientesPorAmostra,
    bool? identificacaoComposta,
    bool? umAmostraPorLaudo,
    bool? entregaAreiasDetalhadas,
    bool? entregaCascalho,
    bool? ativo,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LabTemplate(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      keywords: keywords ?? this.keywords,
      unidadeK: unidadeK ?? this.unidadeK,
      unidadeCa: unidadeCa ?? this.unidadeCa,
      unidadeMg: unidadeMg ?? this.unidadeMg,
      unidadeAl: unidadeAl ?? this.unidadeAl,
      unidadeHAl: unidadeHAl ?? this.unidadeHAl,
      unidadeNa: unidadeNa ?? this.unidadeNa,
      unidadeCTC: unidadeCTC ?? this.unidadeCTC,
      unidadeSB: unidadeSB ?? this.unidadeSB,
      unidadeMO: unidadeMO ?? this.unidadeMO,
      unidadeCOT: unidadeCOT ?? this.unidadeCOT,
      unidadeTextura: unidadeTextura ?? this.unidadeTextura,
      entregaCTC: entregaCTC ?? this.entregaCTC,
      entregaSB: entregaSB ?? this.entregaSB,
      entregaVPercent: entregaVPercent ?? this.entregaVPercent,
      entregaMPercent: entregaMPercent ?? this.entregaMPercent,
      entregaHidrogenioPuro: entregaHidrogenioPuro ?? this.entregaHidrogenioPuro,
      entregaH: entregaH ?? this.entregaH,
      entregaCtcEfetiva: entregaCtcEfetiva ?? this.entregaCtcEfetiva,
      entregaMicroMehlich: entregaMicroMehlich ?? this.entregaMicroMehlich,
      entregaMicroDtpa: entregaMicroDtpa ?? this.entregaMicroDtpa,
      entregaPhAgua: entregaPhAgua ?? this.entregaPhAgua,
      entregaPhSMP: entregaPhSMP ?? this.entregaPhSMP,
      entregaCaMaisMg: entregaCaMaisMg ?? this.entregaCaMaisMg,
      entregaKNH4Cl: entregaKNH4Cl ?? this.entregaKNH4Cl,
      entregaMo: entregaMo ?? this.entregaMo,
      entregaCo: entregaCo ?? this.entregaCo,
      entregaPTotal: entregaPTotal ?? this.entregaPTotal,
      entregaClassificacaoTextura: entregaClassificacaoTextura ?? this.entregaClassificacaoTextura,
      entregaTipoSoloMapa: entregaTipoSoloMapa ?? this.entregaTipoSoloMapa,
      separaSolicitanteProprietario: separaSolicitanteProprietario ?? this.separaSolicitanteProprietario,
      entregaTextura: entregaTextura ?? this.entregaTextura,
      micronutrientesPorAmostra: micronutrientesPorAmostra ?? this.micronutrientesPorAmostra,
      identificacaoComposta: identificacaoComposta ?? this.identificacaoComposta,
      umAmostraPorLaudo: umAmostraPorLaudo ?? this.umAmostraPorLaudo,
      entregaAreiasDetalhadas: entregaAreiasDetalhadas ?? this.entregaAreiasDetalhadas,
      entregaCascalho: entregaCascalho ?? this.entregaCascalho,
      ativo: ativo ?? this.ativo,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabTemplate &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ---- Enums ------------------------------------------------------------------

enum UnidadeNutriente {
  // ignore: constant_identifier_names
  cmolcDm3('cmolc/dm³'),
  // ignore: constant_identifier_names
  mmolcDm3('mmolc/dm³');

  final String label;
  const UnidadeNutriente(this.label);
}

// IMPORTANTE -- dag/kg e % sao numericamente equivalentes:
// dag.kg-1 = decagrama por quilograma = 10g/kg = 1%
// M.O. 2,5 dag/kg = M.O. 2,5%
// Fonte: rodape do laudo Sellar confirma "dag.kg-1 = %"
// Para calculos, tratar ambos como a mesma escala numerica.
// Apenas para exibicao ao usuario usar o label correto do lab.
enum UnidadeMO {
  percent('%'),
  // ignore: constant_identifier_names
  dagKg('dag/kg'), // Sellar usa esta (= % numericamente)
  // ignore: constant_identifier_names
  gKg('g/kg'),
  // ignore: constant_identifier_names
  gDm3('g/dm³');

  final String label;
  const UnidadeMO(this.label);

  /// dag/kg e % sao numericamente equivalentes
  bool get isEquivalentToPercent =>
      this == UnidadeMO.percent || this == UnidadeMO.dagKg;
}

enum UnidadeTextura {
  // ignore: constant_identifier_names
  gKg('g/kg'),
  // ignore: constant_identifier_names
  gDm3('g/dm³'),
  percent('%');

  final String label;
  const UnidadeTextura(this.label);
}
