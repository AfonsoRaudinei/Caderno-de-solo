import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/features/clientes/application/providers/cliente_provider.dart';
import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';

class FazendaFormScreen extends ConsumerStatefulWidget {
  const FazendaFormScreen({
    super.key,
    required this.clienteId,
    this.fazendaId,
  });

  final String clienteId;
  final String? fazendaId;

  @override
  ConsumerState<FazendaFormScreen> createState() => _FazendaFormScreenState();
}

class _FazendaFormScreenState extends ConsumerState<FazendaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _areaController = TextEditingController();
  bool _initialized = false;

  bool get _isEdicao =>
      widget.fazendaId != null && widget.fazendaId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(clienteProvider.notifier)
          .carregarClienteDetalhe(widget.clienteId);
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clienteProvider);
    final fazenda = state.clienteSelecionado?.fazendas
        .where((item) => item.id == widget.fazendaId)
        .firstOrNull;

    if (!_initialized && fazenda != null) {
      _nomeController.text = fazenda.nome;
      _areaController.text = fazenda.areaTotal.toString().replaceAll('.', ',');
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: context.appPalette.background,
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Fazenda' : 'Nova Fazenda'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppSurface(
                  showBorder: true,
                  child: Column(
                    children: [
                      AppInput(
                        controller: _nomeController,
                        label: 'Nome da fazenda*',
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if ((value?.trim() ?? '').isEmpty) {
                            return 'Informe o nome.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      AppInputNumerico(
                        controller: _areaController,
                        label: 'Área total (ha)*',
                        suffixText: 'ha',
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Salvar Fazenda',
                  isLoading: state.isLoading,
                  onPressed: _salvar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final area = _parseDecimal(_areaController.text);
    if (area == null) return;

    final notifier = ref.read(clienteProvider.notifier);
    final entity = FazendaEntity(
      id: widget.fazendaId ?? '',
      nome: _nomeController.text.trim(),
      areaTotal: area,
      talhoes: fazendaAtual?.talhoes ?? const [],
      criadoEm: fazendaAtual?.criadoEm ?? DateTime.now(),
    );

    if (_isEdicao) {
      await notifier.atualizarFazenda(widget.clienteId, entity);
    } else {
      await notifier.adicionarFazenda(widget.clienteId, entity);
    }

    if (mounted) context.pop(true);
  }

  FazendaEntity? get fazendaAtual {
    final atual = ref.read(clienteProvider).clienteSelecionado;
    return atual?.fazendas
        .where((item) => item.id == widget.fazendaId)
        .firstOrNull;
  }

  double? _parseDecimal(String text) {
    final normalized = text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }
}
