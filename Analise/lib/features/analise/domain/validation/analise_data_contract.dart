import 'dart:math' as math;

import 'package:soloforte/features/analise/domain/models/analise_draft.dart';

const analiseDataContractVersion = '2.0.0';

enum AnaliseFieldType { text, number, enumValue }

enum ValidationSeverity { error, warning }

class CanonicalFieldSchema {
  final String key;
  final String label;
  final AnaliseFieldType type;
  final String? canonicalUnit;
  final double? minValue;
  final double? maxValue;
  final int precision;
  final bool allowEmpty;
  final Set<String> allowedEnumValues;

  const CanonicalFieldSchema({
    required this.key,
    required this.label,
    required this.type,
    this.canonicalUnit,
    this.minValue,
    this.maxValue,
    this.precision = 2,
    this.allowEmpty = true,
    this.allowedEnumValues = const <String>{},
  });
}

class LabValidationProfile {
  final String id;
  final String label;
  final Set<String> requiredFields;
  final Set<String> optionalFields;
  final Set<String> unsupportedFields;

  const LabValidationProfile({
    required this.id,
    required this.label,
    required this.requiredFields,
    required this.optionalFields,
    required this.unsupportedFields,
  });
}

class ValidationIssue {
  final int columnIndex;
  final String fieldKey;
  final String fieldLabel;
  final String code;
  final String message;
  final ValidationSeverity severity;
  final String? currentValue;

  const ValidationIssue({
    required this.columnIndex,
    required this.fieldKey,
    required this.fieldLabel,
    required this.code,
    required this.message,
    required this.severity,
    this.currentValue,
  });

  String get columnLabel => 'A${columnIndex + 1}';
  String get cellLabel => '$columnLabel > $fieldLabel';

  String get cellKey => '$columnIndex:$fieldKey';
}

class ColumnValidationSummary {
  final int columnIndex;
  final List<ValidationIssue> issues;

  const ColumnValidationSummary({
    required this.columnIndex,
    required this.issues,
  });

  int get errorCount =>
      issues.where((i) => i.severity == ValidationSeverity.error).length;
  int get warningCount =>
      issues.where((i) => i.severity == ValidationSeverity.warning).length;
}

class ValidationSnapshot {
  final String version;
  final String labId;
  final List<ValidationIssue> issues;
  final List<Map<String, String>> normalizedColumns;

  const ValidationSnapshot({
    required this.version,
    required this.labId,
    required this.issues,
    required this.normalizedColumns,
  });

  static const empty = ValidationSnapshot(
    version: analiseDataContractVersion,
    labId: '',
    issues: <ValidationIssue>[],
    normalizedColumns: <Map<String, String>>[],
  );

  bool get hasBlockingErrors =>
      issues.any((i) => i.severity == ValidationSeverity.error);
  bool get hasWarnings =>
      issues.any((i) => i.severity == ValidationSeverity.warning);
  bool get hasIssues => issues.isNotEmpty;

  int get totalErrors =>
      issues.where((i) => i.severity == ValidationSeverity.error).length;
  int get totalWarnings =>
      issues.where((i) => i.severity == ValidationSeverity.warning).length;

  List<ValidationIssue> get blockingIssues =>
      issues.where((i) => i.severity == ValidationSeverity.error).toList();

  Map<int, ColumnValidationSummary> get byColumn {
    final grouped = <int, List<ValidationIssue>>{};
    for (final issue in issues) {
      grouped
          .putIfAbsent(issue.columnIndex, () => <ValidationIssue>[])
          .add(issue);
    }
    return grouped.map(
      (columnIndex, columnIssues) => MapEntry(
        columnIndex,
        ColumnValidationSummary(columnIndex: columnIndex, issues: columnIssues),
      ),
    );
  }

  ValidationIssue? issueForCell(int columnIndex, String fieldKey) {
    ValidationIssue? warning;
    for (final issue in issues) {
      if (issue.columnIndex != columnIndex || issue.fieldKey != fieldKey) {
        continue;
      }
      if (issue.severity == ValidationSeverity.error) return issue;
      warning ??= issue;
    }
    return warning;
  }

