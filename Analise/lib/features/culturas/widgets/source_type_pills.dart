import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/data/culturas_data.dart';
import 'package:soloforte/features/culturas/providers/culturas_provider.dart';

class SourceTypePills extends ConsumerWidget {
  const SourceTypePills({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(culturasProvider).sourceType;

    return Row(
      children: SourceType.values.map((type) {
        final isSelected = current == type;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: type != SourceType.tecnologia ? 8 : 0),
            child: GestureDetector(
              onTap: () => ref.read(culturasProvider.notifier).setSourceType(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF0F6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFE5E5EA),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_iconFor(type), size: 16,
                      color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF86868B)),
                    const SizedBox(width: 6),
                    Text(_labelFor(type),
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF86868B),
                      )),
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
    SourceType.autor      => Icons.people_outline,
    SourceType.cultivar   => Icons.grass_outlined,
    SourceType.tecnologia => Icons.wb_sunny_outlined,
  };

  String _labelFor(SourceType t) => switch (t) {
    SourceType.autor      => 'Autor',
    SourceType.cultivar   => 'Cultivar',
    SourceType.tecnologia => 'Tecnologia',
  };
}
