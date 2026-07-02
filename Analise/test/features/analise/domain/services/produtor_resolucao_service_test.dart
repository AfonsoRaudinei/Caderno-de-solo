import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/services/produtor_resolucao_service.dart';

AnaliseSolo _analise({
  String produtor = '',
  Map<String, dynamic>? metadata,
}) {
  return AnaliseSolo(
    id: 'a-1',
    fazenda: 'Fazenda A',
    produtor: produtor,
    talhao: 'T1',
    numeroAmostra: '001',
    cultura: Cultura.soja,
    safra: '25/26',
    laboratorio: 'IBRA',
    dataCadastro: DateTime(2026, 1, 1),
    profundidade: '0-20',
    laudoMetadata: metadata,
  );
}

void main() {
  group('ProdutorResolucaoService', () {
    test('detecta contratante IBRA como produtor invalido', () {
      expect(
        ProdutorResolucaoService.isProdutorInvalido(
          'Agrofarm — Produtos Agroquímicos Ltda.',
        ),
        isTrue,
      );
      expect(
        ProdutorResolucaoService.isProdutorInvalido('Rogério de Paiva Moura'),
        isFalse,
      );
    });

    test('resolver prioriza produtor atual valido', () {
      final resolvido = ProdutorResolucaoService.resolver(
        produtorAtual: 'Cliente A',
        laudoMetadata: const {'proprietario': 'Outro'},
        produtorConfigurado: 'Configurado',
      );

      expect(resolvido, 'Cliente A');
    });

    test('resolver usa metadata e depois produtor configurado', () {
      final viaMetadata = ProdutorResolucaoService.resolver(
        produtorAtual: '',
        laudoMetadata: const {'proprietario': 'Rogério de Paiva Moura'},
        produtorConfigurado: 'Configurado',
      );
      expect(viaMetadata, 'Rogério de Paiva Moura');

      final viaConfigurado = ProdutorResolucaoService.resolver(
        produtorAtual: '',
        laudoMetadata: const {'proprietario': 'Agrofarm'},
        produtorConfigurado: 'Cliente Configurado',
      );
      expect(viaConfigurado, 'Cliente Configurado');
    });

    test('aplicarProdutorConfigurado corrige analise legada', () {
      final corrigida = ProdutorResolucaoService.aplicarProdutorConfigurado(
        _analise(
          metadata: const {'proprietario': 'Rogério de Paiva Moura'},
        ),
        'Fallback',
      );

      expect(corrigida.produtor, 'Rogério de Paiva Moura');
    });

    test('compativelComConfigurado exige match quando configurado', () {
      final analise = _analise(produtor: 'Cliente A');

      expect(
        ProdutorResolucaoService.compativelComConfigurado(analise, ''),
        isTrue,
      );
      expect(
        ProdutorResolucaoService.compativelComConfigurado(analise, 'Cliente A'),
        isTrue,
      );
      expect(
        ProdutorResolucaoService.compativelComConfigurado(analise, 'Outro'),
        isFalse,
      );
    });
  });
}
