import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/data/lab_templates/pdf_import_service.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/application/providers/produtor_configurado_provider.dart';
import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';
import 'package:soloforte/features/analise/domain/services/produtor_resolucao_service.dart';
import 'package:soloforte/features/analise/application/providers/analise_persistence_gateway.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
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
    final configuradoAtual =
        ref.read(produtorConfiguradoProvider).valueOrNull ?? '';
    final sugestao = _sugerirProdutor(analises, configuradoAtual);
    if (!context.mounted) return;

    final produtorConfigurado = await showProdutorConfiguradoImportSheet(
      context,
      valorInicial: sugestao,
    );
    if (produtorConfigurado == null || !context.mounted) return;

    await ref
        .read(produtorConfiguradoProvider.notifier)
        .salvar(produtorConfigurado);
    if (!context.mounted) return;

    final analisesNormalizadas = analises
        .map(
          (analise) => ProdutorResolucaoService.aplicarProdutorConfigurado(
            analise,
            produtorConfigurado,
          ),
        )
        .toList(growable: false);

    await _salvarImportadas(
      context,
      ref,
      analisesNormalizadas,
      popOnSuccess: popOnSuccess,
    );

    if (context.mounted) {
      await ref
          .read(analiseNotifierProvider.notifier)
          .repararProdutoresLegados();
    }
  }

  static String _sugerirProdutor(
    List<AnaliseSolo> analises,
    String configuradoAtual,
  ) {
    if (configuradoAtual.trim().isNotEmpty) return configuradoAtual.trim();
    for (final analise in analises) {
      final candidato = ProdutorResolucaoService.resolver(
        produtorAtual: analise.produtor,
        laudoMetadata: analise.laudoMetadata,
        produtorConfigurado: '',
      );
      if (candidato.isNotEmpty) return candidato;
    }
    return '';
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

Future<String?> showProdutorConfiguradoImportSheet(
  BuildContext context, {
  required String valorInicial,
}) {
  final controller = TextEditingController(text: valorInicial);
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      var erro = '';
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1D1D6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Produtor configurado',
                        style: Theme.of(sheetContext)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Informe o produtor/cliente desta importação. '
                        'Somente análises deste produtor ficarão visíveis.',
                        style: Theme.of(sheetContext)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: const Color(0xFF6E6E73)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Produtor / Cliente',
                          hintText: 'Ex: Rogério de Paiva Moura',
                          errorText: erro.isEmpty ? null : erro,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          final produtor = controller.text.trim();
                          if (ProdutorResolucaoService.isProdutorInvalido(
                            produtor,
                          )) {
                            setState(() {
                              erro =
                                  'Informe o nome do produtor/cliente da análise.';
                            });
                            return;
                          }
                          Navigator.of(sheetContext).pop(produtor);
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Confirmar e importar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  ).whenComplete(controller.dispose);
}

/// Inicia importação de PDF a partir da lista de análises.
Future<void> iniciarImportacaoPdf(BuildContext context, WidgetRef ref) {
  return ImportarAnalisePdfFlow.executar(context, ref);
}
