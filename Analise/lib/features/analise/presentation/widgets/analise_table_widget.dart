import 'package:flutter/material.dart';
import 'package:soloforte/data/lab_templates/exata_brasil_template.dart';
import 'package:soloforte/data/lab_templates/ibra_template.dart';
import 'package:soloforte/data/lab_templates/mb_template.dart';
import 'package:soloforte/data/lab_templates/sellar_template.dart';
import 'package:soloforte/features/analise/domain/validation/analise_data_contract.dart';
import 'package:soloforte/features/analise/presentation/widgets/analise_calc_cell.dart';
import 'package:soloforte/features/analise/presentation/widgets/analise_input_cell.dart';

class _FieldDef {
  final String key;
  final String label;
  final String? unit;
  final bool isText;
  final bool isGps;

  const _FieldDef(
    this.key,
    this.label, {
    this.unit,
    this.isText = false,
    this.isGps = false,
  });
}

class _CalcFieldDef {
  final String key;
  final String label;
  final String? unit;

  const _CalcFieldDef(this.key, this.label, {this.unit});
}

class _SectionDef {
  final String title;
  final List<_FieldDef> fields;
  final List<_CalcFieldDef> calcFields;

  const _SectionDef(this.title, this.fields, {this.calcFields = const []});
}

enum _RowKind { section, input, calc }

class _RenderedRow {
  final _RowKind kind;
  final String title;
  final String? unit;
  final _FieldDef? field;
  final _CalcFieldDef? calcField;

  _RenderedRow.section(this.title)
      : kind = _RowKind.section,
        unit = null,
        field = null,
        calcField = null;

  _RenderedRow.input(this.field)
      : kind = _RowKind.input,
        title = field!.label,
        unit = field.unit,
        calcField = null;

  _RenderedRow.calc(this.calcField)
      : kind = _RowKind.calc,
        title = calcField!.label,
        unit = calcField.unit,
        field = null;
}

const double _stickyWidth = 164;
const double _colWidth = 96;
const double _addColWidth = 44;

const double _headerRowHeight = 44;
const double _sectionRowHeight = 34;
const double _dataRowHeight = 50;

const _brandGreen = Color(0xFF4ADE80);
const _darkGreen = Color(0xFF1E3A2F);
const _mint = Color(0xFFD1FAE5);
const _ink = Color(0xFF1A1A1A);
const _muted = Color(0xFF6B7280);
const _line = Color(0xFFE5E7EB);
const _surface = Color(0xFFFFFFFF);
const _surfaceAlt = Color(0xFFF3F4F6);

