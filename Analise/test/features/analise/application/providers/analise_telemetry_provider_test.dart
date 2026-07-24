import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/analise/application/observability/analise_telemetry.dart';
import 'package:soloforte/features/analise/application/providers/analise_telemetry_provider.dart';

void main() {
  test('provider usa sink de debug no caminho padrão sem autorização remota',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final telemetry = container.read(analiseTelemetryProvider);
    expect(telemetry.sink, isA<DebugPrintAnaliseTelemetrySink>());
  });

  test(
      'provider mantém sink local mesmo com endpoint se autorização remota faltar',
      () {
    final container = ProviderContainer(
      overrides: [
        analiseTelemetryPolicyProvider.overrideWithValue(
          const AnaliseTelemetryPolicy(
            allowRemote: false,
            allowRemoteInDebug: true,
            endpoint: 'https://collector.example/v1/analise/events',
            apiKey: 'secret',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final telemetry = container.read(analiseTelemetryProvider);
    expect(telemetry.sink, isA<DebugPrintAnaliseTelemetrySink>());
  });

  test('provider habilita sink remoto somente com autorização explícita', () {
    final container = ProviderContainer(
      overrides: [
        analiseTelemetryPolicyProvider.overrideWithValue(
          const AnaliseTelemetryPolicy(
            allowRemote: true,
            allowRemoteInDebug: true,
            endpoint: 'https://collector.example/v1/analise/events',
            apiKey: 'secret',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final telemetry = container.read(analiseTelemetryProvider);
    expect(telemetry.sink, isA<CompositeAnaliseTelemetrySink>());
  });
}
