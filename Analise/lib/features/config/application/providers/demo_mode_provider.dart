import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/config/data/datasources/demo_mode_hive_datasource.dart';
import 'package:soloforte/features/config/data/repositories/demo_mode_repository_impl.dart';
import 'package:soloforte/features/config/domain/repositories/demo_mode_repository.dart';
import 'package:soloforte/features/config/domain/usecases/demo_mode_usecases.dart';

// ── Datasource ────────────────────────────────────────────────────────────────

final demoModeHiveDatasourceProvider = Provider<DemoModeHiveDatasource>((ref) {
  return DemoModeHiveDatasource();
});

final demoModeRepositoryProvider = Provider<DemoModeRepository>((ref) {
  return DemoModeRepositoryImpl(ref.watch(demoModeHiveDatasourceProvider));
});

final getDemoModeUsecaseProvider = Provider<GetDemoModeUsecase>((ref) {
  return GetDemoModeUsecase(ref.watch(demoModeRepositoryProvider));
});

final setDemoModeUsecaseProvider = Provider<SetDemoModeUsecase>((ref) {
  return SetDemoModeUsecase(ref.watch(demoModeRepositoryProvider));
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class DemoModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return ref.read(getDemoModeUsecaseProvider).call();
  }

  Future<void> toggle() async {
    final current = await future;
    final next = !current;
    await ref.read(setDemoModeUsecaseProvider).call(next);
    state = AsyncData(next);
    ref.invalidateSelf();
  }
}

final demoModeNotifierProvider = AsyncNotifierProvider<DemoModeNotifier, bool>(
  DemoModeNotifier.new,
);
