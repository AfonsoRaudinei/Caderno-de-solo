import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/entities/analise_entity.dart';
import 'package:soloforte/domain/entities/resultado_gesso.dart';
import 'package:soloforte/domain/export/recomendacao_export_context.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
import 'package:soloforte/features/laboratorio/services/recomendacao_html_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecomendacaoHtmlRenderer', () {
    late RecomendacaoExportContext ctx;

    setUp(() {
      const analise = AnaliseEntity(
        id: 'a1',
        nome: 'Solum',
        consultor: 'Consultor',
        fazenda: 'Fazenda',
        talhao: 'T01',
        localizacao: 'Cidade / UF',
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
      );

      final calibracao = CalibracaoProfile(
        id: 'c1',
        nome: 'Calibracao',
        cultura: 'Soja',
        safra: '2025/2026',
        cliente: 'Produtor',
        fazenda: 'Fazenda',
        talhao: 'T01',
        observacoes: '',
        parametrosCards: const {
          'corretivos': {
            'calcario1': {'caO': 30, 'mgO': 16, 'prnt': 80},
          },
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

      final resultado = ResultadoRecomendacao(
        analise: analise,
        calibracao: calibracao,
        metodoCalagem: 'V%',
        doseCalcarioTHa: 7.25,
        vEsperado: 139,
        caEsperado: 10.74,
        mgEsperado: 4.91,
        relacaoCaMg: 1.8,
        parcelamento: const [],
        gesso: gesso,
        modoFosforo: 'Correcao',
        ncFosforo: 4,
        doseP2O5KgHa: 30,
        legacyP: false,
        criterioPotassio: 'CTC',
        ncPotassio: 46,
        doseK2OKgHa: 137.5,
        relacoesK: const RelacoesK(
          relKMg: 0.15,
          relKCa: 0.09,
          alertas: [],
          kNaCTC: 2.3,
        ),
        micros: const [],
        grupos: const [],
        avisos: const [],
        argumentos: '',
      );

      ctx = RecomendacaoExportContext(
        resultado: resultado,
        geradaEm: DateTime(2026, 6, 16, 9, 49),
        metadata: const RecomendacaoExportMetadata(
          consultorNome: 'Consultor',
          laboratorio: 'Solum',
        ),
      );
    });

    test('render retorna HTML completo com template e corpo', () async {
      const renderer = RecomendacaoHtmlRenderer();
      final html = await renderer.render(ctx);

      expect(html, startsWith('<!DOCTYPE html>'));
      expect(html, contains('<title>Recomendacao · SoloForte</title>'));
      expect(html, contains('Qualidade do Solo'));
      expect(html, contains('Calcario'));
      expect(html, contains('SoloForte · Caderno de Solo'));
      expect(html, isNot(contains('{{BODY}}')));
    });
  });
}
