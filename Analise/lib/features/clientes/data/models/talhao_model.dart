import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';

class TalhaoModel extends TalhaoEntity {
  const TalhaoModel({
    required super.id,
    required super.nome,
    required super.area,
    super.latitude,
    super.longitude,
    super.culturaPrincipal,
    required super.criadoEm,
  });

  factory TalhaoModel.fromEntity(TalhaoEntity entity) {
    return TalhaoModel(
      id: entity.id,
      nome: entity.nome,
      area: entity.area,
      latitude: entity.latitude,
      longitude: entity.longitude,
      culturaPrincipal: entity.culturaPrincipal,
      criadoEm: entity.criadoEm,
    );
  }

  factory TalhaoModel.fromMap(Map<String, dynamic> map) {
    return TalhaoModel.fromEntity(TalhaoEntity.fromMap(map));
  }
}
