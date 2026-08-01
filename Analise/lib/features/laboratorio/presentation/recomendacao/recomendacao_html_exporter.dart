import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soloforte/core/utils/image_source_resolver.dart';
import 'package:soloforte/domain/export/recomendacao_export_context.dart';
import 'package:soloforte/features/laboratorio/services/recomendacao_html_renderer.dart';

/// Gera e compartilha relatório HTML de recomendação.
class RecomendacaoHtmlExporter {
  const RecomendacaoHtmlExporter({
    RecomendacaoHtmlRenderer? renderer,
  }) : _renderer = renderer ?? const RecomendacaoHtmlRenderer();

  final RecomendacaoHtmlRenderer _renderer;

  Future<void> exportar(
    RecomendacaoExportContext exportContext, {
    Rect? sharePositionOrigin,
  }) async {
    final html = await _renderer.render(exportContext);
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final file = File('${dir.path}/recomendacao_$stamp.html');
    await file.writeAsString(html, encoding: utf8);

    await Share.shareXFiles(
      [
        XFile(
          file.path,
          mimeType: 'text/html',
          name: 'recomendacao_$stamp.html',
        ),
      ],
      subject: 'Recomendacao SoloForte',
      text: 'Relatorio de recomendacao agronomica gerado pelo Caderno de Solo.',
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  static Future<String?> logoToDataUri(String? source) {
    return ImageSourceResolver.toDataUri(source);
  }
}
