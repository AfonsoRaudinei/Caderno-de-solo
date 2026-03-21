import 'package:cloud_firestore/cloud_firestore.dart';

class CalibracaoFirestoreDatasource {
  CalibracaoFirestoreDatasource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('calibracoes');
  }

  Future<List<Map<String, dynamic>>> getProfiles(String userId) async {
    final snapshot = await _collection(userId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> upsertProfile(
      String userId, Map<String, dynamic> profile) async {
    final id = (profile['id'] ?? '').toString();
    if (id.isEmpty) return;
    await _collection(userId).doc(id).set(profile, SetOptions(merge: true));
  }

  Future<void> deleteProfile(String userId, String profileId) async {
    await _collection(userId).doc(profileId).delete();
  }
}
