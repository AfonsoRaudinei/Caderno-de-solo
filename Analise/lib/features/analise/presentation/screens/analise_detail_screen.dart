import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
import 'package:soloforte/features/analise/presentation/widgets/map_preview_widget.dart';

class AnaliseDetailScreen extends ConsumerWidget {
  final String analiseId;

  const AnaliseDetailScreen({super.key, required this.analiseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analises = ref.watch(analiseNotifierProvider).valueOrNull ?? [];
    final analiseIndex = analises.indexWhere((a) => a.id == analiseId);
    
    if (analiseIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Análise não encontrada')),
        body: const Center(child: Text('A análise foi deletada ou não existe.')),
      );
    }
    
    final analise = analises[analiseIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(analise.nomeArea),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navegar para edição usando go_router
              context.push(
                '${AppRoutes.analise}/detalhe/${analise.id}/editar',
                extra: analise,
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
                  content: const Text('Tem certeza que deseja excluir esta análise?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(analiseNotifierProvider.notifier).deletar(analise.id);
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(analise.cultura.emoji, style: const TextStyle(fontSize: 24)),
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
                    Text('Produtor ID: ${analise.produtorId}'),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Navega para o Lab com dados pré-carregados')),
                    );
                  },
                ),
                _ActionButton(
                  icon: Icons.picture_as_pdf,
                  label: 'PDF',
                  color: Colors.red,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Baixando ou abrindo laudo anexado')),
                    );
                  },
                ),
                _ActionButton(
                  icon: Icons.map,
                  label: 'Mapa',
                  color: Colors.blue,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Abre SoloForte Mapas: soloforte-maps://analise/${analise.id}')),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Localização Preview
            if (analise.latitude != null && analise.longitude != null) ...[
              const Text('Localização', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              MapPreviewWidget(
                latitude: analise.latitude!,
                longitude: analise.longitude!,
                onOpenMap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abrindo aplicativo de mapa...')),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Dados Físicos
            const Text('Físico e Textura', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDataRow('Textura', analise.textura.name.toUpperCase()),
            _buildDataRow('Profundidade', analise.profundidade),
            const Divider(),

            // pH e Tampão
            const Text('pH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDataRow('pH Água', analise.phAgua?.toString() ?? '-'),
            _buildDataRow('pH SMP', analise.phSmp?.toString() ?? '-'),
            _buildDataRow('pH CaCl₂', analise.phCacl2?.toString() ?? '-'),
            const Divider(),

            // Macronutrientes
            const Text('Macronutrientes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDataRow('Fósforo (mg/dm³)', analise.fosforo?.toString() ?? '-'),
            _buildDataRow('Potássio (cmolc/dm³)', analise.potassio?.toString() ?? '-'),
            _buildDataRow('Cálcio (cmolc/dm³)', analise.calcio?.toString() ?? '-'),
            _buildDataRow('Magnésio (cmolc/dm³)', analise.magnesio?.toString() ?? '-'),
            _buildDataRow('Enxofre (mg/dm³)', analise.enxofre?.toString() ?? '-'),
            const Divider(),

            // Acidez e CTC
            const Text('Acidez', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDataRow('Alumínio (cmolc/dm³)', analise.aluminio?.toString() ?? '-'),
            _buildDataRow('H+Al (cmolc/dm³)', analise.hMaisAl?.toString() ?? '-'),
            const Divider(),
            
            const Text('Calculados Automáticos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDataRow('CTC', analise.ctc.toStringAsFixed(2)),
            _buildDataRow('V%', analise.vPorcento.toStringAsFixed(2)),
            const Divider(),

            // Micronutrientes
            const Text('Micronutrientes (mg/dm³)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDataRow('Boro', analise.boro?.toString() ?? '-'),
            _buildDataRow('Cobre', analise.cobre?.toString() ?? '-'),
            _buildDataRow('Ferro', analise.ferro?.toString() ?? '-'),
            _buildDataRow('Manganês', analise.manganes?.toString() ?? '-'),
            _buildDataRow('Zinco', analise.zinco?.toString() ?? '-'),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
