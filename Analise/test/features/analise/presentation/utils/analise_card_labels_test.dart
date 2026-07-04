import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/presentation/utils/analise_card_labels.dart';

import '../../../../support/analise_test_factories.dart';

void main() {
  group('buildPastaCardLabels', () {
    test('prioriza produtor fazenda laboratorio e os', () {
      final labels = buildPastaCardLabels(
        produtor: 'ANDRE LUIZ DE SIQUEIRA',
        fazenda: 'MOEMA',
        laboratorio: 'Exata Brasil',
        os: '20573',
      );

      expect(labels.titulo, 'ANDRE LUIZ DE SIQUEIRA');
      expect(labels.subtitulo, 'MOEMA');
      expect(labels.detalhe, 'Exata Brasil · O.S. 20573');
    });
  });

  group('buildAmostraCardLabels', () {
    test('diferencia amostras pelo numero quando talhao repetido', () {
      final a = buildAmostraCardLabels(
        makeAnalise(
          id: 'a1',
          talhao: 'T01',
          numeroAmostra: 'SBA25.147294',
          fazenda: 'MOEMA',
        ),
      );
      final b = buildAmostraCardLabels(
        makeAnalise(
          id: 'a2',
          talhao: 'T01',
          numeroAmostra: 'SBA25.147295',
          fazenda: 'MOEMA',
        ),
      );

      expect(a.titulo, 'T01');
      expect(b.titulo, 'T01');
      expect(a.subtitulo, 'SBA25.147294');
      expect(b.subtitulo, 'SBA25.147295');
      expect(a.subtitulo, isNot(b.subtitulo));
    });

    test('inclui profundidade e fazenda no detalhe', () {
      final labels = buildAmostraCardLabels(
        makeAnalise(
          id: 'a1',
          talhao: 'T01',
          numeroAmostra: 'SBA25.147294',
          fazenda: 'MOEMA',
        ),
      );

      expect(labels.detalhe, contains('0-20'));
      expect(labels.detalhe, contains('MOEMA'));
    });
  });
}
