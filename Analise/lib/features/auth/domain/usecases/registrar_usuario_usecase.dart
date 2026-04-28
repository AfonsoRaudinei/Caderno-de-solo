import 'package:soloforte/features/auth/domain/repositories/cadastro_repository.dart';

class RegistrarUsuarioUsecase {
  const RegistrarUsuarioUsecase(this._repository);

  final CadastroRepository _repository;

  Future<void> call({
    required String nome,
    required String tipoPerfil,
    required String estado,
    required String cidade,
    required String email,
    required String senha,
  }) {
    return _repository.registrar(
      nome: nome,
      tipoPerfil: tipoPerfil,
      estado: estado,
      cidade: cidade,
      email: email,
      senha: senha,
    );
  }
}
