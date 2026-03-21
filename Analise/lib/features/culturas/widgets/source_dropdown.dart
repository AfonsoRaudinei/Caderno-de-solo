import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/culturas/providers/culturas_provider.dart';

class SourceDropdown extends ConsumerWidget {
  const SourceDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources   = ref.watch(sourcesListProvider);
    final selected  = ref.watch(culturasProvider).selectedSource;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected != null ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          hint: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Escolher...', style: TextStyle(color: Color(0xFFC7C7CC), fontSize: 14)),
          ),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF86868B)),
          borderRadius: BorderRadius.circular(12),
          items: sources.map((s) => DropdownMenuItem(
            value: s,
            child: Text(s, style: const TextStyle(fontSize: 14, color: Color(0xFF1D1D1F))),
          )).toList(),
          onChanged: (v) {
            if (v != null) ref.read(culturasProvider.notifier).setSelectedSource(v);
          },
        ),
      ),
    );
  }
}
