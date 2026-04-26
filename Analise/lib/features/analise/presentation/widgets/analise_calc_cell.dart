import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';

/// Célula calculada (read-only) na tabela de análise.
/// Fundo bgSecondary, não editável, atualiza em tempo real.
class AnaliseCalcCell extends StatelessWidget {
  final double width;
  final double? height;
  final double? value;
  final int decimals;

  const AnaliseCalcCell({
    super.key,
    required this.width,
    this.height,
    this.value,
    this.decimals = 2,
  });

  @override
  Widget build(BuildContext context) {
    final text = value != null ? value!.toStringAsFixed(decimals) : '—';
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          left: BorderSide(color: AppColors.border, width: 0.5),
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF86868B),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
