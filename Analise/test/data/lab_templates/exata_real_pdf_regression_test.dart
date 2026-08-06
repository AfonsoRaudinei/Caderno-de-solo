import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/pdf_import_service.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

void main() {
  group('Exata Brasil PDFs reais', () {
    test('importa EDUARDO JOSE BRUXEL DE SA conferindo nutrientes essenciais',
        () async {
      final file = File(
        '/Users/raudineisilvapereira/Documents/Trabalho/Analise de solo/EDUARDO JOSE BRUXEL DE SA.pdf',
      );
      if (!file.existsSync()) {
        markTestSkipped('PDF local ausente: ${file.path}');
        return;
      }

      final analises = await PdfImportService().importarArquivoPdf(
        fileBytes: file.readAsBytesSync(),
        fileName: file.path.split('/').last,
        forcedLabId: 'exata_brasil',
      );

      expect(analises, hasLength(4));
      for (final analise in analises) {
        _expectAllFilled(
          analise,
          fields: const [
            'phCaCl2',
            'ca',
            'mg',
            'al',
            'hMaisAl',
            'k',
            'pMehlich',
            'pRem',
            's020',
            'materiaOrganica',
            'carbonoOrganico',
            'b',
            'cu',
            'fe',
            'mn',
            'zn',
            'na',
            'argila',
            'silte',
            'areiaTotal',
          ],
        );
      }
      final talhao1 = analises.first;
      expect(talhao1.numeroAmostra, 'SBA24.124624');
      expect(talhao1.talhao, 'TALHÃO 1');
      expect(talhao1.profundidade, '0-20');
      expect(talhao1.phCaCl2, closeTo(5.74, 0.001));
      expect(talhao1.ca, closeTo(2.94, 0.001));
      expect(talhao1.mg, closeTo(1.21, 0.001));
      expect(talhao1.al, closeTo(0.0, 0.001));
      expect(talhao1.hMaisAl, closeTo(1.73, 0.001));
      expect(talhao1.k, closeTo(67.94 / 391.0, 0.0001));
      expect(talhao1.pMehlich, closeTo(5.68, 0.001));
      expect(talhao1.pRem, closeTo(29.19, 0.001));
      expect(talhao1.s020, closeTo(3.40, 0.001));
      expect(talhao1.materiaOrganica, closeTo(2.078, 0.001));
      expect(talhao1.carbonoOrganico, closeTo(1.205, 0.001));
      expect(talhao1.b, closeTo(0.34, 0.001));
      expect(talhao1.cu, closeTo(1.02, 0.001));
      expect(talhao1.fe, closeTo(10.68, 0.001));
      expect(talhao1.mn, closeTo(2.46, 0.001));
      expect(talhao1.zn, closeTo(0.75, 0.001));
      expect(talhao1.na, closeTo(3.07, 0.001));
      expect(talhao1.argila, closeTo(419.0, 0.001));
      expect(talhao1.silte, closeTo(54.0, 0.001));
      expect(talhao1.areiaTotal, closeTo(527.0, 0.001));
    });

    test('importa Teste Andre Luiz conferindo nutrientes essenciais', () async {
      final file = File(
        '/Users/raudineisilvapereira/Documents/Trabalho/Analise de solo/ Teste André Luiz .pdf',
      );
      if (!file.existsSync()) {
        markTestSkipped('PDF local ausente: ${file.path}');
        return;
      }

      final analises = await PdfImportService().importarArquivoPdf(
        fileBytes: file.readAsBytesSync(),
        fileName: file.path.split('/').last,
        forcedLabId: 'exata_brasil',
      );

      expect(analises, hasLength(19));
      for (final analise in analises) {
        _expectAllFilled(
          analise,
          fields: const [
            'phCaCl2',
            'ca',
            'mg',
            'al',
            'hMaisAl',
            'k',
            'pMehlich',
            'cu',
            'fe',
            'mn',
            'zn',
            'na',
            'argila',
            'silte',
            'areiaTotal',
          ],
        );
      }
      final profundidade2040 = analises.first;
      expect(profundidade2040.numeroAmostra, 'SBA25.147312');
      expect(profundidade2040.talhao, 'T01');
      expect(profundidade2040.profundidade, '20-40');
      expect(profundidade2040.phCaCl2, closeTo(5.54, 0.001));
      expect(profundidade2040.ca, closeTo(1.91, 0.001));
      expect(profundidade2040.mg, closeTo(1.15, 0.001));
      expect(profundidade2040.al, closeTo(0.0, 0.001));
      expect(profundidade2040.hMaisAl, closeTo(3.35, 0.001));
      expect(profundidade2040.k, closeTo(50.70 / 391.0, 0.0001));
      expect(profundidade2040.pMehlich, closeTo(1.41, 0.001));
      expect(profundidade2040.s020, closeTo(24.57, 0.001));
      expect(profundidade2040.cu, closeTo(0.10, 0.001));
      expect(profundidade2040.fe, closeTo(42.55, 0.001));
      expect(profundidade2040.mn, closeTo(20.15, 0.001));
      expect(profundidade2040.zn, closeTo(0.25, 0.001));
      expect(profundidade2040.na, closeTo(1.66, 0.001));
      expect(profundidade2040.argila, closeTo(540.0, 0.001));
      expect(profundidade2040.silte, closeTo(75.0, 0.001));
      expect(profundidade2040.areiaTotal, closeTo(385.0, 0.001));
    });
  });
}

void _expectAllFilled(
  AnaliseSolo analise, {
  required List<String> fields,
}) {
  for (final field in fields) {
    final value = switch (field) {
      'phCaCl2' => analise.phCaCl2,
      'ca' => analise.ca,
      'mg' => analise.mg,
      'al' => analise.al,
      'hMaisAl' => analise.hMaisAl,
      'k' => analise.k,
      'pMehlich' => analise.pMehlich,
      'pRem' => analise.pRem,
      's020' => analise.s020,
      'materiaOrganica' => analise.materiaOrganica,
      'carbonoOrganico' => analise.carbonoOrganico,
      'b' => analise.b,
      'cu' => analise.cu,
      'fe' => analise.fe,
      'mn' => analise.mn,
      'zn' => analise.zn,
      'na' => analise.na,
      'argila' => analise.argila,
      'silte' => analise.silte,
      'areiaTotal' => analise.areiaTotal,
      _ => throw ArgumentError('Campo nao mapeado no teste: $field'),
    };
    expect(
      value,
      isNotNull,
      reason: 'Campo $field veio vazio na amostra ${analise.numeroAmostra}.',
    );
  }
}
