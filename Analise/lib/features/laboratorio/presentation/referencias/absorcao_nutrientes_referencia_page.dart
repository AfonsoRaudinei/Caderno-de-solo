import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/absorcao_nutrientes_data.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/absorcao_nutrientes_models.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/widgets/absorcao_card_wrapper.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/widgets/absorcao_dropdown_field.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/widgets/absorcao_info_card.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/widgets/absorcao_reference_table_card.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/widgets/absorcao_stats_card.dart';

class AbsorcaoNutrientesReferenciaPage extends StatefulWidget {
  const AbsorcaoNutrientesReferenciaPage({super.key});

  @override
  State<AbsorcaoNutrientesReferenciaPage> createState() =>
      _AbsorcaoNutrientesReferenciaPageState();
}

class _AbsorcaoNutrientesReferenciaPageState
    extends State<AbsorcaoNutrientesReferenciaPage> {
  final TextEditingController _yieldController = TextEditingController(
    text: '4.2',
  );

  String _sourceType = AbsorcaoNutrientesData.nutrientData.keys.first;
  late String _selectedSource = _sourceNames.first;
  String _selectedNutrient = AbsorcaoNutrientesData.nutrientNames.keys.first;
  String _selectedDataType = 'Extração';
  ViewMode _viewMode = ViewMode.perStage;
  ReferenceSection _section = ReferenceSection.painel;

  List<String> get _sourceNames =>
      AbsorcaoNutrientesData.nutrientData[_sourceType]?.keys
          .toList(growable: false) ??
      const [];
  String get _sourceLabel => _sourceType == 'Autores'
      ? 'Autor'
      : _sourceType == 'Guidorizzi'
          ? 'Tecnologia'
          : 'Cultivar';

  List<String> get _macroNutrients => const ['N', 'P', 'K', 'Ca', 'Mg', 'S'];
  List<String> get _microNutrients => const [
        'B',
        'Cu',
        'Fe',
        'Mn',
        'Zn',
        'Mo',
        'Co',
        'Ni',
        'Se',
      ];

  double get _expectedYield {
    final parsed = double.tryParse(
      _yieldController.text.replaceAll(',', '.'),
    );
    if (parsed == null || parsed <= 0) {
      return 4.2;
    }
    return parsed;
  }

  DataValue resolveDataValue() {
    final source =
        AbsorcaoNutrientesData.nutrientData[_sourceType]?[_selectedSource];
    if (source == null) {
      return const DataValue(
        valuePerTon: 0,
        quality: DataQuality.unavailable,
      );
    }

    final selectedValue = source[_selectedDataType]?[_selectedNutrient] ?? 0;
    if (selectedValue > 0) {
      return DataValue(
        valuePerTon: selectedValue,
        quality: DataQuality.original,
      );
    }

    final oppositeType =
        _selectedDataType == 'Extração' ? 'Exportação' : 'Extração';
    final oppositeValue = source[oppositeType]?[_selectedNutrient] ?? 0;
    final index = AbsorcaoNutrientesData.exportIndexes[_selectedNutrient] ?? 0;
    if (oppositeValue <= 0 || index <= 0) {
      return const DataValue(
        valuePerTon: 0,
        quality: DataQuality.unavailable,
      );
    }

    final calculated = _selectedDataType == 'Exportação'
        ? oppositeValue * index
        : oppositeValue / index;
    return DataValue(
      valuePerTon: calculated,
      quality: DataQuality.calculated,
    );
  }

  List<StagePoint> computeStageData() {
    final resolved = resolveDataValue();
    final percentages =
        AbsorcaoNutrientesData.absorptionPercentages[_selectedNutrient];
    if (percentages == null) {
      return const [];
    }

    final isMacro = _macroNutrients.contains(_selectedNutrient);
    final valuePerTonInKg =
        isMacro ? resolved.valuePerTon : resolved.valuePerTon / 1000;
    final totalInKg = valuePerTonInKg * _expectedYield;
    final useGram = totalInKg < 1;
    final multiplier = useGram ? 1000.0 : 1.0;

    return List<StagePoint>.generate(AbsorcaoNutrientesData.stageKeys.length,
        (index) {
      final key = AbsorcaoNutrientesData.stageKeys[index];
      final currentPct = percentages[key] ?? 0;
      final previousPct = index == 0
          ? 0
          : (percentages[AbsorcaoNutrientesData.stageKeys[index - 1]] ?? 0);

      final pctForMode = _viewMode == ViewMode.accumulated
          ? currentPct
          : currentPct - previousPct;
      final value = (pctForMode / 100) * totalInKg * multiplier;

      return StagePoint(
        stage: AbsorcaoNutrientesData.stages[index],
        percentage: pctForMode,
        value: value,
      );
    });
  }

  String get displayUnit {
    final resolved = resolveDataValue();
    final isMacro = _macroNutrients.contains(_selectedNutrient);
    final valuePerTonInKg =
        isMacro ? resolved.valuePerTon : resolved.valuePerTon / 1000;
    final totalInKg = valuePerTonInKg * _expectedYield;
    return totalInKg < 1 ? 'g' : 'kg';
  }

  @override
  void dispose() {
    _yieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final stageData = computeStageData();
    final resolved = resolveDataValue();
    final unit = displayUnit;
    final total = stageData.isEmpty
        ? 0.0
        : (_viewMode == ViewMode.accumulated
            ? stageData.last.value
            : stageData.fold<double>(0, (sum, row) => sum + row.value));
    final modeText =
        _viewMode == ViewMode.accumulated ? 'Acumulado' : 'Por Estádio';

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        title: const Text('Absorção de Nutrientes'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 12),
            _buildSectionSwitcher(),
            const SizedBox(height: 12),
            _buildFiltersCard(),
            if (_section == ReferenceSection.painel) ...[
              const SizedBox(height: 12),
              AbsorcaoStatsCard(
                total: total,
                unit: unit,
                quality: resolved.quality,
                expectedYield: _expectedYield,
                selectedNutrient: _selectedNutrient,
              ),
              const SizedBox(height: 12),
              _buildChartCard(stageData, unit, modeText),
              const SizedBox(height: 12),
              AbsorcaoInfoCard(
                unit: unit,
                quality: resolved.quality,
                modeText: modeText,
                isAccumulated: _viewMode == ViewMode.accumulated,
              ),
              const SizedBox(height: 12),
              _buildTableCard(stageData, unit),
              const SizedBox(height: 12),
              _buildIndexReferenceCard(),
            ] else ...[
              const SizedBox(height: 12),
              _buildReferenceTablesView(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AbsorcaoNutrientesCores.greenDark,
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REFERÊNCIA TÉCNICA',
            style: AppTextStyles.caption.copyWith(
              color: AbsorcaoNutrientesCores.greenAccent,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Absorção de Nutrientes em Soja',
            style: AppTextStyles.headline.copyWith(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Análise por estádio fenológico para apoiar recomendação agronômica.',
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSwitcher() {
    final palette = context.appPalette;

    return Container(
      decoration: BoxDecoration(
        color: AbsorcaoNutrientesCores.sectionSwitcherBg(isDark: palette.isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AbsorcaoNutrientesCores.sectionSwitcherBorder(
            isDark: palette.isDark,
          ),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildSectionButton(
              label: 'Painel',
              section: ReferenceSection.painel,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildSectionButton(
              label: 'Tabelas',
              section: ReferenceSection.tabelas,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionButton({
    required String label,
    required ReferenceSection section,
  }) {
    final palette = context.appPalette;
    final isSelected = _section == section;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _section = section),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? palette.cardStrong : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? palette.borderStrong : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              fontSize: 13,
              color: isSelected
                  ? palette.textPrimary
                  : palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersCard() {
    final palette = context.appPalette;

    return AbsorcaoCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros de análise',
            style: AppTextStyles.sectionLabel.copyWith(
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          AbsorcaoDropdownField<String>(
            label: 'Tipo de Fonte',
            value: _sourceType,
            items: AbsorcaoNutrientesData.nutrientData.keys.toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _sourceType = value;
                _selectedSource =
                    _sourceNames.isNotEmpty ? _sourceNames.first : '';
              });
            },
          ),
          const SizedBox(height: 10),
          AbsorcaoDropdownField<String>(
            label: _sourceLabel,
            value: _selectedSource.isNotEmpty ? _selectedSource : null,
            items: _sourceNames,
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _selectedSource = value);
            },
          ),
          const SizedBox(height: 10),
          AbsorcaoDropdownField<String>(
            label: 'Nutriente',
            value: _selectedNutrient,
            items: AbsorcaoNutrientesData.nutrientNames.keys.toList(),
            labelBuilder: (nutrient) =>
                AbsorcaoNutrientesData.nutrientNames[nutrient] ?? nutrient,
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _selectedNutrient = value);
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AbsorcaoDropdownField<String>(
                  label: 'Tipo de Dado',
                  value: _selectedDataType,
                  items: const ['Extração', 'Exportação'],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _selectedDataType = value);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AbsorcaoDropdownField<ViewMode>(
                  label: 'Visualização',
                  value: _viewMode,
                  items: const [ViewMode.perStage, ViewMode.accumulated],
                  labelBuilder: (mode) =>
                      mode == ViewMode.perStage ? 'Por Estádio' : 'Acumulado',
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _viewMode = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Produtividade esperada (t/ha)',
            style: AppTextStyles.label.copyWith(
              fontSize: 13,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _yieldController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            style: AppTextStyles.body.copyWith(color: palette.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: palette.inputFill,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: palette.borderStrong),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AbsorcaoNutrientesCores.greenAccent,
                  width: 1.5,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: palette.borderStrong),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(
    List<StagePoint> stageData,
    String unit,
    String modeText,
  ) {
    final palette = context.appPalette;
    final maxValue = stageData.isEmpty
        ? 1.0
        : stageData.fold<double>(0, (max, row) => math.max(max, row.value));

    return AbsorcaoCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Curva de absorção ($modeText)',
            style: AppTextStyles.headline.copyWith(
              fontSize: 18,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$_sourceType · $_selectedSource',
            style: AppTextStyles.caption.copyWith(
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...stageData.map((row) {
            final widthFactor = (row.value / maxValue).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          row.stage,
                          style: AppTextStyles.label.copyWith(
                            fontSize: 12,
                            color: AbsorcaoNutrientesCores.accentText(
                              isDark: palette.isDark,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              Container(
                                height: 12,
                                color: AbsorcaoNutrientesCores.progressTrack(
                                  isDark: palette.isDark,
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: widthFactor,
                                child: Container(
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AbsorcaoNutrientesCores.greenDark,
                                        AbsorcaoNutrientesCores.greenAccent
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${row.value.toStringAsFixed(2)} $unit · ${row.percentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableCard(List<StagePoint> stageData, String unit) {
    final palette = context.appPalette;
    final pctHeader =
        _viewMode == ViewMode.accumulated ? '% Acumulada' : '% no Estádio';
    final valueHeader =
        _viewMode == ViewMode.accumulated ? 'Acumulado' : 'No Estádio';

    return AbsorcaoCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados por estádio',
            style: AppTextStyles.headline.copyWith(
              fontSize: 18,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: palette.border,
              ),
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(Colors.transparent),
                dataRowColor: WidgetStateProperty.all(Colors.transparent),
                headingTextStyle: AppTextStyles.label.copyWith(
                  color: palette.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                dataTextStyle: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: palette.textPrimary,
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      'Estádio',
                      style: AppTextStyles.label.copyWith(
                        color: palette.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      pctHeader,
                      style: AppTextStyles.label.copyWith(
                        color: palette.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      '$valueHeader ($unit)',
                      style: AppTextStyles.label.copyWith(
                        color: palette.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                rows: stageData
                    .map(
                      (row) => DataRow(
                        cells: [
                          DataCell(
                            Text(
                              row.stage,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 13,
                                color: palette.textPrimary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${row.percentage.toStringAsFixed(1)}%',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 13,
                                color: palette.textPrimary,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              row.value.toStringAsFixed(2),
                              style: AppTextStyles.body.copyWith(
                                fontSize: 13,
                                color: palette.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexReferenceCard() {
    final palette = context.appPalette;
    final indexEntries =
        AbsorcaoNutrientesData.exportIndexes.entries.toList(growable: false);

    return AbsorcaoCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Índices médios de exportação',
            style: AppTextStyles.headline.copyWith(
              fontSize: 18,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: indexEntries
                .map(
                  (entry) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: palette.cardStrong,
                      border: Border.all(color: palette.borderStrong),
                    ),
                    child: Text(
                      '${entry.key}: ${(entry.value * 100).toStringAsFixed(1)}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AbsorcaoNutrientesCores.chipText(
                          isDark: palette.isDark,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          Text(
            'Quando faltam dados diretos de extração/exportação, o valor é estimado por índice.',
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceTablesView() {
    final source =
        AbsorcaoNutrientesData.nutrientData[_sourceType]?[_selectedSource];
    final exportacao = source?['Exportação'] ?? const <String, double>{};
    final extracao = source?['Extração'] ?? const <String, double>{};

    final cards = <ReferenceTableCardData>[
      ReferenceTableCardData(
        title: 'Extração — Macronutrientes',
        description:
            'Valores de extração por tonelada. Fonte: $_sourceType · $_selectedSource.',
        unit: 'kg/t',
        rows: _buildNutrientRows(
          extracao,
          _macroNutrients,
          unit: 'kg/t',
        ),
      ),
      ReferenceTableCardData(
        title: 'Exportação — Macronutrientes',
        description:
            'Valores de exportação por tonelada. Fonte: $_sourceType · $_selectedSource.',
        unit: 'kg/t',
        rows: _buildNutrientRows(
          exportacao,
          _macroNutrients,
          unit: 'kg/t',
        ),
      ),
      ReferenceTableCardData(
        title: 'Extração — Micronutrientes',
        description:
            'Micronutrientes por tonelada com base na literatura selecionada.',
        unit: 'g/t',
        rows: _buildNutrientRows(
          extracao,
          _microNutrients,
          unit: 'g/t',
        ),
      ),
      ReferenceTableCardData(
        title: 'Exportação — Micronutrientes',
        description: 'Micronutrientes exportados por tonelada na colheita.',
        unit: 'g/t',
        rows: _buildNutrientRows(
          exportacao,
          _microNutrients,
          unit: 'g/t',
        ),
      ),
      ReferenceTableCardData(
        title: 'Curva Acumulada — $_selectedNutrient',
        description: 'Percentual acumulado de absorção por estádio fenológico.',
        unit: '%',
        rows: _buildStagePercentRows(accumulated: true),
      ),
      ReferenceTableCardData(
        title: 'Absorção por Estádio — $_selectedNutrient',
        description: 'Percentual absorvido em cada estádio individual.',
        unit: '%',
        rows: _buildStagePercentRows(accumulated: false),
      ),
    ];

    return Column(
      children: cards
          .map(
            (card) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AbsorcaoReferenceTableCard(card: card),
            ),
          )
          .toList(),
    );
  }

  List<ReferenceTableRow> _buildNutrientRows(
    Map<String, double> values,
    List<String> nutrients, {
    required String unit,
  }) {
    return nutrients.map((nutrient) {
      final raw = values[nutrient];
      final label = AbsorcaoNutrientesData.nutrientNames[nutrient] ?? nutrient;
      final formatted = raw == null ? '—' : '${raw.toStringAsFixed(2)} $unit';
      return ReferenceTableRow(label: label, value: formatted);
    }).toList(growable: false);
  }

  List<ReferenceTableRow> _buildStagePercentRows({required bool accumulated}) {
    final percentages =
        AbsorcaoNutrientesData.absorptionPercentages[_selectedNutrient];
    if (percentages == null) {
      return const [];
    }

    return List<ReferenceTableRow>.generate(
        AbsorcaoNutrientesData.stageKeys.length, (index) {
      final key = AbsorcaoNutrientesData.stageKeys[index];
      final current = percentages[key] ?? 0;
      final previous = index == 0
          ? 0
          : (percentages[AbsorcaoNutrientesData.stageKeys[index - 1]] ?? 0);
      final value = accumulated ? current : current - previous;
      return ReferenceTableRow(
        label: AbsorcaoNutrientesData.stages[index],
        value: '${value.toStringAsFixed(1)} %',
      );
    });
  }
}
