abstract class CadastroRepository {
  Future<void> registrar({
    required String nome,
    required String tipoPerfil,
    required String estado,
    required String cidade,
    required String email,
    required String senha,
  });
}
