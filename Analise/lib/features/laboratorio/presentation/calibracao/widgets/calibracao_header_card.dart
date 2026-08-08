import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/features/laboratorio/application/providers/calibracao_state.dart';

class CalibracaoHeaderCard extends StatefulWidget {
  const CalibracaoHeaderCard({
    super.key,
    required this.state,
    required this.isExpanded,
    required this.onToggle,
    required this.culturas,
    required this.onNomeChanged,
    required this.onCulturaChanged,
    required this.onSafraChanged,
    required this.onClienteChanged,
    required this.onProdutividadeChanged,
    required this.onUnidadeChanged,
  });

  final CalibracaoState state;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<AppDropdownItem<String>> culturas;
  final ValueChanged<String> onNomeChanged;
  final ValueChanged<String?> onCulturaChanged;
  final ValueChanged<String> onSafraChanged;
  final ValueChanged<String> onClienteChanged;
  final ValueChanged<double?> onProdutividadeChanged;
  final ValueChanged<String> onUnidadeChanged;

  @override
  State<CalibracaoHeaderCard> createState() => _CalibracaoHeaderCardState();
}

class _CalibracaoHeaderCardState extends State<CalibracaoHeaderCard> {
  static const double _sacasPorTon = 16.667;
  static const Duration _animDuration = Duration(milliseconds: 250);

  bool _emSacas = true;

  late TextEditingController _prodCtrl;
  final GlobalKey _cardKey = GlobalKey();

  CalibracaoState get _state => widget.state;
  CalibracaoProfile get _draft => _state.draft;

  String get _draftKey =>
      '${_draft.id}_${_draft.createdAt.microsecondsSinceEpoch}';

  String? get _culturaSelecionada {
    final cultura = _draft.cultura;
    final values = widget.culturas.map((item) => item.value).toList();
    if (values.isEmpty) return null;
    return values.contains(cultura) ? cultura : values.first;
  }

  String _textoInicial(double? tHa) {
    if (tHa == null || tHa <= 0) return '';
    if (_emSacas) {
      return (tHa * _sacasPorTon).toStringAsFixed(0);
    }
    return tHa.toStringAsFixed(1);
  }

  double? get _valorEmTha {
    final raw = _prodCtrl.text.replaceAll(',', '.');
    final parsed = double.tryParse(raw);
    if (parsed == null || parsed <= 0) return null;
    return _emSacas ? parsed / _sacasPorTon : parsed;
  }

  String get _equivalenciaLabel {
    final tHa = _valorEmTha;
    if (tHa == null) return '';
    if (_emSacas) {
      return '≈ ${tHa.toStringAsFixed(1)} t/ha';
    }
    return '≈ ${(tHa * _sacasPorTon).toStringAsFixed(0)} sc/ha';
  }

  String get _unidadeLabel => _emSacas ? 'Sacas/ha' : 't/ha';

  String? _produtividadeResumo(double? tHa) {
    if (tHa == null || tHa <= 0) return null;
    if (_emSacas) {
      return '${(tHa * _sacasPorTon).toStringAsFixed(0)} Sacas/ha';
    }
    return '${tHa.toStringAsFixed(1)} t/ha';
  }

  @override
  void initState() {
    super.initState();
    _prodCtrl = TextEditingController(
      text: _textoInicial(_draft.produtividadeEsperadaTha),
    );
  }

  @override
  void didUpdateWidget(covariant CalibracaoHeaderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.draft.produtividadeEsperadaTha !=
        widget.state.draft.produtividadeEsperadaTha) {
      _prodCtrl.text =
          _textoInicial(widget.state.draft.produtividadeEsperadaTha);
    }
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
  void dispose() {
    _prodCtrl.dispose();
    super.dispose();
  }

  void _onToggleUnidade(bool paraEmSacas) {
    if (_emSacas == paraEmSacas) return;
    final tHaAtual = _valorEmTha;
    setState(() {
      _emSacas = paraEmSacas;
      if (tHaAtual != null && tHaAtual > 0) {
        _prodCtrl.text = paraEmSacas
            ? (tHaAtual * _sacasPorTon).toStringAsFixed(0)
            : tHaAtual.toStringAsFixed(1);
      }
    });
    widget.onUnidadeChanged(_unidadeLabel);
  }

