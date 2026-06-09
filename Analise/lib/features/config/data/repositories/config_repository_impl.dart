import 'package:firebase_auth/firebase_auth.dart';
import 'package:soloforte/data/datasources/remote/auth_datasource.dart';
import 'package:soloforte/features/config/data/datasources/config_local_datasource.dart';
import 'package:soloforte/features/config/data/datasources/config_remote_datasource.dart';
import 'package:soloforte/features/config/domain/entities/app_theme_mode.dart';
import 'package:soloforte/features/config/domain/entities/config_action_exception.dart';
import 'package:soloforte/features/config/domain/entities/perfil_assets.dart';
import 'package:soloforte/features/config/domain/entities/user_profile_data.dart';
import 'package:soloforte/features/config/domain/repositories/config_repository.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  const ConfigRepositoryImpl({
    required ConfigRemoteDatasource remoteDatasource,
    required ConfigLocalDatasource localDatasource,
    required AuthDatasource authDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _authDatasource = authDatasource;

  final ConfigRemoteDatasource _remoteDatasource;
  final ConfigLocalDatasource _localDatasource;
  final AuthDatasource _authDatasource;

  @override
  Future<UserProfileData> getUserProfile() async {
    final user = _remoteDatasource.currentUser;
    if (user == null) {
      return const UserProfileData(
        nome: '—',
        email: '—',
        tipoPerfil: '—',
        empresa: '—',
      );
    }

    final nome = _fallback(user.displayName);
    final email = _fallback(user.email);

    try {
      final data = await _remoteDatasource.getUserDocument(user.uid);
      return UserProfileData(
        nome: nome,
        email: email,
        tipoPerfil: _fallback(data?['tipoPerfil'] as String?),
        empresa: _fallback(data?['empresa'] as String?),
      );
    } catch (_) {
      return UserProfileData(
        nome: nome,
        email: email,
        tipoPerfil: '—',
        empresa: '—',
      );
    }
  }

  @override
  Future<void> updateProfileField(String field, String value) async {
    final uid = _remoteDatasource.currentUser?.uid;
    if (uid == null) return;
    await _remoteDatasource.updateUserFields(uid, {field: value.trim()});
  }

  @override
  Future<void> logout() => _authDatasource.signOut();

  @override
  Future<void> excluirConta({required String password}) async {
    try {
      final user = _remoteDatasource.currentUser;
      if (user == null) {
        await _remoteDatasource.reauthenticateCurrentUser(password: password);
        return;
      }

      await _remoteDatasource.reauthenticateCurrentUser(password: password);
      await _remoteDatasource.deleteCloudDataForUser(user.uid);
      await limparDadosLocais();
      await _authDatasource.deleteAccount();
    } on FirebaseAuthException catch (e) {
      throw ConfigActionException(e.code, _deleteAccountMessage(e.code));
    }
  }

  @override
  Future<void> limparDadosLocais() => _localDatasource.limparDadosLocais();

  @override
  Future<AppThemeMode> getThemeMode() => _localDatasource.getThemeMode();

  @override
  Future<void> setThemeMode(AppThemeMode mode) {
    return _localDatasource.setThemeMode(mode);
  }

  @override
  Future<PerfilAssets> getPerfilAssets() async {
    final uid = _remoteDatasource.currentUser?.uid;
    if (uid == null || uid.isEmpty) return const PerfilAssets();

    try {
      final data = await _remoteDatasource.getUserDocument(uid);
      final logo = data?['logoUrl'] as String?;
      final assinatura = data?['assinaturaUrl'] as String?;

      return PerfilAssets(
        logoUrl: _assetUrlOrNull(logo),
        assinaturaUrl: _assetUrlOrNull(assinatura),
      );
    } catch (_) {
      return const PerfilAssets();
    }
  }

  @override
  Future<String?> uploadLogo() async {
    final uid = _requireUid();
    final file = await _remoteDatasource.pickImage(
      imageQuality: 85,
      maxWidth: 800,
    );
    if (file == null) return null;

    final url =
        await _remoteDatasource.uploadImage(file, 'users/$uid/logo.jpg');
    await _remoteDatasource.updateUserFields(uid, {'logoUrl': url});
    return _withCacheBust(url);
  }

  @override
  Future<String?> uploadAssinatura() async {
    final uid = _requireUid();
    final file = await _remoteDatasource.pickImage(
      imageQuality: 90,
      maxWidth: 600,
    );
    if (file == null) return null;

    final url = await _remoteDatasource.uploadImage(
      file,
      'users/$uid/assinatura.jpg',
    );
    await _remoteDatasource.updateUserFields(uid, {'assinaturaUrl': url});
    return _withCacheBust(url);
  }

  @override
  Future<void> removeLogo() async {
    final uid = _requireUid();
    await _remoteDatasource.deleteStoragePath('users/$uid/logo.jpg');
    await _remoteDatasource.updateUserFields(uid, {'logoUrl': ''});
  }

  @override
  Future<void> removeAssinatura() async {
    final uid = _requireUid();
    await _remoteDatasource.deleteStoragePath('users/$uid/assinatura.jpg');
    await _remoteDatasource.updateUserFields(uid, {'assinaturaUrl': ''});
  }

  String _requireUid() {
    final uid = _remoteDatasource.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('Usuário não autenticado. Faça login novamente.');
    }
    return uid;
  }

  String _fallback(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return '—';
    return trimmed;
  }

  String? _assetUrlOrNull(String? value) {
    if (value == null || value.isEmpty) return null;
    return _withCacheBust(value);
  }

  String _withCacheBust(String url) {
    final token = DateTime.now().millisecondsSinceEpoch;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}v=$token';
  }

  String _deleteAccountMessage(String code) {
    return switch (code) {
      'wrong-password' ||
      'invalid-credential' =>
        'Senha incorreta. Confira e tente novamente.',
      'requires-recent-login' => 'Por segurança, confirme sua senha novamente.',
      _ => 'Erro ao excluir conta. Tente novamente.',
    };
  }
}
