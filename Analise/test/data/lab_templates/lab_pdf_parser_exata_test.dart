import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/lab_pdf_parser.dart';

void main() {
  group('LabPdfParserService Exata Brasil', () {
    test('mapeia corretamente colunas do bloco pH/K com descricao e profundidade',
        () {
      const text = '''
Relatório de Ensaio Nº 17259.2025.V0.U
Data Emissão: 30/07/2025
Razão Social: ANDRE LUIZ DE SIQUEIRA
Propriedade/Município/Proprietário: MOEMA - ANDRE LUIS DE SIQUEIRA
Amostra
Descrição da Amostra
Profundidade
Talhão
pH
(CaCl2)
Ca
+
Mg
Ca
Mg
Al
H + Al
K
K
(NH4Cl)
Un
cmolc/dm³
mg/dm³
SBA25.147266
1
0 - 20
T02
5,57
4,27
2,81
1,46
0,00
3,71
0,21
83,90
Amostra
Descrição da Amostra
Profundidade
Talhão
P
(meh)
S
Cu (meh)
Fe (meh)
Mn (meh)
Zn (meh)
Na
Argila
Un
mg/dm³
g/dm³
SBA25.147266
1
0 - 20
T02
35,20
-
0,38
56,45
55,22
1,10
2,07
420,0
Amostra
Descrição da Amostra
Profundidade
Talhão
Silte
Areia
T
V
m
Ca/CTC
Mg/CTC
K/CTC
Un
g/dm³
cmolc/dm³
%
SBA25.147266
1
0 - 20
T02
125,00
455,0
8,19
54,70
0,0
34,31
17,83
2,56
''';

      final parsed = const LabPdfParserService().parse(
        labId: 'exata_brasil',
        text: text,
        sourceName: 'exata-2025.pdf',
      );

      final amostras =
          (parsed.laudo['amostras'] as List).cast<Map<String, dynamic>>();
      expect(amostras, hasLength(1));
      final sample = amostras.single;
      expect(sample['numeroAmostra'], 'SBA25.147266');
      expect(sample['talhao'], 'T02');
      expect(sample['profundidade'], '0-20');
      expect(sample['phCaCl2'], 5.57);
      expect(sample['ca'], 2.81);
      expect(sample['mg'], 1.46);
      expect(sample['al'], 0.0);
      expect(sample['hMaisAl'], 3.71);
      expect(sample['k'], 0.21);
      expect(sample['k_mgdm3'], 83.90);
      expect(sample['pMehlich'], 35.20);
      expect(sample['s020'], isNull);
      expect(sample['cu_meh'], 0.38);
      expect(sample['fe_meh'], 56.45);
      expect(sample['mn_meh'], 55.22);
      expect(sample['zn_meh'], 1.10);
      expect(sample['na'], 2.07);
      expect(sample['argila'], 420.0);
      expect(sample['silte'], 125.0);
      expect(sample['areiaTotal'], 455.0);
    });

    test('preserva talhao sem profundidade explicita no prefixo', () {
      const text = '''
Relatório de Ensaio Nº 16723.2024.V0.U
Data Emissão: 14/08/2024
Razão Social: JOSE AUGUSTO MIRANDA
Propriedade/Município/Proprietário: SANTA MARIA - ROSALANDIA TO - JOSE AUGUSTO MIRANDA
Amostra
Descrição da Amostra
Profundidade
Talhão
pH
(CaCl2)
Ca
+
Mg
Ca
Mg
Al
H + Al
K
K
(NH4Cl)
Un
cmolc/dm³
mg/dm³
SBA24.99401
RA 01
5,36
3,50
2,39
1,11
0,00
2,76
0,08
32,98
''';

      final parsed = const LabPdfParserService().parse(
        labId: 'exata_brasil',
        text: text,
        sourceName: 'exata-2024.pdf',
      );

      final amostras =
          (parsed.laudo['amostras'] as List).cast<Map<String, dynamic>>();
      expect(amostras, hasLength(1));
      final sample = amostras.single;
      expect(sample['numeroAmostra'], 'SBA24.99401');
      expect(sample['talhao'], 'RA 01');
      expect(sample['profundidade'], '0-20');
      expect(sample['phCaCl2'], 5.36);
      expect(sample['ca'], 2.39);
      expect(sample['mg'], 1.11);
      expect(sample['hMaisAl'], 2.76);
      expect(sample['k_mgdm3'], 32.98);
    });
  });
}