  Map<String, dynamic> metadataForColumn(int index) {
    final columnIssues = issues
        .where((i) => i.columnIndex == index)
        .map(
          (i) => <String, dynamic>{
            'cell': i.cellLabel,
            'fieldKey': i.fieldKey,
            'code': i.code,
            'message': i.message,
            'severity': i.severity.name,
            'value': i.currentValue,
          },
        )
        .toList(growable: false);

    return <String, dynamic>{
      'dataContractVersion': version,
      'labId': labId,
      'column': 'A${index + 1}',
      'hasBlockingErrors':
          columnIssues.any((e) => (e['severity'] as String) == 'error'),
      'issues': columnIssues,
    };
  }
}

class _NormalizationResult {
  final String? normalizedValue;
  final List<ValidationIssue> issues;

  const _NormalizationResult({
    required this.normalizedValue,
    required this.issues,
  });
}

class AnaliseDataContract {
  static final Map<String, CanonicalFieldSchema> schemaByField = {
    'talhao': const CanonicalFieldSchema(
      key: 'talhao',
      label: 'Talhão',
      type: AnaliseFieldType.text,
      allowEmpty: true,
    ),
    'numeroAmostra': const CanonicalFieldSchema(
      key: 'numeroAmostra',
      label: 'Nº Amostra',
      type: AnaliseFieldType.text,
      allowEmpty: true,
    ),
    'cultura': const CanonicalFieldSchema(
      key: 'cultura',
      label: 'Cultura',
      type: AnaliseFieldType.enumValue,
      allowEmpty: true,
      allowedEnumValues: {
        'soja',
        'milho',
        'feijão',
        'feijao',
        'algodão',
        'algodao',
        'arroz',
        'sorgo',
      },
    ),
    'profundidade': const CanonicalFieldSchema(
      key: 'profundidade',
      label: 'Profundidade',
      type: AnaliseFieldType.text,
      canonicalUnit: 'cm',
      allowEmpty: false,
    ),
    'latitude': const CanonicalFieldSchema(
      key: 'latitude',
      label: 'Latitude',
      type: AnaliseFieldType.number,
      minValue: -90,
      maxValue: 90,
      precision: 6,
    ),
    'longitude': const CanonicalFieldSchema(
      key: 'longitude',
      label: 'Longitude',
      type: AnaliseFieldType.number,
      minValue: -180,
      maxValue: 180,
      precision: 6,
    ),
    'descricaoLocal': const CanonicalFieldSchema(
      key: 'descricaoLocal',
      label: 'Descrição',
      type: AnaliseFieldType.text,
    ),
    'argila': const CanonicalFieldSchema(
      key: 'argila',
      label: 'Argila',
      type: AnaliseFieldType.number,
      canonicalUnit: 'g/kg',
      minValue: 0,
      maxValue: 1000,
      precision: 1,
    ),
    'silte': const CanonicalFieldSchema(
      key: 'silte',
      label: 'Silte',
      type: AnaliseFieldType.number,
      canonicalUnit: 'g/kg',
      minValue: 0,
      maxValue: 1000,
      precision: 1,
    ),
    'areiaTotal': const CanonicalFieldSchema(
      key: 'areiaTotal',
      label: 'Areia Total',
      type: AnaliseFieldType.number,
      canonicalUnit: 'g/kg',
      minValue: 0,
      maxValue: 1000,
      precision: 1,
    ),
    'phAgua': const CanonicalFieldSchema(
      key: 'phAgua',
      label: 'pH Água',
      type: AnaliseFieldType.number,
      minValue: 0,
      maxValue: 14,
      precision: 2,
    ),
    'phCaCl2': const CanonicalFieldSchema(
      key: 'phCaCl2',
      label: 'pH CaCl₂',
      type: AnaliseFieldType.number,
      minValue: 0,
      maxValue: 14,
      precision: 2,
      allowEmpty: false,
    ),
    'phSmp': const CanonicalFieldSchema(
      key: 'phSmp',
      label: 'pH SMP',
      type: AnaliseFieldType.number,
      minValue: 0,
      maxValue: 14,
      precision: 2,
    ),
    'materiaOrganica': const CanonicalFieldSchema(
      key: 'materiaOrganica',
      label: 'M.O.',
      type: AnaliseFieldType.number,
      canonicalUnit: 'dag/kg',
      minValue: 0,
      maxValue: 80,
      precision: 2,
    ),
    'carbonoOrganico': const CanonicalFieldSchema(
      key: 'carbonoOrganico',
      label: 'C Orgânico',
      type: AnaliseFieldType.number,
      canonicalUnit: 'dag/kg',
      minValue: 0,
      maxValue: 50,
      precision: 2,
    ),
    'pMehlich': const CanonicalFieldSchema(
      key: 'pMehlich',
      label: 'P Mehlich',
      type: AnaliseFieldType.number,
      canonicalUnit: 'mg/dm³',
      minValue: 0,
      maxValue: 500,
      precision: 2,
    ),
    'pResina': const CanonicalFieldSchema(
      key: 'pResina',
      label: 'P Resina',
      type: AnaliseFieldType.number,
      canonicalUnit: 'mg/dm³',
      minValue: 0,
      maxValue: 500,
      precision: 2,
    ),
    'pRem': const CanonicalFieldSchema(
      key: 'pRem',
      label: 'P-rem',
      type: AnaliseFieldType.number,
      canonicalUnit: 'mg/L',
      minValue: 0,
      maxValue: 100,
      precision: 2,
    ),
    's020': const CanonicalFieldSchema(
      key: 's020',
      label: 'S 0-20',
      type: AnaliseFieldType.number,
      canonicalUnit: 'mg/dm³',
      minValue: 0,
      maxValue: 250,
      precision: 2,
    ),
    's2040': const CanonicalFieldSchema(
      key: 's2040',
      label: 'S 20-40',
      type: AnaliseFieldType.number,
      canonicalUnit: 'mg/dm³',
      minValue: 0,
      maxValue: 250,
      precision: 2,
    ),
    'k': const CanonicalFieldSchema(
      key: 'k',
      label: 'K',
      type: AnaliseFieldType.number,
      canonicalUnit: 'cmolc/dm³',
      minValue: 0,
      maxValue: 10,
      precision: 3,
      allowEmpty: false,
    ),
    'ca': const CanonicalFieldSchema(
      key: 'ca',
      label: 'Ca',
      type: AnaliseFieldType.number,
      canonicalUnit: 'cmolc/dm³',
      minValue: 0,
      maxValue: 50,
      precision: 2,
      allowEmpty: false,
    ),
    'mg': const CanonicalFieldSchema(
      key: 'mg',
      label: 'Mg',
      type: AnaliseFieldType.number,
      canonicalUnit: 'cmolc/dm³',
      minValue: 0,
      maxValue: 20,
      precision: 2,
      allowEmpty: false,
    ),
    'al': const CanonicalFieldSchema(
      key: 'al',
      label: 'Al',
      type: AnaliseFieldType.number,
      canonicalUnit: 'cmolc/dm³',
      minValue: 0,
      maxValue: 20,
      precision: 2,
    ),
    'hMaisAl': const CanonicalFieldSchema(
      key: 'hMaisAl',
      label: 'H+Al',
      type: AnaliseFieldType.number,
      canonicalUnit: 'cmolc/dm³',
      minValue: 0,
      maxValue: 50,
      precision: 2,
    ),
    'na': const CanonicalFieldSchema(
      key: 'na',
      label: 'Na',
      type: AnaliseFieldType.number,
      canonicalUnit: 'cmolc/dm³',
      minValue: 0,
      maxValue: 10,
      precision: 2,
    ),
    'b': const CanonicalFieldSchema(
      key: 'b',
      label: 'B',
      type: AnaliseFieldType.number,
      canonicalUnit: 'mg/dm³',
      minValue: 0,
      maxValue: 10,
      precision: 2,
    ),
    'cu': const CanonicalFieldSchema(
      key: 'cu',
      label: 'Cu',
      type: AnaliseFieldType.number,
      canonicalUnit: 'mg/dm³',
      minValue: 0,
      maxValue: 60,
      precision: 2,
    ),
    'fe': const CanonicalFieldSchema(
      key: 'fe',
      label: 'Fe',
      type: AnaliseFieldType.number,
      canonicalUnit: 'mg/dm³',
      minValue: 0,
      maxValue: 500,
      precision: 2,
    ),
    'mn': const CanonicalFieldSchema(
      key: 'mn',
      label: 'Mn',
      type: AnaliseFieldType.number,
      canonicalUnit: 'mg/dm³',
      minValue: 0,
      maxValue: 300,
      precision: 2,
    ),
    'zn': const CanonicalFieldSchema(
      key: 'zn',
      label: 'Zn',
      type: AnaliseFieldType.number,
      canonicalUnit: 'mg/dm³',
      minValue: 0,
      maxValue: 80,
      precision: 2,
    ),
    'ni': const CanonicalFieldSchema(
      key: 'ni',
      label: 'Ni',
      type: AnaliseFieldType.number,
      canonicalUnit: 'mg/dm³',
      minValue: 0,
      maxValue: 50,
      precision: 2,
    ),
    'mo': const CanonicalFieldSchema(
      key: 'mo',
      label: 'Mo',
      type: AnaliseFieldType.number,
      canonicalUnit: 'mg/dm³',
      minValue: 0,
      maxValue: 50,
      precision: 2,
    ),
    'se': const CanonicalFieldSchema(
      key: 'se',
      label: 'Se',
      type: AnaliseFieldType.number,
      canonicalUnit: 'mg/dm³',
      minValue: 0,
      maxValue: 50,
      precision: 2,
    ),
  };

