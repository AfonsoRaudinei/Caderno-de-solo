/// Sanitiza IDs para uso como document ID no Firestore.
///
/// Firestore interpreta `/` como separador de path; caracteres inválidos
/// causam falha na persistência.
String sanitizeFirestoreDocId(String id) {
  final trimmed = id.trim();
  if (trimmed.isEmpty) return trimmed;

  return trimmed
      .replaceAll('/', '_')
      .replaceAll('\\', '_')
      .replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '')
      .trim();
}
