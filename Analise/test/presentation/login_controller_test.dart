import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloforte/data/repositories/auth_repository_impl.dart';
import 'package:soloforte/domain/repositories/auth_repository.dart';
import 'package:soloforte/features/auth/presentation/login/login_controller.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('LoginController', () {
    late ProviderContainer container;
    late MockAuthRepository authRepository;

    setUp(() {
      authRepository = MockAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('inicia em estado idle', () {
      final state = container.read(loginControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isFalse);
    });

    test('retorna erro para e-mail inválido propagado pelo repository', () async {
      when(() => authRepository.login(
            email: 'agronomo.com',
            password: '123456',
          )).thenThrow('E-mail inválido.');

      await container
          .read(loginControllerProvider.notifier)
          .login('agronomo.com', '123456');

      final state = container.read(loginControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, 'E-mail inválido.');
      verify(() => authRepository.login(
            email: 'agronomo.com',
            password: '123456',
          )).called(1);
    });

    test('retorna erro para senha curta propagado pelo repository', () async {
      when(() => authRepository.login(
            email: 'agronomo@gmail.com',
            password: '123',
          )).thenThrow('A senha deve ter pelo menos 6 caracteres.');

      await container
          .read(loginControllerProvider.notifier)
          .login('agronomo@gmail.com', '123');

      final state = container.read(loginControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, 'A senha deve ter pelo menos 6 caracteres.');
      verify(() => authRepository.login(
            email: 'agronomo@gmail.com',
            password: '123',
          )).called(1);
    });

    test('fluxo de sucesso no login', () async {
      when(() => authRepository.login(
            email: 'agronomo@gmail.com',
            password: 'senha_segura',
          )).thenAnswer((_) async {});

      await container
          .read(loginControllerProvider.notifier)
          .login('agronomo@gmail.com', 'senha_segura');

      final state = container.read(loginControllerProvider);
      expect(state.hasError, isFalse);
      expect(state.isLoading, isFalse);
      expect(state, isA<AsyncData<void>>());

      verify(() => authRepository.login(
            email: 'agronomo@gmail.com',
            password: 'senha_segura',
          )).called(1);
    });

    test('propaga erro de autenticação no login', () async {
      when(() => authRepository.login(
            email: 'agronomo@gmail.com',
            password: 'senha_segura',
          )).thenThrow('Senha incorreta fornecida.');

      await container
          .read(loginControllerProvider.notifier)
          .login('agronomo@gmail.com', 'senha_segura');

      final state = container.read(loginControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, 'Senha incorreta fornecida.');
    });

    test('exibe mensagem correta para network-request-failed', () async {
      when(() => authRepository.login(
            email: 'agronomo@gmail.com',
            password: 'senha_segura',
          )).thenThrow(
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
      );

      await container
          .read(loginControllerProvider.notifier)
          .login('agronomo@gmail.com', 'senha_segura');

      final state = container.read(loginControllerProvider);
      expect(state.hasError, isTrue);
      expect(
        state.error,
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
      );
    });

    test('exibe mensagem correta para user-disabled', () async {
      when(() => authRepository.login(
            email: 'desativado@gmail.com',
            password: 'senha_segura',
          )).thenThrow(
        'Esta conta foi desativada. Entre em contato com o suporte.',
      );

      await container
          .read(loginControllerProvider.notifier)
          .login('desativado@gmail.com', 'senha_segura');

      final state = container.read(loginControllerProvider);
      expect(state.hasError, isTrue);
      expect(
        state.error,
        'Esta conta foi desativada. Entre em contato com o suporte.',
      );
    });

    test('retorna mensagem amigável padrão quando erro não mapeado', () async {
      when(() => authRepository.login(
            email: 'agronomo@gmail.com',
            password: 'senha_segura',
          )).thenThrow(Exception('erro interno técnico'));

      await container
          .read(loginControllerProvider.notifier)
          .login('agronomo@gmail.com', 'senha_segura');

      final state = container.read(loginControllerProvider);
      expect(state.hasError, isTrue);
      expect(
        state.error,
        'Não foi possível entrar agora. Tente novamente em instantes.',
      );
    });

    test('logout com sucesso', () async {
      when(() => authRepository.logout()).thenAnswer((_) async {});

      await container.read(loginControllerProvider.notifier).logout();

      final state = container.read(loginControllerProvider);
      expect(state, isA<AsyncData<void>>());
      verify(() => authRepository.logout()).called(1);
    });

    test('logout com erro retorna mensagem padrão', () async {
      when(() => authRepository.logout()).thenThrow(Exception('falha'));

      await container.read(loginControllerProvider.notifier).logout();

      final state = container.read(loginControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, 'Erro ao sair da conta.');
    });
  });
}
