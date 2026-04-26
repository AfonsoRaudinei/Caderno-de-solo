import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/laboratorio/domain/entities/laudo_recomendacao.dart';
import 'package:soloforte/features/laboratorio/domain/repositories/laudo_repository.dart';
import 'package:soloforte/features/laboratorio/presentation/providers/laudo_provider.dart';

class FakeLaudoRepo implements LaudoRepository {
  final List<LaudoRecomendacao> _store;

  FakeLaudoRepo([List<LaudoRecomendacao> initial = const []])
      : _store = List<LaudoRecomendacao>.from(initial);

  @override
  Future<List<LaudoRecomendacao>> getLaudos() async {
    return List<LaudoRecomendacao>.from(_store);
  }

  @override
  Future<void> saveLaudo(LaudoRecomendacao laudo) async {
    _store.removeWhere((e) => e.id == laudo.id);
    _store.insert(0, laudo);
  }

  @override
  Future<void> deleteLaudo(String id) async {
    _store.removeWhere((e) => e.id == id);
  }
}

LaudoRecomendacao _laudo(String id) {
  return LaudoRecomendacao(
    id: id,
    userId: 'u1',
    analiseId: 'a1',
    calibracaoId: 'c1',
    geradaEm: DateTime(2026, 4, 5),
    talhao: 'Talhão',
    fazenda: 'Fazenda',
    cliente: 'Cliente',
    cultura: 'Soja',
    safra: '24/25',
    laboratorio: 'Lab',
    nomeCalibra: 'Cal',
    metodoCalagem: '① Saturação por Bases (V%)',
    doseCalcarioTHa: 1.2,
    vAtual: 45,
    vEsperado: 65,
    caAtual: 2,
    caEsperado: 2.4,
    mgAtual: 0.8,
    mgEsperado: 1.0,
    relacaoCaMg: 2.5,
    parcelamento: const [],
    gessoIndicado: false,
    gessoKgHa: 0,
    modoFosforo: '① Correção do solo',
    pSoloMgDm3: 10,
    ncFosforo: 20,
    doseP2O5KgHa: 35,
    legacyP: false,
    criterioPotassio: 'Ambos',
    kSolo: 0.2,
    ncPotassio: 70,
    doseK2OKgHa: 80,
    micros: const [],
    avisos: const [],
    argumentos: 'ok',
  );
}

void main() {
  test('LaudoNotifier salva e deleta mantendo estado atualizado', () async {
    final repo = FakeLaudoRepo([_laudo('L1')]);
    final container = ProviderContainer(
      overrides: [
        laudoRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(laudoNotifierProvider.future);
    expect(initial.map((e) => e.id), ['L1']);

    await container.read(laudoNotifierProvider.notifier).salvar(_laudo('L2'));
    final afterSave = await container.read(laudoNotifierProvider.future);
    expect(afterSave.map((e) => e.id), contains('L2'));

    await container.read(laudoNotifierProvider.notifier).deletar('L1');
    final afterDelete = await container.read(laudoNotifierProvider.future);
    expect(afterDelete.map((e) => e.id), isNot(contains('L1')));
  });
}
