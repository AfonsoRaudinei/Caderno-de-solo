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

  /// Senha de acesso ao módulo Cálculos (gate interno).
  /// Definir em build/CI via `--dart-define=CALCULOS_ACCESS_PASSWORD=...`.
  /// Quando vazia, o acesso é negado.
  static const String calculosAccessPassword = String.fromEnvironment(
    'CALCULOS_ACCESS_PASSWORD',
    defaultValue: '',
  );

  /// Autoriza explicitamente qualquer envio remoto de telemetria operacional.
  ///
  /// Sem esta flag, a aplicação mantém trilha apenas local e não publica
  /// eventos para fora do app, mesmo em profile/release.
  static const bool allowRemoteAnaliseTelemetry = bool.fromEnvironment(
    'ALLOW_REMOTE_ANALISE_TELEMETRY',
    defaultValue: false,
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
