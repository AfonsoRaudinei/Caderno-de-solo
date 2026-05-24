import 'dart:convert';
import 'package:flutter/services.dart';

// REGRA MB -- tratamento de "nr" (nao requisitado):
//
// A MB usa "nr" quando o cliente nao solicitou o parametro.
// "nr" deve ser tratado como null -- NUNCA como 0.
//
// Exemplo no parser:
//   if (rawValue == 'nr' || rawValue == '--') return null;
//
// Esta regra se aplica a TODOS os campos do laudo MB:
//   - Micronutrientes: Fe, Mn, Zn, Cu, B, Mo, Co -> null se "nr"
//   - pH H2O -> null se "nr"
//   - S -> null se "nr"
//   - P-Remanescente -> null se nao preenchido
//   - P-Resina -> null se nao preenchido
//   - Sodio -> null se nao preenchido
//   - Cascalho, Areia Grossa, Areia Fina -> null se "--"

// REGRAS SOLUM -- campos exclusivos do laudo Solum Laboratorio S.A.:
//
// 1. dataInicioEnsaio / dataFimEnsaio
//    - Formato: "DD/MM/YYYY". Extrair do cabecalho do laudo.
//    - Regex: r'Inicio dos Ensaios[:\s]+(\d{2}/\d{2}/\d{4})'
//             r'Fim dos Ensaios[:\s]+(\d{2}/\d{2}/\d{4})'
//    - Armazenar como String (sem converter para DateTime).
//
// 2. matriculaImovel
//    - Matricula do imovel rural (SIGEF/SNCR).
//    - Regex: r'Matricula[:\s]+([A-Z0-9\-/]+)'
//    - Pode estar ausente -> null.
//
// 3. codigoInterno
//    - Codigo interno do laboratorio (ex: "SLM-2024-00123").
//    - Regex: r'Codigo Interno[:\s]+([A-Z0-9\-]+)'
//    - Aparece no cabecalho ao lado de codigoExternoAmostra.
//
// 4. codigoExternoAmostra
//    - Codigo externo fornecido pelo cliente (pode conter letras, numeros, hifen).
//    - Regex: r'Codigo Externo[:\s]+([A-Z0-9\-]+)'
//    - Quando identificacaoComposta=true, exibir como "interno / externo".
//
// 5. Micronutrientes por amostra (micronutrientesPorAmostra=true)
//    - No Solum, Fe/Mn/Zn/Cu/B sao listados individualmente por amostra,
//      nao agrupados numa tabela compartilhada. O parser deve ler
//      cada linha de micro de cada amostra separadamente.
import 'package:soloforte/features/analise/data/models/lab_template_model.dart';

class PdfParserDatasource {
  Future<List<LabTemplateModel>> loadLabTemplates() async {
    try {
      // Exemplo lendo da pasta assets. Em dev não teremos o pdf gerado, mas deixamos pronto
      final String jsonString =
          await rootBundle.loadString('assets/lab_templates/soloagro.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      final template = LabTemplateModel.fromJson(jsonMap);
      return [template];
    } catch (e) {
      // Silenciar erro se o arquivo não existir ainda durante o mock
      return [];
    }
  }
}
