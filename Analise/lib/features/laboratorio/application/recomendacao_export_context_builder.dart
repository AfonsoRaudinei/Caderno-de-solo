import 'package:soloforte/domain/export/recomendacao_export_context.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/services/produtor_resolucao_service.dart';
import 'package:soloforte/features/config/domain/entities/user_profile_data.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/recomendacao_html_exporter.dart';

/// Monta [RecomendacaoExportContext] a partir dos dados da tela de recomendação.
class RecomendacaoExportContextBuilder {
  const RecomendacaoExportContextBuilder();

  Future<RecomendacaoExportContext> build({
    required ResultadoRecomendacao resultado,
    AnaliseSolo? analiseSolo,
    List<AnaliseSolo> analisesSelecionadas = const [],
    UserProfileData? perfil,
    String? logoUrl,
    DateTime? geradaEm,
  }) async {
    final logoDataUri = await RecomendacaoHtmlExporter.logoToDataUri(logoUrl);
    final credencial = perfil != null
        ? '${perfil.tipoPerfil}${perfil.empresa.isNotEmpty ? ' · ${perfil.empresa}' : ''}'
        : null;
    final selecionadas = analisesSelecionadas.isNotEmpty
        ? analisesSelecionadas
        : [
            if (analiseSolo != null) analiseSolo,
          ];
    final metadata = _buildMetadata(
      resultado: resultado,
      analisesSelecionadas: selecionadas,
      perfil: perfil,
      credencial: credencial,
      logoDataUri: logoDataUri,
    );

    return RecomendacaoExportContext(
      resultado: resultado,
      geradaEm: geradaEm ?? DateTime.now(),
      metadata: metadata,
    );
  }

  static DateTime? parseDataLaudo(AnaliseSolo? analiseSolo) =>
      _parseDataLaudo(analiseSolo);

  static DateTime? _parseDataLaudo(AnaliseSolo? analiseSolo) {
    final emissao = analiseSolo?.dataEmissao;
    if (emissao != null && emissao.isNotEmpty) {
      final parsed = DateTime.tryParse(emissao);
      if (parsed != null) return parsed;
      final br = RegExp(r'^(\d{2})/(\d{2})/(\d{4})').firstMatch(emissao);
      if (br != null) {
        return DateTime.tryParse(
          '${br.group(3)}-${br.group(2)}-${br.group(1)}',
        );
      }
    }
    return analiseSolo?.dataCadastro;
  }

  static RecomendacaoExportMetadata _buildMetadata({
    required ResultadoRecomendacao resultado,
    required List<AnaliseSolo> analisesSelecionadas,
    required UserProfileData? perfil,
    required String? credencial,
    required String? logoDataUri,
  }) {
    final a = resultado.analise;
    final cal = resultado.calibracao;
    final single =
        analisesSelecionadas.length == 1 ? analisesSelecionadas.first : null;

    return RecomendacaoExportMetadata(
      consultorNome: _firstNonEmpty([perfil?.nome, a.consultor]),
      consultorCredencial: credencial,
      produtor: _firstNonEmpty([
        _commonOrFirst(
          analisesSelecionadas.map(ProdutorResolucaoService.produtorEfetivo),
        ),
        cal.cliente,
      ]),
      fazenda: _firstNonEmpty([
        _commonOrFirst(analisesSelecionadas.map((item) => item.fazenda)),
        a.fazenda,
        cal.fazenda,
      ]),
      cidadeUf: _firstNonEmpty([
        _commonOrFirst(
          analisesSelecionadas.map((item) => item.municipio ?? ''),
        ),
        _commonOrFirst(
          analisesSelecionadas.map((item) => item.descricaoLocal ?? ''),
        ),
        a.localizacao,
      ]),
      talhao: _firstNonEmpty([
        if (analisesSelecionadas.length > 1)
          'Média de ${analisesSelecionadas.length} amostras',
        single?.talhao,
        a.talhao,
        cal.talhao,
      ]),
      cultura: _firstNonEmpty([
        _commonOrFirst(analisesSelecionadas.map((item) => item.cultura.label)),
        a.cultura,
        cal.cultura,
      ]),
      safra: _firstNonEmpty([
        _commonOrFirst(analisesSelecionadas.map((item) => item.safra)),
        cal.safra,
      ]),
      laboratorio: _firstNonEmpty([
        _commonOrFirst(analisesSelecionadas.map((item) => item.laboratorio)),
        a.nome,
      ]),
      profundidade: _firstNonEmpty([
        _commonOrFirst(
          analisesSelecionadas.map((item) => _normalizarProfundidade(
                item.profundidade,
              )),
        ),
      ]),
      dataLaudo: _latestDataLaudo(analisesSelecionadas),
      logoDataUri: logoDataUri,
    );
  }

  static String? _firstNonEmpty(Iterable<String?> values) {
    for (final value in values) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }
    return null;
  }

  static String? _commonOrFirst(Iterable<String> values) {
    final cleaned = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (cleaned.isEmpty) return null;
    final normalized = cleaned.map((value) => value.toLowerCase()).toSet();
    return normalized.length == 1 ? cleaned.first : cleaned.first;
  }

  static String _normalizarProfundidade(String raw) {
    final value = raw.replaceAll('–', '-').replaceAll(' ', '').trim();
    return value.isEmpty ? '0-20' : value;
  }

  static DateTime? _latestDataLaudo(List<AnaliseSolo> analises) {
    DateTime? latest;
    for (final analise in analises) {
      final data = _parseDataLaudo(analise);
      if (data == null) continue;
      if (latest == null || data.isAfter(latest)) latest = data;
    }
    return latest;
  }
}
