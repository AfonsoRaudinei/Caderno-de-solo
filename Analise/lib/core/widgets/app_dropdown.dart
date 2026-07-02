import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';

/// DropdownButton estilizado iOS — usar para seleções com 3+ opções
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.borderRadius = 14,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
  });

  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.label.copyWith(color: palette.textSecondary),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: enabled ? palette.inputFill : palette.cardStrong,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: hasError ? AppColors.error : palette.border,
            ),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: contentPadding,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: palette.textSecondary,
                size: 20,
              ),
              style: AppTextStyles.body.copyWith(color: palette.textPrimary),
              dropdownColor: palette.cardStrong,
              borderRadius: BorderRadius.circular(12),
              hint: hint != null
                  ? Text(
                      hint!,
                      style: AppTextStyles.body.copyWith(
                        color: palette.textTertiary,
                      ),
                    )
                  : null,
              onChanged: enabled ? onChanged : null,
              items: items
                  .map((item) => DropdownMenuItem<T>(
                        value: item.value,
                        child: Text(
                          item.label,
                          style: AppTextStyles.body.copyWith(
                            color: palette.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(errorText!, style: AppTextStyles.error),
        ],
      ],
    );
  }
}

/// Item de um AppDropdown
class AppDropdownItem<T> {
  const AppDropdownItem({required this.value, required this.label});

  final T value;
  final String label;
}

// ─── LISTAS UTILITÁRIAS ──────────────────────────────────────────────────────

/// 27 estados brasileiros para dropdown
final List<AppDropdownItem<String>> estadosBrasileiros = [
  const AppDropdownItem(value: 'AC', label: 'Acre'),
  const AppDropdownItem(value: 'AL', label: 'Alagoas'),
  const AppDropdownItem(value: 'AP', label: 'Amapá'),
  const AppDropdownItem(value: 'AM', label: 'Amazonas'),
  const AppDropdownItem(value: 'BA', label: 'Bahia'),
  const AppDropdownItem(value: 'CE', label: 'Ceará'),
  const AppDropdownItem(value: 'DF', label: 'Distrito Federal'),
  const AppDropdownItem(value: 'ES', label: 'Espírito Santo'),
  const AppDropdownItem(value: 'GO', label: 'Goiás'),
  const AppDropdownItem(value: 'MA', label: 'Maranhão'),
  const AppDropdownItem(value: 'MT', label: 'Mato Grosso'),
  const AppDropdownItem(value: 'MS', label: 'Mato Grosso do Sul'),
  const AppDropdownItem(value: 'MG', label: 'Minas Gerais'),
  const AppDropdownItem(value: 'PA', label: 'Pará'),
  const AppDropdownItem(value: 'PB', label: 'Paraíba'),
  const AppDropdownItem(value: 'PR', label: 'Paraná'),
  const AppDropdownItem(value: 'PE', label: 'Pernambuco'),
  const AppDropdownItem(value: 'PI', label: 'Piauí'),
  const AppDropdownItem(value: 'RJ', label: 'Rio de Janeiro'),
  const AppDropdownItem(value: 'RN', label: 'Rio Grande do Norte'),
  const AppDropdownItem(value: 'RS', label: 'Rio Grande do Sul'),
  const AppDropdownItem(value: 'RO', label: 'Rondônia'),
  const AppDropdownItem(value: 'RR', label: 'Roraima'),
  const AppDropdownItem(value: 'SC', label: 'Santa Catarina'),
  const AppDropdownItem(value: 'SP', label: 'São Paulo'),
  const AppDropdownItem(value: 'SE', label: 'Sergipe'),
  const AppDropdownItem(value: 'TO', label: 'Tocantins'),
];

/// Culturas agrícolas mais comuns
final List<AppDropdownItem<String>> culturas = [
  const AppDropdownItem(value: 'Soja', label: 'Soja'),
  const AppDropdownItem(value: 'Milho', label: 'Milho'),
  const AppDropdownItem(value: 'Algodão', label: 'Algodão'),
  const AppDropdownItem(value: 'Cana', label: 'Cana-de-açúcar'),
  const AppDropdownItem(value: 'Café', label: 'Café'),
  const AppDropdownItem(value: 'Pastagem', label: 'Pastagem'),
  const AppDropdownItem(value: 'Trigo', label: 'Trigo'),
  const AppDropdownItem(value: 'Arroz', label: 'Arroz'),
  const AppDropdownItem(value: 'Feijão', label: 'Feijão'),
  const AppDropdownItem(value: 'Outro', label: 'Outro'),
];

/// Perfis de usuário
final List<AppDropdownItem<String>> perfisUsuario = [
  const AppDropdownItem(value: 'Agrônomo', label: 'Agrônomo'),
  const AppDropdownItem(value: 'Produtor', label: 'Produtor'),
  const AppDropdownItem(value: 'Técnico', label: 'Técnico Agrícola'),
  const AppDropdownItem(value: 'Consultor', label: 'Consultor'),
  const AppDropdownItem(value: 'Administrador', label: 'Administrador'),
];

/// Profundidades de coleta
final List<AppDropdownItem<String>> profundidades = [
  const AppDropdownItem(value: '0-20cm', label: '0-20 cm'),
  const AppDropdownItem(value: '0-40cm', label: '0-40 cm'),
];
