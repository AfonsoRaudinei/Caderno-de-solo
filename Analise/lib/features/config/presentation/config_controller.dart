import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:soloforte/data/datasources/remote/auth_datasource.dart';

class UserProfileData {
  final String nome;
  final String email;
  final String tipoPerfil;
  final String empresa;

  const UserProfileData({
    required this.nome,
    required this.email,
    required this.tipoPerfil,
    required this.empresa,
  });
}

class ConfigController extends AsyncNotifier<UserProfileData> {
  @override
  Future<UserProfileData> build() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const UserProfileData(
        nome: '—',
        email: '—',
        tipoPerfil: '—',
        empresa: '—',
      );
    }

    final nome = _fallback(user.displayName);
    final email = _fallback(user.email);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();

      final tipoPerfil = _fallback(data?['tipoPerfil'] as String?);
      final empresa = _fallback(data?['empresa'] as String?);

      return UserProfileData(
        nome: nome,
        email: email,
        tipoPerfil: tipoPerfil,
        empresa: empresa,
      );
    } catch (_) {
      return UserProfileData(
        nome: nome,
        email: email,
        tipoPerfil: '—',
        empresa: '—',
      );
    }
  }

  Future<void> logout() async {
    final authDatasource = ref.read(authDatasourceProvider);
    await authDatasource.signOut();
  }

  /// Atualiza um campo do perfil no Firestore.
  Future<void> updateProfileField(String field, String value) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {field: value.trim(), 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
    ref.invalidateSelf(); // seguro aqui — não está no path de salvar análises
  }

  /// Exclui permanentemente a conta.
  ///
  /// A reautenticação acontece antes de qualquer remoção para evitar apagar
  /// dados quando o Firebase Auth ainda exigiria login recente.
  Future<void> excluirConta({required String password}) async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
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

    await _deleteCloudDataForUser(user.uid);
    await limparDadosLocais();
    await ref.read(authDatasourceProvider).deleteAccount();
  }

  /// Limpa todos os dados locais Hive (não afeta Firebase).
  Future<void> limparDadosLocais() async {
    final boxNames = [
      'demo_mode_box',
      'tabela_metricas_box',
      'laudo_recomendacao_box',
      'calibracao_profiles_box',
    ];
    for (final name in boxNames) {
      final box = await Hive.openBox(name);
      await box.clear();
    }
  }

  String _fallback(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return '—';
    return trimmed;
  }

  Future<void> _deleteCloudDataForUser(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection('users').doc(uid);

    await _deleteStorageDirectory(FirebaseStorage.instance.ref('users/$uid'));
    await _deleteCollection(
      userRef.collection('calibracoes'),
      firestore: firestore,
    );
    await _deleteCollection(
      userRef.collection('laudos'),
      firestore: firestore,
    );
    await _deleteQuery(
      firestore.collection('analises').where('userId', isEqualTo: uid),
      firestore: firestore,
    );
    await _deleteQuery(
      firestore.collection('recomendacoes').where('userId', isEqualTo: uid),
      firestore: firestore,
    );
    await _deleteQuery(
      firestore
          .collection('analise_save_batches')
          .where('userId', isEqualTo: uid),
      firestore: firestore,
    );
    await userRef.delete();
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection, {
    required FirebaseFirestore firestore,
  }) async {
    await _deleteQuery(collection.limit(400), firestore: firestore);
  }

  Future<void> _deleteQuery(
    Query<Map<String, dynamic>> query, {
    required FirebaseFirestore firestore,
  }) async {
    while (true) {
      final snapshot = await query.limit(400).get();
      if (snapshot.docs.isEmpty) return;

      final batch = firestore.batch();
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
}

final configControllerProvider =
    AsyncNotifierProvider<ConfigController, UserProfileData>(
  ConfigController.new,
);
