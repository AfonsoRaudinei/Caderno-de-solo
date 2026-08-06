import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/usecases/migrar_vinculos_legados_usecase.dart';
import 'package:soloforte/features/analise/domain/value_objects/cliente_hierarquia_snapshot.dart';

AnaliseSolo _analise({
  String id = 'a1',
  String produtor = 'João Silva',
  String fazenda = 'Fazenda Boa Vista',
  String talhao = 'Talhão 01',
  AnaliseVinculoStatus? vinculoStatus,
  String? clienteId,
}) {
  return AnaliseSolo(
    id: id,
    fazenda: fazenda,
    produtor: produtor,
    talhao: talhao,
    numeroAmostra: 'A1',
    cultura: Cultura.soja,
    safra: '2025/26',
    laboratorio: 'IBRA',
    dataCadastro: DateTime(2025, 6, 1),
    profundidade: '0-20',
    vinculoStatus: vinculoStatus,
    clienteId: clienteId,
    fazendaId: clienteId == null ? null : 'fazenda-1',
    talhaoId: clienteId == null ? null : 'talhao-1',
  );
}

List<ClienteHierarquiaSnapshot> _clientes() {
  return [
    const ClienteHierarquiaSnapshot(
      id: 'cliente-1',
      nome: 'João Silva',
      fazendas: [
        FazendaHierarquiaSnapshot(
          id: 'fazenda-1',
          nome: 'Fazenda Boa Vista',
          talhoes: [
            TalhaoHierarquiaSnapshot(id: 'talhao-1', nome: 'Talhão 01'),
          ],
        ),
      ],
    ),
  ];
}

void main() {
  const usecase = MigrarVinculosLegadosUsecase();

  group('MigrarVinculosLegadosUsecase', () {
    test('infere reparos sem marcar pendentes quando desabilitado', () {
      final plan = usecase(
        analises: [
          _analise(),
          _analise(id: 'a2', produtor: 'Desconhecido'),
        ],
        clientes: _clientes(),
        marcarPendentes: false,
      );

      expect(plan.reparos, hasLength(1));
      expect(plan.reparos.first.clienteId, 'cliente-1');
      expect(plan.pendentes, isEmpty);
      expect(plan.jaVinculadas, 0);
    });

    test('marca pendentes quando habilitado', () {
      final plan = usecase(
        analises: [
          _analise(),
          _analise(id: 'a2', produtor: 'Desconhecido'),
        ],
        clientes: _clientes(),
        marcarPendentes: true,
      );

      expect(plan.reparos, hasLength(1));
      expect(plan.pendentes, hasLength(1));
      expect(plan.pendentes.first.vinculoStatus, AnaliseVinculoStatus.pendente);
    });

    test('ignora análises já vinculadas', () {
      final plan = usecase(
        analises: [
          _analise(clienteId: 'cliente-1'),
        ],
        clientes: _clientes(),
      );

      expect(plan.jaVinculadas, 1);
      expect(plan.isEmpty, isTrue);
    });
  });
}
