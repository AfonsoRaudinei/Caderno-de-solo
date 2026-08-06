import 'package:soloforte/domain/usecases/recomendacao_engine.dart';

/// Metadados da análise/perfil necessários ao cabeçalho do relatório HTML.
class RecomendacaoExportMetadata {
  const RecomendacaoExportMetadata({
    this.consultorNome,
    this.consultorCredencial,
    this.produtor,
    this.fazenda,
    this.cidadeUf,
    this.talhao,
    this.cultura,
    this.safra,
    this.laboratorio,
    this.profundidade,
    this.dataLaudo,
    this.logoDataUri,
  });

  final String? consultorNome;
  final String? consultorCredencial;
  final String? produtor;
  final String? fazenda;
  final String? cidadeUf;
  final String? talhao;
  final String? cultura;
  final String? safra;
  final String? laboratorio;
  final String? profundidade;
  final DateTime? dataLaudo;
  final String? logoDataUri;
}

/// Entrada para geração do relatório HTML de recomendação.
class RecomendacaoExportContext {
  const RecomendacaoExportContext({
    required this.resultado,
    this.metadata = const RecomendacaoExportMetadata(),
    this.geradaEm,
  });

  final ResultadoRecomendacao resultado;
  final RecomendacaoExportMetadata metadata;
  final DateTime? geradaEm;
}
