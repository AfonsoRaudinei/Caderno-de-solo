import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/pdf_import_service.dart';

void main() {
  test('pipeline real importa PDFs locais por laboratório', () async {
    final dir = Directory(
      '/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/Analise de solo ',
    );
    if (!dir.existsSync()) {
      return;
    }

    final allPdfs = dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.pdf'))
        .toList(growable: false);
    if (allPdfs.isEmpty) {
      return;
    }

    File? findByToken(String token) {
      for (final file in allPdfs) {
        if (file.path.toLowerCase().contains(token.toLowerCase())) {
          return file;
        }
      }
      return null;
    }

    final service = PdfImportService();
    const cases = <_ImportCase>[
      _ImportCase('54215', 'sellar', minSamples: 3),
      _ImportCase('sba24.99401', 'exata_brasil', minSamples: 6),
      _ImportCase('os_237526', 'ibra', minSamples: 10),
      _ImportCase('laudo-1', 'mb', minSamples: 1),
    ];

    var executed = 0;
    for (final c in cases) {
      final file = findByToken(c.fileToken);
      if (file == null) continue;
      executed++;

      final analises = await service.importarArquivoPdf(
        fileBytes: file.readAsBytesSync(),
        fileName: file.path.split('/').last,
        forcedLabId: c.labId,
      );

      expect(
        analises.length,
        greaterThanOrEqualTo(c.minSamples),
        reason:
            'Falha em ${c.labId}: esperado >= ${c.minSamples}, obtido ${analises.length}',
      );

      final groupIds = analises
          .map((a) => a.laudoMetadata?['groupId']?.toString().trim() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      expect(
        groupIds.length,
        1,
        reason:
            'Falha em ${c.labId}: amostras do mesmo PDF devem compartilhar groupId único.',
      );
      final groupTitles = analises
          .map((a) => a.laudoMetadata?['groupTitle']?.toString().trim() ?? '')
          .where((title) => title.isNotEmpty)
          .toSet();
      expect(
        groupTitles.isNotEmpty,
        isTrue,
        reason:
            'Falha em ${c.labId}: groupTitle ausente nas amostras importadas.',
      );
      final sourceNames = analises
          .map((a) =>
              a.laudoMetadata?['sourceFileName']?.toString().trim() ?? '')
          .where((name) => name.isNotEmpty)
          .toSet();
      expect(
        sourceNames.length,
        1,
        reason:
            'Falha em ${c.labId}: sourceFileName deve ser consistente entre as amostras.',
      );
      if (c.labId == 'ibra') {
        expect(
          groupIds.first.startsWith('ibra:'),
          isTrue,
          reason:
              'Falha em IBRA: groupId deve começar com prefixo do laboratório.',
        );
      }
    }

    expect(executed, greaterThanOrEqualTo(3));
  });
}

class _ImportCase {
  final String fileToken;
  final String labId;
  final int minSamples;

  const _ImportCase(this.fileToken, this.labId, {required this.minSamples});
}
