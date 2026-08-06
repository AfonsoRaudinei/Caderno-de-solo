import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloforte/data/datasources/remote/auth_datasource.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  const storage = FlutterSecureStorage();

  late MockFirebaseAuth auth;
  late AuthDatasource datasource;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    auth = MockFirebaseAuth();
    datasource = AuthDatasource(auth);
  });

  test('signIn salva auth_uid quando autentica com usuário válido', () async {
    final credential = MockUserCredential();
    final user = MockUser();

    when(() => user.uid).thenReturn('uid-123');
    when(() => credential.user).thenReturn(user);
    when(() => auth.signInWithEmailAndPassword(
          email: 'user@solo.com',
          password: '123456',
        )).thenAnswer((_) async => credential);

    final result = await datasource.signInWithEmailAndPassword(
      email: 'user@solo.com',
      password: '123456',
    );

    expect(result, same(credential));
    expect(
        await storage.read(key: AuthDatasource.authUidStorageKey), 'uid-123');
    expect(
      await storage.read(key: AuthDatasource.legacyAuthTokenStorageKey),
      isNull,
    );
  });

  test('signIn converte wrong-password para mensagem genérica', () async {
    when(() => auth.signInWithEmailAndPassword(
          email: 'user@solo.com',
          password: '123456',
        )).thenThrow(
      FirebaseAuthException(code: 'wrong-password'),
    );

    await expectLater(
      () => datasource.signInWithEmailAndPassword(
        email: 'user@solo.com',
        password: '123456',
      ),
      throwsA(AuthDatasource.genericSignInMessage),
    );
  });

  test('user-not-found retorna mesma mensagem genérica do login', () async {
    when(() => auth.signInWithEmailAndPassword(
          email: 'inexistente@solo.com',
          password: '123456',
        )).thenThrow(
      FirebaseAuthException(code: 'user-not-found'),
    );

    await expectLater(
      () => datasource.signInWithEmailAndPassword(
        email: 'inexistente@solo.com',
        password: '123456',
      ),
      throwsA(AuthDatasource.genericSignInMessage),
    );
  });

  test('network-request-failed retorna mensagem de sem internet', () async {
    when(() => auth.signInWithEmailAndPassword(
          email: 'user@solo.com',
          password: '123456',
        )).thenThrow(
      FirebaseAuthException(code: 'network-request-failed'),
    );

    await expectLater(
      () => datasource.signInWithEmailAndPassword(
        email: 'user@solo.com',
        password: '123456',
      ),
      throwsA(
          'Sem conexão com a internet. Verifique sua rede e tente novamente.'),
    );
  });

  test('user-disabled retorna mensagem genérica para evitar enumeração',
      () async {
    when(() => auth.signInWithEmailAndPassword(
          email: 'desativado@solo.com',
          password: '123456',
        )).thenThrow(
      FirebaseAuthException(code: 'user-disabled'),
    );

    await expectLater(
      () => datasource.signInWithEmailAndPassword(
        email: 'desativado@solo.com',
        password: '123456',
      ),
      throwsA(AuthDatasource.genericSignInMessage),
    );
  });

  test('createUser converte email-already-in-use para mensagem genérica',
      () async {
    when(() => auth.createUserWithEmailAndPassword(
          email: 'existente@solo.com',
          password: '123456',
        )).thenThrow(
      FirebaseAuthException(code: 'email-already-in-use'),
    );

    await expectLater(
      () => datasource.createUserWithEmailAndPassword(
        email: 'existente@solo.com',
        password: '123456',
      ),
      throwsA(AuthDatasource.genericCreateAccountMessage),
    );
  });

  test('createUser converte invalid-email para mensagem amigável', () async {
    when(() => auth.createUserWithEmailAndPassword(
          email: 'invalido',
          password: '123456',
        )).thenThrow(
      FirebaseAuthException(code: 'invalid-email'),
    );

    await expectLater(
      () => datasource.createUserWithEmailAndPassword(
        email: 'invalido',
        password: '123456',
      ),
      throwsA('O formato do e-mail é inválido.'),
    );
  });

  test('sendPasswordResetEmail converte erro para mensagem amigável', () async {
    when(() => auth.sendPasswordResetEmail(email: 'invalido')).thenThrow(
      FirebaseAuthException(code: 'invalid-email'),
    );

    await expectLater(
      () => datasource.sendPasswordResetEmail(email: 'invalido'),
      throwsA('O formato do e-mail é inválido.'),
    );
  });

  test('sendPasswordResetEmail não revela user-not-found', () async {
    when(() => auth.sendPasswordResetEmail(email: 'inexistente@solo.com'))
        .thenThrow(
      FirebaseAuthException(code: 'user-not-found'),
    );

    await expectLater(
      datasource.sendPasswordResetEmail(email: 'inexistente@solo.com'),
      completes,
    );
  });

  test('signOut remove apenas chaves de auth e preserva dados não-auth',
      () async {
    await storage.write(
        key: AuthDatasource.authUidStorageKey, value: 'uid-123');
    await storage.write(
        key: AuthDatasource.legacyAuthTokenStorageKey, value: 'legacy-uid-123');
    await storage.write(key: 'feature_flag_cache', value: 'enabled');
    when(() => auth.signOut()).thenAnswer((_) async {});

    await datasource.signOut();

    expect(await storage.read(key: AuthDatasource.authUidStorageKey), isNull);
    expect(await storage.read(key: AuthDatasource.legacyAuthTokenStorageKey),
        isNull);
    expect(await storage.read(key: 'feature_flag_cache'), 'enabled');
  });

  test('currentUserId retorna uid da sessão ativa', () {
    final activeUser = MockUser();
    when(() => activeUser.uid).thenReturn('uid-ativo');
    when(() => auth.currentUser).thenReturn(activeUser);

    expect(datasource.currentUserId(), 'uid-ativo');
  });

  test('waitForCurrentUserId retorna uid imediato quando sessão existe',
      () async {
    final activeUser = MockUser();
    when(() => activeUser.uid).thenReturn('uid-imediato');
    when(() => auth.currentUser).thenReturn(activeUser);

    final uid = await datasource.waitForCurrentUserId();
    expect(uid, 'uid-imediato');
  });

  test('waitForCurrentUserId aguarda authStateChanges', () async {
    final controller = StreamController<User?>();
    when(() => auth.currentUser).thenReturn(null);
    when(() => auth.authStateChanges()).thenAnswer((_) => controller.stream);

    final future = datasource.waitForCurrentUserId();
    final activeUser = MockUser();
    when(() => activeUser.uid).thenReturn('uid-stream');
    controller.add(activeUser);

    expect(await future, 'uid-stream');
    await controller.close();
  });

  test('createUser com sucesso delega ao FirebaseAuth', () async {
    final credential = MockUserCredential();
    when(() => auth.createUserWithEmailAndPassword(
          email: 'novo@solo.com',
          password: '123456',
        )).thenAnswer((_) async => credential);

    final result = await datasource.createUserWithEmailAndPassword(
      email: 'novo@solo.com',
      password: '123456',
    );

    expect(result, same(credential));
  });

  test('createUser converte weak-password para mensagem amigável', () async {
    when(() => auth.createUserWithEmailAndPassword(
          email: 'novo@solo.com',
          password: '123',
        )).thenThrow(
      FirebaseAuthException(code: 'weak-password'),
    );

    await expectLater(
      () => datasource.createUserWithEmailAndPassword(
        email: 'novo@solo.com',
        password: '123',
      ),
      throwsA('A senha fornecida é muito fraca.'),
    );
  });

  test('deleteAccount remove usuário e chaves de auth', () async {
    final activeUser = MockUser();
    when(() => activeUser.uid).thenReturn('uid-delete');
    when(() => auth.currentUser).thenReturn(activeUser);
    when(() => activeUser.delete()).thenAnswer((_) async {});
    await storage.write(
        key: AuthDatasource.authUidStorageKey, value: 'uid-delete');

    await datasource.deleteAccount();

    verify(() => activeUser.delete()).called(1);
    expect(await storage.read(key: AuthDatasource.authUidStorageKey), isNull);
  });

  test('deleteAccount falha quando não há usuário autenticado', () async {
    when(() => auth.currentUser).thenReturn(null);

    await expectLater(
      datasource.deleteAccount,
      throwsA(isA<Exception>()),
    );
  });
}
