import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/pdf_import_service.dart';
import 'package:soloforte/data/lab_templates/lab_pdf_parser.dart';
import 'package:soloforte/data/lab_templates/solum_import_service.dart';

void main() {
  group('LabPdfParserService Solum', () {
    test('importa todas as amostras e nutrientes em laudo multipagina', () {
      const text = '''
Cuiabá, 02 de março de 2026.
Data do Recebimento: 20/02/2026 Inicio Ensaio: 26/02/2026 Fim Ensaio: 02/03/2026
LAUDO Nº 8827
Cliente: ELO AGRONEGOCIOS LTDA Cidade: Aparecida de Goiânia UF: GO
Proprietário: ISAQUE SILVA Propriedade: IDABJ Matrícula: -
Nº DO LAB. IDENTIFICAÇÃO DA AMOSTRA
23134 1 ; 00-20 ; 1000192802
23135 1 ; 00-20 ; 1000192803
23136 1 ; 00-05 ; 1000192804
23137 1 ; 00-20 ; 1000192805
23138 1 ; 00-20 ; 1000192806
23139 1 ; 00-05 ; 1000192807
23140 1 ; 00-20 ; 1000192808
23141 1 ; 00-20 ; 1000192809
23142 1 ; 00-05 ; 1000192810
AMOSTRAS
DETERMINAÇÕES METODOLOGIA
23134 23135 23136 23137 23138 23139 23140 23141 23142
K Potássio mmolc/dm³ IAC 0.94 1.14 1.58 0.99 0.96 2.44 1.32 1.31 1.08
Mg Magnésio mmolc/dm³ IAC 12.8 15.4 20.6 15.7 11.7 23.8 14.6 13.6 9.5
Ca Cálcio mmolc/dm³ IAC 23.4 30.2 38.5 28.6 26.4 53.8 42.6 26.3 21
P Fósforo mg/dm³ IAC 10.5 25.9 40 24.5 17.3 48.6 18.2 20.2 37.9
Al³ Alumínio mmolc/dm³ IAC 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1
MO Matéria Orgânica g/dm³ IAC 24 17 28 20 21 46 29 19 16
H° + Al³ Hidrogênio + Alumínio mmolc/dm³ - 18.13 18.71 16.84 20.14 15.48 18.32 16.14 18.91 17.02
pH pH CaCl2 - - 6.1 5.9 6.2 5.8 6.2 6 6.2 5.8 6.2
pH SMP pH (SMP) - IAC 6.8 6.77 6.87 6.7 6.95 6.79 6.91 6.76 6.86
V% Saturação de Bases V% Resina % Cálculo 67.16 71.42 78.29 69.23 71.6 81.38 78.37 68.5 65.01
C.T.C. Capacidade de Troca Catiônica mmolc/dm³ Cálculo 55.21 65.46 77.58 65.47 54.5 98.37 74.65 60.03 48.64
H ° Hidrogênio mmolc/dm³ Cálculo 18.03 18.61 16.74 20.04 15.38 18.22 16.04 18.81 16.92
S.B. Soma de Bases NH4Cl mmolc/dm³ Cálculo 37.08 46.75 60.74 45.33 39.02 80.05 58.51 41.13 31.62
m% Saturação por Alumínio - m% % Cálculo 0.27 0.21 0.16 0.22 0.26 0.13 0.17 0.24 0.32
S Enxofre mg/dm³ IAC - - - 6.73 - - 9.17 - -
B Boro (Água quente) mg/dm³ IAC - - - 0.28 - - 0.25 - -
Cu Cobre - DTPA mg/dm³ IAC - - - 0.23 - - 0.21 - -
Fe Ferro - DTPA mg/dm³ IAC - - - 14.9 - - 20.1 - -
Mn Manganês - DTPA mg/dm³ IAC - - - 3.78 - - 11.11 - -
Zn Zinco - DTPA mg/dm³ IAC - - - 0.53 - - 0.61 - -
Notas:
Nº DO LAB. IDENTIFICAÇÃO DA AMOSTRA
23143 1 ; 00-20 ; 1000192811
23144 1 ; 00-20 ; 1000192812
23145 1 ; 00-20 ; 1000192813
23146 1 ; 00-20 ; 1000192814
23147 1 ; 00-20 ; 1000192815
23148 1 ; 00-20 ; 1000192816
23149 1 ; 00-05 ; 1000192817
23150 1 ; 00-20 ; 1000192818
23151 1 ; 00-20 ; 1000192819
AMOSTRAS
DETERMINAÇÕES METODOLOGIA
23143 23144 23145 23146 23147 23148 23149 23150 23151
K Potássio mmolc/dm³ IAC 0.91 1.54 0.97 0.71 1.15 1.18 1.7 0.94 0.74
Mg Magnésio mmolc/dm³ IAC 8.6 14.4 12.4 8 7.1 11.3 19.4 13.6 17.9
Ca Cálcio mmolc/dm³ IAC 18.4 47.7 31.1 20.4 14.8 23.2 35.8 26.9 36.6
P Fósforo mg/dm³ IAC 21.7 20.5 11.2 8.2 9.7 29.5 34.5 23.2 22.2
Al³ Alumínio mmolc/dm³ IAC 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1
MO Matéria Orgânica g/dm³ IAC 13 32 24 20 23 21 27 22 20
H° + Al³ Hidrogênio + Alumínio mmolc/dm³ - 17.94 17.38 19.11 22.15 20.36 18.71 16.14 18.71 17.56
pH pH CaCl2 - - 6.2 6 5.8 5.8 5.8 5.7 6.3 5.9 6.1
pH SMP pH (SMP) - IAC 6.81 6.84 6.75 6.61 6.69 6.77 6.91 6.77 6.83
V% Saturação de Bases V% Resina % Cálculo 60.84 78.55 69.94 56.82 53.18 65.58 77.88 68.91 75.87
C.T.C. Capacidade de Troca Catiônica mmolc/dm³ Cálculo 45.81 81.02 63.57 51.29 43.47 54.36 72.99 60.17 72.8
H ° Hidrogênio mmolc/dm³ Cálculo 17.84 17.28 19.01 22.04 20.25 18.61 16.04 18.61 17.46
S.B. Soma de Bases NH4Cl mmolc/dm³ Cálculo 27.87 63.64 44.46 29.14 23.12 35.66 56.85 41.46 55.23
m% Saturação por Alumínio - m% % Cálculo 0.36 0.16 0.23 0.34 0.43 0.28 0.18 0.24 0.18
S Enxofre mg/dm³ IAC 7.71 - - - - - - 10.06 -
B Boro (Água quente) mg/dm³ IAC 0.28 - - - - - - 0.2 -
Cu Cobre - DTPA mg/dm³ IAC 0.2 - - - - - - 0.34 -
Fe Ferro - DTPA mg/dm³ IAC 25.8 - - - - - - 16.1 -
Mn Manganês - DTPA mg/dm³ IAC 2.34 - - - - - - 3.44 -
Zn Zinco - DTPA mg/dm³ IAC 0.22 - - - - - - 0.4 -
Notas:
Nº DO LAB. IDENTIFICAÇÃO DA AMOSTRA
23152 1 ; 00-20 ; 1000192867
23153 1 ; 00-20 ; 1000192868
AMOSTRAS
DETERMINAÇÕES METODOLOGIA
23152 23153
K Potássio mmolc/dm³ IAC 2.98 2.88
Mg Magnésio mmolc/dm³ IAC 24.5 24.1
Ca Cálcio mmolc/dm³ IAC 67.2 66.8
P Fósforo mg/dm³ IAC 38.6 37.1
Al³ Alumínio mmolc/dm³ IAC 0.1 0.1
MO Matéria Orgânica g/dm³ IAC 30 30
H° + Al³ Hidrogênio + Alumínio mmolc/dm³ - 18.13 17.94
pH pH CaCl2 - - 5.9 5.9
pH SMP pH (SMP) - IAC 6.8 6.81
V% Saturação de Bases V% Resina % Cálculo 83.92 83.94
C.T.C. Capacidade de Troca Catiônica mmolc/dm³ Cálculo 112.75 111.69
H ° Hidrogênio mmolc/dm³ Cálculo 18.03 17.84
S.B. Soma de Bases NH4Cl mmolc/dm³ Cálculo 94.62 93.75
m% Saturação por Alumínio - m% % Cálculo 0.11 0.11
S Enxofre mg/dm³ IAC - -
B Boro (Água quente) mg/dm³ IAC - -
Cu Cobre - DTPA mg/dm³ IAC - -
Fe Ferro - DTPA mg/dm³ IAC - -
Mn Manganês - DTPA mg/dm³ IAC - -
Zn Zinco - DTPA mg/dm³ IAC - -
Notas:
''';

      final parsed = const LabPdfParserService().parse(
        labId: 'solum',
        text: text,
        sourceName: 'solum.pdf',
      );

      final amostras = parsed.laudo['amostras'] as List<dynamic>;
      expect(amostras, hasLength(20));

      final first = amostras.first as Map<String, dynamic>;
      expect(first['numeroAmostra'], '23134');
      expect(first['profundidade'], '0-20');
      expect(first['k_mmolc'], closeTo(0.94, 0.001));
      expect(first['mg_mmolc'], closeTo(12.8, 0.001));
      expect(first['ca_mmolc'], closeTo(23.4, 0.001));
      expect(first['p_mgdm3'], closeTo(10.5, 0.001));
      expect(first['al_mmolc'], closeTo(0.1, 0.001));
      expect(first['mo_gdm3'], closeTo(24, 0.001));
      expect(first['hMaisAl_mmolc'], closeTo(18.13, 0.001));
      expect(first['h_mmolc'], closeTo(18.03, 0.001));
      expect(first['phCaCl2'], closeTo(6.1, 0.001));
      expect(first['phSmp'], closeTo(6.8, 0.001));
      expect(first['vPercent'], closeTo(67.16, 0.001));
      expect(first['ctc_mmolc'], closeTo(55.21, 0.001));
      expect(first['sb_mmolc'], closeTo(37.08, 0.001));
      expect(first['mPercent'], closeTo(0.27, 0.001));
      expect(first['s020'], isNull);
      expect(first['b'], isNull);
      expect(first['cu'], isNull);
      expect(first['fe'], isNull);
      expect(first['mn'], isNull);
      expect(first['zn'], isNull);

      final withMicros = amostras[6] as Map<String, dynamic>;
      expect(withMicros['numeroAmostra'], '23140');
      expect(withMicros['profundidade'], '0-20');
      expect(withMicros['s020'], closeTo(9.17, 0.001));
      expect(withMicros['b'], closeTo(0.25, 0.001));
      expect(withMicros['cu'], closeTo(0.21, 0.001));
      expect(withMicros['fe'], closeTo(20.1, 0.001));
      expect(withMicros['mn'], closeTo(11.11, 0.001));
      expect(withMicros['zn'], closeTo(0.61, 0.001));

      final secondPage = amostras[9] as Map<String, dynamic>;
      expect(secondPage['numeroAmostra'], '23143');
      expect(secondPage['s020'], closeTo(7.71, 0.001));
      expect(secondPage['b'], closeTo(0.28, 0.001));
      expect(secondPage['cu'], closeTo(0.2, 0.001));
      expect(secondPage['fe'], closeTo(25.8, 0.001));
      expect(secondPage['mn'], closeTo(2.34, 0.001));
      expect(secondPage['zn'], closeTo(0.22, 0.001));

      final last = amostras.last as Map<String, dynamic>;
      expect(last['numeroAmostra'], '23153');
      expect(last['k_mmolc'], closeTo(2.88, 0.001));
      expect(last['mg_mmolc'], closeTo(24.1, 0.001));
      expect(last['ca_mmolc'], closeTo(66.8, 0.001));
      expect(last['p_mgdm3'], closeTo(37.1, 0.001));
      expect(last['h_mmolc'], closeTo(17.84, 0.001));
      expect(last['s020'], isNull);

      final analises = const SolumImportService().fromJson(parsed.laudo);
      expect(analises, hasLength(20));
      expect(analises.first.k, closeTo(0.094, 0.001));
      expect(analises.first.ca, closeTo(2.34, 0.001));
      expect(analises.first.mg, closeTo(1.28, 0.001));
      expect(analises.first.h, closeTo(1.803, 0.001));
      expect(analises.first.materiaOrganica, closeTo(2.4, 0.001));
      expect(analises[6].zn, closeTo(0.61, 0.001));
    });

    test('upload importa o PDF Solum real com todos os nutrientes', () async {
      final file = File(
        '/Users/raudineisilvapereira/Documents/Trabalho/Analise de solo/Unknown.pdf',
      );
      if (!file.existsSync()) {
        return;
      }

      final analises = await PdfImportService().importarArquivoPdf(
        fileBytes: file.readAsBytesSync(),
        fileName: file.path.split('/').last,
      );

      expect(analises, hasLength(20));

      final first = analises.first;
      expect(first.numeroAmostra, '23134');
      expect(first.profundidade, '0-20');
      expect(first.k, closeTo(0.094, 0.001));
      expect(first.mg, closeTo(1.28, 0.001));
      expect(first.ca, closeTo(2.34, 0.001));
      expect(first.pMehlich, closeTo(10.5, 0.001));
      expect(first.al, closeTo(0.01, 0.001));
      expect(first.materiaOrganica, closeTo(2.4, 0.001));
      expect(first.hMaisAl, closeTo(1.813, 0.001));
      expect(first.h, closeTo(1.803, 0.001));
      expect(first.phCaCl2, closeTo(6.1, 0.001));
      expect(first.phSmp, closeTo(6.8, 0.001));
      expect(first.vPercent, closeTo(67.16, 0.001));
      expect(first.ctc, closeTo(5.521, 0.001));
      expect(first.sb, closeTo(3.708, 0.001));
      expect(first.mPercent, closeTo(0.27, 0.001));
      expect(first.s020, isNull);
      expect(first.b, isNull);
      expect(first.cu, isNull);
      expect(first.fe, isNull);
      expect(first.mn, isNull);
      expect(first.zn, isNull);

      final withMicros = analises[6];
      expect(withMicros.numeroAmostra, '23140');
      expect(withMicros.s020, closeTo(9.17, 0.001));
      expect(withMicros.b, closeTo(0.25, 0.001));
      expect(withMicros.cu, closeTo(0.21, 0.001));
      expect(withMicros.fe, closeTo(20.1, 0.001));
      expect(withMicros.mn, closeTo(11.11, 0.001));
      expect(withMicros.zn, closeTo(0.61, 0.001));

      final secondPage = analises[9];
      expect(secondPage.numeroAmostra, '23143');
      expect(secondPage.s020, closeTo(7.71, 0.001));
      expect(secondPage.b, closeTo(0.28, 0.001));
      expect(secondPage.cu, closeTo(0.2, 0.001));
      expect(secondPage.fe, closeTo(25.8, 0.001));
      expect(secondPage.mn, closeTo(2.34, 0.001));
      expect(secondPage.zn, closeTo(0.22, 0.001));

      final last = analises.last;
      expect(last.numeroAmostra, '23153');
      expect(last.profundidade, '0-20');
      expect(last.k, closeTo(0.288, 0.001));
      expect(last.mg, closeTo(2.41, 0.001));
      expect(last.ca, closeTo(6.68, 0.001));
      expect(last.pMehlich, closeTo(37.1, 0.001));
      expect(last.h, closeTo(1.784, 0.001));
      expect(last.s020, isNull);
      expect(last.b, isNull);
      expect(last.cu, isNull);
      expect(last.fe, isNull);
      expect(last.mn, isNull);
      expect(last.zn, isNull);
    });
  });
}
