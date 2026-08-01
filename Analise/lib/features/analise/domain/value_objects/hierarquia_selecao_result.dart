/// Resultado da seleção ou criação Cliente → Fazenda → Talhão.
class HierarquiaSelecaoResult {
  const HierarquiaSelecaoResult({
    required this.clienteId,
    required this.fazendaId,
    required this.talhaoId,
    required this.clienteNome,
    required this.fazendaNome,
    required this.talhaoNome,
  });

  final String clienteId;
  final String fazendaId;
  final String talhaoId;
  final String clienteNome;
  final String fazendaNome;
  final String talhaoNome;

  bool get isValid =>
      clienteId.trim().isNotEmpty &&
      fazendaId.trim().isNotEmpty &&
      talhaoId.trim().isNotEmpty &&
      clienteNome.trim().isNotEmpty &&
      fazendaNome.trim().isNotEmpty &&
      talhaoNome.trim().isNotEmpty;
}
