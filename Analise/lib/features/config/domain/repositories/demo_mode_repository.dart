abstract class DemoModeRepository {
  Future<bool> isEnabled();

  Future<void> setEnabled(bool value);
}
