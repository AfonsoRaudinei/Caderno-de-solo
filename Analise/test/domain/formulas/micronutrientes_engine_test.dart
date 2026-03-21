import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/formulas/micronutrientes_engine.dart';

void main() {
  group('MicronutrientesEngine', () {
    test('classificar B muito baixo', () {
      final c = MicronutrientesEngine.classificar(ElementoMicro.B, 0.10);
      expect(c, ClasseMicro.muitoBaixo);
    });

    test('classificar Zn alto', () {
      final c = MicronutrientesEngine.classificar(ElementoMicro.Zn, 2.0);
      expect(c, ClasseMicro.alto);
    });

    test('fronteira B: 0.20 = muitoBaixo; 0.21 = baixo', () {
      final c020 = MicronutrientesEngine.classificar(ElementoMicro.B, 0.20);
      final c021 = MicronutrientesEngine.classificar(ElementoMicro.B, 0.21);
      expect(c020, ClasseMicro.muitoBaixo);
      expect(c021, ClasseMicro.baixo);
    });

    test('fronteira Fe: 8 = muitoBaixo; 9 = baixo', () {
      final c8 = MicronutrientesEngine.classificar(ElementoMicro.Fe, 8.0);
      final c9 = MicronutrientesEngine.classificar(ElementoMicro.Fe, 9.0);
      expect(c8, ClasseMicro.muitoBaixo);
      expect(c9, ClasseMicro.baixo);
    });

    test('via solo calcula dose do produto', () {
      final r = MicronutrientesEngine.calcularViaSolo(
        elemento: ElementoMicro.B,
        teorSolo: 0.10,
        percentualCorrecao: 100.0,
        teorFonte: 10.0,
        eficiencia: 50.0,
      );
      // NC(B)=0.60 -> deficit=0.50
      // dose_elem_g = 0.5*2*1000 = 1000
      // dose_prod = 1000/(0.1*0.5*1000)=20 kg/ha
      expect(r.doseProduto, closeTo(20.0, 0.001));
      expect(r.unidade, 'kg/ha');
    });

    test('via foliar calcula dose do produto', () {
      final r = MicronutrientesEngine.calcularViaFoliar(
        elemento: ElementoMicro.Zn,
        teorSolo: 0.5,
        doseElemento: 200.0,
        teorFonte: 20.0,
        eficienciaFoliar: 80.0,
      );
      // 200/(0.2*0.8)=1250 g/ha
      expect(r.doseProduto, closeTo(1250.0, 0.001));
      expect(r.unidade, 'g/ha');
    });

    test('via grupo usa maior dose entre elementos', () {
      final r = MicronutrientesEngine.calcularViaGrupo(
        doseElementoPorElemento: const {
          ElementoMicro.B: 150.0,
          ElementoMicro.Zn: 300.0,
        },
        teorNoProdutoPorElemento: const {
          ElementoMicro.B: 5.0,
          ElementoMicro.Zn: 10.0,
        },
        eficienciaGrupo: 80.0,
      );
      // B: 150/(0.05*0.8)=3750
      // Zn:300/(0.10*0.8)=3750
      expect(r.doseProduto, closeTo(3750.0, 0.001));
      expect(r.unidade, 'g/ha');
    });
  });
}
