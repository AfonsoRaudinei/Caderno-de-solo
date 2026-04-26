import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/data/datasources/analise_local_datasource.dart';
import 'package:soloforte/features/analise/data/models/analise_solo_model.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';

AnaliseSoloModel _model(String id, String talhao) {
  return AnaliseSoloModel(
    id: id,
    fazenda: 'Fazenda',
    produtor: 'Produtor',
    talhao: talhao,
    numeroAmostra: id,
    cultura: Cultura.soja,
    safra: '2025/2026',
    laboratorio: 'Sellar',
    dataCadastro: DateTime(2026, 4, 6),
    profundidade: '0-20',
    phCaCl2: 5.3,
    k: 0.32,
    ca: 2.9,
    mg: 1.1,
  );
}

void main() {
  group('AnaliseLocalDatasource batch persistence', () {
    test('idempotência de reenvio não duplica dados', () async {
      final ds = AnaliseLocalDatasource(useAssetSeed: false);
      final payload = [_model('a1', 'T-01'), _model('a2', 'T-02')];

      final first = await ds.saveAnalisesBatch(payload);
      final second = await ds.saveAnalisesBatch(payload);
      final all = await ds.getAnalises();

      expect(first.isReplay, isFalse);
      expect(second.isReplay, isTrue);
      expect(second.code, SaveBatchCode.saveIdempotentReplay);
      expect(all, hasLength(2));
    });

    test('falha simulada não deixa estado meio salvo visível', () async {
      final ds = AnaliseLocalDatasource(
        useAssetSeed: false,
        faultInjection: const BatchFaultInjection(failAfterPendingWrites: 1),
      );
      final payload = [_model('a1', 'T-01'), _model('a2', 'T-02')];

      try {
        await ds.saveAnalisesBatch(payload);
        fail('Era esperado SaveBatchException');
      } catch (e) {
        expect(e, isA<SaveBatchException>());
        final err = e as SaveBatchException;
        expect(err.code, SaveBatchCode.saveCompensated);
      }

      final all = await ds.getAnalises();
      expect(all, isEmpty);
    });

    test('recovery converte persisting órfão para compensado', () async {
      final ds = AnaliseLocalDatasource(
        useAssetSeed: false,
        faultInjection: const BatchFaultInjection(
          failAfterPendingWrites: 1,
          skipCompensationOnFailure: true,
          leaveBatchPersistingOnFailure: true,
        ),
      );
      final payload = [_model('a1', 'T-01'), _model('a2', 'T-02')];

      try {
        await ds.saveAnalisesBatch(payload);
      } catch (_) {}

      // Ainda não deve vazar pending em leitura.
      final before = await ds.getAnalises();
      expect(before, isEmpty);

      await ds.recoverPendingBatches(timeout: Duration.zero);
      final after = await ds.getAnalises();
      expect(after, isEmpty);
    });
  });
}
