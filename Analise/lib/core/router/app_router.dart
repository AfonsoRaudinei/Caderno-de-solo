import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/features/auth/presentation/login/login_page.dart';

import 'package:soloforte/features/auth/presentation/cadastro/cadastro_page.dart';

import 'package:soloforte/features/auth/presentation/recuperar_senha/recuperar_senha_page.dart';

import 'package:soloforte/features/main/presentation/main_page.dart';
import 'package:soloforte/features/analise/presentation/screens/analise_page.dart';
import 'package:soloforte/features/analise/presentation/screens/analise_detail_screen.dart';
import 'package:soloforte/features/laboratorio/presentation/lab_page.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_page.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_seletor_page.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/recomendacao_screen.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/lab_referencias_page.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/absorcao_nutrientes_referencia_page.dart';
import 'package:soloforte/features/historico/presentation/historico_page.dart';
import 'package:soloforte/features/historico/presentation/historico_detalhe_screen.dart';
import 'package:soloforte/features/mapa/presentation/mapa_page.dart';
import 'package:soloforte/features/config/presentation/config_page.dart';
import 'package:soloforte/features/config/presentation/screens/lab_templates_list_screen.dart';
import 'package:soloforte/features/config/presentation/screens/lab_template_edit_screen.dart';
import 'package:soloforte/domain/entities/lab_template.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';

import 'package:soloforte/features/config/presentation/feedback/feedback_page.dart';
import 'package:soloforte/features/config/presentation/base_dados/base_dados_page.dart';
import 'package:soloforte/features/config/presentation/base_dados/base_dados_form_page.dart';
import 'package:soloforte/features/config/presentation/base_dados/base_dados_detail_page.dart';
import 'package:soloforte/data/base_dados/referencias_tecnicas_data.dart';
import 'package:soloforte/features/config/presentation/tabela_metricas_page.dart';
import 'package:soloforte/features/culturas/screens/culturas_screen.dart';

@visibleForTesting
String? resolveAppRedirect({
  required String path,
  required User? currentUser,
}) {
  final isAuthenticated = currentUser != null;
  final hasVerifiedEmail = currentUser?.emailVerified == true;

  final isAuthRoute = path == AppRoutes.login ||
      path == AppRoutes.cadastro ||
      path == AppRoutes.recuperarSenha;

  if (!isAuthenticated && path == AppRoutes.verificarEmail) {
    return AppRoutes.login;
  }

  if (!isAuthenticated && !isAuthRoute) {
    return AppRoutes.login;
  }

  if (isAuthenticated && !hasVerifiedEmail) {
    return path == AppRoutes.verificarEmail ? null : AppRoutes.verificarEmail;
  }

  if (isAuthenticated && (isAuthRoute || path == AppRoutes.verificarEmail)) {
    return AppRoutes.analise;
  }

  if (path == AppRoutes.home) {
    return isAuthenticated && hasVerifiedEmail
        ? AppRoutes.analise
        : AppRoutes.login;
  }

  return null;
}

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

String _authUserTag(User? user) {
  if (user == null) return 'user=null';
  final uid = user.uid;
  final shortUid = uid.length <= 8 ? uid : uid.substring(0, 8);
  return 'user=$shortUid verified=${user.emailVerified}';
}

void _authRouterLog(String message) {
  debugPrint('[auth-router] $message');
}

