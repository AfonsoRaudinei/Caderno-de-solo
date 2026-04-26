import 'package:soloforte/domain/entities/resultado_gesso.dart';
import 'package:soloforte/domain/formulas/conversoes.dart';
import 'package:soloforte/domain/formulas/types/gesso_input.dart';

/// Motor de cálculo de gesso agrícola (02_gesso.md)
/// Referências: EMBRAPA, UFLA, ESALQ, UEPG, Fancelli.
class GessoEngine {
  GessoEngine._();

  static const double _sTeor = 0.15;
  static const double _caTeor = 0.20;
  static const double _caCmolcPorTHa = 0.5;

  /// Diagnóstico (camada 20–40 cm):
  /// - Ca_sub < 0,5 cmolc/dm³
  /// - Al_sub > 0,5 cmolc/dm³
  /// - m%_sub > 25%
  static DiagnosticoGesso diagnosticar({
    required double caSub,
    required double alSub,
    required double mSub,
  }) {
    final caSubBaixo = caSub < 0.5;
    final alSubAlto = alSub > 0.5;
    final mSubAlto = mSub > 25.0;

    final motivos = <String>[];
    if (caSubBaixo) motivos.add('Ca_sub < 0,5 cmolc/dm³');
    if (alSubAlto) motivos.add('Al_sub > 0,5 cmolc/dm³');
    if (mSubAlto) motivos.add('m%_sub > 25%');

    return DiagnosticoGesso(
      indicado: caSubBaixo || alSubAlto || mSubAlto,
      caSubBaixo: caSubBaixo,
      alSubAlto: alSubAlto,
      mSubAlto: mSubAlto,
      motivos: motivos,
    );
  }

  /// Método ① — Teor de Argila (EMBRAPA).
  static ResultadoGesso metodo1Argila({
    required double argilaPercent,
    required bool culturaPerena,
    DiagnosticoGesso? diagnostico,
  }) {
    final fator = culturaPerena ? 75.0 : 50.0;
    final doseKg = fator * argilaPercent;
    return _buildResultado(
      metodo: MetodoGesso.argilaEmbrapa,
      doseKgHa: doseKg,
      diagnostico: diagnostico,
      observacoes: [
        culturaPerena
            ? 'Cultura perene: NG = 75 × argila(%).'
            : 'Cultura anual: NG = 50 × argila(%).',
      ],
    );
  }

  /// Método ② — Tabela por textura (UFLA).
  static ResultadoGesso metodo2Textura({
    required double argilaPercent,
    DiagnosticoGesso? diagnostico,
  }) {
    final doseKg = switch (argilaPercent) {
      < 15.0 => 700.0,
      >= 15.0 && <= 35.0 => 1200.0,
      >= 36.0 && <= 60.0 => 2200.0,
      _ => 3200.0,
    };

    return _buildResultado(
      metodo: MetodoGesso.tabelaTexturaUfla,
      doseKgHa: doseKg,
      diagnostico: diagnostico,
      observacoes: ['Dose por classe textural (UFLA/Lopes et al. 2006).'],
    );
  }

  /// Método ③ — V% e CTC subsolo (ESALQ/Vitti), válido para Va_sub < 35%.
  /// NG(t/ha) = ((50 - Va_sub) × CTC_sub) / 500
  /// CTC_sub em mmolc/dm³.
  static ResultadoGesso metodo3VSubCTC({
    required double vaSub,
    required double ctcSubMmolcDm3,
    DiagnosticoGesso? diagnostico,
  }) {
    final obs = <String>[];
    if (vaSub >= 35.0) {
      obs.add('Método ③ recomendado apenas para Va_sub < 35%.');
    }

    final doseTHa = ((50.0 - vaSub) * ctcSubMmolcDm3) / 500.0;
    final doseKg = Conversoes.tHaToKgHa(doseTHa.clamp(0.0, double.infinity));
    return _buildResultado(
      metodo: MetodoGesso.vPctCtcSubEsalq,
      doseKgHa: doseKg,
      diagnostico: diagnostico,
      observacoes: obs,
    );
  }

