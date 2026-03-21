import 'package:hive_flutter/hive_flutter.dart';

class CalibracaoHiveDatasource {
  static const String boxName = 'calibracao_profiles_box';
  static const String key = 'profiles';

  Future<List<Map<String, dynamic>>> getProfiles() async {
    final box = await Hive.openBox(boxName);
    final raw = box.get(key, defaultValue: <dynamic>[]) as List<dynamic>;
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> saveProfiles(List<Map<String, dynamic>> profiles) async {
    final box = await Hive.openBox(boxName);
    await box.put(key, profiles);
  }
}
