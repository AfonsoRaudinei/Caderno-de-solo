import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:soloforte/data/lab_templates/exata_brasil_import_service.dart';
import 'package:soloforte/data/lab_templates/ibra_import_service.dart';
import 'package:soloforte/data/lab_templates/lab_detector.dart';
import 'package:soloforte/data/lab_templates/lab_pdf_parser.dart';
import 'package:soloforte/data/lab_templates/mb_import_service.dart';
import 'package:soloforte/data/lab_templates/pdf_text_extractor.dart';
import 'package:soloforte/data/lab_templates/sellar_import_service.dart';
import 'package:soloforte/data/lab_templates/solum_import_service.dart';
import 'package:soloforte/features/analise/application/observability/analise_telemetry.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

/// Exceção: laboratório não reconhecido no texto do PDF.
class LabNaoReconhecidoException implements Exception {
  const LabNaoReconhecidoException();
  final String message = 'Laboratório não reconhecido';

  @override
  String toString() => message;
}

/// Exceção: nenhum package de extração de texto PDF está disponível.
class ExtracacaoIndisponivelException implements Exception {
  const ExtracacaoIndisponivelException();
  final String message =
      'Extração de texto de PDF não disponível neste momento';

  @override
  String toString() => message;
}

class LabConfiancaBaixaException implements Exception {
  final String operationId;
  final String? suggestedLabId;
  final double confidence;
  final List<LabDetectionCandidate> ranking;
  final Uint8List fileBytes;
  final String fileName;
  final List<String> sampleHints;

  const LabConfiancaBaixaException({
    required this.operationId,
    required this.suggestedLabId,
    required this.confidence,
    required this.ranking,
    required this.fileBytes,
    required this.fileName,
    required this.sampleHints,
  });

  @override
  String toString() => 'Detecção de laboratório com baixa confiança';
}

class ImportacaoInvalidaException implements Exception {
  final String message;

  const ImportacaoInvalidaException(this.message);

  @override
  String toString() => message;
}

class ImportacaoQualidadeAmostra {
  final String numeroAmostra;
  final List<String> missingFields;

  const ImportacaoQualidadeAmostra({
    required this.numeroAmostra,
    required this.missingFields,
  });
}

class ImportacaoQualidadeBaixaException implements Exception {
  final String operationId;
  final String labId;
  final String fileName;
  final double essentialCoverage;
  final double overallCoverage;
  final List<ImportacaoQualidadeAmostra> sampleIssues;

  const ImportacaoQualidadeBaixaException({
    required this.operationId,
    required this.labId,
    required this.fileName,
    required this.essentialCoverage,
    required this.overallCoverage,
    required this.sampleIssues,
  });

  String buildSummary({int maxSamples = 3}) {
    final preview = sampleIssues.take(maxSamples).map((issue) {
      final fields = issue.missingFields.join(', ');
      return '${issue.numeroAmostra}: $fields';
    }).join(' | ');
    if (preview.isEmpty) {
      return 'A importação foi bloqueada por baixa qualidade dos campos essenciais.';
    }
    final suffix =
        sampleIssues.length > maxSamples ? ' | +${sampleIssues.length - maxSamples} amostra(s)' : '';
    return 'Campos essenciais ausentes: $preview$suffix';
  }

  @override
  String toString() => buildSummary();
}

class PdfImportService {
  final PdfTextExtractorService _extractor;
  final LabPdfParserService _parser;
  final AnaliseTelemetry _telemetry;

  PdfImportService({
    PdfTextExtractorService extractor = const PdfTextExtractorService(),
    LabPdfParserService parser = const LabPdfParserService(),
    AnaliseTelemetry? telemetry,
  })  : _extractor = extractor,
        _parser = parser,
        _telemetry = telemetry ?? AnaliseTelemetry();

  Future<List<AnaliseSolo>?> importarDePdf({
    String? forcedLabId,
    Uint8List? forcedFileBytes,
    String? forcedFileName,
    String? operationId,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );
    final picked =
        (result == null || result.files.isEmpty) ? null : result.files.first;
    if (picked == null && (forcedFileBytes == null || forcedFileName == null)) {
      return null;
    }

    final fileBytes = forcedFileBytes ??
        picked?.bytes ??
        await _readFileBytes(picked?.path ?? '');
    final fileName = forcedFileName ?? picked?.name ?? 'laudo.pdf';
    if (fileBytes.isEmpty) return null;

    return importarArquivoPdf(
      fileBytes: fileBytes,
      fileName: fileName,
      forcedLabId: forcedLabId,
      operationId: operationId,
    );
  }

