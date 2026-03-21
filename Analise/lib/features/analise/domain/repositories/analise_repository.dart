import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/entities/produtor.dart';

abstract class AnaliseRepository {
  Future<List<AnaliseSolo>> getAnalises();
  Future<void> saveAnalise(AnaliseSolo analise);
  Future<void> deleteAnalise(String id);
  Future<List<Produtor>> getProdutores();
}
