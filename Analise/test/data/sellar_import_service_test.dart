import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/sellar_import_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SellarImportService', () {
    test('importa 3 amostras e ignora derivados do JSON', () async {
      final jsonString = await rootBundle.loadString(
        'assets/lab_data/sellar_6077_2025.json',
      );
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      final amostras = const SellarImportService().fromJson(json);

      expect(amostras, hasLength(3));

      expect(amostras[0].phCaCl2, 5.4);
      expect(amostras[0].pMehlich, 13.8);
      expect(amostras[0].ca, 1.7);
      expect(amostras[0].k, 0.13);
      expect(amostras[0].phAgua, isNull);
      expect(amostras[0].pResina, isNull);

      expect(amostras[1].phCaCl2, 5.5);
      expect(amostras[2].phCaCl2, 5.8);

      final dynamic primeiraAmostra = amostras[0];
      expect(() => primeiraAmostra.sb, throwsA(anything));
      expect(() => primeiraAmostra.ctcTotal, throwsA(anything));
      expect(() => primeiraAmostra.vPct, throwsA(anything));

      expect(amostras[0].laudoMetadata?['derivados'], isNull);
    });

    test('id sanitizado nao contem barra do laudoNumero', () async {
      final jsonString = await rootBundle.loadString(
        'assets/lab_data/sellar_6077_2025.json',
      );
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      final amostras = const SellarImportService().fromJson(json);

      expect(amostras[0].id, '6077_2025-54215');
      expect(amostras[0].id.contains('/'), isFalse);
    });
  });
}
