import 'package:flutter/services.dart';
import 'package:soloforte/domain/export/recomendacao_export_context.dart';
import 'package:soloforte/domain/export/recomendacao_html_mapper.dart';

/// Carrega o template HTML e injeta o conteúdo gerado pelo mapper.
class RecomendacaoHtmlRenderer {
  const RecomendacaoHtmlRenderer({
    RecomendacaoHtmlMapper? mapper,
  }) : _mapper = mapper ?? const RecomendacaoHtmlMapper();

  static const _templateAsset =
      'assets/templates/recomendacao_soloforte_v4.html';

  final RecomendacaoHtmlMapper _mapper;

  Future<String> render(RecomendacaoExportContext context) async {
    final template = await rootBundle.loadString(_templateAsset);
    final body = _mapper.buildBody(context);
    return template.replaceAll('{{BODY}}', body);
  }
}
