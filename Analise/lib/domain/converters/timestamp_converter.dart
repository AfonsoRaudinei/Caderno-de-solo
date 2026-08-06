import 'package:freezed_annotation/freezed_annotation.dart';

/// Conversor JSON ↔ DateTime sem depender de `cloud_firestore`.
///
/// Aceita Timestamp do Firestore via duck-typing (`toDate()`), ISO-8601,
/// epoch millis e mapas `{seconds,_seconds}`.
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is DateTime) return json;
    if (json is String) return DateTime.tryParse(json);
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    if (json is double) {
      return DateTime.fromMillisecondsSinceEpoch(json.toInt());
    }

    final dynamic value = json;
    try {
      final toDate = value.toDate;
      if (toDate is Function) {
        final result = toDate.call();
        if (result is DateTime) return result;
      }
    } catch (_) {}

    if (json is Map) {
      final seconds = json['_seconds'] ?? json['seconds'];
      final nanos = json['_nanoseconds'] ?? json['nanoseconds'] ?? 0;
      if (seconds is int) {
        final nanoMs = nanos is int ? nanos ~/ 1000000 : 0;
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + nanoMs);
      }
    }

    return null;
  }

  @override
  Object? toJson(DateTime? object) => object;
}
