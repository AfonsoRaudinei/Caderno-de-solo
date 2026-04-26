import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/data/datasources/remote/auth_datasource.dart';
import 'package:soloforte/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    datasource: ref.watch(authDatasourceProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthDatasource datasource,
  }) : _datasource = datasource;

  static const String _invalidEmailMessage = 'E-mail inválido.';
  static const String _shortPasswordMessage =
      'A senha deve ter pelo menos 6 caracteres.';
  static const String _genericLoginError =
      'Não foi possível entrar agora. Tente novamente em instantes.';

  final AuthDatasource _datasource;

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (!_isValidEmail(email)) {
      throw _invalidEmailMessage;
    }

    if (password.length < 6) {
      throw _shortPasswordMessage;
    }

    try {
      await _datasource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      if (error is String && error.trim().isNotEmpty) {
        throw error.trim();
      }
      throw _genericLoginError;
    }
  }

  @override
  Future<void> logout() async {
    await _datasource.signOut();
  }

  @override
  Future<void> enviarEmailRedefinicaoSenha(String email) async {
    if (!_isValidEmail(email)) {
      throw _invalidEmailMessage;
    }

    try {
      await _datasource.sendPasswordResetEmail(email: email.trim());
    } catch (error) {
      if (error is String && error.trim().isNotEmpty) {
        throw error.trim();
      }
      throw 'Erro ao enviar e-mail de redefinição. Tente novamente em instantes.';
    }
  }

  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }
}
