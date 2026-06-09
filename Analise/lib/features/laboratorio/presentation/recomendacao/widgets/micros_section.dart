import 'package:flutter/material.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';

class RecomendacaoMicrosUnificadosSection extends StatelessWidget {
  const RecomendacaoMicrosUnificadosSection({
    super.key,
    required this.resultado,
  });

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    if (resultado.micros.isEmpty) return const SizedBox.shrink();

    final referencia = resultado.micros
        .firstWhere((m) => m.referencia != null && m.referencia!.isNotEmpty,
            orElse: () => resultado.micros.first)
        .referencia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'MICRONUTRIENTES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF86868B),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (referencia != null && referencia.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Text(
                    referencia,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF86868B),
                    ),
                  ),
                ),
              ...resultado.micros.asMap().entries.map((entry) {
                final index = entry.key;
                final m = entry.value;
                final isLast = index == resultado.micros.length - 1;
                return _MicroNutrienteItem(
                  micro: m,
                  showDivider: !isLast,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _MicroNutrienteItem extends StatelessWidget {
  const _MicroNutrienteItem({
    required this.micro,
    required this.showDivider,
  });

  final MicroResultado micro;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final temSolo =
        (micro.via == 'Solo' || micro.via == 'Ambas') && micro.dose > 0;
    final temFoliar =
        (micro.via == 'Foliar' || micro.via == 'Ambas') && micro.dose > 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _corDoNutriente(micro.elemento),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    micro.elemento,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1D1D1F),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${micro.valorAtual.toStringAsFixed(2)} mg/dm³',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1D1D1F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _ClassificacaoBadge(deficiente: micro.deficiente),
              if (temSolo) ...[
                const SizedBox(height: 8),
                _DoseRow(
                  label: 'Aplicação no solo',
                  valor: micro.doseProdutoLabel,
                ),
              ],
              if (temFoliar) ...[
                const SizedBox(height: 6),
                _DoseRow(
                  label: 'Aplicação foliar',
                  valor: micro.doseProdutoLabel,
                ),
              ],
              if (micro.avisosNutriente.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...micro.avisosNutriente.map(
                  (aviso) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠️ ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(
                            aviso,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF9500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFFE5E5E7),
          ),
      ],
    );
  }

  Color _corDoNutriente(String elemento) {
    final cores = {
      'Se': const Color(0xFF34C759),
      'Ni': const Color(0xFF1D1D1F),
      'Co': const Color(0xFF8E8E93),
      'Mn': const Color(0xFFAF52DE),
      'B': const Color(0xFFFFCC00),
      'Cu': const Color(0xFFFF9500),
      'Zn': const Color(0xFF007AFF),
      'Mo': const Color(0xFF5856D6),
    };
    return cores[elemento] ?? const Color(0xFF8E8E93);
  }
}

class _ClassificacaoBadge extends StatelessWidget {
  const _ClassificacaoBadge({required this.deficiente});

  final bool deficiente;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: deficiente ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        deficiente ? 'Deficiente' : 'Adequado',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: deficiente ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
        ),
      ),
    );
  }
}

class _DoseRow extends StatelessWidget {
  const _DoseRow({
    required this.label,
    required this.valor,
  });

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF86868B),
            ),
          ),
        ),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1D1D1F),
          ),
        ),
      ],
    );
  }
}
