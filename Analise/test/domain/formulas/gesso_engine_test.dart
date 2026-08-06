import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/entities/resultado_gesso.dart';
import 'package:soloforte/domain/formulas/gesso_engine.dart';
import 'package:soloforte/domain/formulas/types/gesso_input.dart';

void main() {
  group('GessoEngine', () {
    test('CASO 1 — Critério ESALQ (Vitti et al., 2004)', () {
      final res = GessoEngine.metodo3VSubCTC(
        vaSub: 21.5,
        ctcSubMmolcDm3: 45.0,
      );
      expect(res.doseTHa, closeTo(2.565, 0.05));
    });

    test('Critério UEPG/Caires - CTCe e Ca', () {
      const diagnostico = DiagnosticoGesso(
        indicado: true,
        caSubBaixo: true,
        alSubAlto: false,
        mSubAlto: false,
        motivos: [],
      );
      final resultado = GessoEngine.metodo4CTCeCa(
        const GessoInput(
          ctcEfetiva: 7.0,
          ca: 2.5,
          metodo: 'Metodo UEPG',
        ),
        diagnostico: diagnostico,
      );

      // NG = (0.6 * 7.0 - 2.5) * 6.4 = (4.2 - 2.5) * 6.4 = 1.7 * 6.4 = 10.88 t/ha
      // doseKgHa = 10880 kg/ha
      expect(resultado.doseKgHa / 1000, closeTo(10.88, 0.01));
    });

    group('metodo2Textura — fronteiras de argila', () {
      test('argila < 15 → 700 kg/ha', () {
        expect(GessoEngine.metodo2Textura(argilaPercent: 14.9).doseKgHa, 700.0);
      });

      test('argila 15 e 35 → 1200 kg/ha', () {
        expect(
            GessoEngine.metodo2Textura(argilaPercent: 15.0).doseKgHa, 1200.0);
        expect(
            GessoEngine.metodo2Textura(argilaPercent: 35.0).doseKgHa, 1200.0);
      });

      test('argila entre 35 e 36 não cai no default muito argiloso', () {
        expect(
            GessoEngine.metodo2Textura(argilaPercent: 35.5).doseKgHa, 2200.0);
      });

      test('argila 36 e 60 → 2200 kg/ha', () {
        expect(
            GessoEngine.metodo2Textura(argilaPercent: 36.0).doseKgHa, 2200.0);
        expect(
            GessoEngine.metodo2Textura(argilaPercent: 60.0).doseKgHa, 2200.0);
      });

      test('argila > 60 → 3200 kg/ha', () {
        expect(
            GessoEngine.metodo2Textura(argilaPercent: 60.1).doseKgHa, 3200.0);
      });
    });

    group('diagnosticar', () {
      test('indica gessagem quando Ca_sub baixo', () {
        final diag = GessoEngine.diagnosticar(
          caSub: 0.4,
          alSub: 0.2,
          mSub: 10.0,
        );
        expect(diag.indicado, isTrue);
        expect(diag.caSubBaixo, isTrue);
      });

      test('não indica quando critérios não são atendidos', () {
        final diag = GessoEngine.diagnosticar(
          caSub: 1.0,
          alSub: 0.2,
          mSub: 10.0,
        );
        expect(diag.indicado, isFalse);
      });
    });
  });
}
