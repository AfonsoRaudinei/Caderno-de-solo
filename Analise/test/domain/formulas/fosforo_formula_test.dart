import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/fosforo_formula.dart';
import 'package:soloforte/domain/models/analise_model.dart';

void main() {
  group('FosforoFormula - Nível Crítico e Recomendação', () {
    group('Nível Crítico Mehlich-1', () {
      test('Deve retornar nível crítico de 25 para solo muito argiloso (> 60%)',
          () {
        expect(FosforoFormula.nivelCriticoMehlich1(65.0), 25.0);
      });

      test('Deve retornar nível crítico de 18 para solo argiloso (36% a 60%)',
          () {
        expect(FosforoFormula.nivelCriticoMehlich1(45.0), 18.0);
      });

      test(
          'Deve retornar nível crítico de 12 para solo textura média (15% a 35%)',
          () {
        expect(FosforoFormula.nivelCriticoMehlich1(20.0), 12.0);
      });
    });

    group('Nível Crítico Resina', () {
      test('Deve retornar 40 para muito argiloso', () {
        expect(FosforoFormula.nivelCriticoResina(65.0), 40.0);
      });

      test('Deve retornar 20 para textura média', () {
        expect(FosforoFormula.nivelCriticoResina(20.0), 20.0);
      });
    });

    group('Recomendação de Adubação', () {
      test('Deve calcular recomendação Modo 1 quando P atual é menor que NC',
          () {
        const fosforo = FosforoData(
          pMehlich: 5.0,
          fontePrincipal: FonteP.mehlich,
        );
        final dose = FosforoFormula.recomendacao(
          fosforo,
          18.0,
          argilaPercent: 40.0, // argiloso: fator 4, FEP 15
        );
        // deficit=13; dose_base=13*4=52; dose_final=52/0.15=346.67
        expect(dose, closeTo(346.67, 0.01));
      });

      test(
          'Não deve recomendar P quando o nível atual já atingiu ou superou o crítico',
          () {
        const fosforo = FosforoData(
          pResina: 20.0,
          fontePrincipal: FonteP.resina,
        );
        final dose = FosforoFormula.recomendacao(
          fosforo,
          12.0,
          argilaPercent: 10.0,
        );
        expect(dose, 0.0);
      });

      test(
          'Deve aplicar fallback automático para a outra fonte quando principal não existe',
          () {
        const fosforo = FosforoData(
          pMehlich: 6.0,
          fontePrincipal: FonteP.resina,
        );
        final dose = FosforoFormula.recomendacao(
          fosforo,
          20.0,
          argilaPercent: 20.0, // médio: fator 3, FEP 20
        );
        // deficit=14; dose_base=42; dose_final=210
        expect(dose, 210.0);
      });

      test('Ajusta FEP por modo de aplicação (sulco)', () {
        final fep = FosforoFormula.ajustarFepPorModo(
          fepBase: 20.0,
          modoAplicacao: 'sulco',
        );
        expect(fep, 30.0);
      });

      test('Modo 2 — extração calcula dose final corretamente', () {
        final dose = FosforoFormula.recomendacaoExtracao(
          pSolo: 10.0,
          percentualUsoSolo: 50.0,
          profundidadeCm: 20.0,
          extracaoP2O5: 70.0,
          fepFinal: 30.0,
        );
        // pSoloUsado=5; pSoloKg=5*2*1*2.291=22.91
        // doseBase=47.09; doseFinal=156.97
        expect(dose, closeTo(156.97, 0.01));
      });

      test('Legacy P retorna flag e dose mínima quando P_solo > NC', () {
        final r = FosforoFormula.avaliarLegacyP(
          pSolo: 25.0,
          nivelCritico: 20.0,
          exportacaoGrao: 70.0,
        );
        expect(r.legacyP, isTrue);
        expect(r.doseMinima, 21.0);
      });
    });
  });
}
