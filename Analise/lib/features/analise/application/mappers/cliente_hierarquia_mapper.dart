import 'package:soloforte/features/analise/domain/value_objects/cliente_hierarquia_snapshot.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';

extension ClienteEntityHierarquiaMapper on ClienteEntity {
  ClienteHierarquiaSnapshot toHierarquiaSnapshot() {
    return ClienteHierarquiaSnapshot(
      id: id,
      nome: nome,
      fazendas: fazendas.map((f) => f.toHierarquiaSnapshot()).toList(),
    );
  }
}

extension FazendaEntityHierarquiaMapper on FazendaEntity {
  FazendaHierarquiaSnapshot toHierarquiaSnapshot() {
    return FazendaHierarquiaSnapshot(
      id: id,
      nome: nome,
      talhoes: talhoes.map((t) => t.toHierarquiaSnapshot()).toList(),
    );
  }
}

extension TalhaoEntityHierarquiaMapper on TalhaoEntity {
  TalhaoHierarquiaSnapshot toHierarquiaSnapshot() {
    return TalhaoHierarquiaSnapshot(
      id: id,
      nome: nome,
    );
  }
}

List<ClienteHierarquiaSnapshot> mapClientesParaHierarquia(
  List<ClienteEntity> clientes,
) {
  return clientes.map((c) => c.toHierarquiaSnapshot()).toList(growable: false);
}
