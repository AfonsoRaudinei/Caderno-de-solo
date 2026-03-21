import 'package:soloforte/features/analise/data/models/analise_solo_model.dart';
import 'package:soloforte/features/analise/data/models/produtor_model.dart';

abstract class AnaliseDataSource {
  Future<List<AnaliseSoloModel>> getAnalises();
  Future<void> saveAnalise(AnaliseSoloModel analise);
  Future<void> deleteAnalise(String id);
  Future<List<ProdutorModel>> getProdutores();
}
