import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/models/analise_model.dart';
import 'package:soloforte/domain/usecases/calcular_recomendacao_usecase.dart';

void main() {
  group('CalcularRecomendacaoUseCase', () {
    late CalcularRecomendacaoUseCase useCase;

    setUp(() {
      useCase = CalcularRecomendacaoUseCase();
    });

    test('CENÁRIO 1 — solo fértil retorna baixa ou nenhuma recomendação', () {
      const analiseFertil = AnaliseModel(
        id: 'fertil',
        userId: 'user-1',
        produtor: 'Fazenda A',
        talhao: 'Talhão 1',
        dataColeta: '2026-04-28',
        status: 'Concluído',
        cultura: 'Soja',
        phAgua: 6.3,
        pMehlich: 30.0,
        k: 0.9,
        ca: 6.0,
        mg: 2.0,
        hMaisAl: 1.0,
        argila: 450.0,
        fontePrincipalP: FonteP.mehlich,
      );

      final recomendacao = useCase(analise: analiseFertil, prntDesejado: 90);

      expect(recomendacao.necessidadeCalagem, 0.0);
      expect(recomendacao.p2o5, 0.0);
      expect(recomendacao.k2o, 0.0);
    });

    test('CENÁRIO 2 — solo deficiente retorna recomendação alta', () {
      const analiseDeficiente = AnaliseModel(
        id: 'deficiente',
        userId: 'user-1',
        produtor: 'Fazenda B',
        talhao: 'Talhão 2',
        dataColeta: '2026-04-28',
        status: 'Concluído',
        cultura: 'Soja',
        phAgua: 4.7,
        pMehlich: 3.0,
        k: 0.08,
        ca: 0.9,
        mg: 0.3,
        hMaisAl: 6.5,
        argila: 550.0,
        fontePrincipalP: FonteP.mehlich,
      );

      final recomendacao = useCase(analise: analiseDeficiente, prntDesejado: 80);

      expect(recomendacao.necessidadeCalagem, greaterThan(0));
      expect(recomendacao.p2o5, greaterThan(0));
      expect(recomendacao.k2o, greaterThan(0));

      expect(recomendacao.necessidadeCalagem, greaterThan(2.0));
      expect(recomendacao.p2o5, greaterThan(100.0));
      expect(recomendacao.k2o, greaterThan(50.0));
    });

    test('CENÁRIO 3 — dado ausente (K null) não quebra e não gera negativo', () {
      const analiseSemK = AnaliseModel(
        id: 'sem-k',
        userId: 'user-1',
        produtor: 'Fazenda C',
        talhao: 'Talhão 3',
        dataColeta: '2026-04-28',
        status: 'Concluído',
        cultura: 'Milho',
        phAgua: 5.2,
        pMehlich: 10.0,
        k: null,
        ca: 2.1,
        mg: 0.8,
        hMaisAl: 4.5,
        argila: 350.0,
        fontePrincipalP: FonteP.mehlich,
      );

      final recomendacao = useCase(analise: analiseSemK, prntDesejado: 80);

      expect(recomendacao.necessidadeCalagem, greaterThanOrEqualTo(0));
      expect(recomendacao.p2o5, greaterThanOrEqualTo(0));
      expect(recomendacao.k2o, greaterThanOrEqualTo(0));
      expect(recomendacao.k2o.isFinite, isTrue);
      expect(recomendacao.p2o5.isFinite, isTrue);
      expect(recomendacao.necessidadeCalagem.isFinite, isTrue);
    });

    test('CENÁRIO 4 — bordas (zeros e extremos) mantém saída válida e sem negativo',
        () {
      const analiseZeros = AnaliseModel(
        id: 'zeros',
        userId: 'user-1',
        cultura: 'Soja',
        phAgua: 0,
        pMehlich: 0,
        k: 0,
        ca: 0,
        mg: 0,
        hMaisAl: 0,
        argila: 0,
      );

      const analiseExtrema = AnaliseModel(
        id: 'extrema',
        userId: 'user-1',
        cultura: 'Soja',
        phAgua: 14.0,
        pMehlich: 500.0,
        k: 10.0,
        ca: 30.0,
        mg: 10.0,
        hMaisAl: 0.1,
        argila: 900.0,
      );

      final recZero = useCase(analise: analiseZeros, prntDesejado: 80);
      final recExtremo = useCase(analise: analiseExtrema, prntDesejado: 80);

      for (final rec in [recZero, recExtremo]) {
        expect(rec.necessidadeCalagem.isFinite, isTrue);
        expect(rec.p2o5.isFinite, isTrue);
        expect(rec.k2o.isFinite, isTrue);
        expect(rec.necessidadeCalagem, greaterThanOrEqualTo(0));
        expect(rec.p2o5, greaterThanOrEqualTo(0));
        expect(rec.k2o, greaterThanOrEqualTo(0));
      }
    });
  });
}
