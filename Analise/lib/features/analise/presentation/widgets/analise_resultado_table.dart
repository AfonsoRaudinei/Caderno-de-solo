// lib/presentation/analise/widgets/analise_resultado_table.dart
//
// Tabela de resultados da análise de solo.
// - Scroll horizontal das colunas de amostras
// - Coluna "Parâmetro" travada à esquerda (sticky)
// - Toque em valores conversíveis alterna unidade (cmolc ↔ mmolc / mg ↔ cmolc)
// - Se [groups] for nulo, usa dataset de exemplo (Exata Brasil 20573.2024)
//
// Uso:
//   AnaliseResultadoTable(
//     headers: const [
//       AmostraHeader(nome: 'Talhão 1', codigo: 'SBA24.124624'),
//       AmostraHeader(nome: 'Talhão 2', codigo: 'SBA24.124625'),
//     ],
//     groups: null,
//   )

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Paleta inline (espelha AppColors) ────────────────────────────────────────
abstract class _C {
  static const primary = Color(0xFF007AFF);
  static const primaryBg = Color(0x14007AFF); // 8 % opacidade
  static const bg = Color(0xFFF5F5F7);
  static const card = Color(0xFFFFFFFF);
  static const textMain = Color(0xFF1D1D1F);
  static const textSub = Color(0xFF86868B);
  static const textLight = Color(0xFFC7C7CC);
  static const borderSoft = Color(0xFFE5E5E7);
  static const groupBg = Color(0x0A007AFF); // grupo header
}

// ── Modelos de dados ─────────────────────────────────────────────────────────

/// Cabeçalho de cada coluna (talhão / amostra).
class AmostraHeader {
  final String nome; // ex: 'Talhão 1'
  final String codigo; // ex: 'SBA24.124624'
  const AmostraHeader({required this.nome, required this.codigo});
}

/// Tipo de conversão disponível para uma linha.
enum ConvType { none, cmolc, kmg }

/// Definição de uma linha de parâmetro.
class ParamRow {
  final String name; // ex: 'Ca'
  final String baseUnit; // unidade original
  final ConvType convType;
  final List<double?> values; // valor base por amostra (null = não analisado)
  final int decimals;

  const ParamRow({
    required this.name,
    required this.baseUnit,
    required this.values,
    this.convType = ConvType.none,
    this.decimals = 2,
  });
}

/// Grupo de parâmetros (ex: Macronutrientes).
class ParamGroup {
  final String label;
  final List<ParamRow> rows;
  const ParamGroup(this.label, this.rows);
}

// ── Conversões ───────────────────────────────────────────────────────────────

/// Uma etapa de conversão para uma unidade.
class _UnitStep {
  final String label; // ex: 'cmolc/dm³'
  final double factor; // multiplicador sobre o valor base
  final int decimals;
  const _UnitStep(this.label, this.factor, {this.decimals = 2});
}

const _cmolcSteps = [
  _UnitStep('cmolc/dm³', 1.0, decimals: 2),
  _UnitStep('mmolc/dm³', 10.0, decimals: 1),
];

const _kmgSteps = [
  _UnitStep('mg/dm³', 1.0, decimals: 2),
  _UnitStep('cmolc/dm³', 1.0 / 391, decimals: 3),
];

List<_UnitStep> _stepsFor(ConvType type) {
  switch (type) {
    case ConvType.cmolc:
      return _cmolcSteps;
    case ConvType.kmg:
      return _kmgSteps;
    case ConvType.none:
      return const [];
  }
}

