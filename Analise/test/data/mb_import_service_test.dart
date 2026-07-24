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
      expect(amostras[0].numeroAmostra, '78416');
      expect(amostras[0].talhao, 'TH ABACAXI');
    });

    test('deve carregar pH, fósforo e bases trocáveis do laudo MB', () {
      expect(amostras[0].phCaCl2!, closeTo(5.8, 0.001));
      expect(amostras[0].phSmp!, closeTo(6.76, 0.001));
      expect(amostras[0].pMehlich!, closeTo(6.53, 0.001));
      expect(amostras[0].pResina, isNull);
      expect(amostras[0].pRem, isNull);
      expect(amostras[0].ca!, closeTo(2.95, 0.001));
      expect(amostras[0].mg!, closeTo(1.02, 0.001));
      expect(amostras[0].al!, closeTo(0.0, 0.001));
      expect(amostras[0].hMaisAl!, closeTo(1.9, 0.001));
      expect(amostras[0].ctc!, closeTo(5.96, 0.001));
      expect(amostras[0].sb!, closeTo(4.06, 0.001));
      expect(amostras[0].vPercent!, closeTo(68.13, 0.001));
      expect(amostras[0].mPercent!, closeTo(0.0, 0.001));
    });

    test('K convertido de mg/dm³ para cmolc/dm³ (÷ 391)', () {
      expect(amostras[0].k!, closeTo(31.74 / 391.0, 0.0001));
    });

    test('argila/silte/areia convertidos de % para g/kg (× 10)', () {
      expect(amostras[0].argila!, closeTo(420.0, 0.001));
      expect(amostras[0].silte!, closeTo(43.6, 0.001));
      expect(amostras[0].areiaTotal!, closeTo(536.4, 0.001));
    });

    test('M.O. em % permanece em dag/kg (sem conversão)', () {
      expect(amostras[0].materiaOrganica!, closeTo(1.94, 0.001));
    });

    test('carbono_gdm3 convertido para dag/kg (÷ 10)', () {
      expect(amostras[0].carbonoOrganico!, closeTo(1.125, 0.001));
    });

    test('campos não requisitados no laudo MB permanecem null', () {
      expect(amostras[0].s020, isNull);
      expect(amostras[0].b, isNull);
      expect(amostras[0].cu, isNull);
      expect(amostras[0].fe, isNull);
      expect(amostras[0].mn, isNull);
      expect(amostras[0].zn, isNull);
    });
  });
}
