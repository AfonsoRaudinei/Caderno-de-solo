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
        produtor: 'Fazenda AAA',
        talhao: 'Talhão 1',
        dataColeta: '2023-10-01',
        status: 'Concluído',
        cultura: 'Soja',
        phAgua: 5.0,
        pResina: 4.0, // menor que o critico (18.0 Mehlich para argiloso)
        k: 0.2, // ~2% de CTC 10
        ca: 2.0,
        mg: 1.0,
        hMaisAl: 6.8,
        argila: 400.0,
        fontePrincipalP: FonteP.resina,
      );

      final recomendacao = useCase(analise: analise, prntDesejado: 100);

      // Asserts Calcário: (10.0 * (70-32))/100 = 3.8 t/ha
      expect(recomendacao.necessidadeCalagem, 3.8);

      // Asserts Fósforo (modo correção):
      // argilaPercent=40 → argiloso → NC_Mehlich=18, fator=4, fep=15
      // deficit=14, doseBase=56, dose=56/(15/100)=373.33 kg/ha P₂O₅
      expect(recomendacao.p2o5, closeTo(373.33, 0.01));

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
        produtor: '',
        talhao: '',
        dataColeta: '',
        status: '',
        cultura: '',
        phAgua: 6.5,
        pMehlich: 20.0, // super fértil
        k: 1.0, // 10% da CTC
        ca: 6.0,
        mg: 2.0,
        hMaisAl: 1.0,
        argila: 400.0,
        fontePrincipalP: FonteP.mehlich,
      );

      final recomendacao = useCase(analise: analise, prntDesejado: 100);

      expect(recomendacao.necessidadeCalagem, 0.0);
      expect(recomendacao.p2o5, 0.0);
      expect(recomendacao.k2o, 0.0);
    });
  });
}
