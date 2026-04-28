import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/features/config/domain/entities/tabela_metricas.dart';
import 'package:soloforte/features/config/presentation/providers/tabela_metricas_provider.dart';

/// Tela que lista todas as Tabelas de Métricas e permite
/// ao Agrônomo editar cada faixa de textura / valor.
class TabelaMetricasPage extends ConsumerWidget {
  const TabelaMetricasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabelasAsync = ref.watch(tabelaMetricasProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Tabelas de Métricas'),
        actions: [
          IconButton(
            tooltip: 'Restaurar padrões',
            icon: const Icon(Icons.restore_rounded),
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Restaurar padrões?'),
                  content: const Text(
                      'Todas as tabelas voltarão para os valores originais das referências bibliográficas. '
                      'Esta ação não pode ser desfeita.'),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => context.pop(true),
                      child: const Text('Restaurar',
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (confirmar == true) {
                await ref
                    .read(tabelaMetricasProvider.notifier)
                    .resetarParaDefaults();
              }
            },
          ),
        ],
      ),
      body: tabelasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (tabelas) => ListView.builder(
          padding: const EdgeInsets.all(AppDimens.lg),
          itemCount: tabelas.length,
          itemBuilder: (context, index) {
            final tabela = tabelas[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.md),
              child: _TabelaCard(
                tabela: tabela,
                onEditar: () => _abrirEditor(context, ref, tabela),
              ),
            );
          },
        ),
      ),
    );
  }

  void _abrirEditor(
      BuildContext context, WidgetRef ref, TabelaMetricas tabela) {
    final container = ProviderScope.containerOf(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UncontrolledProviderScope(
          container: container,
          child: _TabelaEditorPage(tabela: tabela, ref: ref),
        ),
      ),
    );
  }
}

// ── Card da tabela ────────────────────────────────────────────────────────────

class _TabelaCard extends StatelessWidget {
  const _TabelaCard({required this.tabela, required this.onEditar});
  final TabelaMetricas tabela;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onEditar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            children: [
              Expanded(
                child: Text(tabela.nome,
                    style: AppTextStyles.label.copyWith(fontSize: 15)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(tabela.unidade,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primary, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(tabela.descricao,
              style: AppTextStyles.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          // Preview das faixas
          ...tabela.linhas.map((linha) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        linha['faixa']?.toString() ?? '—',
                        style: AppTextStyles.caption.copyWith(fontSize: 12),
                      ),
                    ),
                    Text(
                      '${linha['valor']?.toString() ?? '—'} ${tabela.unidade}',
                      style: AppTextStyles.label
                          .copyWith(fontSize: 12, color: AppColors.primary),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.edit_outlined,
                  size: 14, color: AppColors.textSecond),
              const SizedBox(width: 4),
              Text('Toque para editar',
                  style: AppTextStyles.caption
                      .copyWith(fontSize: 11, color: AppColors.textSecond)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Editor inline de uma tabela ───────────────────────────────────────────────

class _TabelaEditorPage extends StatefulWidget {
  const _TabelaEditorPage({required this.tabela, required this.ref});
  final TabelaMetricas tabela;
  final WidgetRef ref;

  @override
  State<_TabelaEditorPage> createState() => _TabelaEditorPageState();
}

class _TabelaEditorPageState extends State<_TabelaEditorPage> {
  late List<Map<String, dynamic>> _linhas;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _linhas =
        widget.tabela.linhas.map((l) => Map<String, dynamic>.from(l)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: Text(widget.tabela.nome, style: const TextStyle(fontSize: 15)),
        actions: [
          if (_salvando)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Salvar'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              widget.tabela.descricao,
              style: AppTextStyles.caption.copyWith(fontSize: 12),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimens.lg),
              itemCount: _linhas.length,
              itemBuilder: (context, i) {
                final linha = _linhas[i];
                return _LinhaEditor(
                  faixa: linha['faixa']?.toString() ?? '',
                  valor: _asDouble(linha['valor']),
                  unidade: widget.tabela.unidade,
                  onChanged: (novoValor) {
                    setState(() => _linhas[i]['valor'] = novoValor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _salvar() async {
    setState(() => _salvando = true);
    try {
      final atualizado = widget.tabela.copyWith(
        linhas: _linhas,
        updatedAt: DateTime.now(),
      );
      await widget.ref.read(tabelaMetricasProvider.notifier).salvar(atualizado);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Tabela salva com sucesso!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  static double _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return 0;
  }
}

// ── Row de edição de uma linha ────────────────────────────────────────────────

class _LinhaEditor extends StatefulWidget {
  const _LinhaEditor({
    required this.faixa,
    required this.valor,
    required this.unidade,
    required this.onChanged,
  });
  final String faixa;
  final double valor;
  final String unidade;
  final ValueChanged<double> onChanged;

  @override
  State<_LinhaEditor> createState() => _LinhaEditorState();
}

class _LinhaEditorState extends State<_LinhaEditor> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.valor.toStringAsFixed(widget.valor % 1 == 0 ? 0 : 2));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: AppCard(
        onTap: null,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Faixa Textural',
                      style: AppTextStyles.caption.copyWith(fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(widget.faixa,
                      style: AppTextStyles.body.copyWith(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Valor (${widget.unidade})',
                      style: AppTextStyles.caption.copyWith(fontSize: 11)),
                  const SizedBox(height: 2),
                  TextFormField(
                    controller: _ctrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    onChanged: (v) {
                      final parsed = double.tryParse(v.replaceAll(',', '.'));
                      if (parsed != null) widget.onChanged(parsed);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
