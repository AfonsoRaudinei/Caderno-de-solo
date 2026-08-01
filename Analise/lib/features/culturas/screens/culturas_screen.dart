import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/data/culturas_data.dart';
import 'package:soloforte/features/culturas/providers/culturas_provider.dart';
import 'package:soloforte/features/culturas/widgets/nutrient_selector.dart';
import 'package:soloforte/features/culturas/widgets/result_card.dart';
import 'package:soloforte/features/culturas/widgets/source_dropdown.dart';
import 'package:soloforte/features/culturas/widgets/source_type_pills.dart';

class CulturasScreen extends ConsumerWidget {
  const CulturasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(culturasProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Culturas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSurface(
              borderRadius: AppDimens.radiusXl,
              child: Row(
                children: [
                  const AppIconFrame(
                    icon: Icons.grass_rounded,
                    size: 48,
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Base de culturas',
                          style: AppTextStyles.headline,
                        ),
                        const SizedBox(height: AppDimens.xs),
                        Text(
                          'Consulte extração, exportação e relações percentuais por fonte técnica.',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.xl),
            const _SectionLabel('Tipo de fonte'),
            const SizedBox(height: AppDimens.sm),
            const SourceTypePills(),
            const SizedBox(height: AppDimens.xl),
            if (state.sourceType != null) ...[
              _SectionLabel(_dropdownLabel(state.sourceType!)),
              const SizedBox(height: AppDimens.sm),
              const SourceDropdown(),
              const SizedBox(height: AppDimens.xl),
            ],
            if (state.selectedSource != null) ...[
              const _SectionLabel('Nutrientes (até 3)'),
              const SizedBox(height: AppDimens.sm),
              const NutrientSelector(),
              const SizedBox(height: AppDimens.xl),
              const ResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  String _dropdownLabel(SourceType type) => switch (type) {
        SourceType.autor => 'Selecionar Autor',
        SourceType.cultivar => 'Selecionar Cultivar',
        SourceType.tecnologia => 'Selecionar Tecnologia',
      };
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppTextStyles.sectionLabel.copyWith(
          color: AppColors.textSecond,
          fontWeight: FontWeight.w700,
        ),
      );
}
