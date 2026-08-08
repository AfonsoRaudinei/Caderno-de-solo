import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/data/culturas_data.dart';
import 'package:soloforte/features/culturas/providers/culturas_provider.dart';

class SourceTypePills extends ConsumerWidget {
  const SourceTypePills({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.appPalette;
    final current = ref.watch(culturasProvider).sourceType;

    return Row(
      children: SourceType.values.map((type) {
        final isSelected = current == type;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type != SourceType.tecnologia ? AppDimens.sm : 0,
            ),
            child: InkWell(
              onTap: () =>
                  ref.read(culturasProvider.notifier).setSourceType(type),
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 46,
                decoration: BoxDecoration(
                  color: isSelected
                      ? palette.accent.withValues(alpha: 0.09)
                      : palette.card,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  border: Border.all(
                    color: isSelected ? palette.accent : palette.border,
                    width: isSelected ? 1.2 : 0.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _iconFor(type),
                      size: 17,
                      color:
                          isSelected ? palette.accent : palette.textSecondary,
                    ),
                    const SizedBox(width: AppDimens.xs),
                    Text(
                      _labelFor(type),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color:
                            isSelected ? palette.accent : palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconFor(SourceType t) => switch (t) {
        SourceType.autor => Icons.people_outline,
        SourceType.cultivar => Icons.grass_outlined,
        SourceType.tecnologia => Icons.wb_sunny_outlined,
      };

  String _labelFor(SourceType t) => switch (t) {
        SourceType.autor => 'Autor',
        SourceType.cultivar => 'Cultivar',
        SourceType.tecnologia => 'Tecnologia',
      };
}
