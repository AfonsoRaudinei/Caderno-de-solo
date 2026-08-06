import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/clientes/application/providers/cliente_provider.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';

/// Normaliza profundidade para filtro (padrão do app: 0-20).
String normalizarProfundidadeRecomendacao(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) return '0-20';
  final compact = value.replaceAll(' ', '').replaceAll('–', '-');
  if (compact.startsWith('0-20') || compact == '0a20') return '0-20';
  if (compact.startsWith('20-40') || compact == '20a40') return '20-40';
  return compact;
}

bool profundidadeMatchesFiltro(
  String? profundidade, {
  required bool include020,
  required bool include2040,
}) {
  if (!include020 && !include2040) return false;
  final normalized = normalizarProfundidadeRecomendacao(profundidade);
  if (normalized == '0-20') return include020;
  if (normalized == '20-40') return include2040;
  // Outras profundidades: mostra se pelo menos um filtro estiver ativo.
  return include020 || include2040;
}

String chipLabelAnalise(AnaliseSolo analise) {
  final talhao = analise.talhao.trim().isEmpty ? '—' : analise.talhao.trim();
  final amostra =
      analise.numeroAmostra.trim().isEmpty ? '—' : analise.numeroAmostra.trim();
  final prof = normalizarProfundidadeRecomendacao(analise.profundidade);
  return '$talhao · $amostra · $prof';
}

/// Seleção compacta: cliente → filtro profundidade → chips inline + adicionar.
class RecomendacaoSelecaoAnalises extends ConsumerStatefulWidget {
  const RecomendacaoSelecaoAnalises({
    super.key,
    required this.selecionados,
    required this.onChanged,
    this.initialClienteId,
  });

  final List<String> selecionados;
  final ValueChanged<List<String>> onChanged;
  final String? initialClienteId;

  @override
  ConsumerState<RecomendacaoSelecaoAnalises> createState() =>
      _RecomendacaoSelecaoAnalisesState();
}

