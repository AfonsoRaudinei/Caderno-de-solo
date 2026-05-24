import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soloforte/domain/entities/analise_completa.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';
import 'package:soloforte/data/datasources/remote/recomendacao_firestore_datasource.dart';
import 'package:soloforte/domain/mappers/analise_mapper.dart';
import 'package:soloforte/domain/usecases/calcular_recomendacao_completa_usecase.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
import 'package:soloforte/domain/models/diagnostico_recomendacao.dart';
import 'package:soloforte/domain/value_objects/valor_nutriente.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/config/application/providers/tabela_metricas_provider.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
export 'package:soloforte/domain/usecases/recomendacao_engine.dart'
    show ResultadoRecomendacao, MicroResultado, GrupoResultado;

@immutable
class RecomendacaoRequest {
  const RecomendacaoRequest({
    this.analiseId,
    this.analiseIds = const <String>[],
    required this.calibracaoId,
  });

  final String? analiseId;
  final List<String> analiseIds;
  final String? calibracaoId;

  List<String> get analiseIdsEfetivos {
    if (analiseIds.isNotEmpty) return analiseIds;
    if (analiseId != null && analiseId!.isNotEmpty) return <String>[analiseId!];
    return const <String>[];
  }

  bool get isSelecionado =>
      analiseIdsEfetivos.isNotEmpty &&
      calibracaoId != null &&
      calibracaoId!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecomendacaoRequest &&
        listEquals(other.analiseIdsEfetivos, analiseIdsEfetivos) &&
        other.calibracaoId == calibracaoId;
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(analiseIdsEfetivos), calibracaoId);
}

final recomendacaoProvider =
    Provider.family<RecomendacaoResult, RecomendacaoRequest>(
  (ref, request) {
    if (!request.isSelecionado) {
      return const RecomendacaoResult(
        recomendacao: null,
        diagnostico: DiagnosticoRecomendacao(),
      );
    }

    final analises = ref.watch(analiseNotifierProvider).valueOrNull;
    final calibracaoState = ref.watch(calibracaoControllerProvider);
    final tabelas = (ref.watch(tabelaMetricasProvider).valueOrNull ?? const [])
        .map((tabela) => tabela.toJson())
        .toList(growable: false);

    if (analises == null || tabelas.isEmpty) {
      return const RecomendacaoResult(
        recomendacao: null,
        diagnostico: DiagnosticoRecomendacao(),
      );
    }

    final analiseMatches = analises
        .where((item) => request.analiseIdsEfetivos.contains(item.id))
        .toList(growable: false);
    final calibracaoMatches = calibracaoState.profiles
        .where((item) => item.id == request.calibracaoId);
    final analise = analiseMatches.isEmpty ? null : analiseMatches.first;
    final calibracao =
        calibracaoMatches.isEmpty ? null : calibracaoMatches.first;

    if (analise == null || calibracao == null) {
      return const RecomendacaoResult(
        recomendacao: null,
        diagnostico: DiagnosticoRecomendacao(),
      );
    }

    final laboratorios =
        analiseMatches.map((a) => a.laboratorio.trim()).toSet();
    final profundidades = analiseMatches
        .map((a) => _normalizarProfundidade(a.profundidade))
        .toSet();
    if (laboratorios.length > 1 || profundidades.length > 1) {
      return const RecomendacaoResult(
        recomendacao: null,
        diagnostico: DiagnosticoRecomendacao(
          erros: [
            'Selecione apenas amostras do mesmo laboratório e profundidade.',
          ],
        ),
      );
    }

    final analiseCompleta = _buildAnaliseParaRecomendacao(analiseMatches);
    final label = analiseMatches.length > 1
        ? 'Média de ${analiseMatches.length} amostras · ${analise.laboratorio} · ${DateFormat('dd/MM/yyyy').format(analiseCompleta.dataCadastro)}'
        : '${analise.talhao} · ${analise.laboratorio} · ${DateFormat('dd/MM/yyyy').format(analise.dataCadastro)}';
    const usecase = CalcularRecomendacaoCompletaUsecase();
    final resultado = usecase.execute(
      analise: analiseCompleta,
      calibracao: calibracao,
      tabelas: tabelas,
      labelAnalise: label,
    );
    return resultado;
  },
);

String _normalizarProfundidade(String raw) {
  final value = raw.trim();
  return value.isEmpty ? '0-20' : value;
}

