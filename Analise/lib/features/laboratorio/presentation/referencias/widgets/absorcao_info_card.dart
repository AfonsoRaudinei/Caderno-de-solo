import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/absorcao_nutrientes_data.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/absorcao_nutrientes_models.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/widgets/absorcao_card_wrapper.dart';

/// Card informativo da tela de absorção de nutrientes.
/// Extraído de absorcao_nutrientes_referencia_page.dart (_buildInfoCard) — FASE 3.
class AbsorcaoInfoCard extends StatelessWidget {
  const AbsorcaoInfoCard({
    super.key,
    required this.unit,
    required this.quality,
    required this.modeText,
    required this.isAccumulated,
  });

  final String unit;
  final DataQuality quality;
  final String modeText;
  final bool isAccumulated;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final items = <String>[
      quality.subtitle,
      isAccumulated
          ? 'Modo acumulado: mostra o total absorvido desde V1-V3 até cada estádio.'
          : 'Modo por estádio: mostra somente a absorção específica de cada estádio.',
      'Unidade exibida: $unit (ajustada automaticamente para leitura prática).',
      'Uso recomendado: referência para tomada de decisão em recomendações.',
    ];

    return AbsorcaoCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leitura da análise',
            style: AppTextStyles.headline.copyWith(
              fontSize: 18,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AbsorcaoNutrientesCores.greenAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        color: palette.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Visualização atual: $modeText',
            style: AppTextStyles.caption.copyWith(
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
