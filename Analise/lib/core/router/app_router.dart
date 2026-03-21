import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/presentation/auth/login/login_page.dart';

import 'package:soloforte/presentation/auth/cadastro/cadastro_page.dart';

import 'package:soloforte/presentation/auth/recuperar_senha/recuperar_senha_page.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:soloforte/presentation/main/main_page.dart';
import 'package:soloforte/presentation/analise/analise_page.dart';
import 'package:soloforte/presentation/analise/analise_form_page.dart';
import 'package:soloforte/features/analise/presentation/screens/analise_detail_screen.dart';
import 'package:soloforte/features/analise/presentation/screens/nova_analise_screen.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart'
    as feature_analise;
import 'package:soloforte/presentation/lab/lab_page.dart';
import 'package:soloforte/presentation/historico/historico_page.dart';
import 'package:soloforte/presentation/config/config_page.dart';

import 'package:soloforte/presentation/config/feedback/feedback_page.dart';
import 'package:soloforte/presentation/config/base_dados/base_dados_page.dart';
import 'package:soloforte/presentation/config/base_dados/base_dados_form_page.dart';
import 'package:soloforte/presentation/config/base_dados/base_dados_detail_page.dart';
import 'package:soloforte/data/base_dados/referencias_tecnicas_data.dart';
import 'package:soloforte/features/culturas/screens/culturas_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation:
        AppRoutes.analise, // Mudado para tentar entrar direto no app
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');

      final isAuthRoute = state.uri.path == AppRoutes.login ||
          state.uri.path == AppRoutes.cadastro ||
          state.uri.path == AppRoutes.recuperarSenha;

      if (token == null && !isAuthRoute) {
        return AppRoutes.login;
      }

      if (token != null && isAuthRoute) {
        return AppRoutes.analise;
      }

      if (state.uri.path == AppRoutes.home) {
        return AppRoutes.analise;
      }

      return null;
    },
    routes: [
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
        path: AppRoutes.baseDadosLegacyAlias,
        redirect: (_, __) => AppRoutes.baseDados,
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
                          final extra = state.extra;
                          final analise = extra is feature_analise.AnaliseSolo
                              ? extra
                              : null;
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
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.historico,
                builder: (context, state) => const HistoricoPage(),
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
                    path: 'base-dados',
                    builder: (context, state) => const BaseDadosPage(),
                    routes: [
                      GoRoute(
                        path: 'nova',
                        builder: (context, state) => const BaseDadosFormPage(),
                      ),
                      GoRoute(
                        path: ':id',
                        builder: (context, state) {
                          final id = state.pathParameters['id'] ?? '';
                          final ref = state.extra is ReferenciaTecnica
                              ? state.extra as ReferenciaTecnica
                              : referenciaTecnicaPorId(id);
                          if (ref == null) {
                            return const BaseDadosPage();
                          }
                          return BaseDadosDetailPage(referencia: ref);
                        },
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
