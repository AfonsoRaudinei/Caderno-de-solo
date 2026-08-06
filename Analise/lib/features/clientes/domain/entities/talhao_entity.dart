class TalhaoEntity {
  final String id;
  final String nome;
  final double area;
  final double? latitude;
  final double? longitude;
  final String? culturaPrincipal;
  final DateTime criadoEm;

  const TalhaoEntity({
    required this.id,
    required this.nome,
    required this.area,
    this.latitude,
    this.longitude,
    this.culturaPrincipal,
    required this.criadoEm,
  });

  TalhaoEntity copyWith({
    String? id,
    String? nome,
    double? area,
    double? latitude,
    double? longitude,
    String? culturaPrincipal,
    DateTime? criadoEm,
  }) {
    return TalhaoEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      culturaPrincipal: culturaPrincipal ?? this.culturaPrincipal,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
      'culturaPrincipal': culturaPrincipal,
      'criadoEm': criadoEm,
    };
  }

  factory TalhaoEntity.fromMap(Map<String, dynamic> map) {
    return TalhaoEntity(
      id: (map['id'] as String?) ?? '',
      nome: (map['nome'] as String?) ?? '',
      area: (map['area'] as num?)?.toDouble() ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      culturaPrincipal: map['culturaPrincipal'] as String?,
      criadoEm: _toDateTime(map['criadoEm']),
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TalhaoEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
