import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/absorcao_nutrientes_data.dart';

/// Campo dropdown padronizado da tela de absorção de nutrientes.
/// Extraído de absorcao_nutrientes_referencia_page.dart (_buildDropdownField) — FASE 3.
class AbsorcaoDropdownField<T> extends StatelessWidget {
  const AbsorcaoDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labelBuilder,
  });

  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T value)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontSize: 13,
            color: AbsorcaoNutrientesCores.mutedText(isDark: palette.isDark),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          dropdownColor: palette.cardStrong,
          style: AppTextStyles.body.copyWith(
            fontSize: 14,
            color: palette.textPrimary,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    labelBuilder?.call(item) ?? item.toString(),
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AbsorcaoNutrientesCores.inputFill(isDark: palette.isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }
}
