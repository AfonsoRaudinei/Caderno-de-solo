import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/analise/application/observability/analise_telemetry.dart';
import 'package:soloforte/features/analise/application/providers/analise_telemetry_provider.dart';

void main() {
  test('provider usa sink de debug no caminho padrão sem endpoint remoto', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final telemetry = container.read(analiseTelemetryProvider);
    expect(telemetry.sink, isA<DebugPrintAnaliseTelemetrySink>());
  });
}
