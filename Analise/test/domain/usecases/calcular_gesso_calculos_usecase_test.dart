import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/entities/resultado_gesso.dart';
import 'package:soloforte/domain/usecases/calcular_calagem_calculos_usecase.dart';
import 'package:soloforte/domain/usecases/calcular_gesso_calculos_usecase.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';

CalibracaoProfile _calibracao({
  required String metodoGesso,
  bool usarGesso = true,
}) {
  return CalibracaoProfile(
    id: 'cal-gesso',
    nome: 'Calibração Gesso',
    cultura: 'Soja',
    safra: '2026/27',
    cliente: '',
    fazenda: '',
    talhao: '',
    observacoes: '',
    parametrosCards: {
      'corretivos': {
        'gesso': {
          'usarGesso': usarGesso,
          'metodo': metodoGesso,
          'teorCa': 20.0,
          'teorS': 15.0,
          'referencia': '02 — Gesso Agrícola: Motor de Cálculo',
        },
      },
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
  ca: 2.0,
  mg: 0.5,
  k: 0.16,
  hAl: 3.38,
  al: 0.3,
  ctc: 6.04,
  vPercent: 43.7,
  argila: 35.0,
);

void main() {
  const usecase = CalcularGessoCalculosUsecase();

  test('método ① usa argila', () {
    final resultado = usecase(
      analise: _analise,
      calibracao: _calibracao(
        metodoGesso: '① EMBRAPA / Souza et al. (2004) — argila %',
      ),
    );

    expect(resultado.resultado.doseKgHa, closeTo(1750.0, 0.01));
    expect(resultado.metodo, contains('①'));
  });

  test('método ② usa tabela textural', () {
    final resultado = usecase(
      analise: _analise,
      calibracao: _calibracao(metodoGesso: '② UFLA'),
    );

    expect(resultado.resultado.doseKgHa, 1200.0);
  });

  test('método ③ usa V% e CTC do subsolo estimado', () {
    final resultado = usecase(
      analise: _analise,
      calibracao: _calibracao(metodoGesso: '③ Vitti'),
    );

    expect(resultado.resultado.doseTHa, greaterThanOrEqualTo(0.0));
    expect(resultado.resultado.metodo.nome, 'V% e CTC Subsolo (ESALQ)');
  });

  test('método ④ usa CTCe e Ca do subsolo estimado', () {
    final resultado = usecase(
      analise: _analise,
      calibracao: _calibracao(metodoGesso: '④ Caires'),
    );

    expect(resultado.resultado.doseTHa, greaterThanOrEqualTo(0.0));
    expect(resultado.resultado.metodo.nome, 'CTCe e Ca Subsolo (UEPG)');
  });

  test('gesso desligado zera dose e mantém rastreabilidade', () {
    final resultado = usecase(
      analise: _analise,
      calibracao: _calibracao(
        metodoGesso: '① EMBRAPA / Souza et al. (2004) — argila %',
        usarGesso: false,
      ),
    );

    expect(resultado.usarGesso, isFalse);
    expect(resultado.resultado.doseKgHa, 0.0);
    expect(
      resultado.resultado.observacoes,
      contains('Gesso desativado na calibração.'),
    );
  });
}
