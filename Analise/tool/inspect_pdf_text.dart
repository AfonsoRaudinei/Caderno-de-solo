import 'dart:convert';
import 'dart:io';

import 'package:syncfusion_flutter_pdf/pdf.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Uso: dart run tool/inspect_pdf_text.dart <arquivo.pdf> [max_chars]');
    exit(64);
  }

  final file = File(args[0]);
  if (!file.existsSync()) {
    stderr.writeln('Arquivo não encontrado: ${file.path}');
    exit(66);
  }

  final maxChars = args.length > 1 ? int.tryParse(args[1]) ?? 12000 : 12000;

  final bytes = file.readAsBytesSync();
  final document = PdfDocument(inputBytes: bytes);
  final extractor = PdfTextExtractor(document);

  final buf = StringBuffer();
  for (int i = 0; i < document.pages.count; i++) {
    final pageNo = i + 1;
    final text = extractor.extractText(startPageIndex: i, endPageIndex: i);
    buf.writeln('----- PAGE $pageNo -----');
    buf.writeln(text);
    buf.writeln();
  }

  document.dispose();

  final all = buf.toString();
  stdout.writeln('Chars: ${all.length}');
  stdout.writeln(all.substring(0, all.length < maxChars ? all.length : maxChars));

  final outPath = '/tmp/pdf_text_${DateTime.now().millisecondsSinceEpoch}.txt';
  File(outPath).writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
    'file': file.path,
    'chars': all.length,
    'preview': all.substring(0, all.length < 4000 ? all.length : 4000),
  }));
  stdout.writeln('Preview JSON: $outPath');
}