class _RecomendacaoSelecaoAnalisesState
    extends ConsumerState<RecomendacaoSelecaoAnalises> {
  String? _clienteId;
  bool _filtro020 = true;
  bool _filtro2040 = true;
  bool _initialClienteApplied = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialClienteApplied) return;
    _initialClienteApplied = true;
    final initial = widget.initialClienteId?.trim();
    if (initial != null && initial.isNotEmpty) {
      _clienteId = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _selecionarClientePorId(initial);
      });
    }
  }

  void _selecionarClientePorId(String id) {
    final clientes = ref.read(clienteProvider).clientes;
    final match = clientes.where((c) => c.id == id).firstOrNull;
    if (match != null) {
      ref.read(clienteProvider.notifier).selecionarCliente(match);
    }
  }

  void _onClienteChanged(String? id) {
    setState(() => _clienteId = id);
    if (id == null || id.isEmpty) {
      ref.read(clienteProvider.notifier).selecionarCliente(null);
      widget.onChanged(const []);
      return;
    }
    _selecionarClientePorId(id);
    // Remove seleção que não pertence ao novo cliente.
    final doCliente = ref.read(analisesPorClienteProvider(id));
    final idsCliente = doCliente.map((a) => a.id).toSet();
    final mantidos =
        widget.selecionados.where(idsCliente.contains).toList(growable: false);
    if (mantidos.length != widget.selecionados.length) {
      widget.onChanged(mantidos);
    }
  }

  List<AnaliseSolo> _candidatas(List<AnaliseSolo> doCliente) {
    return doCliente
        .where(
          (a) => profundidadeMatchesFiltro(
            a.profundidade,
            include020: _filtro020,
            include2040: _filtro2040,
          ),
        )
        .toList(growable: false);
  }

  String? _laboratorioAtivo(List<AnaliseSolo> todas) {
    if (widget.selecionados.isEmpty) return null;
    final primeira = todas.where((a) => a.id == widget.selecionados.first);
    if (primeira.isEmpty) return null;
    return primeira.first.laboratorio.trim();
  }

  Future<void> _abrirSheetAdicionar(List<AnaliseSolo> candidatas) async {
    final labAtivo = _laboratorioAtivo(
      ref.read(analiseNotifierProvider).valueOrNull ?? const [],
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Adicionar análises',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (labAtivo != null && labAtivo.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Mesmo laboratório: $labAtivo',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecond,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                  ),
                  child: candidatas.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Nenhuma análise para os filtros atuais.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecond,
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: candidatas.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final analise = candidatas[index];
                            final id = analise.id;
                            final jaSelecionado =
                                widget.selecionados.contains(id);
                            final lab = analise.laboratorio.trim();
                            final labBloqueado = labAtivo != null &&
                                labAtivo.isNotEmpty &&
                                !jaSelecionado &&
                                lab != labAtivo;
                            final prof = normalizarProfundidadeRecomendacao(
                              analise.profundidade,
                            );

                            return Opacity(
                              opacity: labBloqueado ? 0.4 : 1,
                              child: Material(
                                color: AppColors.bgPrimary,
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  key: Key('amostra_option_$id'),
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: labBloqueado
                                      ? null
                                      : () {
                                          final novos = List<String>.from(
                                            widget.selecionados,
                                          );
                                          if (jaSelecionado) {
                                            novos.remove(id);
                                          } else {
                                            novos.add(id);
                                          }
                                          widget.onChanged(novos);
                                          Navigator.of(context).pop();
                                        },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          jaSelecionado
                                              ? Icons.check_circle
                                              : labBloqueado
                                                  ? Icons.remove_circle_outline
                                                  : Icons
                                                      .radio_button_unchecked,
                                          size: 20,
                                          color: jaSelecionado
                                              ? AppColors.primary
                                              : AppColors.textTertiary,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            chipLabelAnalise(analise),
                                            style: AppTextStyles.body,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _DepthPill(label: prof),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final clienteState = ref.watch(clienteProvider);
    final clientes = clienteState.clientes;
    final clienteId = _clienteId;

    final doCliente = clienteId == null || clienteId.isEmpty
        ? const <AnaliseSolo>[]
        : ref.watch(analisesPorClienteProvider(clienteId));
    final candidatas = _candidatas(doCliente);

    final selecionadas = <AnaliseSolo>[];
    for (final id in widget.selecionados) {
      final match = doCliente.where((a) => a.id == id);
      if (match.isNotEmpty) {
        selecionadas.add(match.first);
      } else {
        final all = ref.watch(analiseNotifierProvider).valueOrNull ?? const [];
        final fallback = all.where((a) => a.id == id);
        if (fallback.isNotEmpty) selecionadas.add(fallback.first);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropdown<String>(
          key: const Key('dropdown_cliente_recomendacao'),
          label: 'Cliente',
          hint: clientes.isEmpty ? 'Nenhum cliente cadastrado' : 'Selecione',
          value: clienteId != null && clientes.any((c) => c.id == clienteId)
              ? clienteId
              : null,
          items: clientes
              .map(
                (c) => AppDropdownItem<String>(
                  value: c.id,
                  label: _clienteLabel(c),
                ),
              )
              .toList(growable: false),
          onChanged: clientes.isEmpty ? null : _onClienteChanged,
        ),
        const SizedBox(height: 10),
        Text(
          'Profundidade',
          style: AppTextStyles.label.copyWith(color: AppColors.textSecond),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            FilterChip(
              key: const Key('filtro_prof_0_20'),
              label: const Text('0-20'),
              selected: _filtro020,
              onSelected: (v) => setState(() => _filtro020 = v),
              selectedColor: AppColors.primary.withValues(alpha: 0.14),
              checkmarkColor: AppColors.primary,
              labelStyle: AppTextStyles.caption.copyWith(
                color: _filtro020 ? AppColors.primary : AppColors.textSecond,
                fontWeight: FontWeight.w600,
              ),
            ),
            FilterChip(
              key: const Key('filtro_prof_20_40'),
              label: const Text('20-40'),
              selected: _filtro2040,
              onSelected: (v) => setState(() => _filtro2040 = v),
              selectedColor: AppColors.primary.withValues(alpha: 0.14),
              checkmarkColor: AppColors.primary,
              labelStyle: AppTextStyles.caption.copyWith(
                color: _filtro2040 ? AppColors.primary : AppColors.textSecond,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Amostras selecionadas',
          style: AppTextStyles.label.copyWith(color: AppColors.textSecond),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...selecionadas.map((analise) {
              return InputChip(
                key: Key('chip_selecionada_${analise.id}'),
                label: Text(chipLabelAnalise(analise)),
                onDeleted: () {
                  final novos = List<String>.from(widget.selecionados)
                    ..remove(analise.id);
                  widget.onChanged(novos);
                },
                deleteIconColor: AppColors.textSecond,
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
                labelStyle: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
            }),
            ActionChip(
              key: const Key('btn_adicionar_amostra'),
              avatar: const Icon(
                CupertinoIcons.plus,
                size: 16,
                color: AppColors.primary,
              ),
              label: const Text('Adicionar'),
              onPressed: clienteId == null || clienteId.isEmpty
                  ? null
                  : () => _abrirSheetAdicionar(candidatas),
              backgroundColor: AppColors.bgPrimary,
              side: const BorderSide(color: AppColors.border),
              labelStyle: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        if (clienteId == null || clienteId.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Selecione um cliente para listar as análises.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecond),
          ),
        ] else if (doCliente.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Nenhuma análise vinculada a este cliente.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecond),
          ),
        ] else if (candidatas.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Nenhuma análise nas profundidades filtradas.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecond),
          ),
        ],
      ],
    );
  }

  String _clienteLabel(ClienteEntity cliente) {
    final nome = cliente.nome.trim();
    return nome.isEmpty ? 'Cliente sem nome' : nome;
  }
}

class _DepthPill extends StatelessWidget {
  const _DepthPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF86868B),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
