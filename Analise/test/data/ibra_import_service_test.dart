import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/ibra_import_service.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

void main() {
  const service = IbraImportService();

  Map<String, dynamic> loadJson(String path) {
    final file = File(path);
    return json.decode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  group('IbraImportService — OS 237526 (14 amostras)', () {
    late List<AnaliseSolo> amostras;

    setUpAll(() {
      final jsonIbra = loadJson('assets/lab_data/ibra_237526_2025.json');
      amostras = service.fromJson(jsonIbra);
    });

    test('deve retornar 14 amostras', () {
      expect(amostras.length, 14);
    });

    test('amostra[0] deve ser 257056 / LT-01', () {
      expect(amostras[0].numeroAmostra, '257056');
      expect(amostras[0].talhao, 'LT-01');
    });

    test('K convertido de mmolc/dm³ para cmolc/dm³ (÷ 10)', () {
      // 257056 k_mmolc = 0.8 → 0.8 / 10 = 0.08 cmolc/dm³
      expect(amostras[0].k!, closeTo(0.08, 0.0001));
    });

    test('K convertido < 1.0 (confirmação mmolc→cmolc)', () {
      expect(amostras[0].k!, lessThan(1.0));
    });

    test('Ca convertido de mmolc para cmolc (÷ 10)', () {
      // 257056 ca_mmolc = 29.0 → 2.9
      expect(amostras[0].ca!, closeTo(2.9, 0.001));
    });

    test('Mg convertido de mmolc para cmolc (÷ 10)', () {
      // 257056 mg_mmolc = 12.0 → 1.2
      expect(amostras[0].mg!, closeTo(1.2, 0.001));
    });

    test('H+Al convertido de mmolc para cmolc (÷ 10)', () {
      // 257056 hMaisAl_mmolc = 18.0 → 1.8
      expect(amostras[0].hMaisAl!, closeTo(1.8, 0.001));
    });

    test('M.O. convertida de g/dm³ para dag/kg (÷ 10)', () {
      // 257056 mo_gdm3 = 22.0 → 2.2
      expect(amostras[0].materiaOrganica!, closeTo(2.2, 0.001));
    });

    test('amostra[6] deve ser 257062 / LT-5A', () {
      expect(amostras[6].numeroAmostra, '257062');
      expect(amostras[6].talhao, 'LT-5A');
    });

    test('pMehlich deve ser null (IBRA usa Resina)', () {
      expect(amostras[0].pMehlich, isNull);
    });

    test('última amostra deve ser 257069', () {
      expect(amostras.last.numeroAmostra, '257069');
    });

    test('produtor usa responsavel quando proprietario vem vazio', () {
      final jsonIbra = loadJson('assets/lab_data/ibra_237526_2025.json');
      jsonIbra['proprietario'] = '';
      jsonIbra['responsavel'] = 'Agrofarm';

      final importadas = service.fromJson(jsonIbra);

      expect(importadas, isNotEmpty);
      expect(importadas.first.produtor, 'Agrofarm');
    });
  });
}
