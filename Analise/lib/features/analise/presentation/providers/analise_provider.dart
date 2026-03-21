import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloforte/core/config/app_config.dart';
import 'package:soloforte/data/datasources/remote/analise_firestore_datasource.dart';
import 'package:soloforte/features/analise/data/datasources/analise_datasource.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/usecases/get_analises_usecase.dart';
import 'package:soloforte/features/analise/domain/usecases/save_analise_usecase.dart';
import 'package:soloforte/features/analise/domain/usecases/delete_analise_usecase.dart';
import 'package:soloforte/features/analise/domain/repositories/analise_repository.dart';
import 'package:soloforte/features/analise/data/repositories/analise_repository_impl.dart';
import 'package:soloforte/features/analise/data/datasources/analise_local_datasource.dart';

part 'analise_provider.g.dart';

@riverpod
AnaliseLocalDatasource analiseLocalDatasource(AnaliseLocalDatasourceRef ref) {
  return AnaliseLocalDatasource();
}

final analiseFirestoreDatasourceProvider =
    Provider<AnaliseFirestoreDatasource>((ref) {
  return AnaliseFirestoreDatasource();
});

final analiseDataSourceProvider = Provider<AnaliseDataSource>((ref) {
  if (AppConfig.useFirestore) {
    return ref.watch(analiseFirestoreDatasourceProvider);
  }
  return ref.watch(analiseLocalDatasourceProvider);
});

@riverpod
AnaliseRepository analiseRepository(AnaliseRepositoryRef ref) {
  final dataSource = ref.watch(analiseDataSourceProvider);
  return AnaliseRepositoryImpl(dataSource: dataSource);
}

@riverpod
GetAnalisesUsecase getAnalisesUsecase(GetAnalisesUsecaseRef ref) {
  final repository = ref.watch(analiseRepositoryProvider);
  return GetAnalisesUsecase(repository);
}

@riverpod
SaveAnaliseUsecase saveAnaliseUsecase(SaveAnaliseUsecaseRef ref) {
  final repository = ref.watch(analiseRepositoryProvider);
  return SaveAnaliseUsecase(repository);
}

@riverpod
DeleteAnaliseUsecase deleteAnaliseUsecase(DeleteAnaliseUsecaseRef ref) {
  final repository = ref.watch(analiseRepositoryProvider);
  return DeleteAnaliseUsecase(repository);
}

@riverpod
class AnaliseNotifier extends _$AnaliseNotifier {
  @override
  Future<List<AnaliseSolo>> build() async {
    return ref.read(getAnalisesUsecaseProvider).call();
  }

  Future<void> salvar(AnaliseSolo analise) async {
    await ref.read(saveAnaliseUsecaseProvider).call(analise);
    ref.invalidateSelf();
  }

  Future<void> deletar(String id) async {
    await ref.read(deleteAnaliseUsecaseProvider).call(id);
    ref.invalidateSelf();
  }
}

@riverpod
List<AnaliseSolo> analisesFiltradas(
  AnalisesFiltradasRef ref, {
  Cultura? cultura,
  String? produtorId,
  String? safra,
  String? busca,
}) {
  final lista = ref.watch(analiseNotifierProvider).valueOrNull ?? [];
  return lista.where((a) {
    if (cultura != null && a.cultura != cultura) return false;
    if (produtorId != null && a.produtorId != produtorId) return false;
    if (safra != null && a.safra != safra) return false;
    if (busca != null && busca.isNotEmpty) {
      final q = busca.toLowerCase();
      return a.nomeArea.toLowerCase().contains(q) ||
          a.laboratorio.toLowerCase().contains(q);
    }
    return true;
  }).toList();
}
