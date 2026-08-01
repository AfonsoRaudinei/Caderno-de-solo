import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/features/clientes/application/providers/cliente_provider.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';

class ClienteFormScreen extends ConsumerStatefulWidget {
  const ClienteFormScreen({
    super.key,
    this.clienteId,
  });

  final String? clienteId;

  @override
  ConsumerState<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends ConsumerState<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _observacoesController = TextEditingController();

  String? _estado;
  bool _initialized = false;

  bool get _isEdicao =>
      widget.clienteId != null && widget.clienteId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_isEdicao) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(clienteProvider.notifier)
            .carregarClienteDetalhe(widget.clienteId!);
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _cidadeController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(clienteProvider.select((s) => s.isLoading));
    final cliente = _isEdicao
        ? ref.watch(clienteProvider.select((s) => s.clienteSelecionado))
        : null;

    if (!_initialized && cliente != null) {
      _nomeController.text = cliente.nome;
      _telefoneController.text = cliente.telefone;
      _emailController.text = cliente.email;
      _cidadeController.text = cliente.cidade;
      _observacoesController.text = cliente.observacoes ?? '';
      _estado = cliente.estado;
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: context.appPalette.background,
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Cliente' : 'Novo Cliente'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSurface(
                  showBorder: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Dados Pessoais'),
                      AppInput(
                        controller: _nomeController,
                        label: 'Nome completo',
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        validator: ClienteFormValidators.nome,
                      ),
                      const SizedBox(height: 12),
                      AppInput(
                        controller: _telefoneController,
                        label: 'Telefone / WhatsApp',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: const [_PhoneInputFormatter()],
                        validator: ClienteFormValidators.telefone,
                      ),
                      const SizedBox(height: 12),
                      AppInput(
                        controller: _emailController,
                        label: 'E-mail',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: ClienteFormValidators.email,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppSurface(
                  showBorder: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Localização'),
                      AppInput(
                        controller: _cidadeController,
                        label: 'Cidade',
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        validator: ClienteFormValidators.cidade,
                      ),
                      const SizedBox(height: 12),
                      AppDropdown<String>(
                        label: 'Estado',
                        hint: 'Selecione a UF',
                        items: estadosBrasileiros
                            .map((item) => AppDropdownItem(
                                  value: item.value,
                                  label: '${item.value} · ${item.label}',
                                ))
                            .toList(growable: false),
                        value: _estado,
                        onChanged: (value) => setState(() => _estado = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppSurface(
                  showBorder: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Observações'),
                      AppTextArea(
                        controller: _observacoesController,
                        label: 'Campo livre',
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Salvar Cliente',
                  isLoading: isLoading,
                  onPressed: _salvar,
                ),
                if (_isEdicao) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : _confirmarExclusao,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Excluir Cliente'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(clienteProvider.notifier);
    final base = ClienteEntity(
      id: widget.clienteId ?? '',
      token: '',
      nome: _nomeController.text.trim(),
      telefone: _telefoneController.text.trim(),
      email: _emailController.text.trim(),
      cidade: _cidadeController.text.trim(),
      estado: _estado?.trim() ?? '',
      observacoes: _observacoesController.text.trim().isEmpty
          ? null
          : _observacoesController.text.trim(),
      usuarioId: '',
      criadoEm: DateTime.now(),
      atualizadoEm: DateTime.now(),
    );

    var salvou = false;
    if (_isEdicao) {
      final atual = ref.read(clienteProvider).clienteSelecionado;
      if (atual == null) return;
      salvou = await notifier.atualizarCliente(
        base.copyWith(
          token: atual.token,
          usuarioId: atual.usuarioId,
          criadoEm: atual.criadoEm,
          analiseIds: atual.analiseIds,
          fazendas: atual.fazendas,
        ),
      );
    } else {
      final id = await notifier.criarCliente(base);
      salvou = id != null && id.isNotEmpty;
    }

    if (!mounted) return;
    if (!salvou) {
      final state = ref.read(clienteProvider);
      if (state.requiresLogin) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        context.go(AppRoutes.login);
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(state.erro ?? 'Não foi possível salvar o cliente.'),
          ),
        );
      return;
    }
    context.pop(true);
  }

  Future<void> _confirmarExclusao() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Excluir cliente?'),
            content: const Text(
              'Essa ação também remove as fazendas e talhões vinculados.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;
    await ref.read(clienteProvider.notifier).deletarCliente(widget.clienteId!);
    if (mounted) context.pop(true);
  }
}

/// Validações do formulário de cliente (testáveis fora da árvore de widgets).
class ClienteFormValidators {
  ClienteFormValidators._();

  static String? nome(String? value) => null;

  static String? cidade(String? value) => null;

  static String? telefone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    if (digits.length < 10) {
      return 'Informe um telefone válido.';
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(text)) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: AppColors.textSecond, letterSpacing: 0.8),
      ),
    );
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  const _PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 7 && limited.length > 10) buffer.write('-');
      if (i == 6 && limited.length <= 10) buffer.write('-');
      buffer.write(limited[i]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
