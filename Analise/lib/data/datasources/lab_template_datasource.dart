import 'package:hive_flutter/hive_flutter.dart';
import 'package:soloforte/domain/models/lab_template_model.dart';

class LabTemplateDatasource {
  static const String _boxName = 'lab_templates';

  Future<Box<Map>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<Map>(_boxName);
    }
    return Hive.openBox<Map>(_boxName);
  }

  /// Lista todos os templates
  Future<List<LabTemplateModel>> getAll() async {
    final box = await _getBox();
    return box.values
        .map((json) =>
            LabTemplateModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  /// Busca template por ID
  Future<LabTemplateModel?> getById(String id) async {
    final box = await _getBox();
    final json = box.get(id);
    if (json == null) return null;
    return LabTemplateModel.fromJson(Map<String, dynamic>.from(json));
  }

  /// Salva ou atualiza template
  Future<void> save(LabTemplateModel template) async {
    final box = await _getBox();
    await box.put(template.id, template.toJson());
  }

  /// Remove template
  Future<void> delete(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  /// Retorna o total de templates salvos
  Future<int> count() async {
    final box = await _getBox();
    return box.length;
  }

  /// Busca o primeiro template cujas keywords batem com o texto
  Future<LabTemplateModel?> findByText(String text) async {
    final templates = await getAll();
    final activeTemplates = templates.where((t) => t.ativo).toList();
    try {
      return activeTemplates.firstWhere(
        (t) => t.toEntity().matches(text),
      );
    } catch (_) {
      return null;
    }
  }
}
