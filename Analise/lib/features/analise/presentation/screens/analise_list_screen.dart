import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
import 'package:soloforte/features/analise/presentation/widgets/produtor_row_widget.dart';
import 'package:soloforte/features/analise/presentation/widgets/filter_chips_widget.dart';

class AnaliseListScreen extends ConsumerStatefulWidget {
  const AnaliseListScreen({super.key});

  @override
  ConsumerState<AnaliseListScreen> createState() => _AnaliseListScreenState();
}

class _AnaliseListScreenState extends ConsumerState<AnaliseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedCultura;
  String? _selectedSafra;
  String? _selectedFolderKey;
  String _searchQuery = '';

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
    final analisesRaw = analiseState.valueOrNull ?? [];

    final safras = analisesRaw
        .map((e) => e.safra)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final analises = ref.watch(
      analisesFiltradasProvider(
        cultura: culturaEnum,
        safra: _selectedSafra,
        busca: _searchQuery,
      ),
    );
    final pastas = _agruparPorPasta(analises);
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
    final itensGrid = mostrandoAmostras ? pastaSelecionada.analises : pastas;

    final produtores = ref.watch(produtoresAnaliseProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Análise de Solo'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(safras.isNotEmpty ? 170 : 130),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Buscar área, produtor, cultura...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilterChipsWidget(
                labels: Cultura.values.map((e) => e.label).toList(),
                selectedLabel: _selectedCultura,
                onSelected: (label) {
                  setState(() {
                    _selectedCultura = _selectedCultura == label ? null : label;
                  });
                },
              ),
              if (safras.isNotEmpty) ...[
                const SizedBox(height: 8),
                FilterChipsWidget(
                  labels: safras,
                  selectedLabel: _selectedSafra,
                  onSelected: (label) {
                    setState(() {
                      _selectedSafra = _selectedSafra == label ? null : label;
                    });
                  },
                ),
              ],
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
              child: produtores.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Produtores',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: produtores.length,
                          itemBuilder: (context, index) {
                            return ProdutorRowWidget(
                              produtor: produtores[index],
                            );
                          },
                        ),
                        const Divider(),
                      ],
                    ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mostrandoAmostras ? 'Amostras' : 'Pastas de Análises',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (mostrandoAmostras) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _selectedFolderKey = null),
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
                    ],
                  ],
                ),
              ),
            ),
            analiseState.when(
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
                if (listaCompleta.isEmpty && !mostrandoAmostras) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.analytics_outlined,
                                size: 64, color: AppColors.textTertiary),
                            const SizedBox(height: 24),
                            Text(
                              'Nenhuma análise encontrada',
                              style: AppTextStyles.headline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Você ainda não possui análises salvas na nuvem. Se estiver testando, você pode ativar o Modo de Demonstração nas Configurações.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.textSecond),
                            ),
                            const SizedBox(height: 32),
                            _NovaAnaliseCard(
                              onTap: () => context.push(AppRoutes.analiseForm),
                            ),
                          ],
                        ),
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
                        if (index == itensGrid.length) {
                          return _NovaAnaliseCard(
                            onTap: () => context.push(AppRoutes.analiseForm),
                          );
                        }

                        if (!mostrandoAmostras) {
                          final pasta =
                              itensGrid[index] as _AnaliseFolderSummary;
                          return _PastaAnaliseCard(
                            pasta: pasta,
                            onTap: () {
                              setState(() {
                                _selectedFolderKey = pasta.key;
                              });
                            },
                            onLongPress: () =>
                                _showPastaOptionsSheet(context, pasta),
                          );
                        }

                        final analise = itensGrid[index] as AnaliseSolo;
                        return _AnaliseAmostraCard(
                          analise: analise,
                          onTap: () {
                            context.push(
                                '${AppRoutes.analise}/detalhe/${analise.id}');
                          },
                          onLongPress: () =>
                              _showAnaliseOptionsSheet(context, analise),
                        );
                      },
                      childCount: itensGrid.length + 1,
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
                pasta.laboratorio,
                style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading:
                  const Icon(Icons.edit_outlined, color: AppColors.primary),
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
    final controller = TextEditingController(text: pasta.laboratorio);

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setStateDialog) {
            final nome = controller.text.trim();
            final desabilitado = nome.isEmpty || nome == pasta.laboratorio;

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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (_) => setStateDialog(() {}),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancelar',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecond),
                  ),
                ),
                TextButton(
                  onPressed: desabilitado
                      ? null
                      : () async {
                          Navigator.of(dialogContext).pop();
                          await _executarRenomearPasta(pasta, nome);
                        },
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.primary),
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
      if (_selectedFolderKey == pasta.key) {
        setState(() => _selectedFolderKey = null);
      }
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
              title: Text(
                'Mover para outra pasta',
                style: AppTextStyles.body,
              ),
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
      final metadata = analise.laudoMetadata;
      final groupId = _extrairGroupId(analise);
      final groupTitle = _extrairGroupTitle(analise);
      final os = _extrairOs(analise);
      final isLegacy = metadata != null &&
          metadata.isNotEmpty &&
          groupId.isEmpty &&
          os.isEmpty;
      final folderKey = groupId.isNotEmpty
          ? 'group:$groupId'
          : (isLegacy
              ? 'legacy:$laboratorio'
              : (os.isNotEmpty ? '$laboratorio::$os' : 'manual:${analise.id}'));
      final folderOs = groupId.isNotEmpty
          ? (os.isNotEmpty
              ? os
              : (groupTitle.isNotEmpty ? groupTitle : groupId))
          : (isLegacy ? 'Importações antigas' : (os.isEmpty ? 'Sem O.S.' : os));

      final current = map[folderKey];
      if (current == null) {
        map[folderKey] = _AnaliseFolderSummary(
          key: folderKey,
          laboratorio: laboratorio,
          os: folderOs,
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
        laboratorio: current.laboratorio,
        os: current.os,
        analises: atualizadas,
        dataMaisRecente: maisRecente,
      );
    }

    final pastas = map.values.toList(growable: false);
    pastas.sort((a, b) => b.dataMaisRecente.compareTo(a.dataMaisRecente));
    return pastas;
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
  const _AnaliseLoadError({
    required this.error,
    required this.onRetry,
  });

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
    required this.laboratorio,
    required this.os,
    required this.analises,
    required this.dataMaisRecente,
  });

  final String key;
  final String laboratorio;
  final String os;
  final List<AnaliseSolo> analises;
  final DateTime dataMaisRecente;
}