// ── Dataset de exemplo (Exata Brasil 20573.2024) ─────────────────────────────
List<ParamGroup> _buildExataGroups() {
  return const [
    ParamGroup('pH e Acidez', [
      ParamRow(
        name: 'pH (CaCl₂)',
        baseUnit: '',
        values: [5.74, 6.14, 5.80, 5.69],
        decimals: 2,
      ),
      ParamRow(
        name: 'H + Al',
        baseUnit: 'cmolc/dm³',
        values: [1.73, 1.42, 2.15, 2.39],
        convType: ConvType.cmolc,
      ),
      ParamRow(
        name: 'Al',
        baseUnit: 'cmolc/dm³',
        values: [0.0, 0.0, 0.0, 0.0],
        convType: ConvType.cmolc,
      ),
    ]),
    ParamGroup('Macronutrientes', [
      ParamRow(
        name: 'Ca',
        baseUnit: 'cmolc/dm³',
        values: [2.94, 4.10, 3.78, 3.15],
        convType: ConvType.cmolc,
      ),
      ParamRow(
        name: 'Mg',
        baseUnit: 'cmolc/dm³',
        values: [1.21, 1.55, 1.62, 1.55],
        convType: ConvType.cmolc,
      ),
      ParamRow(
        name: 'Ca + Mg',
        baseUnit: 'cmolc/dm³',
        values: [4.15, 5.65, 5.40, 4.70],
        convType: ConvType.cmolc,
      ),
      ParamRow(
        name: 'K (NH₄Cl)',
        baseUnit: 'mg/dm³',
        values: [67.94, 59.97, 92.67, 76.39],
        convType: ConvType.kmg,
      ),
      ParamRow(
        name: 'K (cmolc)',
        baseUnit: 'cmolc/dm³',
        values: [0.17, 0.15, 0.24, 0.20],
        convType: ConvType.cmolc,
      ),
      ParamRow(
          name: 'P (Meh)',
          baseUnit: 'mg/dm³',
          values: [5.68, 10.75, 7.66, 5.40]),
      ParamRow(
          name: 'P (rem)',
          baseUnit: 'mg/dm³',
          values: [29.19, 29.97, 33.95, 31.18]),
      ParamRow(name: 'S', baseUnit: 'mg/dm³', values: [3.40, 3.25, 9.79, 8.75]),
    ]),
    ParamGroup('Matéria Orgânica', [
      ParamRow(
          name: 'M.O.',
          baseUnit: 'g/dm³',
          values: [20.78, 20.30, 21.20, 19.30]),
      ParamRow(
          name: 'C.O.',
          baseUnit: 'g/dm³',
          values: [12.05, 11.77, 12.30, 11.19]),
    ]),
    ParamGroup('CTC e Saturação', [
      ParamRow(
        name: 'T (CTC)',
        baseUnit: 'cmolc/dm³',
        values: [6.05, 7.22, 7.79, 7.29],
        convType: ConvType.cmolc,
      ),
      ParamRow(
          name: 'V%',
          baseUnit: '%',
          values: [71.40, 80.33, 72.40, 67.22],
          decimals: 1),
      ParamRow(
          name: 'm%', baseUnit: '%', values: [0.7, 0.3, 0.4, 0.2], decimals: 1),
      ParamRow(
          name: 'Ca/CTC',
          baseUnit: '%',
          values: [48.60, 56.79, 48.52, 43.21],
          decimals: 1),
      ParamRow(
          name: 'Mg/CTC',
          baseUnit: '%',
          values: [20.00, 21.47, 20.80, 21.26],
          decimals: 1),
      ParamRow(name: 'K/CTC', baseUnit: '%', values: [2.81, 2.08, 3.08, 2.74]),
      ParamRow(
          name: 'H+Al/CTC',
          baseUnit: '%',
          values: [28.60, 19.67, 27.60, 32.78],
          decimals: 1),
    ]),
    ParamGroup('Micronutrientes (Meh)', [
      ParamRow(name: 'B', baseUnit: 'mg/dm³', values: [0.34, 0.58, 0.34, 0.38]),
      ParamRow(
          name: 'Cu (Meh)',
          baseUnit: 'mg/dm³',
          values: [1.99, 1.80, 2.97, 4.24]),
      ParamRow(
          name: 'Fe (Meh)',
          baseUnit: 'mg/dm³',
          values: [46.37, 42.65, 55.01, 47.41]),
      ParamRow(
          name: 'Mn (Meh)',
          baseUnit: 'mg/dm³',
          values: [26.07, 37.72, 82.34, 76.68]),
      ParamRow(
          name: 'Zn (Meh)',
          baseUnit: 'mg/dm³',
          values: [1.59, 2.82, 2.50, 1.49]),
    ]),
    ParamGroup('Micronutrientes (DTPA)', [
      ParamRow(
          name: 'Cu (DTPA)',
          baseUnit: 'mg/dm³',
          values: [1.02, 0.96, 1.92, 2.41]),
      ParamRow(
          name: 'Fe (DTPA)',
          baseUnit: 'mg/dm³',
          values: [10.68, 11.83, 15.72, 15.78]),
      ParamRow(
          name: 'Mn (DTPA)',
          baseUnit: 'mg/dm³',
          values: [2.46, 2.72, 10.90, 11.66]),
      ParamRow(
          name: 'Zn (DTPA)',
          baseUnit: 'mg/dm³',
          values: [0.75, 1.06, 1.41, 0.90]),
    ]),
    ParamGroup('Granulometria', [
      ParamRow(
          name: 'Argila',
          baseUnit: 'g/dm³',
          values: [419.0, 396.5, 448.5, 523.5],
          decimals: 1),
      ParamRow(
          name: 'Silte',
          baseUnit: 'g/dm³',
          values: [54.0, 46.5, 76.5, 76.5],
          decimals: 1),
      ParamRow(
          name: 'Areia',
          baseUnit: 'g/dm³',
          values: [527.0, 557.0, 475.0, 400.0],
          decimals: 1),
      ParamRow(
          name: 'Na', baseUnit: 'mg/dm³', values: [3.07, 3.10, 2.80, 2.20]),
    ]),
  ];
}

