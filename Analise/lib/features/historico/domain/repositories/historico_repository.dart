import 'package:soloforte/domain/models/recomendacao_model.dart';

abstract class HistoricoRepository {
  Future<List<RecomendacaoModel>> listarPorAnaliseIds({
    required Set<String> analiseIds,
    required String userId,
  });

  Future<void> deletarRecomendacao(String id);
}
