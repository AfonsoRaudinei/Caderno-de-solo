class CoordinatePair {
  final double latitude;
  final double longitude;

  const CoordinatePair({
    required this.latitude,
    required this.longitude,
  });
}

class CoordinateFormatter {
  static CoordinatePair? parseCombined(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final match = RegExp(
      r'^\s*([+-]?\d+(?:[\.,]\d+)?)\s*[,;]\s*([+-]?\d+(?:[\.,]\d+)?)\s*$',
    ).firstMatch(trimmed);
    if (match == null) return null;

    final lat = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    final lng = double.tryParse(match.group(2)!.replaceAll(',', '.'));
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;

    return CoordinatePair(latitude: lat, longitude: lng);
  }

  static String formatCombined(num? latitude, num? longitude) {
    if (latitude == null && longitude == null) return '';
    if (latitude == null) return formatDecimal(longitude!);
    if (longitude == null) return formatDecimal(latitude);
    return '${formatDecimal(latitude)}, ${formatDecimal(longitude)}';
  }

  static String formatDecimal(num value) => value.toStringAsFixed(6);
}
