import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';

class CalibracaoHeaderCard extends StatefulWidget {
  const CalibracaoHeaderCard({
    super.key,
    required this.draftKey,
    required this.nome,
    required this.safra,
    required this.cliente,
    required this.culturas,
    required this.culturaSelecionada,
    required this.onNomeChanged,
    required this.onCulturaChanged,
    required this.onSafraChanged,
    required this.onClienteChanged,
    this.produtividadeEsperadaTha,
    this.onProdutividadeChanged,
  });

  final String draftKey;
  final String nome;
  final String safra;
  final String cliente;
  final List<AppDropdownItem<String>> culturas;
  final String? culturaSelecionada;
  final ValueChanged<String> onNomeChanged;
  final ValueChanged<String?> onCulturaChanged;
  final ValueChanged<String> onSafraChanged;
  final ValueChanged<String> onClienteChanged;

  /// Produtividade persistida sempre em t/ha. Null = não configurado.
  final double? produtividadeEsperadaTha;

  /// Callback com o valor em t/ha (null = campo limpo).
  final ValueChanged<double?>? onProdutividadeChanged;

  @override
  State<CalibracaoHeaderCard> createState() => _CalibracaoHeaderCardState();
}

class _CalibracaoHeaderCardState extends State<CalibracaoHeaderCard> {
  // 1 tonelada = 16.667 sacas (saco = 60 kg de soja)
  static const double _sacasPorTon = 16.667;

  /// Toggle session-only: não persiste. Padrão = Sacas/ha.
  bool _emSacas = true;

  late TextEditingController _prodCtrl;

  // ── helpers ──────────────────────────────────────────────────────────────

  String _textoInicial(double? tHa) {
    if (tHa == null || tHa <= 0) return '';
    if (_emSacas) {
      return (tHa * _sacasPorTon).toStringAsFixed(0);
    } else {
      return tHa.toStringAsFixed(1);
    }
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
    } else {
      return '≈ ${(tHa * _sacasPorTon).toStringAsFixed(0)} sc/ha';
    }
  }

  // ── lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _prodCtrl = TextEditingController(
      text: _textoInicial(widget.produtividadeEsperadaTha),
    );
  }

  @override
  void didUpdateWidget(covariant CalibracaoHeaderCard old) {
    super.didUpdateWidget(old);
    // Atualiza campo apenas quando o perfil selecionado muda externamente.
    if (old.produtividadeEsperadaTha != widget.produtividadeEsperadaTha) {
      _prodCtrl.text = _textoInicial(widget.produtividadeEsperadaTha);
    }
  }

  @override
  void dispose() {
    _prodCtrl.dispose();
    super.dispose();
  }

  // ── callbacks ─────────────────────────────────────────────────────────────

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
  }

  void _onProdChanged(String _) {
    setState(() {}); // reconstrói label de equivalência
    widget.onProdutividadeChanged?.call(_valorEmTha);
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimens.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInput(
            key: ValueKey('nome-${widget.draftKey}'),
            label: 'Nome',
            initialValue: widget.nome,
            onChanged: widget.onNomeChanged,
          ),
          const SizedBox(height: AppDimens.md),
          AppDropdown<String>(
            label: 'Cultura',
            value: widget.culturaSelecionada,
            items: widget.culturas,
            onChanged: widget.onCulturaChanged,
          ),
          const SizedBox(height: AppDimens.md),
          AppInput(
            key: ValueKey('safra-${widget.draftKey}'),
            label: 'Safra',
            hint: 'Ex.: 2026/2027',
            initialValue: widget.safra,
            onChanged: widget.onSafraChanged,
          ),
          const SizedBox(height: AppDimens.md),
          AppInput(
            key: ValueKey('cliente-${widget.draftKey}'),
            label: 'Cliente',
            initialValue: widget.cliente,
            onChanged: widget.onClienteChanged,
          ),
          const SizedBox(height: AppDimens.md),
          _buildProdutividadeSection(),
        ],
      ),
    );
  }

  Widget _buildProdutividadeSection() {
    final equiv = _equivalenciaLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label da seção
        Text('Produtividade Esperada', style: AppTextStyles.label),
        const SizedBox(height: 8),

        // ── Toggle Sacas/ha | t/ha
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggleBtn(label: 'Sacas/ha', selected: _emSacas,
                onTap: () => _onToggleUnidade(true), isLeft: true),
            _buildToggleBtn(label: 't/ha', selected: !_emSacas,
                onTap: () => _onToggleUnidade(false), isLeft: false),
          ],
        ),
        const SizedBox(height: 8),

        // ── Campo numérico
        AppInput(
          controller: _prodCtrl,
          hint: _emSacas ? 'Ex.: 70' : 'Ex.: 4.2',
          maxLength: 7,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
          ],
          onChanged: _onProdChanged,
        ),

        // ── Label de equivalência
        if (equiv.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            equiv,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecond,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.borderSoft,
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
            color: selected ? Colors.white : AppColors.textSecond,
          ),
        ),
      ),
    );
  }
}

