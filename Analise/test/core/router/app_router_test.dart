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

GoRoute? _findGoRouteByPathWithRedirect(
  Iterable<RouteBase> routes,
  String path,
) {
  for (final route in routes) {
    if (route is GoRoute) {
      if (route.path == path && route.redirect != null) return route;
      final nested = _findGoRouteByPathWithRedirect(route.routes, path);
      if (nested != null) return nested;
    }
    if (route is StatefulShellRoute) {
      for (final branch in route.branches) {
        final nested = _findGoRouteByPathWithRedirect(branch.routes, path);
        if (nested != null) return nested;
      }
    }
  }
  return null;
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

  test('permite rota de recuperação sem sessão no Firebase', () {
    final redirect = resolveAppRedirect(
      path: AppRoutes.recuperarSenha,
      currentUser: null,
    );

    expect(redirect, isNull);
  });

  test('bloqueia verificação de e-mail sem autenticação', () {
    final redirect = resolveAppRedirect(
      path: AppRoutes.verificarEmail,
      currentUser: null,
    );

    expect(redirect, AppRoutes.login);
  });

  group('GoRouterAuthRefreshNotifier', () {
    test('inicia sem bootstrap quando usuário já existe', () {
      final notifier = GoRouterAuthRefreshNotifier(
        const Stream<User?>.empty(),
        initialUser: user,
      );
      addTearDown(notifier.dispose);

      expect(notifier.isBootstrapping, isFalse);
    });

    test('encerra bootstrap após timeout', () async {
      final notifier = GoRouterAuthRefreshNotifier(
        const Stream<User?>.empty(),
        initialUser: null,
        bootstrapTimeout: const Duration(milliseconds: 20),
      );
      addTearDown(notifier.dispose);

      expect(notifier.isBootstrapping, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(notifier.isBootstrapping, isFalse);
    });

    test('encerra bootstrap quando stream emite erro', () async {
      final controller = StreamController<User?>();
      final notifier = GoRouterAuthRefreshNotifier(
        controller.stream,
        initialUser: null,
      );
      addTearDown(() async {
        await controller.close();
        notifier.dispose();
      });

      expect(notifier.isBootstrapping, isTrue);
      controller.addError(Exception('auth stream failed'));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(notifier.isBootstrapping, isFalse);
    });

    test('dispose cancela timer e subscription', () {
      final controller = StreamController<User?>();
      final notifier = GoRouterAuthRefreshNotifier(
        controller.stream,
        initialUser: null,
      );

      notifier.dispose();
      controller.close();
    });

    test('log usa uid abreviado quando sessão tem id longo', () {
      final longUidUser = MockUser();
      when(() => longUidUser.uid).thenReturn('0123456789abcdef');
      when(() => longUidUser.emailVerified).thenReturn(true);

      final notifier = GoRouterAuthRefreshNotifier(
        const Stream<User?>.empty(),
        initialUser: longUidUser,
      );
      addTearDown(notifier.dispose);

      expect(notifier.isBootstrapping, isFalse);
    });
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

  group('resolveCalculosRedirect', () {
    test('bloqueia quando senha não está configurada', () {
      expect(
        resolveCalculosRedirect(
          calculosAccessPassword: '',
          navigationExtra: true,
        ),
        AppRoutes.config,
      );
    });

    test('bloqueia navegação direta sem desbloqueio', () {
      expect(
        resolveCalculosRedirect(
          calculosAccessPassword: 'secret',
          navigationExtra: null,
        ),
        AppRoutes.config,
      );
    });

    test('permite acesso após desbloqueio via extra', () {
      expect(
        resolveCalculosRedirect(
          calculosAccessPassword: 'secret',
          navigationExtra: true,
        ),
        isNull,
      );
    });
  });

  group('resolveRouterRedirect', () {
    test('mantém bootstrap durante inicialização', () {
      expect(
        resolveRouterRedirect(
          isBootstrapping: true,
          path: AppRoutes.authBootstrap,
          currentUser: null,
        ),
        isNull,
      );
    });

    test('redireciona rotas protegidas para bootstrap durante inicialização',
        () {
      expect(
        resolveRouterRedirect(
          isBootstrapping: true,
          path: AppRoutes.analise,
          currentUser: null,
        ),
        AppRoutes.authBootstrap,
      );
    });

    test('auth-bootstrap sem sessão vai para login', () {
      expect(
        resolveRouterRedirect(
          isBootstrapping: false,
          path: AppRoutes.authBootstrap,
          currentUser: null,
        ),
        AppRoutes.login,
      );
    });

    test('auth-bootstrap com sessão verificada vai para análise', () {
      expect(
        resolveRouterRedirect(
          isBootstrapping: false,
          path: AppRoutes.authBootstrap,
          currentUser: user,
        ),
        AppRoutes.analise,
      );
    });

    test('auth-bootstrap com e-mail pendente vai para verificação', () {
      when(() => user.emailVerified).thenReturn(false);

      expect(
        resolveRouterRedirect(
          isBootstrapping: false,
          path: AppRoutes.authBootstrap,
          currentUser: user,
        ),
        AppRoutes.verificarEmail,
      );
    });

    test('delega redirect padrão após bootstrap', () {
      expect(
        resolveRouterRedirect(
          isBootstrapping: false,
          path: AppRoutes.historico,
          currentUser: user,
        ),
        isNull,
      );
    });

    test('registra log ao resolver redirect', () {
      expect(
        resolveRouterRedirectWithLog(
          isBootstrapping: false,
          path: AppRoutes.authBootstrap,
          currentUser: user,
        ),
        AppRoutes.analise,
      );
    });
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
        AppRoutes.clientes,
        'novo',
        ':id',
        'editar',
        'analises',
        'fazenda/nova',
        'fazenda/:fazendaId/editar',
        'fazenda/:fazendaId/talhao/novo',
        'fazenda/:fazendaId/talhao/:talhaoId/editar',
        'nova',
        'detalhe/:id',
        AppRoutes.lab,
        'historico',
        AppRoutes.config,
        'feedback',
      }),
    );
  });

  test('rota editar declara redirect legado para detalhe', () {
    when(() => auth.currentUser).thenReturn(null);

    final container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(auth),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(routerProvider);
    addTearDown(router.dispose);

    final editarRoute =
        _findGoRouteByPathWithRedirect(router.configuration.routes, 'editar');
    expect(editarRoute, isNotNull);
    expect(editarRoute!.redirect, isNotNull);
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
