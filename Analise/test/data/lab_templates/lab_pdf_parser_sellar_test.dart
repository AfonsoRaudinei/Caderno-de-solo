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

    test('extrai P Total, C.O., profundidade e múltiplos blocos do Sellar', () {
      const text = '''
Laudo de Análise Solo
Laudo Nº 4517/2026 Entrada: 07/07/2026
Solicitante: JOSÉ AUGUSTO MIRANDA Gerado: 08/07/2026
Proprietário: JOSÉ AUGUSTO MIRANDA Município: Santa Rita do Tocantins - TO
Propriedade: FAZ. MONTANHA Convênio: PARTICULAR
Cultura:
Número Sellar 37610 37611 37612
Amostra 01 - Amostra 01 - Amostra 02 -
Identificação da Amostra (00-20) (20-40) (00-20)
Determinação Unidade
pH Água -
pH CaCl 2 - 5,0 4,9 5,5
P Total % 80,50 80,80 79,80
P meh 5,8 4,6 7,9
S-SO 9 8 6
4
K 59 51 101
K 0,15 0,13 0,26
Ca 2,4 2,1 3,9
Mg cmol .dm 0,7 0,6 1,2
Al 0,20 0,30 0,00
H+Al 2,80 3,10 1,80
M.O. 2,6 2,5 3,2
C.O. 1,5 1,5 1,9
B 0,13 0,13 0,15
Cu 1,4 1,3 1,4
Fe mg.dm 13 10 11
Mn 10,5 8,2 8,3
Zn 0,4 0,3 0,4
SB 3,25 2,83 5,36
CTC cmol .dm 6,05 5,93 7,16
CTC 3,45 3,13 5,36
V 54 48 75
m 6 10 0
Ca/T % 40 35 54
Mg/T 12 10 17
K/T 2 2 4
Ca/Mg 3,4 3,5 3,2
Ca/K 16,0 16,2 15,0
Mg/K 4,7 4,6 4,6
Análise Granulométrica
Argila 650 650 550
Silte g.kg 75 50 50
Areia Total 275 300 400
Classificação M Argilosa M Argilosa Argilosa
Tipo de Solo (MAPA) 3 3 3
Página 1
Laudo de Análise Solo
Laudo Nº 4517/2026 Entrada: 07/07/2026
Número Sellar 37618 37619
Amostra 05 - Amostra 05 -
Identificação da Amostra (00-20) (20-40)
Determinação Unidade
pH Água -
pH CaCl 2 - 5,7 5,5
P Total % 79,30 82,20
P meh 5,1 4,4
S-SO 6 6
4
K 29 25
K 0,07 0,06
Ca 3,1 3,1
Mg cmol .dm 0,9 0,9
Al 0,00 0,00
H+Al 1,60 1,80
M.O. 2,7 2,4
C.O. 1,6 1,4
B 0,13 0,14
Cu 1,6 1,5
Fe mg.dm 15 15
Mn 4,5 3,3
Zn 0,4 0,4
SB 4,07 4,06
CTC cmol .dm 5,67 5,86
CTC 4,07 4,06
V 72 69
m 0 0
Análise Granulométrica
Argila 550 550
Silte g.kg 50 50
Areia Total 400 400
Classificação Argilosa Argilosa
Tipo de Solo (MAPA) 3 3
''';

      final parsed = const LabPdfParserService().parse(
        labId: 'sellar',
        text: text,
        sourceName: 'sellar-montanha.pdf',
      );

      final amostras =
          (parsed.laudo['amostras'] as List).cast<Map<String, dynamic>>();
      expect(amostras, hasLength(5));

      expect(amostras[0]['numeroSellar'], '37610');
      expect(amostras[0]['identificacao'], 'Amostra 01 - (0-20)');
      expect(amostras[0]['profundidade'], '0-20');
      expect(amostras[0]['pTotal'], 80.5);
      expect(amostras[0]['carbonoOrganico'], 1.5);
      expect(amostras[0]['sb'], 3.25);
      expect(amostras[0]['ctc'], 6.05);
      expect(amostras[0]['ctcEfetiva'], 3.45);
      expect(amostras[0]['vPercent'], 54.0);
      expect(amostras[0]['mPercent'], 6.0);

      expect(amostras[1]['identificacao'], 'Amostra 01 - (20-40)');
      expect(amostras[1]['profundidade'], '20-40');
      expect(amostras[3]['numeroSellar'], '37618');
      expect(amostras[3]['profundidade'], '0-20');
      expect(amostras[3]['pTotal'], 79.3);
      expect(amostras[4]['numeroSellar'], '37619');
      expect(amostras[4]['profundidade'], '20-40');
      expect(amostras[4]['carbonoOrganico'], 1.4);
    });
  });
}
