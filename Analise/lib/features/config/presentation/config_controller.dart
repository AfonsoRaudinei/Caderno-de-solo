import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  /// Exclui permanentemente a conta: Firebase Auth + dados Firestore + Hive local.
  Future<void> excluirConta() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // 1. Limpar Hive primeiro (não depende de rede)
    await limparDadosLocais();

    // 2. Deletar documento do usuário no Firestore
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    }

    // 3. Deletar conta no Firebase Auth (deve ser último)
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
}

final configControllerProvider =
    AsyncNotifierProvider<ConfigController, UserProfileData>(
  ConfigController.new,
);
