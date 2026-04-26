import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloforte/data/datasources/remote/auth_datasource.dart';

part 'cadastro_controller.g.dart';

// Provider simples para controlar qual etapa do cadastro o usuário está (0, 1, 2)
final cadastroStepProvider = StateProvider.autoDispose<int>((ref) => 0);

@riverpod
class CadastroController extends _$CadastroController {
  @override
  FutureOr<void> build() {
    return null; // Idle state
  }

  Future<void> registrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    state = const AsyncLoading();

    try {
      final authDataSource = ref.read(authDatasourceProvider);
      final credential = await authDataSource.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Atualiza o displayName apenas para manter o nome salvo no perfil
      await credential.user?.updateDisplayName(nome);

      state = const AsyncData(null);
    } catch (e, stack) {
      // Exibe a mensagem real tratada no AuthDatasource (ex.: e-mail em uso)
      state = AsyncError(e.toString(), stack);
    }
  }
}
