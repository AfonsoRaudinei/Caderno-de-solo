import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/data/culturas_data.dart';

// ── Tipo de dado exibido ──────────────────────────────────────
// DataMode importado de culturas_data.dart

// ── Estado da tela ────────────────────────────────────────────
class CulturasState {
  final SourceType? sourceType;
  final String? selectedSource;
  final List<String> selectedNutrients;
  final DataMode dataMode;

  const CulturasState({
    this.sourceType,
    this.selectedSource,
    this.selectedNutrients = const ['N', 'P', 'K'],
    this.dataMode = DataMode.exportacao,
  });

  CulturasState copyWith({
    SourceType? sourceType,
    String? selectedSource,
    List<String>? selectedNutrients,
    DataMode? dataMode,
    bool clearSource = false,
  }) => CulturasState(
    sourceType:         sourceType ?? this.sourceType,
    selectedSource:     clearSource ? null : (selectedSource ?? this.selectedSource),
    selectedNutrients:  selectedNutrients ?? this.selectedNutrients,
    dataMode:           dataMode ?? this.dataMode,
  );
}

// ── Notifier ──────────────────────────────────────────────────
class CulturasNotifier extends StateNotifier<CulturasState> {
  CulturasNotifier() : super(const CulturasState());

  void setSourceType(SourceType type) {
    state = state.copyWith(sourceType: type, clearSource: true);
  }

  void setSelectedSource(String name) {
    state = state.copyWith(selectedSource: name);
  }

  void toggleNutrient(String key) {
    final current = List<String>.from(state.selectedNutrients);
    if (current.contains(key)) {
      if (current.length == 1) return; // mínimo 1
      current.remove(key);
    } else {
      if (current.length >= 3) current.removeAt(0); // máximo 3, FIFO
      current.add(key);
    }
    state = state.copyWith(selectedNutrients: current);
  }

  void setDataMode(DataMode mode) {
    state = state.copyWith(dataMode: mode);
  }
}

// ── Providers ─────────────────────────────────────────────────
final culturasProvider =
    StateNotifierProvider<CulturasNotifier, CulturasState>(
  (ref) => CulturasNotifier(),
);

// Retorna os nomes disponíveis para a fonte selecionada
final sourcesListProvider = Provider<List<String>>((ref) {
  final type = ref.watch(culturasProvider).sourceType;
  return switch (type) {
    SourceType.autor      => kAutores.keys.toList(),
    SourceType.tecnologia => kTecnologias.keys.toList(),
    SourceType.cultivar   => kCultivares.keys.toList(),
    null                  => [],
  };
});

// Retorna o SourceEntry da seleção atual (null se incompleto)
final currentEntryProvider = Provider<SourceEntry?>((ref) {
  final state = ref.watch(culturasProvider);
  if (state.sourceType == null || state.selectedSource == null) return null;
  return switch (state.sourceType!) {
    SourceType.autor      => kAutores[state.selectedSource],
    SourceType.tecnologia => kTecnologias[state.selectedSource],
    SourceType.cultivar   => kCultivares[state.selectedSource],
  };
});
