abstract class AuthRepository {
  Future<void> login({
    required String email,
    required String password,
  });

  Future<void> enviarEmailRedefinicaoSenha(String email);

  Future<void> logout();

  String? currentUserId();

  Future<String?> waitForCurrentUserId({Duration timeout});
}
