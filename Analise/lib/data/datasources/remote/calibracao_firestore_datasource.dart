import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soloforte/domain/exceptions/permission_denied_exception.dart';

class CalibracaoFirestoreDatasource {
  CalibracaoFirestoreDatasource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('calibracoes');
  }

  Future<List<Map<String, dynamic>>> getProfiles(String userId) async {
    try {
      final snapshot = await _collection(userId).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } on FirebaseException catch (e) {
      _rethrowMapped('Erro ao listar calibrações', e);
    }
  }

  Future<void> upsertProfile(
      String userId, Map<String, dynamic> profile) async {
    try {
      final id = (profile['id'] ?? '').toString();
      if (id.isEmpty) return;
      await _collection(userId).doc(id).set(profile, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      _rethrowMapped('Erro ao salvar calibração', e);
    }
  }

  Future<void> deleteProfile(String userId, String profileId) async {
    try {
      await _collection(userId).doc(profileId).delete();
    } on FirebaseException catch (e) {
      _rethrowMapped('Erro ao excluir calibração', e);
    }
  }

  Never _rethrowMapped(String operation, FirebaseException error) {
    if (error.code == 'permission-denied' ||
        error.code == 'missing-or-insufficient-permissions') {
      throw const PermissionDeniedException();
    }
    throw Exception('$operation: $error');
  }
}
