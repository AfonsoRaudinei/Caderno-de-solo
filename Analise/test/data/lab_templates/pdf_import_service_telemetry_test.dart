import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/lab_pdf_parser.dart';
import 'package:soloforte/data/lab_templates/pdf_import_service.dart';
import 'package:soloforte/data/lab_templates/pdf_text_extractor.dart';
import 'package:soloforte/features/analise/application/observability/analise_telemetry.dart';

class _MemorySink implements AnaliseTelemetrySink {
  final List<Map<String, Object?>> events = [];

  @override
  void emit(Map<String, Object?> event) {
    events.add(Map<String, Object?>.from(event));
  }
}

class _FakeExtractor extends PdfTextExtractorService {
  final PdfTextExtractionResult result;

  const _FakeExtractor(this.result);

  @override
  Future<PdfTextExtractionResult> extract(Uint8List bytes) async => result;
}

class _FakeParser extends LabPdfParserService {
  final LabPdfParseResult result;

  const _FakeParser(this.result);

  @override
  LabPdfParseResult parse({
    required String labId,
    required String text,
    required String sourceName,
  }) {
    return result;
  }
}

void main() {
  group('PdfImportService telemetry', () {
    test('emite trilha completa de sucesso na importação', () async {
      final sink = _MemorySink();
      final telemetry = AnaliseTelemetry(
        sink: sink,
        operationIdFactory: () => 'op-import-ok',
      );
      const extractor = _FakeExtractor(
        PdfTextExtractionResult(
          text:
              'Sellar Análises Agrícolas Laudo nº 123/2026 Número Sellar Análise granulométrica Extratores: Mehlich',
          route: PdfTextExtractionRoute.native,
          qualityScore: 0.91,
          nativeScore: 0.91,
          ocrScore: null,
        ),
      );
      const parser = _FakeParser(
        LabPdfParseResult(
          labId: 'sellar',
          warnings: <String>[],
          laudo: <String, dynamic>{
            'fonte': 'Sellar',
            'laudoNumero': '123',
            'dataGeracao': '2026-04-06T10:00:00.000Z',
            'proprietario': 'Produtor X',
            'solicitante': 'Solicitante X',
            'propriedade': 'Fazenda X',
            'municipio': 'Cidade X',
            'cultura': 'soja',
            'amostras': <Map<String, dynamic>>[
              <String, dynamic>{
                'numeroSellar': 'A1',
                'identificacao': 'T-01',
                'profundidade': '0-20',
                'phCaCl2': 5.4,
                'k': 0.31,
                'ca': 3.1,
                'mg': 1.2,
              },
            ],
          },
        ),
      );
      final service = PdfImportService(
        extractor: extractor,
        parser: parser,
        telemetry: telemetry,
      );

      final result = await service.importarArquivoPdf(
        fileBytes: Uint8List.fromList(<int>[1, 2, 3, 4]),
        fileName: 'laudo-sellar.pdf',
      );

      expect(result, hasLength(1));
      final metadata = result.first.laudoMetadata;
      expect(metadata, isNotNull);
      expect((metadata?['groupId'] as String?)?.isNotEmpty, isTrue);
      expect((metadata?['groupTitle'] as String?)?.isNotEmpty, isTrue);
      expect(metadata?['sourceFileName'], 'laudo-sellar.pdf');
      expect((metadata?['importedAt'] as String?)?.isNotEmpty, isTrue);
      final names = sink.events.map((e) => e['eventName']).toList();
      expect(
        names,
        containsAllInOrder(<String>[
          AnaliseTelemetryEvents.importStarted,
          AnaliseTelemetryEvents.importExtractFinished,
          AnaliseTelemetryEvents.importDetectFinished,
          AnaliseTelemetryEvents.importParseFinished,
          AnaliseTelemetryEvents.importValidateFinished,
          AnaliseTelemetryEvents.importCompleted,
        ]),
      );
      expect(names, isNot(contains(AnaliseTelemetryEvents.importFailed)));
      for (final event in sink.events) {
        expect(event['operationId'], 'op-import-ok');
      }
    });

    test('emite fallback_opened quando confiança é baixa', () async {
      final sink = _MemorySink();
      final telemetry = AnaliseTelemetry(
        sink: sink,
        operationIdFactory: () => 'op-import-low-confidence',
      );
      const extractor = _FakeExtractor(
        PdfTextExtractionResult(
          text: 'Exata Brasil',
          route: PdfTextExtractionRoute.native,
          qualityScore: 0.5,
          nativeScore: 0.5,
          ocrScore: null,
        ),
      );
      const parser = _FakeParser(
        LabPdfParseResult(
          labId: 'exata_brasil',
          warnings: <String>[],
          laudo: <String, dynamic>{
            'amostras': <Map<String, dynamic>>[],
          },
        ),
      );
      final service = PdfImportService(
        extractor: extractor,
        parser: parser,
        telemetry: telemetry,
      );

      try {
        await service.importarArquivoPdf(
          fileBytes: Uint8List.fromList(<int>[9, 8, 7]),
          fileName: 'laudo-baixa-confianca.pdf',
        );
        fail('Era esperado LabConfiancaBaixaException');
      } on LabConfiancaBaixaException catch (e) {
        expect(e.operationId, 'op-import-low-confidence');
      }

      final names = sink.events.map((e) => e['eventName']).toList();
      expect(names, contains(AnaliseTelemetryEvents.importFallbackOpened));
      expect(names, isNot(contains(AnaliseTelemetryEvents.importFailed)));
    });

    test('emite bloqueio de qualidade quando campos essenciais faltam', () async {
      final sink = _MemorySink();
      final telemetry = AnaliseTelemetry(
        sink: sink,
        operationIdFactory: () => 'op-import-quality-blocked',
      );
      const extractor = _FakeExtractor(
        PdfTextExtractionResult(
          text:
              'Exata Brasil Relatório de Ensaio Nº 999.2026.V0.U sample_id_sba K (NH4Cl)',
          route: PdfTextExtractionRoute.native,
          qualityScore: 0.88,
          nativeScore: 0.88,
          ocrScore: null,
        ),
      );
      const parser = _FakeParser(
        LabPdfParseResult(
          labId: 'exata_brasil',
          warnings: <String>[],
          laudo: <String, dynamic>{
            'fonte': 'Exata Brasil',
            'relatorio': '999.2026.V0.U',
            'dataEmissao': '2026-04-06',
            'proprietario': 'Produtor X',
            'propriedade': 'Fazenda X',
            'laboratorio': 'Exata Brasil',
            'amostras': <Map<String, dynamic>>[
              <String, dynamic>{
                'numeroAmostra': 'SBA26.000001',
                'talhao': 'T-01',
                'profundidade': '0-20',
                'phCaCl2': 5.4,
                'k_mgdm3': 70.0,
              },
            ],
          },
        ),
      );
      final service = PdfImportService(
        extractor: extractor,
        parser: parser,
        telemetry: telemetry,
      );

      await expectLater(
        () => service.importarArquivoPdf(
          fileBytes: Uint8List.fromList(<int>[1, 2, 3]),
          fileName: 'exata-incompleto.pdf',
          forcedLabId: 'exata_brasil',
        ),
        throwsA(isA<ImportacaoQualidadeBaixaException>()),
      );

      final names = sink.events.map((e) => e['eventName']).toList();
      expect(names, contains(AnaliseTelemetryEvents.importQualityBlocked));
      expect(names, isNot(contains(AnaliseTelemetryEvents.importCompleted)));

      final qualityEvent = sink.events.firstWhere(
        (e) => e['eventName'] == AnaliseTelemetryEvents.importQualityBlocked,
      );
      expect(qualityEvent['errorCode'], 'IMPORT_LOW_QUALITY');
      expect(qualityEvent['labId'], 'exata_brasil');
    });
  });
}