  static const Map<String, LabValidationProfile> profiles = {
    'sellar': LabValidationProfile(
      id: 'sellar',
      label: 'Sellar',
      requiredFields: {
        'phCaCl2',
        'k',
        'ca',
        'mg',
      },
      optionalFields: {},
      unsupportedFields: {},
    ),
    'exata_brasil': LabValidationProfile(
      id: 'exata_brasil',
      label: 'Exata Brasil',
      requiredFields: {
        'phCaCl2',
        'k',
        'ca',
        'mg',
      },
      optionalFields: {
        'pResina',
        'phSmp',
      },
      unsupportedFields: {
        's2040',
      },
    ),
    'ibra': LabValidationProfile(
      id: 'ibra',
      label: 'IBRA',
      requiredFields: {
        'phCaCl2',
        'pResina',
        'k',
        'ca',
        'mg',
      },
      optionalFields: {
        'pMehlich',
      },
      unsupportedFields: {
        'phAgua',
        's2040',
      },
    ),
    'mb': LabValidationProfile(
      id: 'mb',
      label: 'MB Agronegócios',
      requiredFields: {
        'phCaCl2',
        'k',
        'ca',
        'mg',
      },
      optionalFields: {},
      unsupportedFields: {
        'phAgua',
        's2040',
        'ni',
        'mo',
        'se',
      },
    ),
  };

