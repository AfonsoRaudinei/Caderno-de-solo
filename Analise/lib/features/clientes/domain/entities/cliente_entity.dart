import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';

class ClienteEntity {
  final String id;
  final String token;
  final String nome;
  final String telefone;
  final String email;
  final String cidade;
  final String estado;
  final String? observacoes;
  final List<FazendaEntity> fazendas;
  final String usuarioId;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final List<String> analiseIds;

  const ClienteEntity({
    required this.id,
    required this.token,
    required this.nome,
    required this.telefone,
    required this.email,
    required this.cidade,
    required this.estado,
    this.observacoes,
    this.fazendas = const [],
    required this.usuarioId,
    required this.criadoEm,
    required this.atualizadoEm,
    this.analiseIds = const [],
  });

  ClienteEntity copyWith({
    String? id,
    String? token,
    String? nome,
    String? telefone,
    String? email,
    String? cidade,
    String? estado,
    String? observacoes,
    List<FazendaEntity>? fazendas,
    String? usuarioId,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    List<String>? analiseIds,
  }) {
    return ClienteEntity(
      id: id ?? this.id,
      token: token ?? this.token,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      observacoes: observacoes ?? this.observacoes,
      fazendas: fazendas ?? this.fazendas,
      usuarioId: usuarioId ?? this.usuarioId,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      analiseIds: analiseIds ?? this.analiseIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'token': token,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'cidade': cidade,
      'estado': estado,
      'observacoes': observacoes,
      'fazendas': fazendas.map((fazenda) => fazenda.toMap()).toList(),
      'usuarioId': usuarioId,
      'criadoEm': criadoEm,
      'atualizadoEm': atualizadoEm,
      'analiseIds': analiseIds,
    };
  }

  factory ClienteEntity.fromMap(Map<String, dynamic> map) {
    return ClienteEntity(
      id: (map['id'] as String?) ?? '',
      token: (map['token'] as String?) ?? '',
      nome: (map['nome'] as String?) ?? '',
      telefone: (map['telefone'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      cidade: (map['cidade'] as String?) ?? '',
      estado: (map['estado'] as String?) ?? '',
      observacoes: map['observacoes'] as String?,
      fazendas: ((map['fazendas'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => FazendaEntity.fromMap(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      usuarioId: (map['usuarioId'] as String?) ?? '',
      criadoEm: _toDateTime(map['criadoEm']),
      atualizadoEm: _toDateTime(map['atualizadoEm']),
      analiseIds: ((map['analiseIds'] as List?) ?? const [])
          .whereType<String>()
          .toList(growable: false),
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
      identical(this, other) || other is ClienteEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
