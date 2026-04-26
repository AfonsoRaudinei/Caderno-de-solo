import 'package:hive_flutter/hive_flutter.dart';

class CalibracaoHiveDatasource {
  static const String boxName = 'calibracao_profiles_box';
  static const String key = 'profiles';

  // Chave separada para controle de seed único.
  // Uma vez marcada como true, o perfil padrão nunca é recriado — mesmo
  // que o usuário delete todas as calibrações depois.
  static const String _seededKey = 'calibracao_seeded';

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

  /// Retorna [true] se o perfil padrão já foi criado ao menos uma vez.
  Future<bool> hasBeenSeeded() async {
    final box = await Hive.openBox(boxName);
    return box.get(_seededKey, defaultValue: false) as bool;
  }

  /// Marca o box como "já semeado" — chamado logo após salvar o perfil padrão.
  Future<void> markAsSeeded() async {
    final box = await Hive.openBox(boxName);
    await box.put(_seededKey, true);
  }
}
