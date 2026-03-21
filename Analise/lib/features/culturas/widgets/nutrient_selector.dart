import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/data/culturas_data.dart';
import 'package:soloforte/features/culturas/providers/culturas_provider.dart';

class NutrientSelector extends ConsumerWidget {
  const NutrientSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(culturasProvider).selectedNutrients;

    return GridView.count(
      crossAxisCount: 5,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      children: kNutrients.map((n) {
        final isSel = selected.contains(n.key);
        return GestureDetector(
          onTap: () => ref.read(culturasProvider.notifier).toggleNutrient(n.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSel ? n.color : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSel ? n.color : const Color(0xFFE5E5EA),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              n.key,
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: isSel ? Colors.white : const Color(0xFF86868B),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
