import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/clientes/presentation/widgets/analise_vinculo_badge.dart';
import '../../../support/analise_test_factories.dart';

void main() {
  group('analiseExibeVinculoPendente', () {
    test('retorna true sem FK completa', () {
      final analise = makeAnalise(id: 'a1', talhao: 'T1');
      expect(analiseExibeVinculoPendente(analise), isTrue);
    });

    test('retorna true com status pendente', () {
      final analise = makeAnalise(id: 'a1', talhao: 'T1').copyWith(
        clienteId: 'c1',
        fazendaId: 'f1',
        talhaoId: 't1',
        vinculoStatus: AnaliseVinculoStatus.pendente,
      );
      expect(analiseExibeVinculoPendente(analise), isTrue);
    });

    test('retorna false com vínculo manual completo', () {
      final analise = makeAnalise(id: 'a1', talhao: 'T1').copyWith(
        clienteId: 'c1',
        fazendaId: 'f1',
        talhaoId: 't1',
        vinculoStatus: AnaliseVinculoStatus.manual,
      );
      expect(analiseExibeVinculoPendente(analise), isFalse);
    });
  });
}
