/// Exceção de domínio para falhas de autorização/sessão em datasources remotas.
///
/// Mantém FirebaseException fora da UI/camada de apresentação.
class PermissionDeniedException implements Exception {
  const PermissionDeniedException([
    this.message = 'Sessão inválida ou sem permissão. Faça login novamente.',
  ]);

  final String message;

  @override
  String toString() => 'PermissionDeniedException: $message';
}
