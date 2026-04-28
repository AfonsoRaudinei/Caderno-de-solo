import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloforte/data/datasources/remote/auth_datasource.dart';
import 'package:soloforte/features/auth/presentation/cadastro/cadastro_controller.dart';

class MockAuthDatasource extends Mock implements AuthDatasource {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late FakeFirebaseFirestore firestore;
  late MockAuthDatasource authDatasource;
  late MockUserCredential credential;
  late MockUser user;
  late ProviderContainer container;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    authDatasource = MockAuthDatasource();
    credential = MockUserCredential();
    user = MockUser();

    when(() => user.uid).thenReturn('uid-123');
    when(() => user.updateDisplayName(any())).thenAnswer((_) async {});
    when(() => user.sendEmailVerification()).thenAnswer((_) async {});
    when(() => credential.user).thenReturn(user);
    when(
      () => authDatasource.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => credential);

    container = ProviderContainer(
      overrides: [
        authDatasourceProvider.overrideWithValue(authDatasource),
        cadastroFirestoreProvider.overrideWithValue(firestore),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('registrar cria perfil completo em users/{uid}', () async {
    await container.read(cadastroControllerProvider.notifier).registrar(
          nome: '  Maria Silva  ',
          tipoPerfil: ' Agrônomo ',
          estado: ' TO ',
          cidade: '  Porto Nacional  ',
          email: ' maria@solo.com ',
          senha: 'senha_segura',
        );

    verify(
      () => authDatasource.createUserWithEmailAndPassword(
        email: 'maria@solo.com',
        password: 'senha_segura',
      ),
    ).called(1);
    verify(() => user.updateDisplayName('Maria Silva')).called(1);
    verify(() => user.sendEmailVerification()).called(1);

    final doc = await firestore.collection('users').doc('uid-123').get();
    expect(doc.exists, isTrue);
    expect(doc.data(), containsPair('nome', 'Maria Silva'));
    expect(doc.data(), containsPair('email', 'maria@solo.com'));
    expect(doc.data(), containsPair('tipoPerfil', 'Agrônomo'));
    expect(doc.data(), containsPair('estado', 'TO'));
    expect(doc.data(), containsPair('cidade', 'Porto Nacional'));
    expect(doc.data()?['createdAt'], isNotNull);
    expect(doc.data()?['updatedAt'], isNotNull);
    expect(container.read(cadastroControllerProvider), isA<AsyncData<void>>());
  });
}
