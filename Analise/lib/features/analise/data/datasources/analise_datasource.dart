import 'package:soloforte/features/analise/data/models/analise_solo_model.dart';
import 'package:soloforte/features/analise/data/models/produtor_model.dart';
import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';

abstract class AnaliseDataSource {
  Future<List<AnaliseSoloModel>> getAnalises();
  Stream<List<AnaliseSoloModel>> watchAnalises();
  Future<void> saveAnalise(AnaliseSoloModel analise);
  Future<SaveBatchResult> saveAnalisesBatch(List<AnaliseSoloModel> analises);
  Future<void> recoverPendingBatches({Duration timeout});
  Future<void> deleteAnalise(String id);
  Future<List<ProdutorModel>> getProdutores();
}
