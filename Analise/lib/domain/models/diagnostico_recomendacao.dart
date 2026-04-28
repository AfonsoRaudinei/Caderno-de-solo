import 'package:soloforte/domain/usecases/recomendacao_engine.dart';

enum StatusNutriente {
  ok,
  ausente,
  invalido,
}

enum DiagnosticoStatus {
  baixo,
  adequado,
  alto,
}

class DiagnosticoNutriente {
  const DiagnosticoNutriente({
    required this.status,
    required this.mensagemTecnica,
    required this.recomendacao,
  });

  final DiagnosticoStatus status;
  final String mensagemTecnica;
  final String recomendacao;
}

class DiagnosticoRecomendacao {
  const DiagnosticoRecomendacao({
    this.erros = const <String>[],
    this.avisos = const <String>[],
    this.statusNutrientes = const <String, StatusNutriente>{},
    this.diagnosticos = const <String, DiagnosticoNutriente>{},
  });

  final List<String> erros;
  final List<String> avisos;
  final Map<String, StatusNutriente> statusNutrientes;
  final Map<String, DiagnosticoNutriente> diagnosticos;

  bool get valido => erros.isEmpty;
}

class RecomendacaoResult {
  const RecomendacaoResult({
    required this.recomendacao,
    required this.diagnostico,
  });

  final ResultadoRecomendacao? recomendacao;
  final DiagnosticoRecomendacao diagnostico;
}
