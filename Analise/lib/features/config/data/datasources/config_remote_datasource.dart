import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ConfigRemoteDatasource {
  ConfigRemoteDatasource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final ImagePicker _picker;

  User? get currentUser => _auth.currentUser;

  DocumentReference<Map<String, dynamic>> userRef(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Future<Map<String, dynamic>?> getUserDocument(String uid) async {
    final doc = await userRef(uid).get();
    return doc.data();
  }

  Future<void> updateUserFields(String uid, Map<String, dynamic> data) async {
    await userRef(uid).set(
      {...data, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  Future<void> reauthenticateCurrentUser({required String password}) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.trim().isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-authenticated',
        message: 'Usuário não autenticado.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<XFile?> pickImage({
    required int imageQuality,
    required double maxWidth,
  }) async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
      );
    } on PlatformException {
      throw Exception('Permita acesso à galeria para selecionar a imagem.');
    }
  }

  Future<String> uploadImage(XFile file, String path) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Arquivo de imagem vazio.');
      }

      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(
          contentType: _contentType(file),
          cacheControl: 'no-cache',
        ),
      );
      return uploadTask.ref.getDownloadURL();
    } catch (error) {
      _throwFriendlyError(error);
    }
  }

  Future<void> deleteStoragePath(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') {
        _throwFriendlyError(error);
      }
    }
  }

  Future<void> deleteCloudDataForUser(String uid) async {
    final userRef = this.userRef(uid);

    await _deleteStorageDirectory(_storage.ref('users/$uid'));
    await _deleteCollection(userRef.collection('calibracoes'));
    await _deleteCollection(userRef.collection('laudos'));
    await _deleteQuery(
      _firestore.collection('analises').where('userId', isEqualTo: uid),
    );
    await _deleteQuery(
      _firestore.collection('recomendacoes').where('userId', isEqualTo: uid),
    );
    await _deleteQuery(
      _firestore
          .collection('analise_save_batches')
          .where('userId', isEqualTo: uid),
    );
    await userRef.delete();
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    await _deleteQuery(collection.limit(400));
  }

  Future<void> _deleteQuery(Query<Map<String, dynamic>> query) async {
    while (true) {
      final snapshot = await query.limit(400).get();
      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> _deleteStorageDirectory(Reference ref) async {
    try {
      final result = await ref.listAll();
      for (final item in result.items) {
        await item.delete();
      }
      for (final prefix in result.prefixes) {
        await _deleteStorageDirectory(prefix);
      }
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }

  String _contentType(XFile file) {
    final mimeType = file.mimeType?.trim().toLowerCase();
    if (mimeType != null && mimeType.startsWith('image/')) return mimeType;

    final path = file.path.toLowerCase();
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.webp')) return 'image/webp';
    if (path.endsWith('.heic')) return 'image/heic';
    if (path.endsWith('.heif')) return 'image/heif';
    return 'image/jpeg';
  }

  Never _throwFriendlyError(Object error) {
    if (error is FirebaseException) {
      if (error.code == 'unauthorized') {
        throw Exception(
            'Sem permissão para enviar imagem. Verifique as regras do Storage.');
      }
      throw Exception('Falha no upload (${error.code}). Tente novamente.');
    }
    if (error is PlatformException) {
      throw Exception(
          'Não foi possível acessar a galeria. Verifique as permissões do app.');
    }
    throw Exception('Falha ao enviar imagem. Tente novamente.');
  }
}
