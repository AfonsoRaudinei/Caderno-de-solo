import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soloforte/features/config/domain/entities/app_theme_mode.dart';
import 'package:soloforte/features/config/domain/entities/perfil_assets.dart';

class ConfigLocalDatasource {
  static const _preferencesBox = 'config_preferences_box';
  static const _themeModeKey = 'theme_mode';
  static const _logoPathPrefix = 'perfil_logo_path';
  static const _assinaturaPathPrefix = 'perfil_assinatura_path';

  final ImagePicker _picker = ImagePicker();

  Future<void> limparDadosLocais() async {
    final boxNames = [
      'tabela_metricas_box',
      'laudo_recomendacao_box',
      'calibracao_profiles_box',
    ];
    for (final name in boxNames) {
      final box = await Hive.openBox(name);
      await box.clear();
    }
  }

  Future<AppThemeMode> getThemeMode() async {
    final box = await Hive.openBox(_preferencesBox);
    return AppThemeMode.fromStorageKey(box.get(_themeModeKey) as String?);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final box = await Hive.openBox(_preferencesBox);
    await box.put(_themeModeKey, mode.storageKey);
  }

  Future<PerfilAssets> getPerfilAssets(String uid) async {
    final box = await Hive.openBox(_preferencesBox);
    final logoPath = await _validAssetPath(
      box,
      _assetKey(_logoPathPrefix, uid),
    );
    final assinaturaPath = await _validAssetPath(
      box,
      _assetKey(_assinaturaPathPrefix, uid),
    );
    return PerfilAssets(
      logoUrl: logoPath,
      assinaturaUrl: assinaturaPath,
    );
  }

  Future<String?> pickAndSaveLogo({
    required String uid,
    required int imageQuality,
    required double maxWidth,
  }) {
    return _pickAndPersistImage(
      uid: uid,
      storageKey: _assetKey(_logoPathPrefix, uid),
      fileStem: 'logo',
      imageQuality: imageQuality,
      maxWidth: maxWidth,
    );
  }

  Future<String?> pickAndSaveAssinatura({
    required String uid,
    required int imageQuality,
    required double maxWidth,
  }) {
    return _pickAndPersistImage(
      uid: uid,
      storageKey: _assetKey(_assinaturaPathPrefix, uid),
      fileStem: 'assinatura',
      imageQuality: imageQuality,
      maxWidth: maxWidth,
    );
  }

  Future<void> removeLogo(String uid) async {
    await _removeAsset(_assetKey(_logoPathPrefix, uid));
  }

  Future<void> removeAssinatura(String uid) async {
    await _removeAsset(_assetKey(_assinaturaPathPrefix, uid));
  }

  Future<String?> _pickAndPersistImage({
    required String uid,
    required String storageKey,
    required String fileStem,
    required int imageQuality,
    required double maxWidth,
  }) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
      );
      if (picked == null) return null;

      final bytes = await picked.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Arquivo de imagem vazio.');
      }

      final box = await Hive.openBox(_preferencesBox);
      final existingPath = box.get(storageKey) as String?;
      final documentsDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${documentsDir.path}/perfil_assets/$uid');
      await targetDir.create(recursive: true);

      final extension = _safeExtension(picked.path);
      final targetPath = '${targetDir.path}/$fileStem$extension';
      final file = File(targetPath);
      await file.writeAsBytes(bytes, flush: true);

      if (existingPath != null &&
          existingPath.isNotEmpty &&
          existingPath != targetPath) {
        final oldFile = File(existingPath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }

      await box.put(storageKey, targetPath);
      return targetPath;
    } on PlatformException {
      throw Exception(
        'Permita acesso à galeria para selecionar a imagem.',
      );
    } on Exception {
      rethrow;
    } catch (_) {
      throw Exception('Falha ao salvar imagem localmente. Tente novamente.');
    }
  }

  Future<void> _removeAsset(String storageKey) async {
    final box = await Hive.openBox(_preferencesBox);
    final path = box.get(storageKey) as String?;
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await box.delete(storageKey);
  }

  Future<String?> _validAssetPath(Box box, String key) async {
    final path = box.get(key) as String?;
    if (path == null || path.isEmpty) return null;
    if (await File(path).exists()) return path;
    await box.delete(key);
    return null;
  }

  String _assetKey(String prefix, String uid) => '${prefix}_$uid';

  String _safeExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) return '.jpg';
    final extension = path.substring(dot).toLowerCase();
    if (extension.length > 8) return '.jpg';
    return extension;
  }
}
