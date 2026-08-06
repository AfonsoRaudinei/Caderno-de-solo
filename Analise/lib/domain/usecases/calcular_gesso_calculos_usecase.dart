import 'package:soloforte/domain/entities/resultado_gesso.dart';
import 'package:soloforte/domain/formulas/gesso_engine.dart';
import 'package:soloforte/domain/formulas/types/gesso_input.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/usecases/calcular_calagem_calculos_usecase.dart';

class CalculoGessoResultado {
  const CalculoGessoResultado({
    required this.referencia,
    required this.metodo,
    required this.usarGesso,
    required this.diagnostico,
    required this.resultado,
    required this.caSubEstimado,
    required this.alSubEstimado,
    required this.mSubEstimado,
    required this.resumoCalculo,
  });

  final String referencia;
  final String metodo;
  final bool usarGesso;
  final DiagnosticoGesso diagnostico;
  final ResultadoGesso resultado;
  final double caSubEstimado;
  final double alSubEstimado;
  final double mSubEstimado;
  final String resumoCalculo;
}

class CalcularGessoCalculosUsecase {
  const CalcularGessoCalculosUsecase();

  CalculoGessoResultado call({
    required CalculoCalagemAnaliseInput analise,
    required CalibracaoProfile calibracao,
  }) {
    final corretivos = _asMap(calibracao.parametrosCards['corretivos']);
    final gesso = _asMap(corretivos['gesso']);
    final usarGesso = _asBool(gesso['usarGesso']);
    final referencia = _asString(
      gesso['referencia'],
      '02 — Gesso Agrícola: Motor de Cálculo',
    );
    final metodo = _asString(
      gesso['metodo'],
      '① EMBRAPA / Souza et al. (2004) — argila %',
    );

    final ca = _required(analise.ca, 'Ca');
    final mg = _required(analise.mg, 'Mg');
    final k = _required(analise.k, 'K');
    final al = _required(analise.al, 'Al');
    final argila = _required(analise.argila, 'Argila');
    final vPercent = _required(analise.vPercent, 'V%');
    final ctc = _required(analise.ctc, 'CTC');

    final caSubEstimado = ca * 0.4;
    final alSubEstimado = al * 0.8;
    final mSubEstimado = _mSubEstimado(ca: ca, mg: mg, k: k, al: al);

    final diagnostico = GessoEngine.diagnosticar(
      caSub: caSubEstimado,
      alSub: alSubEstimado,
      mSub: mSubEstimado,
    );

    final resultado = !usarGesso
        ? const ResultadoGesso(
            metodo: MetodoGesso.argilaEmbrapa,
            indicado: false,
            doseKgHa: 0,
            doseTHa: 0,
            sFornecidoKgHa: 0,
            caFornecidoKgHa: 0,
            caAumentoCmolcDm3: 0,
            observacoes: ['Gesso desativado na calibração.'],
          )
        : _calcularResultado(
            metodo: metodo,
            argila: argila,
            vPercent: vPercent,
            ctc: ctc,
            ca: ca,
            mg: mg,
            k: k,
            al: al,
            diagnostico: diagnostico,
          );

    return CalculoGessoResultado(
      referencia: referencia,
      metodo: metodo,
      usarGesso: usarGesso,
      diagnostico: diagnostico,
      resultado: resultado,
      caSubEstimado: caSubEstimado,
      alSubEstimado: alSubEstimado,
      mSubEstimado: mSubEstimado,
      resumoCalculo: _resumo(
        metodo: metodo,
        caSubEstimado: caSubEstimado,
        alSubEstimado: alSubEstimado,
        mSubEstimado: mSubEstimado,
      ),
    );
  }

  ResultadoGesso _calcularResultado({
    required String metodo,
    required double argila,
    required double vPercent,
    required double ctc,
    required double ca,
    required double mg,
    required double k,
    required double al,
    required DiagnosticoGesso diagnostico,
  }) {
    if (metodo.startsWith('②')) {
      return GessoEngine.metodo2Textura(
        argilaPercent: argila,
        diagnostico: diagnostico,
      );
    }
    if (metodo.startsWith('③')) {
      return GessoEngine.metodo3VSubCTC(
        vaSub: vPercent * 0.75,
        ctcSubMmolcDm3: ctc * 0.7,
        diagnostico: diagnostico,
      );
    }
    if (metodo.startsWith('④')) {
      final ctcEfetiva = ca + mg + k + al;
      return GessoEngine.metodo4CTCeCa(
        GessoInput(
          ctcEfetiva: ctcEfetiva * 0.7,
          ca: ca * 0.4,
          metodo: MetodoGesso.ctcEfetivaCaUepg.nome,
        ),
        diagnostico: diagnostico,
      );
    }
    return GessoEngine.metodo1Argila(
      argilaPercent: argila,
      culturaPerena: false,
      diagnostico: diagnostico,
    );
  }

  static double _mSubEstimado({
    required double ca,
    required double mg,
    required double k,
    required double al,
  }) {
    final t = ca + mg + k + al;
    if (t <= 0) return 0;
    return (al / t) * 100;
  }

  static String _resumo({
    required String metodo,
    required double caSubEstimado,
    required double alSubEstimado,
    required double mSubEstimado,
  }) {
    return 'Método ${metodo.split(' ').first} · Ca_sub ${caSubEstimado.toStringAsFixed(2)} · '
        'Al_sub ${alSubEstimado.toStringAsFixed(2)} · m%_sub ${mSubEstimado.toStringAsFixed(1)}';
  }

  static double _required(double? value, String field) {
    if (value == null) {
      throw StateError('$field ausente na análise para calcular o gesso.');
    }
    return value;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }

  static String _asString(dynamic value, String fallback) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return fallback;
    return text;
  }

  static bool _asBool(dynamic value) {
    return value is bool ? value : false;
  }
}
