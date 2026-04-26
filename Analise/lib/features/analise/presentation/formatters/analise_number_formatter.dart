class AnaliseNumberFormatter {
  const AnaliseNumberFormatter._();

  static String formatDecimal(
    num? value, {
    int decimals = 3,
    bool keepIntegers = true,
  }) {
    if (value == null) return '-';

    final asDouble = value.toDouble();
    if (asDouble.isNaN || asDouble.isInfinite) return '-';

    if (keepIntegers && asDouble == asDouble.truncateToDouble()) {
      return asDouble.toStringAsFixed(0);
    }

    return asDouble.toStringAsFixed(decimals);
  }
}
