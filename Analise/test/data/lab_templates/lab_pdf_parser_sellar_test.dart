import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/lab_pdf_parser.dart';

void main() {
  group('LabPdfParserService Sellar', () {
    test('extrai nutrientes do layout real Sellar por linhas rotuladas', () {
      const text = '''
Laudo de Análise Solo
Laudo Nº 6077/2025 Entrada: 11/08/2025
Solicitante: JOSÉ AUGUSTO MIRANDA Gerado: 13/08/2025
Proprietário: JOSÉ AUGUSTO MIRANDA Município: Santa Rita do Tocantins - TO
Propriedade: FAZ. SANTO ANTÔNIO Convênio: PARTICULAR
Cultura:
Número Sellar 54215 54216 54217
MANOEL 1 MANOEL 2 TRÊS
Identificação da Amostra
Determinação Unidade
pH Água -
pH CaCl 2 - 5,4 5,5 5,8
P Total %
P meh 13,8 4,9 7,8
P resina -3
-2 mg.dm
S-SO 4 6 4 6
K 51 33 57
K 0,13 0,08 0,15
Ca 1,7 1,7 1,1
Mg cmol .dm 0,7 0,7 0,6
Al 0,00 0,00 0,00
H+Al 2,00 1,80 1,50
M.O. 1,0 1,1 1,0
C.O. 0,6 0,6 0,6
B 0,12 0,13 0,14
Cu 0,6 0,6 0,6
Fe mg.dm 24 15 12
Mn 1,2 1,2 1,2
Zn 0,5 0,5 0,4
SB 2,53 2,48 1,85
CTC cmol .dm 4,53 4,28 3,35
CTC 2,53 2,48 1,85
V 56 58 55
m 0 0 0
Ca/T % 38 40 33
Mg/T 16 16 18
K/T 3 2 4
Ca/Mg 2,4 2,4 1,8
Ca/K 13,1 21,3 7,3
Mg/K 5,4 8,8 4,0
Análise Granulométrica
Argila 175 300 200
Silte g.kg 50 50 50
Areia Total 775 650 750
Classificação Média Média Média
Tipo de Solo (MAPA) 1 2 1
Média
''';

      final parsed = const LabPdfParserService().parse(
        labId: 'sellar',
        text: text,
        sourceName: 'sellar.pdf',
      );

      final amostras =
          (parsed.laudo['amostras'] as List).cast<Map<String, dynamic>>();
      expect(amostras, hasLength(3));

      expect(amostras[0]['numeroSellar'], '54215');
      expect(amostras[0]['identificacao'], 'MANOEL 1');
      expect(amostras[0]['phCaCl2'], 5.4);
      expect(amostras[0]['pMehlich'], 13.8);
      expect(amostras[0]['pResina'], isNull);
      expect(amostras[0]['k_mgdm3'], 51.0);
      expect(amostras[0]['k'], 0.13);
      expect(amostras[1]['k_mgdm3'], 33.0);
      expect(amostras[1]['k'], 0.08);
      expect(amostras[2]['k_mgdm3'], 57.0);
      expect(amostras[2]['k'], 0.15);
      expect(amostras[0]['ca'], 1.7);
      expect(amostras[0]['mg'], 0.7);
      expect(amostras[0]['al'], 0.0);
      expect(amostras[0]['hMaisAl'], 2.0);
      expect(amostras[0]['materiaOrganica'], 1.0);
      expect(amostras[0]['carbonoOrganico'], 0.6);
      expect(amostras[0]['s020'], 6.0);
      expect(amostras[0]['b'], 0.12);
      expect(amostras[0]['cu'], 0.6);
      expect(amostras[0]['fe'], 24.0);
      expect(amostras[0]['mn'], 1.2);
      expect(amostras[0]['zn'], 0.5);
      expect(amostras[0]['sb'], 2.53);
      expect(amostras[0]['ctc'], 4.53);
      expect(amostras[0]['ctcEfetiva'], 2.53);
      expect(amostras[0]['vPercent'], 56.0);
      expect(amostras[0]['mPercent'], 0.0);
      expect(amostras[0]['argila'], 175.0);
      expect(amostras[0]['silte'], 50.0);
      expect(amostras[0]['areiaTotal'], 775.0);
      expect(amostras[0]['classificacaoTextura'], 'Média');
      expect(amostras[0]['tipoSoloMapa'], '1');
    });
  });
}
