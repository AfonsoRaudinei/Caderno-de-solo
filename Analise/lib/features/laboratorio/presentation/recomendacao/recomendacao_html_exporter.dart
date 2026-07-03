import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soloforte/domain/export/recomendacao_export_context.dart';
import 'package:soloforte/features/laboratorio/services/recomendacao_html_renderer.dart';

/// Gera e compartilha relatório HTML de recomendação.
class RecomendacaoHtmlExporter {
  const RecomendacaoHtmlExporter({
    RecomendacaoHtmlRenderer? renderer,
  }) : _renderer = renderer ?? const RecomendacaoHtmlRenderer();

  final RecomendacaoHtmlRenderer _renderer;

  Future<void> exportar(RecomendacaoExportContext exportContext) async {
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
    );
  }

  /// Baixa logo remoto e retorna data URI, ou null se indisponível.
  static Future<String?> logoToDataUri(String? url) async {
    if (url == null || url.trim().isEmpty) return null;
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) return null;
      final bytes = await consolidateHttpClientResponseBytes(response);
      final mime =
          _mimeFromBytes(response.headers.contentType?.mimeType, bytes);
      final b64 = base64Encode(bytes);
      return 'data:$mime;base64,$b64';
    } catch (e) {
      debugPrint('Logo download failed: $e');
      return null;
    } finally {
      client.close(force: true);
    }
  }

  static String _mimeFromBytes(String? mime, List<int> bytes) {
    if (mime != null && mime.contains('/')) return mime;
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    return 'image/png';
  }
}
