import 'package:soloforte/domain/usecases/recomendacao_engine.dart';

/// Metadados da análise/perfil necessários ao cabeçalho do relatório HTML.
class RecomendacaoExportMetadata {
  const RecomendacaoExportMetadata({
    this.consultorNome,
    this.consultorCredencial,
    this.laboratorio,
    this.dataLaudo,
    this.logoDataUri,
  });

  final String? consultorNome;
  final String? consultorCredencial;
  final String? laboratorio;
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
