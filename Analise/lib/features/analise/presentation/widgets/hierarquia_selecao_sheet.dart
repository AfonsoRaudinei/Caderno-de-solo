import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/features/analise/application/providers/hierarquia_selecao_provider.dart';
import 'package:soloforte/features/analise/domain/value_objects/hierarquia_selecao_result.dart';
import 'package:soloforte/features/analise/domain/value_objects/hierarquia_selecao_sugestao.dart';

/// Bottom sheet para selecionar ou criar Cliente → Propriedade → Talhão.
Future<HierarquiaSelecaoResult?> showHierarquiaSelecaoSheet(
  BuildContext context,
  WidgetRef ref, {
  required HierarquiaSelecaoSugestao sugestao,
}) {
  return showModalBottomSheet<HierarquiaSelecaoResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _HierarquiaSelecaoSheetBody(
        sugestao: sugestao,
        onConfirm: (result) => Navigator.of(sheetContext).pop(result),
      );
    },
  );
}

class _HierarquiaSelecaoSheetBody extends ConsumerStatefulWidget {
  const _HierarquiaSelecaoSheetBody({
    required this.sugestao,
    required this.onConfirm,
  });

  final HierarquiaSelecaoSugestao sugestao;
  final ValueChanged<HierarquiaSelecaoResult> onConfirm;

  @override
  ConsumerState<_HierarquiaSelecaoSheetBody> createState() =>
      _HierarquiaSelecaoSheetBodyState();
}

class _HierarquiaSelecaoSheetBodyState
    extends ConsumerState<_HierarquiaSelecaoSheetBody> {
  final _novoNomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hierarquiaSelecaoProvider.notifier).inicializar(widget.sugestao);
    });
  }

  @override
  void dispose() {
    _novoNomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(hierarquiaSelecaoProvider, (previous, next) {
      if (next.requiresLogin && context.mounted) {
        Navigator.of(context).pop();
        context.go(AppRoutes.login);
      }
    });

    final state = ref.watch(hierarquiaSelecaoProvider);
    final notifier = ref.read(hierarquiaSelecaoProvider.notifier);
    final palette = context.appPalette;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.88,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Vincular análise',
                          style: AppTextStyles.headline.copyWith(
                            fontSize: 20,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimens.sm),
                        Text(
                          'Selecione ou crie o cliente, a propriedade e o talhão '
                          'onde esta análise será salva.',
                          style: AppTextStyles.body.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                        if (state.isLoading) ...[
                          const SizedBox(height: AppDimens.xl),
                          const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ] else if (state.listaVazia) ...[
                          const SizedBox(height: AppDimens.lg),
                          _EmptyClientes(onCriar: () {
                            notifier
                                .abrirModo(HierarquiaSelecaoModo.criarCliente);
                          }),
                        ] else ...[
                          const SizedBox(height: AppDimens.lg),
                          _DropdownSecao(
                            label: 'Cliente',
                            hint: 'Selecione o cliente',
                            value: state.clienteId,
                            items: state.clientes
                                .map(
                                  (c) => AppDropdownItem(
                                    value: c.id,
                                    label: c.nome.trim().isEmpty
                                        ? 'Cliente sem nome'
                                        : c.nome,
                                  ),
                                )
                                .toList(),
                            onChanged: notifier.selecionarCliente,
                            onNovo: () {
                              _novoNomeController.text =
                                  widget.sugestao.produtor.trim();
                              notifier.abrirModo(
                                HierarquiaSelecaoModo.criarCliente,
                              );
                            },
                          ),
                          const SizedBox(height: AppDimens.md),
                          _DropdownSecao(
                            label: 'Propriedade',
                            hint: state.clienteId == null
                                ? 'Selecione um cliente'
                                : 'Selecione a propriedade',
                            value: state.fazendaId,
                            enabled: state.clienteId != null,
                            items: state.fazendasDisponiveis
                                .map(
                                  (f) => AppDropdownItem(
                                    value: f.id,
                                    label: f.nome,
                                  ),
                                )
                                .toList(),
                            onChanged: notifier.selecionarFazenda,
                            onNovo: state.clienteId == null
                                ? null
                                : () {
                                    _novoNomeController.text =
                                        widget.sugestao.fazenda.trim();
                                    notifier.abrirModo(
                                      HierarquiaSelecaoModo.criarFazenda,
                                    );
                                  },
                          ),
                          const SizedBox(height: AppDimens.md),
                          _DropdownSecao(
                            label: 'Talhão / Área',
                            hint: state.fazendaId == null
                                ? 'Selecione uma propriedade'
                                : 'Selecione o talhão',
                            value: state.talhaoId,
                            enabled: state.fazendaId != null,
                            items: state.talhoesDisponiveis
                                .map(
                                  (t) => AppDropdownItem(
                                    value: t.id,
                                    label: t.nome,
                                  ),
                                )
                                .toList(),
                            onChanged: notifier.selecionarTalhao,
                            onNovo: state.fazendaId == null
                                ? null
                                : () {
                                    _novoNomeController.text =
                                        widget.sugestao.talhao.trim();
                                    notifier.abrirModo(
                                      HierarquiaSelecaoModo.criarTalhao,
                                    );
                                  },
                          ),
                        ],
                        if (state.modo != HierarquiaSelecaoModo.selecionar) ...[
                          const SizedBox(height: AppDimens.lg),
                          _InlineCreateForm(
                            modo: state.modo,
                            controller: _novoNomeController,
                            onCancel: notifier.cancelarModo,
                            onSubmit: () => _submitCreate(notifier),
                          ),
                        ],
                        if (state.erro != null && state.erro!.isNotEmpty) ...[
                          const SizedBox(height: AppDimens.md),
                          Text(
                            state.erro!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppDimens.lg),
                        AppButton(
                          label: 'Confirmar e importar',
                          onPressed: state.podeConfirmar && !state.isLoading
                              ? () {
                                  final result = notifier.buildResult();
                                  if (result != null) {
                                    widget.onConfirm(result);
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitCreate(HierarquiaSelecaoNotifier notifier) async {
    final nome = _novoNomeController.text.trim();
    switch (ref.read(hierarquiaSelecaoProvider).modo) {
      case HierarquiaSelecaoModo.criarCliente:
        await notifier.criarCliente(nome);
      case HierarquiaSelecaoModo.criarFazenda:
        await notifier.criarFazenda(nome: nome);
      case HierarquiaSelecaoModo.criarTalhao:
        await notifier.criarTalhao(nome: nome);
      case HierarquiaSelecaoModo.selecionar:
        break;
    }
  }
}

class _DropdownSecao extends StatelessWidget {
  const _DropdownSecao({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.onNovo,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final String? value;
  final List<AppDropdownItem<String>> items;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onNovo;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.label.copyWith(color: palette.textPrimary),
              ),
            ),
            if (onNovo != null)
              TextButton(
                onPressed: enabled ? onNovo : null,
                child: const Text('Novo'),
              ),
          ],
        ),
        AppDropdown<String>(
          label: null,
          hint: hint,
          value: items.any((item) => item.value == value) ? value : null,
          enabled: enabled && items.isNotEmpty,
          items: items,
          onChanged: onChanged,
          errorText:
              enabled && items.isEmpty ? 'Nenhum cadastro disponível' : null,
        ),
      ],
    );
  }
}

