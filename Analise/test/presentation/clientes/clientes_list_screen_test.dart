import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/features/clientes/application/providers/cliente_provider.dart';
import 'package:soloforte/features/clientes/data/datasources/cliente_firestore_datasource.dart';
import 'package:soloforte/features/clientes/data/repositories/cliente_repository.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';
import 'package:soloforte/features/clientes/presentation/clientes_list_screen.dart';

void main() {
  group('ClientesListScreen', () {
    testWidgets('exibe empty state quando lista está vazia', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          notifier: _FakeClienteNotifier(const ClienteState()),
        ),
      );

      expect(find.text('Nenhum cliente cadastrado'), findsOneWidget);
      expect(find.text('Toque em + para adicionar'), findsOneWidget);
    });

    testWidgets('exibe ClienteCardWidget quando há clientes', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          notifier: _FakeClienteNotifier(
            ClienteState(clientes: [_cliente(nome: 'Cliente Teste')]),
          ),
        ),
      );

      expect(find.text('Cliente Teste'), findsOneWidget);
      expect(find.textContaining('token SF-2026-ABCD'), findsOneWidget);
    });

    testWidgets('tap no card navega para /clientes/:id/analises',
        (tester) async {
      final cliente = _cliente(nome: 'Cliente Teste');
      final router = GoRouter(
        initialLocation: AppRoutes.clientes,
        routes: [
          GoRoute(
            path: AppRoutes.clientes,
            builder: (_, __) => const ClientesListScreen(),
          ),
          GoRoute(
            path: '/clientes/:id/analises',
            builder: (_, state) => Scaffold(
              body: Text('analises ${state.pathParameters['id']}'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clienteProvider.overrideWith(
              (ref) => _FakeClienteNotifier(
                ClienteState(clientes: [cliente]),
              ),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.tap(find.text('Cliente Teste'));
      await tester.pumpAndSettle();

      expect(find.text('analises 1'), findsOneWidget);
    });

    testWidgets('exibe badge com contagem de análises no card', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          notifier: _FakeClienteNotifier(
            ClienteState(
              clientes: [
                _cliente(nome: 'Com Análises', analiseIds: ['a1', 'a2']),
              ],
            ),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('FAB navega para /clientes/novo', (tester) async {
      final router = GoRouter(
        initialLocation: AppRoutes.clientes,
        routes: [
          GoRoute(
            path: AppRoutes.clientes,
            builder: (_, __) => const ClientesListScreen(),
          ),
          GoRoute(
            path: AppRoutes.clienteNovo,
            builder: (_, __) => const Scaffold(body: Text('novo cliente')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clienteProvider.overrideWith(
              (ref) => _FakeClienteNotifier(const ClienteState()),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('novo cliente'), findsOneWidget);
    });

    testWidgets(
        'não recarrega lista ao voltar do cadastro (evita redirect falso)',
        (tester) async {
      final notifier = _FakeClienteNotifier(const ClienteState());
      final router = GoRouter(
        initialLocation: AppRoutes.clientes,
        routes: [
          GoRoute(
            path: AppRoutes.clientes,
            builder: (_, __) => const ClientesListScreen(),
          ),
          GoRoute(
            path: AppRoutes.clienteNovo,
            builder: (context, __) => Scaffold(
              body: TextButton(
                onPressed: () => context.pop(true),
                child: const Text('salvar fake'),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clienteProvider.overrideWith((ref) => notifier),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('salvar fake'));
      await tester.pumpAndSettle();

      expect(notifier.carregarClientesCount, 0);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('empty state não duplica botão de adicionar (só FAB)',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          notifier: _FakeClienteNotifier(const ClienteState()),
        ),
      );

      expect(find.text('Adicionar cliente'), findsNothing);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('campo de busca filtra por nome', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          notifier: _FakeClienteNotifier(
            ClienteState(
              clientes: [
                _cliente(nome: 'Maria Silva'),
                _cliente(nome: 'João Costa', token: 'SF-2026-ZZZZ'),
              ],
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'maria');
      await tester.pumpAndSettle();

      expect(find.text('Maria Silva'), findsOneWidget);
      expect(find.text('João Costa'), findsNothing);
    });

    testWidgets('loading indicator aparece quando isLoading = true',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          notifier: _FakeClienteNotifier(
            const ClienteState(isLoading: true),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('redireciona para login quando sessão é inválida',
        (tester) async {
      final notifier = _FakeClienteNotifier(const ClienteState());

      await tester.pumpWidget(
        _buildApp(
          notifier: notifier,
          includeLoginRoute: true,
        ),
      );

      notifier.exigirLogin();
      await tester.pumpAndSettle();

      expect(find.text('login'), findsOneWidget);
      expect(find.textContaining('permission-denied'), findsNothing);
    });
  });
}

Widget _buildApp({
  required _FakeClienteNotifier notifier,
  bool includeLoginRoute = false,
}) {
  final router = GoRouter(
    initialLocation: AppRoutes.clientes,
    routes: [
      GoRoute(
        path: AppRoutes.clientes,
        builder: (_, __) => const ClientesListScreen(),
      ),
      GoRoute(
        path: AppRoutes.clienteNovo,
        builder: (_, __) => const Scaffold(body: Text('novo cliente')),
      ),
      if (includeLoginRoute)
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const Scaffold(body: Text('login')),
        ),
    ],
  );

  return ProviderScope(
    overrides: [
      clienteProvider.overrideWith((ref) => notifier),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _FakeClienteNotifier extends ClienteNotifier {
  _FakeClienteNotifier(ClienteState initialState)
      : super(
          repository: _NoopClienteRepository(),
          waitForCurrentUserId:
              ({timeout = const Duration(seconds: 5)}) async => 'test-user',
          signOut: () async {},
        ) {
    state = initialState;
  }

  int carregarClientesCount = 0;

  @override
  Future<void> carregarClientes() async {
    carregarClientesCount++;
  }

  void exigirLogin() {
    state = state.copyWith(requiresLogin: true);
  }
}

class _NoopClienteRepository extends ClienteRepository {
  _NoopClienteRepository() : super(_NoopDatasource());
}

class _NoopDatasource extends ClienteFirestoreDatasource {
  _NoopDatasource() : super(firestore: FakeFirebaseFirestore());
}

ClienteEntity _cliente({
  String nome = 'Cliente',
  String token = 'SF-2026-ABCD',
  List<String> analiseIds = const [],
}) {
  return ClienteEntity(
    id: '1',
    token: token,
    nome: nome,
    telefone: '(63) 99999-0000',
    email: 'cliente@teste.com',
    cidade: 'Palmas',
    estado: 'TO',
    fazendas: [
      FazendaEntity(
        id: 'f1',
        nome: 'Boa Vista',
        areaTotal: 120.5,
        criadoEm: DateTime(2026, 7, 14),
      ),
    ],
    usuarioId: 'user-1',
    criadoEm: DateTime(2026, 7, 14),
    atualizadoEm: DateTime(2026, 7, 14),
    analiseIds: analiseIds,
  );
}
