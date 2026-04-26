import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/lab_detector.dart';

void main() {
  group('LabDetector', () {
    test('detecta Sellar com confiança alta', () {
      const text = '''
      Sellar Análises Agrícolas
      Laudo Nº 6077/2025
      Número Sellar
      Análise Granulométrica
      ''';

      final result = LabDetector.detectarComConfianca(text);
      expect(result.labId, 'sellar');
      expect(result.confidence, greaterThan(0.58));
      expect(result.needsFallback, isFalse);
    });

    test('detecta Exata Brasil com confiança alta', () {
      const text = '''
      Software Ultra Lims
      Relatório de Ensaio Nº17259.2025.V0.U
      Exata Brasil Unidade BA
      K (NH4Cl)
      SBA25.147266
      ''';

      final result = LabDetector.detectarComConfianca(text);
      expect(result.labId, 'exata_brasil');
      expect(result.confidence, greaterThan(0.58));
      expect(result.needsFallback, isFalse);
    });

    test('detecta IBRA com confiança alta', () {
      const text = '''
      INSTITUTO BRASILEIRO DE ANÁLISES
      O.S.: 237526
      Fósforo (Resina)
      Agrofarm - Produtos Agroquimicos Ltda.
      ''';

      final result = LabDetector.detectarComConfianca(text);
      expect(result.labId, 'ibra');
      expect(result.confidence, greaterThan(0.58));
      expect(result.needsFallback, isFalse);
    });

    test('detecta MB com confiança alta', () {
      const text = '''
      ANÁLISE DE SOLO - Nº 78416
      MB AGRONEGOCIOS LTDA
      PARÂMETROS ESTRATÉGICOS
      TEORES QUÍMICOS DOS ELEMENTOS
      ''';

      final result = LabDetector.detectarComConfianca(text);
      expect(result.labId, 'mb');
      expect(result.confidence, greaterThan(0.58));
      expect(result.needsFallback, isFalse);
    });
  });
}
