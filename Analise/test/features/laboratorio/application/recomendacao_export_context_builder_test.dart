import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/entities/analise_entity.dart';
import 'package:soloforte/domain/entities/resultado_gesso.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/config/domain/entities/user_profile_data.dart';
import 'package:soloforte/features/laboratorio/application/recomendacao_export_context_builder.dart';

void main() {
  group('RecomendacaoExportContextBuilder', () {
    test('parseia data de laudo em formato BR', () {
      final analise = AnaliseSolo(
        id: 'a1',
        fazenda: 'Fazenda',
        produtor: 'Produtor',
        talhao: 'T01',
        numeroAmostra: '1',
        cultura: Cultura.soja,
        safra: '2025/26',
        laboratorio: 'Solum',
        dataCadastro: DateTime(2026, 1, 1),
        profundidade: '0-20',
        dataEmissao: '16/06/2026',
      );

      final ctx = RecomendacaoExportContextBuilder.parseDataLaudo(analise);
      expect(ctx?.year, 2026);
      expect(ctx?.month, 6);
      expect(ctx?.day, 16);
    });

    test('monta metadata com perfil e laboratorio', () async {
      const analise = AnaliseEntity(
        id: 'a1',
        nome: 'Lab',
        consultor: 'Consultor',
        fazenda: 'Fazenda',
        talhao: 'T01',
        localizacao: 'Cidade / UF',
        cultura: 'Soja',
        ph: 5.8,
        mo: 30,
        p: 5,
        k: 0.2,
        ca: 2,
        mg: 1,
        hAl: 3,
        al: 0.1,
        s: 5,
        b: 0.2,
        cu: 0.5,
        fe: 20,
        mn: 5,
        zn: 1,
        sb: 3,
        ctc: 6,
        vPercent: 50,
        argila: 35,
      );

      final calibracao = CalibracaoProfile(
        id: 'c1',
        nome: 'Calib',
        cultura: 'Soja',
        safra: '2025/26',
        cliente: 'Cliente',
        fazenda: 'Fazenda',
        talhao: 'T01',
        observacoes: '',
        parametrosCards: const {},
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
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
        doseCalcarioTHa: 0,
        vEsperado: 70,
        caEsperado: 5,
        mgEsperado: 2,
        relacaoCaMg: 2,
        parcelamento: const [],
        gesso: gesso,
        modoFosforo: 'Correcao',
        ncFosforo: 4,
        doseP2O5KgHa: 0,
        legacyP: false,
        criterioPotassio: 'CTC',
        ncPotassio: 0.3,
        doseK2OKgHa: 0,
        relacoesK: const RelacoesK(
          relKMg: 0,
          relKCa: 0,
          alertas: [],
          kNaCTC: 0,
        ),
        micros: const [],
        grupos: const [],
        avisos: const [],
        argumentos: '',
      );

      final ctx = await const RecomendacaoExportContextBuilder().build(
        resultado: resultado,
        analiseSolo: AnaliseSolo(
          id: 'a1',
          fazenda: 'Fazenda',
          produtor: 'Cliente',
          talhao: 'T01',
          numeroAmostra: '1',
          cultura: Cultura.soja,
          safra: '2025/26',
          laboratorio: 'Solum',
          dataCadastro: DateTime(2026, 6, 16),
          profundidade: '0-20',
        ),
        perfil: const UserProfileData(
          nome: 'Eng. Teste',
          email: 'teste@teste.com',
          tipoPerfil: 'Eng. Agronomo',
          empresa: 'CREA-MT',
        ),
      );

      expect(ctx.metadata.consultorNome, 'Eng. Teste');
      expect(ctx.metadata.laboratorio, 'Solum');
      expect(ctx.metadata.consultorCredencial, contains('CREA-MT'));
    });
  });
}
