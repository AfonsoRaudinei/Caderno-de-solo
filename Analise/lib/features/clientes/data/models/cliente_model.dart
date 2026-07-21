import 'package:soloforte/features/clientes/data/models/fazenda_model.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';

class ClienteModel extends ClienteEntity {
  const ClienteModel({
    required super.id,
    required super.token,
    required super.nome,
    required super.telefone,
    required super.email,
    required super.cidade,
    required super.estado,
    super.observacoes,
    super.fazendas = const [],
    required super.usuarioId,
    required super.criadoEm,
    required super.atualizadoEm,
    super.analiseIds = const [],
  });

  factory ClienteModel.fromEntity(ClienteEntity entity) {
    return ClienteModel(
      id: entity.id,
      token: entity.token,
      nome: entity.nome,
      telefone: entity.telefone,
      email: entity.email,
      cidade: entity.cidade,
      estado: entity.estado,
      observacoes: entity.observacoes,
      fazendas: entity.fazendas.map(FazendaModel.fromEntity).toList(),
      usuarioId: entity.usuarioId,
      criadoEm: entity.criadoEm,
      atualizadoEm: entity.atualizadoEm,
      analiseIds: entity.analiseIds,
    );
  }

  factory ClienteModel.fromMap(Map<String, dynamic> map) {
    return ClienteModel.fromEntity(ClienteEntity.fromMap(map));
  }
}
