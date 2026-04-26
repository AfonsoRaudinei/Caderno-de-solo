import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final confirm = args.contains('--confirm');
  if (!confirm) {
    stderr.writeln(
      'Uso: dart run tool/export_lab_data_seed.dart --confirm [--out build/seed/analises_seed_bundle.jsonl]',
    );
    stderr.writeln(
      'Objetivo: exportar dataset de seed para operação administrativa fora do runtime do app.',
    );
    exit(64);
  }

  final outArgIndex = args.indexOf('--out');
  final outPath = (outArgIndex >= 0 && outArgIndex + 1 < args.length)
      ? args[outArgIndex + 1]
      : 'build/seed/analises_seed_bundle.jsonl';

  final inputDir = Directory('assets/lab_data');
  if (!inputDir.existsSync()) {
    stderr.writeln('Diretório não encontrado: ${inputDir.path}');
    exit(2);
  }

  final files = inputDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.json'))
      .toList(growable: false)
    ..sort((a, b) => a.path.compareTo(b.path));

  if (files.isEmpty) {
    stderr.writeln('Nenhum arquivo JSON encontrado em ${inputDir.path}.');
    exit(3);
  }

  final outFile = File(outPath);
  outFile.parent.createSync(recursive: true);
  final sink = outFile.openWrite();

  var count = 0;
  for (final file in files) {
    final raw = file.readAsStringSync();
    final decoded = jsonDecode(raw);
    final payload = <String, Object?>{
      'sourceFile': file.path.split('/').last,
      'exportedAtUtc': DateTime.now().toUtc().toIso8601String(),
      'payload': decoded,
    };
    sink.writeln(jsonEncode(payload));
    count++;
  }

  sink.close();
  stdout.writeln('Seed bundle exportado com sucesso.');
  stdout.writeln('Arquivos processados: $count');
  stdout.writeln('Saída: ${outFile.path}');
}
