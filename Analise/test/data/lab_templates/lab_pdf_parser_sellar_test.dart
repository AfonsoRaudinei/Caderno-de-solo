import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/lab_pdf_parser.dart';

void main() {
  group('LabPdfParserService Sellar', () {
    test('prioriza o bloco rotulado com valores para K e P resina', () {
      const text = '''
Identificação da Amostra
MANOEL 1
MANOEL 2
TRÊS
Tipo de Solo
Análise granulométrica
54215 54216 54217
5,4 5,5 5,8
13,8 4,9 7,8
10 11 12
1,7 1,7 1,1
0,7 0,7 0,6
0,0 0,0 0,0
2,0 1,8 1,5
1,0 1,1 1,0
2,5 2,4 1,9
4,5 4,2 3,2
55 57 53
0 0 0
0,4 0,5 0,6
0,6 0,6 0,6
24 15 12
1,2 1,2 1,2
0,5 0,5 0,4
2,4 2,4 1,8
13 21 7
5 9 4
775 650 750
50 50 50
175 300 200
pH Água
pH CaCl2
P meh
P resina
K
Ca
Mg
Al
H+Al
M.O.
SB
CTCT
V
m
B
Cu
Fe
Mn
Zn
Ca/Mg
Ca/K
Mg/K
K/T
%
Número Sellar
K
0,13
0,08
0,15
S-SO4-2
6
4
6
C.O.
P Total
%
2,53
2,48
1,85
P resina
10
11
12
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
      expect(amostras[0]['k_mgdm3'], 0.13);
      expect(amostras[1]['k_mgdm3'], 0.08);
      expect(amostras[2]['k_mgdm3'], 0.15);
      expect(amostras[0]['pResina'], 10.0);
      expect(amostras[1]['pResina'], 11.0);
      expect(amostras[2]['pResina'], 12.0);
      expect(amostras[0]['carbonoOrganico'], 2.53);
      expect(amostras[1]['carbonoOrganico'], 2.48);
      expect(amostras[2]['carbonoOrganico'], 1.85);
      expect(amostras[0]['ca'], 1.7);
      expect(amostras[0]['mg'], 0.7);
    });
  });
}
