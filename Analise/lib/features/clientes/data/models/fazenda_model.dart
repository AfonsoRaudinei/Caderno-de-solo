import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';
import 'package:soloforte/features/clientes/data/models/talhao_model.dart';

class FazendaModel extends FazendaEntity {
  const FazendaModel({
    required super.id,
    required super.nome,
    required super.areaTotal,
    super.talhoes = const [],
    required super.criadoEm,
  });

  factory FazendaModel.fromEntity(FazendaEntity entity) {
    return FazendaModel(
      id: entity.id,
      nome: entity.nome,
      areaTotal: entity.areaTotal,
      talhoes: entity.talhoes.map(TalhaoModel.fromEntity).toList(),
      criadoEm: entity.criadoEm,
    );
  }

  factory FazendaModel.fromMap(Map<String, dynamic> map) {
    return FazendaModel.fromEntity(FazendaEntity.fromMap(map));
  }
}
