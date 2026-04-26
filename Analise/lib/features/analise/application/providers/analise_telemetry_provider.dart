import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/config/app_config.dart';
import 'package:soloforte/features/analise/application/observability/analise_telemetry.dart';

final analiseTelemetryProvider = Provider<AnaliseTelemetry>(
  (ref) {
    final sinks = <AnaliseTelemetrySink>[];
    final allowRemote = AppConfig.isRelease ||
        AppConfig.isProfile ||
        AppConfig.enableAnaliseTelemetryInDebug;

    if (allowRemote && AppConfig.hasAnaliseTelemetryEndpoint) {
      final endpoint = Uri.tryParse(AppConfig.analiseTelemetryEndpoint.trim());
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
            apiKey: AppConfig.analiseTelemetryApiKey,
          ),
        );
      }
    }

    // Mantém trilha local visível em debug e fallback explícito quando remoto não está configurado.
    if (!AppConfig.isRelease || sinks.isEmpty) {
      sinks.add(const DebugPrintAnaliseTelemetrySink());
    }

    final sink = sinks.length == 1
        ? sinks.first
        : CompositeAnaliseTelemetrySink(sinks: sinks);
    return AnaliseTelemetry(sink: sink);
  },
);
