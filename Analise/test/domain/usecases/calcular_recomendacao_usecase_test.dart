import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/models/analise_model.dart';
import 'package:soloforte/domain/usecases/calcular_recomendacao_usecase.dart';

void main() {
  group('CalcularRecomendacaoUseCase', () {
    late CalcularRecomendacaoUseCase useCase;

    setUp(() {
      useCase = CalcularRecomendacaoUseCase();
    });

    test('Deve calcular recomendação completa corretamente', () {
      const analise = AnaliseModel(
        id: '123',
        userId: 'user1',
        fazendaNome: 'Fazenda AAA',
        talhaoNome: 'Talhão 1',
        dataColeta: '2023-10-01',
        status: 'Concluído',
        cultura: 'Soja',
        ph: 5.0,
        fosforo: FosforoData(
          pResina: 4.0, // menor que o critico (8.0 para argila>35)
          fontePrincipal: FonteP.resina,
        ),
        potassio: 0.2, // ~2% de CTC 10
        calcio: 2.0,
        magnesio: 1.0,
        ctc: 10.0,
        saturacaoBases: 32.0, // V% = 32% (abaixo do alvo 70%)
      );

      final recomendacao = useCase(analise: analise, prntDesejado: 100);

      // Asserts Calcário: (10.0 * (70-32))/100 = 3.8 t/ha
      expect(recomendacao.necessidadeCalagem, 3.8);

      // Asserts Fósforo (modo correção atualizado): 210.0 kg/ha
      expect(recomendacao.p2o5, 210.0);

      // Asserts Potássio: fator atualizado 942.31
      expect(recomendacao.k2o, closeTo(282.693, 0.01));

      // Assegura meta dados
      expect(recomendacao.cultura, 'Soja');
      expect(recomendacao.analiseId, '123');
    });

    test('As doses devem ser zero se o solo já for muito fértil', () {
      const analise = AnaliseModel(
        id: '123',
        userId: 'user1',
        fazendaNome: '',
        talhaoNome: '',
        dataColeta: '',
        status: '',
        cultura: '',
        ph: 6.5,
        fosforo: FosforoData(
          pMehlich: 20.0, // super fértil
          fontePrincipal: FonteP.mehlich,
        ),
        potassio: 1.0, // 10% da CTC
        calcio: 6.0,
        magnesio: 2.0,
        ctc: 10.0,
        saturacaoBases: 90.0, // V% super alto
      );

      final recomendacao = useCase(analise: analise, prntDesejado: 100);

      expect(recomendacao.necessidadeCalagem, 0.0);
      expect(recomendacao.p2o5, 0.0);
      expect(recomendacao.k2o, 0.0);
    });
  });
}
