import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/entities/analise_completa.dart';
import 'package:soloforte/domain/formulas/enxofre_formula.dart';
import 'package:soloforte/domain/value_objects/valor_nutriente.dart';

void main() {
  group('EnxofreFormula', () {
    test('S < 10 → dose 20 kg/ha', () {
      final dose = EnxofreFormula.calcular(_analise(s020: 8));
      expect(dose, 20);
    });

    test('S entre 10 e 20 → dose 10 kg/ha', () {
      final dose = EnxofreFormula.calcular(_analise(s020: 15));
      expect(dose, 10);
    });

    test('S >= 20 → dose 0', () {
      final dose = EnxofreFormula.calcular(_analise(s020: 22));
      expect(dose, 0);
    });

    test('fallback para S 20–40 quando 0–20 ausente', () {
      final dose = EnxofreFormula.calcular(
        _analise(s020: null, s2040: 7),
      );
      expect(dose, 20);
    });

    test('retorna null quando S ausente nas duas camadas', () {
      final dose = EnxofreFormula.calcular(
        _analise(s020: null, s2040: null),
      );
      expect(dose, isNull);
    });
  });
}

AnaliseCompleta _analise({double? s020, double? s2040}) {
  const ausente = ValorNutriente(valor: null, analisado: false);
  ValorNutriente vn(double? v) =>
      v == null ? ausente : ValorNutriente(valor: v, analisado: true);

  return AnaliseCompleta(
    id: 's-test',
    fazenda: 'F',
    produtor: 'P',
    talhao: 'T',
    cultura: 'soja',
    laboratorio: 'Lab',
    dataCadastro: DateTime(2026, 1, 1),
    phAgua: ausente,
    phSmp: ausente,
    phCaCl2: ausente,
    materiaOrganica: ausente,
    argila: ausente,
    pMehlich: ausente,
    pResina: ausente,
    pRem: ausente,
    k: ausente,
    ca: ausente,
    mg: ausente,
    al: ausente,
    hAl: ausente,
    na: ausente,
    s020: vn(s020),
    s2040: vn(s2040),
    b: ausente,
    cu: ausente,
    fe: ausente,
    mn: ausente,
    zn: ausente,
    ni: ausente,
    mo: ausente,
    se: ausente,
    co: ausente,
  );
}
