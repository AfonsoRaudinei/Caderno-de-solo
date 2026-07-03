import 'package:soloforte/domain/export/recomendacao_export_context.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/config/domain/entities/user_profile_data.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/recomendacao_html_exporter.dart';

/// Monta [RecomendacaoExportContext] a partir dos dados da tela de recomendação.
class RecomendacaoExportContextBuilder {
  const RecomendacaoExportContextBuilder();

  Future<RecomendacaoExportContext> build({
    required ResultadoRecomendacao resultado,
    AnaliseSolo? analiseSolo,
    UserProfileData? perfil,
    String? logoUrl,
    DateTime? geradaEm,
  }) async {
    final logoDataUri = await RecomendacaoHtmlExporter.logoToDataUri(logoUrl);
    final credencial = perfil != null
        ? '${perfil.tipoPerfil}${perfil.empresa.isNotEmpty ? ' · ${perfil.empresa}' : ''}'
        : null;

    return RecomendacaoExportContext(
      resultado: resultado,
      geradaEm: geradaEm ?? DateTime.now(),
      metadata: RecomendacaoExportMetadata(
        consultorNome: perfil?.nome ?? resultado.analise.consultor,
        consultorCredencial: credencial,
        laboratorio: analiseSolo?.laboratorio,
        dataLaudo: _parseDataLaudo(analiseSolo),
        logoDataUri: logoDataUri,
      ),
    );
  }

  static DateTime? parseDataLaudo(AnaliseSolo? analiseSolo) =>
      _parseDataLaudo(analiseSolo);

  static DateTime? _parseDataLaudo(AnaliseSolo? analiseSolo) {
    final emissao = analiseSolo?.dataEmissao;
    if (emissao != null && emissao.isNotEmpty) {
      final parsed = DateTime.tryParse(emissao);
      if (parsed != null) return parsed;
      final br = RegExp(r'^(\d{2})/(\d{2})/(\d{4})').firstMatch(emissao);
      if (br != null) {
        return DateTime.tryParse(
          '${br.group(3)}-${br.group(2)}-${br.group(1)}',
        );
      }
    }
    return analiseSolo?.dataCadastro;
  }
}
