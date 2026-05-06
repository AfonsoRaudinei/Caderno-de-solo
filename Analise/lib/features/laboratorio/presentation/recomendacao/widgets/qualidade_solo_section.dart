import 'package:flutter/material.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/agronomic_progress_bar.dart';
import 'package:soloforte/core/widgets/nutrient_ph_bar_chart.dart';
import 'package:soloforte/domain/formulas/classificacao_nivel.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';

class RecomendacaoQualidadeSoloSection extends StatelessWidget {
  const RecomendacaoQualidadeSoloSection({super.key, required this.resultado});

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    final analise = resultado.analise;

    return AppCardSection(
      title: 'QUALIDADE DO SOLO',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gráfico pH ──────────────────────────────────────────
          NutrientPhBarChart(ph: analise.ph),

          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),

          // ── Argila + Classe Textural ────────────────────────────────────
          _buildArgilaCard(
            analise.argila.toDouble(),
            silte: analise.silte,
            areiaTotal: analise.areiaTotal,
          ),

          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),

          // ── Matéria Orgânica ─────────────────────────────────────
          _buildMOCard(analise.mo),

          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),

          // ── Enxofre ──────────────────────────────────────────────
          _buildEnxofreCard(analise.s, s2040: analise.s2040),
        ],
      ),
    );
  }

  Widget _buildEnxofreCard(double s, {double? s2040}) {
    double doseKgHa() {
      if (s < 10) return 20.0;
      if (s < 20) return 10.0;
      return 0.0;
    }

    final dose = doseKgHa();
    final temDose = dose > 0;
    final rotulo020 = ClassificacaoNivel.classificar(nutriente: 's', valor: s);
    final barPct020 = (s / 30.0 * 100).clamp(0.0, 100.0);

    Color corDose() {
      if (!temDose) return const Color(0xFF34C759);
      if (dose >= 20) return const Color(0xFFFF3B30);
      return const Color(0xFFFF9500);
    }

    Widget buildCamada({
      required String profundidade,
      required double valor,
      required double barPct,
      required String rotuloCamada,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Text(
                  'S · $profundidade',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF86868B)),
                ),
                const Spacer(),
                Text(
                  '${valor.toStringAsFixed(1)} mg/dm³',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: AgronomicProgressBar(value: barPct),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Text(
              rotuloCamada,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                temDose ? dose.toStringAsFixed(0) : '✓',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: corDose(),
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  temDose ? 'kg S/ha' : 'Sem necessidade',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF86868B)),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: corDose().withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: corDose().withValues(alpha: 0.3), width: 0.5),
                ),
                child: Text(
                  rotulo020,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: corDose(),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),

        buildCamada(
          profundidade: '0–20 cm',
          valor: s,
          barPct: barPct020,
          rotuloCamada: rotulo020,
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 1, color: Color(0xFFE5E5E7)),
        ),

        if (s2040 != null)
          buildCamada(
            profundidade: '20–40 cm',
            valor: s2040,
            barPct: (s2040 / 30.0 * 100).clamp(0.0, 100.0),
            rotuloCamada:
                ClassificacaoNivel.classificar(nutriente: 's', valor: s2040),
          )
        else
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              '⚠️ Camada 20–40 cm não disponível nesta análise',
              style: TextStyle(fontSize: 11, color: Color(0xFFC7C7CC)),
            ),
          ),

        if (temDose) ...[
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              s < 10
                  ? 'Nível muito baixo — aplicar enxofre elementar ou sulfato.'
                  : 'Nível baixo — complementar com fonte sulfatada.',
              style: const TextStyle(fontSize: 11, color: Color(0xFF86868B)),
            ),
          ),
        ] else
          const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildArgilaCard(double argila, {double? silte, double? areiaTotal}) {
    final argilaPct = argila / 10.0;
    final siltePct = silte != null ? silte / 10.0 : null;
    final areiaPct = areiaTotal != null ? areiaTotal / 10.0 : null;
    final areiaPctFinal = areiaPct ??
        (siltePct != null ? (100.0 - argilaPct - siltePct).clamp(0.0, 100.0) : null);

    String classeTextural;
    if (argilaPct < 15) {
      classeTextural = 'Arenosa';
    } else if (argilaPct < 35) {
      classeTextural = 'Franco-Arenosa';
    } else if (argilaPct < 60) {
      classeTextural = 'Franco-Argilosa';
    } else {
      classeTextural = 'Argilosa';
    }

    final barPercent = argilaPct.clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              const Text(
                'Argila',
                style: TextStyle(fontSize: 14, color: Color(0xFF86868B)),
              ),
              const Spacer(),
              Text(
                '${argilaPct.toStringAsFixed(1)} %  ·  ${argila.toStringAsFixed(0)} g/kg',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: AgronomicProgressBar(value: barPercent),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            classeTextural,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D1D1F),
            ),
          ),
        ),
        if (siltePct != null || areiaPctFinal != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                if (areiaPctFinal != null)
                  _texturaPill('Areia', areiaPctFinal, const Color(0xFFF5A623)),
                if (areiaPctFinal != null && siltePct != null)
                  const SizedBox(width: 8),
                if (siltePct != null)
                  _texturaPill('Silte', siltePct, const Color(0xFF5AC8FA)),
                const SizedBox(width: 8),
                _texturaPill('Argila', argilaPct, const Color(0xFF34C759)),
              ],
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              '· Areia e Silte não disponíveis nesta análise',
              style: TextStyle(fontSize: 11, color: Color(0xFFC7C7CC)),
            ),
          ),
      ],
    );
  }

  Widget _texturaPill(String label, double pct, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        '$label ${pct.toStringAsFixed(1)}%',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: cor.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildMOCard(double mo) {
    final carbono = mo / 1.724;
    final nitrogenio = mo * 1.0;
    final barPercent = (mo / 50.0 * 100).clamp(0.0, 100.0);
    final rotulo = ClassificacaoNivel.classificar(nutriente: 'mo', valor: mo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              const Text(
                'Matéria Orgânica',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF86868B),
                ),
              ),
              const Spacer(),
              Text(
                '${mo.toStringAsFixed(1)} g/dm³',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: AgronomicProgressBar(value: barPercent),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Text(
            rotulo,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF86868B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E5E7), width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Carbono (C)',
                      style: TextStyle(fontSize: 13, color: Color(0xFF1D1D1F)),
                    ),
                    const Spacer(),
                    Text(
                      '${carbono.toStringAsFixed(2)} %',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      'N estimado (Fancelli)',
                      style: TextStyle(fontSize: 13, color: Color(0xFF1D1D1F)),
                    ),
                    const Spacer(),
                    Text(
                      '${nitrogenio.toStringAsFixed(2)} t/ha',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
