import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/data/culturas_data.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/calibracao_status_badge.dart';

class MicronutrientesCard extends ConsumerStatefulWidget {
  const MicronutrientesCard({
    super.key,
    required this.draftKey,
    required this.micros,
    required this.elementos,
    required this.grupos,
    required this.isExpanded,
    required this.onToggle,
    required this.onChanged,
  });

  static const title = 'Micronutrientes';
  static const Color accentColor = AppColors.micronut;

  final String draftKey;
  final Map<String, dynamic> micros;
  final Map<String, dynamic> elementos;
  final List<Map<String, dynamic>> grupos;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  ConsumerState<MicronutrientesCard> createState() =>
      _MicronutrientesCardState();
}

class _MicronutrientesCardState extends ConsumerState<MicronutrientesCard> {
  static const Duration _animDuration = Duration(milliseconds: 250);

  static const List<String> _viasMicros = [
    'Solo (correção)',
    'Foliar',
    'TS',
    'Ambas',
  ];

  static const List<String> _viasGrupo = ['Foliar', 'Solo', 'TS'];

  static const List<String> _elementosMicros = [
    'B',
    'Cu',
    'Fe',
    'Mn',
    'Zn',
    'Mo',
    'Co',
    'Ni',
    'Se',
  ];

  static const List<String> _referenciasMicrosBase = [
    '06 — Micronutrientes: Motor de Cálculo',
    'EMBRAPA Soja',
  ];

  final GlobalKey _cardKey = GlobalKey();
  final Map<String, bool> _expandedMicros = {};
  final Map<String, bool> _editandoInline = {};

  String _microTipoFonte = 'Autores';
  String? _microFonteNome;

  @override
  void initState() {
    super.initState();
    _syncAbsorcaoFromMicros();
    for (final simbolo in _elementosMicros) {
      _expandedMicros.putIfAbsent(simbolo, () => false);
    }
  }

