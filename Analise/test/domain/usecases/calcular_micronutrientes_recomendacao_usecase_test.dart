import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/entities/analise_entity.dart';
import 'package:soloforte/domain/usecases/calcular_micronutrientes_recomendacao_usecase.dart';

const _analiseBase = AnaliseEntity(
  id: 'a1',
  nome: 'Teste',
  consultor: 'Teste',
  fazenda: '',
  talhao: '',
  localizacao: '',
  cultura: 'Soja',
  ph: 5.5,
  mo: 30,
  p: 10,
  k: 0.2,
  ca: 3,
  mg: 1,
  hAl: 2,
  al: 0.1,
  s: 5,
  b: 0.5,
  cu: 0.4,
  fe: 20,
  mn: 8,
  zn: 1.0,
  sb: 4,
  ctc: 8,
  vPercent: 50,
  argila: 35,
);

AnaliseEntity _analise({double zn = 1.0, double b = 0.5, double cu = 0.4}) {
  return _analiseBase.copyWith(zn: zn, b: b, cu: cu);
}

Map<String, dynamic> _elementoBase(String simbolo, {double nc = 2.0}) {
  return {
    'simbolo': simbolo,
    'ncSolo': nc,
    'ncUnidade': 'mg/dm³',
    'extracaoPlanta': 70,
    'exportacaoGraos': 30,
    'concentracaoFonte': 20,
    'concentracaoUnidade': '%',
    'viasAplicacao': ['Solo'],
    'eficienciaSolo': 100,
    'doseMinima': 0,
    'doseMaxima': 0,
    'limiteToxicidade': 0,
  };
}

