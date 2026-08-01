import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/services/analise_vinculo_service.dart';
import 'package:soloforte/features/analise/domain/usecases/reparar_vinculos_legados_usecase.dart';
import 'package:soloforte/features/analise/domain/value_objects/cliente_hierarquia_snapshot.dart';

AnaliseSolo _analise({
  String produtor = 'João Silva',
  String fazenda = 'Fazenda Boa Vista',
  String talhao = 'Talhão 01',
}) {
  return AnaliseSolo(
    id: 'analise-1',
    fazenda: fazenda,
    produtor: produtor,
    talhao: talhao,
    numeroAmostra: 'A1',
    cultura: Cultura.soja,
    safra: '2025/26',
    laboratorio: 'IBRA',
    dataCadastro: DateTime(2025, 6, 1),
    profundidade: '0-20',
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
  group('AnaliseVinculoService', () {
    test('infere vínculo completo por correspondência de nomes', () {
      final vinculo = AnaliseVinculoService.inferir(
        analise: _analise(),
        clientes: _clientes(),
      );

      expect(vinculo, isNotNull);
      expect(vinculo!.clienteId, 'cliente-1');
      expect(vinculo.fazendaId, 'fazenda-1');
      expect(vinculo.talhaoId, 'talhao-1');
      expect(vinculo.status, AnaliseVinculoStatus.inferido);
    });

    test('marca pendente quando cliente não existe', () {
      final reparada = AnaliseVinculoService.tentarInferirVinculo(
        analise: _analise(produtor: 'Desconhecido'),
        clientes: _clientes(),
      );

      expect(reparada.possuiVinculoHierarquico, isFalse);
      expect(reparada.vinculoStatus, AnaliseVinculoStatus.pendente);
    });

    test('não altera análise já vinculada', () {
      final vinculada = _analise().copyWith(
        clienteId: 'cliente-existente',
        fazendaId: 'fazenda-existente',
        talhaoId: 'talhao-existente',
        vinculoStatus: AnaliseVinculoStatus.manual,
      );

      final resultado = AnaliseVinculoService.tentarInferirVinculo(
        analise: vinculada,
        clientes: _clientes(),
      );

      expect(resultado, same(vinculada));
    });
  });

  group('RepararVinculosLegadosUsecase', () {
    test('retorna apenas análises reparadas', () {
      const usecase = RepararVinculosLegadosUsecase();
      final reparos = usecase(
        analises: [
          _analise(),
          _analise(produtor: 'Sem match'),
        ],
        clientes: _clientes(),
      );

      expect(reparos, hasLength(1));
      expect(reparos.first.clienteId, 'cliente-1');
      expect(reparos.first.vinculoStatus, AnaliseVinculoStatus.inferido);
    });
  });
}