const List<_SectionDef> _sections = [
  _SectionDef('1. Identificação', [
    _FieldDef('talhao', 'Talhão', isText: true),
    _FieldDef('numeroAmostra', 'Nº Amostra', isText: true),
    _FieldDef('cultura', 'Cultura', isText: true),
    _FieldDef('profundidade', 'Profundidade', unit: 'cm', isText: true),
  ]),
  _SectionDef('2. Localização', [
    _FieldDef('gps', 'GPS', isGps: true),
    _FieldDef('latitude', 'Latitude, Longitude', isText: true),
    _FieldDef('descricaoLocal', 'Descrição', isText: true),
  ]),
  _SectionDef('3. Composição Física', [
    _FieldDef('argila', 'Argila', unit: 'g/kg'),
    _FieldDef('silte', 'Silte', unit: 'g/kg'),
    _FieldDef('areiaTotal', 'Areia Total', unit: 'g/kg'),
  ]),
  _SectionDef('4. pH', [
    _FieldDef('phAgua', 'pH Água'),
    _FieldDef('phCaCl2', 'pH CaCl₂'),
    _FieldDef('phSmp', 'pH SMP'),
  ]),
  _SectionDef('5. Matéria Orgânica', [
    _FieldDef('materiaOrganica', 'M.O.', unit: 'dag/kg'),
    _FieldDef('carbonoOrganico', 'C Orgânico', unit: 'dag/kg'),
  ]),
  _SectionDef('6. Fósforo', [
    _FieldDef('pMehlich', 'P Mehlich', unit: 'mg/dm³'),
    _FieldDef('pResina', 'P Resina', unit: 'mg/dm³'),
    _FieldDef('pRem', 'P-rem', unit: 'mg/L'),
  ]),
  _SectionDef('7. Enxofre', [
    _FieldDef('s020', 'S 0-20', unit: 'mg/dm³'),
    _FieldDef('s2040', 'S 20-40', unit: 'mg/dm³'),
  ]),
  _SectionDef('8. Macronutrientes', [
    _FieldDef('k', 'K', unit: 'cmolc/dm³'),
    _FieldDef('ca', 'Ca', unit: 'cmolc/dm³'),
    _FieldDef('mg', 'Mg', unit: 'cmolc/dm³'),
    _FieldDef('al', 'Al', unit: 'cmolc/dm³'),
    _FieldDef('hMaisAl', 'H+Al', unit: 'cmolc/dm³'),
    _FieldDef('na', 'Na', unit: 'cmolc/dm³'),
  ]),
  _SectionDef(
    '9. Bases e CTC',
    [],
    calcFields: [
      _CalcFieldDef('sb', 'SB', unit: 'cmolc/dm³'),
      _CalcFieldDef('ctcTotal', 'CTC(T)', unit: 'cmolc/dm³'),
      _CalcFieldDef('ctcEfetiva', 'CTC(e)', unit: 'cmolc/dm³'),
      _CalcFieldDef('vPct', 'V%', unit: '%'),
      _CalcFieldDef('mPct', 'm%', unit: '%'),
    ],
  ),
  _SectionDef(
    '10. Saturação das Bases',
    [],
    calcFields: [
      _CalcFieldDef('caPctT', 'Ca/T', unit: '%'),
      _CalcFieldDef('mgPctT', 'Mg/T', unit: '%'),
      _CalcFieldDef('kPctT', 'K/T', unit: '%'),
      _CalcFieldDef('hAlPctT', 'H+Al/T', unit: '%'),
    ],
  ),
  _SectionDef(
    '11. Relações entre Bases',
    [],
    calcFields: [
      _CalcFieldDef('relCaMg', 'Ca/Mg'),
      _CalcFieldDef('relCaK', 'Ca/K'),
      _CalcFieldDef('relMgK', 'Mg/K'),
      _CalcFieldDef('relCaMgT', '(Ca+Mg)/T', unit: '%'),
    ],
  ),
  _SectionDef('12. Micronutrientes', [
    _FieldDef('b', 'B', unit: 'mg/dm³'),
    _FieldDef('cu', 'Cu', unit: 'mg/dm³'),
    _FieldDef('fe', 'Fe', unit: 'mg/dm³'),
    _FieldDef('mn', 'Mn', unit: 'mg/dm³'),
    _FieldDef('zn', 'Zn', unit: 'mg/dm³'),
    _FieldDef('ni', 'Ni', unit: 'mg/dm³'),
    _FieldDef('mo', 'Mo', unit: 'mg/dm³'),
    _FieldDef('se', 'Se', unit: 'mg/dm³'),
  ]),
];

class AnaliseTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> analises;
  final List<Map<String, double>> derivados;
  final void Function(int index, String campo, String valor) onCampoChanged;
  final Future<void> Function(int index)? onGpsClicked;
  final VoidCallback? onAddAnalise;
  final void Function(int index)? onRemoveAnalise;
  final String laboratorio;
  final ValidationSnapshot validation;
  final String? highlightedCellKey;

  const AnaliseTableWidget({
    super.key,
    required this.analises,
    required this.derivados,
    required this.onCampoChanged,
    this.onGpsClicked,
    this.onAddAnalise,
    this.onRemoveAnalise,
    this.laboratorio = '',
    this.validation = ValidationSnapshot.empty,
    this.highlightedCellKey,
  });

  @override
  Widget build(BuildContext context) {
    final colCount = analises.length;
    final canAdd = colCount < 6;
    final canRemove = colCount > 1;

    final rows = _buildRowsForLaboratorio(laboratorio);
    final rightWidth = (colCount * _colWidth) + (canAdd ? _addColWidth : 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _stickyWidth,
              child: Column(
                children: [
                  _buildStickyHeader(),
                  for (final row in rows) _buildStickyRow(row),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: rightWidth,
                  child: Column(
                    children: [
                      _buildHeaderRow(colCount, canRemove, canAdd),
                      for (final row in rows)
                        _buildContentRow(
                          row,
                          colCount,
                          canAdd,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyHeader() {
    return Container(
      height: _headerRowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        color: _surfaceAlt,
        border: Border(
          right: BorderSide(color: _line, width: 0.7),
          bottom: BorderSide(color: _line, width: 0.7),
        ),
      ),
      child: const Text(
        'PARÂMETRO',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
          color: _muted,
        ),
      ),
    );
  }

  Widget _buildStickyRow(_RenderedRow row) {
    switch (row.kind) {
      case _RowKind.section:
        return Container(
          height: _sectionRowHeight,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            color: _mint,
            border: Border(
              right: BorderSide(color: _line, width: 0.7),
              bottom: BorderSide(color: _line, width: 0.7),
            ),
          ),
          child: Text(
            row.title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: _darkGreen,
            ),
          ),
        );
      case _RowKind.input:
      case _RowKind.calc:
        return Container(
          height: _dataRowHeight,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            color: _surface,
            border: Border(
              right: BorderSide(color: _line, width: 0.7),
              bottom: BorderSide(color: _line, width: 0.7),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
              if ((row.unit ?? '').isNotEmpty)
                Text(
                  row.unit!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        );
    }
  }

  Widget _buildHeaderRow(int colCount, bool canRemove, bool canAdd) {
    return SizedBox(
      height: _headerRowHeight,
      child: Row(
        children: [
          for (int i = 0; i < colCount; i++)
            _buildSampleHeaderCell(
              index: i,
              canRemove: canRemove,
              summary: validation.byColumn[i],
            ),
          if (canAdd)
            GestureDetector(
              onTap: onAddAnalise,
              child: Container(
                width: _addColWidth,
                height: _headerRowHeight,
                decoration: const BoxDecoration(
                  color: _surfaceAlt,
                  border: Border(
                    left: BorderSide(color: _line, width: 0.7),
                    bottom: BorderSide(color: _line, width: 0.7),
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.add, size: 18, color: _darkGreen),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSampleHeaderCell({
    required int index,
    required bool canRemove,
    required ColumnValidationSummary? summary,
  }) {
    final errorCount = summary?.errorCount ?? 0;
    final warningCount = summary?.warningCount ?? 0;
    final hasIssues = errorCount > 0 || warningCount > 0;

    return Container(
      width: _colWidth,
      height: _headerRowHeight,
      decoration: const BoxDecoration(
        color: _surfaceAlt,
        border: Border(
          left: BorderSide(color: _line, width: 0.7),
          bottom: BorderSide(color: _line, width: 0.7),
        ),
      ),
      child: Stack(
        children: [
          if (hasIssues)
            Positioned(
              left: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: errorCount > 0
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: errorCount > 0
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                child: Text(
                  errorCount > 0 ? '${errorCount}E' : '${warningCount}A',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: errorCount > 0
                        ? const Color(0xFFB91C1C)
                        : const Color(0xFF92400E),
                  ),
                ),
              ),
            ),
          Center(
            child: Text(
              'A${index + 1}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
          ),
          if (canRemove && onRemoveAnalise != null)
            Positioned(
              right: 4,
              top: 4,
              child: InkWell(
                onTap: () => onRemoveAnalise?.call(index),
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.close, size: 13, color: _muted),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentRow(_RenderedRow row, int colCount, bool canAdd) {
    final bool section = row.kind == _RowKind.section;
    final double rowHeight = section ? _sectionRowHeight : _dataRowHeight;

    return SizedBox(
      height: rowHeight,
      child: Row(
        children: [
          for (int i = 0; i < colCount; i++)
            _buildDataCellForRow(
              row: row,
              index: i,
              rowHeight: rowHeight,
            ),
          if (canAdd)
            Container(
              width: _addColWidth,
              height: rowHeight,
              decoration: BoxDecoration(
                color: section ? _mint : _surface,
                border: const Border(
                  left: BorderSide(color: _line, width: 0.7),
                  bottom: BorderSide(color: _line, width: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataCellForRow({
    required _RenderedRow row,
    required int index,
    required double rowHeight,
  }) {
    if (row.kind == _RowKind.section) {
      return Container(
        width: _colWidth,
        height: rowHeight,
        decoration: const BoxDecoration(
          color: _mint,
          border: Border(
            left: BorderSide(color: _line, width: 0.7),
            bottom: BorderSide(color: _line, width: 0.7),
          ),
        ),
      );
    }

    if (row.kind == _RowKind.calc) {
      return AnaliseCalcCell(
        key: ValueKey('${row.calcField!.key}_calc_$index'),
        width: _colWidth,
        height: rowHeight,
        value: index < derivados.length
            ? derivados[index][row.calcField!.key]
            : null,
      );
    }

    final field = row.field!;
    if (field.isGps) {
      final hasLat = (analises[index]['latitude']?.toString() ?? '').isNotEmpty;
      final hasLng =
          (analises[index]['longitude']?.toString() ?? '').isNotEmpty;
      final success = hasLat && hasLng;

      return Container(
        width: _colWidth,
        height: rowHeight,
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: _line, width: 0.7),
            bottom: BorderSide(color: _line, width: 0.7),
          ),
        ),
        alignment: Alignment.center,
        child: IconButton(
          onPressed: () => onGpsClicked?.call(index),
          icon: Icon(
            success ? Icons.gps_fixed : Icons.gps_not_fixed,
            size: 19,
            color: success ? _brandGreen : _darkGreen,
          ),
          tooltip: 'Capturar GPS',
        ),
      );
    }

    final issue = validation.issueForCell(index, field.key);

    final initialValue = field.key == 'latitude'
        ? _composeCoordinates(
            analises[index]['latitude']?.toString(),
            analises[index]['longitude']?.toString(),
          )
        : analises[index][field.key]?.toString() ?? '';

    return AnaliseInputCell(
      key: ValueKey('${field.key}_$index'),
      width: _colWidth,
      height: rowHeight,
      initialValue: initialValue,
      type: field.isText ? AnaliseCellType.text : AnaliseCellType.numeric,
      onChanged: (v) => onCampoChanged(index, field.key, v),
      hasError: issue?.severity == ValidationSeverity.error,
      hasWarning: issue?.severity == ValidationSeverity.warning,
      validationMessage:
          issue == null ? null : '${issue.cellLabel}: ${issue.message}',
      highlightedByNavigator: highlightedCellKey == '$index:${field.key}',
    );
  }

  String _composeCoordinates(String? latRaw, String? lngRaw) {
    final lat = (latRaw ?? '').trim();
    final lng = (lngRaw ?? '').trim();
    if (lat.isEmpty && lng.isEmpty) return '';
    if (lat.isNotEmpty && lng.isNotEmpty) return '$lat, $lng';
    return lat.isNotEmpty ? lat : lng;
  }

  List<_RenderedRow> _buildRowsForLaboratorio(String laboratorioAtual) {
    final visibleFields = _visibleFieldKeysForLab(laboratorioAtual);
    final rows = <_RenderedRow>[];

    for (final section in _sections) {
      final fields = section.fields
          .where((f) => visibleFields.contains(f.key))
          .toList(growable: false);

      final includeSection = fields.isNotEmpty || section.calcFields.isNotEmpty;
      if (!includeSection) continue;

      rows.add(_RenderedRow.section(section.title));
      rows.addAll(fields.map(_RenderedRow.input));
      rows.addAll(section.calcFields.map(_RenderedRow.calc));
    }

    return rows;
  }

  Set<String> _visibleFieldKeysForLab(String laboratorioAtual) {
    const always = {
      'talhao',
      'numeroAmostra',
      'cultura',
      'profundidade',
      'gps',
      'latitude',
      'longitude',
      'descricaoLocal',
    };

    final normalized = _normalizeLab(laboratorioAtual);
    final Set<String> raw;

    switch (normalized) {
      case 'sellar':
        raw = sellarFieldMap.values.toSet();
        break;
      case 'exata_brasil':
        raw = exataBrasilFieldMap.values.toSet();
        break;
      case 'ibra':
        raw = ibraFieldMap.values.toSet();
        break;
      case 'mb_agronegocios':
        raw = mbFieldMap.values.toSet();
        break;
      default:
        // Sem laboratório selecionado: mantém todos os campos da tela.
        return {
          ...always,
          for (final section in _sections) ...section.fields.map((e) => e.key),
        };
    }

    final canonical = raw.map(_toCanonicalFieldKey).toSet();
    return {...always, ...canonical};
  }

  String _normalizeLab(String raw) {
    final v = raw.toLowerCase();
    if (v.contains('sellar')) return 'sellar';
    if (v.contains('exata')) return 'exata_brasil';
    if (v.contains('ibra')) return 'ibra';
    if (v.contains('mb')) return 'mb_agronegocios';
    return '';
  }

  String _toCanonicalFieldKey(String key) {
    switch (key) {
      case 'k_mgdm3':
      case 'k_mmolc':
        return 'k';
      case 'ca_mmolc':
        return 'ca';
      case 'mg_mmolc':
        return 'mg';
      case 'al_mmolc':
        return 'al';
      case 'hMaisAl_mmolc':
        return 'hMaisAl';
      case 'mo_gdm3':
      case 'mo_pct':
        return 'materiaOrganica';
      case 'cot_gdm3':
      case 'carbono_gdm3':
        return 'carbonoOrganico';
      case 'argila_pct':
        return 'argila';
      case 'silte_pct':
        return 'silte';
      case 'areiaTotal_pct':
        return 'areiaTotal';
      default:
        return key;
    }
  }
}
