class ConfigActionException implements Exception {
  const ConfigActionException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}
