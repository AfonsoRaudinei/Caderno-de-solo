import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/nivel_gradiente_bar.dart';
import 'package:soloforte/domain/formulas/classificacao_nivel.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/widgets/recomendacao_badge.dart';

class RecomendacaoPotassioSection extends StatelessWidget {
  const RecomendacaoPotassioSection({super.key, required this.resultado});

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    return _buildPotassio(resultado, context.appPalette);
  }

  Widget _buildPotassio(
    ResultadoRecomendacao resultado,
    AppThemePalette palette,
  ) {
    final analise = resultado.analise;
    final k = analise.k;
    final kMg = k * 391.0;
    final nc = resultado.ncPotassio;
    final ncMg = nc * 391.0;
    final dose = resultado.doseK2OKgHa;
    final temDose = dose > 0;
    final rotulo = ClassificacaoNivel.classificar(nutriente: 'k', valor: k);
    final kPct = resultado.relacoesK.kNaCTC;

    Color corKPct() {
      if (kPct < 2) return const Color(0xFFFF3B30);
      if (kPct < 4) return const Color(0xFFFF9500);
      if (kPct < 6) return const Color(0xFF34C759);
      return const Color(0xFF007AFF);
    }

    return AppCardSection(
      title: 'POTÁSSIO',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      k.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.potassio,
                      ),
                    ),
                    Text(
                      'cmolc/dm³',
                      style:
                          TextStyle(fontSize: 11, color: palette.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kMg.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                    Text(
                      'mg/dm³',
                      style:
                          TextStyle(fontSize: 11, color: palette.textSecondary),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.potassio.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.potassio.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    rotulo,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.potassio,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: NivelGradienteBar(
              valor: k,
              min: NivelEscala.escala('k').$1,
              max: NivelEscala.escala('k').$2,
              rotulo: rotulo,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Text(
              'NC: ${nc.toStringAsFixed(2)} cmolc/dm³  ·  ${ncMg.toStringAsFixed(0)} mg/dm³',
              style: TextStyle(fontSize: 11, color: palette.textSecondary),
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: palette.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  temDose ? dose.toStringAsFixed(1) : '—',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: temDose ? AppColors.potassio : palette.textSecondary,
                  ),
                ),
                if (temDose) ...[
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('kg K₂O/ha',
                        style: TextStyle(
                            fontSize: 13, color: palette.textSecondary)),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              resultado.criterioPotassio,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11,
                color: palette.textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: palette.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: _miniBloco(
                    'K% CTC',
                    '${kPct.toStringAsFixed(1)}%',
                    corKPct(),
                    palette,
                  ),
                ),
                Expanded(
                  child: _miniBloco(
                    'K:Mg',
                    resultado.relacoesK.relKMg.toStringAsFixed(2),
                    palette.textSecondary,
                    palette,
                  ),
                ),
                Expanded(
                  child: _miniBloco(
                    'K:Ca',
                    resultado.relacoesK.relKCa.toStringAsFixed(2),
                    palette.textSecondary,
                    palette,
                  ),
                ),
              ],
            ),
          ),
          if (resultado.relacoesK.alertas.isNotEmpty) ...[
            Divider(height: 1, thickness: 0.5, color: palette.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: resultado.relacoesK.alertas
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: RecomendacaoBadge(
                          icon: Icons.warning_amber_rounded,
                          color: AppColors.warning,
                          label: item,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ] else
            const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _miniBloco(
    String label,
    String valor,
    Color cor,
    AppThemePalette palette,
  ) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 10, color: palette.textSecondary)),
        const SizedBox(height: 2),
        Text(
          valor,
          style:
              TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
