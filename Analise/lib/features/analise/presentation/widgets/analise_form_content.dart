import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/data/lab_templates/pdf_import_service.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';
import 'package:soloforte/features/analise/domain/validation/analise_data_contract.dart';
import 'package:soloforte/features/analise/presentation/controllers/nova_analise_controller.dart';
import 'package:soloforte/features/analise/presentation/widgets/analise_table_widget.dart';
import 'package:soloforte/features/analise/presentation/widgets/importacao_bottom_sheet.dart';
import 'package:soloforte/features/analise/presentation/widgets/importacao_confianca_sheet.dart';

const _brandGreen = Color(0xFF4ADE80);
const _darkGreen = Color(0xFF1E3A2F);
const _mint = Color(0xFFD1FAE5);
const _ink = Color(0xFF1A1A1A);
const _muted = Color(0xFF6B7280);
const _line = Color(0xFFE5E7EB);
const _surfaceAlt = Color(0xFFF3F4F6);

/// Formulário planilha reutilizado em nova análise e edição inline no detalhe.
class AnaliseFormContent extends ConsumerStatefulWidget {
  final AnaliseSolo? analiseInicial;
  final VoidCallback onSaveSuccess;
  final bool showFab;
  final bool showImportAction;

  const AnaliseFormContent({
    super.key,
    required this.analiseInicial,
    required this.onSaveSuccess,
    this.showFab = true,
    this.showImportAction = false,
  });

  @override
  ConsumerState<AnaliseFormContent> createState() => AnaliseFormContentState();
}

class AnaliseFormContentState extends ConsumerState<AnaliseFormContent> {
  Future<void> salvar() => _salvar();

  Future<void> importarPdf() async {
    final ctrlProvider = novaAnaliseControllerProvider(widget.analiseInicial);
    final ctrl = ref.read(ctrlProvider.notifier);
    await _importarPdf(ctrl);
  }

  bool get isSaving {
    final ctrlProvider = novaAnaliseControllerProvider(widget.analiseInicial);
    return ref.read(ctrlProvider).isSaving;
  }

