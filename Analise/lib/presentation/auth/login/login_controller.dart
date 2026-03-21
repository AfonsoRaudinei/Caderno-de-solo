import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloforte/data/datasources/remote/auth_datasource.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {
    return null; // idle state
  }

  Future<void> login(String email, String senha) async {
    // Validações básicas pedidas na QA
    if (!email.contains('@')) {
      state = AsyncError('E-mail inválido.', StackTrace.current);
      return;
    }
    if (senha.length < 6) {
      state = AsyncError('A senha deve ter pelo menos 6 caracteres.', StackTrace.current);
      return;
    }

    state = const AsyncLoading();

    try {
      final authDataSource = ref.read(authDatasourceProvider);
      await authDataSource.signInWithEmailAndPassword(email: email, password: senha);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e.toString(), stack);
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      final authDataSource = ref.read(authDatasourceProvider);
      await authDataSource.signOut();
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError('Erro ao sair da conta.', stack);
    }
  }
}
