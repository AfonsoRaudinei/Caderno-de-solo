import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';

/// TextField estilizado iOS do SoloForte
class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.suffixIcon,
    this.prefixIcon,
    this.suffixText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.textInputAction,
    this.inputFormatters,
    this.autofocus = false,
    this.initialValue,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength; // padrão 7 para campos numéricos
  final int? maxLines;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? suffixText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final String? initialValue;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  bool _isFocused = false;
  bool _isObscured = false;
  late FocusNode _focusNode;
  TextEditingController? _internalController;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.controller == null) {
      _internalController =
          TextEditingController(text: widget.initialValue ?? '');
    }
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(covariant AppInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        _internalController?.dispose();
        _internalController = null;
      }
      if (widget.controller == null) {
        _internalController =
            TextEditingController(text: widget.initialValue ?? '');
      }
    }

    // Sincroniza initialValue quando o widget usa controller interno.
    // Evita sobrescrever enquanto o usuário está digitando.
    if (widget.controller == null && !_focusNode.hasFocus) {
      final nextText = widget.initialValue ?? '';
      if ((_internalController?.text ?? '') != nextText) {
        _internalController?.value = TextEditingValue(
          text: nextText,
          selection: TextSelection.collapsed(offset: nextText.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.label.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isFocused && !hasError
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller ?? _internalController,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: _isObscured,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            autofillHints: widget.autofillHints,
            inputFormatters: _buildFormatters(),
            style: AppTextStyles.input.copyWith(
              color: widget.enabled
                  ? palette.textPrimary
                  : palette.textSecondary,
            ),
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.input.copyWith(
                color: palette.textTertiary,
              ),
              counterText: '',
              filled: true,
              fillColor: widget.enabled ? palette.inputFill : palette.cardStrong,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              suffixText: widget.suffixText,
              suffixStyle:
                  AppTextStyles.caption.copyWith(color: palette.textSecondary),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      onPressed: () =>
                          setState(() => _isObscured = !_isObscured),
                      icon: Icon(
                        _isObscured
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: palette.textSecondary,
                        size: 20,
                      ),
                    )
                  : widget.suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : palette.borderStrong,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.primary,
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: palette.border),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.error, width: 1.5),
              ),
              // Sem errorText aqui — exibimos manualmente abaixo para controle total
              errorText: null,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(widget.errorText!, style: AppTextStyles.error),
        ],
      ],
    );
  }

  List<TextInputFormatter> _buildFormatters() {
    final formatters = <TextInputFormatter>[
      ...?widget.inputFormatters,
    ];
    if (widget.maxLength != null &&
        (widget.keyboardType == TextInputType.number ||
            widget.keyboardType ==
                const TextInputType.numberWithOptions(decimal: true))) {
      formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));
    }
    return formatters;
  }
}

/// Input numérico com validação de 7 dígitos — atalho configurado
class AppInputNumerico extends StatelessWidget {
  const AppInputNumerico({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.suffixText,
    this.errorText,
    this.onChanged,
    this.enabled = true,
    this.maxLength = 7,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? suffixText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return AppInput(
      label: label,
      hint: hint ?? '0,00',
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      maxLength: maxLength,
      suffixText: suffixText,
      errorText: errorText,
      onChanged: onChanged,
      enabled: enabled,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
        LengthLimitingTextInputFormatter(maxLength),
      ],
    );
  }
}

/// TextArea — input de múltiplas linhas
class AppTextArea extends StatelessWidget {
  const AppTextArea({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 6,
    this.enabled = true,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final int? minLines;
  final int? maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppInput(
      label: label,
      hint: hint,
      controller: controller,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      errorText: errorText,
      onChanged: onChanged,
      enabled: enabled,
      textInputAction: TextInputAction.newline,
    );
  }
}