class _InlineCreateForm extends StatelessWidget {
  const _InlineCreateForm({
    required this.modo,
    required this.controller,
    required this.onCancel,
    required this.onSubmit,
  });

  final HierarquiaSelecaoModo modo;
  final TextEditingController controller;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  String get _titulo => switch (modo) {
        HierarquiaSelecaoModo.criarCliente => 'Novo cliente',
        HierarquiaSelecaoModo.criarFazenda => 'Nova propriedade',
        HierarquiaSelecaoModo.criarTalhao => 'Novo talhão',
        HierarquiaSelecaoModo.selecionar => '',
      };

  String get _label => switch (modo) {
        HierarquiaSelecaoModo.criarCliente => 'Nome do cliente',
        HierarquiaSelecaoModo.criarFazenda => 'Nome da propriedade',
        HierarquiaSelecaoModo.criarTalhao => 'Nome do talhão',
        HierarquiaSelecaoModo.selecionar => '',
      };

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      showBorder: true,
      padding: const EdgeInsets.all(AppDimens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_titulo, style: AppTextStyles.label),
          const SizedBox(height: AppDimens.sm),
          AppInput(
            controller: controller,
            label: _label,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: FilledButton(
                  onPressed: onSubmit,
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyClientes extends StatelessWidget {
  const _EmptyClientes({required this.onCriar});

  final VoidCallback onCriar;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AppSurface(
      showBorder: true,
      child: Column(
        children: [
          Icon(Icons.person_outline, size: 40, color: palette.textSecondary),
          const SizedBox(height: AppDimens.sm),
          Text(
            'Nenhum cliente cadastrado',
            style: AppTextStyles.label.copyWith(color: palette.textPrimary),
          ),
          const SizedBox(height: AppDimens.xs),
          Text(
            'Crie o primeiro cliente para vincular esta importação.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: AppDimens.md),
          AppButton(label: 'Criar cliente', onPressed: onCriar),
        ],
      ),
    );
  }
}
