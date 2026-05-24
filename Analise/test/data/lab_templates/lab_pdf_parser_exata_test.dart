import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/lab_pdf_parser.dart';

void main() {
  group('LabPdfParserService Exata Brasil', () {
    test(
        'mapeia corretamente colunas do bloco pH/K com descricao e profundidade',
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

    test('mapeia P meh em linhas OCR com valores na mesma linha', () {
      const text = '''
Relatório de Ensaio Nº 16738.2025.V0.U
Data Emissão: 24/07/2025
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
SBA25.147312 18.1 20 - 40 T01 5,54 3,06 1,91 1,15 0,00 3,35 0,13 50,70
SBA25.147294 1 0 - 20 T01 5,76 4,64 2,97 1,67 0,10 4,34 0,26 101,00
SBA25.147295 2 0 - 20 T01 6,09 5,17 3,23 1,94 0,10 2,39 0,38 149,00
SBA25.147298 5 0 - 20 T01 6,03 6,23 4,15 2,08 0,00 2,27 0,27 107,40
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
SBA25.147312 18.1 20 - 40 T01 1,41 24,57 0,10 42,55 20,15 0,25 1,66 540,0
SBA25.147294 1 0 - 20 T01 5,63 - 0,10 27,26 22,26 0,56 2,23 540,0
SBA25.147295 2 0 - 20 T01 4,82 - 0,10 27,81 27,55 1,43 3,74 540,0
SBA25.147298 5 0 - 20 T01 31,41 - 0,10 34,38 67,97 1,17 3,17 340,0
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
SBA25.147312 18.1 20 - 40 T01 75,00 385,0 6,54 48,78 0,0 29,20 17,58 1,99
SBA25.147294 1 0 - 20 T01 75,00 385,0 9,24 53,03 2,0 32,14 18,07 2,81
SBA25.147295 2 0 - 20 T01 100,00 360,0 7,94 69,90 1,8 40,68 24,43 4,79
SBA25.147298 5 0 - 20 T01 75,00 585,0 8,13 73,06 1,7 43,67 23,80 2,75
''';

      final parsed = const LabPdfParserService().parse(
        labId: 'exata_brasil',
        text: text,
        sourceName: 'exata-16738-ocr.pdf',
      );

      final amostras =
          (parsed.laudo['amostras'] as List).cast<Map<String, dynamic>>();
      expect(amostras, hasLength(4));

      Map<String, dynamic> byId(String id) =>
          amostras.firstWhere((sample) => sample['numeroAmostra'] == id);

      final subsolo = byId('SBA25.147312');
      expect(subsolo['talhao'], 'T01');
      expect(subsolo['profundidade'], '20-40');
      expect(subsolo['phCaCl2'], 5.54);
      expect(subsolo['pMehlich'], 1.41);
      expect(subsolo['s020'], 24.57);
      expect(subsolo['cu_meh'], 0.10);
      expect(subsolo['argila'], 540.0);
      expect(subsolo['silte'], 75.0);
      expect(subsolo['areiaTotal'], 385.0);

      expect(byId('SBA25.147294')['pMehlich'], 5.63);
      expect(byId('SBA25.147295')['pMehlich'], 4.82);
      expect(byId('SBA25.147298')['pMehlich'], 31.41);
      expect(byId('SBA25.147298')['s020'], isNull);
    });
  });
}
