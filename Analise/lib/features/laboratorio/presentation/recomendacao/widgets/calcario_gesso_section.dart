import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/domain/entities/resultado_gesso.dart';
import 'package:soloforte/features/laboratorio/presentation/providers/recomendacao_provider_real.dart';

class RecomendacaoCalcarioGessoSection extends StatelessWidget {
  const RecomendacaoCalcarioGessoSection({super.key, required this.resultado});

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Column(
      children: [
        _buildCalcario(resultado, palette),
        _buildGesso(resultado, palette),
      ],
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
        Text(
          label,
          style: TextStyle(fontSize: 10, color: palette.textSecondary),
        ),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double value, [int decimals = 2]) {
    final text = value.toStringAsFixed(decimals);
    return text.replaceAll('.', ',');
  }

  Widget _buildCalcario(
    ResultadoRecomendacao resultado,
    AppThemePalette palette,
  ) {
    final calcarioData = buildCalcarioViewModel(resultado);
    final usarC2 = calcarioData.usarSegundoCalcario;
    final prop1 = calcarioData.prop1;
    final prop2 = calcarioData.prop2;
    final prnt1 = calcarioData.calcario1Prnt;
    final caO1 = calcarioData.calcario1CaO;
    final mgO1 = calcarioData.calcario1MgO;
    final prnt2 = calcarioData.calcario2Prnt;
    final caO2 = calcarioData.calcario2CaO;
    final mgO2 = calcarioData.calcario2MgO;
    final dose = calcarioData.dose;
    final temDose = calcarioData.temDose;
    final analise = calcarioData.analise;

    return AppCardSection(
      title: 'CALCÁRIO',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  temDose ? dose.toStringAsFixed(2) : '—',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: temDose ? AppColors.primary : palette.textSecondary,
                  ),
                ),
                if (temDose) ...[
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      't/ha',
                      style: TextStyle(
                        fontSize: 15,
                        color: palette.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: palette.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                    child: _miniBloco(
                        'V% Atual',
                        '${_fmt(analise.vPercent, 0)}%',
                        const Color(0xFFFF3B30),
                        palette)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Icon(Icons.arrow_forward_ios,
                      size: 12, color: palette.textTertiary),
                ),
                Expanded(
                    child: _miniBloco(
                        'V% Esperado',
                        '${_fmt(resultado.vEsperado, 0)}%',
                        const Color(0xFF34C759),
                        palette)),
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: palette.border),
          _infoRow('Ca',
              '${_fmt(analise.ca, 2)} → ${_fmt(resultado.caEsperado, 2)} cmolc/dm³'),
          _infoRow('Mg',
              '${_fmt(analise.mg, 2)} → ${_fmt(resultado.mgEsperado, 2)} cmolc/dm³'),
          _infoRow('Rel. Ca:Mg', '${_fmt(resultado.relacaoCaMg, 1)}:1'),
          Divider(height: 1, thickness: 0.5, color: palette.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Text(
              usarC2 ? 'Calcário 1 — ${prop1.toStringAsFixed(0)}%' : 'Calcário',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: palette.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Expanded(
                    child: _miniBloco('CaO', '${caO1.toStringAsFixed(0)}%',
                        const Color(0xFF007AFF), palette)),
                Expanded(
                    child: _miniBloco('MgO', '${mgO1.toStringAsFixed(0)}%',
                        const Color(0xFF34C759), palette)),
                Expanded(
                    child: _miniBloco('PRNT', '${prnt1.toStringAsFixed(0)}%',
                        palette.textSecondary, palette)),
              ],
            ),
          ),
          if (usarC2) ...[
            Divider(height: 1, thickness: 0.5, color: palette.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Text(
                'Calcário 2 — ${prop2.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: palette.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  Expanded(
                      child: _miniBloco('CaO', '${caO2.toStringAsFixed(0)}%',
                          const Color(0xFF007AFF), palette)),
                  Expanded(
                      child: _miniBloco('MgO', '${mgO2.toStringAsFixed(0)}%',
                          const Color(0xFF34C759), palette)),
                  Expanded(
                      child: _miniBloco('PRNT', '${prnt2.toStringAsFixed(0)}%',
                          palette.textSecondary, palette)),
                ],
              ),
            ),
          ],
          // Rodapé discreto — referência do método
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.science_outlined,
                    size: 11,
                    color: palette.textSecondary.withValues(alpha: 0.6)),
                const SizedBox(width: 4),
                Text(
                  resultado.metodoCalagem,
                  style: AppTextStyles.caption.copyWith(
                    color: palette.textSecondary.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (resultado.parcelamento.isNotEmpty) ...[
            Divider(height: 1, thickness: 0.5, color: palette.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Parcelamento',
                      style: TextStyle(
                          fontSize: 11, color: palette.textSecondary)),
                  const SizedBox(height: 4),
                  ...resultado.parcelamento.map(
                    (item) => Text('• $item', style: AppTextStyles.caption),
                  ),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildGesso(ResultadoRecomendacao resultado, AppThemePalette palette) {
    final g = resultado.gesso;

    return AppCardSection(
      title: 'GESSO AGRÍCOLA',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (g.indicado) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _fmt(g.doseKgHa, 0),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF007AFF),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('kg/ha',
                        style: TextStyle(
                            fontSize: 15, color: palette.textSecondary)),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 0.5, color: palette.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                      child: _miniBloco(
                          'S fornecido',
                          '${_fmt(g.sFornecidoKgHa, 1)} kg/ha',
                          const Color(0xFFFF9500),
                          palette)),
                  Expanded(
                      child: _miniBloco(
                          'Ca fornecido',
                          '${_fmt(g.caFornecidoKgHa, 1)} kg/ha',
                          const Color(0xFF007AFF),
                          palette)),
                  Expanded(
                      child: _miniBloco(
                          'Ca +cmolc',
                          '+${_fmt(g.caAumentoCmolcDm3, 2)}',
                          const Color(0xFF34C759),
                          palette)),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 8),
          // Rodapé discreto — referência do método
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.layers_outlined,
                    size: 11,
                    color: palette.textSecondary.withValues(alpha: 0.6)),
                const SizedBox(width: 4),
                Text(
                  g.metodo.nome,
                  style: AppTextStyles.caption.copyWith(
                    color: palette.textSecondary.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (g.observacoes.isNotEmpty) ...[
            Divider(height: 1, thickness: 0.5, color: palette.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: g.observacoes
                    .map((obs) => Text('• $obs', style: AppTextStyles.caption))
                    .toList(),
              ),
            ),
          ] else
            const SizedBox(height: 12),
        ],
      ),
    );
  }
}
