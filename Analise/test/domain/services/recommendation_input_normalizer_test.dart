import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/entities/analise_completa.dart';
import 'package:soloforte/domain/models/diagnostico_recomendacao.dart';
import 'package:soloforte/domain/services/recommendation_input_normalizer.dart';
import 'package:soloforte/domain/value_objects/valor_nutriente.dart';

void main() {
  const normalizer = RecommendationInputNormalizer();

  test('normaliza unidades e deriva SB, CTC e V%', () {
    final input = normalizer.normalize(
      analise: _analise(
        k: _v(78.2),
        kUnidadeOriginal: 'mg/dm³',
        ca: _v(29),
        caUnidadeOriginal: 'mmolc/dm³',
        mg: _v(12),
        mgUnidadeOriginal: 'mmolc/dm³',
        hAl: _v(18),
        hAlUnidadeOriginal: 'mmolc/dm³',
        materiaOrganica: _v(24),
        moUnidadeOriginal: 'g/dm³',
        argila: _v(420),
        argilaUnidadeOriginal: 'g/kg',
      ),
    );

    expect(input.entity.k, closeTo(0.2, 0.001));
    expect(input.entity.ca, closeTo(2.9, 0.001));
    expect(input.entity.mg, closeTo(1.2, 0.001));
    expect(input.entity.hAl, closeTo(1.8, 0.001));
    expect(input.entity.mo, closeTo(2.4, 0.001));
    expect(input.entity.argila, closeTo(42, 0.001));
    expect(input.entity.sb, closeTo(4.3, 0.001));
    expect(input.entity.ctc, closeTo(6.1, 0.001));
    expect(input.entity.vPercent, closeTo((4.3 / 6.1) * 100, 0.001));
    expect(input.camposDerivados, containsAll(<String>['SB', 'CTC', 'V%']));
  });

  test('deriva H+Al a partir de CTC quando H+Al nao foi analisado', () {
    final input = normalizer.normalize(
      analise: _analise(
        k: _v(0.2),
        ca: _v(2.9),
        mg: _v(1.2),
        hAl: _na(),
        ctc: _v(5.9),
      ),
    );

    expect(input.entity.hAl, closeTo(1.6, 0.001));
    expect(input.camposDerivados, contains('H+Al'));
    expect(input.blockedModules, isNot(contains(RecommendationModule.calagem)));
  });

  test('fosforo ausente bloqueia somente modulo de fosforo', () {
    final input = normalizer.normalize(
      analise: _analise(
        pMehlich: _na(),
        pResina: _na(),
      ),
    );

    expect(input.status['P'], StatusNutriente.ausente);
    expect(input.blockedModules, contains(RecommendationModule.fosforo));
    expect(input.blockedModules, isNot(contains(RecommendationModule.calagem)));
  });
}

AnaliseCompleta _analise({
  ValorNutriente? k,
  String? kUnidadeOriginal,
  ValorNutriente? ca,
  String? caUnidadeOriginal,
  ValorNutriente? mg,
  String? mgUnidadeOriginal,
  ValorNutriente? hAl,
  String? hAlUnidadeOriginal,
  ValorNutriente? materiaOrganica,
  String? moUnidadeOriginal,
  ValorNutriente? argila,
  String? argilaUnidadeOriginal,
  ValorNutriente? pMehlich,
  ValorNutriente? pResina,
  ValorNutriente? ctc,
}) {
  return AnaliseCompleta(
    id: 'a-1',
    fazenda: 'Fazenda',
    produtor: 'Produtor',
    talhao: 'T1',
    cultura: 'Soja',
    laboratorio: 'Lab',
    dataCadastro: DateTime(2026, 1, 1),
    phAgua: _na(),
    phSmp: _na(),
    phCaCl2: _v(5.4),
    materiaOrganica: materiaOrganica ?? _v(2.5),
    argila: argila ?? _v(40),
    pMehlich: pMehlich ?? _v(12),
    pResina: pResina ?? _na(),
    pRem: _na(),
    k: k ?? _v(0.2),
    ca: ca ?? _v(2.9),
    mg: mg ?? _v(1.2),
    al: _v(0.1),
    hAl: hAl ?? _v(1.8),
    na: _na(),
    s020: _v(8),
    s2040: _na(),
    b: _v(0.3),
    cu: _v(0.8),
    fe: _v(30),
    mn: _v(5),
    zn: _v(1.2),
    ni: _na(),
    mo: _na(),
    se: _na(),
    co: _na(),
    ctc: ctc,
    kUnidadeOriginal: kUnidadeOriginal,
    caUnidadeOriginal: caUnidadeOriginal,
    mgUnidadeOriginal: mgUnidadeOriginal,
    hAlUnidadeOriginal: hAlUnidadeOriginal,
    moUnidadeOriginal: moUnidadeOriginal,
    argilaUnidadeOriginal: argilaUnidadeOriginal,
  );
}

ValorNutriente _v(double value) {
  return ValorNutriente(valor: value, analisado: true);
}

ValorNutriente _na() {
  return const ValorNutriente(valor: null, analisado: false);
}
