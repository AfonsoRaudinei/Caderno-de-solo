import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/services/analise_vinculo_service.dart';
import 'package:soloforte/features/analise/domain/value_objects/cliente_hierarquia_snapshot.dart';
import 'package:soloforte/features/analise/domain/value_objects/migracao_vinculos_plan.dart';

/// Planeja migração em massa de vínculos hierárquicos em análises legadas.
class MigrarVinculosLegadosUsecase {
  const MigrarVinculosLegadosUsecase();

  MigracaoVinculosPlan call({
    required List<AnaliseSolo> analises,
    required List<ClienteHierarquiaSnapshot> clientes,
    bool marcarPendentes = true,
  }) {
    if (clientes.isEmpty) {
      return MigracaoVinculosPlan(
        jaVinculadas: analises.where((a) => a.possuiVinculoHierarquico).length,
      );
    }

    var jaVinculadas = 0;
    final reparos = <AnaliseSolo>[];
    final pendentes = <AnaliseSolo>[];

    for (final analise in analises) {
      if (analise.possuiVinculoHierarquico) {
        jaVinculadas++;
        continue;
      }

      final reparada = AnaliseVinculoService.tentarInferirVinculo(
        analise: analise,
        clientes: clientes,
      );

      if (reparada.possuiVinculoHierarquico) {
        if (_vinculoAlterado(analise, reparada)) {
          reparos.add(reparada);
        }
        continue;
      }

      if (marcarPendentes &&
          reparada.vinculoStatus == AnaliseVinculoStatus.pendente &&
          analise.vinculoStatus != AnaliseVinculoStatus.pendente) {
        pendentes.add(reparada);
      }
    }

    return MigracaoVinculosPlan(
      reparos: reparos,
      pendentes: pendentes,
      jaVinculadas: jaVinculadas,
    );
  }

  bool _vinculoAlterado(AnaliseSolo antes, AnaliseSolo depois) {
    return antes.clienteId != depois.clienteId ||
        antes.fazendaId != depois.fazendaId ||
        antes.talhaoId != depois.talhaoId ||
        antes.vinculoStatus != depois.vinculoStatus;
  }
}
