import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:soloforte/core/config/app_config.dart';

/// Camada central de observabilidade:
/// - captura global de erros
/// - crash reporting
/// - telemetria de performance (traces customizados)
class AppObservability {
  AppObservability._();

  static final AppObservability instance = AppObservability._();

  static const bool _enableCrashInDebug = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING_IN_DEBUG',
    defaultValue: false,
  );

  static const bool _enablePerfInDebug = bool.fromEnvironment(
    'ENABLE_PERFORMANCE_TELEMETRY_IN_DEBUG',
    defaultValue: false,
  );

  bool _initialized = false;
  bool _crashEnabled = false;
  bool _perfEnabled = false;

  bool get crashEnabled => _crashEnabled;
  bool get perfEnabled => _perfEnabled;

  Future<void> initialize() async {
    if (_initialized) return;

    final firebaseReady = Firebase.apps.isNotEmpty;
    _crashEnabled =
        firebaseReady && !kIsWeb && (kReleaseMode || _enableCrashInDebug);
    _perfEnabled =
        firebaseReady && !kIsWeb && (kReleaseMode || _enablePerfInDebug);

    if (_crashEnabled) {
      final crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCrashlyticsCollectionEnabled(true);
      await crashlytics.setCustomKey('app_name', AppConfig.appName);
      await crashlytics.setCustomKey('app_version', AppConfig.appVersion);
      await crashlytics.setCustomKey('build_mode', _buildModeLabel);
    }

    if (_perfEnabled) {
      await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    }

    _initialized = true;
  }

  void installGlobalHandlers() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      unawaited(
        recordFlutterError(
          details,
          fatal: true,
          reason: 'flutter_error',
        ),
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(
        recordError(
          error,
          stack,
          fatal: true,
          reason: 'platform_dispatcher',
        ),
      );
      return true;
    };
  }

  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
    String? reason,
  }) async {
    if (!_crashEnabled) return;

    if (reason != null && reason.isNotEmpty) {
      FirebaseCrashlytics.instance.log(reason);
    }

    if (fatal) {
      await FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      return;
    }
    await FirebaseCrashlytics.instance.recordFlutterError(details);
  }

  Future<void> recordError(
    Object error,
    StackTrace stack, {
    bool fatal = false,
    String? reason,
    Map<String, Object?> extras = const {},
  }) async {
    if (!_crashEnabled) return;

    final crashlytics = FirebaseCrashlytics.instance;
    if (reason != null && reason.isNotEmpty) {
      crashlytics.log(reason);
    }
    for (final entry in extras.entries) {
      await crashlytics.setCustomKey(entry.key, _normalize(entry.value));
    }
    await crashlytics.recordError(
      error,
      stack,
      fatal: fatal,
      reason: reason,
    );
  }

  Future<T> trace<T>(
    String name,
    Future<T> Function() action, {
    Map<String, String> attributes = const {},
  }) async {
    if (!_perfEnabled) {
      return action();
    }

    final traceName = _sanitizeTraceName(name);
    final trace = FirebasePerformance.instance.newTrace(traceName);
    await trace.start();

    for (final entry in attributes.entries) {
      trace.putAttribute(entry.key, entry.value);
    }

    final sw = Stopwatch()..start();
    try {
      final result = await action();
      trace.setMetric('ok', 1);
      return result;
    } finally {
      sw.stop();
      trace.setMetric('duration_ms', sw.elapsedMilliseconds);
      await trace.stop();
    }
  }

  String get _buildModeLabel {
    if (kReleaseMode) return 'release';
    if (kProfileMode) return 'profile';
    return 'debug';
  }

  Object _normalize(Object? value) {
    if (value is String || value is num || value is bool) return value!;
    if (value == null) return 'null';
    return value.toString();
  }

  String _sanitizeTraceName(String raw) {
    final base = raw.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    if (base.isEmpty) return 'trace_default';
    if (base.length > 100) return base.substring(0, 100);
    return base;
  }
}
