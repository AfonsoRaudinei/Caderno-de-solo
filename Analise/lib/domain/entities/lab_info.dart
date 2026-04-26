class LabInfo {
  final String id;
  final String nome;
  final String? cnpj;
  final Map<String, String> extratores;

  const LabInfo({
    required this.id,
    required this.nome,
    this.cnpj,
    required this.extratores,
  });
}
