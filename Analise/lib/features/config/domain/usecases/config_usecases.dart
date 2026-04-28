import 'package:soloforte/features/config/domain/entities/perfil_assets.dart';
import 'package:soloforte/features/config/domain/entities/user_profile_data.dart';
import 'package:soloforte/features/config/domain/repositories/config_repository.dart';

class GetUserProfileUsecase {
  const GetUserProfileUsecase(this._repository);

  final ConfigRepository _repository;

  Future<UserProfileData> call() => _repository.getUserProfile();
}

class UpdateProfileFieldUsecase {
  const UpdateProfileFieldUsecase(this._repository);

  final ConfigRepository _repository;

  Future<void> call(String field, String value) {
    return _repository.updateProfileField(field, value);
  }
}

class LogoutConfigUsecase {
  const LogoutConfigUsecase(this._repository);

  final ConfigRepository _repository;

  Future<void> call() => _repository.logout();
}

class ExcluirContaUsecase {
  const ExcluirContaUsecase(this._repository);

  final ConfigRepository _repository;

  Future<void> call({required String password}) {
    return _repository.excluirConta(password: password);
  }
}

class LimparDadosLocaisUsecase {
  const LimparDadosLocaisUsecase(this._repository);

  final ConfigRepository _repository;

  Future<void> call() => _repository.limparDadosLocais();
}

class GetPerfilAssetsUsecase {
  const GetPerfilAssetsUsecase(this._repository);

  final ConfigRepository _repository;

  Future<PerfilAssets> call() => _repository.getPerfilAssets();
}

class UploadLogoUsecase {
  const UploadLogoUsecase(this._repository);

  final ConfigRepository _repository;

  Future<String?> call() => _repository.uploadLogo();
}

class UploadAssinaturaUsecase {
  const UploadAssinaturaUsecase(this._repository);

  final ConfigRepository _repository;

  Future<String?> call() => _repository.uploadAssinatura();
}

class RemoveLogoUsecase {
  const RemoveLogoUsecase(this._repository);

  final ConfigRepository _repository;

  Future<void> call() => _repository.removeLogo();
}

class RemoveAssinaturaUsecase {
  const RemoveAssinaturaUsecase(this._repository);

  final ConfigRepository _repository;

  Future<void> call() => _repository.removeAssinatura();
}
