import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/config/app_config.dart';
import 'package:soloforte/features/analise/application/observability/analise_telemetry.dart';

class AnaliseTelemetryPolicy {
  final bool allowRemote;
  final bool allowRemoteInDebug;
  final String endpoint;
  final String apiKey;

  const AnaliseTelemetryPolicy({
    required this.allowRemote,
    required this.allowRemoteInDebug,
    required this.endpoint,
    required this.apiKey,
  });

  bool get hasEndpoint => endpoint.trim().isNotEmpty;
}

final analiseTelemetryPolicyProvider = Provider<AnaliseTelemetryPolicy>(
  (ref) {
    return const AnaliseTelemetryPolicy(
      allowRemote: AppConfig.allowRemoteAnaliseTelemetry,
      allowRemoteInDebug: AppConfig.enableAnaliseTelemetryInDebug,
      endpoint: AppConfig.analiseTelemetryEndpoint,
      apiKey: AppConfig.analiseTelemetryApiKey,
    );
  },
);

final analiseTelemetryProvider = Provider<AnaliseTelemetry>(
  (ref) {
    final sinks = <AnaliseTelemetrySink>[];
    final policy = ref.watch(analiseTelemetryPolicyProvider);
    final allowRemote = policy.allowRemote &&
        (AppConfig.isRelease ||
            AppConfig.isProfile ||
            policy.allowRemoteInDebug);

    if (allowRemote && policy.hasEndpoint) {
      final endpoint = Uri.tryParse(policy.endpoint.trim());
      if (endpoint != null && endpoint.hasScheme && endpoint.hasAuthority) {
        sinks.add(
          HttpAnaliseTelemetrySink(
            dio: Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 3),
                sendTimeout: const Duration(seconds: 3),
                receiveTimeout: const Duration(seconds: 3),
              ),
            ),
            endpoint: endpoint,
            apiKey: policy.apiKey,
          ),
        );
      }
    }

    // Sem autorização explícita, eventos não saem do app.
    if (!AppConfig.isRelease || sinks.isEmpty) {
      sinks.add(const DebugPrintAnaliseTelemetrySink());
    }

    final sink = sinks.length == 1
        ? sinks.first
        : CompositeAnaliseTelemetrySink(sinks: sinks);
    return AnaliseTelemetry(sink: sink);
  },
);
