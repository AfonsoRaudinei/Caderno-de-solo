import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/clientes/presentation/clientes_list_screen.dart';

void main() {
  group('isClienteFormRoute', () {
    test('detecta rotas de formulário sobre a lista', () {
      expect(isClienteFormRoute('/clientes/novo'), isTrue);
      expect(isClienteFormRoute('/clientes/abc/editar'), isTrue);
      expect(isClienteFormRoute('/clientes'), isFalse);
      expect(isClienteFormRoute('/clientes/abc'), isFalse);
    });
  });
}
