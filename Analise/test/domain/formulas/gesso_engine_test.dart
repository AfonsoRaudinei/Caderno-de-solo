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
  });
}
