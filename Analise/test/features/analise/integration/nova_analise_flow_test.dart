import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/presentation/controllers/nova_analise_controller.dart';

import '../../../support/analise_test_harness.dart';
import '../../../support/analise_test_factories.dart';

void _fillMin(NovaAnaliseController notifier, int index,
    {required String talhao}) {
  notifier.atualizarCampo(index, 'talhao', talhao);
  notifier.atualizarCampo(index, 'profundidade', '0-20');
  notifier.atualizarCampo(index, 'phCaCl2', '5.4');
  notifier.atualizarCampo(index, 'k', '0.31');
  notifier.atualizarCampo(index, 'ca', '3.1');
  notifier.atualizarCampo(index, 'mg', '1.2');
}

void _fillCabecalho(NovaAnaliseController notifier) {
  notifier.atualizarLaudoProdutor('Produtor');
  notifier.atualizarLaudoFazenda('Fazenda');
  notifier.atualizarLaudoLaboratorio('Sellar');
  notifier.atualizarLaudoSafra('2025/2026');
}

void main() {
  group('NovaAnaliseController fluxo completo (integração headless)', () {
    test('A1 válido + A2 incompleto salva com warning sem meio estado',
        () async {
      final gateway = InMemoryBatchGateway();
      final container = makeAnaliseContainer(gateway: gateway);
      addTearDown(container.dispose);

      final notifier =
          container.read(novaAnaliseControllerProvider(null).notifier);
      _fillCabecalho(notifier);
      _fillMin(notifier, 0, talhao: 'T-01');
      notifier.adicionarAnalise();

      final ok = await notifier.salvar();
      expect(ok, isTrue);
      expect(gateway.committed, hasLength(2));
      expect(gateway.committed.map((e) => e.talhao).toSet(), {'T-01', ''});
    });

    test('falha com compensação não deixa estado parcial visível', () async {
      final gateway = InMemoryBatchGateway()..failWithCompensation = true;
      final container = makeAnaliseContainer(gateway: gateway);
      addTearDown(container.dispose);

      final notifier =
          container.read(novaAnaliseControllerProvider(null).notifier);
      _fillCabecalho(notifier);
      _fillMin(notifier, 0, talhao: 'T-01');

      final ok = await notifier.salvar();
      expect(ok, isFalse);
      expect(gateway.committed, isEmpty);
    });

    test('retry idempotente não duplica', () async {
      final gateway = InMemoryBatchGateway();
      final container = makeAnaliseContainer(gateway: gateway);
      addTearDown(container.dispose);

      final notifier =
          container.read(novaAnaliseControllerProvider(null).notifier);
      final existente =
          makeAnalise(id: 'idem-01', talhao: 'T-IDEM', numeroAmostra: 'A-IDEM');
      notifier.carregarDeAnaliseSolo([existente]);

      final ok1 = await notifier.salvar();
      final ok2 = await notifier.salvar();
      expect(ok1, isTrue);
      expect(ok2, isTrue);
      expect(gateway.committed, hasLength(1));
      expect(gateway.committed.first.id, 'idem-01');
    });
  });
}
