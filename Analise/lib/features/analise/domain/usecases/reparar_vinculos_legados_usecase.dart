import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/services/analise_vinculo_service.dart';
import 'package:soloforte/features/analise/domain/value_objects/cliente_hierarquia_snapshot.dart';

/// Repara vínculos hierárquicos ausentes em análises legadas.
class RepararVinculosLegadosUsecase {
  const RepararVinculosLegadosUsecase();

  List<AnaliseSolo> call({
    required List<AnaliseSolo> analises,
    required List<ClienteHierarquiaSnapshot> clientes,
  }) {
    if (clientes.isEmpty) return const [];

    final reparos = <AnaliseSolo>[];
    for (final analise in analises) {
      if (analise.possuiVinculoHierarquico) continue;

      final reparada = AnaliseVinculoService.tentarInferirVinculo(
        analise: analise,
        clientes: clientes,
      );
      if (!reparada.possuiVinculoHierarquico) continue;
      if (!_vinculoAlterado(analise, reparada)) continue;
      reparos.add(reparada);
    }
    return reparos;
  }

  bool _vinculoAlterado(AnaliseSolo antes, AnaliseSolo depois) {
    return antes.clienteId != depois.clienteId ||
        antes.fazendaId != depois.fazendaId ||
        antes.talhaoId != depois.talhaoId ||
        antes.vinculoStatus != depois.vinculoStatus;
  }
}
