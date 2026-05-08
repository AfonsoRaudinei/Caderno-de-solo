import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/data/datasources/local/calibracao_hive_datasource.dart';
import 'package:soloforte/data/datasources/remote/calibracao_firestore_datasource.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/features/lab/calibracao/data/calibracao_padrao.dart';
import 'package:soloforte/features/laboratorio/domain/repositories/calibracao_repository.dart';
import 'package:uuid/uuid.dart';

final calibracaoRepositoryProvider = Provider<CalibracaoRepository>((ref) {
  return CalibracaoRepositoryImpl(
    hiveDatasource: CalibracaoHiveDatasource(),
    firestoreDatasource: CalibracaoFirestoreDatasource(FirebaseFirestore.instance),
    auth: FirebaseAuth.instance,
  );
});

class CalibracaoRepositoryImpl implements CalibracaoRepository {
  CalibracaoRepositoryImpl({
    required CalibracaoHiveDatasource hiveDatasource,
    required CalibracaoFirestoreDatasource firestoreDatasource,
    required FirebaseAuth auth,
  })  : _hiveDatasource = hiveDatasource,
        _firestoreDatasource = firestoreDatasource,
        _auth = auth;

  final CalibracaoHiveDatasource _hiveDatasource;
  final CalibracaoFirestoreDatasource _firestoreDatasource;
  final FirebaseAuth _auth;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<CalibracaoProfile>> carregarPerfis() async {
    var localMaps = await _hiveDatasource.getProfiles();
    final alreadySeeded = await _hiveDatasource.hasBeenSeeded();
    if (!alreadySeeded && localMaps.isEmpty) {
      final padrao = calibracaoPadrao(id: _uuid.v4());
      await _persistLocal([padrao]);
      await _hiveDatasource.markAsSeeded();
      localMaps = [padrao.toJson()];
    }

    final local = localMaps.map(CalibracaoProfile.fromJson).toList();
    var merged = local;
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        final remoteMaps = await _firestoreDatasource.getProfiles(userId);
        final remote = remoteMaps.map(CalibracaoProfile.fromJson).toList();
        merged = _mergeProfiles(local: local, remote: remote);
        await _persistLocal(merged);
      } catch (_) {
        // Offline/falha remota não impede fluxo local.
      }
    }
    return _sortByUpdatedDesc(merged);
  }

  @override
  Future<void> salvarPerfis({
    required List<CalibracaoProfile> perfis,
    required CalibracaoProfile perfilSincronizar,
  }) async {
    await _persistLocal(perfis);
    await _syncUpsert(perfilSincronizar);
  }

  @override
  Future<void> excluirPerfil({
    required List<CalibracaoProfile> perfisRestantes,
    required String perfilId,
  }) async {
    await _persistLocal(perfisRestantes);
    await _syncDelete(perfilId);
  }

  Future<void> _persistLocal(List<CalibracaoProfile> profiles) async {
    final json = profiles.map((e) => e.toJson()).toList();
    await _hiveDatasource.saveProfiles(json);
  }

  Future<void> _syncUpsert(CalibracaoProfile profile) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestoreDatasource.upsertProfile(userId, profile.toJson());
    } catch (_) {
      // Falha de sync remota é tolerada no fluxo offline-first.
    }
  }

  Future<void> _syncDelete(String profileId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestoreDatasource.deleteProfile(userId, profileId);
    } catch (_) {
      // Falha de sync remota é tolerada no fluxo offline-first.
    }
  }

  List<CalibracaoProfile> _mergeProfiles({
    required List<CalibracaoProfile> local,
    required List<CalibracaoProfile> remote,
  }) {
    final byId = <String, CalibracaoProfile>{};
    for (final p in [...local, ...remote]) {
      final existing = byId[p.id];
      if (existing == null || p.updatedAt.isAfter(existing.updatedAt)) {
        byId[p.id] = p;
      }
    }
    return byId.values.toList();
  }

  List<CalibracaoProfile> _sortByUpdatedDesc(List<CalibracaoProfile> profiles) {
    return [...profiles]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}
