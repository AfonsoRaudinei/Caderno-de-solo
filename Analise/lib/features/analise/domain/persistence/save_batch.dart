import 'dart:convert';

enum SaveBatchStatus {
  received,
  validating,
  persisting,
  committed,
  failed,
  compensated,
}

enum SaveStrategy { atomic, compensating }

enum SaveBatchCode {
  saveAtomicFailed,
  saveCompensated,
  saveIdempotentReplay,
  saveInProgress,
}

class SaveBatchResult {
  final String batchId;
  final String idempotencyKey;
  final SaveBatchStatus status;
  final SaveStrategy strategy;
  final int savedCount;
  final bool isReplay;
  final SaveBatchCode? code;

  const SaveBatchResult({
    required this.batchId,
    required this.idempotencyKey,
    required this.status,
    required this.strategy,
    required this.savedCount,
    required this.isReplay,
    this.code,
  });
}

class SaveBatchException implements Exception {
  final SaveBatchCode code;
  final String message;
  final String? batchId;
  final String? idempotencyKey;
  final Object? cause;

  const SaveBatchException({
    required this.code,
    required this.message,
    this.batchId,
    this.idempotencyKey,
    this.cause,
  });

  @override
  String toString() {
    final codeValue = switch (code) {
      SaveBatchCode.saveAtomicFailed => 'SAVE_ATOMIC_FAILED',
      SaveBatchCode.saveCompensated => 'SAVE_COMPENSATED',
      SaveBatchCode.saveIdempotentReplay => 'SAVE_IDEMPOTENT_REPLAY',
      SaveBatchCode.saveInProgress => 'SAVE_IN_PROGRESS',
    };
    return '$codeValue: $message';
  }
}

class SaveBatchIdempotency {
  const SaveBatchIdempotency._();

  static String build({
    required String userId,
    required List<Map<String, dynamic>> payloads,
    String? context,
  }) {
    final ordered = [...payloads]..sort(
        (a, b) =>
            ((a['id'] ?? '') as String).compareTo((b['id'] ?? '') as String),
      );
    final canonical = _canonicalize({
      'userId': userId,
      'context': context ?? '',
      'payloads': ordered,
    });
    return _fnv1a64Hex(canonical);
  }

  static String _canonicalize(dynamic value) {
    if (value is Map) {
      final keys = value.keys.map((k) => k.toString()).toList()..sort();
      final mapValue = value;
      final entries =
          keys.map((k) => '$k:${_canonicalize(mapValue[k])}').join(',');
      return '{$entries}';
    }
    if (value is List) {
      return '[${value.map(_canonicalize).join(',')}]';
    }
    return jsonEncode(value);
  }

  static String _fnv1a64Hex(String input) {
    const fnv64Offset = 0xcbf29ce484222325;
    const fnv64Prime = 0x100000001b3;
    var hash = fnv64Offset;

    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * fnv64Prime) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }
}
