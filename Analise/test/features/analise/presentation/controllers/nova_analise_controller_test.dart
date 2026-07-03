import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/analise/application/observability/analise_telemetry.dart';
import 'package:soloforte/features/analise/application/providers/analise_telemetry_provider.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/application/providers/analise_persistence_gateway.dart';
import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';
import 'package:soloforte/features/analise/presentation/controllers/nova_analise_controller.dart';

class _FakeAnalisePersistenceGateway implements AnalisePersistenceGateway {
  final List<AnaliseSolo> salvas = [];
  int saveCalls = 0; // chamadas de salvarLote
  bool failOnSave = false;
  bool replayOnSave = false;
  SaveBatchException? saveBatchException;
  bool recarregou = false;

  @override
  Future<SaveBatchResult> salvarLote(List<AnaliseSolo> analises) async {
    saveCalls++;
    if (saveBatchException != null) {
      throw saveBatchException!;
    }
    if (failOnSave) {
      throw Exception('falha fake');
    }
    salvas.addAll(analises);
    return SaveBatchResult(
      batchId: 'batch-test',
      idempotencyKey: 'key-test',
      status: SaveBatchStatus.committed,
      strategy: SaveStrategy.atomic,
      savedCount: analises.length,
      isReplay: replayOnSave,
      code: replayOnSave ? SaveBatchCode.saveIdempotentReplay : null,
    );
  }

  @override
  Future<void> recarregar() async {
    recarregou = true;
  }
}

class _MemoryTelemetrySink implements AnaliseTelemetrySink {
  final List<Map<String, Object?>> events = [];

  @override
  void emit(Map<String, Object?> event) {
    events.add(Map<String, Object?>.from(event));
  }
}

