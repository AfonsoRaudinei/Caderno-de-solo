import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/clientes/application/providers/cliente_provider.dart';
import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';
import 'package:soloforte/features/clientes/presentation/cliente_detail_tab.dart';
import 'package:soloforte/features/clientes/presentation/widgets/cliente_detail_tab_views.dart';
import 'package:soloforte/features/historico/application/providers/historico_provider.dart';

class ClienteDetailScreen extends ConsumerStatefulWidget {
  const ClienteDetailScreen({
    super.key,
    required this.clienteId,
    this.initialTab = ClienteDetailTab.resumo,
  });

  final String clienteId;
  final ClienteDetailTab initialTab;

  @override
  ConsumerState<ClienteDetailScreen> createState() =>
      _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends ConsumerState<ClienteDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<String> _expandedFazendas = <String>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTab.tabIndex,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(clienteProvider.notifier)
          .carregarClienteDetalhe(widget.clienteId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _displayName(String nome) {
    final normalized = nome.trim();
    return normalized.isEmpty ? 'Cliente sem nome' : normalized;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clienteProvider);
    final cliente = state.clienteSelecionado;
    final analises = ref.watch(analisesPorClienteProvider(widget.clienteId));
    final recomendacoesCount = ref
        .watch(recomendacoesPorClienteProvider(widget.clienteId))
        .maybeWhen(data: (items) => items.length, orElse: () => 0);

    return Scaffold(
      backgroundColor: context.appPalette.background,
      appBar: AppBar(
        title: Text(
          cliente == null ? 'Detalhe' : _displayName(cliente.nome),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: cliente == null
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: 'Resumo'),
                  Tab(text: 'Propriedades'),
                  Tab(text: 'Talhões'),
                  Tab(text: 'Análises'),
                  Tab(text: 'Recomendações'),
                ],
              ),
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && cliente == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (cliente == null) {
            return const Center(child: Text('Cliente não encontrado.'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              ClienteDetailResumoTab(
                cliente: cliente,
                totalAnalises: analises.length,
                totalRecomendacoes: recomendacoesCount,
                onCompartilharToken: () => Share.share(cliente.token),
                onCopiarToken: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await Clipboard.setData(ClipboardData(text: cliente.token));
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Token copiado!')),
                  );
                },
                onEditarCliente: () async {
                  final changed = await context.push<bool>(
                    AppRoutes.clienteEditarPath(cliente.id),
                  );
                  if (changed == true) {
                    await ref
                        .read(clienteProvider.notifier)
                        .carregarClienteDetalhe(cliente.id);
                  }
                },
              ),
              ClienteDetailPropriedadesTab(
                cliente: cliente,
                expandedFazendas: _expandedFazendas,
                onToggleFazenda: (fazendaId) {
                  setState(() {
                    if (_expandedFazendas.contains(fazendaId)) {
                      _expandedFazendas.remove(fazendaId);
                    } else {
                      _expandedFazendas.add(fazendaId);
                    }
                  });
                },
                onAdicionarFazenda: _abrirNovaFazenda,
                onAdicionarTalhao: _abrirNovoTalhao,
                onTapTalhao: _abrirTalhaoEdicao,
                onDismissFazenda: (fazendaId) => _confirmarExclusao(
                  'Excluir propriedade?',
                  'Essa ação remove também os talhões cadastrados.',
                ).then((allowed) {
                  if (allowed == true) {
                    ref
                        .read(clienteProvider.notifier)
                        .deletarFazenda(cliente.id, fazendaId);
                  }
                  return allowed;
                }),
              ),
              ClienteDetailTalhoesTab(
                cliente: cliente,
                onTapTalhao: _abrirTalhaoEdicao,
              ),
              ClienteDetailAnalisesTab(clienteId: widget.clienteId),
              ClienteDetailRecomendacoesTab(clienteId: widget.clienteId),
            ],
          );
        },
      ),
    );
  }

  Future<void> _abrirNovaFazenda() async {
    final changed = await context.push<bool>(
      AppRoutes.fazendaNovaPath(widget.clienteId),
    );
    if (changed == true) {
      await ref
          .read(clienteProvider.notifier)
          .carregarClienteDetalhe(widget.clienteId);
    }
  }

  Future<void> _abrirNovoTalhao(String fazendaId) async {
    final changed = await context.push<bool>(
      AppRoutes.talhaoNovoPath(widget.clienteId, fazendaId),
    );
    if (changed == true) {
      await ref
          .read(clienteProvider.notifier)
          .carregarClienteDetalhe(widget.clienteId);
    }
  }

  Future<void> _abrirTalhaoEdicao(
    FazendaEntity fazenda,
    TalhaoEntity talhao,
  ) async {
    final confirmed = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar talhão'),
              onTap: () => Navigator.of(context).pop('edit'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Excluir talhão',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;

    if (confirmed == 'edit') {
      final changed = await context.push<bool>(
        AppRoutes.talhaoEditarPath(
          widget.clienteId,
          fazenda.id,
          talhao.id,
        ),
      );
      if (changed == true) {
        await ref
            .read(clienteProvider.notifier)
            .carregarClienteDetalhe(widget.clienteId);
      }
      return;
    }

    if (confirmed == 'delete') {
      final allowed = await _confirmarExclusao(
        'Excluir talhão?',
        'Esse registro será removido do cliente.',
      );
      if (!mounted) return;
      if (allowed == true) {
        await ref
            .read(clienteProvider.notifier)
            .deletarTalhao(widget.clienteId, fazenda.id, talhao.id);
      }
    }
  }

  Future<bool?> _confirmarExclusao(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