class GoRouterAuthRefreshNotifier extends ChangeNotifier {
  GoRouterAuthRefreshNotifier(
    Stream<User?> stream, {
    required User? initialUser,
    this.bootstrapTimeout = const Duration(seconds: 5),
  }) {
    _authRouterLog(
      'notifier:init ${_authUserTag(initialUser)} timeout=${bootstrapTimeout.inSeconds}s',
    );

    if (initialUser != null) {
      _isBootstrapping = false;
    }

    _bootstrapFallback = Timer(bootstrapTimeout, () {
      if (_isBootstrapping) {
        _authRouterLog('bootstrap:timeout -> unlock');
        _isBootstrapping = false;
        notifyListeners();
      }
    });

    _subscription = stream.asBroadcastStream().listen(
      (user) {
        _authRouterLog('auth:event ${_authUserTag(user)}');
        if (_isBootstrapping) {
          _isBootstrapping = false;
        }
        _bootstrapFallback?.cancel();
        notifyListeners();
      },
      onError: (error, _) {
        _authRouterLog('auth:error $error');
        if (_isBootstrapping) {
          _isBootstrapping = false;
        }
        _bootstrapFallback?.cancel();
        notifyListeners();
      },
    );
  }

  bool _isBootstrapping = true;
  late final StreamSubscription<User?> _subscription;
  final Duration bootstrapTimeout;
  Timer? _bootstrapFallback;

  bool get isBootstrapping => _isBootstrapping;

