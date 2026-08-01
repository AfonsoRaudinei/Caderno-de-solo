import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/features/analise/application/providers/location_provider.dart';
import 'package:soloforte/features/clientes/application/providers/cliente_provider.dart';
import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';

class TalhaoFormScreen extends ConsumerStatefulWidget {
  const TalhaoFormScreen({
    super.key,
    required this.clienteId,
    required this.fazendaId,
    this.talhaoId,
  });

  final String clienteId;
  final String fazendaId;
  final String? talhaoId;

  @override
  ConsumerState<TalhaoFormScreen> createState() => _TalhaoFormScreenState();
}

class _TalhaoFormScreenState extends ConsumerState<TalhaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _areaController = TextEditingController();
  final _culturaController = TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _initialized = false;

  bool get _isEdicao => widget.talhaoId != null && widget.talhaoId!.isNotEmpty;

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
    _culturaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LocationState>(locationNotifierProvider, (previous, next) {
      switch (next) {
        case LocationSuccess(:final result):
          setState(() {
            _latitude = result.latitude;
            _longitude = result.longitude;
          });
        case LocationError(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              content: Text(message),
            ),
          );
        default:
          break;
      }
    });

    final cliente = ref.watch(clienteProvider).clienteSelecionado;
    final fazenda = cliente?.fazendas
        .where((item) => item.id == widget.fazendaId)
        .firstOrNull;
    final talhao = fazenda?.talhoes
        .where((item) => item.id == widget.talhaoId)
        .firstOrNull;

    if (!_initialized && talhao != null) {
      _nomeController.text = talhao.nome;
      _areaController.text = talhao.area.toString().replaceAll('.', ',');
      _culturaController.text = talhao.culturaPrincipal ?? '';
      _latitude = talhao.latitude;
      _longitude = talhao.longitude;
      _initialized = true;
    }

    final locationState = ref.watch(locationNotifierProvider);
    final isCapturando = locationState is LocationLoading;

    final palette = context.appPalette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Talhão' : 'Novo Talhão'),
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
                        label: 'Nome do talhão*',
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
                        label: 'Área (ha)*',
                        suffixText: 'ha',
                      ),
                      const SizedBox(height: 12),
                      AppInput(
                        controller: _culturaController,
                        label: 'Cultura principal',
                        textCapitalization: TextCapitalization.words,
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
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isCapturando
                              ? null
                              : () => ref
                                  .read(locationNotifierProvider.notifier)
                                  .capturar(),
                          icon: isCapturando
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location_rounded),
                          label: const Text('Capturar GPS'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _latitude != null && _longitude != null
                            ? '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'
                            : 'GPS ainda não capturado',
                        style: AppTextStyles.caption.copyWith(
                          color: _latitude != null && _longitude != null
                              ? AppColors.success
                              : palette.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Salvar Talhão',
                  isLoading: ref.watch(clienteProvider).isLoading,
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

    final atual = _talhaoAtual;
    final entity = TalhaoEntity(
      id: widget.talhaoId ?? '',
      nome: _nomeController.text.trim(),
      area: area,
      latitude: _latitude,
      longitude: _longitude,
      culturaPrincipal: _culturaController.text.trim().isEmpty
          ? null
          : _culturaController.text.trim(),
      criadoEm: atual?.criadoEm ?? DateTime.now(),
    );

    final notifier = ref.read(clienteProvider.notifier);
    if (_isEdicao) {
      await notifier.atualizarTalhao(
          widget.clienteId, widget.fazendaId, entity);
    } else {
      await notifier.adicionarTalhao(
          widget.clienteId, widget.fazendaId, entity);
    }

    if (mounted) context.pop(true);
  }

  TalhaoEntity? get _talhaoAtual {
    final cliente = ref.read(clienteProvider).clienteSelecionado;
    final fazenda = cliente?.fazendas
        .where((item) => item.id == widget.fazendaId)
        .firstOrNull;
    return fazenda?.talhoes
        .where((item) => item.id == widget.talhaoId)
        .firstOrNull;
  }

  double? _parseDecimal(String text) {
    final normalized = text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }
}
