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
import 'package:soloforte/features/analise/presentation/screens/analise_form_page.dart';
import 'package:soloforte/features/analise/presentation/screens/analise_detail_screen.dart';
import 'package:soloforte/features/analise/presentation/screens/nova_analise_screen.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart'
    as feature_analise;
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
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

  final isAuthRoute = path == AppRoutes.login ||
      path == AppRoutes.cadastro ||
      path == AppRoutes.recuperarSenha;

  if (!isAuthenticated && !isAuthRoute) {
    return AppRoutes.login;
  }

  if (isAuthenticated && isAuthRoute) {
    return AppRoutes.analise;
  }

  if (path == AppRoutes.home) {
    return isAuthenticated ? AppRoutes.analise : AppRoutes.login;
  }

  return null;
}

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

class GoRouterAuthRefreshNotifier extends ChangeNotifier {
  GoRouterAuthRefreshNotifier(Stream<User?> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      if (_isBootstrapping) {
        _isBootstrapping = false;
      }
      notifyListeners();
    });
  }

  bool _isBootstrapping = true;
  late final StreamSubscription<User?> _subscription;

  bool get isBootstrapping => _isBootstrapping;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final authRefresh = GoRouterAuthRefreshNotifier(auth.authStateChanges());
  ref.onDispose(authRefresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.authBootstrap,
    debugLogDiagnostics: true,
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final path = state.uri.path;

      if (authRefresh.isBootstrapping) {
        if (path == AppRoutes.authBootstrap) {
          return null;
        }
        return AppRoutes.authBootstrap;
      }

      if (path == AppRoutes.authBootstrap) {
        return auth.currentUser != null ? AppRoutes.analise : AppRoutes.login;
      }

      return resolveAppRedirect(
        path: path,
        currentUser: auth.currentUser,
      );
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
                    builder: (context, state) => const AnaliseFormPage(),
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
                        builder: (context, state) {
                          final id = state.pathParameters['id'] ?? '';
                          final container = ProviderScope.containerOf(context);
                          final lista = container
                                  .read(analiseNotifierProvider)
                                  .valueOrNull ??
                              [];
                          final feature_analise.AnaliseSolo? analise = lista
                              .cast<feature_analise.AnaliseSolo?>()
                              .firstWhere(
                                (a) => a?.id == id,
                                orElse: () => null,
                              );
                          if (analise == null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              GoRouter.of(context).go(AppRoutes.analise);
                            });
                            return const SizedBox.shrink();
                          }
                          return NovaAnaliseScreen(analiseParaEditar: analise);
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
