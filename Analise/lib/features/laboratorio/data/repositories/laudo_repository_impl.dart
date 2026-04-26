import 'package:soloforte/features/laboratorio/data/datasources/laudo_firestore_datasource.dart';
import 'package:soloforte/features/laboratorio/data/datasources/laudo_hive_datasource.dart';
import 'package:soloforte/features/laboratorio/data/models/laudo_recomendacao_model.dart';
import 'package:soloforte/features/laboratorio/domain/entities/laudo_recomendacao.dart';
import 'package:soloforte/features/laboratorio/domain/repositories/laudo_repository.dart';
import 'package:soloforte/core/services/app_observability.dart';

/// Implementação offline-first:
/// 1. Lê e persiste SEMPRE localmente (Hive).
/// 2. Sincroniza com o Firestore de forma silenciosa em background.
class LaudoRepositoryImpl implements LaudoRepository {
  LaudoRepositoryImpl({
    required LaudoHiveDatasource hiveDatasource,
    required LaudoFirestoreDatasource firestoreDatasource,
  })  : _hive = hiveDatasource,
        _firestore = firestoreDatasource;

  final LaudoHiveDatasource _hive;
  final LaudoFirestoreDatasource _firestore;

  @override
  Future<List<LaudoRecomendacao>> getLaudos() async {
    return AppObservability.instance.trace(
      'laudo_repository_get_all',
      () async {
        // Tenta enriquecer com dados remotos primeiro.
        try {
          final remote = await _firestore.getLaudos();
          if (remote.isNotEmpty) {
            // Merge: mantém os mais recentes e persiste localmente.
            final local = await _hive.getLaudos();
            final byId = <String, LaudoRecomendacaoModel>{};
            for (final l in [...local, ...remote]) {
              final existing = byId[l.id];
              if (existing == null || l.geradaEm.isAfter(existing.geradaEm)) {
                byId[l.id] = l;
              }
            }
            final merged = byId.values.toList()
              ..sort((a, b) => b.geradaEm.compareTo(a.geradaEm));
            // Persiste localmente para uso offline.
            for (final l in merged) {
              await _hive.saveLaudo(l);
            }
            return merged;
          }
        } catch (_) {}
        return _hive.getLaudos();
      },
      attributes: {'flow': 'historico', 'layer': 'repository'},
    );
  }

  @override
  Future<void> saveLaudo(LaudoRecomendacao laudo) async {
    await AppObservability.instance.trace(
      'laudo_repository_save',
      () async {
        final model = _toModel(laudo);
        await _hive.saveLaudo(model); // local primeiro — jamais falha
        await _firestore.saveLaudo(model); // sync remoto silencioso
      },
      attributes: {'flow': 'laudo', 'layer': 'repository'},
    );
  }

  @override
  Future<void> deleteLaudo(String id) async {
    await AppObservability.instance.trace(
      'laudo_repository_delete',
      () async {
        await _hive.deleteLaudo(id);
        await _firestore.deleteLaudo(id);
      },
      attributes: {'flow': 'historico', 'layer': 'repository'},
    );
  }

  // ── helper ─────────────────────────────────────────────────────────────

  LaudoRecomendacaoModel _toModel(LaudoRecomendacao l) {
    return LaudoRecomendacaoModel(
      id: l.id,
      userId: l.userId,
      analiseId: l.analiseId,
      calibracaoId: l.calibracaoId,
      geradaEm: l.geradaEm,
      talhao: l.talhao,
      fazenda: l.fazenda,
      cliente: l.cliente,
      cultura: l.cultura,
      safra: l.safra,
      laboratorio: l.laboratorio,
      nomeCalibra: l.nomeCalibra,
      metodoCalagem: l.metodoCalagem,
      doseCalcarioTHa: l.doseCalcarioTHa,
      vAtual: l.vAtual,
      vEsperado: l.vEsperado,
      caAtual: l.caAtual,
      caEsperado: l.caEsperado,
      mgAtual: l.mgAtual,
      mgEsperado: l.mgEsperado,
      relacaoCaMg: l.relacaoCaMg,
      parcelamento: l.parcelamento,
      gessoIndicado: l.gessoIndicado,
      gessoKgHa: l.gessoKgHa,
      modoFosforo: l.modoFosforo,
      pSoloMgDm3: l.pSoloMgDm3,
      ncFosforo: l.ncFosforo,
      doseP2O5KgHa: l.doseP2O5KgHa,
      legacyP: l.legacyP,
      criterioPotassio: l.criterioPotassio,
      kSolo: l.kSolo,
      ncPotassio: l.ncPotassio,
      doseK2OKgHa: l.doseK2OKgHa,
      micros: l.micros,
      avisos: l.avisos,
      argumentos: l.argumentos,
      status: l.status,
    );
  }
}
