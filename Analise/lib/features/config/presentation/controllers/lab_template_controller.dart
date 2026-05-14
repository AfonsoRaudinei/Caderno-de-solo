import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/data/datasources/lab_template_datasource.dart';
import 'package:soloforte/data/repositories/lab_template_repository.dart';
import 'package:soloforte/domain/entities/lab_template.dart';

// ─────────────────────────────────────────────
// Providers de infraestrutura
// ─────────────────────────────────────────────

final labTemplateDatasourceProvider = Provider<LabTemplateDatasource>((ref) {
  return LabTemplateDatasource();
});

final labTemplateRepositoryProvider = Provider<LabTemplateRepository>((ref) {
  return LabTemplateRepository(ref.read(labTemplateDatasourceProvider));
});

// ─────────────────────────────────────────────
// Estado do controller
// ─────────────────────────────────────────────

class LabTemplatesState {
  final List<LabTemplate> templates;
  final bool isLoading;
  final String? error;

  const LabTemplatesState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
  });

  LabTemplatesState copyWith({
    List<LabTemplate>? templates,
    bool? isLoading,
    String? error,
  }) {
    return LabTemplatesState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────

class LabTemplatesNotifier extends StateNotifier<LabTemplatesState> {
  final LabTemplateRepository _repository;

  LabTemplatesNotifier(this._repository) : super(const LabTemplatesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final templates = await _repository.getAll();
      // Ordena: padrões primeiro, depois alfabético
      templates.sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return a.nome.compareTo(b.nome);
      });
      state = state.copyWith(templates: templates, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar templates: $e',
      );
    }
  }

  Future<void> save(LabTemplate template) async {
    try {
      await _repository.save(template);
      await load();
    } catch (e) {
      state = state.copyWith(error: 'Erro ao salvar template: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repository.delete(id);
      await load();
    } catch (e) {
      state = state.copyWith(error: 'Erro ao excluir template: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ─────────────────────────────────────────────
// Provider público
// ─────────────────────────────────────────────

final labTemplatesProvider =
    StateNotifierProvider<LabTemplatesNotifier, LabTemplatesState>((ref) {
  return LabTemplatesNotifier(ref.read(labTemplateRepositoryProvider));
});