  static LabValidationProfile profileForLaboratorio(String rawLab) {
    final normalized = normalizeLabId(rawLab);
    return profiles[normalized] ??
        const LabValidationProfile(
          id: 'generic',
          label: 'Genérico',
          requiredFields: {'phCaCl2'},
          optionalFields: {},
          unsupportedFields: {},
        );
  }

  static String normalizeLabId(String rawLab) {
    final value = rawLab.trim().toLowerCase();
    if (value.contains('sellar')) return 'sellar';
    if (value.contains('exata')) return 'exata_brasil';
    if (value.contains('ibra')) return 'ibra';
    if (value.contains('mb')) return 'mb';
    return 'generic';
  }
}

class AnaliseValidationEngine {
  const AnaliseValidationEngine();

  ValidationSnapshot validate({
    required List<AnaliseDraft> drafts,
    required String labDisplayName,
  }) {
    final profile = AnaliseDataContract.profileForLaboratorio(labDisplayName);
    final issues = <ValidationIssue>[];
    final normalizedColumns = <Map<String, String>>[];

    for (var i = 0; i < drafts.length; i++) {
      final draft = drafts[i];
      final normalized = <String, String>{...draft.fields};

      _validateIdentity(
        columnIndex: i,
        draft: draft,
        issues: issues,
      );

      for (final entry in AnaliseDataContract.schemaByField.entries) {
        final key = entry.key;
        final schema = entry.value;
        final rawValue = draft.stringValue(key);
        final isRequired = schema.allowEmpty == false ||
            profile.requiredFields.contains(key) ||
            key == 'profundidade';
        final unsupported = profile.unsupportedFields.contains(key);

        if (rawValue.isEmpty) {
          if (isRequired) {
            issues.add(
              ValidationIssue(
                columnIndex: i,
                fieldKey: key,
                fieldLabel: schema.label,
                code: 'ERR_REQUIRED_FIELD',
                message:
                    'Campo obrigatório para ${profile.label}. Preencha ${schema.label}.',
                severity: ValidationSeverity.warning,
              ),
            );
          }
          continue;
        }

        if (unsupported) {
          issues.add(
            ValidationIssue(
              columnIndex: i,
              fieldKey: key,
              fieldLabel: schema.label,
              code: 'WARN_UNSUPPORTED_FIELD',
              message:
                  'Campo não suportado por ${profile.label}. Valor ignorado.',
              severity: ValidationSeverity.warning,
              currentValue: rawValue,
            ),
          );
          normalized[key] = '';
          continue;
        }

        switch (schema.type) {
          case AnaliseFieldType.text:
            final text = rawValue.trim();
            if (key == 'profundidade') {
              final depth = _normalizeDepth(text);
              if (depth == null) {
                issues.add(
                  ValidationIssue(
                    columnIndex: i,
                    fieldKey: key,
                    fieldLabel: schema.label,
                    code: 'ERR_INVALID_DEPTH',
                    message: 'Formato inválido. Use padrão como 0-20.',
                    severity: ValidationSeverity.warning,
                    currentValue: rawValue,
                  ),
                );
              } else {
                normalized[key] = depth;
              }
            } else {
              normalized[key] = text;
            }
            break;
          case AnaliseFieldType.enumValue:
            final enumRaw = rawValue.trim().toLowerCase();
            if (schema.allowedEnumValues.contains(enumRaw)) {
              normalized[key] = _normalizeEnumLabel(enumRaw);
            } else {
              issues.add(
                ValidationIssue(
                  columnIndex: i,
                  fieldKey: key,
                  fieldLabel: schema.label,
                  code: 'WARN_ENUM_DEFAULT',
                  message: 'Valor fora da lista. Cultura ajustada para Soja.',
                  severity: ValidationSeverity.warning,
                  currentValue: rawValue,
                ),
              );
              normalized[key] = 'Soja';
            }
            break;
          case AnaliseFieldType.number:
            final normalizedNumber = _normalizeNumberField(
              columnIndex: i,
              key: key,
              schema: schema,
              rawValue: rawValue,
              labId: profile.id,
            );
            issues.addAll(normalizedNumber.issues);
            if (normalizedNumber.normalizedValue != null) {
              normalized[key] = normalizedNumber.normalizedValue!;
            }
            break;
        }
      }

      _validateTextureConsistency(i, normalized, issues);
      normalizedColumns.add(normalized);
    }

    return ValidationSnapshot(
      version: analiseDataContractVersion,
      labId: profile.id,
      issues: issues,
      normalizedColumns: normalizedColumns,
    );
  }

