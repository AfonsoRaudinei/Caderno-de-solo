import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/core/services/app_observability.dart';

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  return AuthDatasource(FirebaseAuth.instance);
});

class AuthDatasource {
  static const String authUidStorageKey = 'auth_uid';
  static const String legacyAuthTokenStorageKey = 'auth_token';
  static const String genericSignInMessage =
      'Não foi possível autenticar com esses dados.';
  static const String genericCreateAccountMessage =
      'Não foi possível criar a conta com esses dados.';

  final FirebaseAuth _auth;
  final _storage = const FlutterSecureStorage();

  AuthDatasource(this._auth);

  String? currentUserId() => _auth.currentUser?.uid;

  Future<String?> waitForCurrentUserId(
      {Duration timeout = const Duration(seconds: 5)}) async {
    final current = _auth.currentUser?.uid;
    if (current != null && current.isNotEmpty) return current;
    final user = await _auth
        .authStateChanges()
        .firstWhere((u) => u != null)
        .timeout(timeout, onTimeout: () => null);
    return user?.uid;
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return AppObservability.instance.trace(
      'auth_sign_in_email_password',
      () async {
        try {
          final credential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          if (credential.user != null) {
            await _storage.write(
              key: authUidStorageKey,
              value: credential.user!.uid,
            );
            // Limpa chave legada para manter consistência semântica.
            await _storage.delete(key: legacyAuthTokenStorageKey);
          }

          return credential;
        } on FirebaseAuthException catch (e, stack) {
          await _recordAuthException(e, stack, operation: 'sign_in');
          throw _handleSignInException(e);
        }
      },
      attributes: {'flow': 'auth', 'method': 'email_password'},
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return AppObservability.instance.trace(
      'auth_create_user_email_password',
      () async {
        try {
          return await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } on FirebaseAuthException catch (e, stack) {
          await _recordAuthException(e, stack, operation: 'create_user');
          throw _handleCreateUserException(e);
        }
      },
      attributes: {'flow': 'auth', 'method': 'email_password'},
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await AppObservability.instance.trace(
      'auth_send_password_reset',
      () async {
        try {
          await _auth.sendPasswordResetEmail(email: email);
        } on FirebaseAuthException catch (e, stack) {
          await _recordAuthException(e, stack, operation: 'password_reset');
          if (_isAccountEnumerationCode(e.code)) return;
          throw _handlePasswordResetException(e);
        }
      },
      attributes: {'flow': 'auth'},
    );
  }

  Future<void> signOut() async {
    await AppObservability.instance.trace(
      'auth_sign_out',
      () async {
        await _auth.signOut();
        await _storage.delete(key: authUidStorageKey);
        await _storage.delete(key: legacyAuthTokenStorageKey);
      },
      attributes: {'flow': 'auth'},
    );
  }

  /// Exclui permanentemente a conta do usuário autenticado.
  /// Requer re-autenticação recente — lançará [FirebaseAuthException]
  /// com código 'requires-recent-login' se a sessão for antiga.
  Future<void> deleteAccount() async {
    await AppObservability.instance.trace(
      'auth_delete_account',
      () async {
        final user = _auth.currentUser;
        if (user == null) throw Exception('Usuário não autenticado.');
        await user.delete();
        await _storage.delete(key: authUidStorageKey);
        await _storage.delete(key: legacyAuthTokenStorageKey);
      },
      attributes: {'flow': 'auth'},
    );
  }

  Future<void> _recordAuthException(
    FirebaseAuthException e,
    StackTrace stack, {
    required String operation,
  }) {
    return AppObservability.instance.recordError(
      e,
      stack,
      reason: 'firebase_auth_exception',
      extras: {
        'auth_operation': operation,
        'auth_error_code': e.code,
      },
    );
  }

  bool _isAccountEnumerationCode(String code) {
    return code == 'user-not-found' ||
        code == 'wrong-password' ||
        code == 'invalid-credential' ||
        code == 'user-disabled' ||
        code == 'email-already-in-use';
  }

  String _handleSignInException(FirebaseAuthException e) {
    if (_isAccountEnumerationCode(e.code)) {
      return genericSignInMessage;
    }
    return _handleCommonAuthException(e);
  }

  String _handleCreateUserException(FirebaseAuthException e) {
    if (e.code == 'email-already-in-use') {
      return genericCreateAccountMessage;
    }
    return _handleCommonAuthException(e);
  }

  String _handlePasswordResetException(FirebaseAuthException e) {
    return _handleCommonAuthException(e);
  }

  String _handleCommonAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'A senha fornecida é muito fraca.';
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      case 'network-request-failed':
        return 'Sem conexão com a internet. Verifique sua rede e tente novamente.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      case 'operation-not-allowed':
        return 'Login por e-mail não habilitado. Contate o suporte.';
      default:
        return 'Ocorreu um erro de autenticação. Tente novamente.';
    }
  }
}