  @override
  void dispose() {
    _bootstrapFallback?.cancel();
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final authRefresh = GoRouterAuthRefreshNotifier(
    auth.authStateChanges(),
    initialUser: auth.currentUser,
  );
  ref.onDispose(authRefresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.authBootstrap,
    debugLogDiagnostics: true,
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final path = state.uri.path;
      final currentUser = auth.currentUser;
      String? target;

      if (authRefresh.isBootstrapping) {
        if (path == AppRoutes.authBootstrap) {
          target = null;
        } else {
          target = AppRoutes.authBootstrap;
        }
      } else if (path == AppRoutes.authBootstrap) {
        if (currentUser == null) {
          target = AppRoutes.login;
        } else {
          target = currentUser.emailVerified
              ? AppRoutes.analise
              : AppRoutes.verificarEmail;
        }
      } else {
        target = resolveAppRedirect(
          path: path,
          currentUser: currentUser,
        );
      }

      _authRouterLog(
        'redirect path=$path bootstrap=${authRefresh.isBootstrapping} ${_authUserTag(currentUser)} -> ${target ?? 'stay'}',
      );

      return target;
    },
    routes: [
      GoRoute(
        path: AppRoutes.authBootstrap,
        builder: (context, state) => const _AuthBootstrapPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.cadastro,
        builder: (context, state) => const CadastroPage(),
      ),
      GoRoute(
        path: AppRoutes.recuperarSenha,
        builder: (context, state) => const RecuperarSenhaPage(),
      ),
      GoRoute(
        path: AppRoutes.verificarEmail,
        builder: (context, state) => const _EmailVerificationPage(),
      ),
      GoRoute(
        path: AppRoutes.culturas,
        builder: (context, state) => const CulturasScreen(),
      ),
      GoRoute(
        path: AppRoutes.historico,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: HistoricoPage(),
        ),
        routes: [
          GoRoute(
            path: 'detalhe',
            builder: (context, state) {
              final recomendacao = state.extra as RecomendacaoModel;
              return HistoricoDetalheScreen(recomendacao: recomendacao);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.baseDadosLegacyAlias,
        redirect: (_, __) => AppRoutes.labRefTecnicas,
      ),
      GoRoute(
        path: AppRoutes.baseDados,
        redirect: (_, __) => AppRoutes.labRefTecnicas,
      ),
      GoRoute(
        path: AppRoutes.baseDadosForm,
        redirect: (_, __) => AppRoutes.labRefNova,
      ),
      GoRoute(
        path: AppRoutes.baseDadosDetalhe,
        redirect: (_, __) => AppRoutes.labRefTecnicas,
      ),
      GoRoute(
        path: AppRoutes.tabelaMetricas,
        redirect: (_, __) => AppRoutes.labRefMetricas,
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.analise,
                builder: (context, state) => const AnalisePage(),
                routes: [
                  GoRoute(
                    path: 'nova',
                    redirect: (_, __) => AppRoutes.analise,
                  ),
                  GoRoute(
                    path: 'detalhe/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return AnaliseDetailScreen(analiseId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'editar',
                        redirect: (context, state) {
                          final id = state.pathParameters['id'] ?? '';
                          return '${AppRoutes.analise}/detalhe/$id';
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.lab,
                builder: (context, state) => const LabPage(),
                routes: [
                  GoRoute(
                    path: 'calibracao',
                    builder: (context, state) => const CalibracaoSeletorPage(),
                    routes: [
                      GoRoute(
                        path: 'editar',
                        builder: (context, state) => const CalibracaoPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'recomendacao',
                    builder: (context, state) {
                      final extra = state.extra;
                      final analiseId = extra is String ? extra : null;
                      return RecomendacaoScreen(analiseId: analiseId);
                    },
                  ),
                  GoRoute(
                    path: 'referencias',
                    builder: (context, state) => const LabReferenciasPage(),
                    routes: [
                      GoRoute(
                        path: 'tecnicas',
                        builder: (context, state) => const BaseDadosPage(),
                      ),
                      GoRoute(
                        path: 'detalhes',
                        builder: (context, state) {
                          final ref = state.extra is ReferenciaTecnica
                              ? state.extra as ReferenciaTecnica
                              : null;
                          if (ref == null) {
                            return const BaseDadosPage();
                          }
                          return BaseDadosDetailPage(referencia: ref);
                        },
                      ),
                      GoRoute(
                        path: 'nova',
                        builder: (context, state) => const BaseDadosFormPage(),
                      ),
                      GoRoute(
                        path: 'metricas',
                        builder: (context, state) => const TabelaMetricasPage(),
                      ),
                      GoRoute(
                        path: 'absorcao-nutrientes',
                        builder: (context, state) =>
                            const AbsorcaoNutrientesReferenciaPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'historico',
                    builder: (context, state) => const HistoricoPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.mapa,
                builder: (context, state) => MapaPage(
                  initialAnaliseId: state.uri.queryParameters['analiseId'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.config,
                builder: (context, state) => const ConfigPage(),
                routes: [
                  GoRoute(
                    path: 'feedback',
                    builder: (context, state) => const FeedbackPage(),
                  ),
                  GoRoute(
                    path: 'lab-templates',
                    builder: (context, state) => const LabTemplatesListScreen(),
                    routes: [
                      GoRoute(
                        path: 'editar',
                        builder: (context, state) => LabTemplateEditScreen(
                          template: state.extra is LabTemplate
                              ? state.extra as LabTemplate
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _AuthBootstrapPage extends StatelessWidget {
  const _AuthBootstrapPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _EmailVerificationPage extends ConsumerWidget {
  const _EmailVerificationPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthProvider);
    final user = auth.currentUser;
    final email = user?.email ?? 'seu e-mail';

    Future<void> resendEmail() async {
      try {
        await auth.currentUser?.sendEmailVerification();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail de verificação reenviado.'),
          ),
        );
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível reenviar agora. Tente novamente.'),
          ),
        );
      }
    }

    Future<void> checkVerification() async {
      try {
        await auth.currentUser?.reload();
        final refreshedUser = auth.currentUser;
        if (!context.mounted) return;
        if (refreshedUser?.emailVerified == true) {
          context.go(AppRoutes.analise);
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail ainda não verificado.'),
          ),
        );
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível atualizar a sessão.'),
          ),
        );
      }
    }

    Future<void> signOut() async {
      await auth.signOut();
      if (context.mounted) context.go(AppRoutes.login);
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.mark_email_unread_outlined, size: 56),
                  const SizedBox(height: 20),
                  Text(
                    'Verifique seu e-mail',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enviamos um link para $email. Confirme o endereço antes de acessar o app.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: checkVerification,
                    child: const Text('Já verifiquei'),
                  ),
                  TextButton(
                    onPressed: resendEmail,
                    child: const Text('Reenviar e-mail'),
                  ),
                  TextButton(
                    onPressed: signOut,
                    child: const Text('Sair'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
