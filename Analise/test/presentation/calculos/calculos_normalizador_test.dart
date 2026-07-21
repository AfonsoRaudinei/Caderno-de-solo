import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/config/presentation/calculos/calculos_normalizador.dart';

AnaliseSolo _analise({
  required String id,
  required String laboratorio,
  required String talhao,
  String? labTemplateId,
  double? phAgua,
  double? phSmp,
  double? phCaCl2,
  double? materiaOrganica,
  double? carbonoOrganico,
  double? pMehlich,
  double? pResina,
  double? pRem,
  double? k,
  double? kMgDm3,
  double? ca,
  double? mg,
  double? al,
  double? hMaisAl,
  double? na,
  double? sb,
  double? ctc,
  double? ctcEfetiva,
  double? vPercent,
  double? mPercent,
  double? b,
  double? cu,
  double? fe,
  double? mn,
  double? zn,
  double? cuMehlich,
  double? feMehlich,
  double? mnMehlich,
  double? znMehlich,
  double? cuDtpa,
  double? feDtpa,
  double? mnDtpa,
  double? znDtpa,
  double? ni,
  double? mo,
  double? se,
  double? co,
  double? argila,
  double? silte,
  double? areiaTotal,
  String? classificacaoTextura,
}) {
  return AnaliseSolo(
    id: id,
    fazenda: 'Fazenda',
    produtor: 'Produtor',
    talhao: talhao,
    numeroAmostra: '1',
    cultura: Cultura.soja,
    safra: '2025/26',
    laboratorio: laboratorio,
    dataCadastro: DateTime(2026, 7, 20, 8, 0),
    profundidade: '0-20',
    phAgua: phAgua,
    phSmp: phSmp,
    phCaCl2: phCaCl2,
    materiaOrganica: materiaOrganica,
    carbonoOrganico: carbonoOrganico,
    pMehlich: pMehlich,
    pResina: pResina,
    pRem: pRem,
    k: k,
    kMgDm3: kMgDm3,
    ca: ca,
    mg: mg,
    al: al,
    hMaisAl: hMaisAl,
    na: na,
    sb: sb,
    ctc: ctc,
    ctcEfetiva: ctcEfetiva,
    vPercent: vPercent,
    mPercent: mPercent,
    b: b,
    cu: cu,
    fe: fe,
    mn: mn,
    zn: zn,
    cuMehlich: cuMehlich,
    feMehlich: feMehlich,
    mnMehlich: mnMehlich,
    znMehlich: znMehlich,
    cuDtpa: cuDtpa,
    feDtpa: feDtpa,
    mnDtpa: mnDtpa,
    znDtpa: znDtpa,
    ni: ni,
    mo: mo,
    se: se,
    co: co,
    argila: argila,
    silte: silte,
    areiaTotal: areiaTotal,
    classificacaoTextura: classificacaoTextura,
    labTemplateId: labTemplateId,
  );
}

