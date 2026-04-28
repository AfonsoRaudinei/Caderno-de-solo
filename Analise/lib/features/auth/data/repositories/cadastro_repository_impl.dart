import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soloforte/data/datasources/remote/auth_datasource.dart';
import 'package:soloforte/features/auth/domain/repositories/cadastro_repository.dart';

class CadastroRepositoryImpl implements CadastroRepository {
  const CadastroRepositoryImpl({
    required AuthDatasource authDatasource,
    required FirebaseFirestore firestore,
  })  : _authDatasource = authDatasource,
        _firestore = firestore;

  final AuthDatasource _authDatasource;
  final FirebaseFirestore _firestore;

  @override
  Future<void> registrar({
    required String nome,
    required String tipoPerfil,
    required String estado,
    required String cidade,
    required String email,
    required String senha,
  }) async {
    final nomeTrimmed = nome.trim();
    final emailTrimmed = email.trim();
    final tipoPerfilTrimmed = tipoPerfil.trim();
    final estadoTrimmed = estado.trim();
    final cidadeTrimmed = cidade.trim();

    final credential = await _authDatasource.createUserWithEmailAndPassword(
      email: emailTrimmed,
      password: senha,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Conta criada sem usuário autenticado.');
    }

    await user.updateDisplayName(nomeTrimmed);
    await user.sendEmailVerification();
    await _firestore.collection('users').doc(user.uid).set({
      'nome': nomeTrimmed,
      'email': emailTrimmed,
      'tipoPerfil': tipoPerfilTrimmed,
      'estado': estadoTrimmed,
      'cidade': cidadeTrimmed,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
