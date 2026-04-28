import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloforte/data/datasources/remote/auth_datasource.dart';
import 'package:soloforte/data/repositories/auth_repository_impl.dart';

class MockAuthDatasource extends Mock implements AuthDatasource {}

void main() {
  late MockAuthDatasource datasource;
  late AuthRepositoryImpl repository;

  setUp(() {
    datasource = MockAuthDatasource();
    repository = AuthRepositoryImpl(datasource: datasource);
  });

  test('login valida e-mail e não chama datasource quando inválido', () async {
    await expectLater(
      () => repository.login(email: 'agronomo.com', password: '123456'),
      throwsA('E-mail inválido.'),
    );

    verifyNever(() => datasource.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ));
  });

  test('login valida senha e não chama datasource quando inválida', () async {
    await expectLater(
      () => repository.login(email: 'agronomo@gmail.com', password: '123'),
      throwsA('A senha deve ter pelo menos 6 caracteres.'),
    );

    verifyNever(() => datasource.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ));
  });

  test('login propaga mensagem amigável do datasource', () async {
    when(() => datasource.signInWithEmailAndPassword(
          email: 'agronomo@gmail.com',
          password: 'senha_segura',
        )).thenThrow(AuthDatasource.genericSignInMessage);

    await expectLater(
      () => repository.login(
        email: 'agronomo@gmail.com',
        password: 'senha_segura',
      ),
      throwsA(AuthDatasource.genericSignInMessage),
    );
  });

  test('login normaliza erro técnico para fallback amigável', () async {
    when(() => datasource.signInWithEmailAndPassword(
          email: 'agronomo@gmail.com',
          password: 'senha_segura',
        )).thenThrow(Exception('erro interno'));

    await expectLater(
      () => repository.login(
        email: 'agronomo@gmail.com',
        password: 'senha_segura',
      ),
      throwsA('Não foi possível entrar agora. Tente novamente em instantes.'),
    );
  });

  test('logout delega ao datasource', () async {
    when(() => datasource.signOut()).thenAnswer((_) async {});

    await repository.logout();

    verify(() => datasource.signOut()).called(1);
  });
}
