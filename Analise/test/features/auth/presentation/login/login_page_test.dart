import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/data/repositories/auth_repository_impl.dart';
import 'package:soloforte/domain/repositories/auth_repository.dart';
import 'package:soloforte/features/auth/presentation/login/login_page.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;
  late GoRouter router;

  setUp(() {
    authRepository = MockAuthRepository();
    router = GoRouter(
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, __) => const Scaffold(body: Text('AREA_AUTENTICADA')),
        ),
        GoRoute(
          path: AppRoutes.analise,
          builder: (_, __) => const Scaffold(body: Text('AREA_AUTENTICADA')),
        ),
      ],
      initialLocation: AppRoutes.login,
    );
  });

  Future<void> pumpLoginPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('login válido navega para área autenticada', (tester) async {
    when(() => authRepository.login(
          email: 'agronomo@gmail.com',
          password: 'senha_segura',
        )).thenAnswer((_) async {});

    await pumpLoginPage(tester);

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(2));

    await tester.enterText(fields.at(0), 'agronomo@gmail.com');
    await tester.enterText(fields.at(1), 'senha_segura');
    await tester.ensureVisible(find.text('Entrar'));
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('AREA_AUTENTICADA'), findsOneWidget);
    verify(() => authRepository.login(
          email: 'agronomo@gmail.com',
          password: 'senha_segura',
        )).called(1);
  });
}
