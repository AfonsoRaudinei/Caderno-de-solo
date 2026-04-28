import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soloforte/features/laboratorio/data/models/laudo_recomendacao_model.dart';

/// Datasource remoto — sincroniza laudos com o Firestore.
///
/// Path: users/{uid}/laudos/{laudoId}
/// Isolamento total por usuário: um laudo só é visível para quem o criou.
class LaudoFirestoreDatasource {
  LaudoFirestoreDatasource([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('laudos');

  Future<List<LaudoRecomendacaoModel>> getLaudos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    try {
      final snap = await _collection(uid).get();
      return snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['userId'] = uid;
        return LaudoRecomendacaoModel.fromJson(data);
      }).toList();
    } catch (_) {
      return []; // falha remota tolerada — offline-first
    }
  }

  Future<void> saveLaudo(LaudoRecomendacaoModel laudo) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final data = laudo.toJson();
      data['userId'] = uid;
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _collection(uid).doc(laudo.id).set(data, SetOptions(merge: true));
    } catch (_) {
      // Falha remota é tolerada; dado já foi salvo localmente pelo Hive.
    }
  }

  Future<void> deleteLaudo(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _collection(uid).doc(id).delete();
    } catch (_) {}
  }
}
