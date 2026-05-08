import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';

enum ImportacaoBottomSheetTipo {
  labNaoReconhecido,
  extracacaoIndisponivel,
  qualidadeInsuficiente,
}

/// BottomSheet de erro para o fluxo de importação de PDF.
///
/// Dois estados visuais via [tipo]:
/// - [ImportacaoBottomSheetTipo.labNaoReconhecido]: PDF não corresponde a nenhum lab.
/// - [ImportacaoBottomSheetTipo.extracacaoIndisponivel]: sem package de PDF disponível.
class ImportacaoBottomSheet extends StatelessWidget {
  final ImportacaoBottomSheetTipo tipo;
  final VoidCallback onDigitarManualmente;
  final String? detalhe;

  const ImportacaoBottomSheet({
    super.key,
    required this.tipo,
    required this.onDigitarManualmente,
    this.detalhe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drag handle ─────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Título ───────────────────────────────────────────────────
            Text(
              _titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1D1D1F),
              ),
            ),
            const SizedBox(height: 12),

            // ── Descrição ────────────────────────────────────────────────
            Text(
              _descricao,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF86868B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // ── Botão primário ───────────────────────────────────────────
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: onDigitarManualmente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Digitar manualmente',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Botão secundário ─────────────────────────────────────────
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bgSecondary,
                  foregroundColor: const Color(0xFF1D1D1F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _titulo {
    switch (tipo) {
      case ImportacaoBottomSheetTipo.labNaoReconhecido:
        return 'Laboratório não reconhecido';
      case ImportacaoBottomSheetTipo.extracacaoIndisponivel:
        return 'Importação automática\nindisponível';
      case ImportacaoBottomSheetTipo.qualidadeInsuficiente:
        return 'Importação bloqueada';
    }
  }

  String get _descricao {
    switch (tipo) {
      case ImportacaoBottomSheetTipo.labNaoReconhecido:
        return 'Este PDF não corresponde a nenhum laboratório cadastrado.\n'
            'Insira os dados manualmente.';
      case ImportacaoBottomSheetTipo.extracacaoIndisponivel:
        return 'A leitura automática de PDF não está disponível no momento.\n'
            'Insira os dados manualmente ou tente novamente mais tarde.';
      case ImportacaoBottomSheetTipo.qualidadeInsuficiente:
        final detalheNormalizado = detalhe?.trim();
        if (detalheNormalizado != null && detalheNormalizado.isNotEmpty) {
          return 'O PDF foi reconhecido, mas os campos essenciais vieram incompletos.\n'
              '$detalheNormalizado';
        }
        return 'O PDF foi reconhecido, mas os campos essenciais vieram incompletos.\n'
            'Revise o laudo ou insira os dados manualmente.';
    }
  }
}
