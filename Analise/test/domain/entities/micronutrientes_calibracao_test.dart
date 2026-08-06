import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/entities/micronutrientes_calibracao.dart';

void main() {
  group('MicronutrientesCalibracao', () {
    test('normaliza elemento legado com referencia e ncSolo', () {
      final elemento = normalizarElementoMicros('B', {
        'referencia': 'EMBRAPA Soja',
        'ncSolo': 0.9,
        'viaAplicacao': 'Ambas',
        'tipoFonte': 'Autores',
        'autor': 'Malavolta (1997)',
        'teorFonteSolo': 10,
      });

      expect(elemento['referenciaNc'], 'EMBRAPA Soja');
      expect(elemento['referencia'], 'EMBRAPA Soja');
      expect(elemento['ncSolo'], 0.9);
      expect(elemento['ncUnidade'], 'mg/dm³');
      expect(elemento['concentracaoFonte'], 10.0);
      expect(elemento['viasAplicacao'], ['Solo', 'Foliar']);
      expect(elemento['referenciaAbsorcaoNome'], 'Malavolta (1997)');
    });

    test('normaliza grupo legado com produto e eficiencia', () {
      final grupo = normalizarGrupoMicros({
        'nome': 'Foliares',
        'via': 'Foliar',
        'produto': 'Mistura manual',
        'eficiencia': 90,
        'elementos': ['B', 'Mn'],
      });

      expect(grupo['fonte'], 'Mistura manual');
      expect(grupo['eficienciaFoliarGrupo'], 90.0);
      expect(grupo['viasAplicacaoGrupo'], ['Foliar']);
      expect(grupo['elementos'], ['B', 'Mn']);
    });

    test('elementosSelecionadosNosGrupos retorna união dos grupos', () {
      final selecionados = elementosSelecionadosNosGrupos([
        {
          'elementos': ['B', 'Mn']
        },
        {
          'elementos': ['B', 'Cu']
        },
      ]);

      expect(selecionados, {'B', 'Mn', 'Cu'});
    });

    test('novoGrupoMicros cria estrutura mínima', () {
      final grupo = novoGrupoMicros(indice: 2);

      expect(grupo['nome'], 'Grupo 2');
      expect(grupo['viasAplicacaoGrupo'], ['Foliar']);
      expect(grupo['referenciaTecnica'], isNotEmpty);
      expect(grupo['elementos'], isEmpty);
    });
  });
}
