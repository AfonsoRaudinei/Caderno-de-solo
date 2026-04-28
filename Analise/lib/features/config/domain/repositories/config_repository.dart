import 'package:soloforte/features/config/domain/entities/perfil_assets.dart';
import 'package:soloforte/features/config/domain/entities/user_profile_data.dart';

abstract class ConfigRepository {
  Future<UserProfileData> getUserProfile();

  Future<void> updateProfileField(String field, String value);

  Future<void> logout();

  Future<void> excluirConta({required String password});

  Future<void> limparDadosLocais();

  Future<PerfilAssets> getPerfilAssets();

  Future<String?> uploadLogo();

  Future<String?> uploadAssinatura();

  Future<void> removeLogo();

  Future<void> removeAssinatura();
}