  @override
  Widget build(BuildContext context) {
    final ctrlProvider = novaAnaliseControllerProvider(widget.analiseInicial);
    final state = ref.watch(ctrlProvider);
    final ctrl = ref.read(ctrlProvider.notifier);

    final derivados = ctrl.todosDerivados;
    final analisesForTable = state.analises
        .map((draft) => draft.toFormMap())
        .toList(growable: false);

    final content = SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 12,
        bottom: widget.showFab ? 80 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderGlobal(state, ctrl),
          const SizedBox(height: 12),
          _buildValidationOverview(context, state, ctrl),
          const SizedBox(height: 12),
          AnaliseTableWidget(
            analises: analisesForTable,
            derivados: derivados,
            onCampoChanged: ctrl.atualizarCampo,
            onGpsClicked: (index) async {
              final erro = await ctrl.capturarGps(index);
              if (!context.mounted) return;
              final snackBottomMargin =
                  MediaQuery.of(context).viewPadding.bottom + 92;
              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Localização capturada com sucesso'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: _darkGreen,
                    margin: EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      snackBottomMargin,
                    ),
                  ),
                );
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(erro),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.error,
                  margin: EdgeInsets.fromLTRB(16, 0, 16, snackBottomMargin),
                ),
              );
            },
            onAddAnalise: ctrl.adicionarAnalise,
            onRemoveAnalise: ctrl.removerAnalise,
            laboratorio: state.laudoLaboratorio,
            validation: state.validation,
            highlightedCellKey: state.highlightedCellKey,
          ),
        ],
      ),
    );

    if (!widget.showFab) {
      return ColoredBox(color: _surfaceAlt, child: content);
    }

    return ColoredBox(
      color: _surfaceAlt,
      child: Stack(
        children: [
          content,
          Positioned(
            right: 16,
            bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
            child: _buildSaveFab(state, ctrl),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveFab(NovaAnaliseState state, NovaAnaliseController ctrl) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D007AFF),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          onTap: state.isSaving ? null : _salvar,
          child: Container(
            height: AppDimens.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.isSaving)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                const SizedBox(width: 8),
                Text(
                  state.analises.length == 1
                      ? 'Salvar Análise'
                      : 'Salvar ${state.analises.length} Análises',
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderGlobal(
    NovaAnaliseState state,
    NovaAnaliseController ctrl,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'IDENTIFICAÇÃO DO LAUDO',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: _muted,
                  ),
                ),
              ),
              if (state.laudoLaboratorio.trim().isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _mint,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: _brandGreen.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        state.laudoLaboratorio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _darkGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          AppInput(
            label: 'Produtor',
            initialValue: state.laudoProdutor,
            onChanged: ctrl.atualizarLaudoProdutor,
          ),
          const SizedBox(height: 10),
          AppInput(
            label: 'Fazenda',
            initialValue: state.laudoFazenda,
            onChanged: ctrl.atualizarLaudoFazenda,
          ),
          const SizedBox(height: 10),
          AppDropdown<String>(
            label: 'Laboratório',
            hint: 'Selecione o laboratório',
            value:
                state.laudoLaboratorio.isEmpty ? null : state.laudoLaboratorio,
            items: const [
              AppDropdownItem(value: 'Sellar', label: 'Sellar'),
              AppDropdownItem(value: 'Exata Brasil', label: 'Exata Brasil'),
              AppDropdownItem(value: 'IBRA', label: 'IBRA'),
              AppDropdownItem(
                value: 'MB Agronegócios',
                label: 'MB Agronegócios',
              ),
            ],
            onChanged: (val) => ctrl.atualizarLaudoLaboratorio(val ?? ''),
          ),
          const SizedBox(height: 10),
          AppInput(
            label: 'Safra',
            initialValue: state.laudoSafra,
            onChanged: ctrl.atualizarLaudoSafra,
            hint: 'Ex: 2024/2025',
            maxLength: 9,
          ),
        ],
      ),
    );
  }

  Widget _buildValidationOverview(
    BuildContext context,
    NovaAnaliseState state,
    NovaAnaliseController ctrl,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                state.validation.hasBlockingErrors
                    ? Icons.error_outline
                    : (state.validation.hasWarnings
                        ? Icons.warning_amber_outlined
                        : Icons.check_circle_outline),
                size: 18,
                color: state.validation.hasBlockingErrors
                    ? AppColors.error
                    : (state.validation.hasWarnings
                        ? const Color(0xFFD97706)
                        : _darkGreen),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.validation.hasIssues
                      ? '${state.validation.totalErrors} erro(s) e ${state.validation.totalWarnings} aviso(s)'
                      : 'Sem inconsistências na validação',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: state.validation.hasBlockingErrors
                        ? AppColors.error
                        : _ink,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: state.validation.hasIssues
                    ? () {
                        final issue = ctrl.destacarProximaCelulaInvalida();
                        if (issue == null || !context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${issue.cellLabel}: ${issue.message}',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor:
                                issue.severity == ValidationSeverity.error
                                    ? AppColors.error
                                    : const Color(0xFFD97706),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.skip_next_rounded, size: 16),
                label: const Text('Próxima'),
                style: TextButton.styleFrom(
                  foregroundColor: _darkGreen,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _salvar() async {
    final ctrlProvider = novaAnaliseControllerProvider(widget.analiseInicial);
    final ctrl = ref.read(ctrlProvider.notifier);
    final snackBottomMargin = MediaQuery.of(context).viewPadding.bottom + 92;
    final ok = await ctrl.salvar();
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Análise salva com sucesso'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _darkGreen,
          margin: EdgeInsets.fromLTRB(16, 0, 16, snackBottomMargin),
        ),
      );
      widget.onSaveSuccess();
      return;
    }

    ctrl.destacarProximaCelulaInvalida();

    final erro = (ref.read(ctrlProvider).error ?? '').trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(erro.isEmpty ? 'Erro ao salvar — tente novamente' : erro),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
        margin: EdgeInsets.fromLTRB(16, 0, 16, snackBottomMargin),
      ),
    );
  }

  Future<void> _importarPdf(NovaAnaliseController ctrl) async {
    try {
      final analises = await PdfImportService().importarDePdf();
      if (analises == null) return;
      if (!mounted) return;

      await _salvarImportadas(ctrl, analises);
    } on LabConfiancaBaixaException catch (e) {
      if (!mounted) return;
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

      if (selectedLabId == null || !mounted) return;

      final analises = await PdfImportService().importarArquivoPdf(
        fileBytes: e.fileBytes,
        fileName: e.fileName,
        forcedLabId: selectedLabId,
        operationId: e.operationId,
      );

      if (!mounted) return;
      await _salvarImportadas(ctrl, analises);
    } on LabNaoReconhecidoException {
      if (!mounted) return;
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => ImportacaoBottomSheet(
          tipo: ImportacaoBottomSheetTipo.labNaoReconhecido,
          onDigitarManualmente: () => Navigator.of(context).pop(),
        ),
      );
    } on ExtracacaoIndisponivelException {
      if (!mounted) return;
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => ImportacaoBottomSheet(
          tipo: ImportacaoBottomSheetTipo.extracacaoIndisponivel,
          onDigitarManualmente: () => Navigator.of(context).pop(),
        ),
      );
    } on ImportacaoQualidadeBaixaException catch (e) {
      if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao importar: $e')),
      );
    }
  }

  Future<void> _salvarImportadas(
    NovaAnaliseController ctrl,
    List<AnaliseSolo> analises,
  ) async {
    try {
      final result = await ctrl.salvarImportadas(analises);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mensagemSucessoImportacao(result.savedCount)),
          backgroundColor: const Color(0xFF34C759),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );

      widget.onSaveSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mensagemErroImportacao(e)),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  String _mensagemSucessoImportacao(int total) {
    final label = total == 1 ? 'análise' : 'análises';
    return '$total $label importada${total == 1 ? '' : 's'} e salva${total == 1 ? '' : 's'}.';
  }

  String _mensagemErroImportacao(Object erro) {
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
