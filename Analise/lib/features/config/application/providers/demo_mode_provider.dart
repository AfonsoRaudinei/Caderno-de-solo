import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/config/data/datasources/demo_mode_hive_datasource.dart';

// ── Datasource ────────────────────────────────────────────────────────────────

final demoModeHiveDatasourceProvider = Provider<DemoModeHiveDatasource>((ref) {
  return DemoModeHiveDatasource();
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class DemoModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return ref.read(demoModeHiveDatasourceProvider).isEnabled();
  }

  Future<void> toggle() async {
    final current = await future;
    final next = !current;
    await ref.read(demoModeHiveDatasourceProvider).setEnabled(next);
    state = AsyncData(next);
    ref.invalidateSelf();
  }
}

final demoModeNotifierProvider = AsyncNotifierProvider<DemoModeNotifier, bool>(
  DemoModeNotifier.new,
);
