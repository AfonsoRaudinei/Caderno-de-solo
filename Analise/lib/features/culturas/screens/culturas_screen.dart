import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/culturas/providers/culturas_provider.dart';
import 'package:soloforte/features/culturas/widgets/source_type_pills.dart';
import 'package:soloforte/features/culturas/widgets/source_dropdown.dart';
import 'package:soloforte/features/culturas/widgets/nutrient_selector.dart';
import 'package:soloforte/features/culturas/widgets/result_card.dart';
import 'package:soloforte/data/culturas_data.dart';

class CulturasScreen extends ConsumerWidget {
  const CulturasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(culturasProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text(
          'Culturas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1D1D1F)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Passo 1 — Tipo de fonte
            const _SectionLabel('Tipo de fonte'),
            const SizedBox(height: 8),
            const SourceTypePills(),
            const SizedBox(height: 20),

            // Passo 2 — Dropdown (aparece após tipo de fonte)
            if (state.sourceType != null) ...[
              _SectionLabel(_dropdownLabel(state.sourceType!)),
              const SizedBox(height: 8),
              const SourceDropdown(),
              const SizedBox(height: 20),
            ],

            // Passo 3 — Seletor de nutrientes (aparece após fonte selecionada)
            if (state.selectedSource != null) ...[
              const _SectionLabel('Nutrientes (até 3)'),
              const SizedBox(height: 8),
              const NutrientSelector(),
              const SizedBox(height: 20),
              const ResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  String _dropdownLabel(SourceType type) => switch (type) {
    SourceType.autor      => 'Selecionar Autor',
    SourceType.cultivar   => 'Selecionar Cultivar',
    SourceType.tecnologia => 'Selecionar Tecnologia',
  };
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 11, fontWeight: FontWeight.w600,
      color: Color(0xFF86868B), letterSpacing: 0.5,
    ),
  );
}
