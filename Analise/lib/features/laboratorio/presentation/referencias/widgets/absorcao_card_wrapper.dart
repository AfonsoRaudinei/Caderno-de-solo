import 'package:flutter/material.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E5E7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080D2818),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }
}
