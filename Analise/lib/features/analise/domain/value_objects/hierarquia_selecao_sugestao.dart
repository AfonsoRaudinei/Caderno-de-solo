import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/services/produtor_resolucao_service.dart';

/// Sugestão de vínculo extraída do laudo PDF ou do produtor configurado.
class HierarquiaSelecaoSugestao {
  const HierarquiaSelecaoSugestao({
    this.produtor = '',
    this.fazenda = '',
    this.talhao = '',
  });

  final String produtor;
  final String fazenda;
  final String talhao;

  bool get isEmpty =>
      produtor.trim().isEmpty &&
      fazenda.trim().isEmpty &&
      talhao.trim().isEmpty;

  factory HierarquiaSelecaoSugestao.fromAnalises(
    List<AnaliseSolo> analises, {
    String produtorConfigurado = '',
  }) {
    if (analises.isEmpty) {
      return HierarquiaSelecaoSugestao(produtor: produtorConfigurado.trim());
    }

    final first = analises.first;
    final produtor = ProdutorResolucaoService.resolver(
      produtorAtual: first.produtor,
      laudoMetadata: first.laudoMetadata,
      produtorConfigurado: produtorConfigurado,
    );

    return HierarquiaSelecaoSugestao(
      produtor: produtor.isNotEmpty ? produtor : produtorConfigurado.trim(),
      fazenda: first.fazenda.trim(),
      talhao: first.talhao.trim().isNotEmpty
          ? first.talhao.trim()
          : (first.codigoTalhao?.trim() ?? ''),
    );
  }
}
