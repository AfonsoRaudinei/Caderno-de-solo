import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloforte/data/repositories/auth_repository_impl.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {
    return null; // idle state
  }

  Future<void> login(String email, String senha) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.login(email: email, password: senha);
      state = const AsyncData(null);
    } catch (e, stack) {
      final message = e is String && e.trim().isNotEmpty
          ? e
          : 'Não foi possível entrar agora. Tente novamente em instantes.';
      state = AsyncError(message, stack);
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError('Erro ao sair da conta.', stack);
    }
  }
}
