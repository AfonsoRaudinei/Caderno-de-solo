import 'dart:math';

class TokenGenerator {
  TokenGenerator._();

  static const String _prefix = 'SF';
  static const String _charset = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static final Random _random = Random.secure();

  static String generate({DateTime? now}) {
    final year = (now ?? DateTime.now()).year;
    final suffix = List.generate(
      4,
      (_) => _charset[_random.nextInt(_charset.length)],
    ).join();
    return '$_prefix-$year-$suffix';
  }
}
