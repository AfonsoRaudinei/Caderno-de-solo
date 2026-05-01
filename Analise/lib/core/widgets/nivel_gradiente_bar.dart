import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';

class NivelGradienteBar extends StatelessWidget {
  final double valor;
  final double min;
  final double max;
  final String rotulo;

  const NivelGradienteBar({
    super.key,
    required this.valor,
    required this.min,
    required this.max,
    required this.rotulo,
  });

  @override
  Widget build(BuildContext context) {
    final double range = max - min;
    final double clampedValor = valor < min ? min : (valor > max ? max : valor);
    final double fraction = range == 0 ? 0 : (clampedValor - min) / range;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            valor.toStringAsFixed(1),
            style: AppTextStyles.label,
          ),
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final double left = width * fraction;
            final double pointerLeft = left - 6;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF3B30),
                        Color(0xFFFF9500),
                        Color(0xFFFFCC00),
                        Color(0xFF34C759),
                        Color(0xFF007AFF),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: pointerLeft.clamp(0.0, width - 12.0),
                  top: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D1D1F),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        Align(
          alignment: FractionalOffset(fraction, 0),
          child: Text(
            rotulo,
            style: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }
}
