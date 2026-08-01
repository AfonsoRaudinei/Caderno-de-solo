import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/usecases/calcular_derivados_analise.dart';
import 'package:soloforte/features/analise/presentation/formatters/analise_number_formatter.dart';
import 'package:soloforte/features/analise/presentation/formatters/coordinate_formatter.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';

class AnaliseDetailScreen extends ConsumerStatefulWidget {
  final String analiseId;
  static const _calc = CalcularDerivadosAnalise();

  const AnaliseDetailScreen({super.key, required this.analiseId});

  @override
  ConsumerState<AnaliseDetailScreen> createState() =>
      _AnaliseDetailScreenState();
}

class _AnaliseDetailScreenState extends ConsumerState<AnaliseDetailScreen> {
  static const String _analiseIcon = 'assets/icons/analises.png';

  bool _isEditing = false;

  void _toggleEditMode() => setState(() => _isEditing = !_isEditing);

  @override
  Widget build(BuildContext context) {
    final analises = ref.watch(analiseNotifierProvider).valueOrNull ?? [];
    final analiseIndex = analises.indexWhere((a) => a.id == widget.analiseId);

    if (analiseIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Análise não encontrada')),
        body:
            const Center(child: Text('A análise foi deletada ou não existe.')),
      );
    }

    final analise = analises[analiseIndex];

