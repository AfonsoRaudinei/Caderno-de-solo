import 'package:soloforte/features/historico/domain/repositories/historico_repository.dart';

class DeletarRecomendacaoUseCase {
  const DeletarRecomendacaoUseCase(this._repository);

  final HistoricoRepository _repository;

  Future<void> call(String recomendacaoId) {
    return _repository.deletarRecomendacao(recomendacaoId);
  }
}
