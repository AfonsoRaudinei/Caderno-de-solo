import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/entities/analise_entity.dart';
import 'package:soloforte/domain/models/micronutrientes_calibracao.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
import 'package:soloforte/features/laboratorio/application/providers/calibracao_controller.dart';

void main() {
  group('Micronutrientes — grupos de aplicação', () {
    test('1) criação de grupo', () {
      final grupo = novoGrupoAplicacao(id: 'g1', indice: 1, via: 'Foliar');
      expect(grupo['id'], 'g1');
      expect(grupo['nome'], 'Grupo 1');
      expect(grupo['via'], 'Foliar');
      expect(grupo['elementos'], isEmpty);
      expect(grupo['eficienciaFoliar'], 70.0);
      expect(grupo['fonteFoliar'], isNotEmpty);
    });

    test('2) seleção de elementos sem duplicata no mesmo grupo', () {
      final migrado = migrateGrupoAplicacao({
        'id': 'g1',
        'nome': 'Mistura foliar vegetativa',
        'via': 'Foliar',
        'elementos': ['B', 'Mn', 'Zn', 'B'],
      }, indice: 1);

      expect(migrado['elementos'], ['B', 'Mn', 'Zn']);
    });

    test('3) exibição apenas dos elementos selecionados', () {
      final micros = migrateMicrosParametros({
        'grupos': [
          {
            'id': 'g1',
            'nome': 'Grupo foliar',
            'via': 'Foliar',
            'elementos': ['B', 'Mn'],
          },
        ],
      });
      final grupos = gruposFromMicros(micros);
      final selecionados = List<String>.from(grupos.first['elementos'] as List);
      expect(selecionados, ['B', 'Mn']);
      expect(selecionados.contains('Zn'), isFalse);

      final emGrupos = elementosEmGrupos(grupos);
      expect(emGrupos, {'B', 'Mn'});
      final individuais =
          kElementosMicros.where((e) => !emGrupos.contains(e)).toList();
      expect(individuais.contains('B'), isFalse);
      expect(individuais.contains('Zn'), isTrue);
    });

    test('4) persistência do nível crítico por elemento', () {
      final micros = migrateMicrosParametros({
        'elementos': {
          'B': {'ncSolo': 0.90, 'referencia': 'EMBRAPA Soja'},
          'Mn': {'ncSolo': 6.5},
        },
        'grupos': [
          {
            'id': 'g1',
            'nome': 'Grupo',
            'via': 'Solo',
            'elementos': ['B', 'Mn'],
          },
        ],
      });

      final elementos = micros['elementos'] as Map<String, dynamic>;
      final b = elementos['B'] as Map<String, dynamic>;
      final mn = elementos['Mn'] as Map<String, dynamic>;

      expect(b['ncSolo'], 0.90);
      expect(mn['ncSolo'], 6.5);
      expect(b['referenciaNc'], 'EMBRAPA Soja');
      expect(b['ncSolo'] == mn['ncSolo'], isFalse);
    });

    test('5) exibição visível do nível crítico', () {
      final el = defaultElementoMicro('B');
      el['ncSolo'] = 0.90;
      final texto = formatNivelCriticoVisivel(el);
      expect(texto, contains('0,90'));
      expect(texto, contains('mg/dm³'));
      expect(nomeElementoMicro('B'), 'Boro');
    });

    test('6) mudança de via mostra campos específicos', () {
      final foliar = migrateGrupoAplicacao({
        'id': 'g1',
        'nome': 'Foliar',
        'via': 'Foliar',
        'produto': 'Mistura A',
        'eficiencia': 80,
      }, indice: 1);
      expect(fonteDoGrupo(foliar), 'Mistura A');
      expect(eficienciaDoGrupo(foliar), 80);

      final solo = migrateGrupoAplicacao({
        ...foliar,
        'via': 'Solo',
        'fonteSolo': 'Ulexita mix',
        'eficienciaSolo': 55,
      }, indice: 1);
      expect(fonteDoGrupo(solo), 'Ulexita mix');
      expect(eficienciaDoGrupo(solo), 55);

      final ts = migrateGrupoAplicacao({
        'id': 'g1',
        'via': 'TS',
        'fonteTs': 'TS Premium',
        'eficienciaTs': 90,
      }, indice: 1);
      expect(fonteDoGrupo(ts), 'TS Premium');
      expect(eficienciaDoGrupo(ts), 90);
    });

    test('7) eficiência específica por via', () {
      final grupo = migrateGrupoAplicacao({
        'id': 'g1',
        'via': 'Foliar',
        'eficienciaFoliar': 85,
        'eficienciaSolo': 40,
        'eficienciaTs': 95,
      }, indice: 1);

      expect(eficienciaDoGrupo({...grupo, 'via': 'Foliar'}), 85);
      expect(eficienciaDoGrupo({...grupo, 'via': 'Solo'}), 40);
      expect(eficienciaDoGrupo({...grupo, 'via': 'TS'}), 95);
    });

    test('8) edição e exclusão de grupo', () {
      var micros = migrateMicrosParametros({
        'grupos': [
          novoGrupoAplicacao(id: 'g1', indice: 1),
          novoGrupoAplicacao(id: 'g2', indice: 2, via: 'Solo'),
        ],
      });

      var grupos = gruposFromMicros(micros);
      expect(grupos, hasLength(2));

      grupos[0] = migrateGrupoAplicacao({
        ...grupos[0],
        'nome': 'Mistura foliar vegetativa',
        'elementos': ['B', 'Mn', 'Zn'],
      }, indice: 1);
      micros = migrateMicrosParametros({...micros, 'grupos': grupos});
      expect(
          gruposFromMicros(micros).first['nome'], 'Mistura foliar vegetativa');

      grupos = [...gruposFromMicros(micros)]..removeAt(0);
      micros = migrateMicrosParametros({...micros, 'grupos': grupos});
      expect(gruposFromMicros(micros), hasLength(1));
      expect(gruposFromMicros(micros).first['id'], 'g2');
    });

    test('8b) duplicação de grupo', () {
      final original = novoGrupoAplicacao(id: 'g1', indice: 1);
      original['elementos'] = ['B', 'Cu'];
      original['nome'] = 'Correção de micronutrientes';
      final copia = duplicarGrupoAplicacao(original, novoId: 'g2');
      expect(copia['id'], 'g2');
      expect(copia['nome'], contains('cópia'));
      expect(copia['elementos'], ['B', 'Cu']);
    });

    test('9) carregamento de calibração salva', () {
      final salvo = CalibracaoController.defaultMicros();
      final grupos = [
        {
          'id': 'grupo-foliares',
          'nome': 'Mistura foliar vegetativa',
          'via': 'Foliar',
          'elementos': ['B', 'Mn', 'Zn'],
          'produto': 'Mistura foliar',
          'eficiencia': 90.0,
        },
        {
          'id': 'grupo-solo',
          'nome': 'Correção de micronutrientes',
          'via': 'Solo',
          'elementos': ['B', 'Cu'],
          'produto': 'Fonte solo',
          'eficiencia': 60.0,
        },
      ];
      final carregado = migrateMicrosParametros({
        ...salvo,
        'grupos': grupos,
      });

      expect(carregado['schemaVersion'], kMicrosSchemaVersion);
      final g = gruposFromMicros(carregado);
      expect(g, hasLength(2));
      expect(g[0]['eficienciaFoliar'], 90.0);
      expect(g[1]['eficienciaSolo'], 60.0);
      expect(g[0]['fonteFoliar'], 'Mistura foliar');
      expect(g[1]['fonteSolo'], 'Fonte solo');
    });

    test('10) validações dos campos', () {
      final invalid = migrateMicrosParametros({
        'grupos': [
          {
            'id': 'g1',
            'nome': '',
            'via': 'Foliar',
            'elementos': <String>[],
            'eficienciaFoliar': 0,
          },
        ],
        'elementos': {
          'B': {
            'ncSolo': -1,
            'extracaoGt': -2,
            'exportacaoGt': -3,
            'doseMin': 10,
            'doseMax': 5,
          },
        },
      });

      // Sem elementos: falha antes de validar o elemento
      final semElementos = validateMicrosParametros(invalid);
      expect(semElementos.isValid, isFalse);
      expect(semElementos.errors, isNotEmpty);
      expect(semElementos.fieldErrors.containsKey('grupo:g1:nome'), isTrue);
      expect(
          semElementos.fieldErrors.containsKey('grupo:g1:elementos'), isTrue);

      final comElementoInvalido = migrateMicrosParametros({
        'grupos': [
          {
            'id': 'g1',
            'nome': 'OK',
            'via': 'Foliar',
            'elementos': ['B'],
            'eficienciaFoliar': 150,
          },
        ],
        'elementos': {
          'B': {
            'ncSolo': -1,
            'extracaoGt': -2,
            'exportacaoGt': -3,
            'doseMin': 10,
            'doseMax': 5,
          },
        },
      });
      final result = validateMicrosParametros(comElementoInvalido);
      expect(result.isValid, isFalse);
      expect(result.fieldErrors['grupo:g1:eficienciaFoliar'], isNotNull);
      expect(result.fieldErrors['elemento:B:ncSolo'], isNotNull);
      expect(result.fieldErrors['elemento:B:doseMin'], isNotNull);

      final ok = migrateMicrosParametros({
        'grupos': [
          {
            'id': 'g1',
            'nome': 'Mistura foliar vegetativa',
            'via': 'Foliar',
            'elementos': ['B', 'Mn', 'Zn'],
            'eficienciaFoliar': 80,
          },
        ],
      });
      final okResult = validateMicrosParametros(ok);
      expect(
        okResult.isValid,
        isTrue,
        reason: '${okResult.errors} | ${okResult.fieldErrors}',
      );
    });

    test('11) compatibilidade com registros antigos', () {
      final legado = {
        'elementos': {
          'B': {
            'simbolo': 'B',
            'ncSolo': 1.0,
            'referencia': 'EMBRAPA Soja',
            'viaAplicacao': 'Ambas',
            'teorFonteFoliar': 0.5,
            'eficienciaFoliar': 80.0,
          },
        },
        'grupos': [
          {
            'id': 'grupo-foliares',
            'nome': 'foliares',
            'via': 'Foliar',
            'elementos': ['B', 'Cu'],
            'produto': 'carbonatos e fontes nobres',
            'eficiencia': 90.0,
            'referenciaNome': 'EMBRAPA Soja',
          },
        ],
      };

      final migrado = migrateMicrosParametros(legado);
      expect(migrado['schemaVersion'], kMicrosSchemaVersion);

      final grupo = gruposFromMicros(migrado).first;
      expect(grupo['referenciaNcNome'], 'EMBRAPA Soja');
      expect(grupo['eficienciaFoliar'], 90.0);
      expect(grupo['fonteFoliar'], 'carbonatos e fontes nobres');

      final b = (migrado['elementos'] as Map)['B'] as Map;
      expect(b['referenciaNc'], 'EMBRAPA Soja');
      expect(b['ncUnidade'], 'mg/dm³');
      expect(b.containsKey('extracaoGt'), isTrue);
      expect(b.containsKey('concentracao'), isTrue);
      expect(b.containsKey('viasPermitidas'), isTrue);
    });

    test('grupos geram recomendações independentes no engine', () {
      const engine = RecomendacaoEngine();
      const analise = AnaliseEntity(
        id: 'a1',
        nome: 'A1',
        consultor: 'Teste',
        fazenda: 'F1',
        talhao: 'T1',
        localizacao: '',
        cultura: 'Soja',
        ph: 5.5,
        mo: 2.0,
        p: 10,
        k: 0.2,
        ca: 2.0,
        mg: 0.8,
        hAl: 4.0,
        al: 0.2,
        s: 8,
        b: 0.1,
        cu: 0.2,
        fe: 20,
        mn: 2,
        zn: 0.3,
        sb: 3.0,
        ctc: 8,
        vPercent: 40,
        argila: 35,
      );

      final b = defaultElementoMicro('B');
      b['ncSolo'] = 0.9;
      b['doseElementoFoliar'] = 100;
      b['concentracao'] = 10;
      b['teorFonteFoliar'] = 10;
      b['teorFonteSolo'] = 10;

      final mn = defaultElementoMicro('Mn');
      mn['ncSolo'] = 8;
      mn['doseElementoFoliar'] = 200;
      mn['concentracao'] = 20;
      mn['teorFonteFoliar'] = 20;

      final cu = defaultElementoMicro('Cu');
      cu['ncSolo'] = 1.0;
      cu['doseElementoFoliar'] = 50;
      cu['concentracao'] = 25;
      cu['teorFonteSolo'] = 25;

      final micros = migrateMicrosParametros({
        'elementos': {
          'B': b,
          'Mn': mn,
          'Cu': cu,
        },
        'grupos': [
          {
            'id': 'g1',
            'nome': 'Mistura foliar vegetativa',
            'via': 'Foliar',
            'elementos': ['B', 'Mn'],
            'eficienciaFoliar': 80,
            'fonteFoliar': 'Foliar Mix',
          },
          {
            'id': 'g2',
            'nome': 'Correção de micronutrientes',
            'via': 'Solo',
            'elementos': ['B', 'Cu'],
            'eficienciaSolo': 50,
            'fonteSolo': 'Solo Mix',
          },
        ],
      });

      final grupos = engine.calcularGrupos(
        grupos: gruposFromMicros(micros),
        microsConfig: micros,
        analise: analise,
      );

      expect(grupos, hasLength(2));
      expect(grupos[0].nomeGrupo, 'Mistura foliar vegetativa');
      expect(grupos[0].via, 'Foliar');
      expect(grupos[0].produto, 'Foliar Mix');
      expect(
        grupos[0].micros.map((m) => m.elemento).toSet(),
        {'B', 'Mn'},
      );

      expect(grupos[1].nomeGrupo, 'Correção de micronutrientes');
      expect(grupos[1].via, 'Solo');
      expect(grupos[1].produto, 'Solo Mix');
      expect(
        grupos[1].micros.map((m) => m.elemento).toSet(),
        {'B', 'Cu'},
      );

      final bFoliar = grupos[0].micros.firstWhere((m) => m.elemento == 'B');
      final bSolo = grupos[1].micros.firstWhere((m) => m.elemento == 'B');
      expect(bFoliar.via, 'Foliar');
      expect(bSolo.via, 'Solo');
      expect(bFoliar.fonte, 'Foliar Mix');
      expect(bSolo.fonte, 'Solo Mix');
    });
  });
}
