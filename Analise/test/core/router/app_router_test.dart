import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/router/app_router.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

Set<String> _collectPaths(Iterable<RouteBase> routes) {
  final paths = <String>{};

  void walk(RouteBase route) {
    if (route is GoRoute) {
      paths.add(route.path);
      for (final child in route.routes) {
        walk(child);
      }
      return;
    }

    if (route is StatefulShellRoute) {
      for (final branch in route.branches) {
        for (final child in branch.routes) {
          walk(child);
        }
      }
    }
  }

  for (final route in routes) {
    walk(route);
  }
  return paths;
}

void main() {
  late MockFirebaseAuth auth;
  late MockUser user;

  setUp(() {
    auth = MockFirebaseAuth();
    user = MockUser();
    when(() => user.uid).thenReturn('test-user-id');
    when(() => user.emailVerified).thenReturn(true);
    when(() => auth.authStateChanges())
        .thenAnswer((_) => const Stream<User?>.empty());
  });

  test('redirect para login quando não autenticado em rota protegida', () {
    final redirect = resolveAppRedirect(
      path: AppRoutes.analise,
      currentUser: null,
    );

    expect(redirect, AppRoutes.login);
  });

  test('permite rota de autenticação sem sessão no Firebase', () {
    final redirect = resolveAppRedirect(
      path: AppRoutes.cadastro,
      currentUser: null,
    );

    expect(redirect, isNull);
  });

  test('redireciona rota auth para análise quando sessão ativa', () {
    final redirect = resolveAppRedirect(
      path: AppRoutes.login,
      currentUser: user,
    );

    expect(redirect, AppRoutes.analise);
  });

  test('redireciona usuário sem e-mail verificado para verificação', () {
    when(() => user.emailVerified).thenReturn(false);

    final redirect = resolveAppRedirect(
      path: AppRoutes.analise,
      currentUser: user,
    );

    expect(redirect, AppRoutes.verificarEmail);
  });

  test('permite rota de verificação para usuário não verificado', () {
    when(() => user.emailVerified).thenReturn(false);

    final redirect = resolveAppRedirect(
      path: AppRoutes.verificarEmail,
      currentUser: user,
    );

    expect(redirect, isNull);
  });

  test('usuário verificado não acessa rota de verificação', () {
    final redirect = resolveAppRedirect(
      path: AppRoutes.verificarEmail,
      currentUser: user,
    );

    expect(redirect, AppRoutes.analise);
  });

  test('guard não entra em loop na rota /login sem autenticação', () {
    final redirect = resolveAppRedirect(
      path: AppRoutes.login,
      currentUser: null,
    );

    expect(redirect, isNull);
  });

  test('redireciona raiz para análise quando autenticado', () {
    final redirect = resolveAppRedirect(
      path: AppRoutes.home,
      currentUser: user,
    );

    expect(redirect, AppRoutes.analise);
  });

  test('redireciona raiz para login quando não autenticado', () {
    final redirect = resolveAppRedirect(
      path: AppRoutes.home,
      currentUser: null,
    );

    expect(redirect, AppRoutes.login);
  });

  test('não redireciona rota protegida quando sessão ativa', () {
    final redirect = resolveAppRedirect(
      path: AppRoutes.historico,
      currentUser: user,
    );

    expect(redirect, isNull);
  });

  test('sessão expirada no Firebase bloqueia rota protegida', () {
    final redirect = resolveAppRedirect(
      path: AppRoutes.config,
      currentUser: null,
    );

    expect(redirect, AppRoutes.login);
  });

  test('router provider registra rotas críticas do sistema', () {
    when(() => auth.currentUser).thenReturn(null);

    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(auth),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(routerProvider);
    addTearDown(router.dispose);

    final paths = _collectPaths(router.configuration.routes);

    expect(
      paths,
      containsAll(<String>{
        AppRoutes.login,
        AppRoutes.cadastro,
        AppRoutes.recuperarSenha,
        AppRoutes.verificarEmail,
        AppRoutes.authBootstrap,
        AppRoutes.culturas,
        AppRoutes.historico,
        AppRoutes.baseDadosLegacyAlias,
        AppRoutes.baseDados,
        AppRoutes.baseDadosForm,
        AppRoutes.baseDadosDetalhe,
        AppRoutes.tabelaMetricas,
        AppRoutes.analise,
        'nova',
        'detalhe/:id',
        'editar',
        AppRoutes.lab,
        'historico',
        AppRoutes.config,
        'feedback',
      }),
    );
  });

  test('auth refresh notifier encerra bootstrapping ao receber evento',
      () async {
    final controller = StreamController<User?>();
    final notifier = GoRouterAuthRefreshNotifier(
      controller.stream,
      initialUser: null,
    );
    addTearDown(() async {
      await controller.close();
      notifier.dispose();
    });

    var notifications = 0;
    notifier.addListener(() {
      notifications++;
    });

    expect(notifier.isBootstrapping, isTrue);

    controller.add(user);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(notifier.isBootstrapping, isFalse);
    expect(notifications, greaterThanOrEqualTo(1));
  });
}
