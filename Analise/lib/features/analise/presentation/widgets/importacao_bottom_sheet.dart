import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';

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
    final palette = context.appPalette;
    final onAccent = Theme.of(context).colorScheme.onPrimary;

    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                  color: palette.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Título ───────────────────────────────────────────────────
            Text(
              _titulo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // ── Descrição ────────────────────────────────────────────────
            Text(
              _descricao,
              style: TextStyle(
                fontSize: 14,
                color: palette.textSecondary,
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
                  backgroundColor: palette.accent,
                  foregroundColor: onAccent,
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
                  backgroundColor: palette.surfaceAlt,
                  foregroundColor: palette.textPrimary,
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
