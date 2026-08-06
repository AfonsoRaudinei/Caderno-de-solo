import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/usecases/aplicar_hierarquia_analises_usecase.dart';
import 'package:soloforte/features/analise/domain/value_objects/hierarquia_selecao_result.dart';
import '../../../../support/analise_test_factories.dart';

void main() {
  const usecase = AplicarHierarquiaAnalisesUsecase();

  const selecao = HierarquiaSelecaoResult(
    clienteId: 'cliente-1',
    fazendaId: 'fazenda-1',
    talhaoId: 'talhao-1',
    clienteNome: 'João Silva',
    fazendaNome: 'Fazenda Boa Vista',
    talhaoNome: 'Talhão 01',
  );

  group('AplicarHierarquiaAnalisesUsecase', () {
    test('aplica vínculo manual e produtor configurado em lote', () {
      final analises = [
        makeAnalise(
          id: 'a1',
          talhao: 'Talhão 01',
          produtor: 'Produtor Laudo',
          fazenda: 'Fazenda Boa Vista',
        ),
        makeAnalise(
          id: 'a2',
          talhao: '',
          produtor: '',
          fazenda: '',
        ),
      ];

      final resultado = usecase(analises: analises, selecao: selecao);

      expect(resultado, hasLength(2));
      for (final analise in resultado) {
        expect(analise.clienteId, 'cliente-1');
        expect(analise.fazendaId, 'fazenda-1');
        expect(analise.talhaoId, 'talhao-1');
        expect(analise.vinculoStatus, AnaliseVinculoStatus.manual);
        expect(analise.produtor, 'João Silva');
      }
      expect(resultado.first.fazenda, 'Fazenda Boa Vista');
      expect(resultado.first.talhao, 'Talhão 01');
      expect(resultado.last.fazenda, 'Fazenda Boa Vista');
      expect(resultado.last.talhao, 'Talhão 01');
    });

    test('retorna lista inalterada quando seleção é inválida', () {
      final analises = [
        makeAnalise(id: 'a1', talhao: 'T1'),
      ];
      const invalida = HierarquiaSelecaoResult(
        clienteId: '',
        fazendaId: 'fazenda-1',
        talhaoId: 'talhao-1',
        clienteNome: '',
        fazendaNome: 'Fazenda',
        talhaoNome: 'Talhão',
      );

      final resultado = usecase(analises: analises, selecao: invalida);

      expect(resultado, same(analises));
    });
  });
}