  Future<List<AnaliseSolo>> importarArquivoPdf({
    required Uint8List fileBytes,
    required String fileName,
    String? forcedLabId,
    String? operationId,
  }) async {
    final opId = operationId ?? _telemetry.newOperationId();
    final totalWatch = Stopwatch()..start();
    var currentStage = 'extract';
    String? observedLabId = forcedLabId;

    _telemetry.emit(
      eventName: AnaliseTelemetryEvents.importStarted,
      operationId: opId,
      status: 'started',
      labId: forcedLabId,
      context: <String, Object?>{
        'fileExtension': _fileExtension(fileName),
        'bytes': fileBytes.length,
        'forcedLab': forcedLabId != null,
      },
    );

    try {
      final extractWatch = Stopwatch()..start();
      late final PdfTextExtractionResult extraction;
      try {
        extraction = await _extractor.extract(fileBytes);
        _telemetry.emit(
          eventName: AnaliseTelemetryEvents.importExtractFinished,
          operationId: opId,
          status: 'ok',
          durationMs: extractWatch.elapsedMilliseconds,
          confidence: extraction.qualityScore,
          context: <String, Object?>{
            'route': extraction.route.name,
            'nativeScore': extraction.nativeScore,
            'ocrScore': extraction.ocrScore,
            'textLength': extraction.text.length,
          },
        );
      } on Object {
        throw const ExtracacaoIndisponivelException();
      } finally {
        extractWatch.stop();
      }

      currentStage = 'detect';
      final detectWatch = Stopwatch()..start();
      final detection = LabDetector.detectarComConfianca(extraction.text);
      observedLabId = detection.labId ?? observedLabId;
      _telemetry.emit(
        eventName: AnaliseTelemetryEvents.importDetectFinished,
        operationId: opId,
        status: 'ok',
        labId: detection.labId,
        confidence: detection.confidence,
        durationMs: detectWatch.elapsedMilliseconds,
        context: <String, Object?>{
          'forcedLab': forcedLabId != null,
          'forcedLabId': forcedLabId,
          'detectedLab': detection.labId,
          'needsFallback': detection.needsFallback,
          'ranking': detection.ranking
              .map(
                (c) => <String, Object?>{
                  'labId': c.labId,
                  'score': c.score,
                  'confidence': c.confidence,
                  'signals': c.matchedSignals,
                },
              )
              .toList(growable: false),
        },
      );
      detectWatch.stop();

      final selectedLab = forcedLabId ?? detection.labId;
      if (selectedLab == null) {
        throw const LabNaoReconhecidoException();
      }
      observedLabId = selectedLab;

      if (forcedLabId != null) {
        _telemetry.emit(
          eventName: AnaliseTelemetryEvents.importFallbackSelectedLab,
          operationId: opId,
          status: 'selected',
          labId: forcedLabId,
          confidence: detection.confidence,
          context: <String, Object?>{
            'detectedLab': detection.labId,
            'needsFallback': detection.needsFallback,
          },
        );
      }

      if (forcedLabId == null && detection.needsFallback) {
        _telemetry.emit(
          eventName: AnaliseTelemetryEvents.importFallbackOpened,
          operationId: opId,
          status: 'waiting_manual_selection',
          labId: detection.labId,
          confidence: detection.confidence,
          context: <String, Object?>{
            'rankingSize': detection.ranking.length,
          },
        );
        throw LabConfiancaBaixaException(
          operationId: opId,
          suggestedLabId: detection.labId,
          confidence: detection.confidence,
          ranking: detection.ranking,
          fileBytes: fileBytes,
          fileName: fileName,
          sampleHints: _extractSampleHints(extraction.text),
        );
      }

      currentStage = 'parse';
      final parseWatch = Stopwatch()..start();
      late final LabPdfParseResult parsed;
      try {
        parsed = _parser.parse(
          labId: selectedLab,
          text: extraction.text,
          sourceName: fileName,
        );
      } on Object {
        throw const LabNaoReconhecidoException();
      } finally {
        parseWatch.stop();
      }

      _telemetry.emit(
        eventName: AnaliseTelemetryEvents.importParseFinished,
        operationId: opId,
        labId: selectedLab,
        status: 'ok',
        durationMs: parseWatch.elapsedMilliseconds,
        context: <String, Object?>{
          'warnings': parsed.warnings,
          'samples': (parsed.laudo['amostras'] as List?)?.length ?? 0,
        },
      );

      currentStage = 'normalize';
      final importedAt = DateTime.now().toUtc();
      final laudo = Map<String, dynamic>.from(parsed.laudo);
      final groupId = _buildGroupId(
        labId: selectedLab,
        laudo: laudo,
        fileName: fileName,
        importedAt: importedAt,
      );
      final groupTitle = _buildGroupTitle(
        labId: selectedLab,
        laudo: laudo,
        fileName: fileName,
      );
      laudo['groupId'] = groupId;
      laudo['groupTitle'] = groupTitle;
      laudo['importedAt'] = importedAt.toIso8601String();
      laudo['sourceFileName'] = fileName;

      final normalizeWatch = Stopwatch()..start();
      final analises = _importService(selectedLab).fromJson(laudo);
      normalizeWatch.stop();

      currentStage = 'validate';
      final validateWatch = Stopwatch()..start();
      final qualityReport = _evaluateImportQuality(
        analises: analises,
        labId: selectedLab,
        operationId: opId,
        fileName: fileName,
      );
      _validateImportedAnalises(analises);
      _telemetry.emit(
        eventName: AnaliseTelemetryEvents.importValidateFinished,
        operationId: opId,
        labId: selectedLab,
        status: 'ok',
        durationMs: validateWatch.elapsedMilliseconds,
        columnCount: analises.length,
        context: <String, Object?>{
          'essentialCoverage': qualityReport.essentialCoverage,
          'overallCoverage': qualityReport.overallCoverage,
        },
      );
      validateWatch.stop();

      _telemetry.emit(
        eventName: AnaliseTelemetryEvents.importCompleted,
        operationId: opId,
        labId: selectedLab,
        status: 'completed',
        durationMs: totalWatch.elapsedMilliseconds,
        columnCount: analises.length,
        confidence: detection.confidence,
        context: <String, Object?>{
          'route': extraction.route.name,
        },
      );
      return analises;
    } on LabConfiancaBaixaException {
      rethrow;
    } on ImportacaoQualidadeBaixaException {
      rethrow;
    } on Object catch (error) {
      _telemetry.emit(
        eventName: AnaliseTelemetryEvents.importFailed,
        operationId: opId,
        labId: observedLabId,
        status: 'failed',
        durationMs: totalWatch.elapsedMilliseconds,
        errorCode: _importErrorCode(error, stage: currentStage),
        context: <String, Object?>{
          'stage': currentStage,
          'message': error.toString(),
        },
      );
      rethrow;
    } finally {
      totalWatch.stop();
    }
  }

