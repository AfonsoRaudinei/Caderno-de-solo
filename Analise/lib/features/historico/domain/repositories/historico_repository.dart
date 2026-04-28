import 'package:soloforte/domain/models/recomendacao_model.dart';

abstract class HistoricoRepository {
  Future<List<RecomendacaoModel>> listarPorAnaliseIds(Set<String> analiseIds);

  Future<void> deletarRecomendacao(String id);
}
