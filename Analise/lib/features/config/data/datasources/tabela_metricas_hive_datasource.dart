import 'package:hive_flutter/hive_flutter.dart';
import 'package:soloforte/features/config/domain/entities/tabela_metricas.dart';
import 'package:soloforte/features/config/domain/entities/tabela_metricas_defaults.dart';

/// Datasource local para [TabelaMetricas].
/// Usa Hive — offline-first, sem depender de conexão.
class TabelaMetricasHiveDatasource {
  static const String _boxName = 'tabela_metricas_box';
  static const String _key = 'tabelas';

  Future<List<TabelaMetricas>> getTabelasOuSeed() async {
    final box = await Hive.openBox(_boxName);
    final raw = box.get(_key, defaultValue: <dynamic>[]) as List<dynamic>;
    final salvas = raw
        .whereType<Map>()
        .map((e) => TabelaMetricas.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    // Primeira execução: injeta defaults
    if (salvas.isEmpty) {
      final defaults = TabelaMetricasDefaults.build();
      await _salvarTodas(box, defaults);
      return defaults;
    }

    // Se faltam tabelas (ex: nova versão adicionou chave), faz merge.
    return _merge(salvas);
  }

  Future<void> salvarTabela(TabelaMetricas tabela) async {
    final box = await Hive.openBox(_boxName);
    final current = await getTabelasOuSeed();
    final idx = current.indexWhere((t) => t.id == tabela.id);
    final updated = [...current];
    if (idx >= 0) {
      updated[idx] = tabela;
    } else {
      updated.add(tabela);
    }
    await _salvarTodas(box, updated);
  }

  Future<void> resetarParaDefaults() async {
    final box = await Hive.openBox(_boxName);
    await _salvarTodas(box, TabelaMetricasDefaults.build());
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  Future<void> _salvarTodas(Box box, List<TabelaMetricas> tabelas) async {
    await box.put(_key, tabelas.map((t) => t.toJson()).toList());
  }

  /// Garante que todas as chaves canônicas estejam presentes.
  List<TabelaMetricas> _merge(List<TabelaMetricas> salvas) {
    final defaults = TabelaMetricasDefaults.build();
    final chavesExistentes = salvas.map((t) => t.chave).toSet();
    final novas = defaults.where((d) => !chavesExistentes.contains(d.chave));
    if (novas.isEmpty) return salvas;
    return [...salvas, ...novas];
  }
}
