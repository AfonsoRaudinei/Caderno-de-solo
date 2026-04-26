class CalibracaoProfile {
  const CalibracaoProfile({
    required this.id,
    required this.nome,
    required this.cultura,
    required this.safra,
    required this.cliente,
    required this.fazenda,
    required this.talhao,
    required this.observacoes,
    required this.parametrosCards,
    required this.createdAt,
    required this.updatedAt,
    this.produtividadeEsperadaTha,
  });

  final String id;
  final String nome;
  final String cultura;
  final String safra;
  final String cliente;
  final String fazenda;
  final String talhao;
  final String observacoes;
  final Map<String, dynamic> parametrosCards;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Produtividade esperada em t/ha. Null = não configurado.
  /// A UI pode exibir em sacas/ha (1 t = 16.667 sc) mas persiste sempre em t/ha.
  final double? produtividadeEsperadaTha;

  CalibracaoProfile copyWith({
    String? id,
    String? nome,
    String? cultura,
    String? safra,
    String? cliente,
    String? fazenda,
    String? talhao,
    String? observacoes,
    Map<String, dynamic>? parametrosCards,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? produtividadeEsperadaTha,
  }) {
    return CalibracaoProfile(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cultura: cultura ?? this.cultura,
      safra: safra ?? this.safra,
      cliente: cliente ?? this.cliente,
      fazenda: fazenda ?? this.fazenda,
      talhao: talhao ?? this.talhao,
      observacoes: observacoes ?? this.observacoes,
      parametrosCards: parametrosCards ?? this.parametrosCards,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      produtividadeEsperadaTha:
          produtividadeEsperadaTha ?? this.produtividadeEsperadaTha,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cultura': cultura,
      'safra': safra,
      'cliente': cliente,
      'fazenda': fazenda,
      'talhao': talhao,
      'observacoes': observacoes,
      'parametrosCards': parametrosCards,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'produtividadeEsperadaTha': produtividadeEsperadaTha,
    };
  }

  factory CalibracaoProfile.fromJson(Map<String, dynamic> json) {
    return CalibracaoProfile(
      id: (json['id'] ?? '').toString(),
      nome: (json['nome'] ?? '').toString(),
      cultura: (json['cultura'] ?? '').toString(),
      safra: (json['safra'] ?? '').toString(),
      cliente: (json['cliente'] ?? '').toString(),
      fazenda: (json['fazenda'] ?? '').toString(),
      talhao: (json['talhao'] ?? '').toString(),
      observacoes: (json['observacoes'] ?? '').toString(),
      parametrosCards: Map<String, dynamic>.from(
        (json['parametrosCards'] as Map?) ?? const {},
      ),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      produtividadeEsperadaTha:
          (json['produtividadeEsperadaTha'] as num?)?.toDouble(),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
