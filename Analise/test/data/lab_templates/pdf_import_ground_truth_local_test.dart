import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/pdf_import_service.dart';

const _minTotalPdfs = 20;
const _minByLab = 5;
const _globalSuccessTarget = 0.95;
const _labSuccessTarget = 0.90;
const _essentialCoverageTarget = 1.0;

const _supportedLabs = <String>{
  'sellar',
  'exata_brasil',
  'ibra',
  'mb',
};

const _requiredColumns = <String>{
  'arquivo_pdf',
  'lab_esperado',
  'amostras_esperadas',
  'status_validacao_manual',
  'perfil_qualidade',
};

const _allowedQualityProfiles = <String>{
  'bom',
  'medio',
  'ruim',
};

class _GroundTruthRow {
  final int lineNumber;
  final String arquivoPdf;
  final String labEsperado;
  final int amostrasEsperadas;
  final String statusValidacaoManual;
  final String perfilQualidade;

  const _GroundTruthRow({
    required this.lineNumber,
    required this.arquivoPdf,
    required this.labEsperado,
    required this.amostrasEsperadas,
    required this.statusValidacaoManual,
    required this.perfilQualidade,
  });
}

class _LabStats {
  int attempted = 0;
  int ok = 0;
  final List<String> failures = <String>[];

  int get failed => attempted - ok;
  double get successRate => attempted == 0 ? 0 : ok / attempted;
}

