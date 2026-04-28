import 'package:soloforte/features/config/domain/entities/tabela_metricas.dart';
import 'package:soloforte/features/config/domain/repositories/tabela_metricas_repository.dart';

class GetTabelasMetricasUsecase {
  const GetTabelasMetricasUsecase(this._repository);

  final TabelaMetricasRepository _repository;

  Future<List<TabelaMetricas>> call() => _repository.getTabelasOuSeed();
}

class SalvarTabelaMetricasUsecase {
  const SalvarTabelaMetricasUsecase(this._repository);

  final TabelaMetricasRepository _repository;

  Future<void> call(TabelaMetricas tabela) => _repository.salvarTabela(tabela);
}

class ResetarTabelaMetricasUsecase {
  const ResetarTabelaMetricasUsecase(this._repository);

  final TabelaMetricasRepository _repository;

  Future<void> call() => _repository.resetarParaDefaults();
}
