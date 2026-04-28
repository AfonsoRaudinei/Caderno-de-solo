import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/laboratorio/data/datasources/laudo_firestore_datasource.dart';
import 'package:soloforte/features/laboratorio/data/datasources/laudo_hive_datasource.dart';
import 'package:soloforte/features/laboratorio/data/repositories/laudo_repository_impl.dart';
import 'package:soloforte/features/laboratorio/domain/entities/laudo_recomendacao.dart';
import 'package:soloforte/features/laboratorio/domain/repositories/laudo_repository.dart';

// ── Datasources ─────────────────────────────────────────────────────────────

final laudoHiveDatasourceProvider = Provider<LaudoHiveDatasource>((ref) {
  return LaudoHiveDatasource();
});

final laudoFirestoreDatasourceProvider =
    Provider<LaudoFirestoreDatasource>((ref) {
  return LaudoFirestoreDatasource();
});

// ── Repository ───────────────────────────────────────────────────────────────

final laudoRepositoryProvider = Provider<LaudoRepository>((ref) {
  return LaudoRepositoryImpl(
    hiveDatasource: ref.watch(laudoHiveDatasourceProvider),
    firestoreDatasource: ref.watch(laudoFirestoreDatasourceProvider),
  );
});

// ── Notifier (State) ─────────────────────────────────────────────────────────

class LaudoNotifier extends AsyncNotifier<List<LaudoRecomendacao>> {
  @override
  Future<List<LaudoRecomendacao>> build() async {
    return ref.read(laudoRepositoryProvider).getLaudos();
  }

  /// Persiste o laudo e recarrega o estado.
  Future<void> salvar(LaudoRecomendacao laudo) async {
    await ref.read(laudoRepositoryProvider).saveLaudo(laudo);
    ref.invalidateSelf();
  }

  /// Remove o laudo e recarrega o estado.
  Future<void> deletar(String id) async {
    await ref.read(laudoRepositoryProvider).deleteLaudo(id);
    ref.invalidateSelf();
  }
}

final laudoNotifierProvider =
    AsyncNotifierProvider<LaudoNotifier, List<LaudoRecomendacao>>(
  LaudoNotifier.new,
);

// ── Helper: userId atual ─────────────────────────────────────────────────────

/// Retorna o uid do usuário autenticado ou string vazia.
String currentUserId() => FirebaseAuth.instance.currentUser?.uid ?? '';
