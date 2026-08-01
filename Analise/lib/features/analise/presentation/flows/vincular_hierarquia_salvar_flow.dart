import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/analise/application/providers/produtor_configurado_provider.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/usecases/aplicar_hierarquia_analises_usecase.dart';
import 'package:soloforte/features/analise/domain/value_objects/hierarquia_selecao_sugestao.dart';
import 'package:soloforte/features/analise/presentation/widgets/hierarquia_selecao_sheet.dart';
import 'package:soloforte/features/clientes/application/providers/cliente_provider.dart';

/// Solicita vínculo hierárquico antes de persistir análises (manual ou import).
abstract final class VincularHierarquiaSalvarFlow {
  static Future<List<AnaliseSolo>?> solicitarEVincular(
    BuildContext context,
    WidgetRef ref, {
    required List<AnaliseSolo> analises,
  }) async {
    if (analises.isEmpty) return analises;

    final configuradoAtual =
        ref.read(produtorConfiguradoProvider).valueOrNull ?? '';
    final sugestao = HierarquiaSelecaoSugestao.fromAnalises(
      analises,
      produtorConfigurado: configuradoAtual,
    );
    if (!context.mounted) return null;

    final selecao = await showHierarquiaSelecaoSheet(
      context,
      ref,
      sugestao: sugestao,
    );
    if (selecao == null || !context.mounted) return null;

    await ref
        .read(produtorConfiguradoProvider.notifier)
        .salvar(selecao.clienteNome);
    if (!context.mounted) return null;

    return const AplicarHierarquiaAnalisesUsecase()(
      analises: analises,
      selecao: selecao,
    );
  }

  static Future<void> sincronizarPosSalvar(
    WidgetRef ref,
    List<AnaliseSolo> analisesVinculadas,
  ) async {
    await ref
        .read(analiseNotifierProvider.notifier)
        .registrarVinculosPosSalvar(analisesVinculadas);
    await ref.read(clienteProvider.notifier).carregarClientes();
    await ref.read(analiseNotifierProvider.notifier).repararProdutoresLegados();
  }
}