  Future<Uint8List> _readFileBytes(String path) async {
    if (path.trim().isEmpty) return Uint8List(0);
    final file = File(path);
    return file.readAsBytes();
  }

  List<String> _extractSampleHints(String text) {
    final hints = <String>{};
    final patterns = <RegExp>[
      RegExp(r'\b(SBA|SGO)\d{2}\.\d{5,6}\b', caseSensitive: false),
      RegExp(r'\b\d{6}\b'),
      RegExp(r'\b\d{5}\b'),
    ];
    for (final pattern in patterns) {
      for (final match in pattern.allMatches(text)) {
        final value = match.group(0)?.trim();
        if (value != null && value.isNotEmpty) {
          hints.add(value);
        }
        if (hints.length >= 8) break;
      }
      if (hints.length >= 8) break;
    }
    return hints.take(8).toList(growable: false);
  }

  void _validateImportedAnalises(List<AnaliseSolo> analises) {
    if (analises.isEmpty) {
      throw const ImportacaoInvalidaException(
        'Nenhuma amostra válida foi importada',
      );
    }

    for (var i = 0; i < analises.length; i++) {
      final amostra = analises[i];
      if (amostra.numeroAmostra.trim().isEmpty) {
        throw ImportacaoInvalidaException(
          'Amostra A${i + 1} sem número da amostra',
        );
      }
      if (amostra.laboratorio.trim().isEmpty) {
        throw ImportacaoInvalidaException(
          'Amostra A${i + 1} sem laboratório definido',
        );
      }
    }
  }

