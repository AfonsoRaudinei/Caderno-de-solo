import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/usecases/calcular_derivados_analise.dart';
import 'package:soloforte/features/analise/presentation/formatters/analise_number_formatter.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
import 'package:soloforte/features/analise/presentation/widgets/analise_form_content.dart';
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
  final _formKey = GlobalKey<AnaliseFormContentState>();

  void _enterEditMode() => setState(() => _isEditing = true);

  void _exitEditMode() => setState(() => _isEditing = false);

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
          _exitEditMode();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(analise.talhao),
          actions: _isEditing
              ? [
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Cancelar',
                    onPressed: _exitEditMode,
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    tooltip: 'Salvar',
                    onPressed: () => _formKey.currentState?.salvar(),
                  ),
                ]
              : [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Editar',
                    onPressed: _enterEditMode,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Excluir',
                    onPressed: () => _confirmDelete(context, analise),
                  ),
                ],
        ),
        body: _isEditing
            ? AnaliseFormContent(
                key: _formKey,
                analiseInicial: analise,
                onSaveSuccess: _exitEditMode,
                showFab: false,
              )
            : _buildViewBody(context, analise),
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
          _buildDataRow('Latitude', _fmt(analise.latitude), palette),
          _buildDataRow('Longitude', _fmt(analise.longitude), palette),
          _buildDataRow('Descrição', analise.descricaoLocal ?? '-', palette),
          Divider(color: palette.divider),
          _buildSectionTitle('Composição Física', palette),
          const SizedBox(height: 8),
          _buildDataRow('Argila (g/kg)', _fmt(analise.argila), palette),
          _buildDataRow('Silte (g/kg)', _fmt(analise.silte), palette),
          _buildDataRow(
              'Areia Total (g/kg)', _fmt(analise.areiaTotal), palette),
          _buildDataRow('Profundidade', analise.profundidade, palette),
          Divider(color: palette.divider),
          _buildSectionTitle('pH', palette),
          const SizedBox(height: 8),
          _buildDataRow('pH Água', _fmt(analise.phAgua), palette),
          _buildDataRow('pH SMP', _fmt(analise.phSmp), palette),
          _buildDataRow('pH CaCl₂', _fmt(analise.phCaCl2), palette),
          Divider(color: palette.divider),
          _buildSectionTitle('Matéria Orgânica', palette),
          const SizedBox(height: 8),
          _buildDataRow(
              'M.O. (dag/kg)', _fmt(analise.materiaOrganica), palette),
          _buildDataRow(
              'C Orgânico (dag/kg)', _fmt(analise.carbonoOrganico), palette),
          Divider(color: palette.divider),
          _buildSectionTitle('Fósforo', palette),
          const SizedBox(height: 8),
          _buildDataRow('P Mehlich (mg/dm³)', _fmt(analise.pMehlich), palette),
          _buildDataRow('P Resina (mg/dm³)', _fmt(analise.pResina), palette),
          _buildDataRow('P-rem (mg/L)', _fmt(analise.pRem), palette),
          Divider(color: palette.divider),
          _buildSectionTitle('Enxofre', palette),
          const SizedBox(height: 8),
          _buildDataRow('S 0-20 (mg/dm³)', _fmt(analise.s020), palette),
          _buildDataRow('S 20-40 (mg/dm³)', _fmt(analise.s2040), palette),
          Divider(color: palette.divider),
          _buildSectionTitle('Macronutrientes', palette),
          const SizedBox(height: 8),
          _buildDataRow('Potássio (cmolc/dm³)', _fmt(analise.k), palette),
          _buildDataRow('Cálcio (cmolc/dm³)', _fmt(analise.ca), palette),
          _buildDataRow('Magnésio (cmolc/dm³)', _fmt(analise.mg), palette),
          _buildDataRow('Alumínio (cmolc/dm³)', _fmt(analise.al), palette),
          _buildDataRow('H+Al (cmolc/dm³)', _fmt(analise.hMaisAl), palette),
          _buildDataRow('Sódio (cmolc/dm³)', _fmt(analise.na), palette),
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
          _buildDataRow('Boro', _fmt(analise.b), palette),
          _buildDataRow('Cobre', _fmt(analise.cu), palette),
          _buildDataRow('Ferro', _fmt(analise.fe), palette),
          _buildDataRow('Manganês', _fmt(analise.mn), palette),
          _buildDataRow('Zinco', _fmt(analise.zn), palette),
          _buildDataRow('Níquel', _fmt(analise.ni), palette),
          _buildDataRow('Molibdênio', _fmt(analise.mo), palette),
          _buildDataRow('Selênio', _fmt(analise.se), palette),
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
    _AnaliseDetailPalette palette,
  ) {
    final isVazio =
        value == '-' || value.isEmpty || value == 'N/A' || value == 'null';
    return Padding(
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
        ],
      ),
    );
  }

  String _fmt(num? value) => AnaliseNumberFormatter.formatDecimal(value);
}

class _AnaliseDetailPalette {
  const _AnaliseDetailPalette({
    required this.valueText,
    required this.mutedText,
    required this.sectionText,
    required this.divider,
  });

  final Color valueText;
  final Color mutedText;
  final Color sectionText;
  final Color divider;

  factory _AnaliseDetailPalette.of(BuildContext context) {
    final theme = Theme.of(context);
    return _AnaliseDetailPalette(
      valueText: theme.colorScheme.onSurface,
      mutedText: theme.colorScheme.onSurfaceVariant,
      sectionText: theme.colorScheme.onSurface,
      divider: theme.dividerColor,
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
