import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      data['createdAt'] = FieldValue.serverTimestamp();
      await _collection.add(data);
    } catch (e) {
      throw Exception('Erro ao salvar recomendação: $e');
    }
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
