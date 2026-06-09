import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/config/application/providers/config_providers.dart';
import 'package:soloforte/features/config/domain/entities/app_theme_mode.dart';

class AppThemeModeNotifier extends AsyncNotifier<AppThemeMode> {
  @override
  Future<AppThemeMode> build() {
    return ref.read(getThemeModeUsecaseProvider).call();
  }

  Future<void> setBlackMode(bool enabled) async {
    final mode = enabled ? AppThemeMode.black : AppThemeMode.light;
    await ref.read(setThemeModeUsecaseProvider).call(mode);
    state = AsyncData(mode);
  }
}

final appThemeModeProvider =
    AsyncNotifierProvider<AppThemeModeNotifier, AppThemeMode>(
  AppThemeModeNotifier.new,
);

extension AppThemeModeMaterial on AppThemeMode {
  ThemeMode get materialThemeMode {
    return switch (this) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.black => ThemeMode.dark,
    };
  }
}
