import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/calcario_formula.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/usecases/calcular_calagem_calculos_usecase.dart';

CalibracaoProfile _calibracao({
  required String metodoCalagem,
  Map<String, dynamic>? extraCorretivos,
}) {
  final corretivos = <String, dynamic>{
    'referencia': '01 — Calagem: Motor de Cálculo',
    'metodoCalagem': metodoCalagem,
    'tipoCalcario': 'Dolomítico',
    'calcario1': {
      'caO': 30.0,
      'mgO': 16.0,
      'prnt': 81.0,
    },
    'usarSegundoCalcario': false,
    'proporcaoCalcario1': 50.0,
    'v2': 70.0,
    'fatorHAl': 0.5,
    'doseFixa': 1.75,
    'mgDesejado': 0.8,
    'albrecht': {
      'caAlvo': 65.0,
      'mgAlvo': 15.0,
      'kAlvo': 4.0,
      'ncCa': 2.0,
      'ncMg': 0.8,
      'ncK': 0.15,
    },
    'metodoIncorporacao': 'Sem incorporação',
    'profundidadeManual': 20.0,
    'sc': 1.0,
    ...?extraCorretivos,
  };

  return CalibracaoProfile(
    id: 'cal-1',
    nome: 'Calibração Teste',
    cultura: 'Soja',
    safra: '2026/27',
    cliente: '',
    fazenda: '',
    talhao: '',
    observacoes: '',
    parametrosCards: {
      'corretivos': corretivos,
    },
    createdAt: DateTime(2026, 7, 23),
    updatedAt: DateTime(2026, 7, 23),
  );
}

const _analise = CalculoCalagemAnaliseInput(
  id: 'media',
  label: 'Média',
  talhao: 'Talhão 1',
  laboratorio: 'Exata',
  phCaCl2: 4.8,
  materiaOrganica: 3.0,
  ca: 2.0,
  mg: 0.5,
  k: 0.16,
  hAl: 3.38,
  al: 0.3,
  ctc: 6.04,
  vPercent: 43.7,
  argila: 35.0,
  pRem: 18.0,
);

void main() {
  const usecase = CalcularCalagemCalculosUsecase();

  test('método ① usa V2 da calibração', () {
    final resultado = usecase(
      analise: _analise,
      calibracao: _calibracao(
        metodoCalagem: '① Saturação por Bases (V%)',
      ),
    );

    expect(resultado.metodo, '① Saturação por Bases (V%)');
    expect(resultado.vAlvo, 70.0);
    expect(resultado.doseFinalTHa, closeTo(1.96, 0.05));
  });

  test('método ② usa H+Al e fator da calibração', () {
    final resultado = usecase(
      analise: _analise,
      calibracao: _calibracao(
        metodoCalagem: '② EMBRAPA (fator H+Al)',
      ),
    );

    expect(resultado.ncBase, closeTo(1.69, 0.01));
    expect(resultado.doseFinalTHa, closeTo(2.08, 0.05));
  });

  test('método ③ usa soma Ca + Mg', () {
    final resultado = usecase(
      analise: _analise,
      calibracao: _calibracao(
        metodoCalagem: '③ Ca+Mg',
      ),
    );

    expect(resultado.ncBase, closeTo(2.5, 0.01));
    expect(resultado.doseFinalTHa, closeTo(3.09, 0.05));
  });

  test('método ④ usa dose fixa da calibração', () {
    final resultado = usecase(
      analise: _analise,
      calibracao: _calibracao(
        metodoCalagem: '④ Supercalagem',
      ),
    );

    expect(resultado.ncBase, 1.75);
    expect(resultado.doseFinalTHa, closeTo(2.16, 0.05));
  });

  test('método ⑤ usa metas Albrecht da calibração', () {
    final resultado = usecase(
      analise: _analise,
      calibracao: _calibracao(
        metodoCalagem: '⑤ Albrecht',
      ),
    );

    expect(resultado.vAlvo, 84.0);
    expect(resultado.doseFinalTHa, greaterThanOrEqualTo(0.0));
  });

  test('método ⑥ calcula Y a partir de argila e P-rem', () {
    final resultado = usecase(
      analise: _analise,
      calibracao: _calibracao(
        metodoCalagem: '⑥ Albrecht + Y',
      ),
    );

    expect(resultado.y, isNotNull);
    expect(resultado.y!, greaterThan(0.0));
    expect(resultado.doseFinalTHa, greaterThanOrEqualTo(0.0));
  });

  test('método ⑦ usa Mg desejado da calibração', () {
    final resultado = usecase(
      analise: _analise,
      calibracao: _calibracao(
        metodoCalagem: '⑦ Correção Mg',
      ),
    );

    expect(resultado.ncBase, greaterThanOrEqualTo(0.0));
    expect(resultado.doseFinalTHa, greaterThanOrEqualTo(0.0));
  });

  test('método ⑧ CA+CD usa NC = CA + CD e aplicarCorrecoes', () {
    final bruto = CalcarioFormula.calcularNcCaCd(
      al3: _analise.al!,
      ca2: _analise.ca!,
      mg2: _analise.mg!,
      ncCa: 2.0,
      ncMg: 0.8,
      argilaPercent: _analise.argila,
      prem: _analise.pRem,
    );
    final dose = CalcarioFormula.metodoCaCd(
      al3: _analise.al!,
      ca2: _analise.ca!,
      mg2: _analise.mg!,
      ncCa: 2.0,
      ncMg: 0.8,
      argilaPercent: _analise.argila,
      prem: _analise.pRem,
      prnt: 81.0,
      profundidadeCm: 20.0,
      sc: 1.0,
    );

    final resultado = usecase(
      analise: _analise,
      calibracao: _calibracao(
        metodoCalagem: '⑧ CA+CD',
      ),
    );

    expect(resultado.metodo, '⑧ CA+CD');
    expect(resultado.ncBase, closeTo(bruto.nc, 0.0001));
    expect(resultado.y, closeTo(bruto.y, 0.0001));
    expect(resultado.doseFinalTHa, closeTo(dose, 0.0001));
  });

  test('método ⑥ falha sem argila e P-rem', () {
    const analiseSemY = CalculoCalagemAnaliseInput(
      id: 'media',
      label: 'Média',
      talhao: 'Talhão 1',
      laboratorio: 'Exata',
      ca: 2.0,
      mg: 0.5,
      k: 0.16,
      hAl: 3.38,
      al: 0.3,
      ctc: 6.04,
      vPercent: 43.7,
    );

    expect(
      () => usecase(
        analise: analiseSemY,
        calibracao: _calibracao(metodoCalagem: '⑥ Albrecht + Y'),
      ),
      throwsA(isA<StateError>()),
    );
  });
}
