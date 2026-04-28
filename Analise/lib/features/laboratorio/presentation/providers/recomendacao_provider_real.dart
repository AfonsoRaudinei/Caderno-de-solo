import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloforte/domain/mappers/analise_mapper.dart';
import 'package:soloforte/domain/usecases/calcular_recomendacao_completa_usecase.dart';
import 'package:soloforte/domain/models/diagnostico_recomendacao.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/config/application/providers/tabela_metricas_provider.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';

@immutable
class RecomendacaoRequest {
  const RecomendacaoRequest({
    required this.analiseId,
    required this.calibracaoId,
  });

  final String? analiseId;
  final String? calibracaoId;

  bool get isSelecionado =>
      analiseId != null &&
      analiseId!.isNotEmpty &&
      calibracaoId != null &&
      calibracaoId!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecomendacaoRequest &&
        other.analiseId == analiseId &&
        other.calibracaoId == calibracaoId;
  }

  @override
  int get hashCode => Object.hash(analiseId, calibracaoId);
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

    final analiseMatches =
        analises.where((item) => item.id == request.analiseId);
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

    final analiseCompleta = AnaliseMapper.fromSolo(analise);
    final label =
        '${analise.talhao} · ${analise.laboratorio} · ${DateFormat('dd/MM/yyyy').format(analise.dataCadastro)}';
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
