import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/application/providers/hierarquia_selecao_provider.dart';
import 'package:soloforte/features/clientes/data/datasources/cliente_firestore_datasource.dart';
import 'package:soloforte/features/analise/domain/value_objects/hierarquia_selecao_sugestao.dart';
import 'package:soloforte/features/clientes/data/repositories/cliente_repository.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';

void main() {
  final clientes = [
    ClienteEntity(
      id: 'cliente-1',
      token: 'tok',
      nome: 'João Silva',
      telefone: '',
      email: '',
      cidade: 'Palmas',
      estado: 'TO',
      usuarioId: 'user-1',
      criadoEm: DateTime(2026, 1),
      atualizadoEm: DateTime(2026, 1),
      fazendas: [
        FazendaEntity(
          id: 'fazenda-1',
          nome: 'Fazenda Boa Vista',
          areaTotal: 100,
          criadoEm: DateTime(2026, 1),
          talhoes: [
            TalhaoEntity(
              id: 'talhao-1',
              nome: 'Talhão 01',
              area: 10,
              criadoEm: DateTime(2026, 1),
            ),
          ],
        ),
      ],
    ),
  ];

  HierarquiaSelecaoNotifier buildNotifier(_FakeClienteRepository repository) {
    return HierarquiaSelecaoNotifier(
      repository: repository,
      waitForCurrentUserId: ({timeout = const Duration(seconds: 5)}) async {
        return 'user-1';
      },
    );
  }

  group('HierarquiaSelecaoNotifier', () {
    test('carregarClientes popula lista e limpa loading', () async {
      final notifier = buildNotifier(_FakeClienteRepository(clientes: clientes));

      await notifier.carregarClientes();

      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.clientes, hasLength(1));
      expect(notifier.state.requiresLogin, isFalse);
    });

    test('inicializar aplica sugestão compatível', () async {
      final notifier = buildNotifier(_FakeClienteRepository(clientes: clientes));

      await notifier.inicializar(
        const HierarquiaSelecaoSugestao(
          produtor: 'João Silva',
          fazenda: 'Fazenda Boa Vista',
          talhao: 'Talhão 01',
        ),
      );

      expect(notifier.state.clienteId, 'cliente-1');
      expect(notifier.state.fazendaId, 'fazenda-1');
      expect(notifier.state.talhaoId, 'talhao-1');
      expect(notifier.state.podeConfirmar, isTrue);
    });

    test('selecionarCliente limpa fazenda e talhão', () async {
      final notifier = buildNotifier(_FakeClienteRepository(clientes: clientes));
      await notifier.carregarClientes();
      notifier.selecionarCliente('cliente-1');
      notifier.selecionarFazenda('fazenda-1');
      notifier.selecionarTalhao('talhao-1');

      notifier.selecionarCliente('cliente-1');

      expect(notifier.state.fazendaId, isNull);
      expect(notifier.state.talhaoId, isNull);
      expect(notifier.state.podeConfirmar, isFalse);
    });

    test('buildResult retorna null até seleção completa', () async {
      final notifier = buildNotifier(_FakeClienteRepository(clientes: clientes));
      await notifier.carregarClientes();

      expect(notifier.buildResult(), isNull);

      notifier.selecionarCliente('cliente-1');
      notifier.selecionarFazenda('fazenda-1');
      notifier.selecionarTalhao('talhao-1');

      final result = notifier.buildResult();
      expect(result, isNotNull);
      expect(result!.clienteNome, 'João Silva');
      expect(result.fazendaNome, 'Fazenda Boa Vista');
      expect(result.talhaoNome, 'Talhão 01');
    });

    test('criarCliente rejeita nome vazio', () async {
      final notifier = buildNotifier(_FakeClienteRepository(clientes: clientes));

      final ok = await notifier.criarCliente('   ');

      expect(ok, isFalse);
      expect(notifier.state.erro, 'Informe o nome do cliente.');
    });
  });
}

class _FakeClienteRepository extends ClienteRepository {
  _FakeClienteRepository({required this.clientes})
      : super(
          ClienteFirestoreDatasource(firestore: FakeFirebaseFirestore()),
        );

  final List<ClienteEntity> clientes;

  @override
  Future<List<ClienteEntity>> listarClientes(String usuarioId) async {
    return clientes;
  }
}
