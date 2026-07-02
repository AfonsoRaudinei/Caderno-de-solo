import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';

/// Container padrão da tela de absorção de nutrientes.
/// Extraído de absorcao_nutrientes_referencia_page.dart (_buildCard) — FASE 3.
class AbsorcaoCardWrapper extends StatelessWidget {
  const AbsorcaoCardWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }
}
