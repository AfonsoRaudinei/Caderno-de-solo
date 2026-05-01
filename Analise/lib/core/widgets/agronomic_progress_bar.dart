import 'package:flutter/material.dart';

/// Barra de progresso agronômica com gradiente iOS por faixa de valor.
/// [value] deve estar entre 0 e 100 (percentual relativo à escala do nutriente).
class AgronomicProgressBar extends StatelessWidget {
  const AgronomicProgressBar({
    super.key,
    required this.value,
    this.height = 14.0,
  });

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 100.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: clamped),
      duration: const Duration(milliseconds: 400),
      builder: (context, val, _) {
        return Stack(
          children: [
            // Fundo
            Container(
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E7),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            // Preenchimento
            FractionallySizedBox(
              widthFactor: (val / 100).clamp(0.0, 1.0),
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  gradient: _gradient(val),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            // Valor em texto
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  '${val.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  LinearGradient _gradient(double v) {
    if (v <= 20) {
      return const LinearGradient(
        colors: [Color(0xFFFF3B30), Color(0xFFFF6B6B)],
      );
    } else if (v <= 40) {
      return const LinearGradient(
        colors: [Color(0xFFFF9500), Color(0xFFFFB340)],
      );
    } else if (v <= 60) {
      return const LinearGradient(
        colors: [Color(0xFFFFC107), Color(0xFFFFE082)],
      );
    } else if (v <= 80) {
      return const LinearGradient(
        colors: [Color(0xFF34C759), Color(0xFF6EE7A2)],
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF007AFF), Color(0xFF0051D5)],
      );
    }
  }
}
