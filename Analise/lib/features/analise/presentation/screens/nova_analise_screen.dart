import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/data/lab_templates/pdf_import_service.dart';
import 'package:soloforte/features/auth/application/providers/auth_usecase_providers.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/validation/analise_data_contract.dart';
import 'package:soloforte/features/analise/presentation/controllers/nova_analise_controller.dart';
import 'package:soloforte/features/analise/presentation/widgets/importacao_confianca_sheet.dart';
import 'package:soloforte/features/analise/presentation/widgets/analise_table_widget.dart';
import 'package:soloforte/features/analise/presentation/widgets/importacao_bottom_sheet.dart';

const _brandGreen = Color(0xFF4ADE80);
const _darkGreen = Color(0xFF1E3A2F);
const _mint = Color(0xFFD1FAE5);
const _ink = Color(0xFF1A1A1A);
const _muted = Color(0xFF6B7280);
const _line = Color(0xFFE5E7EB);
const _surfaceAlt = Color(0xFFF3F4F6);

class NovaAnaliseScreen extends ConsumerWidget {
  final AnaliseSolo? analiseParaEditar;

  const NovaAnaliseScreen({super.key, this.analiseParaEditar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrlProvider = novaAnaliseControllerProvider(analiseParaEditar);
    final state = ref.watch(ctrlProvider);
    final ctrl = ref.read(ctrlProvider.notifier);

    final derivados = ctrl.todosDerivados;
    final analisesForTable = state.analises
        .map((draft) => draft.toFormMap())
        .toList(growable: false);

    return Scaffold(
      backgroundColor: _surfaceAlt,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          analiseParaEditar == null ? 'Nova Análise' : 'Editar Análise',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
            letterSpacing: -0.2,
          ),
        ),
        iconTheme: const IconThemeData(color: _darkGreen),
        actions: [
          TextButton.icon(
            onPressed:
                state.isSaving ? null : () => _importarPdf(context, ref, ctrl),
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Importar'),
            style: TextButton.styleFrom(
              foregroundColor: _darkGreen,
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.7),
          child: SizedBox(height: 0.7, child: ColoredBox(color: _line)),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 12, bottom: 80),
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
                          content:
                              const Text('Localização capturada com sucesso'),
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
                        margin:
                            EdgeInsets.fromLTRB(16, 0, 16, snackBottomMargin),
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
          ),
          Positioned(
            right: 16,
            bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
            child: DecoratedBox(
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
                  onTap:
                      state.isSaving ? null : () => _salvar(context, ref, ctrl),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderGlobal(
      NovaAnaliseState state, NovaAnaliseController ctrl) {
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
                  value: 'MB Agronegócios', label: 'MB Agronegócios'),
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
    final byColumn = state.validation.byColumn.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

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
          if (byColumn.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: byColumn.map((entry) {
                final summary = entry.value;
                final text = summary.errorCount > 0
                    ? '${summary.errorCount} erro(s) em A${entry.key + 1}'
                    : '${summary.warningCount} aviso(s) em A${entry.key + 1}';
                final hasError = summary.errorCount > 0;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: hasError
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: hasError
                          ? const Color(0xFFFCA5A5)
                          : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: hasError
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF92400E),
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _salvar(
    BuildContext context,
    WidgetRef ref,
    NovaAnaliseController ctrl,
  ) async {
    final snackBottomMargin = MediaQuery.of(context).viewPadding.bottom + 92;
    final ok = await ctrl.salvar();
    if (!context.mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Análise salva com sucesso'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _darkGreen,
          margin: EdgeInsets.fromLTRB(16, 0, 16, snackBottomMargin),
        ),
      );
      if (context.canPop()) {
        context.pop();
      }
      return;
    }

    ctrl.destacarProximaCelulaInvalida();

    final erro =
        (ref.read(novaAnaliseControllerProvider(analiseParaEditar)).error ?? '')
            .trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(erro.isEmpty ? 'Erro ao salvar — tente novamente' : erro),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
        margin: EdgeInsets.fromLTRB(16, 0, 16, snackBottomMargin),
      ),
    );
  }

  Future<void> _importarPdf(
    BuildContext context,
    WidgetRef ref,
    NovaAnaliseController ctrl,
  ) async {
    try {
      final analises = await PdfImportService().importarDePdf(context);
      if (analises == null) return;

      ctrl.carregarDeAnaliseSolo(analises);
      final userId = await ref
          .read(waitForCurrentUserIdUsecaseProvider)
          .call(timeout: const Duration(seconds: 5));

      if (userId == null || userId.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sessão expirada. Faça login novamente.'),
            backgroundColor: Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final ok = await ctrl.salvar();
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${analises.length} ${analises.length == 1 ? 'análise importada' : 'análises importadas'} com sucesso',
            ),
            backgroundColor: const Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
        if (context.mounted) context.pop();
      }
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

      ctrl.carregarDeAnaliseSolo(analises);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${analises.length} amostra${analises.length > 1 ? 's' : ''} importada${analises.length > 1 ? 's' : ''} após confirmação do laboratório',
          ),
          backgroundColor: _darkGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao importar: $e')),
      );
    }
  }
}
