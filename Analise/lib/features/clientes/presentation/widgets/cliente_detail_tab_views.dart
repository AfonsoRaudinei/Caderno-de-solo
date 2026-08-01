import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';
import 'package:soloforte/features/clientes/presentation/widgets/cliente_analise_list_tile.dart';
import 'package:soloforte/features/clientes/presentation/widgets/fazenda_section_widget.dart';
import 'package:soloforte/features/clientes/presentation/widgets/qr_token_widget.dart';
import 'package:soloforte/features/clientes/presentation/widgets/talhao_row_widget.dart';
import 'package:soloforte/features/historico/application/providers/historico_provider.dart';
import 'package:soloforte/features/historico/presentation/historico_card_widget.dart';

class ClienteDetailResumoTab extends StatelessWidget {
  const ClienteDetailResumoTab({
    super.key,
    required this.cliente,
    required this.totalAnalises,
    required this.totalRecomendacoes,
    required this.onCompartilharToken,
    required this.onCopiarToken,
    required this.onEditarCliente,
  });

  final ClienteEntity cliente;
  final int totalAnalises;
  final int totalRecomendacoes;
  final VoidCallback onCompartilharToken;
  final Future<void> Function() onCopiarToken;
  final VoidCallback onEditarCliente;

  String _displayName(String nome) {
    final normalized = nome.trim();
    return normalized.isEmpty ? 'Cliente sem nome' : normalized;
  }

  String? _displayLocation(String cidade, String estado) {
    final cidadeNormalizada = cidade.trim();
    final estadoNormalizado = estado.trim();
    if (cidadeNormalizada.isEmpty && estadoNormalizado.isEmpty) {
      return null;
    }
    if (cidadeNormalizada.isEmpty) return estadoNormalizado;
    if (estadoNormalizado.isEmpty) return cidadeNormalizada;
    return '$cidadeNormalizada — $estadoNormalizado';
  }

  int get _totalTalhoes =>
      cliente.fazendas.fold<int>(0, (sum, f) => sum + f.talhoes.length);

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppSurface(
          showBorder: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppIconFrame(
                icon: Icons.person_outline_rounded,
                size: AppDimens.cardIconSize,
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName(cliente.nome),
                      style: AppTextStyles.headline.copyWith(
                        fontSize: 20,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),
                    if (cliente.telefone.trim().isNotEmpty)
                      _DetailLine(
                        icon: Icons.phone_outlined,
                        text: cliente.telefone.trim(),
                      ),
                    if (cliente.email.trim().isNotEmpty)
                      _DetailLine(
                        icon: Icons.mail_outline,
                        text: cliente.email.trim(),
                      ),
                    if (_displayLocation(cliente.cidade, cliente.estado)
                        case final location?)
                      _DetailLine(
                        icon: Icons.location_on_outlined,
                        text: location,
                      ),
                    if ((cliente.observacoes ?? '').isNotEmpty)
                      _DetailLine(
                        icon: Icons.description_outlined,
                        text: cliente.observacoes!,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ResumoStatsGrid(
          propriedades: cliente.fazendas.length,
          talhoes: _totalTalhoes,
          analises: totalAnalises,
          recomendacoes: totalRecomendacoes,
        ),
        const SizedBox(height: 16),
        QrTokenWidget(
          token: cliente.token,
          onCompartilhar: onCompartilharToken,
          onCopiar: onCopiarToken,
        ),
        const SizedBox(height: 20),
        AppButtonSecondary(
          label: 'Editar Cliente',
          icon: Icons.edit_outlined,
          onPressed: onEditarCliente,
        ),
      ],
    );
  }
}

class ClienteDetailPropriedadesTab extends StatelessWidget {
  const ClienteDetailPropriedadesTab({
    super.key,
    required this.cliente,
    required this.expandedFazendas,
    required this.onToggleFazenda,
    required this.onAdicionarFazenda,
    required this.onAdicionarTalhao,
    required this.onTapTalhao,
    required this.onDismissFazenda,
  });

