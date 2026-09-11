import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/clientes/presentation/cliente_form_screen.dart';

void main() {
  group('ClienteFormValidators.nome', () {
    test('rejeita vazio ou curto demais', () {
      expect(
        ClienteFormValidators.nome(null),
        'Informe pelo menos 3 caracteres.',
      );
      expect(
        ClienteFormValidators.nome(''),
        'Informe pelo menos 3 caracteres.',
      );
      expect(
        ClienteFormValidators.nome('Ab'),
        'Informe pelo menos 3 caracteres.',
      );
    });

    test('aceita nome com ao menos 3 caracteres', () {
      expect(ClienteFormValidators.nome('Ana'), isNull);
      expect(ClienteFormValidators.nome('  João  '), isNull);
    });
  });

  group('ClienteFormValidators.cidade', () {
    test('aceita vazio para permitir cadastro parcial', () {
      expect(ClienteFormValidators.cidade(null), isNull);
      expect(ClienteFormValidators.cidade(''), isNull);
      expect(ClienteFormValidators.cidade('Palmas'), isNull);
    });
  });

  group('ClienteFormValidators.telefone', () {
    test('aceita vazio (campo opcional)', () {
      expect(ClienteFormValidators.telefone(null), isNull);
      expect(ClienteFormValidators.telefone(''), isNull);
      expect(ClienteFormValidators.telefone('   '), isNull);
    });

    test('aceita telefone com 10 ou 11 dígitos', () {
      expect(ClienteFormValidators.telefone('(63) 3333-3333'), isNull);
      expect(ClienteFormValidators.telefone('(63) 99999-0000'), isNull);
    });

    test('rejeita telefone incompleto quando preenchido', () {
      expect(
        ClienteFormValidators.telefone('(63) 999'),
        'Informe um telefone válido.',
      );
    });
  });

  group('ClienteFormValidators.email', () {
    test('aceita vazio (campo opcional)', () {
      expect(ClienteFormValidators.email(null), isNull);
      expect(ClienteFormValidators.email(''), isNull);
      expect(ClienteFormValidators.email('  '), isNull);
    });

    test('aceita e-mail válido', () {
      expect(ClienteFormValidators.email('produtor@fazenda.com'), isNull);
    });

    test('rejeita e-mail inválido quando preenchido', () {
      expect(
        ClienteFormValidators.email('sem-arroba'),
        'Informe um e-mail válido.',
      );
    });
  });
}
