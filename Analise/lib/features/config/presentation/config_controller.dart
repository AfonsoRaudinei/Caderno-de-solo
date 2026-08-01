import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/clientes/application/providers/cliente_provider.dart';
import 'package:soloforte/features/config/application/providers/config_providers.dart';
import 'package:soloforte/features/config/application/providers/perfil_assets_provider.dart';
import 'package:soloforte/features/config/application/providers/tabela_metricas_provider.dart';
import 'package:soloforte/features/config/domain/entities/user_profile_data.dart';
import 'package:soloforte/features/historico/application/providers/historico_provider.dart';
import 'package:soloforte/features/laboratorio/application/providers/calibracao_controller.dart';
import 'package:soloforte/features/laboratorio/application/providers/laudo_provider.dart';

export 'package:soloforte/features/config/domain/entities/user_profile_data.dart';

class ConfigController extends AsyncNotifier<UserProfileData> {
  @override
  Future<UserProfileData> build() async {
    return ref.read(getUserProfileUsecaseProvider).call();
  }

  Future<void> logout() async {
    await ref.read(logoutConfigUsecaseProvider).call();
    ref
      ..invalidate(perfilAssetsProvider)
      ..invalidate(tabelaMetricasProvider)
      ..invalidate(clienteProvider)
      ..invalidate(historicoProvider)
      ..invalidate(calibracaoControllerProvider)
      ..invalidate(laudoNotifierProvider)
      ..invalidateSelf();
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
