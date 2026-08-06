import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/config/app_config.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/data/datasources/remote/auth_datasource.dart';
import 'package:soloforte/features/auth/presentation/login/login_page.dart';

import 'package:soloforte/features/auth/presentation/cadastro/cadastro_page.dart';

import 'package:soloforte/features/auth/presentation/recuperar_senha/recuperar_senha_page.dart';

import 'package:soloforte/features/main/presentation/main_page.dart';
import 'package:soloforte/features/clientes/presentation/cliente_detail_tab.dart';
import 'package:soloforte/features/clientes/presentation/cliente_detail_screen.dart';
import 'package:soloforte/features/clientes/presentation/cliente_form_screen.dart';
import 'package:soloforte/features/clientes/presentation/fazenda_form_screen.dart';
import 'package:soloforte/features/clientes/presentation/talhao_form_screen.dart';
import 'package:soloforte/features/clientes/presentation/clientes_page.dart';
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
import 'package:soloforte/features/config/presentation/calculos/calculos_page.dart';
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

@visibleForTesting
String? resolveRouterRedirect({
  required bool isBootstrapping,
  required String path,
  required User? currentUser,
}) {
  if (isBootstrapping) {
    return path == AppRoutes.authBootstrap ? null : AppRoutes.authBootstrap;
  }

  if (path == AppRoutes.authBootstrap) {
    if (currentUser == null) {
      return AppRoutes.login;
    }
    return currentUser.emailVerified
        ? AppRoutes.analise
        : AppRoutes.verificarEmail;
  }

  return resolveAppRedirect(
    path: path,
    currentUser: currentUser,
  );
}

@visibleForTesting
String? resolveRouterRedirectWithLog({
  required bool isBootstrapping,
  required String path,
  required User? currentUser,
}) {
  final target = resolveRouterRedirect(
    isBootstrapping: isBootstrapping,
    path: path,
    currentUser: currentUser,
  );

  _authRouterLog(
    'redirect path=$path bootstrap=$isBootstrapping ${_authUserTag(currentUser)} -> ${target ?? 'stay'}',
  );

  return target;
}

@visibleForTesting
String? resolveCalculosRedirect({
  required bool requiresCalculosAccessPassword,
  required Object? navigationExtra,
}) {
  if (!requiresCalculosAccessPassword) {
    return null;
  }
  if (navigationExtra != true) {
    return AppRoutes.config;
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
      final target = resolveRouterRedirectWithLog(
        isBootstrapping: authRefresh.isBootstrapping,
        path: path,
        currentUser: currentUser,
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
                path: AppRoutes.clientes,
                builder: (context, state) => const ClientesPage(),
                routes: [
                  GoRoute(
                    path: 'novo',
                    builder: (context, state) => const ClienteFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final clienteId = state.pathParameters['id']!;
                      return ClienteDetailScreen(
                        key: ValueKey('cliente-detail-$clienteId'),
                        clienteId: clienteId,
                        initialTab: ClienteDetailTab.fromQuery(
                          state.uri.queryParameters[AppRoutes.clienteTabQuery],
                        ),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'editar',
                        builder: (context, state) => ClienteFormScreen(
                          clienteId: state.pathParameters['id'],
                        ),
                      ),
                      GoRoute(
                        path: 'analises',
                        builder: (context, state) {
                          final clienteId = state.pathParameters['id']!;
                          return ClienteDetailScreen(
                            key: ValueKey('cliente-detail-$clienteId-analises'),
                            clienteId: clienteId,
                            initialTab: ClienteDetailTab.analises,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'fazenda/nova',
                        builder: (context, state) => FazendaFormScreen(
                          clienteId: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'fazenda/:fazendaId/editar',
                        builder: (context, state) => FazendaFormScreen(
                          clienteId: state.pathParameters['id']!,
                          fazendaId: state.pathParameters['fazendaId'],
                        ),
                      ),
                      GoRoute(
                        path: 'fazenda/:fazendaId/talhao/novo',
                        builder: (context, state) => TalhaoFormScreen(
                          clienteId: state.pathParameters['id']!,
                          fazendaId: state.pathParameters['fazendaId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'fazenda/:fazendaId/talhao/:talhaoId/editar',
                        builder: (context, state) => TalhaoFormScreen(
                          clienteId: state.pathParameters['id']!,
                          fazendaId: state.pathParameters['fazendaId']!,
                          talhaoId: state.pathParameters['talhaoId'],
                        ),
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
                  selectionMode:
                      state.uri.queryParameters['selectionMode'] == 'true',
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
                    path: 'calculos',
                    redirect: (context, state) => resolveCalculosRedirect(
                      requiresCalculosAccessPassword:
                          AppConfig.requiresCalculosAccessPassword,
                      navigationExtra: state.extra,
                    ),
                    builder: (context, state) => const CalculosPage(),
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
      backgroundColor: AppColors.bgSecondary,
      body: Center(
        child: AppSurface(
          borderRadius: AppDimens.radiusXl,
          child: SizedBox(
            width: 88,
            height: 88,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ),
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
      await ref.read(authDatasourceProvider).signOut();
      if (context.mounted) context.go(AppRoutes.login);
    }

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AppSurface(
                borderRadius: AppDimens.radius2xl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppIconFrame(
                      icon: Icons.mark_email_unread_rounded,
                      size: 72,
                      iconSize: 38,
                    ),
                    const SizedBox(height: AppDimens.lg),
                    Text(
                      'Verifique seu e-mail',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline,
                    ),
                    const SizedBox(height: AppDimens.sm),
                    Text(
                      'Enviamos um link para $email. Confirme o endereço antes de acessar o app.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecond,
                      ),
                    ),
                    const SizedBox(height: AppDimens.xl),
                    AppButton(
                      label: 'Já verifiquei',
                      icon: Icons.verified_rounded,
                      onPressed: checkVerification,
                    ),
                    const SizedBox(height: AppDimens.sm),
                    AppButtonSecondary(
                      label: 'Reenviar e-mail',
                      icon: Icons.refresh_rounded,
                      onPressed: resendEmail,
                    ),
                    const SizedBox(height: AppDimens.sm),
                    TextButton.icon(
                      onPressed: signOut,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sair'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
