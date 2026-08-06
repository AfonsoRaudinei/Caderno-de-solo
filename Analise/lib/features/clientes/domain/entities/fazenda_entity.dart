import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';

class FazendaEntity {
  final String id;
  final String nome;
  final double areaTotal;
  final List<TalhaoEntity> talhoes;
  final DateTime criadoEm;

  const FazendaEntity({
    required this.id,
    required this.nome,
    required this.areaTotal,
    this.talhoes = const [],
    required this.criadoEm,
  });

  FazendaEntity copyWith({
    String? id,
    String? nome,
    double? areaTotal,
    List<TalhaoEntity>? talhoes,
    DateTime? criadoEm,
  }) {
    return FazendaEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      areaTotal: areaTotal ?? this.areaTotal,
      talhoes: talhoes ?? this.talhoes,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'areaTotal': areaTotal,
      'talhoes': talhoes.map((talhao) => talhao.toMap()).toList(),
      'criadoEm': criadoEm,
    };
  }

  factory FazendaEntity.fromMap(Map<String, dynamic> map) {
    return FazendaEntity(
      id: (map['id'] as String?) ?? '',
      nome: (map['nome'] as String?) ?? '',
      areaTotal: (map['areaTotal'] as num?)?.toDouble() ?? 0,
      talhoes: ((map['talhoes'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => TalhaoEntity.fromMap(Map<String, dynamic>.from(item)))
          .toList(growable: false),
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
      identical(this, other) || other is FazendaEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
