import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/domain/entities/micronutrientes_calibracao.dart';
import 'package:soloforte/features/laboratorio/application/providers/calibracao_controller.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/calibracao_status_badge.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/micronutrientes_elemento_card.dart';

/// Cadastro de parâmetros agronômicos de micronutrientes.
///
/// Não realiza cálculo de recomendação — apenas persiste grupos, elementos e
/// referências para uso posterior pelo módulo de cálculo.
class MicronutrientesCard extends ConsumerStatefulWidget {
  const MicronutrientesCard({
    super.key,
    required this.draftKey,
    required this.micros,
    required this.elementos,
    required this.grupos,
    required this.isExpanded,
    required this.onToggle,
    required this.onChanged,
  });

  static const title = 'Micronutrientes';
  static const Color accentColor = AppColors.micronut;

  final String draftKey;
  final Map<String, dynamic> micros;
  final Map<String, dynamic> elementos;
  final List<Map<String, dynamic>> grupos;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  ConsumerState<MicronutrientesCard> createState() =>
      _MicronutrientesCardState();
}

class _MicronutrientesCardState extends ConsumerState<MicronutrientesCard> {
  static const Duration _animDuration = Duration(milliseconds: 250);

  final GlobalKey _cardKey = GlobalKey();

  @override
  void didUpdateWidget(covariant MicronutrientesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isExpanded && widget.isExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _cardKey.currentContext;
        if (context != null && context.mounted) {
          Scrollable.ensureVisible(
            context,
            duration: _animDuration,
            curve: Curves.easeInOut,
            alignment: 0,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shadowColor = context.appPalette.shadow;
    final grupos = widget.grupos;
    final selecionados = elementosSelecionadosNosGrupos(grupos).toList()
      ..sort((a, b) => kElementosMicros.indexOf(a).compareTo(
            kElementosMicros.indexOf(b),
          ));

    return Container(
      key: _cardKey,
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.lg,
                  vertical: 14,
                ),
                child: _buildHeader(grupos, selecionados),
              ),
            ),
            AnimatedSize(
              duration: _animDuration,
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.hardEdge,
              child: widget.isExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.lg,
                        AppDimens.sm,
                        AppDimens.lg,
                        AppDimens.lg,
                      ),
                      child: _buildConteudo(grupos, selecionados),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    List<Map<String, dynamic>> grupos,
    List<String> selecionados,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: MicronutrientesCard.accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                MicronutrientesCard.title,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: widget.isExpanded
                    ? const SizedBox.shrink()
                    : Column(
                        key: const ValueKey('micronutrientes-resumo'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildSummaryWidgets(
                          _collapsedSummaryLines(grupos, selecionados),
                        ),
                      ),
              ),
            ],
          ),
        ),
        _buildChevron(onTap: widget.onToggle),
      ],
    );
  }

  List<String> _collapsedSummaryLines(
    List<Map<String, dynamic>> grupos,
    List<String> selecionados,
  ) {
    return [
      if (grupos.isEmpty) 'Nenhum grupo criado' else _grupoResumo(grupos),
      if (selecionados.isNotEmpty) selecionados.join(' · '),
    ];
  }

  String _grupoResumo(List<Map<String, dynamic>> grupos) {
    if (grupos.length == 1) {
      final grupo = grupos.first;
      final nome = grupo['nome']?.toString().trim() ?? '';
      final via = (grupo['viasAplicacaoGrupo'] as List?)?.join('/') ??
          grupo['via']?.toString() ??
          '';
      final detalhe = [nome, via].where((v) => v.isNotEmpty).join(' · ');
      return detalhe.isEmpty ? '1 grupo' : '1 grupo: $detalhe';
    }
    return '${grupos.length} grupos';
  }

  List<Widget> _buildSummaryWidgets(List<String> lines) {
    final captionStyle = AppTextStyles.caption.copyWith(
      color: AppColors.textSecond,
    );
    return [
      for (final line in lines) ...[
        const SizedBox(height: 2),
        Text(
          line,
          style: captionStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ];
  }

  Widget _buildChevron({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedRotation(
        turns: widget.isExpanded ? 0.5 : 0.0,
        duration: _animDuration,
        curve: Curves.easeInOut,
        child: const Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.textSecond,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildConteudo(
    List<Map<String, dynamic>> grupos,
    List<String> selecionados,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () {
              final atualizado = normalizarMicros({...widget.micros});
              final novosGrupos = [
                ...grupos,
                novoGrupoMicros(indice: grupos.length + 1),
              ];
              atualizado['grupos'] = novosGrupos;
              widget.onChanged(atualizado);
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Criar Grupo de Aplicação'),
          ),
        ),
        const SizedBox(height: 10),
        if (grupos.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: CalibracaoStatusBadge(
              icon: Icons.info_outline,
              color: AppColors.textSecond,
              label: 'Nenhum grupo de aplicação criado ainda.',
            ),
          ),
        ...grupos.asMap().entries.map(
              (entry) => _buildGrupoCard(
                index: entry.key,
                grupo: entry.value,
                grupos: grupos,
              ),
            ),
        if (selecionados.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Text('Parâmetros por elemento', style: AppTextStyles.label),
          const SizedBox(height: 8),
          ...selecionados.map((simbolo) {
            final elemento = normalizarElementoMicros(
              simbolo,
              _asMap(widget.elementos[simbolo]),
            );
            return MicronutrientesElementoCard(
              key: ValueKey('${widget.draftKey}-elemento-$simbolo'),
              draftKey: widget.draftKey,
              simbolo: simbolo,
              elemento: elemento,
              onChanged: (patch) => _updateElemento(simbolo, patch),
            );
          }),
        ] else if (grupos.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: CalibracaoStatusBadge(
              icon: Icons.touch_app_outlined,
              color: AppColors.textSecond,
              label:
                  'Selecione elementos nos grupos para cadastrar parâmetros.',
            ),
          ),
      ],
    );
  }

  Widget _buildGrupoCard({
    required int index,
    required Map<String, dynamic> grupo,
    required List<Map<String, dynamic>> grupos,
  }) {
    final nome = grupo['nome']?.toString() ?? 'Grupo ${index + 1}';
    final viasGrupo = List<String>.from(
      (grupo['viasAplicacaoGrupo'] as List?)?.map((e) => e.toString()) ??
          [_string(grupo['via'], fallback: 'Foliar')],
    );
    final elementosGrupo = List<String>.from(
      (grupo['elementos'] as List?)?.map((e) => e.toString()) ?? const [],
    );
    final referenciaTecnica = _string(
      grupo['referenciaTecnica'] ?? grupo['referenciaNome'],
      fallback: kReferenciasNivelCritico.first,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.bgSecondary,
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppInput(
                    key: ValueKey('${widget.draftKey}-grupo-nome-$index'),
                    label: 'Nome do grupo',
                    initialValue: nome,
                    onChanged: (value) => _updateGrupo(
                      index: index,
                      grupos: grupos,
                      patch: {'nome': value},
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () {
                    final atualizado = normalizarMicros({...widget.micros});
                    final novosGrupos = [...grupos]..removeAt(index);
                    atualizado['grupos'] = novosGrupos;
                    widget.onChanged(atualizado);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppDropdown<String>(
              label: 'Extrator',
              value: _safeValue(
                kExtratoresGrupo,
                _string(grupo['extrator'], fallback: 'DTPA-TEA'),
              ),
              items: kExtratoresGrupo
                  .map((item) => AppDropdownItem(value: item, label: item))
                  .toList(),
              onChanged: (value) => _updateGrupo(
                index: index,
                grupos: grupos,
                patch: {'extrator': value ?? 'DTPA-TEA'},
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Via de aplicação do grupo',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecond,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            _ViaToggleGroup(
              selecionadas: viasGrupo,
              opcoes: kViasAplicacaoMicros,
              onChanged: (value) => _updateGrupo(
                index: index,
                grupos: grupos,
                patch: {
                  'viasAplicacaoGrupo': value,
                  'via': value.first,
                },
              ),
            ),
            const SizedBox(height: 8),
            AppInput(
              key: ValueKey('${widget.draftKey}-grupo-fonte-$index'),
              label: 'Fonte',
              initialValue: _string(grupo['fonte'] ?? grupo['produto']),
              onChanged: (value) => _updateGrupo(
                index: index,
                grupos: grupos,
                patch: {'fonte': value, 'produto': value},
              ),
            ),
            const SizedBox(height: 8),
            if (viasGrupo.contains('Solo'))
              _buildNumericInput(
                keyValue: '${widget.draftKey}-grupo-ef-solo-$index',
                label: 'Eficiência solo (%)',
                value: _num(grupo['eficienciaSoloGrupo'], fallback: 30),
                onChanged: (value) => _updateGrupo(
                  index: index,
                  grupos: grupos,
                  patch: {'eficienciaSoloGrupo': value},
                ),
              ),
            if (viasGrupo.contains('Solo')) const SizedBox(height: 8),
            if (viasGrupo.contains('Foliar'))
              _buildNumericInput(
                keyValue: '${widget.draftKey}-grupo-ef-foliar-$index',
                label: 'Eficiência foliar (%)',
                value: _num(
                  grupo['eficienciaFoliarGrupo'] ?? grupo['eficiencia'],
                  fallback: 70,
                ),
                onChanged: (value) => _updateGrupo(
                  index: index,
                  grupos: grupos,
                  patch: {
                    'eficienciaFoliarGrupo': value,
                    'eficiencia': value,
                  },
                ),
              ),
            if (viasGrupo.contains('Foliar')) const SizedBox(height: 8),
            if (viasGrupo.contains('TS'))
              _buildNumericInput(
                keyValue: '${widget.draftKey}-grupo-ef-ts-$index',
                label: 'Eficiência TS (%)',
                value: _num(grupo['eficienciaTsGrupo'], fallback: 80),
                onChanged: (value) => _updateGrupo(
                  index: index,
                  grupos: grupos,
                  patch: {'eficienciaTsGrupo': value},
                ),
              ),
            if (viasGrupo.contains('TS')) const SizedBox(height: 8),
            AppDropdown<String>(
              label: 'Referência técnica do grupo',
              value: _safeValue(kReferenciasNivelCritico, referenciaTecnica),
              items: kReferenciasNivelCritico
                  .map((item) => AppDropdownItem(value: item, label: item))
                  .toList(),
              onChanged: (value) {
                final referencia = value ?? kReferenciasNivelCritico.first;
                _updateGrupo(
                  index: index,
                  grupos: grupos,
                  patch: {
                    'referenciaTecnica': referencia,
                    'referenciaNome': referencia,
                  },
                );
                ref
                    .read(calibracaoControllerProvider.notifier)
                    .propagarNcParaGrupo(
                      grupoIndex: index,
                      referenciaNome: referencia,
                    );
              },
            ),
            const SizedBox(height: 12),
            Text('Elementos deste grupo', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: kElementosMicros.map((simbolo) {
                final isSelected = elementosGrupo.contains(simbolo);
                return FilterChip(
                  label: Text(simbolo),
                  selected: isSelected,
                  selectedColor:
                      const Color(0xFF007AFF).withValues(alpha: 0.15),
                  checkmarkColor: const Color(0xFF007AFF),
                  backgroundColor: const Color(0xFFF2F2F7),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? const Color(0xFF007AFF)
                        : const Color(0xFF1D1D1F),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF007AFF)
                        : const Color(0xFFD1D1D6),
                  ),
                  onSelected: (selected) {
                    final atual = [...elementosGrupo];
                    if (selected) {
                      if (!atual.contains(simbolo)) atual.add(simbolo);
                    } else {
                      atual.remove(simbolo);
                    }
                    _updateGrupo(
                      index: index,
                      grupos: grupos,
                      patch: {'elementos': atual},
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _updateGrupo({
    required int index,
    required List<Map<String, dynamic>> grupos,
    required Map<String, dynamic> patch,
  }) {
    final atualizado = normalizarMicros({...widget.micros});
    final novosGrupos = [...grupos];
    novosGrupos[index] = normalizarGrupoMicros({
      ...novosGrupos[index],
      ...patch,
    });
    atualizado['grupos'] = novosGrupos;
    widget.onChanged(atualizado);
  }

  void _updateElemento(String simbolo, Map<String, dynamic> patch) {
    final atualizado = normalizarMicros({...widget.micros});
    final elementos = Map<String, dynamic>.from(
      atualizado['elementos'] as Map<String, dynamic>,
    );
    elementos[simbolo] = patch;
    atualizado['elementos'] = elementos;
    widget.onChanged(atualizado);
  }

  Widget _buildNumericInput({
    required String keyValue,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return AppInput(
      key: ValueKey(keyValue),
      label: label,
      initialValue: _fmt(value),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      maxLength: 7,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
        LengthLimitingTextInputFormatter(7),
      ],
      onChanged: (text) => onChanged(_parseDouble(text)),
    );
  }

  T? _safeValue<T>(List<T> options, T current) {
    if (options.contains(current)) return current;
    return options.isNotEmpty ? options.first : null;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  String _fmt(double value, {int decimals = 2}) {
    final fixed = value.toStringAsFixed(decimals);
    final normalized =
        fixed.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return normalized.replaceAll('.', ',');
  }

  double _parseDouble(String value) {
    return double.tryParse(value.replaceAll(',', '.').trim()) ?? 0;
  }

  double _num(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) return _parseDouble(value);
    return fallback;
  }

  String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}

class _ViaToggleGroup extends StatelessWidget {
  const _ViaToggleGroup({
    required this.selecionadas,
    required this.opcoes,
    required this.onChanged,
  });

  final List<String> selecionadas;
  final List<String> opcoes;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < opcoes.length; i++) ...[
          Expanded(child: _buildToggle(opcoes[i])),
          if (i < opcoes.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }

  Widget _buildToggle(String opcao) {
    final selected = selecionadas.contains(opcao);

    return GestureDetector(
      onTap: () {
        final nova = List<String>.from(selecionadas);
        if (nova.contains(opcao)) {
          nova.remove(opcao);
        } else {
          nova.add(opcao);
        }
        if (nova.isEmpty) return;
        onChanged(nova);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 36,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFAF52DE).withValues(alpha: 0.10)
              : const Color(0xFFE5E5E7),
          border: Border.all(
            color: selected ? const Color(0xFFAF52DE) : const Color(0xFFD1D1D6),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          opcao,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? const Color(0xFFAF52DE) : const Color(0xFF86868B),
          ),
        ),
      ),
    );
  }
}
