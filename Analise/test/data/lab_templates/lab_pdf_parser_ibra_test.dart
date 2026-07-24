import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/lab_pdf_parser.dart';

void main() {
  group('LabPdfParserService IBRA', () {
    test('mapeia enxofre e micronutrientes na ordem S, B, Cu, Fe, Mn, Zn', () {
      const text = '''
INSTITUTO BRASILEIRO DE ANÁLISES
O.S. : 237526
Emissão: 01/01/2025
257056
Talhão: LT-01; Prof.: 0 a 20 cm
Nº LAB
Fósforo (Resina)
Fósforo Remanescente
Matéria Orgânica
Carbono Orgânico
pH CaCl2
pH SMP
K Ca Mg Na H+Al Al
SB CTC V m Ca na CTC Mg na CTC K na CTC
S B Cu Fe Mn Zn
Argila Silte Areia Total
257056 18,00 37,58 22,00 13,00 5,80 6,79 0,80 29,00 12,00 1,00 18,00 0,00 42,80 60,80 70,39 0,00 47,70 3,00 0,40 0,40 20,00 0,60 0,50 1,30 0,00 0,00 0,00 0,00 98,00 74,00 828,00
Página 1 de 1
METODOLOGIA
''';

      final parsed = const LabPdfParserService().parse(
        labId: 'ibra',
        text: text,
        sourceName: 'ibra.pdf',
      );

      final amostras =
          (parsed.laudo['amostras'] as List).cast<Map<String, dynamic>>();
      expect(amostras, hasLength(1));
      final sample = amostras.single;
      expect(sample['numeroAmostra'], '257056');
      expect(sample['talhao'], 'LT-01');
      expect(sample['profundidade'], '0-20');
      expect(sample['pResina'], 18.0);
      expect(sample['pRem'], 37.58);
      expect(sample['s020'], 3.0);
      expect(sample['b'], 0.4);
      expect(sample['cu'], 0.4);
      expect(sample['fe'], 20.0);
      expect(sample['mn'], 0.6);
      expect(sample['zn'], 0.5);
      expect(sample['argila'], 98.0);
      expect(sample['silte'], 74.0);
      expect(sample['areiaTotal'], 828.0);
    });

    test('mapeia layout matricial Agrofarm/IBRA com textura e derivados', () {
      const text = '''
Agrofarm - Produtos Agroquimicos Ltda.
O.S.: 237526 - Emissão: 21/08/2025
Nº LAB IDENTIFICAÇÃO DA AMOSTRA (Informações fornecidas pelo cliente)
257056 Talhão: LT-01; Prof.: 0 a 20 cm
257057 Talhão: LT-02; Prof.: 0 a 20 cm
AMOSTRAS
DETERMINAÇÕES METODOLOGIA
257056 257057
P Fósforo (Resina) mg/dm³ IAC 18 19
P Rem Fósforo Remanescente mg/dm³ 37,58 33,25
M.O. Matéria Orgânica g/dm³ IAC 22 32
COT Carbono Orgânico Total g/dm³ IAC 13 19
pH pH (CaCl2) - IAC 5,8 5,4
pH pH (SMP) - IAC 6,79 6,26
K Potássio mmolc/dm³ IAC 0,8 1,3
Ca Cálcio mmolc/dm³ IAC 29 28
Mg Magnésio mmolc/dm³ IAC 12 10
Na Sódio (Mehlich) mmolc/dm³ Embrapa 0,1 0,1
H° + Al ³ Acidez Total mmolc/dm³ IAC 18 32
Al ³ Alumínio Trocável mmolc/dm³ IAC 0 0
C.T.C. Capac. de troca de cátions mmolc/dm³ Embrapa 59,9 71,4
S.B. Soma de bases mmolc/dm³ Cálculo 41,9 39,4
V% Saturação por bases % Embrapa 70 55
m% Saturação por Al % Embrapa 0 0
S Enxofre (Fosfato de Cálcio) mg/dm³ IAC 3 3
B Boro mg/dm³ ME SOLO 03 0,4 0,64
Cu Cobre (DTPA) mg/dm³ IAC 0,4 0,5
Fe Ferro (DTPA) mg/dm³ IAC 20 23
Mn Manganês (DTPA) mg/dm³ IAC 0,6 5
Zn Zinco (DTPA) mg/dm³ IAC 0,5 0,8
Argila Argila g/kg Método da Pipeta 98 123
Silte Silte g/kg Método da Pipeta 74 96
Areia Total Areia Total g/kg Método da Pipeta 828 781
Referências:
''';

      final parsed = const LabPdfParserService().parse(
        labId: 'ibra',
        text: text,
        sourceName: 'ibra-agrofarm.pdf',
      );

      final amostras =
          (parsed.laudo['amostras'] as List).cast<Map<String, dynamic>>();
      expect(amostras, hasLength(2));
      expect(amostras.first['numeroAmostra'], '257056');
      expect(amostras.first['talhao'], 'LT-01');
      expect(amostras.first['profundidade'], '0-20');
      expect(amostras.first['pResina'], 18.0);
      expect(amostras.first['ctc_mmolc'], 59.9);
      expect(amostras.first['sb_mmolc'], 41.9);
      expect(amostras.first['vPercent'], 70.0);
      expect(amostras.first['argila'], 98.0);
      expect(amostras.first['silte'], 74.0);
      expect(amostras.first['areiaTotal'], 828.0);
      expect(amostras.last['pResina'], 19.0);
      expect(amostras.last['b'], 0.64);
    });
  });
}
