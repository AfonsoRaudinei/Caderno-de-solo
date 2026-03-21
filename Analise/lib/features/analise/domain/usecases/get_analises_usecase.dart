import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/repositories/analise_repository.dart';

class GetAnalisesUsecase {
  final AnaliseRepository repository;

  GetAnalisesUsecase(this.repository);

  Future<List<AnaliseSolo>> call() async {
    return await repository.getAnalises();
  }
}
