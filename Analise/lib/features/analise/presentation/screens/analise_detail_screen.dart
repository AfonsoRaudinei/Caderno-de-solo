import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/usecases/calcular_derivados_analise.dart';
import 'package:soloforte/features/analise/presentation/formatters/analise_number_formatter.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
import 'package:soloforte/features/analise/presentation/widgets/map_preview_widget.dart';

class AnaliseDetailScreen extends ConsumerWidget {
  final String analiseId;
  static const _calc = CalcularDerivadosAnalise();

  const AnaliseDetailScreen({super.key, required this.analiseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analises = ref.watch(analiseNotifierProvider).valueOrNull ?? [];
    final analiseIndex = analises.indexWhere((a) => a.id == analiseId);

    if (analiseIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Análise não encontrada')),
        body:
            const Center(child: Text('A análise foi deletada ou não existe.')),
      );
    }

    final analise = analises[analiseIndex];

    final derivados = _calc.call({
      'ca': analise.ca,
      'mg': analise.mg,
      'k': analise.k,
      'na': analise.na,
      'al': analise.al,
      'hMaisAl': analise.hMaisAl,
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(analise.talhao),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navegar para edição usando go_router
              context.push(
                '${AppRoutes.analise}/detalhe/${analise.id}/editar',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Excluir'),
                  content: const Text(
                      'Tem certeza que deseja excluir esta análise?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Excluir')),
                  ],
                ),
              );
              if (confirm == true) {
                await ref
                    .read(analiseNotifierProvider.notifier)
                    .deletar(analise.id);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho
            Card(
              elevation: 0,
              color: analise.cultura.color.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(analise.cultura.emoji,
                            style: const TextStyle(fontSize: 24)),
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
                    Text('Produtor: ${analise.produtor}'),
                    Text('Safra: ${analise.safra}'),
                    Text('Laboratório: ${analise.laboratorio}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Ações
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.science,
                  label: 'Recomendar',
                  color: Colors.green,
                  onTap: () {
                    context.push(
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
                          content: Text('Baixando ou abrindo laudo anexado')),
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

            // Localização Preview
            if (analise.latitude != null && analise.longitude != null) ...[
              const Text('Localização',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 24),
            ],

            // Dados Físicos
            const Text('Composição Física',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDataRow('Argila (g/kg)', _fmt(analise.argila)),
            _buildDataRow('Silte (g/kg)', _fmt(analise.silte)),
            _buildDataRow('Areia Total (g/kg)', _fmt(analise.areiaTotal)),
            _buildDataRow('Profundidade', analise.profundidade),
            const Divider(),

            // pH e Tampão
            const Text('pH',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDataRow('pH Água', _fmt(analise.phAgua)),
            _buildDataRow('pH SMP', _fmt(analise.phSmp)),
            _buildDataRow('pH CaCl₂', _fmt(analise.phCaCl2)),
            const Divider(),

            // Macronutrientes
            const Text('Macronutrientes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDataRow(
                analise.pResina != null && analise.pMehlich == null
                    ? 'P Resina (mg/dm³)'
                    : 'P Mehlich (mg/dm³)',
                _fmt(analise.pResina ?? analise.pMehlich)),
            _buildDataRow('Potássio (cmolc/dm³)', _fmt(analise.k)),
            _buildDataRow('Cálcio (cmolc/dm³)', _fmt(analise.ca)),
            _buildDataRow('Magnésio (cmolc/dm³)', _fmt(analise.mg)),
            _buildDataRow('S 0-20 (mg/dm³)', _fmt(analise.s020)),
            const Divider(),

            // Acidez e CTC
            const Text('Acidez',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDataRow('Alumínio (cmolc/dm³)', _fmt(analise.al)),
            _buildDataRow('H+Al (cmolc/dm³)', _fmt(analise.hMaisAl)),
            const Divider(),

            const Text('Calculados Automáticos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDataRow('CTC T', _fmt(derivados['ctcTotal'])),
            _buildDataRow('V%', _fmt(derivados['vPct'])),
            const Divider(),

            // Micronutrientes
            const Text('Micronutrientes (mg/dm³)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDataRow('Boro', _fmt(analise.b)),
            _buildDataRow('Cobre', _fmt(analise.cu)),
            _buildDataRow('Ferro', _fmt(analise.fe)),
            _buildDataRow('Manganês', _fmt(analise.mn)),
            _buildDataRow('Zinco', _fmt(analise.zn)),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    final isVazio =
        value == '-' || value.isEmpty || value == 'N/A' || value == 'null';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            isVazio ? 'Não informado' : value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isVazio ? Colors.orange : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(num? value) => AnaliseNumberFormatter.formatDecimal(value);
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
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
