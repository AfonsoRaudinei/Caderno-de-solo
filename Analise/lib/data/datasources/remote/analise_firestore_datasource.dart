import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soloforte/features/analise/data/datasources/analise_datasource.dart';
import 'package:soloforte/features/analise/data/models/analise_solo_model.dart';
import 'package:soloforte/features/analise/data/models/produtor_model.dart';

class AnaliseFirestoreDatasource implements AnaliseDataSource {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _collection;

  AnaliseFirestoreDatasource([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _collection = _firestore.collection('analises');
  }

  Future<void> addAnalise(Map<String, dynamic> data) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();
      await _collection.add(data);
    } catch (e) {
      throw Exception('Erro ao adicionar análise: $e');
    }
  }

  Future<void> updateAnalise(String id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _collection.doc(id).update(data);
    } catch (e) {
      throw Exception('Erro ao atualizar análise: $e');
    }
  }

  @override
  Future<void> deleteAnalise(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar análise: $e');
    }
  }

  @override
  Future<List<AnaliseSoloModel>> getAnalises() async {
    try {
      final querySnapshot =
          await _collection.orderBy('dataCadastro', descending: true).get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AnaliseSoloModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao listar análises: $e');
    }
  }

  @override
  Future<void> saveAnalise(AnaliseSoloModel analise) async {
    final data = analise.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _collection.doc(analise.id).set(data, SetOptions(merge: true));
  }

  @override
  Future<List<ProdutorModel>> getProdutores() async {
    return const [];
  }

  Future<Map<String, dynamic>?> getAnalise(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar análise: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAnalisesByUser(String userId) async {
    try {
      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Erro ao listar análises: $e');
    }
  }
}
