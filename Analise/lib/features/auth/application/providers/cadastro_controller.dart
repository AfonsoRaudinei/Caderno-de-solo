import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloforte/data/datasources/remote/auth_datasource.dart';
import 'package:soloforte/features/auth/data/repositories/cadastro_repository_impl.dart';
import 'package:soloforte/features/auth/domain/repositories/cadastro_repository.dart';
import 'package:soloforte/features/auth/domain/usecases/registrar_usuario_usecase.dart';

part 'cadastro_controller.g.dart';

// Provider simples para controlar qual etapa do cadastro o usuário está (0, 1, 2)
final cadastroStepProvider = StateProvider.autoDispose<int>((ref) => 0);

final cadastroFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final cadastroRepositoryProvider = Provider<CadastroRepository>((ref) {
  return CadastroRepositoryImpl(
    authDatasource: ref.read(authDatasourceProvider),
    firestore: ref.read(cadastroFirestoreProvider),
  );
});

final registrarUsuarioUsecaseProvider =
    Provider<RegistrarUsuarioUsecase>((ref) {
  return RegistrarUsuarioUsecase(ref.read(cadastroRepositoryProvider));
});

@riverpod
class CadastroController extends _$CadastroController {
  @override
  FutureOr<void> build() {
    return null; // Idle state
  }

  Future<void> registrar({
    required String nome,
    required String tipoPerfil,
    required String estado,
    required String cidade,
    required String email,
    required String senha,
  }) async {
    state = const AsyncLoading();

    try {
      final registrarUsuario = ref.read(registrarUsuarioUsecaseProvider);
      await registrarUsuario(
        nome: nome,
        tipoPerfil: tipoPerfil,
        estado: estado,
        cidade: cidade,
        email: email,
        senha: senha,
      );

      state = const AsyncData(null);
    } catch (e, stack) {
      // Exibe a mensagem real tratada no AuthDatasource (ex.: e-mail em uso)
      state = AsyncError(e.toString(), stack);
    }
  }
}
