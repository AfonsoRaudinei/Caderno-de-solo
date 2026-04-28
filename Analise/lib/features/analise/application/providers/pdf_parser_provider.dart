import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:io';
import 'package:soloforte/features/analise/domain/usecases/parse_pdf_usecase.dart';
import 'package:soloforte/features/analise/data/datasources/pdf_parser_datasource.dart';
import 'package:soloforte/features/analise/data/models/lab_template_model.dart';

part 'pdf_parser_provider.g.dart';

@riverpod
PdfParserDatasource pdfParserDatasource(PdfParserDatasourceRef ref) {
  return PdfParserDatasource();
}

@riverpod
ParsePdfUsecase parsePdfUsecase(ParsePdfUsecaseRef ref) {
  return ParsePdfUsecase();
}

@riverpod
class PdfParserNotifier extends _$PdfParserNotifier {
  @override
  Future<List<LabTemplateModel>> build() async {
    final datasource = ref.watch(pdfParserDatasourceProvider);
    return await datasource.loadLabTemplates();
  }

  Future<Map<String, String>> parseLaudo(File pdfFile, String labName) async {
    final templates = state.valueOrNull ?? [];
    final template = templates.firstWhere(
      (t) => t.lab.toLowerCase() == labName.toLowerCase(),
      orElse: () => throw Exception(
          'Template não encontrado para o laboratório $labName'),
    );

    final usecase = ref.read(parsePdfUsecaseProvider);

    // Convertendo mapeamento para regex map simples
    final regexes =
        template.mapeamento.map((key, value) => MapEntry(key, value.regex));
    return await usecase.call(pdfFile, regexes);
  }
}
