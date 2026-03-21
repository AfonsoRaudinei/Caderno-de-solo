import 'package:soloforte/features/analise/domain/repositories/analise_repository.dart';

class DeleteAnaliseUsecase {
  final AnaliseRepository repository;

  DeleteAnaliseUsecase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteAnalise(id);
  }
}
