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
            if (!widget.isExpanded)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onToggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.lg,
                    vertical: 14,
                  ),
                  child: _buildCollapsedHeader(),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.lg,
                  14,
                  AppDimens.lg,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildChevron(onTap: widget.onToggle),
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

  Widget _buildCollapsedHeader() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 32,
          decoration: BoxDecoration(
            color: MicronutrientesCard.accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: Text(
            MicronutrientesCard.title,
            style: AppTextStyles.label
                .copyWith(color: MicronutrientesCard.accentColor),
          ),
        ),
        _buildChevron(onTap: widget.onToggle),
      ],
    );
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

  Widget _buildConteudo() {
    final draftKey = widget.draftKey;
    final micros = widget.micros;
    final elementos = widget.elementos;
    final grupos = widget.grupos;
    final onChanged = widget.onChanged;
    final microTipoFonte = _microTipoFonte;
    final microFonteNome = _microFonteNome;
    // Helper local para fontes por tipo
    List<String> fontesParaTipo(String tipo) {
      if (tipo == 'Guidorizzi') return kTecnologias.keys.toList();
      if (tipo == 'Cultivar') return kCultivares.keys.toList();
      return kAutores.keys.toList();
    }

    const tiposDisponiveis = ['Autores', 'Guidorizzi', 'Cultivar'];
    final fontesAtual = fontesParaTipo(microTipoFonte);
    final fonteAtual = fontesAtual.contains(microFonteNome)
        ? microFonteNome!
        : (fontesAtual.isNotEmpty ? fontesAtual.first : '');
    final labelFonte = microTipoFonte == 'Guidorizzi'
        ? 'Tecnologia'
        : microTipoFonte == 'Cultivar'
            ? 'Cultivar'
            : 'Autor';
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
        // — Seção: Referência de Absorção (T3C) —
        const Text(
          'REFERÊNCIA DE ABSORÇÃO',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecond,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        AppDropdown<String>(
          label: 'Tipo de Fonte',
          value: microTipoFonte,
          items: tiposDisponiveis
              .map((t) => AppDropdownItem(value: t, label: t))
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            final novasFontes = fontesParaTipo(v);
            final novoNome = novasFontes.isNotEmpty ? novasFontes.first : null;

            final atualizado = {
              ...micros,
              'microTipoFonte': v,
              'microFonteNome': novoNome ?? '',
            };
            onChanged(atualizado);
          },
        ),
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: labelFonte,
          value: fonteAtual.isNotEmpty
              ? fonteAtual
              : (fontesAtual.isNotEmpty ? fontesAtual.first : ''),
          items: fontesAtual.isNotEmpty
              ? fontesAtual
                  .map((t) => AppDropdownItem(value: t, label: t))
                  .toList()
              : [const AppDropdownItem(value: '', label: '')],
          onChanged: (v) {
            if (v == null || v.isEmpty) return;

            final atualizado = {...micros, 'microFonteNome': v};
            onChanged(atualizado);
          },
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () {
              final novoGrupo = {
                'id': 'grupo-${DateTime.now().microsecondsSinceEpoch}',
                'nome': 'Grupo ${grupos.length + 1}',
                'via': _viasGrupo.first,
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
          final via = grupo['via']?.toString() ?? _viasGrupo.first;
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
                    label: 'Via de aplicação do grupo',
                    value: _safeValue(_viasGrupo, via),
                    items: _viasGrupo
                        .map(
                            (item) => AppDropdownItem(value: item, label: item))
                        .toList(),
                    onChanged: (value) => _updateGrupo(
                      micros: micros,
                      grupos: grupos,
                      index: index,
                      patch: {'via': value ?? _viasGrupo.first},
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
                  const SizedBox(height: 12),
                  AppInput(
                    key: ValueKey('$draftKey-grupo-produto-$index'),
                    label: 'Fonte / Produto comercial',
                    initialValue:
                        grupo['produto']?.toString() ?? 'Mistura manual',
                    onChanged: (value) => _updateGrupo(
                      micros: micros,
                      grupos: grupos,
                      index: index,
                      patch: {'produto': value},
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildNumericInput(
                    keyValue: '$draftKey-grupo-ef-$index',
                    label: 'Eficiência esperada (%)',
                    value: _num(grupo['eficiencia'], fallback: 70),
                    onChanged: (value) => _updateGrupo(
                      micros: micros,
                      grupos: grupos,
                      index: index,
                      patch: {'eficiencia': value},
                      onChanged: onChanged,
                    ),
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
                          AppDropdown<String>(
                            label: 'Via de aplicação',
                            value: _safeValue(
                                _viasMicros,
                                _string(elemento['viaAplicacao'],
                                    fallback: _viasMicros.first)),
                            items: _viasMicros
                                .map((item) =>
                                    AppDropdownItem(value: item, label: item))
                                .toList(),
                            onChanged: (value) => _updateElementoMicro(
                              micros: micros,
                              elementos: elementos,
                              simbolo: simbolo,
                              patch: {
                                'viaAplicacao': value ?? _viasMicros.first
                              },
                              onChanged: onChanged,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_usaSolo(elemento)) ...[
                            _buildNumericPair(
                              left: _buildNumericInput(
                                keyValue: '$draftKey-$simbolo-pct-solo',
                                label: '% correção solo',
                                value: _num(elemento['percentualCorrecaoSolo'],
                                    fallback: 100),
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
                              initialValue:
                                  _string(elemento['fonteSolo'], fallback: ''),
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
                              value: _num(elemento['eficienciaSolo']),
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
                          if (_usaFoliarOuTs(elemento)) ...[
                            _buildNumericPair(
                              left: _buildNumericInput(
                                keyValue: '$draftKey-$simbolo-dose-foliar',
                                label: 'Dose elemento puro (g/ha)',
                                value: _num(elemento['doseElementoFoliar']),
                                onChanged: (value) => _updateElementoMicro(
                                  micros: micros,
                                  elementos: elementos,
                                  simbolo: simbolo,
                                  patch: {'doseElementoFoliar': value},
                                  onChanged: onChanged,
                                ),
                              ),
                              right: _buildNumericInput(
                                keyValue: '$draftKey-$simbolo-teor-foliar',
                                label: 'Teor fonte foliar (%)',
                                value: _num(elemento['teorFonteFoliar']),
                                onChanged: (value) => _updateElementoMicro(
                                  micros: micros,
                                  elementos: elementos,
                                  simbolo: simbolo,
                                  patch: {'teorFonteFoliar': value},
                                  onChanged: onChanged,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            AppInput(
                              key: ValueKey('$draftKey-$simbolo-fonte-foliar'),
                              label: 'Fonte foliar',
                              initialValue: _string(elemento['fonteFoliar'],
                                  fallback: ''),
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
                              value: _num(elemento['eficienciaFoliar']),
                              onChanged: (value) => _updateElementoMicro(
                                micros: micros,
                                elementos: elementos,
                                simbolo: simbolo,
                                patch: {'eficienciaFoliar': value},
                                onChanged: onChanged,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
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

  bool _usaSolo(Map<String, dynamic> elemento) {
    final via = _string(elemento['viaAplicacao'], fallback: _viasMicros.first)
        .toLowerCase();
    return via.contains('solo') || via == 'ambas';
  }

  bool _usaFoliarOuTs(Map<String, dynamic> elemento) {
    final via = _string(elemento['viaAplicacao'], fallback: _viasMicros.first)
        .toLowerCase();
    return via.contains('foliar') || via.contains('ts') || via == 'ambas';
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
