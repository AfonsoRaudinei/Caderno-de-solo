import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/services/analise_vinculo_service.dart';
import 'package:soloforte/features/analise/domain/services/produtor_resolucao_service.dart';
import 'package:soloforte/features/analise/domain/value_objects/hierarquia_selecao_result.dart';

/// Aplica vínculo hierárquico manual em lote de análises antes da persistência.
class AplicarHierarquiaAnalisesUsecase {
  const AplicarHierarquiaAnalisesUsecase();

  List<AnaliseSolo> call({
    required List<AnaliseSolo> analises,
    required HierarquiaSelecaoResult selecao,
  }) {
    if (!selecao.isValid) return analises;

    return analises
        .map((analise) => _aplicarUma(analise, selecao))
        .toList(growable: false);
  }

  AnaliseSolo _aplicarUma(
    AnaliseSolo analise,
    HierarquiaSelecaoResult selecao,
  ) {
    final comProdutor = ProdutorResolucaoService.aplicarProdutorConfigurado(
      analise,
      selecao.clienteNome,
      forcarProdutorConfigurado: true,
    );

    final fazenda = comProdutor.fazenda.trim().isNotEmpty
        ? comProdutor.fazenda.trim()
        : selecao.fazendaNome;
    final talhao = comProdutor.talhao.trim().isNotEmpty
        ? comProdutor.talhao.trim()
        : selecao.talhaoNome;

    return AnaliseVinculoService.aplicarVinculoManual(
      analise: comProdutor.copyWith(fazenda: fazenda, talhao: talhao),
      clienteId: selecao.clienteId,
      fazendaId: selecao.fazendaId,
      talhaoId: selecao.talhaoId,
      clienteNome: selecao.clienteNome,
      fazendaNome: selecao.fazendaNome,
      talhaoNome: selecao.talhaoNome,
    );
  }
}
