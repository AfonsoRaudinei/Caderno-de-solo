import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/services/produtor_resolucao_service.dart';

/// Filtra análises pertencentes a um cliente por FK, índice ou nome.
class ClienteAnalisesFilter {
  const ClienteAnalisesFilter._();

  static List<AnaliseSolo> filtrar({
    required List<AnaliseSolo> analises,
    required String clienteId,
    Set<String> analiseIds = const {},
    String clienteNome = '',
  }) {
    final normalizedId = clienteId.trim();
    if (normalizedId.isEmpty) return const [];

    final index = analiseIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    final nome = clienteNome.trim();

    final filtradas = analises.where((analise) {
      if (analise.clienteId?.trim() == normalizedId) return true;
      if (index.contains(analise.id)) return true;
      if (nome.isNotEmpty &&
          ProdutorResolucaoService.nomesProdutorCompativeis(
            analise.produtor,
            nome,
          )) {
        return true;
      }
      return false;
    }).toList(growable: false);

    filtradas.sort((a, b) => b.dataCadastro.compareTo(a.dataCadastro));
    return filtradas;
  }
}
