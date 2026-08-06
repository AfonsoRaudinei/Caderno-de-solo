/// Exceção de domínio para sessão inválida / sem permissão no módulo Clientes.
class ClienteSessionException implements Exception {
  const ClienteSessionException();

  @override
  String toString() => 'Sessão inválida. Entre novamente.';
}
