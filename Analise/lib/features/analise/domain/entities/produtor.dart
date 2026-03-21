class Produtor {
  final String id;
  final String nome;
  final String fazenda;
  final int totalAnalises;

  const Produtor({
    required this.id,
    required this.nome,
    required this.fazenda,
    this.totalAnalises = 0,
  });
}
