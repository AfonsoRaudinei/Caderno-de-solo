import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloforte/data/datasources/remote/auth_datasource.dart';

part 'cadastro_controller.g.dart';

// Provider simples para controlar qual etapa do cadastro o usuário está (0, 1, 2)
final cadastroStepProvider = StateProvider.autoDispose<int>((ref) => 0);

final cadastroFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
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
      final authDataSource = ref.read(authDatasourceProvider);
      final firestore = ref.read(cadastroFirestoreProvider);
      final nomeTrimmed = nome.trim();
      final emailTrimmed = email.trim();
      final tipoPerfilTrimmed = tipoPerfil.trim();
      final estadoTrimmed = estado.trim();
      final cidadeTrimmed = cidade.trim();
      final credential = await authDataSource.createUserWithEmailAndPassword(
        email: emailTrimmed,
        password: senha,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Conta criada sem usuário autenticado.');
      }

      await user.updateDisplayName(nomeTrimmed);
      await user.sendEmailVerification();
      await firestore.collection('users').doc(user.uid).set({
        'nome': nomeTrimmed,
        'email': emailTrimmed,
        'tipoPerfil': tipoPerfilTrimmed,
        'estado': estadoTrimmed,
        'cidade': cidadeTrimmed,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      state = const AsyncData(null);
    } catch (e, stack) {
      // Exibe a mensagem real tratada no AuthDatasource (ex.: e-mail em uso)
      state = AsyncError(e.toString(), stack);
    }
  }
}
