import 'package:soloforte/domain/models/recomendacao_model.dart';
import 'package:soloforte/features/historico/domain/repositories/historico_repository.dart';

class CarregarHistoricoUseCase {
  const CarregarHistoricoUseCase(this._repository);

  final HistoricoRepository _repository;

  Future<List<RecomendacaoModel>> call({
    required Set<String> analiseIds,
    required String userId,
  }) {
    if (analiseIds.isEmpty) return Future.value(const []);
    return _repository.listarPorAnaliseIds(
      analiseIds: analiseIds,
      userId: userId,
    );
  }
}
