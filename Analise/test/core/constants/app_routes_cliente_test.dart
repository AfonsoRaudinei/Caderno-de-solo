import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/features/clientes/presentation/cliente_detail_tab.dart';

void main() {
  group('AppRoutes clientes', () {
    test('gera paths de fazenda e talhão', () {
      expect(
        AppRoutes.fazendaNovaPath('c1'),
        '/clientes/c1/fazenda/nova',
      );
      expect(
        AppRoutes.fazendaEditarPath('c1', 'f1'),
        '/clientes/c1/fazenda/f1/editar',
      );
      expect(
        AppRoutes.talhaoNovoPath('c1', 'f1'),
        '/clientes/c1/fazenda/f1/talhao/novo',
      );
      expect(
        AppRoutes.talhaoEditarPath('c1', 'f1', 't1'),
        '/clientes/c1/fazenda/f1/talhao/t1/editar',
      );
    });

    test('gera rota de análises do cliente', () {
      expect(
        AppRoutes.clienteAnalisesPath('c1'),
        '/clientes/c1/analises',
      );
      expect(
        AppRoutes.clienteDetalheComAbaPath('c1', tab: 'analises'),
        '/clientes/c1/analises',
      );
      expect(
        AppRoutes.clienteDetalheComAbaPath('c1', tab: 'talhoes'),
        '/clientes/c1?tab=talhoes',
      );
    });
  });

  group('ClienteDetailTab', () {
    test('resolve aba a partir de query', () {
      expect(ClienteDetailTab.fromQuery('analises'), ClienteDetailTab.analises);
      expect(ClienteDetailTab.fromQuery('recomendacao'),
          ClienteDetailTab.recomendacoes);
      expect(ClienteDetailTab.fromQuery(null), ClienteDetailTab.resumo);
    });
  });
}