AnaliseCompleta _buildAnaliseParaRecomendacao(List<AnaliseSolo> analises) {
  if (analises.length == 1) {
    return AnaliseMapper.fromSolo(analises.first);
  }

  final completas =
      analises.map(AnaliseMapper.fromSolo).toList(growable: false);
  final first = completas.first;
  final latest = completas
      .map((a) => a.dataCadastro)
      .reduce((a, b) => a.isAfter(b) ? a : b);
  final extratores = completas.map((a) => a.extratorP).toSet();

  return AnaliseCompleta(
    id: completas.map((a) => a.id).join('+'),
    fazenda: first.fazenda,
    produtor: first.produtor,
    talhao: 'Média de ${completas.length} amostras',
    cultura: first.cultura,
    laboratorio: first.laboratorio,
    dataCadastro: latest,
    descricaoLocal: first.descricaoLocal,
    phAgua: _media(completas.map((a) => a.phAgua)),
    phSmp: _media(completas.map((a) => a.phSmp)),
    phCaCl2: _media(completas.map((a) => a.phCaCl2)),
    materiaOrganica: _media(completas.map((a) => a.materiaOrganica)),
    argila: _media(completas.map((a) => a.argila)),
    pMehlich: _media(completas.map((a) => a.pMehlich)),
    pResina: _media(completas.map((a) => a.pResina)),
    pRem: _media(completas.map((a) => a.pRem)),
    extratorP: extratores.length == 1 ? extratores.first : null,
    k: _media(completas.map((a) => a.k)),
    ca: _media(completas.map((a) => a.ca)),
    mg: _media(completas.map((a) => a.mg)),
    al: _media(completas.map((a) => a.al)),
    hAl: _media(completas.map((a) => a.hAl)),
    na: _media(completas.map((a) => a.na)),
    s020: _media(completas.map((a) => a.s020)),
    s2040: _media(completas.map((a) => a.s2040)),
    b: _media(completas.map((a) => a.b)),
    cu: _media(completas.map((a) => a.cu)),
    fe: _media(completas.map((a) => a.fe)),
    mn: _media(completas.map((a) => a.mn)),
    zn: _media(completas.map((a) => a.zn)),
    ni: _media(completas.map((a) => a.ni)),
    mo: _media(completas.map((a) => a.mo)),
    se: _media(completas.map((a) => a.se)),
    co: _media(completas.map((a) => a.co)),
  );
}

ValorNutriente _media(Iterable<ValorNutriente> valores) {
  final analisados = valores.where((v) => v.isValido).toList(growable: false);
  if (analisados.isEmpty) {
    return const ValorNutriente(valor: null, analisado: false);
  }
  final soma = analisados.fold<double>(0, (total, v) => total + v.valor!);
  return ValorNutriente(
    valor: soma / analisados.length,
    analisado: true,
  );
}

CalcarioViewModel buildCalcarioViewModel(ResultadoRecomendacao resultado) {
  final corretivos = _asMap(resultado.calibracao.parametrosCards['corretivos']);
  final tipoCalcario = _asStr(corretivos['tipoCalcario'], 'Dolomítico');
  final calcario1 = _asMap(corretivos['calcario1']);
  final calcario2 = _asMap(corretivos['calcario2']);
  final usarC2 = _asBool(corretivos['usarSegundoCalcario']);
  final prop1 = _asNum(corretivos['proporcaoCalcario1'], 50).toDouble();
  final prop2 = (100.0 - prop1).clamp(0.0, 100.0);
  final prnt1 = _asNum(calcario1['prnt'], 80).toDouble();
  final caO1 = _asNum(calcario1['caO'], 30).toDouble();
  final mgO1 = _asNum(calcario1['mgO'], 16).toDouble();
  final prnt2 = _asNum(calcario2['prnt'], 75).toDouble();
  final caO2 = _asNum(calcario2['caO'], 42).toDouble();
  final mgO2 = _asNum(calcario2['mgO'], 3).toDouble();
  final dose = resultado.doseCalcarioTHa;
  final temDose = dose > 0;

  return CalcarioViewModel(
    tipoCalcario: tipoCalcario,
    calcario1Prnt: prnt1,
    calcario1CaO: caO1,
    calcario1MgO: mgO1,
    calcario2Prnt: prnt2,
    calcario2CaO: caO2,
    calcario2MgO: mgO2,
    usarSegundoCalcario: usarC2,
    prop1: prop1,
    prop2: prop2,
    dose: dose,
    temDose: temDose,
    analise: resultado.analise,
  );
}

class CalcarioViewModel {
  const CalcarioViewModel({
    required this.tipoCalcario,
    required this.calcario1Prnt,
    required this.calcario1CaO,
    required this.calcario1MgO,
    required this.calcario2Prnt,
    required this.calcario2CaO,
    required this.calcario2MgO,
    required this.usarSegundoCalcario,
    required this.prop1,
    required this.prop2,
    required this.dose,
    required this.temDose,
    required this.analise,
  });

  final String tipoCalcario;
  final double calcario1Prnt;
  final double calcario1CaO;
  final double calcario1MgO;
  final double calcario2Prnt;
  final double calcario2CaO;
  final double calcario2MgO;
  final bool usarSegundoCalcario;
  final double prop1;
  final double prop2;
  final double dose;
  final bool temDose;
  final dynamic analise;

  String get iconeCalcario {
    switch (tipoCalcario) {
      case 'Calcítico':
        return '🟡';
      case 'Magnesiano':
        return '🟣';
      default:
        return '🪨';
    }
  }
}

Map<String, dynamic> _asMap(dynamic v) => v is Map<String, dynamic> ? v : {};
num _asNum(dynamic v, [num fb = 0]) => v is num ? v : fb;
bool _asBool(dynamic v) => v is bool ? v : false;
String _asStr(dynamic v, [String fb = '']) => v is String ? v : fb;

class SalvarRecomendacaoNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> salvarRecomendacao(RecomendacaoModel recomendacao) async {
    state = const AsyncValue.loading();
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuário não autenticado');

      final model = recomendacao.copyWith(
        userId: uid,
        createdAt: DateTime.now(),
      );

      final datasource = ref.read(recomendacaoDatasourceProvider);
      await datasource.saveRecomendacao(model.toJson());
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final salvarRecomendacaoProvider =
    AutoDisposeAsyncNotifierProvider<SalvarRecomendacaoNotifier, void>(() {
  return SalvarRecomendacaoNotifier();
});
