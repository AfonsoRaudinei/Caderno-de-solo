import 'package:hive_flutter/hive_flutter.dart';
import 'package:soloforte/features/config/domain/entities/app_theme_mode.dart';

class ConfigLocalDatasource {
  static const _preferencesBox = 'config_preferences_box';
  static const _themeModeKey = 'theme_mode';

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
}
