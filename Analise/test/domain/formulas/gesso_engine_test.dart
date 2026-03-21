import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/domain/entities/resultado_gesso.dart';
import 'package:soloforte/domain/formulas/gesso_engine.dart';

void main() {
  group('Diagnóstico de gessagem (20-40 cm)', () {
    test('Indica quando Ca_sub < 0,5', () {
      final d = GessoEngine.diagnosticar(caSub: 0.4, alSub: 0.2, mSub: 10);
      expect(d.indicado, isTrue);
      expect(d.caSubBaixo, isTrue);
    });

    test('Não indica quando nenhum critério é atendido', () {
      final d = GessoEngine.diagnosticar(caSub: 0.8, alSub: 0.2, mSub: 12);
      expect(d.indicado, isFalse);
      expect(d.motivos, isEmpty);
    });
  });

  group('Método ① — Argila (EMBRAPA)', () {
    test('Cultura anual: NG = 50 × argila%', () {
      final r =
          GessoEngine.metodo1Argila(argilaPercent: 40, culturaPerena: false);
      expect(r.metodo, MetodoGesso.argilaEmbrapa);
      expect(r.doseKgHa, 2000);
      expect(r.doseTHa, 2.0);
    });

    test('Cultura perene: NG = 75 × argila%', () {
      final r =
          GessoEngine.metodo1Argila(argilaPercent: 40, culturaPerena: true);
      expect(r.doseKgHa, 3000);
    });
  });

  group('Método ② — Tabela textural (UFLA)', () {
    test('Argila < 15 => 700 kg/ha', () {
      final r = GessoEngine.metodo2Textura(argilaPercent: 10);
      expect(r.doseKgHa, 700);
    });

    test('Argila 50 => 2200 kg/ha', () {
      final r = GessoEngine.metodo2Textura(argilaPercent: 50);
      expect(r.doseKgHa, 2200);
    });
  });

  group('Método ③ — Va_sub e CTC_sub (ESALQ)', () {
    test('Aplica fórmula corretamente', () {
      // ((50-20)*80)/500 = 4.8 t/ha = 4800 kg/ha
      final r = GessoEngine.metodo3VSubCTC(vaSub: 20, ctcSubMmolcDm3: 80);
      expect(r.doseTHa, closeTo(4.8, 0.001));
      expect(r.doseKgHa, closeTo(4800, 0.1));
    });

    test('Resultado negativo retorna 0', () {
      final r = GessoEngine.metodo3VSubCTC(vaSub: 60, ctcSubMmolcDm3: 80);
      expect(r.doseKgHa, 0);
    });
  });

  group('Método ④ — CTCe_sub e Ca_sub (UEPG)', () {
    test('Aplica fórmula corretamente', () {
      // (0.60*8 - 1.0) * 6.4 = 24.32 t/ha
      final r = GessoEngine.metodo4CTCeCa(
        ctcESubCmolcDm3: 8,
        caSubCmolcDm3: 1.0,
      );
      expect(r.doseTHa, closeTo(24.32, 0.01));
    });

    test('Resultado negativo vira zero', () {
      final r = GessoEngine.metodo4CTCeCa(
        ctcESubCmolcDm3: 2.0,
        caSubCmolcDm3: 2.0,
      );
      expect(r.doseKgHa, 0);
    });
  });

  group('Fórmulas especiais', () {
    test('Solo sódico calcula NG em kg/ha', () {
      final r = GessoEngine.soloSodico(
        pstInicial: 20,
        pstFinal: 10,
        ctcMmolcDm3: 80,
        profundidadeCm: 20,
        densidadeSolo: 1.2,
      );
      expect(r.metodo, MetodoGesso.sodico);
      expect(r.doseKgHa, closeTo(16512, 0.1));
    });

    test('Excesso de K calcula NG em kg/ha', () {
      final r = GessoEngine.excessoPotassio(
        pskAtual: 8,
        pskDesejado: 4,
        ctcMmolcDm3: 70,
        profundidadeCm: 20,
        densidadeSolo: 1.3,
      );
      expect(r.metodo, MetodoGesso.excessoPotassio);
      expect(r.doseKgHa, closeTo(6260.8, 0.1));
    });
  });

  group('Saídas adicionais (S, Ca, alertas)', () {
    test('1 t/ha fornece 150 kg S e 200 kg Ca', () {
      final r = GessoEngine.metodo2Textura(argilaPercent: 10); // 700 kg/ha
      expect(r.sFornecidoKgHa, closeTo(105.0, 0.001));
      expect(r.caFornecidoKgHa, closeTo(140.0, 0.001));
    });

    test('Dose > 500 kg/ha adiciona alerta de Mo/B', () {
      final r =
          GessoEngine.metodo1Argila(argilaPercent: 20, culturaPerena: false);
      expect(r.observacoes.any((o) => o.contains('Mo')), isTrue);
      expect(r.observacoes.any((o) => o.contains('B')), isTrue);
    });
  });
}
