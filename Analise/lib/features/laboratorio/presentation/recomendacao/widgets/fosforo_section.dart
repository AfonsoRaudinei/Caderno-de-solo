import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/nivel_gradiente_bar.dart';
import 'package:soloforte/domain/formulas/classificacao_nivel.dart';
import 'package:soloforte/features/laboratorio/presentation/providers/recomendacao_provider_real.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/widgets/recomendacao_badge.dart';

class RecomendacaoFosforoSection extends StatelessWidget {
  const RecomendacaoFosforoSection({super.key, required this.resultado});

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    return _buildFosforo(resultado);
  }

  Widget _miniBloco(String label, String valor, Color cor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF86868B))),
        const SizedBox(height: 2),
        Text(
          valor,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFosforo(ResultadoRecomendacao resultado) {
    final analise = resultado.analise;
    final p = analise.p;
    final argila = analise.argila;
    final nc = resultado.ncFosforo;
    final dose = resultado.doseP2O5KgHa;
    final temDose = dose > 0;
    final pRelNC = nc > 0 ? (p / nc * 100).clamp(0.0, 150.0) : 0.0;
    final acimaNc = p >= nc;
    final rotulo = ClassificacaoNivel.classificar(
      nutriente: 'p',
      valor: p,
      argila: argila,
    );

    Color corP(double pVal, double ncVal) {
      final rel = ncVal > 0 ? (pVal / ncVal * 100) : 0.0;
      if (rel < 40) return const Color(0xFFFF3B30);
      if (rel < 70) return const Color(0xFFFF9500);
      if (rel < 100) return const Color(0xFFFFCC00);
      return const Color(0xFF34C759);
    }

    final corPrincipal = corP(p, nc);

    return AppCardSection(
      title: 'FÓSFORO',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'P Mehlich',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF86868B),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  p.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: corPrincipal,
                  ),
                ),
                const SizedBox(width: 6),
                const Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text('mg/dm³',
                      style: TextStyle(fontSize: 13, color: Color(0xFF86868B))),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: corPrincipal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: corPrincipal.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    rotulo,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: corPrincipal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: NivelGradienteBar(
              valor: p,
              min: NivelEscala.escala('p', argila: argila).$1,
              max: NivelEscala.escala('p', argila: argila).$2,
              rotulo: rotulo,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Row(
              children: [
                Text(
                  'NC: ${nc.toStringAsFixed(2)} mg/dm³',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF86868B)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: acimaNc
                        ? const Color(0xFF34C759).withValues(alpha: 0.12)
                        : const Color(0xFFFF9500).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${pRelNC.toStringAsFixed(0)}% do NC',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: acimaNc ? const Color(0xFF34C759) : const Color(0xFFFF9500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
            child: Text(
              resultado.modoFosforo,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecond.withValues(alpha: 0.6),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  temDose ? dose.toStringAsFixed(1) : '—',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: temDose ? AppColors.fosforo : const Color(0xFF86868B),
                  ),
                ),
                if (temDose) ...[
                  const SizedBox(width: 6),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text('kg P₂O₅/ha',
                        style: TextStyle(fontSize: 13, color: Color(0xFF86868B))),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: _miniBloco(
                    'P Solo',
                    '${p.toStringAsFixed(1)} mg',
                    corPrincipal,
                  ),
                ),
                Expanded(
                  child: _miniBloco(
                    'P NC',
                    '${nc.toStringAsFixed(1)} mg',
                    const Color(0xFF86868B),
                  ),
                ),
                Expanded(
                  child: _miniBloco(
                    'Absorção',
                    resultado.doseAbsorcaoP != null
                        ? '${resultado.doseAbsorcaoP!.toStringAsFixed(1)} kg'
                        : '—',
                    resultado.doseAbsorcaoP != null
                        ? const Color(0xFF007AFF)
                        : const Color(0xFFC7C7CC),
                  ),
                ),
              ],
            ),
          ),
          if (resultado.legacyP) ...[
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: RecomendacaoBadge(
                icon: Icons.info_outline,
                color: AppColors.warning,
                label: 'Solo acima do NC — dose mínima de manutenção aplicada.',
              ),
            ),
          ] else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}


