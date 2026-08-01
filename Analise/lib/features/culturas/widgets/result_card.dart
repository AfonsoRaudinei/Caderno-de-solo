import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/data/culturas_data.dart';
import 'package:soloforte/features/culturas/providers/culturas_provider.dart';

class ResultCard extends ConsumerWidget {
  const ResultCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(culturasProvider);
    final entry = ref.watch(currentEntryProvider);
    if (entry == null) return const SizedBox.shrink();

    final tagColor = switch (state.sourceType!) {
      SourceType.autor => AppColors.primary,
      SourceType.cultivar => AppColors.success,
      SourceType.tecnologia => AppColors.warning,
    };
    final tagLabel = switch (state.sourceType!) {
      SourceType.autor => 'Autor',
      SourceType.cultivar => 'Cultivar',
      SourceType.tecnologia => 'Tecnologia',
    };

    return AppSurface(
      borderRadius: AppDimens.radiusXl,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    state.selectedSource!,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  margin: const EdgeInsets.only(left: AppDimens.sm),
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                  ),
                  child: Text(
                    tagLabel,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: tagColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSoft),
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimens.lg,
              AppDimens.md,
              AppDimens.lg,
              0,
            ),
            child: _DataModeToggle(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.lg,
              AppDimens.md,
              AppDimens.lg,
              AppDimens.lg,
            ),
            child: state.dataMode == DataMode.percentual
                ? _PercentualBars(
                    entry: entry, nutrients: state.selectedNutrients)
                : _SingleBars(
                    entry: entry,
                    nutrients: state.selectedNutrients,
                    mode: state.dataMode),
          ),
        ],
      ),
    );
  }
}

class _DataModeToggle extends ConsumerWidget {
  const _DataModeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(culturasProvider).dataMode;
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: DataMode.values.map((m) {
          final isActive = mode == m;
          final label = switch (m) {
            DataMode.exportacao => 'Exportação',
            DataMode.extracao => 'Extração',
            DataMode.percentual => '%',
          };
          return Expanded(
            child: InkWell(
              onTap: () => ref.read(culturasProvider.notifier).setDataMode(m),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    color: isActive ? AppColors.primary : AppColors.textSecond,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleBars extends StatelessWidget {
  final SourceEntry entry;
  final List<String> nutrients;
  final DataMode mode;
  const _SingleBars({
    required this.entry,
    required this.nutrients,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final record =
        mode == DataMode.exportacao ? entry.exportacao : entry.extracao;
    return Column(
      children: nutrients.map((key) {
        final meta = kNutrients.firstWhere((n) => n.key == key);
        final value = record.get(key);
        final pct = (value / (kMaxValues[key] ?? 100)).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${meta.fullName} ($key)',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: value.toStringAsFixed(value < 10 ? 2 : 1),
                          style: AppTextStyles.label.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: ' ${meta.unit}',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: AppColors.textSecond,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pct),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    minHeight: 7,
                    backgroundColor: AppColors.bgSecondary,
                    valueColor: AlwaysStoppedAnimation(Color(meta.color)),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PercentualBars extends StatelessWidget {
  final SourceEntry entry;
  final List<String> nutrients;
  const _PercentualBars({required this.entry, required this.nutrients});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: const Row(
            children: [
              _LegendDot(
                  color: Color(0xFF34C759), label: 'Exp% = exp. ÷ extr.'),
              SizedBox(width: 12),
              _LegendDot(
                  color: Color(0xFF007AFF), label: 'Ext% = extr. ÷ exp.'),
            ],
          ),
        ),
        ...nutrients.map((key) {
          final meta = kNutrients.firstWhere((n) => n.key == key);
          final expV = entry.exportacao.get(key);
          final extV = entry.extracao.get(key);
          final expPct = extV > 0 ? (expV / extV * 100).round() : 0;
          final extPct = expV > 0 ? (extV / expV * 100).round() : 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${meta.fullName} ($key)',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                        '${expV.toStringAsFixed(1)} / ${extV.toStringAsFixed(1)} ${meta.unit}',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecond,
                        )),
                  ],
                ),
                const SizedBox(height: 6),
                _PctBarRow(
                  label: 'Exp%',
                  pct: expPct,
                  color: AppColors.success,
                ),
                const SizedBox(height: 4),
                _PctBarRow(
                  label: 'Ext%',
                  pct: extPct,
                  color: AppColors.primary,
                  capAt: 300,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _PctBarRow extends StatelessWidget {
  final String label;
  final int pct;
  final Color color;
  final int capAt;
  const _PctBarRow({
    required this.label,
    required this.pct,
    required this.color,
    this.capAt = 100,
  });

  @override
  Widget build(BuildContext context) {
    final barFraction = (pct / capAt).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 34,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: barFraction),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 7,
                backgroundColor: AppColors.bgSecondary,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 38,
          child: Text(
            '$pct%',
            textAlign: TextAlign.right,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              color: AppColors.textSecond,
            ),
          ),
        ],
      );
}
