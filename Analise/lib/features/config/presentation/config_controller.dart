import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/config/application/providers/config_providers.dart';
import 'package:soloforte/features/config/domain/entities/user_profile_data.dart';

export 'package:soloforte/features/config/domain/entities/user_profile_data.dart';

class ConfigController extends AsyncNotifier<UserProfileData> {
  @override
  Future<UserProfileData> build() async {
    return ref.read(getUserProfileUsecaseProvider).call();
  }

  Future<void> logout() async {
    await ref.read(logoutConfigUsecaseProvider).call();
  }

  Future<void> updateProfileField(String field, String value) async {
    await ref.read(updateProfileFieldUsecaseProvider).call(field, value);
    ref.invalidateSelf();
  }

  Future<void> excluirConta({required String password}) async {
    await ref.read(excluirContaUsecaseProvider).call(password: password);
  }

  Future<void> limparDadosLocais() async {
    await ref.read(limparDadosLocaisUsecaseProvider).call();
  }
}

final configControllerProvider =
    AsyncNotifierProvider<ConfigController, UserProfileData>(
  ConfigController.new,
);
