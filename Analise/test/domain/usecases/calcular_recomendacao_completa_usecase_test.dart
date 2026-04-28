import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/entities/analise_completa.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/models/diagnostico_recomendacao.dart';
import 'package:soloforte/domain/usecases/calcular_recomendacao_completa_usecase.dart';
import 'package:soloforte/domain/value_objects/valor_nutriente.dart';
import 'package:soloforte/features/config/domain/entities/tabela_metricas_defaults.dart';

void main() {
  const usecase = CalcularRecomendacaoCompletaUsecase();

  group('CalcularRecomendacaoCompletaUsecase - diagnóstico agronômico', () {
    test('classifica fósforo baixo e associa ação de P2O5', () {
      final result = usecase.execute(
        analise: _analise(pResina: 8, k: 0.25),
        calibracao: _calibracao(),
        tabelas: _tabelas(),
      );

      expect(result.recomendacao, isNotNull);
      final diagnostico = result.diagnostico.diagnosticos['fosforo'];
      expect(diagnostico, isNotNull);
      expect(diagnostico!.status, DiagnosticoStatus.baixo);
      expect(
        diagnostico.mensagemTecnica,
        contains('Fósforo abaixo do nível crítico'),
      );
      expect(diagnostico.recomendacao, contains('Aplicar P2O5'));
      expect(result.recomendacao!.doseP2O5KgHa, greaterThan(0));
    });

    test('classifica fósforo adequado sem recomendar correção', () {
      final result = usecase.execute(
        analise: _analise(pResina: 32, k: 0.25),
        calibracao: _calibracao(),
        tabelas: _tabelas(),
      );

      final diagnostico = result.diagnostico.diagnosticos['fosforo'];
      expect(diagnostico, isNotNull);
      expect(diagnostico!.status, DiagnosticoStatus.adequado);
      expect(diagnostico.mensagemTecnica, contains('faixa adequada'));
      expect(diagnostico.recomendacao, contains('Manter reposição'));
    });

    test('classifica potássio baixo e associa ação de K2O', () {
      final result = usecase.execute(
        analise: _analise(pResina: 32, k: 0.10),
        calibracao: _calibracao(),
        tabelas: _tabelas(),
      );

      expect(result.recomendacao, isNotNull);
      final diagnostico = result.diagnostico.diagnosticos['potassio'];
      expect(diagnostico, isNotNull);
      expect(diagnostico!.status, DiagnosticoStatus.baixo);
      expect(
        diagnostico.mensagemTecnica,
        contains('Potássio abaixo do nível crítico'),
      );
      expect(diagnostico.recomendacao, contains('Aplicar K2O'));
      expect(result.recomendacao!.doseK2OKgHa, greaterThan(0));
    });
  });
}

List<Map<String, dynamic>> _tabelas() {
  return TabelaMetricasDefaults.build()
      .map((tabela) => tabela.toJson())
      .toList(growable: false);
}

CalibracaoProfile _calibracao() {
  return CalibracaoProfile(
    id: 'c-1',
    nome: 'Perfil diagnóstico',
    cultura: 'Soja',
    safra: '25/26',
    cliente: 'Cliente',
    fazenda: 'Fazenda',
    talhao: 'Talhão',
    observacoes: '',
    parametrosCards: {
      'corretivos': {
        'metodoCalagem': '① Saturação por Bases (V%)',
        'v2': 60.0,
        'calcario1': {'prnt': 80.0, 'caO': 30.0, 'mgO': 16.0},
        'gesso': {'usarGesso': false},
      },
      'fosforo': {
        'modoCalculo': '① Correção do solo',
        'referencia': 'IAC Bol.100',
      },
      'potassio': {
        'modoCalculo': '① Correção do solo',
        'criterioNc': '% K na CTC',
        'ncPctCtc': 4.0,
        'modoAplicacao': 'Lanço',
      },
      'micros': {},
    },
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

AnaliseCompleta _analise({
  required double pResina,
  required double k,
}) {
  return AnaliseCompleta(
    id: 'a-1',
    fazenda: 'Fazenda',
    produtor: 'Produtor',
    talhao: 'Talhão',
    cultura: 'Soja',
    laboratorio: 'Lab',
    dataCadastro: DateTime(2026, 4, 1),
    extratorP: ExtratorP.resina,
    phAgua: _v(5.4),
    phSmp: _na(),
    phCaCl2: _na(),
    materiaOrganica: _v(3.0),
    argila: _v(35.0),
    pMehlich: _na(),
    pResina: _v(pResina),
    pRem: _na(),
    k: _v(k),
    ca: _v(2.3),
    mg: _v(0.9),
    al: _v(0.1),
    hAl: _v(4.0),
    na: _v(0.0),
    s020: _v(8.0),
    s2040: _na(),
    b: _v(0.35),
    cu: _v(0.8),
    fe: _v(35.0),
    mn: _v(5.0),
    zn: _v(1.2),
    ni: _na(),
    mo: _na(),
    se: _na(),
    co: _na(),
  );
}

ValorNutriente _v(double value) {
  return ValorNutriente(valor: value, analisado: true);
}

ValorNutriente _na() {
  return const ValorNutriente(valor: null, analisado: false);
}