  _ImportQualityReport _evaluateImportQuality({
    required List<AnaliseSolo> analises,
    required String labId,
    required String operationId,
    required String fileName,
  }) {
    final requiredFields = _requiredFieldsForLab(labId);
    final monitoredFields = _monitoredFieldsForLab(labId);

    if (analises.isEmpty || requiredFields.isEmpty) {
      return const _ImportQualityReport(
        essentialCoverage: 1,
        overallCoverage: 1,
        sampleIssues: <ImportacaoQualidadeAmostra>[],
      );
    }

    final sampleIssues = <ImportacaoQualidadeAmostra>[];
    var requiredTotal = 0;
    var requiredFilled = 0;
    var monitoredTotal = 0;
    var monitoredFilled = 0;

    for (var index = 0; index < analises.length; index++) {
      final analise = analises[index];
      final missingFields = <String>[];

      for (final field in requiredFields) {
        requiredTotal++;
        if (_hasFieldValue(analise, field)) {
          requiredFilled++;
        } else {
          missingFields.add(field);
        }
      }

      for (final field in monitoredFields) {
        monitoredTotal++;
        if (_hasFieldValue(analise, field)) {
          monitoredFilled++;
        }
      }

      if (missingFields.isNotEmpty) {
        final numeroAmostra = analise.numeroAmostra.trim().isEmpty
            ? 'A${index + 1}'
            : analise.numeroAmostra.trim();
        sampleIssues.add(
          ImportacaoQualidadeAmostra(
            numeroAmostra: numeroAmostra,
            missingFields: missingFields,
          ),
        );
      }
    }

    final essentialCoverage =
        requiredTotal == 0 ? 1.0 : requiredFilled / requiredTotal;
    final overallCoverage =
        monitoredTotal == 0 ? 1.0 : monitoredFilled / monitoredTotal;

    if (sampleIssues.isNotEmpty) {
      _telemetry.emit(
        eventName: AnaliseTelemetryEvents.importQualityBlocked,
        operationId: operationId,
        labId: labId,
        status: 'blocked',
        columnCount: analises.length,
        confidence: essentialCoverage,
        errorCode: 'IMPORT_LOW_QUALITY',
        context: <String, Object?>{
          'fileName': fileName,
          'essentialCoverage': essentialCoverage,
          'overallCoverage': overallCoverage,
          'sampleIssues': sampleIssues
              .map((issue) => <String, Object?>{
                    'numeroAmostra': issue.numeroAmostra,
                    'missingFields': issue.missingFields,
                  })
              .toList(growable: false),
        },
      );
      throw ImportacaoQualidadeBaixaException(
        operationId: operationId,
        labId: labId,
        fileName: fileName,
        essentialCoverage: essentialCoverage,
        overallCoverage: overallCoverage,
        sampleIssues: sampleIssues,
      );
    }

    return _ImportQualityReport(
      essentialCoverage: essentialCoverage,
      overallCoverage: overallCoverage,
      sampleIssues: sampleIssues,
    );
  }

  Set<String> _requiredFieldsForLab(String labId) {
    switch (labId) {
      case 'ibra':
        return const {'phCaCl2', 'pResina', 'k', 'ca', 'mg'};
      case 'sellar':
      case 'exata_brasil':
      case 'mb':
      case 'solum':
        return const {'phCaCl2', 'k', 'ca', 'mg'};
      default:
        return const {'phCaCl2', 'k'};
    }
  }

  Set<String> _monitoredFieldsForLab(String labId) {
    switch (labId) {
      case 'ibra':
        return const {
          'phCaCl2',
          'phSmp',
          'pResina',
          'pRem',
          'materiaOrganica',
          'carbonoOrganico',
          'k',
          'ca',
          'mg',
          'al',
          'hMaisAl',
          's020',
          'b',
          'cu',
          'fe',
          'mn',
          'zn',
          'argila',
        };
      case 'exata_brasil':
        return const {
          'phCaCl2',
          'phSmp',
          'pMehlich',
          'pResina',
          'pRem',
          'materiaOrganica',
          'carbonoOrganico',
          'k',
          'ca',
          'mg',
          'al',
          'hMaisAl',
          'na',
          's020',
          'b',
          'cu',
          'fe',
          'mn',
          'zn',
          'argila',
          'silte',
          'areiaTotal',
        };
      case 'mb':
      case 'sellar':
      case 'solum':
      default:
        return const {
          'phCaCl2',
          'phSmp',
          'pMehlich',
          'pResina',
          'pRem',
          'materiaOrganica',
          'k',
          'ca',
          'mg',
          'al',
          'hMaisAl',
          's020',
          'b',
          'cu',
          'fe',
          'mn',
          'zn',
          'argila',
          'silte',
          'areiaTotal',
        };
    }
  }

