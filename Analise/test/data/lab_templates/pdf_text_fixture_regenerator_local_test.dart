import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/pdf_text_extractor.dart';

const _runFixtureGeneration =
    bool.fromEnvironment('RUN_GENERATE_TEXT_FIXTURES');

void main() {
  test(
    'gera fixtures de texto nativo para MB, IBRA e Sellar',
    skip: !_runFixtureGeneration,
    () async {
      const extractor = PdfTextExtractorService();

      for (final entry in _fixtureCases) {
        final pdf = File(entry.pdfPath);
        expect(pdf.existsSync(), isTrue, reason: 'PDF ausente: ${pdf.path}');

        final result = await extractor.extract(pdf.readAsBytesSync());
        final output = File(entry.outputPath);
        output.parent.createSync(recursive: true);
        output.writeAsStringSync('${result.text.trimRight()}\n');

        expect(output.existsSync(), isTrue);
        expect(result.text.trim(), isNotEmpty,
            reason: 'Texto vazio para ${entry.pdfPath}');
      }
    },
  );
}

const _fixtureCases = <_FixtureCase>[
  _FixtureCase(
    pdfPath:
        '/Users/raudineisilvapereira/Documents/Trabalho/Analise de solo/mb_gt_01.pdf',
    outputPath:
        '/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/data/lab_templates/fixtures/mb_78416_2025_native.txt',
  ),
  _FixtureCase(
    pdfPath:
        '/Users/raudineisilvapereira/Documents/Trabalho/Analise de solo/Agrofarm___Produtos_Agroquimicos_Ltda_(RE_1.347325.1_-_OS_237526).pdf',
    outputPath:
        '/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/data/lab_templates/fixtures/ibra_237526_2025_native.txt',
  ),
  _FixtureCase(
    pdfPath:
        '/Users/raudineisilvapereira/Documents/Trabalho/Analise de solo/José Augusto Miranda - Faz Santo Antônio- 54215 - 54217.pdf',
    outputPath:
        '/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/data/lab_templates/fixtures/sellar_6077_2025_native.txt',
  ),
  _FixtureCase(
    pdfPath:
        '/Users/raudineisilvapereira/Documents/Trabalho/Analise de solo/nova José Augusto Miranda - Faz Montanha.pdf',
    outputPath:
        '/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/test/data/lab_templates/fixtures/sellar_4517_2026_native.txt',
  ),
];

class _FixtureCase {
  final String pdfPath;
  final String outputPath;

  const _FixtureCase({
    required this.pdfPath,
    required this.outputPath,
  });
}