  void _onProdChanged(String _) {
    setState(() {});
    widget.onProdutividadeChanged(_valorEmTha);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final shadowColor = palette.shadow;

    return Container(
      key: _cardKey,
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: palette.border, width: 0.5),
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
            if (!widget.isExpanded)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onToggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.lg,
                    vertical: 14,
                  ),
                  child: _buildCollapsedContent(),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.xl,
                  AppDimens.md,
                  AppDimens.xl,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildChevron(onTap: widget.onToggle),
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
                        AppDimens.xl,
                        AppDimens.sm,
                        AppDimens.xl,
                        AppDimens.xl,
                      ),
                      child: _buildExpandedForm(),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedContent() {
    final palette = context.appPalette;
    final draft = _draft;
    final captionStyle = AppTextStyles.caption.copyWith(
      color: palette.textSecondary,
    );

    final culturaSafraParts = <String>[
      if (draft.cultura.trim().isNotEmpty) draft.cultura.trim(),
      if (draft.safra.trim().isNotEmpty) draft.safra.trim(),
    ];
    final prodResumo = _produtividadeResumo(draft.produtividadeEsperadaTha);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (draft.nome.trim().isNotEmpty)
              Expanded(
                child: Text(
                  draft.nome.trim(),
                  style: AppTextStyles.value,
                ),
              )
            else
              const Spacer(),
            _buildChevron(onTap: widget.onToggle),
          ],
        ),
        if (culturaSafraParts.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(culturaSafraParts.join(' · '), style: captionStyle),
        ],
        if (draft.cliente.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(draft.cliente.trim(), style: captionStyle),
        ],
        if (prodResumo != null) ...[
          const SizedBox(height: 4),
          Text('Produtividade: $prodResumo', style: captionStyle),
        ],
      ],
    );
  }

  Widget _buildChevron({required VoidCallback onTap}) {
    final palette = context.appPalette;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedRotation(
        turns: widget.isExpanded ? 0.5 : 0.0,
        duration: _animDuration,
        curve: Curves.easeInOut,
        child: Icon(
          Icons.keyboard_arrow_down,
          color: palette.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildExpandedForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppInput(
          key: ValueKey('nome-$_draftKey'),
          label: 'Nome',
          initialValue: _draft.nome,
          onChanged: widget.onNomeChanged,
        ),
        const SizedBox(height: AppDimens.md),
        AppDropdown<String>(
          label: 'Cultura',
          value: _culturaSelecionada,
          items: widget.culturas,
          onChanged: widget.onCulturaChanged,
        ),
        const SizedBox(height: AppDimens.md),
        AppInput(
          key: ValueKey('safra-$_draftKey'),
          label: 'Safra',
          hint: 'Ex.: 2026/2027',
          initialValue: _draft.safra,
          onChanged: widget.onSafraChanged,
        ),
        const SizedBox(height: AppDimens.md),
        AppInput(
          key: ValueKey('cliente-$_draftKey'),
          label: 'Cliente',
          initialValue: _draft.cliente,
          onChanged: widget.onClienteChanged,
        ),
        const SizedBox(height: AppDimens.md),
        _buildProdutividadeSection(),
      ],
    );
  }

  Widget _buildProdutividadeSection() {
    final palette = context.appPalette;
    final equiv = _equivalenciaLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Produtividade Esperada', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleBtn(
              label: 'Sacas/ha',
              selected: _emSacas,
              onTap: () => _onToggleUnidade(true),
              isLeft: true,
            ),
            _buildToggleBtn(
              label: 't/ha',
              selected: !_emSacas,
              onTap: () => _onToggleUnidade(false),
              isLeft: false,
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppInput(
          controller: _prodCtrl,
          hint: _emSacas ? 'Ex.: 70' : 'Ex.: 4.2',
          maxLength: 7,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
          ],
          onChanged: _onProdChanged,
        ),
        if (equiv.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            equiv,
            style: AppTextStyles.caption.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildToggleBtn({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    final palette = context.appPalette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? palette.accent : palette.surfaceAlt,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(8) : Radius.zero,
            right: isLeft ? Radius.zero : const Radius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : palette.textSecondary,
          ),
        ),
      ),
    );
  }
}
