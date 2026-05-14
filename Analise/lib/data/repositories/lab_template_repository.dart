import 'package:soloforte/data/datasources/lab_template_datasource.dart';
import 'package:soloforte/domain/entities/lab_template.dart';
import 'package:soloforte/domain/models/lab_template_model.dart';

class LabTemplateRepository {
  final LabTemplateDatasource _datasource;

  LabTemplateRepository(this._datasource);

  Future<List<LabTemplate>> getAll() async {
    final models = await _datasource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  Future<LabTemplate?> getById(String id) async {
    final model = await _datasource.getById(id);
    return model?.toEntity();
  }

  Future<void> save(LabTemplate template) async {
    final model = LabTemplateModel.fromEntity(template);
    await _datasource.save(model);
  }

  Future<void> delete(String id) async {
    await _datasource.delete(id);
  }

  /// Detecta template a partir do texto do PDF.
  /// Retorna null se nenhum template ativo bater com o texto.
  Future<LabTemplate?> detectFromText(String pdfText) async {
    final model = await _datasource.findByText(pdfText);
    return model?.toEntity();
  }
}
