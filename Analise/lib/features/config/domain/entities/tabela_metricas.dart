/// Modelo de domínio que representa uma tabela de métricas agronômicas
/// persistível e editável pelo módulo Configurações.
///
/// Cada [TabelaMetricas] é identificada por [chave] (ex: 'fosforo_nc_resina')
/// e agrupa um conjunto de [linhas] que mapeiam faixas texturais ou de argila
/// para valores numéricos de referência (ex: NC, FEP, FEK).
///
/// Isso permite que um Agrônomo Administrador altere os valores pela UI
/// sem nenhuma atualização de código ou envio de nova versão à App Store.
class TabelaMetricas {
  const TabelaMetricas({
    required this.id,
    required this.chave,
    required this.nome,
    required this.descricao,
    required this.unidade,
    required this.linhas,
    required this.updatedAt,
    this.userId = '',
  });

  /// ID único do documento (uuid v4).
  final String id;

  /// Chave canônica usada pelo motor para buscar a tabela.
  /// Exemplos: 'fosforo_nc_resina', 'fosforo_nc_mehlich', 'potassio_nc_teor',
  ///           'fosforo_fep', 'fosforo_fator_solo', 'potassio_fek'
  final String chave;

  /// Nome legível para exibição na UI de Configurações.
  final String nome;

  /// Descrição técnica da tabela (fonte bibliográfica).
  final String descricao;

  /// Unidade das linhas (ex: 'mg/dm³', '%', 'cmolc/dm³').
  final String unidade;

  /// Linhas da tabela: cada linha é um Map com ao menos:
  ///   - 'faixa': descrição textual (ex: '<15%', '15–35%')
  ///   - 'valor': double
  ///   - Opcionalmente 'argilaMin' e 'argilaMax' para busca programática.
  final List<Map<String, dynamic>> linhas;

  final DateTime updatedAt;

  /// Se vazio: tabela global (padrão do sistema).
  /// Se preenchido: customização por usuário.
  final String userId;

  // ── Busca de valor ────────────────────────────────────────────────────────

  /// Retorna o valor da tabela para [argilaPercent].
  /// Busca pela linha onde argilaMin <= argila < argilaMax.
  /// Se não encontrar correspondência, retorna [fallback].
  double valorParaArgila(double argilaPercent, {required double fallback}) {
    for (final linha in linhas) {
      final min = _asDouble(linha['argilaMin']);
      final max = _asDouble(linha['argilaMax']);
      if (argilaPercent >= min && argilaPercent < max) {
        return _asDouble(linha['valor'], fallback: fallback);
      }
    }
    // Última linha como fallback (muito argiloso)
    if (linhas.isNotEmpty) {
      return _asDouble(linhas.last['valor'], fallback: fallback);
    }
    return fallback;
  }

  // ── Serialização ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'chave': chave,
        'nome': nome,
        'descricao': descricao,
        'unidade': unidade,
        'linhas': linhas,
        'updatedAt': updatedAt.toIso8601String(),
        'userId': userId,
      };

  factory TabelaMetricas.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parseLinhas(dynamic v) {
      if (v is List) {
        return v
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    }

    return TabelaMetricas(
      id: (json['id'] ?? '').toString(),
      chave: (json['chave'] ?? '').toString(),
      nome: (json['nome'] ?? '').toString(),
      descricao: (json['descricao'] ?? '').toString(),
      unidade: (json['unidade'] ?? '').toString(),
      linhas: parseLinhas(json['linhas']),
      updatedAt: _parseDate(json['updatedAt']),
      userId: (json['userId'] ?? '').toString(),
    );
  }

  TabelaMetricas copyWith({
    String? id,
    String? chave,
    String? nome,
    String? descricao,
    String? unidade,
    List<Map<String, dynamic>>? linhas,
    DateTime? updatedAt,
    String? userId,
  }) {
    return TabelaMetricas(
      id: id ?? this.id,
      chave: chave ?? this.chave,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      unidade: unidade ?? this.unidade,
      linhas: linhas ?? this.linhas,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static double _asDouble(dynamic v, {double fallback = 0}) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static DateTime _parseDate(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }
}