void main() {
  test('ground truth local: aceite P0 com 20+ PDFs reais e 95%+ de sucesso',
      () async {
    final csv = File(
      '/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/docs/importacao/ground_truth_lote_local.csv',
    );
    final pdfDir = Directory(
      '/Users/raudineisilvapereira/dev/Caderno de Solo/Analise/Analise de solo ',
    );
    expect(
      csv.existsSync(),
      isTrue,
      reason: 'Ground truth ausente: ${csv.path}',
    );
    expect(
      pdfDir.existsSync(),
      isTrue,
      reason: 'Diretório de PDFs ausente: ${pdfDir.path}',
    );

    final lines = csv
        .readAsLinesSync()
        .where((line) => line.trim().isNotEmpty)
        .toList(growable: false);
    expect(
      lines.length,
      greaterThan(1),
      reason: 'CSV de ground truth sem dados.',
    );

    final files = pdfDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.pdf'))
        .toList(growable: false);
    expect(
      files.isNotEmpty,
      isTrue,
      reason: 'Nenhum PDF encontrado em ${pdfDir.path}',
    );

    final filesByName = <String, File>{
      for (final f in files) f.path.split('/').last: f,
    };

    final header = _parseCsvRow(lines.first)
        .map((entry) => entry.trim().toLowerCase())
        .toList(growable: false);
    final headerIndex = <String, int>{
      for (var i = 0; i < header.length; i++) header[i]: i,
    };

    final preflightErrors = <String>[];
    for (final required in _requiredColumns) {
      if (!headerIndex.containsKey(required)) {
        preflightErrors.add(
          'CSV sem coluna obrigatória "$required".',
        );
      }
    }

    final rows = <_GroundTruthRow>[];
    for (var i = 1; i < lines.length; i++) {
      final rowNumber = i + 1;
      final parsed = _parseCsvRow(lines[i]);
      if (parsed.length < header.length) {
        preflightErrors.add(
          'Linha $rowNumber inválida: número de colunas insuficiente.',
        );
        continue;
      }

      String value(String key) {
        final idx = headerIndex[key];
        if (idx == null || idx >= parsed.length) return '';
        return parsed[idx].trim();
      }

      final arquivoPdf = value('arquivo_pdf');
      final labEsperado = value('lab_esperado').toLowerCase();
      final amostrasEsperadasRaw = value('amostras_esperadas');
      final status = value('status_validacao_manual').toLowerCase();
      final perfilQualidade = value('perfil_qualidade').toLowerCase();

      if (arquivoPdf.isEmpty) {
        preflightErrors.add('Linha $rowNumber: arquivo_pdf vazio.');
      }
      if (!_supportedLabs.contains(labEsperado)) {
        preflightErrors.add(
          'Linha $rowNumber: lab_esperado "$labEsperado" inválido.',
        );
      }
      final amostrasEsperadas = int.tryParse(amostrasEsperadasRaw);
      if (amostrasEsperadas == null || amostrasEsperadas <= 0) {
        preflightErrors.add(
          'Linha $rowNumber: amostras_esperadas inválido "$amostrasEsperadasRaw".',
        );
      }
      if (status != 'validado') {
        preflightErrors.add(
          'Linha $rowNumber: status_validacao_manual deve ser "validado".',
        );
      }
      if (!_allowedQualityProfiles.contains(perfilQualidade)) {
        preflightErrors.add(
          'Linha $rowNumber: perfil_qualidade "$perfilQualidade" inválido.',
        );
      }
      if (arquivoPdf.isNotEmpty && !filesByName.containsKey(arquivoPdf)) {
        preflightErrors.add(
          'Linha $rowNumber: arquivo não encontrado no diretório local -> $arquivoPdf',
        );
      }

      if (arquivoPdf.isNotEmpty &&
          _supportedLabs.contains(labEsperado) &&
          amostrasEsperadas != null &&
          amostrasEsperadas > 0 &&
          status == 'validado' &&
          _allowedQualityProfiles.contains(perfilQualidade) &&
          filesByName.containsKey(arquivoPdf)) {
        rows.add(
          _GroundTruthRow(
            lineNumber: rowNumber,
            arquivoPdf: arquivoPdf,
            labEsperado: labEsperado,
            amostrasEsperadas: amostrasEsperadas,
            statusValidacaoManual: status,
            perfilQualidade: perfilQualidade,
          ),
        );
      }
    }

    final countByLab = <String, int>{
      for (final lab in _supportedLabs) lab: 0,
    };
    final qualityCount = <String, int>{
      for (final q in _allowedQualityProfiles) q: 0,
    };
    for (final row in rows) {
      countByLab[row.labEsperado] = (countByLab[row.labEsperado] ?? 0) + 1;
      qualityCount[row.perfilQualidade] =
          (qualityCount[row.perfilQualidade] ?? 0) + 1;
      if (row.statusValidacaoManual != 'validado') {
        preflightErrors.add(
          'Linha ${row.lineNumber}: status_validacao_manual diferente de validado.',
        );
      }
    }

    if (rows.length < _minTotalPdfs) {
      preflightErrors.add(
        'Total de PDFs no ground truth (${rows.length}) abaixo do mínimo de $_minTotalPdfs.',
      );
    }

    for (final lab in _supportedLabs) {
      final count = countByLab[lab] ?? 0;
      if (count < _minByLab) {
        preflightErrors.add(
          'Distribuição insuficiente para $lab: $count (mínimo $_minByLab).',
        );
      }
    }

    for (final quality in _allowedQualityProfiles) {
      final count = qualityCount[quality] ?? 0;
      if (count <= 0) {
        preflightErrors.add(
          'Lote sem perfil_qualidade="$quality". Inclua PDFs bons, médios e ruins.',
        );
      }
    }

    if (preflightErrors.isNotEmpty) {
      fail(_composePreflightError(preflightErrors));
    }

    final service = PdfImportService();
    final statsByLab = <String, _LabStats>{
      for (final lab in _supportedLabs) lab: _LabStats(),
    };

    for (final row in rows) {
      final file = filesByName[row.arquivoPdf]!;
      final labStats = statsByLab[row.labEsperado]!;
      labStats.attempted++;
      try {
        final analises = await service.importarArquivoPdf(
          fileBytes: file.readAsBytesSync(),
          fileName: row.arquivoPdf,
          forcedLabId: row.labEsperado,
        );
        final essentialCoverage =
            _essentialCoverage(analises, labId: row.labEsperado);
        if (analises.length >= row.amostrasEsperadas &&
            analises.isNotEmpty &&
            essentialCoverage >= _essentialCoverageTarget) {
          labStats.ok++;
        } else {
          labStats.failures.add(
            '${row.arquivoPdf} (linha ${row.lineNumber}) -> amostras obtidas ${analises.length}, esperado >= ${row.amostrasEsperadas}; cobertura essencial ${(essentialCoverage * 100).toStringAsFixed(2)}%',
          );
        }
      } catch (e) {
        labStats.failures.add(
          '${row.arquivoPdf} (linha ${row.lineNumber}) -> exceção: $e',
        );
      }
    }

    final report =
        _buildReport(statsByLab: statsByLab, totalExpected: rows.length);
    // ignore: avoid_print
    print(report);

    final totalAttempted = statsByLab.values.fold<int>(
      0,
      (sum, s) => sum + s.attempted,
    );
    final totalOk = statsByLab.values.fold<int>(
      0,
      (sum, s) => sum + s.ok,
    );
    final globalRate = totalAttempted == 0 ? 0 : totalOk / totalAttempted;

    final acceptanceErrors = <String>[];
    if (globalRate < _globalSuccessTarget) {
      acceptanceErrors.add(
        'Taxa global abaixo do alvo: ${(globalRate * 100).toStringAsFixed(2)}% < ${(_globalSuccessTarget * 100).toStringAsFixed(0)}%',
      );
    }

    for (final lab in _supportedLabs) {
      final stats = statsByLab[lab]!;
      if (stats.attempted == 0) {
        acceptanceErrors.add('Laboratório $lab sem execuções.');
        continue;
      }
      if (stats.successRate < _labSuccessTarget) {
        acceptanceErrors.add(
          'Taxa do laboratório $lab abaixo do mínimo: ${(stats.successRate * 100).toStringAsFixed(2)}% < ${(_labSuccessTarget * 100).toStringAsFixed(0)}%',
        );
      }
    }

    if (acceptanceErrors.isNotEmpty) {
      fail(
        '$report\n\nFalhas de aceite:\n- ${acceptanceErrors.join('\n- ')}',
      );
    }
  });
}