    return PopScope(
      canPop: !_isEditing,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isEditing) {
          setState(() => _isEditing = false);
        }
      },
      child: Scaffold(
        backgroundColor: context.appPalette.background,
        appBar: AppBar(
          title: Text(analise.talhao),
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              tooltip: _isEditing ? 'Concluir edição' : 'Editar',
              onPressed: _toggleEditMode,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Excluir',
              onPressed: () => _confirmDelete(context, analise),
            ),
          ],
        ),
        body: _buildViewBody(context, analise),
      ),
    );
  }

  Widget _buildViewBody(BuildContext context, AnaliseSolo analise) {
    final palette = _AnaliseDetailPalette.of(context);
    final derivados = AnaliseDetailScreen._calc.call({
      'ca': analise.ca,
      'mg': analise.mg,
      'k': analise.k,
      'na': analise.na,
      'al': analise.al,
      'hMaisAl': analise.hMaisAl,
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSurface(
            showBorder: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppIconFrame(
                  assetPath: _analiseIcon,
                  size: AppDimens.cardIconSize,
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        analise.talhao.trim().isEmpty
                            ? 'Amostra de solo'
                            : analise.talhao,
                        style: AppTextStyles.headline.copyWith(
                          fontSize: 20,
                          color: palette.valueText,
                        ),
                      ),
                      const SizedBox(height: AppDimens.xs),
                      Text(
                        analise.cultura.label,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimens.sm),
                      _HeaderInfoLine(
                        label: 'Produtor',
                        value: analise.produtor,
                        color: palette.mutedText,
                      ),
                      _HeaderInfoLine(
                        label: 'Fazenda',
                        value: analise.fazenda,
                        color: palette.mutedText,
                      ),
                      _HeaderInfoLine(
                        label: 'Nº Amostra',
                        value: analise.numeroAmostra,
                        color: palette.mutedText,
                      ),
                      _HeaderInfoLine(
                        label: 'Safra',
                        value: analise.safra,
                        color: palette.mutedText,
                      ),
                      _HeaderInfoLine(
                        label: 'Laboratório',
                        value: analise.laboratorio,
                        color: palette.mutedText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppSurface(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.sm,
              vertical: AppDimens.xs,
            ),
            showBorder: true,
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.science_outlined,
                    label: 'Recomendar',
                    color: AppColors.success,
                    onTap: () {
                      context.go(
                        AppRoutes.labRecomendacao,
                        extra: analise.id,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'PDF',
                    color: AppColors.error,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Baixando ou abrindo laudo anexado'),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.map_outlined,
                    label: 'Mapa',
                    color: AppColors.primary,
                    onTap: () => _openMapForView(analise),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppSurface(
            showBorder: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle('Localização', palette),
                const SizedBox(height: 8),
                _buildDataRow(
                  'Lat/Long',
                  CoordinateFormatter.formatCombined(
                    analise.latitude,
                    analise.longitude,
                  ),
                  palette,
                  fieldKey: 'latLong',
                  analise: analise,
                  isText: true,
                ),
                _buildMapActionRow(
                  'Ir ao mapa',
                  analise.latitude == null || analise.longitude == null
                      ? 'Selecionar ponto'
                      : 'Alterar ponto',
                  palette,
                  onTap: () => _openMapForSelection(analise),
                ),
                _buildDataRow(
                  'Descrição',
                  analise.descricaoLocal ?? '-',
                  palette,
                  fieldKey: 'descricaoLocal',
                  analise: analise,
                  isText: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Composição Física', palette),
          const SizedBox(height: 8),
          _buildDataRow('Argila (g/kg)', _fmt(analise.argila), palette,
              fieldKey: 'argila', analise: analise),
          _buildDataRow('Silte (g/kg)', _fmt(analise.silte), palette,
              fieldKey: 'silte', analise: analise),
          _buildDataRow('Areia Total (g/kg)', _fmt(analise.areiaTotal), palette,
              fieldKey: 'areiaTotal', analise: analise),
          _buildDataRow('Profundidade', analise.profundidade, palette,
              fieldKey: 'profundidade', analise: analise, isText: true),
          Divider(color: palette.divider),
          _buildSectionTitle('pH', palette),
          const SizedBox(height: 8),
          _buildDataRow('pH Água', _fmt(analise.phAgua), palette,
              fieldKey: 'phAgua', analise: analise),
          _buildDataRow('pH SMP', _fmt(analise.phSmp), palette,
              fieldKey: 'phSmp', analise: analise),
          _buildDataRow('pH CaCl₂', _fmt(analise.phCaCl2), palette,
              fieldKey: 'phCaCl2', analise: analise),
          Divider(color: palette.divider),
          _buildSectionTitle('Matéria Orgânica', palette),
          const SizedBox(height: 8),
          _buildDataRow('M.O. (dag/kg)', _fmt(analise.materiaOrganica), palette,
              fieldKey: 'materiaOrganica', analise: analise),
          _buildDataRow(
              'C Orgânico (dag/kg)', _fmt(analise.carbonoOrganico), palette,
              fieldKey: 'carbonoOrganico', analise: analise),
          Divider(color: palette.divider),
          _buildSectionTitle('Fósforo', palette),
          const SizedBox(height: 8),
          _buildDataRow('P Mehlich (mg/dm³)', _fmt(analise.pMehlich), palette,
              fieldKey: 'pMehlich', analise: analise),
          _buildDataRow('P Total (%)', _fmt(analise.pTotal), palette,
              fieldKey: 'pTotal', analise: analise),
          _buildDataRow('P Resina (mg/dm³)', _fmt(analise.pResina), palette,
              fieldKey: 'pResina', analise: analise),
          _buildDataRow('P-rem (mg/L)', _fmt(analise.pRem), palette,
              fieldKey: 'pRem', analise: analise),
          Divider(color: palette.divider),
          _buildSectionTitle('Enxofre', palette),
          const SizedBox(height: 8),
          _buildDataRow('S 0-20 (mg/dm³)', _fmt(analise.s020), palette,
              fieldKey: 's020', analise: analise),
          _buildDataRow('S 20-40 (mg/dm³)', _fmt(analise.s2040), palette,
              fieldKey: 's2040', analise: analise),
          Divider(color: palette.divider),
          _buildSectionTitle('Macronutrientes', palette),
          const SizedBox(height: 8),
          _buildDataRow('Potássio (cmolc/dm³)', _fmt(analise.k), palette,
              fieldKey: 'k', analise: analise),
          _buildDataRow('Cálcio (cmolc/dm³)', _fmt(analise.ca), palette,
              fieldKey: 'ca', analise: analise),
          _buildDataRow('Magnésio (cmolc/dm³)', _fmt(analise.mg), palette,
              fieldKey: 'mg', analise: analise),
          _buildDataRow('Alumínio (cmolc/dm³)', _fmt(analise.al), palette,
              fieldKey: 'al', analise: analise),
          _buildDataRow('H+Al (cmolc/dm³)', _fmt(analise.hMaisAl), palette,
              fieldKey: 'hMaisAl', analise: analise),
          _buildDataRow('Sódio (cmolc/dm³)', _fmt(analise.na), palette,
              fieldKey: 'na', analise: analise),
          Divider(color: palette.divider),
          _buildSectionTitle('Bases e CTC', palette),
          const SizedBox(height: 8),
          _buildDataRow('SB (cmolc/dm³)',
              _fmt(_labOrDerived(analise.sb, derivados['sb'])), palette),
          _buildDataRow('CTC(T) (cmolc/dm³)',
              _fmt(_labOrDerived(analise.ctc, derivados['ctcTotal'])), palette),
          _buildDataRow(
              'CTC(e) (cmolc/dm³)',
              _fmt(_labOrDerived(analise.ctcEfetiva, derivados['ctcEfetiva'])),
              palette),
          _buildDataRow(
              'V% (%)',
              _fmtPercent(_labOrDerived(analise.vPercent, derivados['vPct'])),
              palette),
          _buildDataRow(
              'm% (%)',
              _fmtPercent(_labOrDerived(analise.mPercent, derivados['mPct'])),
              palette),
          Divider(color: palette.divider),
          _buildSectionTitle('Saturação das Bases', palette),
          const SizedBox(height: 8),
          _buildDataRow('Ca/T (%)', _fmtPercent(derivados['caPctT']), palette),
          _buildDataRow('Mg/T (%)', _fmtPercent(derivados['mgPctT']), palette),
          _buildDataRow('K/T (%)', _fmtPercent(derivados['kPctT']), palette),
          _buildDataRow(
              'H+Al/T (%)', _fmtPercent(derivados['hAlPctT']), palette),
          Divider(color: palette.divider),
          _buildSectionTitle('Relações entre Bases', palette),
          const SizedBox(height: 8),
          _buildDataRow('Ca/Mg', _fmtRatio(derivados['relCaMg']), palette),
          _buildDataRow('Ca/K', _fmtRatio(derivados['relCaK']), palette),
          _buildDataRow('Mg/K', _fmtRatio(derivados['relMgK']), palette),
          _buildDataRow(
              '(Ca+Mg)/T (%)', _fmtPercent(derivados['relCaMgT']), palette),
          Divider(color: palette.divider),
          _buildSectionTitle('Micronutrientes (mg/dm³)', palette),
          const SizedBox(height: 8),
          _buildDataRow('Boro', _fmt(analise.b), palette,
              fieldKey: 'b', analise: analise),
          _buildDataRow('Cobre', _fmt(analise.cu), palette,
              fieldKey: 'cu', analise: analise),
          _buildDataRow('Ferro', _fmt(analise.fe), palette,
              fieldKey: 'fe', analise: analise),
          _buildDataRow('Manganês', _fmt(analise.mn), palette,
              fieldKey: 'mn', analise: analise),
          _buildDataRow('Zinco', _fmt(analise.zn), palette,
              fieldKey: 'zn', analise: analise),
          _buildDataRow('Níquel', _fmt(analise.ni), palette,
              fieldKey: 'ni', analise: analise),
          _buildDataRow('Molibdênio', _fmt(analise.mo), palette,
              fieldKey: 'mo', analise: analise),
          _buildDataRow('Selênio', _fmt(analise.se), palette,
              fieldKey: 'se', analise: analise),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AnaliseSolo analise) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir'),
        content: const Text('Tem certeza que deseja excluir esta análise?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(analiseNotifierProvider.notifier).deletar(analise.id);
      if (context.mounted) context.pop();
    }
  }

  Widget _buildSectionTitle(String title, _AnaliseDetailPalette palette) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: palette.sectionText,
        ),
      ),
    );
  }

  Widget _buildDataRow(
    String label,
    String value,
    _AnaliseDetailPalette palette, {
    String? fieldKey,
    AnaliseSolo? analise,
    bool isText = false,
  }) {
    final isVazio =
        value == '-' || value.isEmpty || value == 'N/A' || value == 'null';
    final canEdit = _isEditing && fieldKey != null && analise != null;
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: palette.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              isVazio ? 'Não informado' : value,
              textAlign: TextAlign.right,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: isVazio ? Colors.orange : palette.valueText,
              ),
            ),
          ),
          if (canEdit) ...[
            const SizedBox(width: 6),
            Icon(Icons.edit_outlined, size: 14, color: palette.editIcon),
          ],
        ],
      ),
    );

    if (!canEdit) return row;

    return InkWell(
      key: ValueKey('edit_row_$fieldKey'),
      borderRadius: BorderRadius.circular(10),
      onTap: () => _editField(
        analise: analise,
        fieldKey: fieldKey,
        label: label,
        currentValue: isVazio ? '' : value,
        isText: isText,
      ),
      child: row,
    );
  }

  Widget _buildMapActionRow(
    String label,
    String value,
    _AnaliseDetailPalette palette, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: const ValueKey('select_location_on_map'),
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: palette.mutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: palette.valueText,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.map_outlined, size: 16, color: palette.editIcon),
          ],
        ),
      ),
    );
  }

  String _fmt(num? value) => AnaliseNumberFormatter.formatDecimal(value);
  String _fmtPercent(num? value) =>
      AnaliseNumberFormatter.formatDecimal(value, decimals: 0);
  String _fmtRatio(num? value) =>
      AnaliseNumberFormatter.formatDecimal(value, decimals: 1);

  double? _labOrDerived(num? labValue, num? derivedValue) =>
      labValue?.toDouble() ?? derivedValue?.toDouble();

  String _mapRoute(AnaliseSolo analise, {bool selectionMode = false}) {
    final params = {
      'analiseId': analise.id,
      if (selectionMode) 'selectionMode': 'true',
    };
    final query = Uri(queryParameters: params).query;
    return '${AppRoutes.mapa}?$query';
  }

  void _openMapForView(AnaliseSolo analise) {
    context.go(_mapRoute(analise));
  }

  Future<void> _openMapForSelection(AnaliseSolo analise) async {
    final result = await context.push<LatLng>(
      _mapRoute(analise, selectionMode: true),
    );
    if (result == null) return;

    await _saveEditedAnalise(
      _copyWithEditedCoordinates(
        analise,
        CoordinatePair(
          latitude: result.latitude,
          longitude: result.longitude,
        ),
      ),
    );
  }

  Future<void> _editField({
    required AnaliseSolo analise,
    required String fieldKey,
    required String label,
    required String currentValue,
    required bool isText,
  }) async {
    final controller = TextEditingController(text: currentValue);
    final newValue = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, bottomInset + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: isText
                    ? TextInputType.text
                    : const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Deixe vazio para marcar como não informado',
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () =>
                        Navigator.pop(context, controller.text.trim()),
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();

    if (newValue == null) return;

    final AnaliseSolo updated;
    if (fieldKey == 'latLong') {
      final coordinates = CoordinateFormatter.parseCombined(newValue);
      if (newValue.trim().isNotEmpty && coordinates == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informe Lat/Long no formato -10.510193, -48.315852'),
          ),
        );
        return;
      }
      updated = _copyWithEditedCoordinates(analise, coordinates);
    } else {
      updated = _copyWithEditedField(
        analise,
        fieldKey,
        isText ? newValue : _parseNullableDouble(newValue),
      );
    }

    await _saveEditedAnalise(updated);
  }

  Future<void> _saveEditedAnalise(AnaliseSolo updated) async {
    try {
      await ref
          .read(analiseNotifierProvider.notifier)
          .atualizarAnalise(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Análise atualizada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
  }

  AnaliseSolo _copyWithEditedCoordinates(
    AnaliseSolo original,
    CoordinatePair? coordinates,
  ) {
    return _copyWithEditedField(
      _copyWithEditedField(original, 'latitude', coordinates?.latitude),
      'longitude',
      coordinates?.longitude,
    );
  }

  double? _parseNullableDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  AnaliseSolo _copyWithEditedField(
    AnaliseSolo original,
    String fieldKey,
    Object? value,
  ) {
    double? number(String key, double? current) =>
        fieldKey == key ? value as double? : current;
    String text(String key, String current) =>
        fieldKey == key ? value as String : current;
    String? nullableText(String key, String? current) =>
        fieldKey == key ? (value as String).trim().nullIfEmpty : current;

    return AnaliseSolo(
      id: original.id,
      fazenda: original.fazenda,
      produtor: original.produtor,
      talhao: original.talhao,
      numeroAmostra: original.numeroAmostra,
      cultura: original.cultura,
      safra: original.safra,
      laboratorio: original.laboratorio,
      dataCadastro: original.dataCadastro,
      profundidade: text('profundidade', original.profundidade),
      latitude: number('latitude', original.latitude),
      longitude: number('longitude', original.longitude),
      descricaoLocal: nullableText('descricaoLocal', original.descricaoLocal),
      argila: number('argila', original.argila),
      silte: number('silte', original.silte),
      areiaTotal: number('areiaTotal', original.areiaTotal),
      phAgua: number('phAgua', original.phAgua),
      phSmp: number('phSmp', original.phSmp),
      phCaCl2: number('phCaCl2', original.phCaCl2),
      materiaOrganica: number('materiaOrganica', original.materiaOrganica),
      carbonoOrganico: number('carbonoOrganico', original.carbonoOrganico),
      pMehlich: number('pMehlich', original.pMehlich),
      pResina: number('pResina', original.pResina),
      pRem: number('pRem', original.pRem),
      s020: number('s020', original.s020),
      s2040: number('s2040', original.s2040),
      k: number('k', original.k),
      ca: number('ca', original.ca),
      mg: number('mg', original.mg),
      al: number('al', original.al),
      hMaisAl: number('hMaisAl', original.hMaisAl),
      na: number('na', original.na),
      b: number('b', original.b),
      cu: number('cu', original.cu),
      fe: number('fe', original.fe),
      mn: number('mn', original.mn),
      zn: number('zn', original.zn),
      ni: number('ni', original.ni),
      mo: number('mo', original.mo),
      se: number('se', original.se),
      co: original.co,
      cascalho: original.cascalho,
      areiaGrossa: original.areiaGrossa,
      areiaFina: original.areiaFina,
      municipio: original.municipio,
      responsavelTecnico: original.responsavelTecnico,
      cnpjCliente: original.cnpjCliente,
      pTotal: original.pTotal,
      classificacaoTextura: original.classificacaoTextura,
      tipoSoloMapa: original.tipoSoloMapa,
      solicitante: original.solicitante,
      convenio: original.convenio,
      creaResponsavel: original.creaResponsavel,
      cnpjLaboratorio: original.cnpjLaboratorio,
      dataInicioEnsaio: original.dataInicioEnsaio,
      dataFimEnsaio: original.dataFimEnsaio,
      matriculaImovel: original.matriculaImovel,
      codigoInterno: original.codigoInterno,
      codigoExternoAmostra: original.codigoExternoAmostra,
      caMaisMg: original.caMaisMg,
      kMgDm3: original.kMgDm3,
      cuMehlich: original.cuMehlich,
      feMehlich: original.feMehlich,
      mnMehlich: original.mnMehlich,
      znMehlich: original.znMehlich,
      cuDtpa: original.cuDtpa,
      feDtpa: original.feDtpa,
      mnDtpa: original.mnDtpa,
      znDtpa: original.znDtpa,
      dataRecebimento: original.dataRecebimento,
      numeroRelatorio: original.numeroRelatorio,
      codigoVerificacao: original.codigoVerificacao,
      codigoTalhao: original.codigoTalhao,
      totalAmostras: original.totalAmostras,
      pdfUrl: original.pdfUrl,
      laudoMetadata: original.laudoMetadata,
      h: original.h,
      ctcEfetiva: original.ctcEfetiva,
      ctc: original.ctc,
      sb: original.sb,
      vPercent: original.vPercent,
      mPercent: original.mPercent,
      osLaboratorio: original.osLaboratorio,
      dataEmissao: original.dataEmissao,
      consultor: original.consultor,
      labTemplateId: original.labTemplateId,
      unidadeNutrientes: original.unidadeNutrientes,
      unidadeMO: original.unidadeMO,
      unidadeTextura: original.unidadeTextura,
      clienteId: original.clienteId,
      fazendaId: original.fazendaId,
      talhaoId: original.talhaoId,
      vinculoStatus: original.vinculoStatus,
    );
  }
}

class _AnaliseDetailPalette {
  const _AnaliseDetailPalette({
    required this.valueText,
    required this.mutedText,
    required this.sectionText,
    required this.divider,
    required this.editIcon,
  });

  final Color valueText;
  final Color mutedText;
  final Color sectionText;
  final Color divider;
  final Color editIcon;

  factory _AnaliseDetailPalette.of(BuildContext context) {
    final theme = Theme.of(context);
    return _AnaliseDetailPalette(
      valueText: theme.colorScheme.onSurface,
      mutedText: theme.colorScheme.onSurfaceVariant,
      sectionText: theme.colorScheme.onSurface,
      divider: theme.dividerColor,
      editIcon: theme.colorScheme.primary,
    );
  }
}

extension on String {
  String? get nullIfEmpty {
    final trimmed = trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _HeaderInfoLine extends StatelessWidget {
  const _HeaderInfoLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? 'Não informado' : value.trim();

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        '$label: $displayValue',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
