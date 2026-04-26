import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:soloforte/core/config/app_config.dart';
import 'package:uuid/uuid.dart';

const analiseTelemetryVersion = '1.0.0';

abstract class AnaliseTelemetrySink {
  void emit(Map<String, Object?> event);
}

class CompositeAnaliseTelemetrySink implements AnaliseTelemetrySink {
  final List<AnaliseTelemetrySink> _sinks;

  const CompositeAnaliseTelemetrySink({
    required List<AnaliseTelemetrySink> sinks,
  }) : _sinks = sinks;

  @override
  void emit(Map<String, Object?> event) {
    for (final sink in _sinks) {
      sink.emit(event);
    }
  }
}

class DebugPrintAnaliseTelemetrySink implements AnaliseTelemetrySink {
  const DebugPrintAnaliseTelemetrySink();

  @override
  void emit(Map<String, Object?> event) {
    debugPrint('[analise_telemetry] ${jsonEncode(event)}');
  }
}

class HttpAnaliseTelemetrySink implements AnaliseTelemetrySink {
  final Dio _dio;
  final Uri _endpoint;
  final Duration _timeout;
  final String? _apiKey;

  HttpAnaliseTelemetrySink({
    required Dio dio,
    required Uri endpoint,
    String? apiKey,
    Duration timeout = const Duration(seconds: 3),
  })  : _dio = dio,
        _endpoint = endpoint,
        _apiKey =
            (apiKey == null || apiKey.trim().isEmpty) ? null : apiKey.trim(),
        _timeout = timeout;

  @override
  void emit(Map<String, Object?> event) {
    unawaited(_post(event));
  }

  Future<void> _post(Map<String, Object?> event) async {
    try {
      await _dio.postUri(
        _endpoint,
        data: event,
        options: Options(
          sendTimeout: _timeout,
          receiveTimeout: _timeout,
          headers: <String, Object?>{
            'Content-Type': 'application/json',
            if (_apiKey != null) 'X-API-Key': _apiKey,
          },
        ),
      );
    } on Object catch (error) {
      debugPrint('[analise_telemetry][http_sink_error] $error');
    }
  }
}

abstract final class AnaliseTelemetryEvents {
  static const String importStarted = 'import_started';
  static const String importExtractFinished = 'import_extract_finished';
  static const String importDetectFinished = 'import_detect_finished';
  static const String importParseFinished = 'import_parse_finished';
  static const String importValidateFinished = 'import_validate_finished';
  static const String importFallbackOpened = 'import_fallback_opened';
  static const String importFallbackSelectedLab =
      'import_fallback_selected_lab';
  static const String importCompleted = 'import_completed';
  static const String importFailed = 'import_failed';

  static const String saveStarted = 'save_started';
  static const String saveValidationBlocked = 'save_validation_blocked';
  static const String savePersisting = 'save_persisting';
  static const String saveCommitted = 'save_committed';
  static const String saveFailed = 'save_failed';
  static const String saveCompensated = 'save_compensated';
  static const String saveIdempotentReplay = 'save_idempotent_replay';

  static const Set<String> critical = {
    importStarted,
    importCompleted,
    importFailed,
    saveStarted,
    saveCommitted,
    saveFailed,
    saveCompensated,
    saveIdempotentReplay,
  };
}

class AnaliseTelemetry {
  static final String _sharedSessionId = _newId(prefix: 'sess');

  final AnaliseTelemetrySink _sink;
  final DateTime Function() _now;
  final String Function() _operationIdFactory;
  final String _appVersion;
  final String _platform;
  final String _environment;

  AnaliseTelemetry({
    AnaliseTelemetrySink sink = const DebugPrintAnaliseTelemetrySink(),
    DateTime Function()? now,
    String Function()? operationIdFactory,
    String appVersion = AppConfig.appVersion,
    String? platform,
    String? environment,
  })  : _sink = sink,
        _now = now ?? DateTime.now,
        _operationIdFactory =
            operationIdFactory ?? (() => _newId(prefix: 'op')),
        _appVersion = appVersion,
        _platform = platform ?? _resolvePlatform(),
        _environment = environment ?? _resolveEnvironment();

