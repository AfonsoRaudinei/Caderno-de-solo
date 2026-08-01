import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/data/lab_templates/pdf_import_service.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';
import 'package:soloforte/features/analise/application/providers/analise_persistence_gateway.dart';
import 'package:soloforte/features/analise/presentation/flows/vincular_hierarquia_salvar_flow.dart';
import 'package:soloforte/features/analise/presentation/widgets/importacao_bottom_sheet.dart';
import 'package:soloforte/features/analise/presentation/widgets/importacao_confianca_sheet.dart';

/// Fluxo reutilizável de importação de PDF + persistência atômica.
class ImportarAnalisePdfFlow {
  ImportarAnalisePdfFlow._();

  static Future<void> executar(
    BuildContext context,
    WidgetRef ref, {
    bool popOnSuccess = false,
  }) async {
    try {
      final analises = await PdfImportService().importarDePdf();
      if (analises == null) return;
      if (!context.mounted) return;

      await _processarImportacao(
        context,
        ref,
        analises,
        popOnSuccess: popOnSuccess,
      );
    } on LabConfiancaBaixaException catch (e) {
      if (!context.mounted) return;
      final selectedLabId = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => ImportacaoConfiancaSheet(
          ranking: e.ranking,
          suggestedLabId: e.suggestedLabId,
          confidence: e.confidence,
          sampleHints: e.sampleHints,
          onConfirm: (labId) => Navigator.of(context).pop(labId),
        ),
      );

      if (selectedLabId == null || !context.mounted) return;

      final analises = await PdfImportService().importarArquivoPdf(
        fileBytes: e.fileBytes,
        fileName: e.fileName,
        forcedLabId: selectedLabId,
        operationId: e.operationId,
      );

      if (!context.mounted) return;
      await _processarImportacao(
        context,
        ref,
        analises,
        popOnSuccess: popOnSuccess,
      );
    } on LabNaoReconhecidoException {
      if (!context.mounted) return;
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => ImportacaoBottomSheet(
          tipo: ImportacaoBottomSheetTipo.labNaoReconhecido,
          onDigitarManualmente: () => Navigator.of(context).pop(),
        ),
      );
    } on ExtracacaoIndisponivelException {
      if (!context.mounted) return;
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => ImportacaoBottomSheet(
          tipo: ImportacaoBottomSheetTipo.extracacaoIndisponivel,
          onDigitarManualmente: () => Navigator.of(context).pop(),
        ),
      );
    } on ImportacaoQualidadeBaixaException catch (e) {
      if (!context.mounted) return;
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => ImportacaoBottomSheet(
          tipo: ImportacaoBottomSheetTipo.qualidadeInsuficiente,
          detalhe: e.buildSummary(),
          onDigitarManualmente: () => Navigator.of(context).pop(),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao importar: $e')));
    }
  }

  static Future<void> _processarImportacao(
    BuildContext context,
    WidgetRef ref,
    List<AnaliseSolo> analises, {
    required bool popOnSuccess,
  }) async {
    final analisesVinculadas =
        await VincularHierarquiaSalvarFlow.solicitarEVincular(
      context,
      ref,
      analises: analises,
    );
    if (analisesVinculadas == null || !context.mounted) return;

    await _salvarImportadas(
      context,
      ref,
      analisesVinculadas,
      popOnSuccess: popOnSuccess,
    );

    if (context.mounted) {
      await VincularHierarquiaSalvarFlow.sincronizarPosSalvar(
        ref,
        analisesVinculadas,
      );
    }
  }

  static Future<void> _salvarImportadas(
    BuildContext context,
    WidgetRef ref,
    List<AnaliseSolo> analises, {
    required bool popOnSuccess,
  }) async {
    try {
      final persistence = ref.read(analisePersistenceGatewayProvider);
      final result = await persistence.salvarLote(analises);

      if (result.status != SaveBatchStatus.committed ||
          result.savedCount != analises.length) {
        throw SaveBatchException(
          code: SaveBatchCode.saveAtomicFailed,
          message:
              'Importação parcial bloqueada: ${result.savedCount} de ${analises.length} amostras foram confirmadas.',
          batchId: result.batchId,
          idempotencyKey: result.idempotencyKey,
        );
      }

      await persistence.recarregar();
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mensagemSucessoImportacao(result.savedCount)),
          backgroundColor: const Color(0xFF34C759),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      if (popOnSuccess && context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mensagemErroImportacao(e)),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  static String _mensagemSucessoImportacao(int total) {
    final label = total == 1 ? 'análise' : 'análises';
    return '$total $label importada${total == 1 ? '' : 's'} e salva${total == 1 ? '' : 's'}.';
  }

  static String _mensagemErroImportacao(Object erro) {
    if (erro is SaveBatchException) {
      if (erro.code == SaveBatchCode.saveAtomicFailed &&
          erro.message.toLowerCase().contains('parcial')) {
        return 'Importação parcial bloqueada. Nenhuma lista foi atualizada parcialmente; tente novamente.';
      }
      if (erro.code == SaveBatchCode.saveInProgress) {
        return 'Ainda salvando a importação anterior. Aguarde e tente novamente.';
      }
      return 'Falha ao salvar a importação: ${erro.message}';
    }

    final raw = erro.toString().replaceFirst('Exception: ', '').trim();
    return 'Falha ao salvar a importação: $raw';
  }
}

/// Inicia importação de PDF a partir da lista de análises.
Future<void> iniciarImportacaoPdf(BuildContext context, WidgetRef ref) {
  return ImportarAnalisePdfFlow.executar(context, ref);
}