  @override
  void didUpdateWidget(covariant MicronutrientesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAbsorcaoFromMicros();
    if (!oldWidget.isExpanded && widget.isExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _cardKey.currentContext;
        if (context != null && context.mounted) {
          Scrollable.ensureVisible(
            context,
            duration: _animDuration,
            curve: Curves.easeInOut,
            alignment: 0,
          );
        }
      });
    }
  }

  void _syncAbsorcaoFromMicros() {
    _microTipoFonte = widget.micros['microTipoFonte']?.toString() ?? 'Autores';
    _microFonteNome = widget.micros['microFonteNome']?.toString();
  }

  @override
  Widget build(BuildContext context) {
    final shadowColor = context.appPalette.shadow;

    return Container(
      key: _cardKey,
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.lg,
                  vertical: 14,
                ),
                child: _buildHeader(),
              ),
            ),
            AnimatedSize(
              duration: _animDuration,
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.hardEdge,
              child: widget.isExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.lg,
                        AppDimens.sm,
                        AppDimens.lg,
                        AppDimens.lg,
                      ),
                      child: _buildConteudo(),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final summaryLines = _collapsedSummaryLines();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFAF52DE),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                MicronutrientesCard.title,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: widget.isExpanded
                    ? const SizedBox.shrink()
                    : Column(
                        key: const ValueKey('micronutrientes-resumo'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildSummaryWidgets(summaryLines),
                      ),
              ),
            ],
          ),
        ),
        _buildChevron(onTap: widget.onToggle),
      ],
    );
  }

  List<String> _collapsedSummaryLines() {
    final fonte = _fonteAtualResumo();
    final grupos = widget.grupos;
    final elementosSelecionados = _elementosMicros
        .where(
          (simbolo) => grupos.any(
            (grupo) => ((grupo['elementos'] as List?) ?? const [])
                .map((e) => e.toString())
                .contains(simbolo),
          ),
        )
        .toList();

    return [
      fonte,
      _grupoResumo(grupos),
      _joinSegments(elementosSelecionados),
    ].where((line) => line.isNotEmpty).toList();
  }

  String _grupoResumo(List<Map<String, dynamic>> grupos) {
    if (grupos.isEmpty) return 'Nenhum grupo criado';
    if (grupos.length > 1) return '${grupos.length} grupos';

    final grupo = grupos.first;
    final nome = grupo['nome']?.toString().trim() ?? '';
    final via = grupo['via']?.toString().trim() ?? '';
    final detalhe = _joinSegments([nome, via]);
    return detalhe.isEmpty ? '1 grupo' : '1 grupo: $detalhe';
  }

  String _fonteAtualResumo() {
    final fontes = _fontesParaTipoMicro(_microTipoFonte);
    if (_microFonteNome != null &&
        fontes.contains(_microFonteNome) &&
        _microFonteNome!.trim().isNotEmpty) {
      return _microFonteNome!.trim();
    }
    return fontes.isNotEmpty ? fontes.first : '';
  }

  List<String> _fontesParaTipoMicro(String tipo) {
    if (tipo == 'Guidorizzi') return kTecnologias.keys.toList();
    if (tipo == 'Cultivar') return kCultivares.keys.toList();
    if (tipo == 'Personalizado') return const ['Personalizado'];
    return kAutores.keys.toList();
  }

  List<String> _fontesParaTipoElemento(String tipo) {
    if (tipo == 'Guidorizzi') return kTecnologias.keys.toList();
    if (tipo == 'Cultivar') return kCultivares.keys.toList();
    if (tipo == 'Personalizado') return const ['Personalizado'];
    return const [
      'Araújo (2023)',
      'Malavolta (1997)',
      'Fancelli (2020)',
      'Personalizado',
    ];
  }

  String _labelFonte(String tipo) {
    if (tipo == 'Guidorizzi') return 'Tecnologia';
    if (tipo == 'Cultivar') return 'Cultivar';
    return 'Autor';
  }

  String? _fonteAtual(List<String> fontes, dynamic value) {
    final raw = value?.toString();
    if (raw != null && fontes.contains(raw)) return raw;
    return fontes.isNotEmpty ? fontes.first : null;
  }

  String _tipoFonteElemento(Map<String, dynamic> elemento) {
    const tipos = ['Autores', 'Guidorizzi', 'Cultivar', 'Personalizado'];
    final raw = elemento['tipoFonte']?.toString();
    return tipos.contains(raw) ? raw! : 'Autores';
  }

  List<String> _normalizarViasGrupo(Map<String, dynamic> grupo) {
    return _normalizarListaVias(
      grupo['viasAplicacaoGrupo'] ?? grupo['via'],
      opcoes: _viasGrupo,
      fallback: 'Foliar',
    );
  }

  List<String> _normalizarViasElemento(Map<String, dynamic> elemento) {
    final raw = elemento['viasAplicacao'] ?? elemento['viaAplicacao'];
    if (raw is String) {
      if (raw == 'Ambas') return ['Solo', 'Foliar'];
      if (raw == 'Solo (correção)') return ['Solo'];
    }
    return _normalizarListaVias(
      raw,
      opcoes: const ['Solo', 'Foliar', 'TS'],
      fallback: 'Solo',
    );
  }

  List<String> _normalizarListaVias(
    dynamic raw, {
    required List<String> opcoes,
    required String fallback,
  }) {
    final valores = <String>[];
    if (raw is List) {
      valores.addAll(raw.map((item) => item.toString()));
    } else if (raw is String && raw.trim().isNotEmpty) {
      valores.add(raw.trim());
    }

    final filtrados = valores
        .where((item) => opcoes.contains(item))
        .toSet()
        .toList(growable: false);
    return filtrados.isEmpty ? [fallback] : filtrados;
  }

  String _viaLegadaElemento(List<String> vias) {
    if (vias.contains('Solo') && vias.contains('Foliar')) return 'Ambas';
    if (vias.contains('Solo')) return 'Solo (correção)';
    if (vias.contains('Foliar')) return 'Foliar';
    if (vias.contains('TS')) return 'TS';
    return _viasMicros.first;
  }

  List<Widget> _buildSummaryWidgets(List<String> lines) {
    final captionStyle = AppTextStyles.caption.copyWith(
      color: AppColors.textSecond,
    );
    return [
      for (final line in lines) ...[
        const SizedBox(height: 2),
        Text(
          line,
          style: captionStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ];
  }

  Widget _buildChevron({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedRotation(
        turns: widget.isExpanded ? 0.5 : 0.0,
        duration: _animDuration,
        curve: Curves.easeInOut,
        child: const Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.textSecond,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCamposViasGrupo({
    required Key key,
    required String draftKey,
    required Map<String, dynamic> grupo,
    required List<String> vias,
    required Map<String, dynamic> micros,
    required List<Map<String, dynamic>> grupos,
    required int index,
    required ValueChanged<Map<String, dynamic>> onChanged,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (vias.contains('Foliar')) ...[
          AppInput(
            key: ValueKey('$draftKey-grupo-fonte-foliar-$index'),
            label: 'Fonte foliar do grupo',
            initialValue: _string(
              grupo['fonteFoliarGrupo'] ?? grupo['produto'],
              fallback: 'Mistura manual',
            ),
            onChanged: (value) => _updateGrupo(
              micros: micros,
              grupos: grupos,
              index: index,
              patch: {'fonteFoliarGrupo': value, 'produto': value},
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 8),
          _buildNumericInput(
            keyValue: '$draftKey-grupo-ef-foliar-$index',
            label: 'Eficiência foliar (%)',
            value: _num(grupo['eficienciaFoliarGrupo'] ?? grupo['eficiencia'],
                fallback: 70),
            onChanged: (value) => _updateGrupo(
              micros: micros,
              grupos: grupos,
              index: index,
              patch: {'eficienciaFoliarGrupo': value, 'eficiencia': value},
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (vias.contains('Solo')) ...[
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '$draftKey-grupo-pct-solo-$index',
              label: '% correção solo do grupo',
              value: _num(grupo['percentualCorrecaoSoloGrupo'], fallback: 100),
              onChanged: (value) => _updateGrupo(
                micros: micros,
                grupos: grupos,
                index: index,
                patch: {'percentualCorrecaoSoloGrupo': value},
                onChanged: onChanged,
              ),
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-grupo-teor-solo-$index',
              label: 'Teor fonte solo (%)',
              value: _num(grupo['teorFonteSoloGrupo']),
              onChanged: (value) => _updateGrupo(
                micros: micros,
                grupos: grupos,
                index: index,
                patch: {'teorFonteSoloGrupo': value},
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AppInput(
            key: ValueKey('$draftKey-grupo-fonte-solo-$index'),
            label: 'Fonte solo do grupo',
            initialValue: _string(grupo['fonteSoloGrupo'], fallback: ''),
            onChanged: (value) => _updateGrupo(
              micros: micros,
              grupos: grupos,
              index: index,
              patch: {'fonteSoloGrupo': value},
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 8),
          _buildNumericInput(
            keyValue: '$draftKey-grupo-ef-solo-$index',
            label: 'Eficiência solo (%)',
            value: _num(grupo['eficienciaSoloGrupo'], fallback: 30),
            onChanged: (value) => _updateGrupo(
              micros: micros,
              grupos: grupos,
              index: index,
              patch: {'eficienciaSoloGrupo': value},
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (vias.contains('TS')) ...[
          AppInput(
            key: ValueKey('$draftKey-grupo-fonte-ts-$index'),
            label: 'Fonte TS do grupo',
            initialValue: _string(grupo['fonteTsGrupo'], fallback: ''),
            onChanged: (value) => _updateGrupo(
              micros: micros,
              grupos: grupos,
              index: index,
              patch: {'fonteTsGrupo': value},
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 8),
          _buildNumericInput(
            keyValue: '$draftKey-grupo-dose-ts-$index',
            label: 'Dose TS (g/100kg)',
            value: _num(grupo['doseTsGrupo']),
            onChanged: (value) => _updateGrupo(
              micros: micros,
              grupos: grupos,
              index: index,
              patch: {'doseTsGrupo': value},
              onChanged: onChanged,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReferenciaAbsorcaoElemento({
    required String tipoFonte,
    required List<String> fontes,
    required String? fonteAtual,
    required String labelFonte,
    required ValueChanged<String?> onTipoChanged,
    required ValueChanged<String?> onFonteChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REFERÊNCIA DE ABSORÇÃO',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecond,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        AppDropdown<String>(
          label: 'Tipo de Fonte',
          value: tipoFonte,
          items: const [
            AppDropdownItem(value: 'Autores', label: 'Autores'),
            AppDropdownItem(value: 'Guidorizzi', label: 'Guidorizzi'),
            AppDropdownItem(value: 'Cultivar', label: 'Cultivar'),
            AppDropdownItem(value: 'Personalizado', label: 'Personalizado'),
          ],
          onChanged: onTipoChanged,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: tipoFonte == 'Autores'
              ? Padding(
                  key: const ValueKey('autor'),
                  padding: const EdgeInsets.only(top: 8),
                  child: AppDropdown<String>(
                    label: labelFonte,
                    value: fonteAtual,
                    items: fontes
                        .map(
                          (item) => AppDropdownItem(value: item, label: item),
                        )
                        .toList(),
                    onChanged: onFonteChanged,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('sem-autor')),
        ),
      ],
    );
  }

  Widget _buildCamposViasElemento({
    required Key key,
    required String draftKey,
    required String simbolo,
    required Map<String, dynamic> elemento,
    required List<String> vias,
    required Map<String, dynamic> micros,
    required Map<String, dynamic> elementos,
    required ValueChanged<Map<String, dynamic>> onChanged,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (vias.contains('Solo')) ...[
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '$draftKey-$simbolo-pct-solo',
              label: '% correção solo',
              value: _num(elemento['percentualCorrecaoSolo'], fallback: 100),
              onChanged: (value) => _updateElementoMicro(
                micros: micros,
                elementos: elementos,
                simbolo: simbolo,
                patch: {'percentualCorrecaoSolo': value},
                onChanged: onChanged,
              ),
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-$simbolo-teor-solo',
              label: 'Teor fonte solo (%)',
              value: _num(elemento['teorFonteSolo']),
              onChanged: (value) => _updateElementoMicro(
                micros: micros,
                elementos: elementos,
                simbolo: simbolo,
                patch: {'teorFonteSolo': value},
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AppInput(
            key: ValueKey('$draftKey-$simbolo-fonte-solo'),
            label: 'Fonte solo',
            initialValue: _string(elemento['fonteSolo'], fallback: ''),
            onChanged: (value) => _updateElementoMicro(
              micros: micros,
              elementos: elementos,
              simbolo: simbolo,
              patch: {'fonteSolo': value},
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 8),
          _buildNumericInput(
            keyValue: '$draftKey-$simbolo-eff-solo',
            label: 'Eficiência solo (%)',
            value: _num(elemento['eficienciaSolo'], fallback: 30),
            onChanged: (value) => _updateElementoMicro(
              micros: micros,
              elementos: elementos,
              simbolo: simbolo,
              patch: {'eficienciaSolo': value},
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (vias.contains('Foliar')) ...[
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Teor foliar disponível?'),
            value: _bool(elemento['temAnaliseFoliar']),
            onChanged: (value) => _updateElementoMicro(
              micros: micros,
              elementos: elementos,
              simbolo: simbolo,
              patch: {'temAnaliseFoliar': value},
              onChanged: onChanged,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _bool(elemento['temAnaliseFoliar'])
                ? Column(
                    key: const ValueKey('foliar-campos'),
                    children: [
                      AppInput(
                        key: ValueKey('$draftKey-$simbolo-fonte-foliar'),
                        label: 'Fonte foliar',
                        initialValue:
                            _string(elemento['fonteFoliar'], fallback: ''),
                        onChanged: (value) => _updateElementoMicro(
                          micros: micros,
                          elementos: elementos,
                          simbolo: simbolo,
                          patch: {'fonteFoliar': value},
                          onChanged: onChanged,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildNumericInput(
                        keyValue: '$draftKey-$simbolo-eff-foliar',
                        label: 'Eficiência foliar (%)',
                        value: _num(elemento['eficienciaFoliar'], fallback: 70),
                        onChanged: (value) => _updateElementoMicro(
                          micros: micros,
                          elementos: elementos,
                          simbolo: simbolo,
                          patch: {'eficienciaFoliar': value},
                          onChanged: onChanged,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(key: ValueKey('foliar-vazio')),
          ),
          const SizedBox(height: 8),
        ],
        if (vias.contains('TS')) ...[
          AppInput(
            key: ValueKey('$draftKey-$simbolo-fonte-ts'),
            label: 'Fonte TS',
            initialValue: _string(elemento['fonteTs'], fallback: ''),
            onChanged: (value) => _updateElementoMicro(
              micros: micros,
              elementos: elementos,
              simbolo: simbolo,
              patch: {'fonteTs': value},
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 8),
          _buildNumericInput(
            keyValue: '$draftKey-$simbolo-dose-ts',
            label: 'Dose TS (g/100kg)',
            value: _num(elemento['doseTs']),
            onChanged: (value) => _updateElementoMicro(
              micros: micros,
              elementos: elementos,
              simbolo: simbolo,
              patch: {'doseTs': value},
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildConteudo() {
    final draftKey = widget.draftKey;
    final micros = widget.micros;
    final elementos = widget.elementos;
    final grupos = widget.grupos;
    final onChanged = widget.onChanged;
    final Set<String> elementosEmGrupos = grupos
        .expand<String>(
          (g) =>
              (g['elementos'] as List?)?.map((e) => e.toString()) ??
              const <String>[],
        )
        .toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () {
              final novoGrupo = {
                'id': 'grupo-${DateTime.now().microsecondsSinceEpoch}',
                'nome': 'Grupo ${grupos.length + 1}',
                'via': _viasGrupo.first,
                'viasAplicacaoGrupo': [_viasGrupo.first],
                'extrator': 'DTPA-TEA',
                'elementos': <String>[],
                'produto': 'Mistura manual',
                'eficiencia': 70.0,
              };
              final atualizado = {...micros};
              atualizado['grupos'] = [...grupos, novoGrupo];
              onChanged(atualizado);
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Criar Grupo de Aplicação'),
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 10),
        if (grupos.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: CalibracaoStatusBadge(
              icon: Icons.info_outline,
              color: AppColors.textSecond,
              label: 'Nenhum grupo de aplicação criado ainda.',
            ),
          ),
        ...grupos.asMap().entries.map((entry) {
          final index = entry.key;
          final grupo = entry.value;
          final nome = grupo['nome']?.toString() ?? 'Grupo ${index + 1}';
          final viasGrupo = _normalizarViasGrupo(grupo);
          final referenciaGrupo = grupo['referenciaNome'] as String? ?? '';
          const tiposFonteGrupo = ['Autores', 'Guidorizzi', 'Cultivar'];
          final tipoFonteGrupoRaw = grupo['microGrupoTipoFonte']?.toString();
          final tipoFonteGrupo = tiposFonteGrupo.contains(tipoFonteGrupoRaw)
              ? tipoFonteGrupoRaw!
              : tiposFonteGrupo.first;
          final fontesGrupo = tipoFonteGrupo == 'Guidorizzi'
              ? kTecnologias.keys.toList()
              : tipoFonteGrupo == 'Cultivar'
                  ? kCultivares.keys.toList()
                  : kAutores.keys.toList();
          final fonteGrupoRaw = grupo['microGrupoFonteNome']?.toString();
          final fonteGrupo = fontesGrupo.contains(fonteGrupoRaw)
              ? fonteGrupoRaw
              : (fontesGrupo.isNotEmpty ? fontesGrupo.first : null);
          final labelFonteGrupo = tipoFonteGrupo == 'Guidorizzi'
              ? 'Tecnologia'
              : tipoFonteGrupo == 'Cultivar'
                  ? 'Cultivar'
                  : 'Autor';
          final elementosGrupo = List<String>.from(
              (grupo['elementos'] as List?)?.map((e) => e.toString()) ??
                  const []);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.bgSecondary,
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppInput(
                          key: ValueKey('$draftKey-grupo-nome-$index'),
                          label: 'Nome do grupo',
                          initialValue: nome,
                          onChanged: (value) => _updateGrupo(
                            micros: micros,
                            grupos: grupos,
                            index: index,
                            patch: {'nome': value},
                            onChanged: onChanged,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error),
                        onPressed: () {
                          final atualizado = {...micros};
                          final novosGrupos = [...grupos]..removeAt(index);
                          atualizado['grupos'] = novosGrupos;
                          onChanged(atualizado);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppDropdown<String>(
                    label: 'Extrator',
                    value: _safeValue(
                      const [
                        'DTPA-TEA',
                        'Mehlich-1',
                        'HCl',
                        'Água quente (B)',
                        'Personalizado',
                      ],
                      _string(grupo['extrator'], fallback: 'DTPA-TEA'),
                    ),
                    items: const [
                      AppDropdownItem(value: 'DTPA-TEA', label: 'DTPA-TEA'),
                      AppDropdownItem(value: 'Mehlich-1', label: 'Mehlich-1'),
                      AppDropdownItem(value: 'HCl', label: 'HCl'),
                      AppDropdownItem(
                          value: 'Água quente (B)', label: 'Água quente (B)'),
                      AppDropdownItem(
                          value: 'Personalizado', label: 'Personalizado'),
                    ],
                    onChanged: (value) => _updateGrupo(
                      micros: micros,
                      grupos: grupos,
                      index: index,
                      patch: {'extrator': value ?? 'DTPA-TEA'},
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Via de aplicação do grupo',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecond,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _ViaToggleGroup(
                    selecionadas: viasGrupo,
                    opcoes: _viasGrupo,
                    onChanged: (value) => _updateGrupo(
                      micros: micros,
                      grupos: grupos,
                      index: index,
                      patch: {
                        'viasAplicacaoGrupo': value,
                        'via': value.first,
                      },
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _buildCamposViasGrupo(
                      key: ValueKey('grupo-vias-${viasGrupo.join('-')}-$index'),
                      draftKey: draftKey,
                      grupo: grupo,
                      vias: viasGrupo,
                      micros: micros,
                      grupos: grupos,
                      index: index,
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppDropdown<String>(
                    label: 'Referência bibliográfica',
                    value: _referenciasMicrosComPersonalizada
                            .contains(referenciaGrupo)
                        ? referenciaGrupo
                        : null,
                    items: _referenciasMicrosComPersonalizada
                        .map(
                            (item) => AppDropdownItem(value: item, label: item))
                        .toList(),
                    onChanged: (value) {
                      final referencia = value ?? '';
                      ref
                          .read(calibracaoControllerProvider.notifier)
                          .propagarNcParaGrupo(
                            grupoIndex: index,
                            referenciaNome: referencia,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'NC atualizado com base em $referencia',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                          backgroundColor: const Color(0xFF1D1D1F),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(milliseconds: 2500),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  AppDropdown<String>(
                    label: 'Tipo de Fonte (Absorção)',
                    value: tipoFonteGrupo,
                    items: tiposFonteGrupo
                        .map(
                            (item) => AppDropdownItem(value: item, label: item))
                        .toList(),
                    onChanged: (value) {
                      final novoTipo = value ?? tiposFonteGrupo.first;
                      _updateGrupo(
                        micros: micros,
                        grupos: grupos,
                        index: index,
                        patch: {
                          'microGrupoTipoFonte': novoTipo,
                          'microGrupoFonteNome': null,
                        },
                        onChanged: onChanged,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  AppDropdown<String>(
                    label: labelFonteGrupo,
                    value: fonteGrupo,
                    items: fontesGrupo
                        .map(
                            (item) => AppDropdownItem(value: item, label: item))
                        .toList(),
                    onChanged: (value) => _updateGrupo(
                      micros: micros,
                      grupos: grupos,
                      index: index,
                      patch: {'microGrupoFonteNome': value},
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Elementos deste grupo',
                        style: AppTextStyles.label),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _elementosMicros.map(
                      (simbolo) {
                        final isSelected = elementosGrupo.contains(simbolo);
                        return FilterChip(
                          label: Text(simbolo),
                          selected: isSelected,
                          selectedColor:
                              const Color(0xFF007AFF).withValues(alpha: 0.15),
                          checkmarkColor: const Color(0xFF007AFF),
                          backgroundColor: const Color(0xFFF2F2F7),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF007AFF)
                                : const Color(0xFF1D1D1F),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF007AFF)
                                : const Color(0xFFD1D1D6),
                            width: 1,
                          ),
                          onSelected: (selected) {
                            final atual = [...elementosGrupo];
                            if (selected) {
                              if (!atual.contains(simbolo)) {
                                atual.add(simbolo);
                              }
                            } else {
                              atual.remove(simbolo);
                            }
                            _updateGrupo(
                              micros: micros,
                              grupos: grupos,
                              index: index,
                              patch: {'elementos': atual},
                              onChanged: onChanged,
                            );
                          },
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        const SizedBox(height: 10),
        ..._elementosMicros
            .where((simbolo) => !elementosEmGrupos.contains(simbolo))
            .map((simbolo) {
          final elemento = _asMap(elementos[simbolo]);
          final propagadoDoGrupo = elemento['propagadoDoGrupo'] == true;
          final aberto = _expandedMicros[simbolo] ?? false;
          final classe = _classeMicro(elemento);
          final chaveReferencia = '${simbolo}referencia';
          final chaveNc = '${simbolo}ncSolo';
          final viasElemento = _normalizarViasElemento(elemento);
          final tipoFonteElemento = _tipoFonteElemento(elemento);
          final fontesElemento = _fontesParaTipoElemento(tipoFonteElemento);
          final fonteElemento = _fonteAtual(
            fontesElemento,
            elemento['autor'] ?? elemento['fonteAbsorcao'],
          );
          final labelFonteElemento = _labelFonte(tipoFonteElemento);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Column(
                children: [
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          _microColor(simbolo).withValues(alpha: 0.12),
                      child: Text(
                        simbolo,
                        style: TextStyle(
                          color: _microColor(simbolo),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title:
                        Text(_nomeMicro(simbolo), style: AppTextStyles.label),
                    subtitle:
                        Text('Classe: $classe', style: AppTextStyles.caption),
                    trailing:
                        Icon(aberto ? Icons.expand_less : Icons.expand_more),
                    onTap: () =>
                        setState(() => _expandedMicros[simbolo] = !aberto),
                  ),
                  if (aberto)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        children: [
                          AppDropdown<String>(
                            label: 'Extrator',
                            value: _string(elemento['extrator'],
                                fallback: 'DTPA-TEA'),
                            items: const [
                              AppDropdownItem(
                                  value: 'DTPA-TEA', label: 'DTPA-TEA'),
                              AppDropdownItem(
                                  value: 'Água quente', label: 'Água quente'),
                              AppDropdownItem(value: 'Resina', label: 'Resina'),
                              AppDropdownItem(
                                  value: 'Oxalato de amônio',
                                  label: 'Oxalato de amônio'),
                            ],
                            onChanged: (value) => _updateElementoMicro(
                              micros: micros,
                              elementos: elementos,
                              simbolo: simbolo,
                              patch: {'extrator': value ?? 'DTPA-TEA'},
                              onChanged: onChanged,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!propagadoDoGrupo)
                            AppDropdown<String>(
                              label: 'Referência',
                              value: _string(
                                elemento['referencia'],
                                fallback:
                                    '06 — Micronutrientes: Motor de Cálculo',
                              ),
                              items: _referenciasMicrosComPersonalizada
                                  .map((item) =>
                                      AppDropdownItem(value: item, label: item))
                                  .toList(),
                              onChanged: (value) => _updateElementoMicro(
                                micros: micros,
                                elementos: elementos,
                                simbolo: simbolo,
                                patch: {
                                  'referencia': value ??
                                      '06 — Micronutrientes: Motor de Cálculo'
                                },
                                onChanged: onChanged,
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Referência', style: AppTextStyles.label),
                                const SizedBox(height: 6),
                                if (!(_editandoInline[chaveReferencia] ??
                                    false))
                                  _buildCampoPropagado(
                                    valor: _string(elemento['referencia']),
                                    onEditar: () => setState(() {
                                      _editandoInline[chaveReferencia] = true;
                                    }),
                                  )
                                else
                                  _buildCampoInlineEdicao(
                                    initialValue:
                                        _string(elemento['referencia']),
                                    keyboardType: TextInputType.text,
                                    onChanged: (value) => _updateElementoMicro(
                                      micros: micros,
                                      elementos: elementos,
                                      simbolo: simbolo,
                                      patch: {'referencia': value},
                                      onChanged: onChanged,
                                    ),
                                    onFinalizar: () => _finalizarEdicaoInline(
                                      simbolo: simbolo,
                                      campo: chaveReferencia,
                                      micros: micros,
                                      elementos: elementos,
                                      onChanged: onChanged,
                                    ),
                                  ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          _buildReferenciaAbsorcaoElemento(
                            tipoFonte: tipoFonteElemento,
                            fontes: fontesElemento,
                            fonteAtual: fonteElemento,
                            labelFonte: labelFonteElemento,
                            onTipoChanged: (value) {
                              final novoTipo = value ?? 'Autores';
                              final novasFontes =
                                  _fontesParaTipoElemento(novoTipo);
                              _updateElementoMicro(
                                micros: micros,
                                elementos: elementos,
                                simbolo: simbolo,
                                patch: {
                                  'tipoFonte': novoTipo,
                                  'autor': novasFontes.isNotEmpty
                                      ? novasFontes.first
                                      : null,
                                },
                                onChanged: onChanged,
                              );
                            },
                            onFonteChanged: (value) => _updateElementoMicro(
                              micros: micros,
                              elementos: elementos,
                              simbolo: simbolo,
                              patch: {'autor': value},
                              onChanged: onChanged,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!propagadoDoGrupo)
                            _buildNumericInput(
                              keyValue: '$draftKey-$simbolo-nc',
                              label: 'NC (mg/dm³)',
                              value: _num(elemento['ncSolo']),
                              onChanged: (value) => _updateElementoMicro(
                                micros: micros,
                                elementos: elementos,
                                simbolo: simbolo,
                                patch: {'ncSolo': value},
                                onChanged: onChanged,
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('NC (mg/dm³)', style: AppTextStyles.label),
                                const SizedBox(height: 6),
                                if (!(_editandoInline[chaveNc] ?? false))
                                  _buildCampoPropagado(
                                    valor: _fmt(_num(elemento['ncSolo'])),
                                    onEditar: () => setState(() {
                                      _editandoInline[chaveNc] = true;
                                    }),
                                  )
                                else
                                  _buildCampoInlineEdicao(
                                    initialValue:
                                        _fmt(_num(elemento['ncSolo'])),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[\d,\.]')),
                                      LengthLimitingTextInputFormatter(7),
                                    ],
                                    onChanged: (value) => _updateElementoMicro(
                                      micros: micros,
                                      elementos: elementos,
                                      simbolo: simbolo,
                                      patch: {'ncSolo': _parseDouble(value)},
                                      onChanged: onChanged,
                                    ),
                                    onFinalizar: () => _finalizarEdicaoInline(
                                      simbolo: simbolo,
                                      campo: chaveNc,
                                      micros: micros,
                                      elementos: elementos,
                                      onChanged: onChanged,
                                    ),
                                  ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Via de aplicação',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecond,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _ViaToggleGroup(
                            selecionadas: viasElemento,
                            opcoes: const ['Solo', 'Foliar', 'TS', 'Ambas'],
                            permiteAmbas: true,
                            onChanged: (value) => _updateElementoMicro(
                              micros: micros,
                              elementos: elementos,
                              simbolo: simbolo,
                              patch: {
                                'viasAplicacao': value,
                                'viaAplicacao': _viaLegadaElemento(value),
                              },
                              onChanged: onChanged,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _buildCamposViasElemento(
                              key: ValueKey(
                                '$simbolo-vias-${viasElemento.join('-')}',
                              ),
                              draftKey: draftKey,
                              simbolo: simbolo,
                              elemento: elemento,
                              vias: viasElemento,
                              micros: micros,
                              elementos: elementos,
                              onChanged: onChanged,
                            ),
                          ),
                          if (_bool(elemento['temAnaliseFoliar']))
                            _buildNumericInput(
                              keyValue: '$draftKey-$simbolo-teor-foliar-laudo',
                              label: 'Teor foliar (mg/kg)',
                              value: _num(elemento['teorFoliar']),
                              onChanged: (value) => _updateElementoMicro(
                                micros: micros,
                                elementos: elementos,
                                simbolo: simbolo,
                                patch: {'teorFoliar': value},
                                onChanged: onChanged,
                              ),
                            ),
                          const SizedBox(height: 6),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Adicionar a grupo?'),
                            value: _bool(elemento['adicionarGrupo']),
                            onChanged: (value) => _updateElementoMicro(
                              micros: micros,
                              elementos: elementos,
                              simbolo: simbolo,
                              patch: {'adicionarGrupo': value},
                              onChanged: onChanged,
                            ),
                          ),
                          if (_bool(elemento['adicionarGrupo']) &&
                              grupos.isNotEmpty)
                            AppDropdown<String>(
                              label: 'Grupo',
                              value: _string(elemento['grupoId'],
                                  fallback:
                                      grupos.first['id']?.toString() ?? ''),
                              items: grupos
                                  .map(
                                    (grupo) => AppDropdownItem(
                                      value: grupo['id']?.toString() ?? '',
                                      label:
                                          grupo['nome']?.toString() ?? 'Grupo',
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) => _updateElementoMicro(
                                micros: micros,
                                elementos: elementos,
                                simbolo: simbolo,
                                patch: {'grupoId': value ?? ''},
                                onChanged: onChanged,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _updateElementoMicro({
    required Map<String, dynamic> micros,
    required Map<String, dynamic> elementos,
    required String simbolo,
    required Map<String, dynamic> patch,
    required ValueChanged<Map<String, dynamic>> onChanged,
  }) {
    final atualizadoElemento = {..._asMap(elementos[simbolo]), ...patch};
    final atualizadoElementos = {...elementos, simbolo: atualizadoElemento};
    final atualizadoMicros = {...micros, 'elementos': atualizadoElementos};
    onChanged(atualizadoMicros);
  }

  void _updateGrupo({
    required Map<String, dynamic> micros,
    required List<Map<String, dynamic>> grupos,
    required int index,
    required Map<String, dynamic> patch,
    required ValueChanged<Map<String, dynamic>> onChanged,
  }) {
    final atualizados = [...grupos];
    atualizados[index] = {...atualizados[index], ...patch};
    final atualizadoMicros = {...micros, 'grupos': atualizados};
    onChanged(atualizadoMicros);
  }

  Widget _buildNumericInput({
    required String keyValue,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return AppInput(
      key: ValueKey(keyValue),
      label: label,
      initialValue: _fmt(value),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      maxLength: 7,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
        LengthLimitingTextInputFormatter(7),
      ],
      onChanged: (text) => onChanged(_parseDouble(text)),
    );
  }

  Widget _buildNumericPair({
    required Widget left,
    required Widget right,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 8),
        Expanded(child: right),
      ],
    );
  }

  List<String> get _referenciasMicrosComPersonalizada {
    return [
      ..._referenciasMicrosBase.where((item) => item != 'Personalizada'),
      'Personalizada',
    ];
  }

  Widget _buildCampoPropagado({
    required String valor,
    required VoidCallback onEditar,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E7)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF1D1D1F),
                fontSize: 15,
              ),
            ),
          ),
          GestureDetector(
            onTap: onEditar,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.edit_outlined,
                size: 16,
                color: Color(0xFF86868B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampoInlineEdicao({
    required String initialValue,
    required TextInputType keyboardType,
    required ValueChanged<String> onChanged,
    required VoidCallback onFinalizar,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          onFinalizar();
        }
      },
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: AppTextStyles.input.copyWith(color: AppColors.textPrimary),
        onChanged: onChanged,
        onEditingComplete: onFinalizar,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.bgPrimary,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  void _finalizarEdicaoInline({
    required String simbolo,
    required String campo,
    required Map<String, dynamic> micros,
    required Map<String, dynamic> elementos,
    required ValueChanged<Map<String, dynamic>> onChanged,
  }) {
    setState(() => _editandoInline[campo] = false);
    _updateElementoMicro(
      micros: micros,
      elementos: elementos,
      simbolo: simbolo,
      patch: {'propagadoDoGrupo': false},
      onChanged: onChanged,
    );
  }

  String _fmt(double value, {int decimals = 2}) {
    final fixed = value.toStringAsFixed(decimals);
    final normalized =
        fixed.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return normalized.replaceAll('.', ',');
  }

  double _parseDouble(String value) {
    final parsed = double.tryParse(value.replaceAll(',', '.').trim());
    return parsed ?? 0;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString() ?? '';
    if (text.isEmpty) return fallback;
    return text;
  }

  String _joinSegments(Iterable<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' · ');
  }

  double _num(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) return _parseDouble(value);
    return fallback;
  }

  bool _bool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  T? _safeValue<T>(List<T> options, T current) {
    if (options.contains(current)) return current;
    return options.isNotEmpty ? options.first : null;
  }

  String _classeMicro(Map<String, dynamic> elemento) {
    final atual = _num(elemento['teorSoloAtual']);
    final nc = _num(elemento['ncSolo'], fallback: 1);
    if (atual <= 0 || nc <= 0) return 'Sem análise';
    final rel = atual / nc;
    if (rel < 0.8) return 'Baixo';
    if (rel <= 1.2) return 'Médio';
    return 'Alto';
  }

  String _nomeMicro(String simbolo) {
    const nomes = {
      'B': 'Boro',
      'Cu': 'Cobre',
      'Fe': 'Ferro',
      'Mn': 'Manganês',
      'Zn': 'Zinco',
      'Mo': 'Molibdênio',
      'Co': 'Cobalto',
      'Ni': 'Níquel',
      'Se': 'Selênio',
    };
    return '$simbolo — ${nomes[simbolo] ?? simbolo}';
  }

  Color _microColor(String simbolo) {
    const colors = {
      'B': Color(0xFFFF9500),
      'Cu': Color(0xFF8E6B4D),
      'Fe': Color(0xFF5AC8FA),
      'Mn': Color(0xFFAF52DE),
      'Zn': Color(0xFF007AFF),
      'Mo': Color(0xFF34C759),
      'Co': Color(0xFFFF3B30),
      'Ni': Color(0xFF5856D6),
      'Se': Color(0xFF30B0C7),
    };
    return colors[simbolo] ?? AppColors.primary;
  }
}

class _ViaToggleGroup extends StatelessWidget {
  const _ViaToggleGroup({
    required this.selecionadas,
    required this.opcoes,
    required this.onChanged,
    this.permiteAmbas = false,
  });

  final List<String> selecionadas;
  final List<String> opcoes;
  final ValueChanged<List<String>> onChanged;
  final bool permiteAmbas;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < opcoes.length; i++) ...[
          Expanded(child: _buildToggle(opcoes[i])),
          if (i < opcoes.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }

  Widget _buildToggle(String opcao) {
    final selected = opcao == 'Ambas'
        ? selecionadas.contains('Solo') && selecionadas.contains('Foliar')
        : selecionadas.contains(opcao);

    return GestureDetector(
      onTap: () => _toggle(opcao),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 36,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFAF52DE).withValues(alpha: 0.10)
              : const Color(0xFFE5E5E7),
          border: Border.all(
            color: selected ? const Color(0xFFAF52DE) : const Color(0xFFD1D1D6),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          opcao,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? const Color(0xFFAF52DE) : const Color(0xFF86868B),
          ),
        ),
      ),
    );
  }

  void _toggle(String opcao) {
    final nova = List<String>.from(selecionadas);

    if (permiteAmbas && opcao == 'Ambas') {
      final ambasSelecionadas =
          nova.contains('Solo') && nova.contains('Foliar');
      if (ambasSelecionadas) {
        nova.remove('Solo');
        nova.remove('Foliar');
      } else {
        if (!nova.contains('Solo')) nova.add('Solo');
        if (!nova.contains('Foliar')) nova.add('Foliar');
      }
    } else if (nova.contains(opcao)) {
      nova.remove(opcao);
    } else {
      nova.add(opcao);
    }

    final semAmbas =
        nova.where((item) => item != 'Ambas').toSet().toList(growable: false);
    if (semAmbas.isEmpty) return;
    onChanged(semAmbas);
  }
}
