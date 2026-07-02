import 'package:hive_flutter/hive_flutter.dart';

class ProdutorConfiguradoLocalDatasource {
  static const _boxName = 'config_preferences_box';
  static const _produtorKey = 'produtor_configurado';

  Future<String?> getProdutorConfigurado() async {
    try {
      final box = await Hive.openBox(_boxName);
      final value = box.get(_produtorKey);
      if (value is! String) return null;
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    } catch (_) {
      return null;
    }
  }

  Future<void> setProdutorConfigurado(String produtor) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_produtorKey, produtor.trim());
    } catch (_) {
      // Persistência local indisponível; fluxo segue sem bloquear importação.
    }
  }
}
