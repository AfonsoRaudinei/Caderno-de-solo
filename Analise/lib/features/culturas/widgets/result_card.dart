// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      SourceType.autor => const Color(0xFF007AFF),
      SourceType.cultivar => const Color(0xFF34C759),
      SourceType.tecnologia => const Color(0xFFFF9500),
    };
    final tagLabel = switch (state.sourceType!) {
      SourceType.autor => 'Autor',
      SourceType.cultivar => 'Cultivar',
      SourceType.tecnologia => 'Tecnologia',
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    state.selectedSource!,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D1D1F)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                      color: tagColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(tagLabel,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F5)),

          // Toggle 3 opções
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: _DataModeToggle(),
          ),

          // Barras
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
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

// ── Toggle ────────────────────────────────────────────────────
class _DataModeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(culturasProvider).dataMode;
    return Container(
      height: 34,
      decoration: BoxDecoration(
          color: const Color(0xFFF0F0F5),
          borderRadius: BorderRadius.circular(10)),
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
            child: GestureDetector(
              onTap: () => ref.read(culturasProvider.notifier).setDataMode(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 3,
                              offset: const Offset(0, 1))
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? const Color(0xFF1D1D1F)
                          : const Color(0xFF86868B),
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Barras simples (Exportação ou Extração) ───────────────────
class _SingleBars extends StatelessWidget {
  final SourceEntry entry;
  final List<String> nutrients;
  final DataMode mode;
  const _SingleBars(
      {required this.entry, required this.nutrients, required this.mode});

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
                  Text('${meta.fullName} ($key)',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1D1D1F))),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: value.toStringAsFixed(value < 10 ? 2 : 1),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D1D1F))),
                    TextSpan(
                        text: ' ${meta.unit}',
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF86868B))),
                  ])),
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
                    backgroundColor: const Color(0xFFF0F0F5),
                    valueColor: AlwaysStoppedAnimation(meta.color),
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

// ── Barras percentuais (Exp% e Ext% lado a lado) ─────────────
//
// Exp% = (Exportação ÷ Extração) × 100
//        → % do absorvido que saiu nos grãos
//
// Ext% = (Extração ÷ Exportação) × 100
//        → quanto a planta absorveu além do que exportou
//
class _PercentualBars extends StatelessWidget {
  final SourceEntry entry;
  final List<String> nutrients;
  const _PercentualBars({required this.entry, required this.nutrients});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Legenda
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(10),
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
        // Nutrientes
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
                    Text('${meta.fullName} ($key)',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1D1D1F))),
                    Text(
                        '${expV.toStringAsFixed(1)} / ${extV.toStringAsFixed(1)} ${meta.unit}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF86868B))),
                  ],
                ),
                const SizedBox(height: 6),
                _PctBarRow(
                    label: 'Exp%', pct: expPct, color: const Color(0xFF34C759)),
                const SizedBox(height: 4),
                _PctBarRow(
                    label: 'Ext%',
                    pct: extPct,
                    color: const Color(0xFF007AFF),
                    capAt: 300),
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
  const _PctBarRow(
      {required this.label,
      required this.pct,
      required this.color,
      this.capAt = 100});

  @override
  Widget build(BuildContext context) {
    final barFraction = (pct / capAt).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
            width: 34,
            child: Text(label,
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: color))),
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
                backgroundColor: const Color(0xFFF0F0F5),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ),
        SizedBox(
            width: 38,
            child: Text('$pct%',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: color))),
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
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF86868B))),
        ],
      );
}
