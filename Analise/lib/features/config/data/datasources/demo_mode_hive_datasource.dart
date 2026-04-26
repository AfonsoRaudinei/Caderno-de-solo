import 'package:hive_flutter/hive_flutter.dart';

/// Datasource local para o toggle de "Análises de Demonstração".
/// Usa Hive — offline-first, persiste entre sessões.
class DemoModeHiveDatasource {
  static const String _boxName = 'demo_mode_box';
  static const String _key = 'analise_demo_mode_enabled';

  Future<bool> isEnabled() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_key, defaultValue: false) as bool;
  }

  Future<void> setEnabled(bool value) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_key, value);
  }
}
