import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/entities/analise_entity.dart';
import 'package:soloforte/domain/entities/resultado_gesso.dart';
import 'package:soloforte/domain/export/disponibilidade_nutrientes_calculator.dart';
import 'package:soloforte/domain/export/recomendacao_export_context.dart';
import 'package:soloforte/domain/export/recomendacao_html_mapper.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';

void main() {
  group('DisponibilidadeNutrientesCalculator', () {
    test('retorna 6 eixos ordenados para radar', () {
      final eixos = DisponibilidadeNutrientesCalculator.calcular(5.8);
      expect(eixos.length, 6);
      expect(eixos.first.id, 'bases');
      expect(eixos.last.id, 'nsb');
    });

    test('interpola valores de pH 5,8 conforme referencia agronomica', () {
      final eixos = DisponibilidadeNutrientesCalculator.calcular(5.8);
      final byId = {for (final e in eixos) e.id: e.value};

      expect(byId['bases'], closeTo(100, 1));
      expect(byId['p'], closeTo(82, 2));
      expect(byId['micros'], closeTo(71, 2));
      expect(byId['al'], closeTo(18, 2));
      expect(byId['moCl'], closeTo(57, 2));
      expect(byId['nsb'], closeTo(91, 2));
    });
  });

  group('RecomendacaoHtmlMapper', () {
    late RecomendacaoExportContext ctx;

    setUp(() {
      const analise = AnaliseEntity(
        id: 'a1',
        nome: 'Solum',
        consultor: 'Consultor Teste',
        fazenda: 'Fazenda Santa Fe',
        talhao: 'T01',
        localizacao: 'Sorriso / MT',
        cultura: 'Soja',
        ph: 5.8,
        mo: 30,
        p: 5.63,
        k: 0.26,
        ca: 2.97,
        mg: 1.67,
        hAl: 4.3,
        al: 0.1,
        s: 0,
        b: 0,
        cu: 0.1,
        fe: 27.3,
        mn: 22.26,
        zn: 0.56,
        sb: 8.26,
        ctc: 10.58,
        vPercent: 62,
        argila: 35,
        s2040: null,
      );

      final calibracao = CalibracaoProfile(
        id: 'c1',
        nome: 'Calibracao Albrecht + Y',
        cultura: 'Soja',
        safra: '2025/2026',
        cliente: 'Joao da Silva',
        fazenda: 'Fazenda Santa Fe',
        talhao: 'T01',
        observacoes: '',
        parametrosCards: {
          'corretivos': {
            'calcario1': {'caO': 30, 'mgO': 16, 'prnt': 80},
          },
          'fosforo': {'referencia': 'Embrapa Cerrado'},
        },
        createdAt: DateTime(2026, 6, 16),
        updatedAt: DateTime(2026, 6, 16),
      );

      const gesso = ResultadoGesso(
        metodo: MetodoGesso.argilaEmbrapa,
        indicado: false,
        doseKgHa: 0,
        doseTHa: 0,
        sFornecidoKgHa: 0,
        caFornecidoKgHa: 0,
        caAumentoCmolcDm3: 0,
        observacoes: [],
      );

      final micro = const MicroResultado(
        elemento: 'Zn',
        valorAtual: 0.56,
        nc: 0.91,
        dose: 10,
        unidade: 'g/ha',
        deficiente: true,
        via: 'Foliar',
        fonte: 'Fonte',
        doseProduto: 1240,
        doseProdutoLabel: '1,24 kg/ha produto',
      );

      final resultado = ResultadoRecomendacao(
        analise: analise,
        calibracao: calibracao,
        metodoCalagem: 'Saturacao por Bases',
        doseCalcarioTHa: 7.25,
        vEsperado: 139,
        caEsperado: 10.74,
        mgEsperado: 4.91,
        relacaoCaMg: 1.8,
        parcelamento: const [
          'Aplicação 1: 60% = 4.35 t/ha — Marco',
          'Aplicação 2: 40% = 2.90 t/ha — Abril',
        ],
        gesso: gesso,
        modoFosforo: 'Correcao do solo',
        ncFosforo: 4,
        doseP2O5KgHa: 30,
        legacyP: true,
        criterioPotassio: 'Ambos — usar o maior',
        ncPotassio: 46,
        doseK2OKgHa: 137.5,
        relacoesK: const RelacoesK(
          relKMg: 0.15,
          relKCa: 0.09,
          alertas: [],
          kNaCTC: 2.3,
        ),
        micros: [micro],
        grupos: const [],
        avisos: const ['Fosforo acima do NC: aplicado piso de manutencao.'],
        argumentos:
            'A recomendacao cruza a analise selecionada com as regras da calibracao.',
        citacoes: const {
          'calagem': '01 — Calagem: Motor de Calculo',
          'gesso': '01 — Calagem: Motor de Calculo',
          'fosforo': 'Embrapa Cerrado',
          'potassio': 'Embrapa Cerrado',
          'micronutrientes': '06 — Micronutrientes: Motor de Calculo',
          'enxofre': '05 — Enxofre (S): Motor de Calculo',
        },
      );

      ctx = RecomendacaoExportContext(
        resultado: resultado,
        geradaEm: DateTime(2026, 6, 16, 9, 49),
        metadata: const RecomendacaoExportMetadata(
          consultorNome: 'Raudinei Silva Pereira',
          consultorCredencial: 'Eng. Agronomo · CREA-MT',
          laboratorio: 'Solum',
          dataLaudo: null,
        ),
      );
    });

    test('buildBody contem secoes principais e dados-chave', () {
      const mapper = RecomendacaoHtmlMapper();
      final html = mapper.buildBody(ctx);

      expect(html, contains('Qualidade do Solo'));
      expect(html, contains('Disponibilidade de Nutrientes'));
      expect(html, contains('pH do solo'));
      expect(html, contains('5,8'));
      expect(html, contains('<svg class="radar"'));
      expect(html, contains('Bases'));
      expect(html, contains('Micros'));
      expect(html, contains('Calcario'));
      expect(html, contains('7,25'));
      expect(html, contains('Fosforo (P)'));
      expect(html, contains('5,63'));
      expect(html, contains('Potassio (K)'));
      expect(html, contains('0,15'));
      expect(html, contains('Enxofre (S)'));
      expect(html, contains('Micronutrientes'));
      expect(html, contains('Zinco (Zn)'));
      expect(html, contains('Avisos Tecnicos'));
      expect(html, contains('Argumentos Tecnicos'));
      expect(html, contains('piso de manutencao'));
      expect(html, isNot(contains('radar demonstrativo foi omitido')));
      expect(html, isNot(contains('O radar')));
    });

    test('marker micro posicionado na escala NC', () {
      expect(RecomendacaoHtmlMapper.microMarkerPercent(0, 0.05), 0);
      expect(
        RecomendacaoHtmlMapper.microMarkerPercent(0.05, 0.05),
        closeTo(50, 0.1),
      );
      expect(
        RecomendacaoHtmlMapper.microMarkerPercent(0.1, 0.05),
        closeTo(100, 0.1),
      );
    });
  });
}
