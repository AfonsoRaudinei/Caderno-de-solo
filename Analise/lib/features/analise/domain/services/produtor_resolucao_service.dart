import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

/// Regras de resolução do produtor em importações e reparo de legado.
class ProdutorResolucaoService {
  const ProdutorResolucaoService._();

  static final RegExp _contratanteIbraPattern = RegExp(
    r'agrofarm|instituto\s+brasileiro|ibra\s*[—\-]',
    caseSensitive: false,
  );

  static bool isProdutorInvalido(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return true;
    if (_contratanteIbraPattern.hasMatch(text)) return true;
    return false;
  }

  static String firstNonEmpty(Iterable<String?> values) {
    for (final value in values) {
      final text = value?.trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  /// Resolve o produtor final usando PDF, metadados e produtor configurado.
  static String resolver({
    required String? produtorAtual,
    Map<String, dynamic>? laudoMetadata,
    required String produtorConfigurado,
  }) {
    final configurado = produtorConfigurado.trim();
    final atual = produtorAtual?.trim() ?? '';
    if (!isProdutorInvalido(atual)) return atual;

    final proprietarioMeta =
        laudoMetadata?['proprietario']?.toString().trim() ?? '';
    if (!isProdutorInvalido(proprietarioMeta)) return proprietarioMeta;

    return configurado;
  }

  static String produtorEfetivo(AnaliseSolo analise) {
    final produtor = analise.produtor.trim();
    if (produtor.isNotEmpty) return produtor;

    final proprietario =
        analise.laudoMetadata?['proprietario']?.toString().trim() ?? '';
    if (proprietario.isNotEmpty) return proprietario;

    return '';
  }

  static bool nomesProdutorCompativeis(String a, String b) {
    final left = a.trim().toLowerCase();
    final right = b.trim().toLowerCase();
    if (left.isEmpty || right.isEmpty) return false;
    return left == right || left.contains(right) || right.contains(left);
  }

  static bool compativelComConfigurado(
    AnaliseSolo analise,
    String produtorConfigurado,
  ) {
    final configurado = produtorConfigurado.trim();
    if (configurado.isEmpty) return true;

    final produtorAnalise = produtorEfetivo(analise);
    if (produtorAnalise.isEmpty) return false;

    return nomesProdutorCompativeis(produtorAnalise, configurado);
  }

  static AnaliseSolo aplicarProdutorConfigurado(
    AnaliseSolo analise,
    String produtorConfigurado, {
    String? consultor,
    bool forcarProdutorConfigurado = false,
  }) {
    final configurado = produtorConfigurado.trim();
    final produtorResolvido =
        forcarProdutorConfigurado && configurado.isNotEmpty
            ? configurado
            : resolver(
                produtorAtual: analise.produtor,
                laudoMetadata: analise.laudoMetadata,
                produtorConfigurado: produtorConfigurado,
              );

    final consultorResolvido = firstNonEmpty([
      consultor,
      analise.consultor,
      analise.laudoMetadata?['responsavel']?.toString(),
    ]);

    if (produtorResolvido == analise.produtor &&
        (consultorResolvido.isEmpty ||
            consultorResolvido == (analise.consultor ?? ''))) {
      return analise;
    }

    return analise.copyWith(
      produtor: produtorResolvido,
      consultor:
          consultorResolvido.isEmpty ? analise.consultor : consultorResolvido,
    );
  }
}
