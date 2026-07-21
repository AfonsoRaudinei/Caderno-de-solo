import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/features/clientes/application/providers/cliente_provider.dart';
import 'package:soloforte/features/clientes/domain/entities/fazenda_entity.dart';
import 'package:soloforte/features/clientes/domain/entities/talhao_entity.dart';
import 'package:soloforte/features/clientes/presentation/fazenda_form_screen.dart';
import 'package:soloforte/features/clientes/presentation/talhao_form_screen.dart';
import 'package:soloforte/features/clientes/presentation/widgets/fazenda_section_widget.dart';
import 'package:soloforte/features/clientes/presentation/widgets/qr_token_widget.dart';

class ClienteDetailScreen extends ConsumerStatefulWidget {
  const ClienteDetailScreen({
    super.key,
    required this.clienteId,
  });

  final String clienteId;

  @override
  ConsumerState<ClienteDetailScreen> createState() =>
      _ClienteDetailScreenState();
}

class _ClienteDetailScreenState extends ConsumerState<ClienteDetailScreen> {
  final Set<String> _expandedFazendas = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(clienteProvider.notifier)
          .carregarClienteDetalhe(widget.clienteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clienteProvider);
    final cliente = state.clienteSelecionado;

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Detalhe'),
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cliente.nome, style: AppTextStyles.headline),
                    const SizedBox(height: 12),
                    _DetailLine(
                        icon: Icons.phone_outlined, text: cliente.telefone),
                    _DetailLine(icon: Icons.mail_outline, text: cliente.email),
                    _DetailLine(
                      icon: Icons.location_on_outlined,
                      text: '${cliente.cidade} — ${cliente.estado}',
                    ),
                    if ((cliente.observacoes ?? '').isNotEmpty)
                      _DetailLine(
                        icon: Icons.description_outlined,
                        text: cliente.observacoes!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              QrTokenWidget(
                token: cliente.token,
                onCompartilhar: () => Share.share(cliente.token),
                onCopiar: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await Clipboard.setData(ClipboardData(text: cliente.token));
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Token copiado!')),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                'FAZENDAS',
                style: AppTextStyles.sectionLabel.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              for (final fazenda in cliente.fazendas)
                Dismissible(
                  key: ValueKey('fazenda-${fazenda.id}'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _confirmarExclusao(
                    'Excluir fazenda?',
                    'Essa ação remove também os talhões cadastrados.',
                  ),
                  onDismissed: (_) => ref
                      .read(clienteProvider.notifier)
                      .deletarFazenda(cliente.id, fazenda.id),
                  background: _dismissBackground(),
                  child: FazendaSectionWidget(
                    fazenda: fazenda.copyWith(
                      talhoes: fazenda.talhoes,
                    ),
                    isExpanded: _expandedFazendas.contains(fazenda.id),
                    onToggle: () {
                      setState(() {
                        if (_expandedFazendas.contains(fazenda.id)) {
                          _expandedFazendas.remove(fazenda.id);
                        } else {
                          _expandedFazendas.add(fazenda.id);
                        }
                      });
                    },
                    onAdicionarTalhao: () => _abrirNovoTalhao(fazenda.id),
                    onTapTalhao: (talhao) =>
                        _abrirTalhaoEdicao(fazenda, talhao),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: AppButtonText(
                  label: '+ Adicionar Fazenda',
                  onPressed: _abrirNovaFazenda,
                ),
              ),
              const SizedBox(height: 20),
              AppButtonSecondary(
                label: 'Editar Cliente',
                icon: Icons.edit_outlined,
                onPressed: () async {
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
            ],
          );
        },
      ),
    );
  }

  Future<void> _abrirNovaFazenda() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FazendaFormScreen(clienteId: widget.clienteId),
      ),
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
      final changed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => TalhaoFormScreen(
            clienteId: widget.clienteId,
            fazendaId: fazenda.id,
            talhaoId: talhao.id,
          ),
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

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecond),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
