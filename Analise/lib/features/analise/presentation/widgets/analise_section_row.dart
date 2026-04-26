import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';

/// Linha de separação de seção na tabela de análise.
/// Fundo bgSecondary, texto em uppercase, 10px.
class AnaliseSectionRow extends StatelessWidget {
  final String title;
  final double stickyWidth;
  final double columnWidth;
  final int columnCount;
  final ScrollController scrollController;

  const AnaliseSectionRow({
    super.key,
    required this.title,
    required this.stickyWidth,
    required this.columnWidth,
    required this.columnCount,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: stickyWidth,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF86868B),
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Row(
                children: [
                  for (int i = 0; i < columnCount; i++)
                    SizedBox(
                      width: columnWidth,
                      height: 32, // Altura mínima consistente para a seção
                    ),
                  // Espaço para o botão de adicionar
                  const SizedBox(width: 44),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
