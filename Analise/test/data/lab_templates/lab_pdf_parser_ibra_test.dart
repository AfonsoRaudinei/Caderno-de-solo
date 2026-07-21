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
  });
}