// ── Widget principal ──────────────────────────────────────────────────────────

/// Tabela de resultados de análise de solo com scroll horizontal.
///
/// [headers] — lista de [AmostraHeader] (uma por coluna).
/// [groups]  — opcional; se nulo usa o dataset Exata Brasil de exemplo.
class AnaliseResultadoTable extends StatefulWidget {
  final List<AmostraHeader> headers;
  final List<ParamGroup>? groups; // passe null para usar dados de exemplo

  const AnaliseResultadoTable({
    super.key,
    required this.headers,
    this.groups,
  });

  @override
  State<AnaliseResultadoTable> createState() => _AnaliseResultadoTableState();
}

class _AnaliseResultadoTableState extends State<AnaliseResultadoTable> {
  static const double _paramColWidth = 140;
  static const double _sampleColWidth = 92;
  static const double _divider = 0.5;

  static const double _headerHeight = 54;
  static const double _groupHeight = 32;
  static const double _rowHeight = 56;

  late List<ParamGroup> _groups;
  late List<List<List<int>>>
      _steps; // [groupIdx][rowIdx][sampleIdx] = stepIndex

  @override
  void initState() {
    super.initState();
    _syncFromWidget();
  }

  @override
  void didUpdateWidget(covariant AnaliseResultadoTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.headers.length != widget.headers.length ||
        oldWidget.groups != widget.groups) {
      _syncFromWidget();
    }
  }

  void _syncFromWidget() {
    _groups = widget.groups ?? _buildExataGroups();
    _steps = _groups
        .map(
          (g) => g.rows
              .map((_) => List<int>.filled(widget.headers.length, 0))
              .toList(),
        )
        .toList();
  }

  void _onTap(int groupIndex, int rowIndex, int sampleIndex) {
    final row = _groups[groupIndex].rows[rowIndex];
    final steps = _stepsFor(row.convType);
    if (steps.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _steps[groupIndex][rowIndex][sampleIndex] =
          (_steps[groupIndex][rowIndex][sampleIndex] + 1) % steps.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sampleAreaWidth = widget.headers.length * _sampleColWidth;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: _C.card,
          border: Border.all(color: _C.borderSoft, width: _divider),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _paramColWidth,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                      right: BorderSide(color: _C.borderSoft, width: _divider)),
                ),
                child: _buildLeftColumn(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: sampleAreaWidth,
                  child: _buildRightColumn(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hDivider() => const SizedBox(
        height: _divider,
        child: ColoredBox(color: _C.borderSoft),
      );

  // ── Left (sticky) column ────────────────────────────────────────────────
  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _leftCell(
          height: _headerHeight,
          color: _C.bg,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'PARÂMETRO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _C.textSub,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ),
        _hDivider(),
        for (final group in _groups) ...[
          _leftCell(
            height: _groupHeight,
            color: _C.groupBg,
            border: const Border(
                bottom: BorderSide(color: _C.borderSoft, width: _divider)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Text(
                group.label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _C.primary,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ),
          for (final row in group.rows) _buildParamRowCell(row),
        ],
      ],
    );
  }

  Widget _buildParamRowCell(ParamRow row) {
    return _leftCell(
      height: _rowHeight,
      color: _C.card,
      border: const Border(
          bottom: BorderSide(color: _C.borderSoft, width: _divider)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              row.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _C.textMain,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (row.baseUnit.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                row.baseUnit,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: _C.textLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _leftCell({
    required double height,
    required Color color,
    BoxBorder? border,
    required Widget child,
  }) {
    return Container(
      height: height,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(color: color, border: border),
      child: child,
    );
  }

  // ── Right (scrollable) columns ───────────────────────────────────────────
  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: _headerHeight,
          color: _C.bg,
          child: Row(
            children: [
              for (final h in widget.headers)
                _SampleHeaderCell(header: h, width: _sampleColWidth)
            ],
          ),
        ),
        _hDivider(),
        for (int gi = 0; gi < _groups.length; gi++) ...[
          Container(
            height: _groupHeight,
            decoration: const BoxDecoration(
              color: _C.groupBg,
              border: Border(
                  bottom: BorderSide(color: _C.borderSoft, width: _divider)),
            ),
          ),
          for (int ri = 0; ri < _groups[gi].rows.length; ri++)
            _buildValuesRow(gi, ri),
        ],
      ],
    );
  }

  Widget _buildValuesRow(int groupIndex, int rowIndex) {
    final row = _groups[groupIndex].rows[rowIndex];
    final steps = _stepsFor(row.convType);
    final hasTap = steps.isNotEmpty;

    return Container(
      height: _rowHeight,
      decoration: const BoxDecoration(
        color: _C.card,
        border:
            Border(bottom: BorderSide(color: _C.borderSoft, width: _divider)),
      ),
      child: Row(
        children: [
          for (int si = 0; si < widget.headers.length; si++)
            _ValueCell(
              width: _sampleColWidth,
              height: _rowHeight,
              value: row.values.length > si ? row.values[si] : null,
              baseDecimals: row.decimals,
              steps: steps,
              stepIndex: _steps[groupIndex][rowIndex][si],
              hasTap: hasTap,
              onTap: hasTap ? () => _onTap(groupIndex, rowIndex, si) : null,
            ),
        ],
      ),
    );
  }
}

// ── Sample header cell ───────────────────────────────────────────────────────
class _SampleHeaderCell extends StatelessWidget {
  final AmostraHeader header;
  final double width;
  const _SampleHeaderCell({required this.header, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              header.nome,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _C.textMain,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              header.codigo,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: _C.textLight,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Value cell ───────────────────────────────────────────────────────────────
class _ValueCell extends StatefulWidget {
  final double width;
  final double height;
  final double? value;
  final int baseDecimals;
  final List<_UnitStep> steps;
  final int stepIndex;
  final bool hasTap;
  final VoidCallback? onTap;

  const _ValueCell({
    required this.width,
    required this.height,
    required this.value,
    required this.baseDecimals,
    required this.steps,
    required this.stepIndex,
    required this.hasTap,
    required this.onTap,
  });

  @override
  State<_ValueCell> createState() => _ValueCellState();
}

class _ValueCellState extends State<_ValueCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<Color?> _numColor;
  late Animation<Color?> _unitColor;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _numColor = ColorTween(begin: _C.primary, end: _C.textMain).animate(_ac);
    _unitColor = ColorTween(begin: _C.primary, end: _C.textSub).animate(_ac);
  }

  @override
  void didUpdateWidget(covariant _ValueCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stepIndex != widget.stepIndex) {
      _ac.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  bool get _isConverted => widget.stepIndex > 0;

  String _formattedValue() {
    if (widget.value == null) return '—';
    if (widget.steps.isEmpty) {
      return widget.value!.toStringAsFixed(widget.baseDecimals);
    }
    final step = widget.steps[widget.stepIndex];
    return (widget.value! * step.factor).toStringAsFixed(step.decimals);
  }

  String _unitLabel() {
    if (widget.steps.isEmpty) return '';
    return widget.steps[widget.stepIndex].label;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _ac,
              builder: (_, __) {
                final numColor = _ac.isAnimating
                    ? _numColor.value ?? _C.textMain
                    : (_isConverted ? _C.primary : _C.textMain);
                final unitColor = _ac.isAnimating
                    ? _unitColor.value ?? _C.textSub
                    : (_isConverted ? _C.primary : _C.textSub);

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formattedValue(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: numColor,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_unitLabel().isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          _unitLabel(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: _isConverted
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: unitColor,
                            letterSpacing: 0.1,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            if (widget.hasTap)
              Positioned(
                bottom: 10,
                child: Container(
                  width: 20,
                  height: 1.5,
                  decoration: BoxDecoration(
                    color: _C.primary.withAlpha(64),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Tela de exemplo (pode remover em produção) ───────────────────────────────
class AnaliseResultadoScreen extends StatelessWidget {
  const AnaliseResultadoScreen({super.key});

  static const _headers = [
    AmostraHeader(nome: 'Talhão 1', codigo: 'SBA24.124624'),
    AmostraHeader(nome: 'Talhão 2', codigo: 'SBA24.124625'),
    AmostraHeader(nome: 'Talhão 3', codigo: 'SBA24.124626'),
    AmostraHeader(nome: 'Talhão 4', codigo: 'SBA24.124627'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: Colors.white.withAlpha(235),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: _C.primary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nova Análise',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: _C.textMain,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: _C.borderSoft),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          const _LaudoInfoCard(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _C.primaryBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child:
                      const Icon(Icons.swap_horiz, size: 12, color: _C.primary),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Toque em um valor para converter a unidade',
                  style: TextStyle(fontSize: 11, color: _C.textSub),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AnaliseResultadoTable(headers: _headers),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _LaudoInfoCard extends StatelessWidget {
  const _LaudoInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.borderSoft, width: 0.5),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          const _InfoRow('Laboratório', 'Exata Brasil — BA'),
          const _Divider(),
          const _InfoRow('Propriedade', 'Serrote — Nova Rosalandia/TO'),
          const _InfoRow('Certificado', '20573.2024'),
          const _InfoRow('Emissão', '25/09/2024'),
          const _Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Talhões importados',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _C.textSub,
                    letterSpacing: 0.4,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _C.primaryBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 6, color: _C.primary),
                      SizedBox(width: 4),
                      Text(
                        '4 selecionados',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _C.primary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _C.textSub,
              letterSpacing: 0.4,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _C.textMain,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 0.5, child: ColoredBox(color: _C.borderSoft));
}
