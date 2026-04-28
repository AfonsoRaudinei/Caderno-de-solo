import 'dart:io';

class ParsePdfUsecase {
  // Passaríamos um datasource ou contrato específico de parse se necessário
  // Para manter simples, a lógica de chamar o package PDF pode ficar aqui ou num datasource
  ParsePdfUsecase();

  Future<Map<String, String>> call(
      File pdfFile, Map<String, dynamic> templateRegexes) async {
    // Essa é uma implementação dummy. Em produção, vai ler o texto do PDF com um package
    // como `syncfusion_flutter_pdf` ou equivalente, e rodar as regex de templateRegexes
    // para extrair os valores.
    return {};
  }
}
