import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';
import 'package:soloforte/features/analise/domain/entities/produtor.dart';

abstract class AnaliseRepository {
  Future<List<AnaliseSolo>> getAnalises();
  Stream<List<AnaliseSolo>> watchAnalises();
  Future<void> saveAnalise(AnaliseSolo analise);
  Future<SaveBatchResult> saveAnalisesBatch(List<AnaliseSolo> analises);
  Future<void> recoverPendingBatches({Duration timeout});
  Future<void> deleteAnalise(String id);
  Future<List<Produtor>> getProdutores();
}
