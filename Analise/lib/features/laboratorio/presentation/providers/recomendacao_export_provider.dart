import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/config/domain/entities/user_profile_data.dart';
import 'package:soloforte/features/laboratorio/application/recomendacao_export_context_builder.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/recomendacao_html_exporter.dart';

typedef ExportRecomendacaoFn = Future<void> Function({
  required ResultadoRecomendacao resultado,
  AnaliseSolo? analiseSolo,
  List<AnaliseSolo> analisesSelecionadas,
  UserProfileData? perfil,
  String? logoUrl,
  Rect? sharePositionOrigin,
});

/// Exporta recomendação como HTML (substituível em testes).
final exportRecomendacaoProvider = Provider<ExportRecomendacaoFn>((ref) {
  return ({
    required ResultadoRecomendacao resultado,
    AnaliseSolo? analiseSolo,
    List<AnaliseSolo> analisesSelecionadas = const [],
    UserProfileData? perfil,
    String? logoUrl,
    Rect? sharePositionOrigin,
  }) async {
    final exportContext = await const RecomendacaoExportContextBuilder().build(
      resultado: resultado,
      analiseSolo: analiseSolo,
      analisesSelecionadas: analisesSelecionadas,
      perfil: perfil,
      logoUrl: logoUrl,
    );
    await const RecomendacaoHtmlExporter().exportar(
      exportContext,
      sharePositionOrigin: sharePositionOrigin,
    );
  };
});
