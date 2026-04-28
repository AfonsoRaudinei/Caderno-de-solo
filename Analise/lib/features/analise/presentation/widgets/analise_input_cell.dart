import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soloforte/core/theme/app_colors.dart';

enum AnaliseCellType { numeric, text }

/// Célula de input editável na tabela de análise.
class AnaliseInputCell extends StatefulWidget {
  final double width;
  final double? height;
  final String? initialValue;
  final AnaliseCellType type;
  final ValueChanged<String>? onChanged;
  final bool isFirst; // remove borda esquerda se false
  final bool hasError;
  final bool hasWarning;
  final String? validationMessage;
  final bool highlightedByNavigator;

  const AnaliseInputCell({
    super.key,
    required this.width,
    this.height,
    this.initialValue,
    this.type = AnaliseCellType.numeric,
    this.onChanged,
    this.isFirst = false,
    this.hasError = false,
    this.hasWarning = false,
    this.validationMessage,
    this.highlightedByNavigator = false,
  });

  @override
  State<AnaliseInputCell> createState() => _AnaliseInputCellState();
}

class _AnaliseInputCellState extends State<AnaliseInputCell> {
  late TextEditingController _ctrl;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(AnaliseInputCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _ctrl.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<TextInputFormatter> get _formatters {
    if (widget.type == AnaliseCellType.numeric) {
      return [
        LengthLimitingTextInputFormatter(7),
        FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
      ];
    }
    return [LengthLimitingTextInputFormatter(40)];
  }

  @override
  Widget build(BuildContext context) {
    final text = _ctrl.text.trim();
    final isVazio = text.isEmpty || text == 'N/A' || text == 'null';
    final statusColor = widget.hasError
        ? AppColors.error
        : (widget.hasWarning ? const Color(0xFFD97706) : AppColors.border);
    final bgColor = widget.hasError
        ? const Color(0xFFFEF2F2)
        : (widget.hasWarning
            ? const Color(0xFFFFFBEB)
            : (_focused
                ? AppColors.primary.withValues(alpha: 0.08)
                : (isVazio
                    ? Colors.orange.withValues(alpha: 0.04)
                    : AppColors.bgPrimary)));
    final hintColor = widget.hasError
        ? AppColors.error
        : (widget.hasWarning
            ? const Color(0xFFD97706)
            : Colors.orange.withValues(alpha: 0.7));

    return Tooltip(
      message: widget.validationMessage ?? '',
      triggerMode: TooltipTriggerMode.longPress,
      child: Focus(
        onFocusChange: (focused) => setState(() => _focused = focused),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              left: const BorderSide(color: AppColors.border, width: 0.5),
              bottom: BorderSide(
                color: widget.highlightedByNavigator
                    ? AppColors.primary
                    : statusColor,
                width: (widget.hasError ||
                        widget.hasWarning ||
                        widget.highlightedByNavigator ||
                        _focused ||
                        isVazio)
                    ? 1.2
                    : 0.5,
              ),
            ),
          ),
          child: Stack(
            children: [
              TextField(
                controller: _ctrl,
                onChanged: (val) {
                  setState(() {}); // para atualizar o destaque de vazio
                  widget.onChanged?.call(val);
                },
                keyboardType: widget.type == AnaliseCellType.numeric
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.text,
                inputFormatters: _formatters,
                textAlign: widget.type == AnaliseCellType.numeric
                    ? TextAlign.center
                    : TextAlign.left,
                style: TextStyle(
                  fontSize: 13,
                  color: isVazio ? Colors.orange[900] : const Color(0xFF1D1D1F),
                  fontWeight: _focused
                      ? FontWeight.w600
                      : (isVazio ? FontWeight.w500 : FontWeight.w400),
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: isVazio ? 'Vazio' : null,
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  isDense: true,
                ),
              ),
              if (widget.hasError || widget.hasWarning)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Icon(
                    widget.hasError
                        ? Icons.error_outline
                        : Icons.warning_amber_outlined,
                    size: 12,
                    color: widget.hasError
                        ? AppColors.error
                        : const Color(0xFFD97706),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