  void _validateIdentity({
    required int columnIndex,
    required AnaliseDraft draft,
    required List<ValidationIssue> issues,
  }) {
    final talhao = draft.stringValue('talhao');
    final numero = draft.stringValue('numeroAmostra');
    if (talhao.isEmpty && numero.isEmpty) {
      issues.add(
        ValidationIssue(
          columnIndex: columnIndex,
          fieldKey: 'numeroAmostra',
          fieldLabel: 'Nº Amostra',
          code: 'ERR_IDENTITY_REQUIRED',
          message: 'Preencha Talhão ou Nº da Amostra.',
          severity: ValidationSeverity.warning,
        ),
      );
    }
  }

  void _validateTextureConsistency(
    int columnIndex,
    Map<String, String> normalized,
    List<ValidationIssue> issues,
  ) {
    final argila = _parseLocalizedNumber(normalized['argila']);
    final silte = _parseLocalizedNumber(normalized['silte']);
    final areia = _parseLocalizedNumber(normalized['areiaTotal']);
    if (argila == null || silte == null || areia == null) return;

    final total = argila + silte + areia;
    if (total < 970 || total > 1030) {
      issues.add(
        ValidationIssue(
          columnIndex: columnIndex,
          fieldKey: 'argila',
          fieldLabel: 'Argila/Silte/Areia',
          code: 'WARN_TEXTURE_SUM',
          message: 'Soma granulométrica fora do esperado (1000 g/kg).',
          severity: ValidationSeverity.warning,
          currentValue: total.toStringAsFixed(1),
        ),
      );
    }
  }