class _PastaAnaliseCard extends StatelessWidget {
  const _PastaAnaliseCard({
    required this.pasta,
    required this.onTap,
    required this.onLongPress,
  });

  final _AnaliseFolderSummary pasta;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final total = pasta.analises.length;
    final totalLabel = total == 1 ? '1 amostra' : '$total amostras';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.folder_open_rounded,
                  size: 42,
                  color: Color(0xFF007AFF),
                ),
                const SizedBox(height: 10),
                Text(
                  pasta.laboratorio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1D1D1F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'O.S.: ${pasta.os}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF86868B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF34C759),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnaliseAmostraCard extends StatelessWidget {
  const _AnaliseAmostraCard({
    required this.analise,
    required this.onTap,
    required this.onLongPress,
  });

  final AnaliseSolo analise;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final titulo =
        analise.talhao.trim().isEmpty ? 'Sem talhão' : analise.talhao;
    final subtitulo = analise.safra.trim().isEmpty
        ? analise.cultura.label
        : '${analise.cultura.label} · ${analise.safra}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.science,
                  size: 48,
                  color: analise.cultura.color,
                ),
                const SizedBox(height: 12),
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecond,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NovaAnaliseCard extends StatelessWidget {
  const _NovaAnaliseCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: const Color(0xFFD1D1D6),
            strokeWidth: 2,
            dashWidth: 8,
            dashSpace: 6,
            radius: 12,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_circle,
                    size: 48,
                    color: Color(0xFF34C759),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nova análise',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 13,
                      color: const Color(0xFF86868B),
                    ),
                  ),
                ],
              ),
            ),
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
