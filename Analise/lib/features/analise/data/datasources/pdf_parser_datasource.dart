import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:soloforte/features/analise/data/models/lab_template_model.dart';

class PdfParserDatasource {
  Future<List<LabTemplateModel>> loadLabTemplates() async {
    try {
      // Exemplo lendo da pasta assets. Em dev não teremos o pdf gerado, mas deixamos pronto
      final String jsonString =
          await rootBundle.loadString('assets/lab_templates/soloagro.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      final template = LabTemplateModel.fromJson(jsonMap);
      return [template];
    } catch (e) {
      // Silenciar erro se o arquivo não existir ainda durante o mock
      return [];
    }
  }
}
