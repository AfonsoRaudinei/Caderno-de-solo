import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/converters/timestamp_converter.dart';

void main() {
  const converter = TimestampConverter();

  group('TimestampConverter', () {
    test('aceita ISO-8601, epoch e DateTime', () {
      final iso = converter.fromJson('2026-07-31T12:00:00.000Z');
      expect(iso, isNotNull);

      final epoch = converter.fromJson(0);
      expect(epoch, DateTime.fromMillisecondsSinceEpoch(0));

      final now = DateTime(2026, 7, 31);
      expect(converter.fromJson(now), now);
    });

    test('aceita mapa seconds/nanoseconds estilo Firestore', () {
      final date = converter.fromJson({
        '_seconds': 0,
        '_nanoseconds': 0,
      });
      expect(date, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('toJson preserva DateTime (sem Timestamp do Firestore)', () {
      final now = DateTime(2026, 7, 31, 10, 30);
      expect(converter.toJson(now), now);
      expect(converter.toJson(null), isNull);
    });
  });
}
