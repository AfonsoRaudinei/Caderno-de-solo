import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/utils/unidade_converter.dart';

void main() {
  group('UnidadeConverter — Cátions', () {
    test('cmolc/dm³ → sem conversão', () {
      expect(UnidadeConverter.normalizarCation(0.08, 'cmolc/dm³'), 0.08);
    });

    test('cmolc (abreviado) → sem conversão', () {
      expect(UnidadeConverter.normalizarCation(0.8, 'cmolc'), 0.8);
    });

    test('mmolc/dm³ → divide por 10', () {
      expect(UnidadeConverter.normalizarCation(0.8, 'mmolc/dm³'), closeTo(0.08, 0.0001));
    });

    test('mmolc (abreviado) → divide por 10', () {
      expect(UnidadeConverter.normalizarCation(8.0, 'mmolc'), closeTo(0.8, 0.0001));
    });

    test('Case-insensitive: MMOLC', () {
      expect(UnidadeConverter.normalizarCation(8.0, 'MMOLC'), closeTo(0.8, 0.0001));
    });

    test('Unidade desconhecida lança ArgumentError', () {
      expect(
        () => UnidadeConverter.normalizarCation(0.8, 'kg/ha'),
        throwsArgumentError,
      );
    });
  });

  group('UnidadeConverter — Matéria Orgânica', () {
    test('% → g/dm³ (multiplica por 10)', () {
      expect(UnidadeConverter.normalizarMO(3.0, '%'), closeTo(30.0, 0.001));
    });

    test('g/kg → g/dm³ (divide por 10)', () {
      expect(UnidadeConverter.normalizarMO(30.0, 'g/kg'), closeTo(3.0, 0.001));
    });

    test('dag/kg → g/dm³ (direto)', () {
      expect(UnidadeConverter.normalizarMO(3.0, 'dag/kg'), closeTo(3.0, 0.001));
    });

    test('g/dm³ → sem conversão', () {
      expect(UnidadeConverter.normalizarMO(28.0, 'g/dm³'), 28.0);
    });
  });

  group('UnidadeConverter — Granulometria', () {
    test('% → sem conversão', () {
      expect(UnidadeConverter.normalizarGranulometria(60.0, '%'), 60.0);
    });

    test('g/kg → % (divide por 10)', () {
      expect(UnidadeConverter.normalizarGranulometria(600.0, 'g/kg'), closeTo(60.0, 0.001));
    });

    test('dag/kg → % (direto)', () {
      expect(UnidadeConverter.normalizarGranulometria(60.0, 'dag/kg'), 60.0);
    });

    test('Soma argila + silte + areia deve ser 100%', () {
      final argila = UnidadeConverter.normalizarGranulometria(600.0, 'g/kg');
      final silte = UnidadeConverter.normalizarGranulometria(200.0, 'g/kg');
      final areia = UnidadeConverter.normalizarGranulometria(200.0, 'g/kg');
      expect(argila + silte + areia, closeTo(100.0, 0.001));
    });
  });

  group('UnidadeConverter — Inferência de K sem unidade', () {
    test('K = 8.0 sem unidade → infere mmolc, converte para 0.8 cmolc', () {
      final result = UnidadeConverter.inferirEConverterK(8.0);
      expect(result.valorNormalizado, closeTo(0.8, 0.0001));
      expect(result.unidadeDetectada, 'mmolc/dm³');
      expect(result.unidadeInferida, isTrue);
      expect(result.aviso, contains('mmolc'));
    });

    test('K = 0.8 sem unidade → infere cmolc, usa direto', () {
      final result = UnidadeConverter.inferirEConverterK(0.8);
      expect(result.valorNormalizado, closeTo(0.8, 0.0001));
      expect(result.unidadeDetectada, 'cmolc/dm³');
      expect(result.unidadeInferida, isTrue);
      expect(result.aviso, contains('cmolc'));
    });

    test('Aviso sempre contém o valor original', () {
      final result = UnidadeConverter.inferirEConverterK(5.5);
      expect(result.aviso, contains('5.5'));
    });
  });

  group('UnidadeConverter — Helper MO para exibição', () {
    test('28 g/dm³ → 2.8%', () {
      expect(UnidadeConverter.moGdm3ParaPercentual(28.0), closeTo(2.8, 0.001));
    });

    test('10 g/dm³ → 1.0%', () {
      expect(UnidadeConverter.moGdm3ParaPercentual(10.0), closeTo(1.0, 0.001));
    });
  });
}