import 'package:flutter/foundation.dart';

/// Configuração central do Caderno de Solo.
///
/// [useFirestore] controla qual datasource está ativo:
///   - Padrão (sem flags) -> usa Firestore (real) em todos os modos.
///   - Diagnóstico interno -> mock local apenas com flag explícita:
///     `--dart-define=ANALISE_MOCK_MODE=true`
///
/// Nunca exponha essa flag na UI; é estritamente interna e temporária.
abstract final class AppConfig {
  // ------------------------------------------------------------------ //
  //  Datasource toggle
  // ------------------------------------------------------------------ //

  /// Habilita datasource mock somente para diagnóstico interno.
  /// Default `false` para manter o fluxo principal 100% real.
  static const bool useAnaliseMockMode = bool.fromEnvironment(
    'ANALISE_MOCK_MODE',
    defaultValue: false,
  );

  /// Mock só pode rodar fora de release.
  /// Garante Firestore real em builds de produção/App Store.
  static bool get allowAnaliseMockMode => !kReleaseMode && useAnaliseMockMode;

  /// `true`  -> Firestore ativo (dados reais)
  /// `false` -> Mock local ativo (somente diagnóstico explícito fora de release)
  static bool get useFirestore => !allowAnaliseMockMode;

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
