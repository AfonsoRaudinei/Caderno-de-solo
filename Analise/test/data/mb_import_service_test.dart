import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/data/lab_templates/mb_import_service.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

void main() {
  const service = MbImportService();

  Map<String, dynamic> loadJson(String path) {
    final file = File(path);
    return json.decode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  group('MbImportService — análise 78416 (1 amostra)', () {
    late List<AnaliseSolo> amostras;

    setUpAll(() {
      final json = loadJson('assets/lab_data/mb_78416_2025.json');
      amostras = service.fromJson(json);
    });

    test('deve retornar 1 amostra', () {
      expect(amostras.length, 1);
    });

    test('deve carregar número da amostra e talhão', () {
      expect(amostras[0].numeroAmostra, '78416-1');
      expect(amostras[0].talhao, 'TH ABACAXI');
    });

    test('K convertido de mg/dm³ para cmolc/dm³ (÷ 391)', () {
      expect(amostras[0].k!, closeTo(120.0 / 391.0, 0.0001));
    });

    test('argila/silte/areia convertidos de % para g/kg (× 10)', () {
      expect(amostras[0].argila!, closeTo(420.0, 0.001));
      expect(amostras[0].silte!, closeTo(80.0, 0.001));
      expect(amostras[0].areiaTotal!, closeTo(500.0, 0.001));
    });

    test('M.O. em % permanece em dag/kg (sem conversão)', () {
      expect(amostras[0].materiaOrganica!, closeTo(2.8, 0.001));
    });

    test('carbono_gdm3 convertido para dag/kg (÷ 10)', () {
      expect(amostras[0].carbonoOrganico!, closeTo(1.62, 0.001));
    });

    test('phSmp deve ser null quando ausente no laudo', () {
      expect(amostras[0].phSmp, isNull);
    });
  });
}