void main() {
  void preencherCabecalhoObrigatorio(NovaAnaliseController notifier) {
    notifier.atualizarLaudoProdutor('Produtor');
    notifier.atualizarLaudoFazenda('Fazenda');
    notifier.atualizarLaudoLaboratorio('Sellar');
    notifier.atualizarLaudoSafra('2025/2026');
  }

  void preencherAmostraMinima(NovaAnaliseController notifier, int index,
      {required String talhao}) {
    notifier.atualizarCampo(index, 'talhao', talhao);
    notifier.atualizarCampo(index, 'profundidade', '0-20');
    notifier.atualizarCampo(index, 'phCaCl2', '5.4');
    notifier.atualizarCampo(index, 'k', '0.31');
    notifier.atualizarCampo(index, 'ca', '3.1');
    notifier.atualizarCampo(index, 'mg', '1.2');
  }

  AnaliseSolo analiseImportada(String id, String numeroAmostra) {
    return AnaliseSolo(
      id: id,
      fazenda: 'Fazenda Importada',
      produtor: 'Produtor Importado',
      talhao: 'T-Importado',
      numeroAmostra: numeroAmostra,
      cultura: Cultura.soja,
      safra: '2025/2026',
      laboratorio: 'Exata Brasil',
      dataCadastro: DateTime(2026, 5, 27),
      profundidade: '0-20',
    );
  }

  group('NovaAnaliseController', () {
    test(
        'bloqueia salvar quando dados globais obrigatórios não foram preenchidos',
        () async {
      final fake = _FakeAnalisePersistenceGateway();
      final telemetrySink = _MemoryTelemetrySink();
      final telemetry = AnaliseTelemetry(
        sink: telemetrySink,
        operationIdFactory: () => 'op-validation',
      );
      final container = ProviderContainer(
        overrides: [
          analisePersistenceGatewayProvider.overrideWithValue(fake),
          analiseTelemetryProvider.overrideWithValue(telemetry),
        ],
      );
      addTearDown(container.dispose);

      final provider = novaAnaliseControllerProvider(null);
      final notifier = container.read(provider.notifier);
      notifier.atualizarCampo(0, 'talhao', 'T-01');

      final ok = await notifier.salvar();
      final state = container.read(provider);

      expect(ok, isFalse);
      expect(state.error, 'Informe o produtor antes de salvar.');
      expect(fake.saveCalls, 0);
      expect(fake.recarregou, isFalse);
      final names = telemetrySink.events.map((e) => e['eventName']).toList();
      expect(
          names,
          containsAllInOrder([
            AnaliseTelemetryEvents.saveStarted,
            AnaliseTelemetryEvents.saveValidationBlocked,
          ]));
    });

    test(
        'permite salvar com aviso quando uma amostra não tem talhão nem número',
        () async {
      final fake = _FakeAnalisePersistenceGateway();
      final container = ProviderContainer(
        overrides: [
          analisePersistenceGatewayProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);

      final provider = novaAnaliseControllerProvider(null);
      final notifier = container.read(provider.notifier);
      preencherCabecalhoObrigatorio(notifier);
      preencherAmostraMinima(notifier, 0, talhao: 'T-01');
      notifier.adicionarAnalise();

      final ok = await notifier.salvar();
      final state = container.read(provider);

      expect(ok, isTrue);
      expect(state.error, isNull);
      expect(
        state.validation.issues.any((i) => i.code == 'ERR_IDENTITY_REQUIRED'),
        isTrue,
      );
      expect(fake.saveCalls, 1);
      expect(fake.recarregou, isTrue);
    });

    test('salva com sucesso e dispara recarga', () async {
      final fake = _FakeAnalisePersistenceGateway();
      final telemetrySink = _MemoryTelemetrySink();
      final telemetry = AnaliseTelemetry(
        sink: telemetrySink,
        operationIdFactory: () => 'op-commit',
      );
      final container = ProviderContainer(
        overrides: [
          analisePersistenceGatewayProvider.overrideWithValue(fake),
          analiseTelemetryProvider.overrideWithValue(telemetry),
        ],
      );
      addTearDown(container.dispose);

      final notifier =
          container.read(novaAnaliseControllerProvider(null).notifier);
      preencherCabecalhoObrigatorio(notifier);
      preencherAmostraMinima(notifier, 0, talhao: 'T-01');

      final ok = await notifier.salvar();

      expect(ok, isTrue);
      expect(fake.salvas, hasLength(1));
      expect(fake.recarregou, isTrue);
      final names = telemetrySink.events.map((e) => e['eventName']).toList();
      expect(
          names,
          containsAllInOrder([
            AnaliseTelemetryEvents.saveStarted,
            AnaliseTelemetryEvents.savePersisting,
            AnaliseTelemetryEvents.saveCommitted,
          ]));
    });

    test('salvarImportadas persiste lote completo e dispara recarga', () async {
      final fake = _FakeAnalisePersistenceGateway();
      final container = ProviderContainer(
        overrides: [
          analisePersistenceGatewayProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);

      final provider = novaAnaliseControllerProvider(null);
      final notifier = container.read(provider.notifier);
      final importadas = [
        analiseImportada('imp-1', '1'),
        analiseImportada('imp-2', '2'),
      ];

      final result = await notifier.salvarImportadas(importadas);
      final state = container.read(provider);

      expect(result.status, SaveBatchStatus.committed);
      expect(result.savedCount, 2);
      expect(fake.saveCalls, 1);
      expect(fake.salvas, importadas);
      expect(fake.recarregou, isTrue);
      expect(state.isSaving, isFalse);
      expect(state.error, isNull);
    });

    test('salvarImportadas mantém tela em caso de falha de persistência',
        () async {
      final fake = _FakeAnalisePersistenceGateway()
        ..saveBatchException = const SaveBatchException(
          code: SaveBatchCode.saveAtomicFailed,
          message: 'Falha simulada ao persistir lote importado.',
        );
      final container = ProviderContainer(
        overrides: [
          analisePersistenceGatewayProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);

      final provider = novaAnaliseControllerProvider(null);
      final notifier = container.read(provider.notifier);

      await expectLater(
        notifier.salvarImportadas([analiseImportada('imp-1', '1')]),
        throwsA(isA<SaveBatchException>()),
      );
      final state = container.read(provider);

      expect(fake.saveCalls, 1);
      expect(fake.salvas, isEmpty);
      expect(fake.recarregou, isFalse);
      expect(state.isSaving, isFalse);
      expect(state.error, 'Falha ao persistir o lote. Tente novamente.');
    });

    test('preserva id e dataCadastro ao editar', () async {
      final fake = _FakeAnalisePersistenceGateway();
      final dataCadastro = DateTime(2024, 6, 20, 15, 0);
      final existente = AnaliseSolo(
        id: 'id-existente',
        fazenda: 'Fazenda X',
        produtor: 'Produtor X',
        talhao: 'Talhao X',
        numeroAmostra: 'AM-10',
        cultura: Cultura.soja,
        safra: '2024/2025',
        laboratorio: 'IBRA',
        dataCadastro: dataCadastro,
        profundidade: '0-20',
      );

      final container = ProviderContainer(
        overrides: [
          analisePersistenceGatewayProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);

      final notifier =
          container.read(novaAnaliseControllerProvider(existente).notifier);
      preencherCabecalhoObrigatorio(notifier);
      notifier.atualizarCampo(0, 'talhao', 'Talhao Editado');
      notifier.atualizarCampo(0, 'profundidade', '0-20');
      notifier.atualizarCampo(0, 'phCaCl2', '5.3');
      notifier.atualizarCampo(0, 'k', '0.32');
      notifier.atualizarCampo(0, 'ca', '2.9');
      notifier.atualizarCampo(0, 'mg', '1.1');

      final ok = await notifier.salvar();

      expect(ok, isTrue);
      expect(fake.salvas, hasLength(1));
      expect(fake.salvas.first.id, 'id-existente');
      expect(fake.salvas.first.dataCadastro, dataCadastro);
      expect(fake.salvas.first.talhao, 'Talhao Editado');
    });

    test('retorna erro com contexto quando falha no save em lote', () async {
      final fake = _FakeAnalisePersistenceGateway()..failOnSave = true;
      final telemetrySink = _MemoryTelemetrySink();
      final telemetry = AnaliseTelemetry(
        sink: telemetrySink,
        operationIdFactory: () => 'op-failed',
      );
      final container = ProviderContainer(
        overrides: [
          analisePersistenceGatewayProvider.overrideWithValue(fake),
          analiseTelemetryProvider.overrideWithValue(telemetry),
        ],
      );
      addTearDown(container.dispose);

      final provider = novaAnaliseControllerProvider(null);
      final notifier = container.read(provider.notifier);

      preencherCabecalhoObrigatorio(notifier);
      preencherAmostraMinima(notifier, 0, talhao: 'T-01');
      notifier.adicionarAnalise();
      preencherAmostraMinima(notifier, 1, talhao: 'T-02');

      final ok = await notifier.salvar();
      final state = container.read(provider);

      expect(ok, isFalse);
      expect(state.error, isNotNull);
      expect(state.error!, contains('falha fake'));
      expect(fake.recarregou, isFalse);
      final names = telemetrySink.events.map((e) => e['eventName']).toList();
      expect(names, contains(AnaliseTelemetryEvents.saveFailed));
      final failed = telemetrySink.events.firstWhere(
        (event) => event['eventName'] == AnaliseTelemetryEvents.saveFailed,
      );
      expect(failed['errorCode'], 'SAVE_UNKNOWN_ERROR');
    });

    test('normaliza valores e salva snapshot de validação por coluna',
        () async {
      final fake = _FakeAnalisePersistenceGateway();
      final container = ProviderContainer(
        overrides: [
          analisePersistenceGatewayProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);

      final notifier =
          container.read(novaAnaliseControllerProvider(null).notifier);
      notifier.atualizarLaudoProdutor('Produtor');
      notifier.atualizarLaudoFazenda('Fazenda');
      notifier.atualizarLaudoLaboratorio('Exata Brasil');
      notifier.atualizarLaudoSafra('2025/2026');

      notifier.atualizarCampo(0, 'talhao', 'T-01');
      notifier.atualizarCampo(0, 'profundidade', '0-20 cm');
      notifier.atualizarCampo(0, 'phCaCl2', '5,4');
      notifier.atualizarCampo(0, 'k', '391'); // mg/dm3 -> cmolc/dm3
      notifier.atualizarCampo(0, 'ca', '3,2');
      notifier.atualizarCampo(0, 'mg', '1,5');

      final ok = await notifier.salvar();

      expect(ok, isTrue);
      expect(fake.salvas, hasLength(1));
      expect(fake.salvas.first.k, closeTo(1.0, 0.0001));
      expect(fake.salvas.first.profundidade, '0-20');
      expect(fake.salvas.first.laudoMetadata, isNotNull);
      expect(fake.salvas.first.laudoMetadata!['dataContractVersion'], '2.0.0');
      final issues =
          fake.salvas.first.laudoMetadata!['issues'] as List<dynamic>;
      expect(issues, isNotEmpty);
    });

    test('emite save_compensated quando lote cai em compensação', () async {
      final fake = _FakeAnalisePersistenceGateway()
        ..saveBatchException = const SaveBatchException(
          code: SaveBatchCode.saveCompensated,
          message: 'Falha simulada com compensação.',
          batchId: 'batch-comp',
          idempotencyKey: 'idem-comp',
        );
      final telemetrySink = _MemoryTelemetrySink();
      final telemetry = AnaliseTelemetry(
        sink: telemetrySink,
        operationIdFactory: () => 'op-compensated',
      );
      final container = ProviderContainer(
        overrides: [
          analisePersistenceGatewayProvider.overrideWithValue(fake),
          analiseTelemetryProvider.overrideWithValue(telemetry),
        ],
      );
      addTearDown(container.dispose);

      final notifier =
          container.read(novaAnaliseControllerProvider(null).notifier);
      preencherCabecalhoObrigatorio(notifier);
      preencherAmostraMinima(notifier, 0, talhao: 'T-01');

      final ok = await notifier.salvar();

      expect(ok, isFalse);
      final compensated = telemetrySink.events.firstWhere(
        (event) => event['eventName'] == AnaliseTelemetryEvents.saveCompensated,
      );
      expect(compensated['errorCode'], 'SAVE_COMPENSATED');
      expect(compensated['batchId'], 'batch-comp');
      expect(compensated['idempotencyKeyHash'], isA<String>());
    });
  });
}
