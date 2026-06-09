import re

path = 'lib/features/laboratorio/presentation/recomendacao/widgets/micros_section.dart'
try:
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()

    match_start = text.find('class RecomendacaoMicrosSoloSection')
    if match_start != -1:
        text = text[:match_start]

    new_ui = r'''
class RecomendacaoMicrosUnificadosSection extends StatelessWidget {
  const RecomendacaoMicrosUnificadosSection({super.key, required this.resultado});

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    if (resultado.micros.isEmpty) return const SizedBox.shrink();

    final microSolo = resultado.micros.where((m) => m.via.contains('Solo')).toList();
    final microFoliar = resultado.micros.where((m) => m.via.contains('Foliar')).toList();

    if (microSolo.isEmpty && microFoliar.isEmpty) return const SizedBox.shrink();

    return AppCardSection(
      title: 'MICRONUTRIENTES',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (microSolo.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'APLICAÇÃO NO SOLO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF007AFF),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...microSolo.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              return Column(
                children: [
                  if (i > 0) const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
                  _MicroItemRow(m),
                ],
              );
            }),
          ],
          if (microSolo.isNotEmpty && microFoliar.isNotEmpty)
            const Divider(height: 16, thickness: 0.5, color: Color(0xFFE5E5E7)),
          if (microFoliar.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'APLICAÇÃO FOLIAR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF34C759),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...microFoliar.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              return Column(
                children: [
                  if (i > 0) const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
                  _MicroItemRow(m),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _MicroItemRow extends StatelessWidget {
  const _MicroItemRow(this.m);

  final MicroResultado m;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                m.elemento,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1D1D1F)),
              ),
              const Spacer(),
              Text(
                '${m.valorAtual.toStringAsFixed(2)} mg/dm³',
                style: const TextStyle(fontSize: 12, color: Color(0xFF86868B)),
              ),
            ],
          ),
          if (m.doseProdutoLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Produto: ${m.doseProdutoLabel}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF86868B)),
            ),
          ],
          if (m.avisosNutriente.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...m.avisosNutriente.map((aviso) => Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFCC00).withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFFF9500)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          aviso,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF995C00), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
'''
    text = text + new_ui

    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)
    print("Done")
except Exception as e:
    print(e)
