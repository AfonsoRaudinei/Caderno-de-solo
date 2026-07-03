import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/presentation/flows/importar_analise_pdf_flow.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
import 'package:soloforte/features/analise/presentation/utils/analise_card_labels.dart';

class AnaliseListScreen extends ConsumerStatefulWidget {
  const AnaliseListScreen({super.key});

  @override
  ConsumerState<AnaliseListScreen> createState() => _AnaliseListScreenState();
}

class _AnaliseListScreenState extends ConsumerState<AnaliseListScreen> {
  static const String _todasCulturasValue = '__todas_culturas__';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedCultura;
  String? _selectedSafra;
  String? _selectedFolderKey;
  bool _isSelectingFolders = false;
  final Set<String> _selectedFolderKeys = <String>{};
  bool _isSelectingAnalises = false;
  final Set<String> _selectedAnaliseIds = <String>{};
  String _searchQuery = '';
  bool _reparoProdutorExecutado = false;
  String? _selectedFolderHeaderTitle;

  void _importarPdf(BuildContext context) {
    iniciarImportacaoPdf(context, ref);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Cultura? culturaEnum;
    if (_selectedCultura != null) {
      culturaEnum = Cultura.values.firstWhere(
        (e) => e.label == _selectedCultura,
        orElse: () => Cultura.soja,
      );
    }

    final analiseState = ref.watch(analiseNotifierProvider);
    final analisesRaw = ref.watch(analisesVisiveisProvider);

    if (!_reparoProdutorExecutado) {
      _reparoProdutorExecutado = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(analiseNotifierProvider.notifier).repararProdutoresLegados();
      });
    }

    final safras = analisesRaw
        .map((e) => e.safra)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final mostrandoAmostrasHeader = _selectedFolderKey != null;

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Análise de Solo'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(safras.isNotEmpty ? 148 : 140),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _HeaderFilterPanel(
                  searchController: _searchController,
                  searchQuery: _searchQuery,
                  onSearchChanged: (val) => setState(() => _searchQuery = val),
                  selectedCultura: _selectedCultura,
                  todasCulturasValue: _todasCulturasValue,
                  safras: safras,
                  selectedSafra: _selectedSafra,
                  onCulturaChanged: (value) {
                    setState(() {
                      _selectedCultura =
                          value == _todasCulturasValue ? null : value;
                    });
                  },
                  onSafraChanged: (safra) {
                    setState(() {
                      _selectedSafra = _selectedSafra == safra ? null : safra;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mostrandoAmostrasHeader
                          ? (_selectedFolderHeaderTitle ?? 'Amostras')
                          : 'Pastas de Análises',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (mostrandoAmostrasHeader) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedFolderKey = null;
                            _selectedFolderHeaderTitle = null;
                            _isSelectingAnalises = false;
                            _selectedAnaliseIds.clear();
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          foregroundColor: const Color(0xFF007AFF),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: Text(
                          'Voltar para pastas',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (_isSelectingAnalises)
                            Text(
                              '${_selectedAnaliseIds.length} selecionada(s)',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecond,
                              ),
                            ),
                          const Spacer(),
                          if (_isSelectingAnalises) ...[
                            TextButton(
                              onPressed: _selectedAnaliseIds.isEmpty
                                  ? null
                                  : () => _confirmarExcluirAnalisesSelecionadas(
                                        context,
                                      ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                              child: const Text('Excluir'),
                            ),
                            TextButton(
                              onPressed: _cancelarSelecaoAnalises,
                              child: const Text('Cancelar'),
                            ),
                          ] else
                            TextButton.icon(
                              onPressed: _iniciarSelecaoAnalises,
                              icon: const Icon(Icons.checklist_rounded),
                              label: const Text('Selecionar'),
                            ),
                        ],
                      ),
                    ],
                    if (!mostrandoAmostrasHeader) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (_isSelectingFolders)
                            Text(
                              '${_selectedFolderKeys.length} selecionada(s)',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecond,
                              ),
                            ),
                          const Spacer(),
                          if (_isSelectingFolders) ...[
                            TextButton(
                              onPressed: _selectedFolderKeys.isEmpty
                                  ? null
                                  : () => _confirmarExcluirPastasSelecionadas(
                                        context,
                                      ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                              child: const Text('Excluir'),
                            ),
                            TextButton(
                              onPressed: _cancelarSelecaoPastas,
                              child: const Text('Cancelar'),
                            ),
                          ] else
                            TextButton.icon(
                              onPressed: _iniciarSelecaoPastas,
                              icon: const Icon(Icons.checklist_rounded),
                              label: const Text('Selecionar'),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            analiseState.when(
              skipLoadingOnRefresh: true,
              skipLoadingOnReload: true,
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: _AnaliseLoadError(
                  error: err,
                  onRetry: () => ref.invalidate(analiseNotifierProvider),
                ),
              ),
              data: (listaCompleta) {
                final analises = _filtrarAnalises(
                  listaCompleta,
                  cultura: culturaEnum,
                  safra: _selectedSafra,
                  busca: _searchQuery,
                );
                final pastas = _agruparPorPasta(analises);
                _sincronizarSelecaoComPastasVisiveis(pastas);
                _AnaliseFolderSummary? pastaSelecionada;
                if (_selectedFolderKey != null) {
                  for (final pasta in pastas) {
                    if (pasta.key == _selectedFolderKey) {
                      pastaSelecionada = pasta;
                      break;
                    }
                  }
                  if (pastaSelecionada == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      setState(() => _selectedFolderKey = null);
                    });
                  }
                }
                final mostrandoAmostras = pastaSelecionada != null;
                if (mostrandoAmostras) {
                  _sincronizarSelecaoComAnalisesVisiveis(
                    pastaSelecionada.analises,
                  );
                } else {
                  _limparSelecaoAnalisesSeNecessario();
                }
                final itensGrid =
                    mostrandoAmostras ? pastaSelecionada.analises : pastas;
                final showNovaAnaliseCard = mostrandoAmostras
                    ? !_isSelectingAnalises
                    : !_isSelectingFolders;

                if (analises.isEmpty && !mostrandoAmostras) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                      child: _AnaliseEmptyState(
                        onImport: () => _importarPdf(context),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (showNovaAnaliseCard && index == itensGrid.length) {
                          return _ImportarPdfCard(
                            onTap: () => _importarPdf(context),
                          );
                        }

                        if (!mostrandoAmostras) {
                          final pasta =
                              itensGrid[index] as _AnaliseFolderSummary;
                          return _PastaAnaliseCard(
                            pasta: pasta,
                            isSelectionMode: _isSelectingFolders,
                            isSelected: _selectedFolderKeys.contains(pasta.key),
                            onTap: () {
                              if (_isSelectingFolders) {
                                _alternarSelecaoPasta(pasta.key);
                                return;
                              }
                              setState(() {
                                _selectedFolderKey = pasta.key;
                                _selectedFolderHeaderTitle =
                                    pasta.cardLabels.titulo;
                              });
                            },
                            onLongPress: () {
                              if (_isSelectingFolders) {
                                _alternarSelecaoPasta(pasta.key);
                                return;
                              }
                              _showPastaOptionsSheet(context, pasta);
                            },
                          );
                        }

                        final analise = itensGrid[index] as AnaliseSolo;
                        return _AnaliseAmostraCard(
                          analise: analise,
                          isSelectionMode: _isSelectingAnalises,
                          isSelected: _selectedAnaliseIds.contains(analise.id),
                          onTap: () {
                            if (_isSelectingAnalises) {
                              _alternarSelecaoAnalise(analise.id);
                              return;
                            }
                            context.push(
                              '${AppRoutes.analise}/detalhe/${analise.id}',
                            );
                          },
                          onLongPress: () {
                            if (_isSelectingAnalises) {
                              _alternarSelecaoAnalise(analise.id);
                              return;
                            }
                            _showAnaliseOptionsSheet(context, analise);
                          },
                        );
                      },
                      childCount:
                          itensGrid.length + (showNovaAnaliseCard ? 1 : 0),
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  void _iniciarSelecaoPastas() {
    setState(() {
      _isSelectingFolders = true;
      _selectedFolderKey = null;
      _selectedFolderKeys.clear();
    });
  }

  void _cancelarSelecaoPastas() {
    setState(() {
      _isSelectingFolders = false;
      _selectedFolderKeys.clear();
    });
  }

  void _alternarSelecaoPasta(String pastaKey) {
    setState(() {
      if (_selectedFolderKeys.contains(pastaKey)) {
        _selectedFolderKeys.remove(pastaKey);
        return;
      }
      _selectedFolderKeys.add(pastaKey);
    });
  }

  void _iniciarSelecaoAnalises() {
    setState(() {
      _isSelectingAnalises = true;
      _selectedAnaliseIds.clear();
    });
  }

  void _cancelarSelecaoAnalises() {
    setState(() {
      _isSelectingAnalises = false;
      _selectedAnaliseIds.clear();
    });
  }

  void _alternarSelecaoAnalise(String analiseId) {
    setState(() {
      if (_selectedAnaliseIds.contains(analiseId)) {
        _selectedAnaliseIds.remove(analiseId);
        return;
      }
      _selectedAnaliseIds.add(analiseId);
    });
  }

  void _sincronizarSelecaoComPastasVisiveis(
    List<_AnaliseFolderSummary> pastas,
  ) {
    if (_selectedFolderKeys.isEmpty && !_isSelectingFolders) return;
    final chavesVisiveis = pastas.map((pasta) => pasta.key).toSet();
    final selecionadasAtualizadas =
        _selectedFolderKeys.where(chavesVisiveis.contains).toSet();
    final mudouSelecao =
        selecionadasAtualizadas.length != _selectedFolderKeys.length;
    final deveSairDaSelecao = _isSelectingFolders && chavesVisiveis.isEmpty;
    if (!mudouSelecao && !deveSairDaSelecao) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedFolderKeys
          ..clear()
          ..addAll(selecionadasAtualizadas);
        if (deveSairDaSelecao) {
          _isSelectingFolders = false;
        }
      });
    });
  }

  void _sincronizarSelecaoComAnalisesVisiveis(List<AnaliseSolo> analises) {
    if (_selectedAnaliseIds.isEmpty && !_isSelectingAnalises) return;
    final idsVisiveis = analises.map((analise) => analise.id).toSet();
    final selecionadasAtualizadas =
        _selectedAnaliseIds.where(idsVisiveis.contains).toSet();
    final mudouSelecao =
        selecionadasAtualizadas.length != _selectedAnaliseIds.length;
    final deveSairDaSelecao = _isSelectingAnalises && idsVisiveis.isEmpty;
    if (!mudouSelecao && !deveSairDaSelecao) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedAnaliseIds
          ..clear()
          ..addAll(selecionadasAtualizadas);
        if (deveSairDaSelecao) {
          _isSelectingAnalises = false;
        }
      });
    });
  }

  void _limparSelecaoAnalisesSeNecessario() {
    if (!_isSelectingAnalises && _selectedAnaliseIds.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _isSelectingAnalises = false;
        _selectedAnaliseIds.clear();
      });
    });
  }

  Future<void> _showPastaOptionsSheet(
    BuildContext context,
    _AnaliseFolderSummary pasta,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                pasta.cardLabels.titulo,
                style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                'Renomear Pasta',
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showRenomearPastaDialog(context, pasta);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(
                'Excluir Pasta',
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _confirmarExcluirPasta(context, pasta);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: AppColors.textSecond),
              title: Text(
                'Cancelar',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecond),
              ),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showRenomearPastaDialog(
    BuildContext context,
    _AnaliseFolderSummary pasta,
  ) async {
    final controller = TextEditingController(text: pasta.cardLabels.titulo);

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setStateDialog) {
            final nome = controller.text.trim();
            final desabilitado =
                nome.isEmpty || nome == pasta.cardLabels.titulo;

            return AlertDialog(
              title: const Text('Renomear pasta'),
              content: TextFormField(
                controller: controller,
                autofocus: true,
                maxLength: 60,
                decoration: InputDecoration(
                  hintText: 'Nome da pasta',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onChanged: (_) => setStateDialog(() {}),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancelar',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecond,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: desabilitado
                      ? null
                      : () async {
                          Navigator.of(dialogContext).pop();
                          await _executarRenomearPasta(pasta, nome);
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _executarRenomearPasta(
    _AnaliseFolderSummary pasta,
    String novoNome,
  ) async {
    try {
      await ref.read(analiseNotifierProvider.notifier).renomearPasta(
            analiseIds: pasta.analises.map((a) => a.id).toList(growable: false),
            novoNome: novoNome,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pasta renomeada'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao renomear. Tente novamente.'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmarExcluirPasta(
    BuildContext context,
    _AnaliseFolderSummary pasta,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir pasta?'),
        content: Text(
          'Esta ação não pode ser desfeita. '
          'Todas as ${pasta.analises.length} análise(s) desta pasta também serão excluídas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _excluirPasta(pasta);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirPasta(_AnaliseFolderSummary pasta) async {
    try {
      final ids = pasta.analises.map((analise) => analise.id).toList();
      await ref.read(analiseNotifierProvider.notifier).excluirPasta(ids);
      if (!mounted) return;
      setState(() {
        if (_selectedFolderKey == pasta.key) {
          _selectedFolderKey = null;
        }
        _selectedFolderKeys.remove(pasta.key);
        if (_isSelectingFolders && _selectedFolderKeys.isEmpty) {
          _isSelectingFolders = false;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pasta excluída'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir pasta. Tente novamente.'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmarExcluirPastasSelecionadas(BuildContext context) async {
    final analises =
        ref.read(analiseNotifierProvider).valueOrNull ?? const <AnaliseSolo>[];
    final Cultura? culturaSelecionada = _selectedCultura == null
        ? null
        : Cultura.values.firstWhere(
            (e) => e.label == _selectedCultura,
            orElse: () => Cultura.soja,
          );
    final pastasSelecionadas = _agruparPorPasta(
      _filtrarAnalises(
        analises,
        cultura: culturaSelecionada,
        safra: _selectedSafra,
        busca: _searchQuery,
      ),
    )
        .where((pasta) => _selectedFolderKeys.contains(pasta.key))
        .toList(growable: false);

    if (pastasSelecionadas.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione ao menos uma pasta para excluir.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final totalPastas = pastasSelecionadas.length;
    final totalAnalises = pastasSelecionadas.fold<int>(
      0,
      (acc, pasta) => acc + pasta.analises.length,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir pastas selecionadas?'),
        content: Text(
          'Esta ação não pode ser desfeita. '
          '$totalPastas pasta(s) e $totalAnalises análise(s) serão excluídas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _excluirPastasSelecionadas(pastasSelecionadas);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarExcluirAnalisesSelecionadas(
    BuildContext context,
  ) async {
    final analises =
        ref.read(analiseNotifierProvider).valueOrNull ?? const <AnaliseSolo>[];
    final Cultura? culturaSelecionada = _selectedCultura == null
        ? null
        : Cultura.values.firstWhere(
            (e) => e.label == _selectedCultura,
            orElse: () => Cultura.soja,
          );

    final pastasFiltradas = _agruparPorPasta(
      _filtrarAnalises(
        analises,
        cultura: culturaSelecionada,
        safra: _selectedSafra,
        busca: _searchQuery,
      ),
    );
    final pastaAtual = pastasFiltradas.where(
      (p) => p.key == _selectedFolderKey,
    );
    if (pastaAtual.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pasta não encontrada. Atualize e tente novamente.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final analisesSelecionadas = pastaAtual.first.analises
        .where((analise) => _selectedAnaliseIds.contains(analise.id))
        .toList(growable: false);
    if (analisesSelecionadas.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione ao menos uma amostra para excluir.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final totalAnalises = analisesSelecionadas.length;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir amostras selecionadas?'),
        content: Text(
          'Esta ação não pode ser desfeita. '
          '$totalAnalises amostra(s) serão excluídas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _excluirAnalisesSelecionadas(analisesSelecionadas);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirAnalisesSelecionadas(
    List<AnaliseSolo> analisesSelecionadas,
  ) async {
    try {
      final ids = analisesSelecionadas
          .map((analise) => analise.id)
          .toSet()
          .toList(growable: false);
      await ref.read(analiseNotifierProvider.notifier).excluirPasta(ids);
      if (!mounted) return;

      setState(() {
        for (final id in ids) {
          _selectedAnaliseIds.remove(id);
        }
        if (_selectedAnaliseIds.isEmpty) {
          _isSelectingAnalises = false;
        }
      });

      final total = ids.length;
      final label =
          total == 1 ? '1 amostra excluída' : '$total amostras excluídas';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(label), duration: const Duration(seconds: 2)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir amostras. Tente novamente.'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _excluirPastasSelecionadas(
    List<_AnaliseFolderSummary> pastasSelecionadas,
  ) async {
    try {
      final ids = <String>{
        for (final pasta in pastasSelecionadas)
          ...pasta.analises.map((analise) => analise.id),
      }.toList(growable: false);
      await ref.read(analiseNotifierProvider.notifier).excluirPasta(ids);
      if (!mounted) return;

      final removeSelectedFolder = _selectedFolderKey != null &&
          pastasSelecionadas.any((pasta) => pasta.key == _selectedFolderKey);
      setState(() {
        if (removeSelectedFolder) {
          _selectedFolderKey = null;
        }
        _selectedFolderKeys.clear();
        _isSelectingFolders = false;
      });

      final totalPastas = pastasSelecionadas.length;
      final pastasLabel = totalPastas == 1
          ? '1 pasta excluída'
          : '$totalPastas pastas excluídas';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pastasLabel),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir pastas. Tente novamente.'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _showAnaliseOptionsSheet(
    BuildContext context,
    AnaliseSolo analise,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                analise.talhao.trim().isEmpty ? 'Análise' : analise.talhao,
                style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(
                'Excluir Análise',
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _confirmarExcluirAnalise(context, analise);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.drive_file_move_outline,
                color: AppColors.primary,
              ),
              title: Text('Mover para outra pasta', style: AppTextStyles.body),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Em breve'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: AppColors.textSecond),
              title: Text(
                'Cancelar',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecond),
              ),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarExcluirAnalise(
    BuildContext context,
    AnaliseSolo analise,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir análise?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _excluirAnalise(analise);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirAnalise(AnaliseSolo analise) async {
    try {
      await ref
          .read(analiseNotifierProvider.notifier)
          .excluirAnalise(analise.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Análise excluída'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao excluir. Tente novamente.'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  List<_AnaliseFolderSummary> _agruparPorPasta(List<AnaliseSolo> analises) {
    final map = <String, _AnaliseFolderSummary>{};
    for (final analise in analises) {
      final laboratorio = analise.laboratorio.trim().isEmpty
          ? 'Laboratório não informado'
          : analise.laboratorio.trim();
      final groupId = _extrairGroupId(analise);
      final groupTitle = _extrairGroupTitle(analise);
      final os = _extrairOs(analise);
      // Chave do produtor para agrupar análises do mesmo cliente
      final produtor = analise.produtor.trim();
      final fazenda = analise.fazenda.trim();
      final produtorKey = produtor.isNotEmpty
          ? produtor.toLowerCase()
          : (fazenda.isNotEmpty ? fazenda.toLowerCase() : 'sem-produtor');

      final folderKey = groupId.isNotEmpty
          ? 'group:$groupId'
          : (os.isNotEmpty
              ? 'produtor:$produtorKey::os:$os'
              : 'produtor:$produtorKey');

      final folderOs = groupId.isNotEmpty
          ? (os.isNotEmpty
              ? os
              : (groupTitle.isNotEmpty ? groupTitle : groupId))
          : (os.isNotEmpty ? os : 'Importações antigas');

      final current = map[folderKey];
      if (current == null) {
        map[folderKey] = _AnaliseFolderSummary(
          key: folderKey,
          produtor: produtor,
          fazenda: fazenda,
          laboratorio: laboratorio,
          os: folderOs,
          nomeExibicao: groupTitle,
          analises: [analise],
          dataMaisRecente: analise.dataCadastro,
        );
        continue;
      }

      final atualizadas = [...current.analises, analise];
      final maisRecente = analise.dataCadastro.isAfter(current.dataMaisRecente)
          ? analise.dataCadastro
          : current.dataMaisRecente;
      map[folderKey] = _AnaliseFolderSummary(
        key: current.key,
        produtor: current.produtor,
        fazenda: current.fazenda,
        laboratorio: current.laboratorio,
        os: current.os,
        nomeExibicao: current.nomeExibicao,
        analises: atualizadas,
        dataMaisRecente: maisRecente,
      );
    }

    final pastas = map.values.toList(growable: false);
    pastas.sort((a, b) => b.dataMaisRecente.compareTo(a.dataMaisRecente));
    return pastas;
  }

  List<AnaliseSolo> _filtrarAnalises(
    List<AnaliseSolo> lista, {
    Cultura? cultura,
    String? produtorId,
    String? safra,
    String? busca,
  }) {
    return lista.where((analise) {
      if (cultura != null && analise.cultura != cultura) return false;
      if (produtorId != null && analise.produtor != produtorId) return false;
      if (safra != null && analise.safra != safra) return false;
      if (busca != null && busca.isNotEmpty) {
        final query = busca.toLowerCase();
        return analise.talhao.toLowerCase().contains(query) ||
            analise.laboratorio.toLowerCase().contains(query) ||
            analise.produtor.toLowerCase().contains(query) ||
            analise.fazenda.toLowerCase().contains(query);
      }
      return true;
    }).toList(growable: false);
  }

  String _extrairOs(AnaliseSolo analise) {
    final metadata = analise.laudoMetadata;
    if (metadata == null) return '';
    for (final key in const ['os', 'relatorio', 'laudoNumero', 'analise']) {
      final value = metadata[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  String _extrairGroupId(AnaliseSolo analise) {
    final metadata = analise.laudoMetadata;
    if (metadata == null) return '';
    return metadata['groupId']?.toString().trim() ?? '';
  }

  String _extrairGroupTitle(AnaliseSolo analise) {
    final metadata = analise.laudoMetadata;
    if (metadata == null) return '';
    return metadata['groupTitle']?.toString().trim() ?? '';
  }
}

class _AnaliseLoadError extends StatefulWidget {
  const _AnaliseLoadError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  State<_AnaliseLoadError> createState() => _AnaliseLoadErrorState();
}

class _AnaliseLoadErrorState extends State<_AnaliseLoadError> {
  @override
  void initState() {
    super.initState();
    debugPrint('Erro visível na tela de análise: ${widget.error}');
  }

  @override
  void didUpdateWidget(covariant _AnaliseLoadError oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.error != widget.error) {
      debugPrint('Erro visível na tela de análise: ${widget.error}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dados da nuvem',
              style: AppTextStyles.headline.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.error.toString(),
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnaliseFolderSummary {
  const _AnaliseFolderSummary({
    required this.key,
    required this.produtor,
    required this.fazenda,
    required this.laboratorio,
    required this.os,
    required this.nomeExibicao,
    required this.analises,
    required this.dataMaisRecente,
  });

  final String key;
  final String produtor;
  final String fazenda;
  final String laboratorio;
  final String os;
  final String nomeExibicao;
  final List<AnaliseSolo> analises;
  final DateTime dataMaisRecente;

  AnalisePastaCardLabels get cardLabels {
    if (nomeExibicao.trim().isNotEmpty) {
      final detalhePartes = <String>[
        if (laboratorio.trim().isNotEmpty &&
            laboratorio.trim().toLowerCase() !=
                nomeExibicao.trim().toLowerCase())
          laboratorio.trim(),
        if (os.trim().isNotEmpty) 'O.S. ${os.trim()}',
      ];
      return AnalisePastaCardLabels(
        titulo: nomeExibicao.trim(),
        subtitulo: produtor.trim().isNotEmpty
            ? produtor.trim()
            : (fazenda.trim().isNotEmpty ? fazenda.trim() : ''),
        detalhe: detalhePartes.join(' · '),
      );
    }
    return buildPastaCardLabels(
      produtor: produtor,
      fazenda: fazenda,
      laboratorio: laboratorio,
      os: os,
    );
  }
}

class _HeaderFilterPanel extends StatelessWidget {
  const _HeaderFilterPanel({
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedCultura,
    required this.todasCulturasValue,
    required this.safras,
    required this.selectedSafra,
    required this.onCulturaChanged,
    required this.onSafraChanged,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String? selectedCultura;
  final String todasCulturasValue;
  final List<String> safras;
  final String? selectedSafra;
  final ValueChanged<String?> onCulturaChanged;
  final ValueChanged<String> onSafraChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderSoft.withValues(alpha: 0.9),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Buscar área, produtor, cultura...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: const Color(0xFFA1A1A6),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.search_rounded,
                    size: 22,
                    color: Color(0xFF6E6E73),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 42,
                  minHeight: 42,
                ),
                suffixIcon: searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppDropdown<String>(
                  value: selectedCultura ?? todasCulturasValue,
                  hint: 'Cultura',
                  borderRadius: 14,
                  items: [
                    AppDropdownItem<String>(
                      value: todasCulturasValue,
                      label: 'Todas culturas',
                    ),
                    ...Cultura.values.map(
                      (cultura) => AppDropdownItem<String>(
                        value: cultura.label,
                        label: cultura.label,
                      ),
                    ),
                  ],
                  onChanged: onCulturaChanged,
                ),
              ),
              if (safras.isNotEmpty) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: safras
                              .map(
                                (safra) => Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: _SafraChip(
                                    label: safra,
                                    isSelected: selectedSafra == safra,
                                    onTap: () => onSafraChanged(safra),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SafraChip extends StatelessWidget {
  const _SafraChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.10)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.22)
              : AppColors.borderSoft,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.03 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.textSecond,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardSurface extends StatefulWidget {
  const _CardSurface({
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.selectionColor = AppColors.primary,
    this.borderRadius = 20,
  });

  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final Color selectionColor;
  final double borderRadius;

  @override
  State<_CardSurface> createState() => _CardSurfaceState();
}

class _CardSurfaceState extends State<_CardSurface> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final shadowColor = widget.isSelected
        ? widget.selectionColor.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.04);

    return AnimatedScale(
      scale: _pressed ? 0.988 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.isSelected
                ? widget.selectionColor.withValues(alpha: 0.30)
                : AppColors.borderSoft.withValues(alpha: 0.95),
            width: widget.isSelected ? 1.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: widget.isSelected ? 12 : 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            splashColor: widget.selectionColor.withValues(alpha: 0.05),
            highlightColor: Colors.transparent,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _PastaAnaliseCard extends StatelessWidget {
  const _PastaAnaliseCard({
    required this.pasta,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final _AnaliseFolderSummary pasta;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final total = pasta.analises.length;
    final totalLabel = total == 1 ? '1 amostra' : '$total amostras';
    final labels = pasta.cardLabels;
    return _CardSurface(
      onTap: onTap,
      onLongPress: onLongPress,
      isSelected: isSelected,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelectionMode) ...[
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color:
                      isSelected ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              labels.titulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1D1D1F),
                letterSpacing: -0.1,
              ),
            ),
            if (labels.subtitulo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                labels.subtitulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecond,
                ),
              ),
            ],
            if (labels.detalhe.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                labels.detalhe,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF8E8E93),
                ),
              ),
            ],
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                totalLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnaliseAmostraCard extends StatelessWidget {
  const _AnaliseAmostraCard({
    required this.analise,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final AnaliseSolo analise;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final labels = buildAmostraCardLabels(analise);

    return _CardSurface(
      onTap: onTap,
      onLongPress: onLongPress,
      isSelected: isSelected,
      selectionColor: analise.cultura.color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelectionMode) ...[
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? analise.cultura.color
                      : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: analise.cultura.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  analise.cultura.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              labels.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              labels.subtitulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (labels.detalhe.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                labels.detalhe,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecond,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnaliseEmptyState extends StatelessWidget {
  const _AnaliseEmptyState({required this.onImport});

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nenhuma análise importada',
              textAlign: TextAlign.center,
              style: AppTextStyles.headline.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'Importe o PDF do laboratório para começar a organizar amostras por talhão.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecond),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.upload_file_outlined, size: 20),
                label: const Text('Importar PDF'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportarPdfCard extends StatelessWidget {
  const _ImportarPdfCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _CardSurface(
      onTap: onTap,
      borderRadius: 20,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.border.withValues(alpha: 0.95),
          strokeWidth: 1.4,
          dashWidth: 8,
          dashSpace: 6,
          radius: 20,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.upload_file_outlined,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Importar PDF',
                style: AppTextStyles.label.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecond,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        final segment = metric.extractPath(distance, next);
        canvas.drawPath(segment, paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.radius != radius;
  }
}