void main() {
  const usecase = CalcularMicronutrientesRecomendacaoUsecase();

  group('CalcularMicronutrientesRecomendacaoUsecase', () {
    test('teor abaixo do NC usa correção solo e regra Planta', () {
      final result = usecase.execute(
        microsConfig: {
          'grupos': [
            {
              'id': 'g1',
              'nome': 'Solo Zn',
              'viasAplicacaoGrupo': ['Solo'],
              'eficienciaSoloGrupo': 100,
              'fonte': 'Sulfato de zinco',
              'elementos': ['Zn'],
            },
          ],
          'elementos': {'Zn': _elementoBase('Zn', nc: 2.0)},
        },
        analise: _analise(zn: 1.0),
        producaoEsperadaTha: 4,
      );

      final zn = result.micros.first;
      expect(zn.deficit, closeTo(1.0, 0.01));
      expect(zn.correcaoSolo, closeTo(2000, 0.01));
      expect(zn.regraUtilizada, 'Planta');
      expect(zn.extracao, closeTo(280, 0.01));
      expect(zn.dose, closeTo(2000, 0.01));
      expect(zn.doseProduto, greaterThan(0));
    });

    test('teor igual ao NC usa regra Grão', () {
      final result = usecase.execute(
        microsConfig: {
          'grupos': [
            {
              'id': 'g1',
              'nome': 'Grupo',
              'viasAplicacaoGrupo': ['Foliar'],
              'eficienciaFoliarGrupo': 80,
              'elementos': ['Zn'],
            },
          ],
          'elementos': {'Zn': _elementoBase('Zn', nc: 1.0)},
        },
        analise: _analise(zn: 1.0),
        producaoEsperadaTha: 4,
      );

      final zn = result.micros.first;
      expect(zn.deficit, 0);
      expect(zn.regraUtilizada, 'Grão');
      expect(zn.exportacao, closeTo(120, 0.01));
      expect(zn.necessidadeNutriente, closeTo(120, 0.01));
    });

    test('teor acima do NC usa exportação', () {
      final result = usecase.execute(
        microsConfig: {
          'grupos': [
            {
              'id': 'g1',
              'nome': 'Grupo',
              'viasAplicacaoGrupo': ['Foliar'],
              'eficienciaFoliarGrupo': 100,
              'elementos': ['B'],
            },
          ],
          'elementos': {
            'B': {
              ..._elementoBase('B', nc: 0.5),
              'viasAplicacao': ['Foliar'],
            },
          },
        },
        analise: _analise(b: 0.8),
        producaoEsperadaTha: 5,
      );

      final b = result.micros.first;
      expect(b.regraUtilizada, 'Grão');
      expect(b.necessidadeNutriente, closeTo(150, 0.01));
    });

    test('cada elemento usa seu próprio teor — nunca mistura B com Cu', () {
      final result = usecase.execute(
        microsConfig: {
          'grupos': [
            {
              'id': 'g1',
              'nome': 'Misto',
              'viasAplicacaoGrupo': ['Solo'],
              'eficienciaSoloGrupo': 100,
              'elementos': ['B', 'Cu'],
            },
          ],
          'elementos': {
            'B': {
              ..._elementoBase('B', nc: 0.9),
              'viasAplicacao': ['Solo']
            },
            'Cu': {
              ..._elementoBase('Cu', nc: 1.0),
              'viasAplicacao': ['Solo']
            },
          },
        },
        analise: _analise(b: 0.5, cu: 1.5),
        producaoEsperadaTha: 4,
      );

      final b = result.micros.firstWhere((m) => m.elemento == 'B');
      final cu = result.micros.firstWhere((m) => m.elemento == 'Cu');
      expect(b.deficit, closeTo(0.4, 0.01));
      expect(b.regraUtilizada, 'Planta');
      expect(cu.deficit, 0);
      expect(cu.regraUtilizada, 'Grão');
    });

    test('múltiplos grupos com mesmo elemento geram resultados distintos', () {
      final result = usecase.execute(
        microsConfig: {
          'grupos': [
            {
              'id': 'g-foliar',
              'nome': 'Foliar',
              'viasAplicacaoGrupo': ['Foliar'],
              'eficienciaFoliarGrupo': 80,
              'elementos': ['B'],
            },
            {
              'id': 'g-solo',
              'nome': 'Solo',
              'viasAplicacaoGrupo': ['Solo'],
              'eficienciaSoloGrupo': 50,
              'elementos': ['B'],
            },
          ],
          'elementos': {
            'B': {
              ..._elementoBase('B', nc: 1.0),
              'viasAplicacao': ['Solo', 'Foliar'],
            },
          },
        },
        analise: _analise(b: 0.4),
        producaoEsperadaTha: 4,
      );

      expect(result.grupos, hasLength(2));
      final foliar = result.micros.firstWhere((m) => m.grupoId == 'g-foliar');
      final solo = result.micros.firstWhere((m) => m.grupoId == 'g-solo');
      expect(foliar.via, 'Foliar');
      expect(solo.via, 'Solo');
      expect(solo.dose, greaterThan(foliar.dose));
    });

    test('filtro por grupo selecionado', () {
      final result = usecase.execute(
        microsConfig: {
          'grupos': [
            {
              'id': 'g1',
              'nome': 'G1',
              'viasAplicacaoGrupo': ['Solo'],
              'eficienciaSoloGrupo': 100,
              'elementos': ['Zn'],
            },
            {
              'id': 'g2',
              'nome': 'G2',
              'viasAplicacaoGrupo': ['Foliar'],
              'eficienciaFoliarGrupo': 100,
              'elementos': ['B'],
            },
          ],
          'elementos': {
            'Zn': _elementoBase('Zn'),
            'B': {
              ..._elementoBase('B', nc: 0.5),
              'viasAplicacao': ['Foliar']
            },
          },
        },
        analise: _analise(),
        producaoEsperadaTha: 4,
        gruposIdsSelecionados: ['g1'],
      );

      expect(result.micros, hasLength(1));
      expect(result.micros.first.elemento, 'Zn');
      expect(result.grupos, hasLength(1));
    });

    test('compatibilidade legado sem grupos', () {
      final result = usecase.execute(
        microsConfig: {
          'elementos': {
            'Zn': {
              'ncSolo': 2.0,
              'viaAplicacao': 'Solo (correção)',
              'teorFonteSolo': 20,
              'eficienciaSolo': 100,
              'percentualCorrecaoSolo': 100,
            },
          },
        },
        analise: _analise(zn: 1.0),
        producaoEsperadaTha: null,
      );

      expect(result.micros, isNotEmpty);
      expect(result.micros.first.dose, closeTo(2000, 0.01));
    });

    test('memória de cálculo preenchida', () {
      final result = usecase.execute(
        microsConfig: {
          'grupos': [
            {
              'id': 'g1',
              'nome': 'Teste',
              'viasAplicacaoGrupo': ['Solo'],
              'eficienciaSoloGrupo': 100,
              'elementos': ['Zn'],
            },
          ],
          'elementos': {'Zn': _elementoBase('Zn')},
        },
        analise: _analise(zn: 1.0),
        producaoEsperadaTha: 4,
      );

      expect(result.micros.first.memoriaCalculo, isNotEmpty);
      expect(
        result.micros.first.memoriaCalculo.any((l) => l.contains('Déficit')),
        isTrue,
      );
    });
  });
}
