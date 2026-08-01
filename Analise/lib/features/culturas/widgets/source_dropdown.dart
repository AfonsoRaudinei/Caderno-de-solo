import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/features/culturas/providers/culturas_provider.dart';

class SourceDropdown extends ConsumerWidget {
  const SourceDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(sourcesListProvider);
    final selected = ref.watch(culturasProvider).selectedSource;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: selected != null ? AppColors.primary : AppColors.borderSoft,
          width: selected != null ? 1.2 : 0.8,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
            child: Text(
              'Escolher...',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecond,
          ),
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          items: sources
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    s,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) {
              ref.read(culturasProvider.notifier).setSelectedSource(v);
            }
          },
        ),
      ),
    );
  }
}
