import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/data/datasources/remote/recomendacao_firestore_datasource.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';

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

    final datasource = ref.read(recomendacaoDatasourceProvider);
    final analises = await ref.watch(analiseNotifierProvider.future);

    final ids = analises.map((a) => a.id).where((id) => id.isNotEmpty).toSet();
    if (ids.isEmpty) return [];

    final recomendacoes = <RecomendacaoModel>[];

    for (final analiseId in ids) {
      final itens = await datasource.getRecomendacoesByAnalise(analiseId);
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
    if (value is num) {
      return value.toDouble();
    }
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

  Future<void> deletar(String id) async {
    await FirebaseFirestore.instance
        .collection('recomendacoes')
        .doc(id)
        .delete();
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_carregar);
  }
}
