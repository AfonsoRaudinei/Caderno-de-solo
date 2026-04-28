import 'package:soloforte/features/config/data/datasources/tabela_metricas_hive_datasource.dart';
import 'package:soloforte/features/config/domain/entities/tabela_metricas.dart';
import 'package:soloforte/features/config/domain/repositories/tabela_metricas_repository.dart';

class TabelaMetricasRepositoryImpl implements TabelaMetricasRepository {
  const TabelaMetricasRepositoryImpl(this._datasource);

  final TabelaMetricasHiveDatasource _datasource;

  @override
  Future<List<TabelaMetricas>> getTabelasOuSeed() {
    return _datasource.getTabelasOuSeed();
  }

  @override
  Future<void> salvarTabela(TabelaMetricas tabela) {
    return _datasource.salvarTabela(tabela);
  }

  @override
  Future<void> resetarParaDefaults() {
    return _datasource.resetarParaDefaults();
  }
}
