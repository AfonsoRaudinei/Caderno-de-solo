import 'package:flutter/foundation.dart';

/// Configuração central do Caderno de Solo.
///
/// O app opera somente com Firestore (dados reais).
abstract final class AppConfig {
  /// Firestore sempre ativo (dados reais).
  static const bool useFirestore = true;

  // ------------------------------------------------------------------ //
  //  Telemetria de operação (Fase 5 P1)
  // ------------------------------------------------------------------ //

  /// Endpoint HTTPS do coletor operacional de telemetria da Nova Análise.
  /// Exemplo: https://<collector>/v1/analise/events
  /// Quando vazio, não publica eventos remotos.
  static const String analiseTelemetryEndpoint = String.fromEnvironment(
    'ANALISE_TELEMETRY_ENDPOINT',
    defaultValue: '',
  );

  /// Chave opcional para autenticar no coletor de telemetria.
  static const String analiseTelemetryApiKey = String.fromEnvironment(
    'ANALISE_TELEMETRY_API_KEY',
    defaultValue: '',
  );

  /// Permite envio remoto também em debug (diagnóstico controlado).
  static const bool enableAnaliseTelemetryInDebug = bool.fromEnvironment(
    'ENABLE_ANALISE_TELEMETRY_IN_DEBUG',
    defaultValue: false,
  );

  static bool get hasAnaliseTelemetryEndpoint =>
      analiseTelemetryEndpoint.trim().isNotEmpty;

  // ------------------------------------------------------------------ //
  //  Ambiente
  // ------------------------------------------------------------------ //

  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;
  static bool get isProfile => kProfileMode;

  // ------------------------------------------------------------------ //
  //  Versão
  // ------------------------------------------------------------------ //

  static const String appVersion = '1.0.1';
  static const String appName = 'Caderno de Solo';
}