  @visibleForTesting
  AnaliseTelemetrySink get sink => _sink;

  String newOperationId() => _operationIdFactory();

  void emit({
    required String eventName,
    required String operationId,
    String? labId,
    int? columnCount,
    String? batchId,
    String? idempotencyKeyHash,
    String? status,
    String? errorCode,
    int? durationMs,
    double? confidence,
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    final event = <String, Object?>{
      'telemetryVersion': analiseTelemetryVersion,
      'eventName': eventName,
      'timestampUtc': _now().toUtc().toIso8601String(),
      'operationId': operationId,
      'sessionId': _sharedSessionId,
      'appVersion': _appVersion,
      'platform': _platform,
      'environment': _environment,
      if (labId != null && labId.trim().isNotEmpty) 'labId': labId.trim(),
      if (columnCount != null) 'columnCount': columnCount,
      if (batchId != null && batchId.trim().isNotEmpty) 'batchId': batchId,
      if (idempotencyKeyHash != null && idempotencyKeyHash.trim().isNotEmpty)
        'idempotencyKeyHash': idempotencyKeyHash,
      if (status != null && status.trim().isNotEmpty) 'status': status,
      if (errorCode != null && errorCode.trim().isNotEmpty)
        'errorCode': errorCode,
      if (durationMs != null) 'durationMs': durationMs,
      if (confidence != null) 'confidence': confidence,
    };

    final sanitized = _sanitizeContext(context);
    for (final entry in sanitized.entries) {
      if (event.containsKey(entry.key)) continue;
      event[entry.key] = entry.value;
    }
    _sink.emit(event);
  }

  String hashIdentifier(String raw) {
    if (raw.trim().isEmpty) return '';
    return _fnv1a64Hex(raw.trim());
  }

  static Map<String, Object?> _sanitizeContext(Map<String, Object?> raw) {
    final out = <String, Object?>{};
    for (final entry in raw.entries) {
      final key = entry.key;
      final normalizedKey = key.toLowerCase();
      if (_piiKeys.contains(normalizedKey)) {
        continue;
      }
      if (normalizedKey == 'idempotencykey') {
        final value = entry.value?.toString() ?? '';
        out['idempotencyKeyHash'] = _fnv1a64Hex(value);
        continue;
      }
      out[key] = _normalizeValue(entry.value);
    }
    return out;
  }

  static Object? _normalizeValue(Object? value) {
    if (value == null || value is num || value is bool || value is String) {
      return value;
    }
    if (value is Iterable) {
      return value.map(_normalizeValue).toList(growable: false);
    }
    if (value is Map) {
      final converted = <String, Object?>{};
      value.forEach((k, v) {
        converted[k.toString()] = _normalizeValue(v);
      });
      return converted;
    }
    return value.toString();
  }

  static const Set<String> _piiKeys = {
    'produtor',
    'fazenda',
    'talhao',
    'nomearea',
    'propriedade',
    'proprietario',
    'municipio',
  };

  static String _resolveEnvironment() {
    if (AppConfig.isRelease) return 'production';
    if (AppConfig.isProfile) return 'staging';
    return 'development';
  }

  static String _resolvePlatform() {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name;
  }

  static String _newId({required String prefix}) {
    final randomPart = Random().nextInt(1 << 32).toRadixString(16);
    return '$prefix-${const Uuid().v4()}-$randomPart';
  }

  static String _fnv1a64Hex(String input) {
    final fnv64Offset = BigInt.parse('cbf29ce484222325', radix: 16);
    final fnv64Prime = BigInt.parse('100000001b3', radix: 16);
    final mask64 = BigInt.parse('ffffffffffffffff', radix: 16);
    var hash = fnv64Offset;
    for (final codeUnit in input.codeUnits) {
      hash ^= BigInt.from(codeUnit);
      hash = (hash * fnv64Prime) & mask64;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }
}
