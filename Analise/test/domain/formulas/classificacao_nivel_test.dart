import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/classificacao_nivel.dart';

void main() {
  group('ClassificacaoNivel', () {
    test('classifica S por faixas do PROMPT', () {
      expect(ClassificacaoNivel.classificar(nutriente: 's', valor: 3),
          'Muito Baixo');
      expect(ClassificacaoNivel.classificar(nutriente: 's', valor: 8), 'Baixo');
      expect(
          ClassificacaoNivel.classificar(nutriente: 's', valor: 15), 'Médio');
      expect(ClassificacaoNivel.classificar(nutriente: 's', valor: 25),
          'Adequado');
    });

    test('classifica P com NC por textura', () {
      expect(
        ClassificacaoNivel.classificar(nutriente: 'p', valor: 5, argila: 10),
        'Muito Baixo',
      );
      expect(
        ClassificacaoNivel.classificar(nutriente: 'p', valor: 5, argila: 70),
        'Adequado',
      );
    });

    test('nutriente desconhecido retorna Indeterminado', () {
      expect(
        ClassificacaoNivel.classificar(nutriente: 'xyz', valor: 1),
        'Indeterminado',
      );
    });
  });
}
