import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/core/config/app_config.dart';

void main() {
  test('AppConfig usa Firestore por padrão sem flags explícitas', () {
    expect(AppConfig.useFirestore, isTrue);
  });

  test('telemetria remota fica desativada sem endpoint explícito', () {
    expect(AppConfig.analiseTelemetryEndpoint, isEmpty);
    expect(AppConfig.hasAnaliseTelemetryEndpoint, isFalse);
    expect(AppConfig.enableAnaliseTelemetryInDebug, isFalse);
  });
}
