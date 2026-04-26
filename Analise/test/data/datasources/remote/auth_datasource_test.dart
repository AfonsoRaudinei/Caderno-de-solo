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
    expect(await storage.read(key: AuthDatasource.authUidStorageKey), 'uid-123');
    expect(
      await storage.read(key: AuthDatasource.legacyAuthTokenStorageKey),
      isNull,
    );
  });

  test('signIn converte wrong-password para mensagem amigável', () async {
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
      throwsA('Senha incorreta fornecida.'),
    );
  });

  test('user-not-found retorna mensagem amigável (sem auto-seed)', () async {
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
      throwsA('Nenhum usuário encontrado para este e-mail.'),
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
      throwsA('Sem conexão com a internet. Verifique sua rede e tente novamente.'),
    );
  });

  test('user-disabled retorna mensagem amigável', () async {
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
      throwsA('Esta conta foi desativada. Entre em contato com o suporte.'),
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

  test('signOut remove apenas chaves de auth e preserva dados não-auth', () async {
    await storage.write(key: AuthDatasource.authUidStorageKey, value: 'uid-123');
    await storage.write(key: AuthDatasource.legacyAuthTokenStorageKey, value: 'legacy-uid-123');
    await storage.write(key: 'feature_flag_cache', value: 'enabled');
    when(() => auth.signOut()).thenAnswer((_) async {});

    await datasource.signOut();

    expect(await storage.read(key: AuthDatasource.authUidStorageKey), isNull);
    expect(await storage.read(key: AuthDatasource.legacyAuthTokenStorageKey), isNull);
    expect(await storage.read(key: 'feature_flag_cache'), 'enabled');
  });
}