  _NormalizationResult _normalizeNumberField({
    required int columnIndex,
    required String key,
    required CanonicalFieldSchema schema,
    required String rawValue,
    required String labId,
  }) {
    final parsed = _parseLocalizedNumber(rawValue);
    if (parsed == null) {
      return _NormalizationResult(
        normalizedValue: null,
        issues: <ValidationIssue>[
          ValidationIssue(
            columnIndex: columnIndex,
            fieldKey: key,
            fieldLabel: schema.label,
            code: 'ERR_INVALID_NUMBER',
            message: 'Número inválido em ${schema.label}.',
            severity: ValidationSeverity.warning,
            currentValue: rawValue,
          ),
        ],
      );
    }

    var normalizedValue = parsed;
    final warnings = <ValidationIssue>[];

    // Conversões contextuais por laboratório.
    if (key == 'k' &&
        (labId == 'exata_brasil' || labId == 'mb') &&
        parsed > 12) {
      normalizedValue = parsed / 391.0;
      warnings.add(
        ValidationIssue(
          columnIndex: columnIndex,
          fieldKey: key,
          fieldLabel: schema.label,
          code: 'WARN_CONVERT_K_MGDM3',
          message: 'K convertido automaticamente de mg/dm³ para cmolc/dm³.',
          severity: ValidationSeverity.warning,
          currentValue: rawValue,
        ),
      );
    }

    if ((key == 'k' ||
            key == 'ca' ||
            key == 'mg' ||
            key == 'al' ||
            key == 'hMaisAl') &&
        labId == 'ibra' &&
        parsed > 12) {
      normalizedValue = parsed / 10.0;
      warnings.add(
        ValidationIssue(
          columnIndex: columnIndex,
          fieldKey: key,
          fieldLabel: schema.label,
          code: 'WARN_CONVERT_MMOLC',
          message:
              '${schema.label} convertido automaticamente de mmolc/dm³ para cmolc/dm³.',
          severity: ValidationSeverity.warning,
          currentValue: rawValue,
        ),
      );
    }

    if ((key == 'argila' || key == 'silte' || key == 'areiaTotal') &&
        labId == 'mb' &&
        parsed <= 100) {
      normalizedValue = parsed * 10.0;
      warnings.add(
        ValidationIssue(
          columnIndex: columnIndex,
          fieldKey: key,
          fieldLabel: schema.label,
          code: 'WARN_CONVERT_PERCENT_TEXTURE',
          message: '${schema.label} convertido automaticamente de % para g/kg.',
          severity: ValidationSeverity.warning,
          currentValue: rawValue,
        ),
      );
    }

    if ((key == 'materiaOrganica' || key == 'carbonoOrganico') &&
        labId == 'exata_brasil' &&
        parsed > 15) {
      normalizedValue = parsed / 10.0;
      warnings.add(
        ValidationIssue(
          columnIndex: columnIndex,
          fieldKey: key,
          fieldLabel: schema.label,
          code: 'WARN_CONVERT_GDM3_DAGKG',
          message:
              '${schema.label} convertido automaticamente de g/dm³ para dag/kg.',
          severity: ValidationSeverity.warning,
          currentValue: rawValue,
        ),
      );
    }

    if (schema.minValue != null && normalizedValue < schema.minValue!) {
      return _NormalizationResult(
        normalizedValue: null,
        issues: <ValidationIssue>[
          ValidationIssue(
            columnIndex: columnIndex,
            fieldKey: key,
            fieldLabel: schema.label,
            code: 'ERR_OUT_OF_RANGE_MIN',
            message:
                'Valor abaixo do mínimo (${_fmt(schema.minValue!)}) para ${schema.label}.',
            severity: ValidationSeverity.warning,
            currentValue: rawValue,
          ),
        ],
      );
    }
    if (schema.maxValue != null && normalizedValue > schema.maxValue!) {
      return _NormalizationResult(
        normalizedValue: null,
        issues: <ValidationIssue>[
          ValidationIssue(
            columnIndex: columnIndex,
            fieldKey: key,
            fieldLabel: schema.label,
            code: 'ERR_OUT_OF_RANGE_MAX',
            message:
                'Valor acima do máximo (${_fmt(schema.maxValue!)}) para ${schema.label}.',
            severity: ValidationSeverity.warning,
            currentValue: rawValue,
          ),
        ],
      );
    }

    final rounded = _roundTo(normalizedValue, schema.precision);
    if ((rounded - normalizedValue).abs() >= _tolerance(schema.precision)) {
      warnings.add(
        ValidationIssue(
          columnIndex: columnIndex,
          fieldKey: key,
          fieldLabel: schema.label,
          code: 'WARN_ROUNDED',
          message:
              'Valor arredondado para ${schema.precision} casas decimais em ${schema.label}.',
          severity: ValidationSeverity.warning,
          currentValue: rawValue,
        ),
      );
    }

    return _NormalizationResult(
      normalizedValue: _formatNumber(rounded, schema.precision),
      issues: warnings,
    );
  }

