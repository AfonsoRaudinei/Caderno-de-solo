import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/data/culturas_data.dart';
import 'package:soloforte/features/culturas/providers/culturas_provider.dart';

class NutrientSelector extends ConsumerWidget {
  const NutrientSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.appPalette;
    final selected = ref.watch(culturasProvider).selectedNutrients;

    return GridView.count(
      crossAxisCount: 5,
      crossAxisSpacing: AppDimens.sm,
      mainAxisSpacing: AppDimens.sm,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      children: kNutrients.map((n) {
        final isSel = selected.contains(n.key);
        return InkWell(
          onTap: () =>
              ref.read(culturasProvider.notifier).toggleNutrient(n.key),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSel
                  ? palette.accent
                  : Color(n.color).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(
                color: isSel
                    ? palette.accent
                    : palette.border.withValues(alpha: 0.9),
                width: isSel ? 1.2 : 0.8,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              n.key,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSel
                    ? Theme.of(context).colorScheme.onPrimary
                    : palette.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
