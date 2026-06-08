import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/data/datasources/remote/recomendacao_firestore_datasource.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';
import 'package:soloforte/features/historico/domain/repositories/historico_repository.dart';

final historicoRepositoryProvider = Provider<HistoricoRepository>((ref) {
  return HistoricoRepositoryImpl(
    datasource: ref.watch(recomendacaoDatasourceProvider),
    firestore: FirebaseFirestore.instance,
  );
});

class HistoricoRepositoryImpl implements HistoricoRepository {
  HistoricoRepositoryImpl({
    required RecomendacaoFirestoreDatasource datasource,
    required FirebaseFirestore firestore,
  })  : _datasource = datasource,
        _firestore = firestore;

  final RecomendacaoFirestoreDatasource _datasource;
  final FirebaseFirestore _firestore;

  @override
  Future<List<RecomendacaoModel>> listarPorAnaliseIds({
    required Set<String> analiseIds,
    required String userId,
  }) async {
    final recomendacoes = <RecomendacaoModel>[];

    for (final analiseId in analiseIds) {
      final itens = await _datasource.getRecomendacoesByAnalise(
        analiseId: analiseId,
        userId: userId,
      );
      for (final item in itens) {
        final model = _toModel(item);
        if (model != null) {
          recomendacoes.add(model);
        }
      }
    }

    recomendacoes.sort(
      (a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
    return recomendacoes;
  }

  @override
  Future<void> deletarRecomendacao(String id) async {
    await _firestore.collection('recomendacoes').doc(id).delete();
  }

  RecomendacaoModel? _toModel(Map<String, dynamic> data) {
    try {
      final normalizado = <String, dynamic>{
        'id': data['id']?.toString() ?? '',
        'analiseId': data['analiseId']?.toString() ?? '',
        'cultura': data['cultura']?.toString() ?? '',
        'necessidadeCalagem': _toDouble(data['necessidadeCalagem']),
        'prnt': _toDouble(data['prnt']),
        'doseCalcario': _toDouble(data['doseCalcario']),
        'p2o5': _toDouble(data['p2o5']),
        'k2o': _toDouble(data['k2o']),
        'citacaoCalagem': _toCitacaoJson(data['citacaoCalagem']),
        'citacaoGesso': _toCitacaoJson(data['citacaoGesso']),
        'citacaoFosforo': _toCitacaoJson(data['citacaoFosforo']),
        'citacaoPotassio': _toCitacaoJson(data['citacaoPotassio']),
        'citacaoEnxofre': _toCitacaoJson(data['citacaoEnxofre']),
        'citacaoMicronutrientes':
            _toCitacaoJson(data['citacaoMicronutrientes']),
        'createdAt': data['createdAt'],
      };

      return RecomendacaoModel.fromJson(normalizado);
    } catch (_) {
      return null;
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> _toCitacaoJson(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry('$key', val));
    }
    return const <String, dynamic>{};
  }
}
