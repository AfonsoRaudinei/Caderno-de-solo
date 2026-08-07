import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/clientes/application/providers/cliente_provider.dart';
import 'package:soloforte/features/clientes/data/datasources/cliente_firestore_datasource.dart';
import 'package:soloforte/features/clientes/data/repositories/cliente_repository.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';
import 'package:soloforte/features/clientes/domain/exceptions/cliente_session_exception.dart';

void main() {
  group('ClienteNotifier.criarCliente', () {
    test('mantem cliente visivel quando reload retorna lista vazia', () async {
      final repository = _CreatedButEmptyListRepository();
      final notifier = ClienteNotifier(
        repository: repository,
        waitForCurrentUserId: ({timeout = const Duration(seconds: 5)}) async {
          return 'user-1';
        },
        signOut: () async {},
      );

      final id = await notifier.criarCliente(
        ClienteEntity(
          id: '',
          token: '',
          nome: 'Cliente Visivel',
          telefone: '',
          email: '',
          cidade: 'Palmas',
          estado: 'TO',
          usuarioId: '',
          criadoEm: DateTime(2026, 8),
          atualizadoEm: DateTime(2026, 8),
        ),
      );

      expect(id, 'cliente-criado');
      expect(notifier.state.clientes, hasLength(1));
      expect(notifier.state.clientes.single.id, 'cliente-criado');
      expect(notifier.state.clientes.single.nome, 'Cliente Visivel');
      expect(notifier.state.clienteSelecionado?.id, 'cliente-criado');
      expect(notifier.state.isLoading, isFalse);
    });

    test(
        'nao força login quando Firestore nega permissão mas Auth ainda tem usuário',
        () async {
      var signedOut = false;
      final notifier = ClienteNotifier(
        repository: _SessionDeniedRepository(),
        waitForCurrentUserId: ({timeout = const Duration(seconds: 5)}) async {
          return 'user-1';
        },
        signOut: () async {
          signedOut = true;
        },
      );

      final id = await notifier.criarCliente(
        ClienteEntity(
          id: '',
          token: '',
          nome: 'Cliente Teste',
          telefone: '',
          email: '',
          cidade: 'Palmas',
          estado: 'TO',
          usuarioId: '',
          criadoEm: DateTime(2026, 7, 31),
          atualizadoEm: DateTime(2026, 7, 31),
        ),
      );

      expect(id, isNull);
      expect(signedOut, isFalse);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.requiresLogin, isFalse);
      expect(notifier.state.erro, isNotNull);
    });

    test('marca requiresLogin quando Auth não tem usuário', () async {
      var signedOut = false;
      final notifier = ClienteNotifier(
        repository: _SessionDeniedRepository(),
        waitForCurrentUserId: ({timeout = const Duration(seconds: 5)}) async {
          return null;
        },
        signOut: () async {
          signedOut = true;
        },
      );

      final id = await notifier.criarCliente(
        ClienteEntity(
          id: '',
          token: '',
          nome: 'Cliente Teste',
          telefone: '',
          email: '',
          cidade: 'Palmas',
          estado: 'TO',
          usuarioId: '',
          criadoEm: DateTime(2026, 7, 31),
          atualizadoEm: DateTime(2026, 7, 31),
        ),
      );

      expect(id, isNull);
      // UID nulo no início do create chama _markRequiresLogin sem signOut.
      expect(signedOut, isFalse);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.requiresLogin, isTrue);
    });
  });
}

class _SessionDeniedRepository extends ClienteRepository {
  _SessionDeniedRepository()
      : super(
          ClienteFirestoreDatasource(firestore: FakeFirebaseFirestore()),
        );

  @override
  Future<String> criarCliente(ClienteEntity cliente) {
    throw const ClienteSessionException();
  }
}

class _CreatedButEmptyListRepository extends ClienteRepository {
  _CreatedButEmptyListRepository()
      : super(
          ClienteFirestoreDatasource(firestore: FakeFirebaseFirestore()),
        );

  ClienteEntity? _created;

  @override
  Future<String> criarCliente(ClienteEntity cliente) async {
    _created = cliente.copyWith(id: 'cliente-criado');
    return 'cliente-criado';
  }

  @override
  Future<List<ClienteEntity>> listarClientes(String usuarioId) async {
    return const [];
  }

  @override
  Future<ClienteEntity?> buscarClientePorId(String id) async {
    return _created;
  }
}
