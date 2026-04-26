import 'package:hive_flutter/hive_flutter.dart';
import 'package:soloforte/features/laboratorio/data/models/laudo_recomendacao_model.dart';

/// Datasource local usando Hive — offline-first.
/// Os laudos ficam disponíveis mesmo sem conexão com a internet.
class LaudoHiveDatasource {
  static const String _boxName = 'laudo_recomendacao_box';
  static const String _key = 'laudos';

  Future<List<LaudoRecomendacaoModel>> getLaudos() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_key, defaultValue: <dynamic>[]) as List<dynamic>;
    return raw
        .whereType<Map>()
        .map((e) =>
            LaudoRecomendacaoModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveLaudo(LaudoRecomendacaoModel laudo) async {
    final box = await Hive.openBox(_boxName);
    final current = await getLaudos();
    final idx = current.indexWhere((l) => l.id == laudo.id);
    if (idx >= 0) {
      current[idx] = laudo;
    } else {
      current.insert(0, laudo); // mais recente no topo
    }
    await box.put(_key, current.map((l) => l.toJson()).toList());
  }

  Future<void> deleteLaudo(String id) async {
    final box = await Hive.openBox(_boxName);
    final current = await getLaudos();
    final updated = current.where((l) => l.id != id).toList();
    await box.put(_key, updated.map((l) => l.toJson()).toList());
  }
}
