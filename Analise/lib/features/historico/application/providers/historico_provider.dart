import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/data/datasources/remote/recomendacao_firestore_datasource.dart';
import 'package:soloforte/features/historico/data/repositories/historico_repository_impl.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/historico/domain/repositories/historico_repository.dart';
import 'package:soloforte/features/historico/domain/usecases/carregar_historico_usecase.dart';
import 'package:soloforte/features/historico/domain/usecases/deletar_recomendacao_usecase.dart';

final historicoRepositoryProvider = Provider<HistoricoRepository>((ref) {
  return HistoricoRepositoryImpl(
    datasource: ref.read(recomendacaoDatasourceProvider),
    firestore: FirebaseFirestore.instance,
  );
});

final carregarHistoricoUseCaseProvider =
    Provider<CarregarHistoricoUseCase>((ref) {
  return CarregarHistoricoUseCase(ref.read(historicoRepositoryProvider));
});

final deletarRecomendacaoUseCaseProvider =
    Provider<DeletarRecomendacaoUseCase>((ref) {
  return DeletarRecomendacaoUseCase(ref.read(historicoRepositoryProvider));
});

final historicoProvider =
    AsyncNotifierProvider<HistoricoNotifier, List<RecomendacaoModel>>(
  HistoricoNotifier.new,
);

class HistoricoNotifier extends AsyncNotifier<List<RecomendacaoModel>> {
  @override
  Future<List<RecomendacaoModel>> build() async {
    return _carregar();
  }

  Future<List<RecomendacaoModel>> _carregar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final carregarHistorico = ref.read(carregarHistoricoUseCaseProvider);
    final analises = await ref.watch(analiseNotifierProvider.future);

    final ids = analises.map((a) => a.id).where((id) => id.isNotEmpty).toSet();
    return carregarHistorico(ids);
  }

  Future<void> deletar(String id) async {
    final deletarRecomendacao = ref.read(deletarRecomendacaoUseCaseProvider);
    await deletarRecomendacao(id);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_carregar);
  }
}
