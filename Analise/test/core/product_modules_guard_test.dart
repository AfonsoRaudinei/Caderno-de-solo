import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/features/clientes/presentation/clientes_page.dart';
import 'package:soloforte/features/main/presentation/main_page.dart';

/// Guard Dart: falha o CI se o módulo Clientes ou a aba sumirem do produto.
void main() {
  group('Product modules guard', () {
    test('AppRoutes expõe a árvore de Clientes', () {
      expect(AppRoutes.clientes, '/clientes');
      expect(AppRoutes.clienteNovo, '/clientes/novo');
      expect(AppRoutes.clienteDetalhe, '/clientes/:id');
      expect(AppRoutes.clienteEditar, '/clientes/:id/editar');
      expect(AppRoutes.fazendaNova, '/clientes/:id/fazenda/nova');
      expect(AppRoutes.clienteDetalhePath('abc'), '/clientes/abc');
      expect(AppRoutes.clienteEditarPath('abc'), '/clientes/abc/editar');
    });

    test('ClientesPage continua importável (módulo presente)', () {
      expect(ClientesPage, isNotNull);
      const page = ClientesPage();
      expect(page, isA<ClientesPage>());
    });

    test('MainPage mantém aba Clientes como primeira tab', () {
      expect(MainPage.tabs, isNotEmpty);
      expect(MainPage.tabs.first.label, 'Clientes');
      final labels = MainPage.tabs.map((t) => t.label).toList();
      expect(labels,
          containsAll(['Clientes', 'Análise', 'Lab', 'Mapa', 'Config']));
    });
  });
}
