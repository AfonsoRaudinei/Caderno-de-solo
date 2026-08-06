import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/lab_pdf_parser.dart';

void main() {
  group('LabPdfParserService MB', () {
    test('extrai textura do texto nativo do app mesmo com valores quebrados',
        () {
      final text = File(
        'test/data/lab_templates/fixtures/mb_78416_2025_native.txt',
      ).readAsStringSync();

      final parsed = const LabPdfParserService().parse(
        labId: 'mb',
        text: text,
        sourceName: 'mb_78416_2025_native.txt',
      );

      final amostras =
          (parsed.laudo['amostras'] as List).cast<Map<String, dynamic>>();
      expect(amostras, hasLength(1));
      final sample = amostras.single;
      expect(sample['numeroAmostra'], '78416-1');
      expect(sample['talhao'], 'TH ABACAXI');
      expect(sample['profundidade'], '0-20');
      expect(sample['areiaTotal_pct'], 53.64);
      expect(sample['silte_pct'], 4.36);
      expect(sample['argila_pct'], 42.0);
      expect(sample['ctc'], 5.96);
      expect(sample['sb'], 4.06);
      expect(sample['vPercent'], 68.13);
      expect(sample['mPercent'], 0.0);
      expect(parsed.warnings, isEmpty);
    });

    test('mantem fallback de profundidade e emite warning quando ausente', () {
      const text = '''
ANÁLISE DE SOLO - Nº 78416
CLIENTE: Timac Agro Industria E Com. De Fert. CNPJ: 02.329.713/0031-44
FAZENDA: Edmilson Hayasaki - Flamboyat
CIDADE: Figueiropolis - TO
RESPONSÁVEL: Larissa Urzedo Rodrigues DATA ENTRADA: 25/07/2025
E-MAIL: DATA SAÍDA: 07/08/2025
AMOSTRA: TH ABACAXI
COMPOSIÇÃO GRANULOMÉTRICA
CASCALHO
AREIA GROSSA
AREIA FINA
AREIA TOTAL
SILTE
ARGILA
--
--
--
53,64
4,36
42,00
2cm
2mm
0,2mm
0,02mm
0,002mm
PARÂMETROS ESTRATÉGICOS INDICADORES DA FERTILIDADE
CTC Potencial (T) 5,96 cmol/dm³ pH CaCl2 5,80 Saturação por alumínio (m) 0,00 % Ca/C.T.C. 49,49 %
Soma de bases (S) 4,06 cmol/dm³ pH H2O nr Matéria orgânica 1,94 % Mg/C.T.C. 17,11 %
Sat. por bases (V) 68,13 % pH SMP 6,76 Carbono 11,25 g/dm³ K/C.T.C. 1,51 %
TEORES QUÍMICOS DOS ELEMENTOS
MACRONUTRIENTES EL. LIMITANTES MICRONUTRIENTES
Ca Mg K P-meh K S H+Al Al Fe Mn Zn Cu B Mo Co
2,95 1,02 0,09 6,53 31,74 nr 1,90 0,00 nr nr nr nr nr nr nr
cmol/dm³ mg/dm³ cmol/dm³ mg/dm³
''';

      final parsed = const LabPdfParserService().parse(
        labId: 'mb',
        text: text,
        sourceName: 'mb-sem-profundidade.pdf',
      );

      final amostras =
          (parsed.laudo['amostras'] as List).cast<Map<String, dynamic>>();
      expect(amostras, hasLength(1));
      final sample = amostras.single;
      expect(sample['talhao'], 'TH ABACAXI');
      expect(sample['profundidade'], '0-20');
      expect(sample['areiaTotal_pct'], 53.64);
      expect(sample['silte_pct'], 4.36);
      expect(sample['argila_pct'], 42.0);
      expect(
        parsed.warnings,
        contains('mb_profundidade_ausente:78416'),
      );
    });
  });
}