  bool _hasFieldValue(AnaliseSolo analise, String field) {
    final value = switch (field) {
      'phAgua' => analise.phAgua,
      'phSmp' => analise.phSmp,
      'phCaCl2' => analise.phCaCl2,
      'materiaOrganica' => analise.materiaOrganica,
      'carbonoOrganico' => analise.carbonoOrganico,
      'pMehlich' => analise.pMehlich,
      'pResina' => analise.pResina,
      'pRem' => analise.pRem,
      's020' => analise.s020,
      'k' => analise.k,
      'ca' => analise.ca,
      'mg' => analise.mg,
      'al' => analise.al,
      'hMaisAl' => analise.hMaisAl,
      'na' => analise.na,
      'b' => analise.b,
      'cu' => analise.cu,
      'fe' => analise.fe,
      'mn' => analise.mn,
      'zn' => analise.zn,
      'argila' => analise.argila,
      'silte' => analise.silte,
      'areiaTotal' => analise.areiaTotal,
      _ => null,
    };
    return value != null;
  }

  String _fileExtension(String fileName) {
    final idx = fileName.lastIndexOf('.');
    if (idx <= -1 || idx >= fileName.length - 1) return 'unknown';
    return fileName.substring(idx + 1).toLowerCase();
  }

  String _importErrorCode(Object error, {required String stage}) {
    if (error is ExtracacaoIndisponivelException) {
      return 'IMPORT_EXTRACT_UNAVAILABLE';
    }
    if (error is LabConfiancaBaixaException) {
      return 'IMPORT_LOW_CONFIDENCE';
    }
    if (error is ImportacaoInvalidaException) {
      return 'IMPORT_INVALID_DATA';
    }
    if (error is ImportacaoQualidadeBaixaException) {
      return 'IMPORT_LOW_QUALITY';
    }
    if (stage == 'parse') {
      return 'IMPORT_PARSE_FAILED';
    }
    if (error is LabNaoReconhecidoException) {
      return 'IMPORT_LAB_NOT_RECOGNIZED';
    }
    return 'IMPORT_UNKNOWN_ERROR';
  }

  String _buildGroupId({
    required String labId,
    required Map<String, dynamic> laudo,
    required String fileName,
    required DateTime importedAt,
  }) {
    final ref = _firstGroupRef(laudo);
    final stem = _safeToken(_fileStem(fileName));
    final refToken = _safeToken(ref);
    final timestamp = importedAt
        .toIso8601String()
        .replaceAll(RegExp(r'[:\-\.]'), '')
        .replaceAll('T', '_')
        .replaceAll('Z', '');
    final identity = refToken.isEmpty ? stem : refToken;
    return '$labId:$identity:$timestamp';
  }

  String _buildGroupTitle({
    required String labId,
    required Map<String, dynamic> laudo,
    required String fileName,
  }) {
    final label = _labLabel(labId);
    final ref = _firstGroupRef(laudo);
    if (ref.isNotEmpty) {
      return '$label • O.S. $ref';
    }
    return '$label • ${_fileStem(fileName)}';
  }

  String _firstGroupRef(Map<String, dynamic> laudo) {
    for (final key in const ['os', 'relatorio', 'laudoNumero', 'analise']) {
      final value = laudo[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  String _fileStem(String fileName) {
    final idx = fileName.lastIndexOf('.');
    if (idx <= 0) return fileName;
    return fileName.substring(0, idx);
  }

  String _safeToken(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  String _labLabel(String labId) {
    switch (labId) {
      case 'ibra':
        return 'IBRA';
      case 'exata_brasil':
        return 'Exata Brasil';
      case 'sellar':
        return 'Sellar';
      case 'solum':
        return 'Solum Lab';
      case 'mb':
      case 'mb_agronegocios':
        return 'MB Agro';
      default:
        return labId;
    }
  }

  dynamic _importService(String labId) {
    switch (labId) {
      case 'sellar':
        return const SellarImportService();
      case 'solum':
        return const SolumImportService();
      case 'exata_brasil':
        return const ExataBrasilImportService();
      case 'ibra':
        return const IbraImportService();
      case 'mb':
      case 'mb_agronegocios':
        return const MbImportService();
      default:
        throw const LabNaoReconhecidoException();
    }
  }
}

class _ImportQualityReport {
  final double essentialCoverage;
  final double overallCoverage;
  final List<ImportacaoQualidadeAmostra> sampleIssues;

  const _ImportQualityReport({
    required this.essentialCoverage,
    required this.overallCoverage,
    required this.sampleIssues,
  });
}
