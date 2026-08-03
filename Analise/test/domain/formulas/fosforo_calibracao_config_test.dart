import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/fosforo_calibracao_config.dart';

void main() {
  group('FosforoCalibracaoConfig.fromMap', () {
    test('calibração antiga só com modoCalculo correção', () {
      final config = FosforoCalibracaoConfig.fromMap({
        'modoCalculo': '① Correção do solo',
        'percentualUsoPSolo': 50.0,
      });

      expect(config.correcaoSoloAtiva, isTrue);
      expect(config.modoReposicao, ModoReposicaoP.semReposicao);
      expect(config.ajusteEficienciaSolo, 0.0);
      expect(config.percentualUsoPSolo, 50.0);
    });

    test('calibração antiga com extração via modoCalculo', () {
      final config = FosforoCalibracaoConfig.fromMap({
        'modoCalculo': '② Extração',
        'percentualUsoPSolo': 80.0,
      });

      expect(config.correcaoSoloAtiva, isFalse);
      expect(config.modoReposicao, ModoReposicaoP.extracao);
    });

    test('calibração antiga exportação via tipoDadoCultivar', () {
      final config = FosforoCalibracaoConfig.fromMap({
        'modoCalculo': 'Manutenção',
        'tipoDadoCultivar': 'Exportação',
        'fosforoModoAbsorcao': 'exportacao',
      });

      expect(config.modoReposicao, ModoReposicaoP.exportacao);
    });

    test('calibração nova com campos explícitos', () {
      final config = FosforoCalibracaoConfig.fromMap({
        'correcaoSoloAtiva': true,
        'modoReposicao': 'Extração',
        'ajusteEficienciaSolo': 50.0,
        'percentualUsoPSolo': 25.0,
      });

      expect(config.correcaoSoloAtiva, isTrue);
      expect(config.modoReposicao, ModoReposicaoP.extracao);
      expect(config.ajusteEficienciaSolo, 50.0);
      expect(config.percentualUsoPSolo, 25.0);
    });

    test('ajuste acima de 100 é limitado na leitura', () {
      final config = FosforoCalibracaoConfig.fromMap({
        'ajusteEficienciaSolo': 150.0,
      });
      expect(config.ajusteEficienciaSolo, 100.0);
    });
  });

  group('validarPercentualFosforo', () {
    test('aceita 0 e 100', () {
      expect(validarPercentualFosforo(0), isNull);
      expect(validarPercentualFosforo(100), isNull);
    });

    test('rejeita abaixo de 0 e acima de 100', () {
      expect(validarPercentualFosforo(-1), isNotNull);
      expect(validarPercentualFosforo(101), isNotNull);
    });
  });
}
