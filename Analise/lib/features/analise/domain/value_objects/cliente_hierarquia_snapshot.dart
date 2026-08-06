/// Snapshot imutável da hierarquia de clientes para resolução de vínculos.
class ClienteHierarquiaSnapshot {
  const ClienteHierarquiaSnapshot({
    required this.id,
    required this.nome,
    this.fazendas = const [],
  });

  final String id;
  final String nome;
  final List<FazendaHierarquiaSnapshot> fazendas;
}

class FazendaHierarquiaSnapshot {
  const FazendaHierarquiaSnapshot({
    required this.id,
    required this.nome,
    this.talhoes = const [],
  });

  final String id;
  final String nome;
  final List<TalhaoHierarquiaSnapshot> talhoes;
}

class TalhaoHierarquiaSnapshot {
  const TalhaoHierarquiaSnapshot({
    required this.id,
    required this.nome,
  });

  final String id;
  final String nome;
}
