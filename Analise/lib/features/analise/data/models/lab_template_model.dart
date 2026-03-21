class LabTemplateModel {
  final String lab;
  final Map<String, LabMapping> mapeamento;

  LabTemplateModel({
    required this.lab,
    required this.mapeamento,
  });

  factory LabTemplateModel.fromJson(Map<String, dynamic> json) {
    final map = (json['mapeamento'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, LabMapping.fromJson(value)),
    );

    return LabTemplateModel(
      lab: json['lab'] as String,
      mapeamento: map,
    );
  }
}

class LabMapping {
  final int pagina;
  final String regex;

  LabMapping({
    required this.pagina,
    required this.regex,
  });

  factory LabMapping.fromJson(Map<String, dynamic> json) {
    return LabMapping(
      pagina: json['pagina'] as int,
      regex: json['regex'] as String,
    );
  }
}