void main() {
  const normalizador = CalculosNormalizador();

  test('normaliza Exata sem perder K mg/dm3, micros duplos e textura', () {
    final analise = _analise(
      id: 'exata-1',
      laboratorio: 'Exata Brasil',
      talhao: 'Talhão 1',
      labTemplateId: 'exata_brasil',
      phAgua: 5.74,
      phSmp: 5.92,
      phCaCl2: 5.61,
      materiaOrganica: 20.78,
      carbonoOrganico: 11.0,
      pMehlich: 5.68,
      pResina: 4.12,
      pRem: 14.0,
      k: 0.17,
      kMgDm3: 67.94,
      ca: 2.94,
      mg: 1.21,
      al: 0.0,
      hMaisAl: 1.73,
      sb: 4.32,
      ctc: 6.05,
      vPercent: 71.40,
      mPercent: 0.70,
      b: 0.21,
      cu: 1.02,
      fe: 10.68,
      mn: 22.1,
      zn: 1.88,
      cuMehlich: 1.99,
      feMehlich: 46.37,
      mnMehlich: 26.07,
      znMehlich: 1.59,
      cuDtpa: 1.02,
      feDtpa: 10.68,
      mnDtpa: 20.01,
      znDtpa: 1.59,
      ni: 0.12,
      mo: 0.03,
      se: 0.01,
      co: 0.0,
      argila: 419.0,
      silte: 320.0,
      areiaTotal: 261.0,
    );

    final normalizada = normalizador.normalizar(
      analise,
      label: 'Amostra 1',
      index: 1,
    );

    expect(normalizada.k, closeTo(0.17, 1e-9));
    expect(normalizada.kMgDm3, closeTo(67.94, 1e-9));
    expect(normalizada.argila, closeTo(41.9, 1e-9));
    expect(normalizada.silte, closeTo(32.0, 1e-9));
    expect(normalizada.areiaTotal, closeTo(26.1, 1e-9));
    expect(normalizada.classificacaoTextura, 'Argiloso');
    expect(normalizada.caMgRel, closeTo(2.43, 0.1));
    expect(normalizada.cuMehlich, closeTo(1.99, 1e-9));
    expect(normalizada.feMehlich, closeTo(46.37, 1e-9));
    expect(normalizada.mnMehlich, closeTo(26.07, 1e-9));
    expect(normalizada.znMehlich, closeTo(1.59, 1e-9));
    expect(normalizada.cuDtpa, closeTo(1.02, 1e-9));
    expect(normalizada.feDtpa, closeTo(10.68, 1e-9));
    expect(normalizada.sb, closeTo(4.32, 1e-9));
    expect(normalizada.ctc, closeTo(6.05, 1e-9));
    expect(normalizada.vPercent, closeTo(71.40, 1e-9));
    expect(normalizada.mPercent, closeTo(0.70, 1e-9));
  });

  test('normaliza IBRA e preserva campos ausentes como null', () {
    final analise = _analise(
      id: 'ibra-1',
      laboratorio: 'IBRA — Instituto Brasileiro de Análises',
      talhao: 'Talhão 2',
      labTemplateId: 'ibra',
      phSmp: 5.60,
      phCaCl2: 4.82,
      materiaOrganica: 18.4,
      carbonoOrganico: 9.2,
      pResina: 12.0,
      pRem: 18.0,
      k: 0.23,
      ca: 4.00,
      mg: 1.20,
      al: 0.10,
      hMaisAl: 2.50,
      sb: 5.43,
      ctc: 7.93,
      vPercent: 68.48,
      mPercent: 1.26,
      b: 0.25,
      cu: 0.92,
      fe: 21.1,
      mn: 8.4,
      zn: 1.3,
      argila: 540.0,
      silte: 240.0,
      areiaTotal: 220.0,
    );

    final normalizada = normalizador.normalizar(
      analise,
      label: 'Amostra 2',
      index: 2,
    );

    expect(normalizada.kMgDm3, isNull);
    expect(normalizada.argila, closeTo(54.0, 1e-9));
    expect(normalizada.classificacaoTextura, 'Argiloso');
    expect(normalizada.cuDtpa, isNull);
    expect(normalizada.feDtpa, isNull);
    expect(normalizada.sb, closeTo(5.43, 1e-9));
    expect(normalizada.ctc, closeTo(7.93, 1e-9));
  });

  test('normaliza sem labTemplateId sem exceção', () {
    final analise = _analise(
      id: 'sem-template',
      laboratorio: 'Laboratório sem template',
      talhao: 'Talhão 9',
      phAgua: 5.80,
      ca: 2.20,
      mg: 1.10,
      k: 0.21,
      argila: 300.0,
    );

    final normalizada = normalizador.normalizar(
      analise,
      label: 'Amostra 4',
      index: 4,
    );

    expect(normalizada.label, 'Amostra 4');
    expect(normalizada.k, closeTo(0.21, 1e-9));
    expect(normalizada.kMgDm3, isNull);
    expect(normalizada.classificacaoTextura, isNotNull);
  });

  test('normaliza Exata preservando Mehlich e DTPA sem troca de campo', () {
    final analise = _analise(
      id: 'exata-rotas',
      laboratorio: 'Exata Brasil',
      talhao: 'Talhão 5',
      labTemplateId: 'exata_brasil',
      cu: 1.02,
      fe: 10.68,
      mn: 22.10,
      zn: 1.88,
      cuMehlich: 1.99,
      feMehlich: 46.37,
      mnMehlich: 26.07,
      znMehlich: 1.59,
      cuDtpa: 1.02,
      feDtpa: 10.68,
      mnDtpa: 20.01,
      znDtpa: 1.59,
    );

    final normalizada = normalizador.normalizar(
      analise,
      label: 'Amostra 5',
      index: 5,
    );

    expect(normalizada.cu, closeTo(1.02, 1e-9));
    expect(normalizada.fe, closeTo(10.68, 1e-9));
    expect(normalizada.mn, closeTo(22.10, 1e-9));
    expect(normalizada.zn, closeTo(1.88, 1e-9));
    expect(normalizada.cuMehlich, closeTo(1.99, 1e-9));
    expect(normalizada.feMehlich, closeTo(46.37, 1e-9));
    expect(normalizada.mnMehlich, closeTo(26.07, 1e-9));
    expect(normalizada.znMehlich, closeTo(1.59, 1e-9));
    expect(normalizada.cuDtpa, closeTo(1.02, 1e-9));
    expect(normalizada.feDtpa, closeTo(10.68, 1e-9));
    expect(normalizada.mnDtpa, closeTo(20.01, 1e-9));
    expect(normalizada.znDtpa, closeTo(1.59, 1e-9));
  });

  test('normaliza MB e não inventa zeros para campos inexistentes', () {
    final analise = _analise(
      id: 'mb-1',
      laboratorio: 'MB Agronegócios',
      talhao: 'Talhão 3',
      labTemplateId: 'mb_agronegocios',
      phCaCl2: 5.10,
      materiaOrganica: 3.20,
      carbonoOrganico: 2.10,
      pMehlich: 7.30,
      pResina: 8.00,
      pRem: 16.0,
      k: 0.31,
      ca: 3.10,
      mg: 1.30,
      al: 0.0,
      hMaisAl: 2.20,
      sb: 4.71,
      ctc: 6.91,
      vPercent: 68.16,
      mPercent: 0.0,
      cu: 1.40,
      fe: 18.0,
      mn: 6.8,
      zn: 1.1,
      argila: 500.0,
      silte: 250.0,
      areiaTotal: 250.0,
    );

    final normalizada = normalizador.normalizar(
      analise,
      label: 'Amostra 3',
      index: 3,
    );

    expect(normalizada.kMgDm3, isNull);
    expect(normalizada.classificacaoTextura, 'Argiloso');
    expect(normalizada.cuDtpa, isNull);
    expect(normalizada.feDtpa, isNull);
    expect(normalizada.mnDtpa, isNull);
    expect(normalizada.znDtpa, isNull);
    expect(normalizada.sb, closeTo(4.71, 1e-9));
    expect(normalizada.ctc, closeTo(6.91, 1e-9));
  });

  test('calcula media ignorando nulls e sem preencher zero', () {
    final completa = normalizador.calcularMedia([
      normalizador.normalizar(
        _analise(
          id: 'exata-1',
          laboratorio: 'Exata Brasil',
          talhao: 'Talhão 1',
          labTemplateId: 'exata_brasil',
          phAgua: 5.74,
          materiaOrganica: 20.78,
          k: 0.17,
          kMgDm3: 67.94,
          ca: 2.94,
          mg: 1.21,
          hMaisAl: 1.73,
          sb: 4.32,
          ctc: 6.05,
          vPercent: 71.40,
          mPercent: 0.70,
          argila: 419.0,
          silte: 320.0,
          areiaTotal: 261.0,
        ),
        label: 'Amostra 1',
        index: 1,
      ),
      normalizador.normalizar(
        _analise(
          id: 'sparse',
          laboratorio: 'Exata Brasil',
          talhao: 'Talhão 4',
          labTemplateId: 'exata_brasil',
        ),
        label: 'Amostra 2',
        index: 2,
      ),
    ]);

    expect(completa.k, closeTo(0.17, 1e-9));
    expect(completa.kMgDm3, closeTo(67.94, 1e-9));
    expect(completa.sb, closeTo(4.32, 1e-9));
    expect(completa.ctc, closeTo(6.05, 1e-9));
    expect(completa.argila, closeTo(41.9, 1e-9));
  });
}
