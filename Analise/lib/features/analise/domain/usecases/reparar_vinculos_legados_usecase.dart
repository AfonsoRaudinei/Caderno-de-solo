import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/usecases/migrar_vinculos_legados_usecase.dart';
import 'package:soloforte/features/analise/domain/value_objects/cliente_hierarquia_snapshot.dart';

/// Repara vínculos hierárquicos ausentes em análises legadas (modo lazy).
class RepararVinculosLegadosUsecase {
  const RepararVinculosLegadosUsecase();

  List<AnaliseSolo> call({
    required List<AnaliseSolo> analises,
    required List<ClienteHierarquiaSnapshot> clientes,
  }) {
    return const MigrarVinculosLegadosUsecase()(
      analises: analises,
      clientes: clientes,
      marcarPendentes: false,
    ).reparos;
  }
}
