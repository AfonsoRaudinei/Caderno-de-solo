import 'package:hive_flutter/hive_flutter.dart';

class ConfigLocalDatasource {
  Future<void> limparDadosLocais() async {
    final boxNames = [
      'demo_mode_box',
      'tabela_metricas_box',
      'laudo_recomendacao_box',
      'calibracao_profiles_box',
    ];
    for (final name in boxNames) {
      final box = await Hive.openBox(name);
      await box.clear();
    }
  }
}
