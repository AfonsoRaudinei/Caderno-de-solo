import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

/// Regras de resolução do produtor em importações e reparo de legado.
class ProdutorResolucaoService {
  const ProdutorResolucaoService._();

  static final RegExp _contratanteIbraPattern = RegExp(
    r'agrofarm|instituto\s+brasileiro|ibra\s*[—\-]',
    caseSensitive: false,
  );

  static bool isProdutorInvalido(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return true;
    if (_contratanteIbraPattern.hasMatch(text)) return true;
    return false;
  }

  static String firstNonEmpty(Iterable<String?> values) {
    for (final value in values) {
      final text = value?.trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  /// Resolve o produtor final usando PDF, metadados e produtor configurado.
  static String resolver({
    required String? produtorAtual,
    Map<String, dynamic>? laudoMetadata,
    required String produtorConfigurado,
  }) {
    final configurado = produtorConfigurado.trim();
    final atual = produtorAtual?.trim() ?? '';
    if (!isProdutorInvalido(atual)) return atual;

    final proprietarioMeta =
        laudoMetadata?['proprietario']?.toString().trim() ?? '';
    if (!isProdutorInvalido(proprietarioMeta)) return proprietarioMeta;

    return configurado;
  }

  static String produtorEfetivo(AnaliseSolo analise) {
    final produtor = analise.produtor.trim();
    if (produtor.isNotEmpty) return produtor;

    final proprietario =
        analise.laudoMetadata?['proprietario']?.toString().trim() ?? '';
    if (proprietario.isNotEmpty) return proprietario;

    return '';
  }

  static bool nomesProdutorCompativeis(String a, String b) {
    final left = a.trim().toLowerCase();
    final right = b.trim().toLowerCase();
    if (left.isEmpty || right.isEmpty) return false;
    return left == right || left.contains(right) || right.contains(left);
  }

  static bool compativelComConfigurado(
    AnaliseSolo analise,
    String produtorConfigurado,
  ) {
    final configurado = produtorConfigurado.trim();
    if (configurado.isEmpty) return true;

    final produtorAnalise = produtorEfetivo(analise);
    if (produtorAnalise.isEmpty) return false;

    return nomesProdutorCompativeis(produtorAnalise, configurado);
  }

  static AnaliseSolo aplicarProdutorConfigurado(
    AnaliseSolo analise,
    String produtorConfigurado, {
    String? consultor,
    bool forcarProdutorConfigurado = false,
  }) {
    final configurado = produtorConfigurado.trim();
    final produtorResolvido = forcarProdutorConfigurado && configurado.isNotEmpty
        ? configurado
        : resolver(
            produtorAtual: analise.produtor,
            laudoMetadata: analise.laudoMetadata,
            produtorConfigurado: produtorConfigurado,
          );

    final consultorResolvido = firstNonEmpty([
      consultor,
      analise.consultor,
      analise.laudoMetadata?['responsavel']?.toString(),
    ]);

    if (produtorResolvido == analise.produtor &&
        (consultorResolvido.isEmpty ||
            consultorResolvido == (analise.consultor ?? ''))) {
      return analise;
    }

    return AnaliseSolo(
      id: analise.id,
      fazenda: analise.fazenda,
      produtor: produtorResolvido,
      talhao: analise.talhao,
      numeroAmostra: analise.numeroAmostra,
      cultura: analise.cultura,
      safra: analise.safra,
      laboratorio: analise.laboratorio,
      dataCadastro: analise.dataCadastro,
      profundidade: analise.profundidade,
      latitude: analise.latitude,
      longitude: analise.longitude,
      descricaoLocal: analise.descricaoLocal,
      argila: analise.argila,
      silte: analise.silte,
      areiaTotal: analise.areiaTotal,
      phAgua: analise.phAgua,
      phSmp: analise.phSmp,
      phCaCl2: analise.phCaCl2,
      materiaOrganica: analise.materiaOrganica,
      carbonoOrganico: analise.carbonoOrganico,
      pMehlich: analise.pMehlich,
      pResina: analise.pResina,
      pRem: analise.pRem,
      s020: analise.s020,
      s2040: analise.s2040,
      k: analise.k,
      ca: analise.ca,
      mg: analise.mg,
      al: analise.al,
      hMaisAl: analise.hMaisAl,
      na: analise.na,
      b: analise.b,
      cu: analise.cu,
      fe: analise.fe,
      mn: analise.mn,
      zn: analise.zn,
      ni: analise.ni,
      mo: analise.mo,
      se: analise.se,
      co: analise.co,
      cascalho: analise.cascalho,
      areiaGrossa: analise.areiaGrossa,
      areiaFina: analise.areiaFina,
      municipio: analise.municipio,
      responsavelTecnico: analise.responsavelTecnico,
      cnpjCliente: analise.cnpjCliente,
      pTotal: analise.pTotal,
      classificacaoTextura: analise.classificacaoTextura,
      tipoSoloMapa: analise.tipoSoloMapa,
      solicitante: analise.solicitante,
      convenio: analise.convenio,
      creaResponsavel: analise.creaResponsavel,
      cnpjLaboratorio: analise.cnpjLaboratorio,
      dataInicioEnsaio: analise.dataInicioEnsaio,
      dataFimEnsaio: analise.dataFimEnsaio,
      matriculaImovel: analise.matriculaImovel,
      codigoInterno: analise.codigoInterno,
      codigoExternoAmostra: analise.codigoExternoAmostra,
      caMaisMg: analise.caMaisMg,
      kMgDm3: analise.kMgDm3,
      cuMehlich: analise.cuMehlich,
      feMehlich: analise.feMehlich,
      mnMehlich: analise.mnMehlich,
      znMehlich: analise.znMehlich,
      cuDtpa: analise.cuDtpa,
      feDtpa: analise.feDtpa,
      mnDtpa: analise.mnDtpa,
      znDtpa: analise.znDtpa,
      dataRecebimento: analise.dataRecebimento,
      numeroRelatorio: analise.numeroRelatorio,
      codigoVerificacao: analise.codigoVerificacao,
      codigoTalhao: analise.codigoTalhao,
      totalAmostras: analise.totalAmostras,
      pdfUrl: analise.pdfUrl,
      laudoMetadata: analise.laudoMetadata,
      h: analise.h,
      ctcEfetiva: analise.ctcEfetiva,
      ctc: analise.ctc,
      sb: analise.sb,
      vPercent: analise.vPercent,
      mPercent: analise.mPercent,
      osLaboratorio: analise.osLaboratorio,
      dataEmissao: analise.dataEmissao,
      consultor:
          consultorResolvido.isEmpty ? analise.consultor : consultorResolvido,
      labTemplateId: analise.labTemplateId,
      unidadeNutrientes: analise.unidadeNutrientes,
      unidadeMO: analise.unidadeMO,
      unidadeTextura: analise.unidadeTextura,
    );
  }
}