  double? _parseLocalizedNumber(String? raw) {
    if (raw == null) return null;
    var text = raw.trim();
    if (text.isEmpty) return null;

    text = text
        .replaceAll('\u00A0', '')
        .replaceAll(' ', '')
        .replaceAll(RegExp(r'[^\d,\.\-]'), '');

    if (text.isEmpty || text == '-' || text == '--') {
      return null;
    }

    final hasComma = text.contains(',');
    final hasDot = text.contains('.');

    if (hasComma && hasDot) {
      if (text.lastIndexOf(',') > text.lastIndexOf('.')) {
        text = text.replaceAll('.', '').replaceAll(',', '.');
      } else {
        text = text.replaceAll(',', '');
      }
    } else if (hasComma) {
      text = text.replaceAll('.', '').replaceAll(',', '.');
    }

    return double.tryParse(text);
  }

  String? _normalizeDepth(String raw) {
    final cleaned = raw.replaceAll('cm', '').trim();
    final pattern = RegExp(r'(\d{1,2})\s*[-aA]\s*(\d{1,2})');
    final match = pattern.firstMatch(cleaned);
    if (match == null) return null;
    return '${match.group(1)}-${match.group(2)}';
  }

  String _normalizeEnumLabel(String raw) {
    switch (raw) {
      case 'feijão':
      case 'feijao':
        return 'Feijão';
      case 'algodão':
      case 'algodao':
        return 'Algodão';
      default:
        return raw.substring(0, 1).toUpperCase() + raw.substring(1);
    }
  }

  double _roundTo(double value, int decimals) {
    final p = math.pow(10, decimals).toDouble();
    return (value * p).round() / p;
  }

  double _tolerance(int decimals) {
    return 1 / math.pow(10, decimals + 3);
  }

  String _formatNumber(double value, int decimals) {
    var text = value.toStringAsFixed(decimals);
    if (text.contains('.')) {
      text = text.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return text;
  }

  String _fmt(double value) => _formatNumber(value, 3);
}
