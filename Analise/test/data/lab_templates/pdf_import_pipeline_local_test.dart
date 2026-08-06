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

  test('pipeline MB importa nutrientes do laudo 78416', () async {
    final file = _localSoilPdf('mb_gt_01.pdf');
    if (!file.existsSync()) return;

    final analises = await PdfImportService().importarArquivoPdf(
      fileBytes: file.readAsBytesSync(),
      fileName: file.path.split('/').last,
      forcedLabId: 'mb',
    );

    expect(analises.length, 1);
    final amostra = analises.single;
    expect(amostra.numeroAmostra, '78416-1');
    expect(amostra.talhao, 'TH ABACAXI');
    expect(amostra.profundidade, '0-20');
    expect(amostra.phCaCl2!, closeTo(5.8, 0.001));
    expect(amostra.phSmp!, closeTo(6.76, 0.001));
    expect(amostra.materiaOrganica!, closeTo(1.94, 0.001));
    expect(amostra.carbonoOrganico!, closeTo(1.125, 0.001));
    expect(amostra.pMehlich!, closeTo(6.53, 0.001));
    expect(amostra.pResina, isNull);
    expect(amostra.pRem, isNull);
    expect(amostra.s020, isNull);
    expect(amostra.k!, closeTo(31.74 / 391.0, 0.0001));
    expect(amostra.ca!, closeTo(2.95, 0.001));
    expect(amostra.mg!, closeTo(1.02, 0.001));
    expect(amostra.al!, closeTo(0, 0.001));
    expect(amostra.hMaisAl!, closeTo(1.9, 0.001));
    expect(amostra.b, isNull);
    expect(amostra.cu, isNull);
    expect(amostra.fe, isNull);
    expect(amostra.mn, isNull);
    expect(amostra.zn, isNull);
    expect(amostra.argila!, closeTo(420, 0.001));
    expect(amostra.silte!, closeTo(43.6, 0.001));
    expect(amostra.areiaTotal!, closeTo(536.4, 0.001));
  });

  test('pipeline MB importa os PDFs citados com dados essenciais', () async {
    final files = <File>[
      _localSoilPdf('Laudo-1 (1).pdf'),
      _localSoilPdf('Laudo-3 (1).pdf'),
      _localSoilPdf('mb_gt_01.pdf'),
    ].where((file) => file.existsSync()).toList(growable: false);
    if (files.isEmpty) return;

    final service = PdfImportService();
    for (final file in files) {
      final analises = await service.importarArquivoPdf(
        fileBytes: file.readAsBytesSync(),
        fileName: file.path.split('/').last,
        forcedLabId: 'mb',
      );

      expect(
        analises.length,
        1,
        reason: 'Falha em ${file.path}: MB deve importar uma amostra.',
      );

      final amostra = analises.single;
      expect(amostra.numeroAmostra.trim(), isNotEmpty,
          reason: 'Número da amostra ausente em ${file.path}.');
      expect(amostra.talhao.trim(), isNotEmpty,
          reason: 'Talhão ausente em ${file.path}.');
      expect(amostra.profundidade.trim(), isNotEmpty,
          reason: 'Profundidade ausente em ${file.path}.');
      expect(amostra.phCaCl2, isNotNull,
          reason: 'pH CaCl2 ausente em ${file.path}.');
      expect(amostra.pMehlich, isNotNull,
          reason: 'P Mehlich ausente em ${file.path}.');
      expect(amostra.k, isNotNull,
          reason: 'K convertido ausente em ${file.path}.');
      expect(amostra.ca, isNotNull, reason: 'Ca ausente em ${file.path}.');
      expect(amostra.mg, isNotNull, reason: 'Mg ausente em ${file.path}.');
      expect(amostra.hMaisAl, isNotNull,
          reason: 'H+Al ausente em ${file.path}.');
      expect(amostra.argila, isNotNull,
          reason: 'Argila ausente em ${file.path}.');
      expect(amostra.silte, isNotNull,
          reason: 'Silte ausente em ${file.path}.');
      expect(amostra.areiaTotal, isNotNull,
          reason: 'Areia total ausente em ${file.path}.');
    }
  });
}

File _localSoilPdf(String fileName) {
  return File(
    '/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/Analise de solo /$fileName',
  );
}

class _ImportCase {
  final String fileToken;
  final String labId;
  final int minSamples;

  const _ImportCase(this.fileToken, this.labId, {required this.minSamples});
}
