import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/usecases/calcular_derivados_analise.dart';
import 'package:soloforte/features/analise/presentation/formatters/analise_number_formatter.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
import 'package:soloforte/features/analise/presentation/widgets/map_preview_widget.dart';

class AnaliseDetailScreen extends ConsumerStatefulWidget {
  final String analiseId;
  static const _calc = CalcularDerivadosAnalise();

  const AnaliseDetailScreen({super.key, required this.analiseId});

  @override
  ConsumerState<AnaliseDetailScreen> createState() =>
      _AnaliseDetailScreenState();
}

class _AnaliseDetailScreenState extends ConsumerState<AnaliseDetailScreen> {
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
          Card(
            elevation: 0,
            color: analise.cultura.color.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        analise.cultura.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        analise.cultura.label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: analise.cultura.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Produtor: ${analise.produtor}',
                    style: TextStyle(color: palette.mutedText),
                  ),
                  Text(
                    'Fazenda: ${analise.fazenda}',
                    style: TextStyle(color: palette.mutedText),
                  ),
                  Text(
                    'Nº Amostra: ${analise.numeroAmostra}',
                    style: TextStyle(color: palette.mutedText),
                  ),
                  Text(
                    'Safra: ${analise.safra}',
                    style: TextStyle(color: palette.mutedText),
                  ),
                  Text(
                    'Laboratório: ${analise.laboratorio}',
                    style: TextStyle(color: palette.mutedText),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionButton(
                icon: Icons.science,
                label: 'Recomendar',
                color: Colors.green,
                onTap: () {
                  context.go(
                    AppRoutes.labRecomendacao,
                    extra: analise.id,
                  );
                },
              ),
              _ActionButton(
                icon: Icons.picture_as_pdf,
                label: 'PDF',
                color: Colors.red,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Baixando ou abrindo laudo anexado'),
                    ),
                  );
                },
              ),
              _ActionButton(
                icon: Icons.map,
                label: 'Mapa',
                color: Colors.blue,
                onTap: () {
                  context.go(
                    '${AppRoutes.mapa}?analiseId=${Uri.encodeComponent(analise.id)}',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (analise.latitude != null && analise.longitude != null) ...[
            _buildSectionTitle('Localização', palette),
            const SizedBox(height: 8),
            MapPreviewWidget(
              latitude: analise.latitude!,
              longitude: analise.longitude!,
              onOpenMap: () {
                context.go(
                  '${AppRoutes.mapa}?analiseId=${Uri.encodeComponent(analise.id)}',
                );
              },
            ),
            const SizedBox(height: 16),
          ],
          _buildSectionTitle('Localização', palette),
          const SizedBox(height: 8),
          _buildDataRow('Latitude', _fmt(analise.latitude), palette,
              fieldKey: 'latitude', analise: analise),
          _buildDataRow('Longitude', _fmt(analise.longitude), palette,
              fieldKey: 'longitude', analise: analise),
          _buildDataRow('Descrição', analise.descricaoLocal ?? '-', palette,
              fieldKey: 'descricaoLocal', analise: analise, isText: true),
          Divider(color: palette.divider),
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
          _buildDataRow('SB (cmolc/dm³)', _fmt(derivados['sb']), palette),
          _buildDataRow(
              'CTC(T) (cmolc/dm³)', _fmt(derivados['ctcTotal']), palette),
          _buildDataRow(
              'CTC(e) (cmolc/dm³)', _fmt(derivados['ctcEfetiva']), palette),
          _buildDataRow('V% (%)', _fmt(derivados['vPct']), palette),
          _buildDataRow('m% (%)', _fmt(derivados['mPct']), palette),
          Divider(color: palette.divider),
          _buildSectionTitle('Saturação das Bases', palette),
          const SizedBox(height: 8),
          _buildDataRow('Ca/T (%)', _fmt(derivados['caPctT']), palette),
          _buildDataRow('Mg/T (%)', _fmt(derivados['mgPctT']), palette),
          _buildDataRow('K/T (%)', _fmt(derivados['kPctT']), palette),
          _buildDataRow('H+Al/T (%)', _fmt(derivados['hAlPctT']), palette),
          Divider(color: palette.divider),
          _buildSectionTitle('Relações entre Bases', palette),
          const SizedBox(height: 8),
          _buildDataRow('Ca/Mg', _fmt(derivados['relCaMg']), palette),
          _buildDataRow('Ca/K', _fmt(derivados['relCaK']), palette),
          _buildDataRow('Mg/K', _fmt(derivados['relMgK']), palette),
          _buildDataRow('(Ca+Mg)/T (%)', _fmt(derivados['relCaMgT']), palette),
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
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: palette.sectionText,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: palette.mutedText),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            isVazio ? 'Não informado' : value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isVazio ? Colors.orange : palette.valueText,
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
      borderRadius: BorderRadius.circular(8),
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

  String _fmt(num? value) => AnaliseNumberFormatter.formatDecimal(value);

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

    final updated = _copyWithEditedField(
      analise,
      fieldKey,
      isText ? newValue : _parseNullableDouble(newValue),
    );

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