  /// Método ④ — CTC efetiva e Ca (UEPG/Caires).
  /// NG(t/ha) = (0,60 × CTCe_sub − Ca_sub) × 6,4
  static ResultadoGesso metodo4CTCeCa(GessoInput input, {DiagnosticoGesso? diagnostico}) {
    final doseTHa = (0.60 * input.ctcEfetiva - input.ca) * 6.4;
    final doseKg = Conversoes.tHaToKgHa(doseTHa.clamp(0.0, double.infinity));
    return _buildResultado(
      metodo: MetodoGesso.ctcEfetivaCaUepg,
      doseKgHa: doseKg,
      diagnostico: diagnostico,
    );
  }

  /// Fórmula especial 6.1 — Solo sódico:
  /// NG(kg/ha) = ((PSTI − PSTF) × CTC × 86 × h × ds) / 100
  static ResultadoGesso soloSodico({
    required double pstInicial,
    required double pstFinal,
    required double ctcMmolcDm3,
    required double profundidadeCm,
    required double densidadeSolo,
  }) {
    final doseKg = ((pstInicial - pstFinal) *
            ctcMmolcDm3 *
            Conversoes.gessoEquivalenteGrama *
            profundidadeCm *
            densidadeSolo) /
        100.0;
    return _buildResultado(
      metodo: MetodoGesso.sodico,
      doseKgHa: doseKg.clamp(0.0, double.infinity),
      observacoes: ['Correção de solo sódico via redução de PST.'],
    );
  }

  /// Fórmula especial 6.2 — Excesso de K:
  /// NG(kg/ha) = ((PSKa − PSKd) × CTC × 86 × h × ds) / 100
  static ResultadoGesso excessoPotassio({
    required double pskAtual,
    required double pskDesejado,
    required double ctcMmolcDm3,
    required double profundidadeCm,
    required double densidadeSolo,
  }) {
    final doseKg = ((pskAtual - pskDesejado) *
            ctcMmolcDm3 *
            Conversoes.gessoEquivalenteGrama *
            profundidadeCm *
            densidadeSolo) /
        100.0;
    return _buildResultado(
      metodo: MetodoGesso.excessoPotassio,
      doseKgHa: doseKg.clamp(0.0, double.infinity),
      observacoes: ['Correção de excesso de saturação de K (PSK).'],
    );
  }

  static ResultadoGesso _buildResultado({
    required MetodoGesso metodo,
    required double doseKgHa,
    DiagnosticoGesso? diagnostico,
    List<String> observacoes = const [],
  }) {
    final doseTHa = Conversoes.kgHaToTHa(doseKgHa);
    final sFornecido = doseKgHa * _sTeor;
    final caFornecido = doseKgHa * _caTeor;
    final caAumentoCmolc = doseTHa * _caCmolcPorTHa;

    final obs = <String>[...observacoes];
    final diagIndicado = diagnostico?.indicado ?? true;
    if (!diagIndicado) {
      obs.add('Diagnóstico não indica gessagem para 20–40 cm.');
    } else if (diagnostico != null) {
      obs.add('Critérios atendidos: ${diagnostico.motivos.join(', ')}.');
    }
    if (doseKgHa > 500.0) {
      obs.add('Dose > 500 kg/ha: monitorar Mo e possível lixiviação de B.');
    }

    return ResultadoGesso(
      metodo: metodo,
      indicado: diagIndicado,
      doseKgHa: doseKgHa,
      doseTHa: doseTHa,
      sFornecidoKgHa: sFornecido,
      caFornecidoKgHa: caFornecido,
      caAumentoCmolcDm3: caAumentoCmolc,
      observacoes: obs,
    );
  }
}
