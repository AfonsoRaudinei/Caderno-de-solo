enum AppThemeMode {
  system('system'),
  light('light'),
  black('black');

  const AppThemeMode(this.storageKey);

  final String storageKey;

  bool get isBlack => this == AppThemeMode.black;

  static AppThemeMode fromStorageKey(String? value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.storageKey == value,
      orElse: () => AppThemeMode.system,
    );
  }
}
