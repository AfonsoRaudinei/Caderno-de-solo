import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';
import 'package:soloforte/features/analise/domain/entities/produtor.dart';
import 'package:soloforte/features/analise/domain/repositories/analise_repository.dart';
import 'package:soloforte/features/analise/data/datasources/analise_datasource.dart';
import 'package:soloforte/features/analise/data/models/analise_solo_model.dart';

class AnaliseRepositoryImpl implements AnaliseRepository {
  final AnaliseDataSource dataSource;

  AnaliseRepositoryImpl({required this.dataSource});

  @override
  Future<List<AnaliseSolo>> getAnalises() async {
    return await dataSource.getAnalises();
  }

  @override
  Stream<List<AnaliseSolo>> watchAnalises() {
    return dataSource.watchAnalises();
  }

  @override
  Future<void> saveAnalise(AnaliseSolo analise) async {
    final model = AnaliseSoloModel.fromEntity(analise);
    await dataSource.saveAnalise(model);
  }

  @override
  Future<SaveBatchResult> saveAnalisesBatch(List<AnaliseSolo> analises) async {
    final models =
        analises.map(AnaliseSoloModel.fromEntity).toList(growable: false);
    return dataSource.saveAnalisesBatch(models);
  }

  @override
  Future<void> recoverPendingBatches(
      {Duration timeout = const Duration(minutes: 10)}) {
    return dataSource.recoverPendingBatches(timeout: timeout);
  }

  @override
  Future<void> deleteAnalise(String id) async {
    await dataSource.deleteAnalise(id);
  }

  @override
  Future<List<Produtor>> getProdutores() async {
    return await dataSource.getProdutores();
  }
}
