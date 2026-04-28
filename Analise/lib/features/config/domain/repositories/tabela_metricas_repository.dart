import 'package:soloforte/features/config/domain/entities/tabela_metricas.dart';

abstract class TabelaMetricasRepository {
  Future<List<TabelaMetricas>> getTabelasOuSeed();

  Future<void> salvarTabela(TabelaMetricas tabela);

  Future<void> resetarParaDefaults();
}
