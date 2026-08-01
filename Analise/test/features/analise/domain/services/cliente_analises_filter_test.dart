import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/services/cliente_analises_filter.dart';
import '../../../../support/analise_test_factories.dart';

void main() {
  group('ClienteAnalisesFilter', () {
    test('filtra por FK, analiseIds e nome compatível', () {
      final analises = [
        makeAnalise(id: 'a-fk', talhao: 'T1').copyWith(
          clienteId: 'cliente-1',
          fazendaId: 'f1',
          talhaoId: 't1',
          vinculoStatus: AnaliseVinculoStatus.manual,
        ),
        makeAnalise(id: 'a-index', talhao: 'T2', produtor: 'Outro'),
        makeAnalise(id: 'a-nome', talhao: 'T3', produtor: 'João Silva'),
        makeAnalise(id: 'a-outro', talhao: 'T4', produtor: 'Maria'),
      ];

      final resultado = ClienteAnalisesFilter.filtrar(
        analises: analises,
        clienteId: 'cliente-1',
        analiseIds: const {'a-index'},
        clienteNome: 'João Silva',
      );

      expect(resultado.map((a) => a.id), ['a-fk', 'a-index', 'a-nome']);
    });

    test('retorna vazio para clienteId em branco', () {
      final resultado = ClienteAnalisesFilter.filtrar(
        analises: [makeAnalise(id: 'a1', talhao: 'T1')],
        clienteId: '   ',
      );

      expect(resultado, isEmpty);
    });
  });
}
