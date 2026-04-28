import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/features/laboratorio/domain/repositories/calibracao_repository.dart';

class CarregarCalibracoesUsecase {
  const CarregarCalibracoesUsecase(this._repository);

  final CalibracaoRepository _repository;

  Future<List<CalibracaoProfile>> call() => _repository.carregarPerfis();
}

class SalvarCalibracaoUsecase {
  const SalvarCalibracaoUsecase(this._repository);

  final CalibracaoRepository _repository;

  Future<void> call({
    required List<CalibracaoProfile> perfis,
    required CalibracaoProfile perfilSincronizar,
  }) {
    return _repository.salvarPerfis(
      perfis: perfis,
      perfilSincronizar: perfilSincronizar,
    );
  }
}

class ExcluirCalibracaoUsecase {
  const ExcluirCalibracaoUsecase(this._repository);

  final CalibracaoRepository _repository;

  Future<void> call({
    required List<CalibracaoProfile> perfisRestantes,
    required String perfilId,
  }) {
    return _repository.excluirPerfil(
      perfisRestantes: perfisRestantes,
      perfilId: perfilId,
    );
  }
}
