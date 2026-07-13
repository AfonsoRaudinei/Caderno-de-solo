import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/domain/entities/citacao_calibracao_model.dart';

final recomendacaoDatasourceProvider =
    Provider<RecomendacaoFirestoreDatasource>((ref) {
  return RecomendacaoFirestoreDatasource(FirebaseFirestore.instance);
});

class RecomendacaoFirestoreDatasource {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _collection;

  RecomendacaoFirestoreDatasource(this._firestore) {
    _collection = _firestore.collection('recomendacoes');
  }

  Future<void> saveRecomendacao(Map<String, dynamic> data) async {
    try {
      final firestoreData = _serializarParaFirestore(data);
      firestoreData['createdAt'] = FieldValue.serverTimestamp();
      assert(
        firestoreData.entries
            .where((entry) => entry.key.startsWith('citacao'))
            .every((entry) => entry.value == null || entry.value is Map),
        'ERRO: Campo de citação não serializado. Chamar .toJson() antes de salvar.',
      );
      await _collection.add(firestoreData);
    } catch (e) {
      throw Exception('Erro ao salvar recomendação: $e');
    }
  }

  Map<String, dynamic> _serializarParaFirestore(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, _serializarValor(value)));
  }

  dynamic _serializarValor(dynamic value) {
    if (value is CitacaoCalibracaoModel) {
      return value.toJson();
    }
    if (value is Map<String, dynamic>) {
      return _serializarParaFirestore(value);
    }
    if (value is List) {
      return value.map(_serializarValor).toList(growable: false);
    }
    return value;
  }

  Future<List<Map<String, dynamic>>> getRecomendacoesByAnalise({
    required String analiseId,
    required String userId,
  }) async {
    try {
      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('analiseId', isEqualTo: analiseId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Erro ao listar recomendações da análise: $e');
    }
  }
}
