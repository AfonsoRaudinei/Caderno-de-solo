import 'package:flutter/foundation.dart';

/// Configuração central do SoloForte.
///
/// [useFirestore] controla qual datasource está ativo:
///   - Em DEBUG (`kDebugMode == true`)  -> usa mock local por padrão
///   - Em RELEASE (`kDebugMode == false`) -> usa Firestore (real)
///
/// Para forçar Firestore mesmo em debug (ex.: teste de integração local),
/// execute com:
/// `--dart-define=FORCE_FIRESTORE_IN_DEBUG=true`
///
/// Nunca exponha essa flag na UI; é estritamente interna.
abstract final class AppConfig {
  // ------------------------------------------------------------------ //
  //  Datasource toggle
  // ------------------------------------------------------------------ //

  /// Força Firestore quando o app roda em debug.
  ///
  /// Default `false` para manter testes locais sem dependência de rede.
  static const bool _forceFirestoreInDebug = bool.fromEnvironment(
    'FORCE_FIRESTORE_IN_DEBUG',
    defaultValue: false,
  );

  /// `true`  -> Firestore ativo (dados reais)
  /// `false` -> Mock local ativo (dados em memória)
  static bool get useFirestore => !kDebugMode || _forceFirestoreInDebug;

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
  static const String appName = 'SoloForte';
}