String _buildReport({
  required Map<String, _LabStats> statsByLab,
  required int totalExpected,
}) {
  final buffer = StringBuffer()
    ..writeln('=== Ground Truth Import Report ===')
    ..writeln('Total esperado no lote: $totalExpected')
    ..writeln(
      'Meta: total >= $_minTotalPdfs | por lab >= $_minByLab | global >= ${(100 * _globalSuccessTarget).toStringAsFixed(0)}% | por lab >= ${(100 * _labSuccessTarget).toStringAsFixed(0)}%',
    );

  var totalAttempted = 0;
  var totalOk = 0;
  for (final lab in _supportedLabs) {
    final stats = statsByLab[lab]!;
    totalAttempted += stats.attempted;
    totalOk += stats.ok;
    buffer.writeln(
      '[lab=$lab] attempted=${stats.attempted} ok=${stats.ok} failed=${stats.failed} successRate=${(stats.successRate * 100).toStringAsFixed(2)}%',
    );
  }

  final globalRate = totalAttempted == 0 ? 0 : totalOk / totalAttempted;
  buffer.writeln(
    '[global] attempted=$totalAttempted ok=$totalOk failed=${totalAttempted - totalOk} successRate=${(globalRate * 100).toStringAsFixed(2)}%',
  );

  final failures = <String>[];
  for (final lab in _supportedLabs) {
    final stats = statsByLab[lab]!;
    for (final failure in stats.failures) {
      failures.add('[$lab] $failure');
    }
  }
  if (failures.isNotEmpty) {
    buffer.writeln('Falhas detalhadas:');
    for (final failure in failures) {
      buffer.writeln('- $failure');
    }
  }
  return buffer.toString().trimRight();
}

String _composePreflightError(List<String> errors) {
  final buffer = StringBuffer()
    ..writeln('Pré-validação do ground truth falhou:')
    ..writeln('- ${errors.join('\n- ')}');
  return buffer.toString().trimRight();
}

List<String> _parseCsvRow(String raw) {
  final out = <String>[];
  var current = '';
  var inQuotes = false;

  for (var i = 0; i < raw.length; i++) {
    final ch = raw[i];
    if (ch == '"') {
      inQuotes = !inQuotes;
      continue;
    }
    if (ch == ',' && !inQuotes) {
      out.add(current);
      current = '';
      continue;
    }
    current += ch;
  }

  out.add(current);
  return out.map((e) => e.trim()).toList(growable: false);
}

double _essentialCoverage(
  List<dynamic> analises, {
  required String labId,
}) {
  final requiredFields = switch (labId) {
    'ibra' => const {'phCaCl2', 'pResina', 'k', 'ca', 'mg'},
    'sellar' || 'exata_brasil' || 'mb' => const {'phCaCl2', 'k', 'ca', 'mg'},
    _ => const {'phCaCl2', 'k'},
  };

  if (analises.isEmpty || requiredFields.isEmpty) {
    return 1.0;
  }

  var total = 0;
  var filled = 0;
  for (final analise in analises) {
    for (final field in requiredFields) {
      total++;
      final value = switch (field) {
        'phCaCl2' => analise.phCaCl2,
        'pResina' => analise.pResina,
        'k' => analise.k,
        'ca' => analise.ca,
        'mg' => analise.mg,
        _ => null,
      };
      if (value != null) {
        filled++;
      }
    }
  }
  return total == 0 ? 1.0 : filled / total;
}