  final ClienteEntity cliente;
  final Set<String> expandedFazendas;
  final ValueChanged<String> onToggleFazenda;
  final VoidCallback onAdicionarFazenda;
  final ValueChanged<String> onAdicionarTalhao;
  final void Function(FazendaEntity fazenda, TalhaoEntity talhao) onTapTalhao;
  final Future<bool?> Function(String fazendaId) onDismissFazenda;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'PROPRIEDADES',
                style: AppTextStyles.sectionLabel.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: palette.textSecondary,
                ),
              ),
            ),
            Text(
              '${cliente.fazendas.length}',
              style: AppTextStyles.caption.copyWith(
                color: palette.textTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (cliente.fazendas.isEmpty)
          AppSurface(
            showBorder: true,
            child: Text(
              'Nenhuma propriedade cadastrada para este cliente.',
              style: AppTextStyles.caption.copyWith(
                color: palette.textSecondary,
              ),
            ),
          )
        else
          for (final fazenda in cliente.fazendas)
            Dismissible(
              key: ValueKey('fazenda-${fazenda.id}'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => onDismissFazenda(fazenda.id),
              background: _dismissBackground(),
              child: FazendaSectionWidget(
                fazenda: fazenda,
                isExpanded: expandedFazendas.contains(fazenda.id),
                onToggle: () => onToggleFazenda(fazenda.id),
                onAdicionarTalhao: () => onAdicionarTalhao(fazenda.id),
                onTapTalhao: (talhao) => onTapTalhao(fazenda, talhao),
              ),
            ),
        Align(
          alignment: Alignment.centerLeft,
          child: AppButtonText(
            label: '+ Adicionar Propriedade',
            onPressed: onAdicionarFazenda,
          ),
        ),
      ],
    );
  }
}

class ClienteDetailTalhoesTab extends StatelessWidget {
  const ClienteDetailTalhoesTab({
    super.key,
    required this.cliente,
    required this.onTapTalhao,
  });

  final ClienteEntity cliente;
  final void Function(FazendaEntity fazenda, TalhaoEntity talhao) onTapTalhao;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final entries = <({FazendaEntity fazenda, TalhaoEntity talhao})>[];
    for (final fazenda in cliente.fazendas) {
      for (final talhao in fazenda.talhoes) {
        entries.add((fazenda: fazenda, talhao: talhao));
      }
    }

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Nenhum talhão cadastrado. Adicione uma propriedade na aba Propriedades.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: palette.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return AppSurface(
          showBorder: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.fazenda.nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: palette.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TalhaoRowWidget(
                talhao: entry.talhao,
                onTap: () => onTapTalhao(entry.fazenda, entry.talhao),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ClienteDetailAnalisesTab extends ConsumerStatefulWidget {
  const ClienteDetailAnalisesTab({
    super.key,
    required this.clienteId,
  });

  final String clienteId;

  @override
  ConsumerState<ClienteDetailAnalisesTab> createState() =>
      _ClienteDetailAnalisesTabState();
}

class _ClienteDetailAnalisesTabState
    extends ConsumerState<ClienteDetailAnalisesTab> {
  bool _reparoVinculoExecutado = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final analises =
        ref.watch(analisesPorClienteProvider(widget.clienteId));

    if (!_reparoVinculoExecutado) {
      _reparoVinculoExecutado = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(analiseNotifierProvider.notifier).repararVinculosLegados();
      });
    }

    if (analises.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Nenhuma análise vinculada a este cliente.\nImporte um laudo PDF e selecione este cliente na hierarquia.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: palette.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: analises.length,
      itemBuilder: (context, index) {
        final analise = analises[index];
        return ClienteAnaliseListTile(
          analise: analise,
          onTap: () => context.push(
            '${AppRoutes.analise}/detalhe/${analise.id}',
          ),
        );
      },
    );
  }
}

class ClienteDetailRecomendacoesTab extends ConsumerWidget {
  const ClienteDetailRecomendacoesTab({
    super.key,
    required this.clienteId,
  });

  final String clienteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.appPalette;
    final recomendacoesAsync =
        ref.watch(recomendacoesPorClienteProvider(clienteId));

    return recomendacoesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Erro ao carregar recomendações: $error',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: palette.textSecondary),
          ),
        ),
      ),
      data: (recomendacoes) {
        if (recomendacoes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Nenhuma recomendação gerada para as análises deste cliente.',
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.body.copyWith(color: palette.textSecondary),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: recomendacoes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return HistoricoCardWidget(recomendacao: recomendacoes[index]);
          },
        );
      },
    );
  }
}

class _ResumoStatsGrid extends StatelessWidget {
  const _ResumoStatsGrid({
    required this.propriedades,
    required this.talhoes,
    required this.analises,
    required this.recomendacoes,
  });

  final int propriedades;
  final int talhoes;
  final int analises;
  final int recomendacoes;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AppSurface(
      showBorder: true,
      child: Row(
        children: [
          _StatCell(label: 'Propriedades', value: propriedades, palette: palette),
          _StatCell(label: 'Talhões', value: talhoes, palette: palette),
          _StatCell(label: 'Análises', value: analises, palette: palette),
          _StatCell(
            label: 'Recomendações',
            value: recomendacoes,
            palette: palette,
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.palette,
  });

  final String label;
  final int value;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: AppTextStyles.headline.copyWith(
              fontSize: 18,
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: palette.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: palette.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(color: palette.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _dismissBackground() {
  return Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Icon(Icons.delete_outline, color: AppColors.error),
  );
}
