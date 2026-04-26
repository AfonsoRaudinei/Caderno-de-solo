import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/exata_brasil_import_service.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

void main() {
  const service = ExataBrasilImportService();

  Map<String, dynamic> loadJson(String path) {
    final file = File(path);
    return json.decode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  group('ExataBrasilImportService — Relatório 16723 (12 amostras SBA24)', () {
    late List<AnaliseSolo> amostras;

    setUpAll(() {
      final json16723 =
          loadJson('assets/lab_data/exata_brasil_16723_2024.json');
      amostras = service.fromJson(json16723);
    });

    test('deve retornar 12 amostras', () {
      expect(amostras.length, 12);
    });

    test('amostra[0] deve ser SBA24.99401 / RA 01', () {
      expect(amostras[0].numeroAmostra, 'SBA24.99401');
      expect(amostras[0].talhao, 'RA 01');
    });

    test('K convertido de mg/dm³ para cmolc/dm³ (÷ 391)', () {
      // SBA24.99401 k_mgdm3 = 32.98 → 32.98 / 391 ≈ 0.08434
      expect(amostras[0].k!, closeTo(32.98 / 391.0, 0.0001));
    });

    test('M.O. convertida de g/dm³ para dag/kg (÷ 10)', () {
      // SBA24.99401 materiaOrganica = 32.47 g/dm³ → 3.247 dag/kg
      expect(amostras[0].materiaOrganica!, closeTo(3.247, 0.001));
    });

    test('amostra[0].materiaOrganica < 10.0 (confirmação da conversão)', () {
      expect(amostras[0].materiaOrganica!, lessThan(10.0));
    });

    test('C.O. convertido de g/dm³ para dag/kg (÷ 10)', () {
      expect(amostras[0].carbonoOrganico!, closeTo(18.83 / 10.0, 0.001));
    });

    test('Cu/Fe/Mn/Zn recebem o valor DTPA como principal', () {
      // SBA24.99401 cu_dtpa = 1.90
      expect(amostras[0].cu!, closeTo(1.90, 0.001));
      expect(amostras[0].fe!, closeTo(20.22, 0.001));
      expect(amostras[0].mn!, closeTo(4.80, 0.001));
      expect(amostras[0].zn!, closeTo(2.01, 0.001));
    });

    test('SBA24.99405 tem pRem preenchido (33.95)', () {
      final ra03 =
          amostras.firstWhere((a) => a.numeroAmostra == 'SBA24.99405');
      expect(ra03.pRem!, closeTo(33.95, 0.001));
    });
  });

  group('ExataBrasilImportService — Relatório 17259 (28 amostras SBA25)', () {
    late List<AnaliseSolo> amostras;

    setUpAll(() {
      final json17259 =
          loadJson('assets/lab_data/exata_brasil_17259_2025.json');
      amostras = service.fromJson(json17259);
    });

    test('deve retornar 28 amostras', () {
      expect(amostras.length, 28);
    });

    test('amostra[0] deve ser SBA25.147266', () {
      expect(amostras[0].numeroAmostra, 'SBA25.147266');
    });

    test('K convertido corretamente na amostra 0 (k_mgdm3=83.90)', () {
      expect(amostras[0].k!, closeTo(83.90 / 391.0, 0.0001));
    });

    test('M.O. nula permanece nula (este relat. não tem M.O.)', () {
      expect(amostras[0].materiaOrganica, isNull);
    });

    test('última amostra deve ser SBA25.147293', () {
      expect(amostras.last.numeroAmostra, 'SBA25.147293');
    });
  });
}
