import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/repositories/analise_repository.dart';

class SaveAnaliseUsecase {
  final AnaliseRepository repository;

  SaveAnaliseUsecase(this.repository);

  Future<void> call(AnaliseSolo analise) async {
    await repository.saveAnalise(analise);
  }
}
