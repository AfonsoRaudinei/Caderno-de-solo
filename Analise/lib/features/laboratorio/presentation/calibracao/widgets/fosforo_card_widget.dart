// lib/presentation/lab/calibracao/widgets/fosforo_card_widget.dart
//
// Fósforo — card de calibração com tabelas científicas
//
// ┌──────────────────────┬────────────────┬───────────────────────────────────────────────┐
// │ Referência           │ Extrator       │ NC (mg/dm³)                                   │
// ├──────────────────────┼────────────────┼───────────────────────────────────────────────┤
// │ IAC Bol.100          │ Resina IAC     │ Fixo 30 — badge azul read-only + ⓘ            │
// │ Embrapa Cerrado      │ Mehlich-1      │ Por argila (Sousa & Lobato, 2004) + ⓘ         │
// │ Embrapa RS/SC        │ Mehlich-1      │ Por argila (CQFS RS/SC, 2004) + ⓘ             │
// │ UFLA / CFSEMG        │ Mehlich-1      │ Por argila (placeholder — tabela pendente) + ⓘ│
// └──────────────────────┴────────────────┴───────────────────────────────────────────────┘
//
// REGRA ABSOLUTA: NC nunca é um TextField livre.
// O valor vem 100% da referência + faixa de argila selecionada.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/features/analise/domain/formulas/fosforo_provider.dart';
import 'package:soloforte/features/laboratorio/presentation/referencias/absorcao_nutrientes_data.dart';

// ══════════════════════════════════════════════════════════════════════════════
// WIDGET PRINCIPAL
// ══════════════════════════════════════════════════════════════════════════════

class FosforoCard extends ConsumerStatefulWidget {
  const FosforoCard({
    super.key,
    this.initialData,
    this.cultura,
    required this.isExpanded,
    required this.onToggle,
    this.onChanged,
  });

  static const title = 'Fósforo';
  static const Color accentColor = AppColors.fosforo;

  final Map<String, dynamic>? initialData;
  final String? cultura;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<Map<String, dynamic>>? onChanged;

  @override
  ConsumerState<FosforoCard> createState() => _FosforoCardState();
}

class _FosforoCardState extends ConsumerState<FosforoCard> {
  static const Duration _animDuration = Duration(milliseconds: 250);

  final GlobalKey _cardKey = GlobalKey();
  ReferenciaP _ref = ReferenciaP.iacBol100;
  CamadaP _camada = CamadaP.c0a20;
  bool _corrigirSolo = true;
  String _reposicaoFosforo = 'nenhuma';
  FaixaArgila _faixa = FaixaArgila.f3; // 21–40% como padrão

  // Referência de Absorção bibliográfica (T3A)
  String _fosforoTipoFonte = 'Autores';
  String? _fosforoFonteNome;
  bool _ncModoManual = false;

  final _pSoloCtrl = TextEditingController(text: '0');
  final _ncCtrl = TextEditingController();
  Map<String, dynamic> _baseData = const {};
  final _ncBadgeKey = GlobalKey();
  OverlayEntry? _tip;

  @override
  void initState() {
    super.initState();
    _syncFromExternalData(widget.initialData);
  }

  @override
  void didUpdateWidget(covariant FosforoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(oldWidget.initialData, widget.initialData) ||
        oldWidget.cultura != widget.cultura) {
      _syncFromExternalData(widget.initialData);
    }
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

  @override
  void dispose() {
    _pSoloCtrl.dispose();
    _ncCtrl.dispose();
    _removeTip();
    super.dispose();
  }

  RefDesc get _d => ref.read(fosforoFormulaProvider)[_ref]!;
  double? get _nc => _d.resolveNc(_faixa, _ref);
  double? get _ncAtual =>
      _ncModoManual ? _parseDoubleOrNull(_ncCtrl.text) : _nc;

  void _syncFromExternalData(Map<String, dynamic>? data) {
    final source = data ?? const <String, dynamic>{};
    _baseData = Map<String, dynamic>.from(source);

    _ref = _referenciaFromString(source['referencia']?.toString());
    _camada = _camadaFromString(source['camada']?.toString());
    _corrigirSolo = _corrigirSoloFromData(source);
    _reposicaoFosforo = _reposicaoFromData(source);
    _faixa = _faixaFromString(source['faixaArgila']?.toString());
    _ncModoManual = source['ncModoManual'] as bool? ?? false;
    _fosforoTipoFonte = source['fosforoTipoFonte']?.toString() ?? 'Autores';
    _fosforoFonteNome = source['fosforoFonteNome']?.toString();
    final usoPSolo = source['percentualUsoPSolo'];
    final usoPSoloTexto = usoPSolo == null
        ? _defaultPercentualUsoPSolo(_reposicaoFosforo).toString()
        : usoPSolo.toString();
    _pSoloCtrl.text = usoPSoloTexto.replaceAll('.', ',');
    _syncNcControllerFromMode(source['nc']);
  }

  void _emitChange() {
    if (widget.onChanged == null) return;

    final percentualUsoPSolo =
        _percentualUsoPSoloParaReposicao(_reposicaoFosforo);
    final cultura =
        widget.cultura ?? _baseData['cultivar']?.toString() ?? 'Soja';
    final tipoDadoCultivar = _reposicaoFosforo == 'exportacao'
        ? 'Exportação'
        : _reposicaoFosforo == 'extracao'
            ? 'Extração'
            : 'Nenhum';

    final payload = <String, dynamic>{
      ..._baseData,
      'extrator':
          _d.extrator == ExtratorP.resinaIAC ? 'Resina IAC' : 'Mehlich-1',
      'referencia': _d.label,
      'faixaArgila': _faixa.label,
      'nc': _ncAtual ?? _nc ?? 30.0,
      'ncModoManual': _ncModoManual,
      'camada': _camada == CamadaP.c0a20 ? '0–20 cm' : '20–40 cm',
      'corrigirSolo': _corrigirSolo,
      'reposicaoFosforo': _reposicaoFosforo,
      'modoCalculo': _modoLabelForPayload(),
      'cultivar': cultura,
      'tipoDadoCultivar': tipoDadoCultivar,
      'percentualUsoPSolo': percentualUsoPSolo,
      'fosforoTipoFonte': _fosforoTipoFonte,
      'fosforoFonteNome': _fosforoFonteNome ??
          (_fontesParaTipoP(_fosforoTipoFonte).isNotEmpty
              ? _fontesParaTipoP(_fosforoTipoFonte).first
              : ''),
      'fosforoModoAbsorcao':
          _reposicaoFosforo == 'exportacao' ? 'exportacao' : 'extracao',
    };

    widget.onChanged!(payload);
  }

  ReferenciaP _referenciaFromString(String? value) {
    switch (value) {
      case 'Embrapa Cerrado':
        return ReferenciaP.embrapasCerrado;
      case 'Embrapa RS/SC':
        return ReferenciaP.embrapaRsSc;
      case 'UFLA / CFSEMG':
        return ReferenciaP.ufla;
      case 'IAC Bol.100':
      default:
        return ReferenciaP.iacBol100;
    }
  }

  CamadaP _camadaFromString(String? value) {
    return value == '20–40 cm' ? CamadaP.c20a40 : CamadaP.c0a20;
  }

  bool _corrigirSoloFromData(Map<String, dynamic> source) {
    final explicit = source['corrigirSolo'];
    if (explicit is bool) return explicit;
    final modo = source['modoCalculo']?.toString() ?? 'Correção do solo';
    return modo.contains('Correção');
  }

  String _reposicaoFromData(Map<String, dynamic> source) {
    final explicit = source['reposicaoFosforo']?.toString();
    if (explicit == 'nenhuma' ||
        explicit == 'exportacao' ||
        explicit == 'extracao') {
      return explicit!;
    }
    final modo = source['modoCalculo']?.toString() ?? '';
    if (modo.contains('Manutenção') || modo.contains('Exportação')) {
      return 'exportacao';
    }
    if (modo.contains('Extração')) return 'extracao';
    return 'nenhuma';
  }

  FaixaArgila _faixaFromString(String? value) {
    switch (value) {
      case '< 10%':
        return FaixaArgila.f1;
      case '10–20%':
        return FaixaArgila.f2;
      case '41–60%':
        return FaixaArgila.f4;
      case '> 60%':
        return FaixaArgila.f5;
      case '21–40%':
      default:
        return FaixaArgila.f3;
    }
  }

  String _modoLabelForPayload() {
    final parts = <String>[
      if (_corrigirSolo) 'Correção do solo',
      if (_reposicaoFosforo == 'exportacao') 'Exportação',
      if (_reposicaoFosforo == 'extracao') 'Extração',
    ];
    return parts.isEmpty ? 'Sem fósforo' : parts.join(' + ');
  }

  String _modoLabelResumo() {
    return _modoLabelForPayload();
  }
  // ── T3A: Helpers de Referência de Absorção ───────────────────────────────────────

  List<String> _fontesParaTipoP(String tipo) {
    return AbsorcaoNutrientesData.nutrientData[tipo]?.keys.toList() ??
        const <String>[];
  }

  Widget _buildAbsorcaoSecaoP() {
    const tiposDisponiveis = ['Autores', 'Guidorizzi', 'Cultivar'];
    final fontes = _fontesParaTipoP(_fosforoTipoFonte);
    final fonteAtual = fontes.contains(_fosforoFonteNome)
        ? _fosforoFonteNome!
        : (fontes.isNotEmpty ? fontes.first : '');
    final labelFonte = _fosforoTipoFonte == 'Guidorizzi'
        ? 'Tecnologia'
        : _fosforoTipoFonte == 'Cultivar'
            ? 'Cultivar'
            : 'Autor';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        _lbl('Tipo de Fonte'),
        const SizedBox(height: AppDimens.xs),
        _drop<String>(
          value: _fosforoTipoFonte,
          items: tiposDisponiveis,
          labelOf: (t) => t,
          onChanged: (v) {
            if (v == null) return;
            final novasFontes = _fontesParaTipoP(v);
            setState(() {
              _fosforoTipoFonte = v;
              _fosforoFonteNome =
                  novasFontes.isNotEmpty ? novasFontes.first : null;
            });
            _emitChange();
          },
        ),
        const SizedBox(height: AppDimens.sm),
        _lbl(labelFonte),
        const SizedBox(height: AppDimens.xs),
        _drop<String>(
          value: fonteAtual.isNotEmpty
              ? fonteAtual
              : (fontes.isNotEmpty ? fontes.first : ''),
          items: fontes.isNotEmpty ? fontes : const [''],
          labelOf: (t) => t,
          onChanged: (v) {
            if (v == null || v.isEmpty) return;
            setState(() => _fosforoFonteNome = v);
            _emitChange();
          },
        ),
        const SizedBox(height: AppDimens.sm),
        Text(
          _reposicaoFosforo == 'exportacao'
              ? 'Exportação selecionada: reposição do P removido no grão.'
              : 'Extração selecionada: necessidade total da planta.',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecond,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

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
            _buildHeader(),
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
    return InkWell(
      onTap: widget.onToggle,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.lg,
          vertical: 14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30),
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
                    'Fósforo',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: widget.isExpanded
                        ? const SizedBox.shrink()
                        : Padding(
                            key: const ValueKey('fosforo-resumo'),
                            padding: const EdgeInsets.only(top: 4),
                            child: _buildResumoColapsado(),
                          ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: widget.isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF86868B),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoColapsado() {
    final summaryLines = _collapsedSummaryLines();
    if (summaryLines.isEmpty) return const SizedBox.shrink();

    final captionStyle = AppTextStyles.caption.copyWith(
      color: AppColors.textSecond,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in summaryLines) ...[
          const SizedBox(height: 2),
          Text(
            line,
            style: captionStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  List<String> _collapsedSummaryLines() {
    final extrator =
        _d.extrator == ExtratorP.resinaIAC ? 'Resina IAC' : 'Mehlich-1';
    final referencia = _d.label;
    final camada = _camada == CamadaP.c0a20 ? '0–20 cm' : '20–40 cm';
    final nc = _ncAtual;
    final modoCalculo = _modoLabelResumo();
    final percentualP = _percentualUsoPSoloParaReposicao(_reposicaoFosforo);
    final percentualSolo =
        _reposicaoFosforo == 'extracao' && (percentualP - 100).abs() > 0.001
            ? '${_fmtNumber(percentualP)}% solo'
            : '';

    return [
      _joinSegments([
        extrator,
        referencia,
      ]),
      _joinSegments([
        if (nc != null) 'NC ${_fmtNumber(nc)} mg/dm³',
        camada,
      ]),
      _joinSegments([modoCalculo, percentualSolo]),
    ].where((line) => line.isNotEmpty).toList();
  }

  Widget _buildConteudo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _lbl('Extrator'),
                  const SizedBox(height: AppDimens.xs),
                  _readOnly(
                    _d.extrator == ExtratorP.resinaIAC
                        ? 'Resina IAC'
                        : 'Mehlich-1',
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _lbl('Referência'),
                  const SizedBox(height: AppDimens.xs),
                  _drop<ReferenciaP>(
                    value: _ref,
                    items: ReferenciaP.values,
                    labelOf: (r) => ref.read(fosforoFormulaProvider)[r]!.label,
                    onChanged: (v) => setState(() {
                      _ref = v!;
                      _removeTip();
                      if (!_ncModoManual) _syncNcControllerFromMode(null);
                      _emitChange();
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.sm),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _lbl('NC (mg/dm³)'),
              const SizedBox(height: AppDimens.xs),
              Row(children: [
                Expanded(child: _ncBadge()),
                const SizedBox(width: 8),
                _infoBtn(_d.tooltipText),
              ]),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _lbl('Camada'),
              const SizedBox(height: AppDimens.xs),
              _drop<CamadaP>(
                value: _camada,
                items: CamadaP.values,
                labelOf: (c) => c == CamadaP.c0a20 ? '0–20 cm' : '20–40 cm',
                onChanged: (v) => setState(() {
                  _camada = v!;
                  _emitChange();
                }),
              ),
            ]),
          ),
        ]),
        if (_d.porArgila) ...[
          const SizedBox(height: AppDimens.sm),
          _argilaSegmented(),
        ],
        const SizedBox(height: AppDimens.sm),
        _lbl('Composição do cálculo'),
        const SizedBox(height: AppDimens.xs),
        _buildComposicaoCalculo(),
        const SizedBox(height: AppDimens.sm),
        _cultivarRow(),
        _buildCampoPercentualPSolo(),
        if (_reposicaoFosforo != 'nenhuma') ...[
          const SizedBox(height: AppDimens.sm),
          _buildAbsorcaoSecaoP(),
        ],
      ],
    );
  }

  Widget _buildCampoPercentualPSolo() {
    final mostrarCampo = _reposicaoFosforo == 'extracao';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: mostrarCampo
          ? Column(
              key: const ValueKey('campo_p_solo'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  '% P DO SOLO CONSIDERADO',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecond,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                _numField(
                  _pSoloCtrl,
                  hint: '100,0',
                  onChanged: _emitChange,
                ),
                const SizedBox(height: 4),
                Text(
                  '100% = usa tudo do solo · 0% = ignora o solo',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecond,
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(key: ValueKey('campo_p_solo_hidden')),
    );
  }

  Widget _buildComposicaoCalculo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Correção do solo',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch.adaptive(
                value: _corrigirSolo,
                activeThumbColor: AppColors.primary,
                onChanged: (value) {
                  setState(() => _corrigirSolo = value);
                  _emitChange();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _lbl('Reposição da planta'),
        const SizedBox(height: AppDimens.xs),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _reposicaoChip('nenhuma', 'Sem reposição'),
            _reposicaoChip('exportacao', 'Exportação'),
            _reposicaoChip('extracao', 'Extração'),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Exportação = P que sai no grão. Extração = necessidade total da planta.',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecond,
          ),
        ),
      ],
    );
  }

  Widget _reposicaoChip(String value, String label) {
    final selected = _reposicaoFosforo == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _reposicaoFosforo = value;
          if (value == 'extracao' &&
              (_pSoloCtrl.text.trim().isEmpty ||
                  _parseDoubleOrNull(_pSoloCtrl.text) == 0)) {
            _pSoloCtrl.text = '100';
          }
        });
        _emitChange();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.borderSoft,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecond,
          ),
        ),
      ),
    );
  }

  double _percentualUsoPSoloParaReposicao(String reposicao) {
    if (reposicao == 'extracao') {
      return _parseDoubleOrNull(_pSoloCtrl.text) ?? 100.0;
    }
    return 0.0;
  }

  double _defaultPercentualUsoPSolo(String reposicao) {
    return reposicao == 'extracao' ? 100.0 : 0.0;
  }

  void _syncNcControllerFromMode(dynamic savedNc) {
    final nc = _ncModoManual ? _numOrNull(savedNc) : _nc;
    _ncCtrl.text = nc == null ? '' : _fmtNumber(nc);
  }

  void _restaurarNcAutomatico() {
    _ncModoManual = false;
    final nc = _nc;
    _ncCtrl.text = nc == null ? '' : _fmtNumber(nc);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NC BADGE
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Estados visuais:
  //   Azul   → IAC fixo (30) ou Mehlich-1 com valor real (Cerrado / RS/SC)
  //   Laranja → UFLA placeholder

  Widget _ncBadge() {
    final nc = _ncAtual;
    final isOrange = _d.placeholder;
    final isManual = _ncModoManual;

    final Color bg = isManual
        ? AppColors.bgPrimary
        : isOrange
            ? AppColors.bgWarning
            : const Color(0xFF007AFF).withValues(alpha: 0.06);
    final Color bdr = isOrange && !isManual
        ? AppColors.warning
        : isManual
            ? AppColors.border
            : const Color(0xFFB8D4FF);
    final Color valC =
        isOrange && !isManual ? const Color(0xFFBF360C) : AppColors.primary;

    final String val = nc != null
        ? (nc == nc.truncateToDouble()
            ? nc.toInt().toString()
            : nc.toStringAsFixed(1))
        : '—';

    final String unit = isOrange ? 'mg/dm³ *' : 'mg/dm³';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: _ncBadgeKey,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: bdr, width: 1),
          ),
          child: Row(children: [
            Expanded(
              child: isManual
                  ? TextField(
                      controller: _ncCtrl,
                      onChanged: (_) => _emitChange(),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(7),
                        FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                      ],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: val,
                        suffixText: unit,
                        suffixStyle: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecond,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Text(
                          val,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: valC,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          unit,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecond,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _ncModoManual = !_ncModoManual;
                  if (_ncModoManual) {
                    _ncCtrl.text = val == '—' ? '' : val;
                  } else {
                    _restaurarNcAutomatico();
                  }
                });
                _emitChange();
              },
              child: Icon(
                isManual ? Icons.edit_outlined : Icons.lock_outline,
                size: 18,
                color: isManual ? const Color(0xFF86868B) : AppColors.primary,
              ),
            ),
          ]),
        ),
        if (isManual)
          GestureDetector(
            onTap: () {
              setState(() => _restaurarNcAutomatico());
              _emitChange();
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Restaurar valor automático',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ARGILA SEGMENTED CONTROL
  // ══════════════════════════════════════════════════════════════════════════

  Widget _argilaSegmented() {
    final accent = _d.placeholder ? const Color(0xFFBF360C) : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label com fonte
        Row(children: [
          const Icon(Icons.layers_outlined,
              size: 11, color: AppColors.textSecond),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '% Argila  ·  ${_d.fonte}',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecond,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
        const SizedBox(height: 6),

        // 5 botões compactos
        Row(
          children: FaixaArgila.values.map((f) {
            final sel = _faixa == f;
            // NC desta faixa para mostrar abaixo do label
            final ncFaixa = _d.resolveNc(f, _ref);
            final ncLabel = ncFaixa != null ? '${ncFaixa.toInt()}' : '?';

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _faixa = f;
                  if (!_ncModoManual) _syncNcControllerFromMode(null);
                  _emitChange();
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: f != FaixaArgila.f5 ? 4 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? accent : AppColors.bgPrimary,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                        color: sel ? accent : AppColors.border, width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Faixa de argila
                      Text(f.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight:
                                  sel ? FontWeight.w600 : FontWeight.w400,
                              color:
                                  sel ? Colors.white : AppColors.textSecond)),
                      const SizedBox(height: 2),
                      // NC correspondente — feedback imediato
                      Text(ncLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: sel
                                  ? Colors.white
                                  : accent.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        if (_d.placeholder)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '* Valores provisórios — aguardando tabela CFSEMG/UFLA oficial.',
              style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFFBF360C),
                  fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TOOLTIP  ⓘ  (overlay estilo iOS — dark bubble acima do badge)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _infoBtn(String msg) => GestureDetector(
        onTap: () => _toggleTip(msg),
        child: const SizedBox(
          width: 30,
          height: 48,
          child: Center(
            child: _InfoIcon(),
          ),
        ),
      );

  void _toggleTip(String msg) {
    if (_tip != null) {
      _removeTip();
      return;
    }

    final rb = _ncBadgeKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null) return;
    final pos = rb.localToGlobal(Offset.zero);
    final w = rb.size.width + 38; // badge + ícone

    _tip = OverlayEntry(builder: (ctx) {
      final screenH = MediaQuery.of(ctx).size.height;
      return Stack(children: [
        // Tap fora fecha
        Positioned.fill(
            child: GestureDetector(
          onTap: _removeTip,
          behavior: HitTestBehavior.translucent,
          child: const SizedBox.expand(),
        )),
        // Balão
        Positioned(
          left: pos.dx,
          width: w,
          bottom: screenH - pos.dy + 6,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D1D1F),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 16,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: Text(msg,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white, height: 1.5)),
                ),
                Center(
                    child: CustomPaint(
                        size: const Size(12, 6), painter: _ArrowDown())),
              ],
            ),
          ),
        ),
      ]);
    });

    Overlay.of(context).insert(_tip!);
  }

  void _removeTip() {
    _tip?.remove();
    _tip = null;
  }

  // ─── Cultivar row ─────────────────────────────────────────────────────────

  Widget _cultivarRow() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Text('Cultivar: ${widget.cultura ?? 'Soja'}',
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textSecond)),
          const Spacer(),
          GestureDetector(
            onTap: () {/* navegar para culturas */},
            child: const Text('Culturas',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary)),
          ),
        ]),
      );

  // ─── Helpers UI ───────────────────────────────────────────────────────────

  Widget _lbl(String t) => Text(t,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecond,
          letterSpacing: 0.3));

  Widget _readOnly(String v) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSoft, width: 1)),
        alignment: Alignment.centerLeft,
        child: Text(v,
            style: const TextStyle(fontSize: 15, color: AppColors.textSecond)),
      );

  Widget _drop<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T?> onChanged,
  }) =>
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 1)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down,
                color: AppColors.textSecond, size: 20),
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
            onChanged: onChanged,
            items: items
                .map((e) =>
                    DropdownMenuItem<T>(value: e, child: Text(labelOf(e))))
                .toList(),
          ),
        ),
      );

  Widget _numField(
    TextEditingController ctrl, {
    String? hint,
    VoidCallback? onChanged,
  }) =>
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 1)),
        child: TextField(
          controller: ctrl,
          onChanged: (_) => onChanged?.call(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            LengthLimitingTextInputFormatter(7),
            FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
          ],
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            isDense: true,
            isCollapsed: true,
            contentPadding: EdgeInsets.zero,
            hintText: hint,
          ),
        ),
      );
}

class _InfoIcon extends StatelessWidget {
  const _InfoIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text('i',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                fontStyle: FontStyle.italic)),
      ),
    );
  }
}

String _joinSegments(Iterable<String> values) {
  return values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(' · ');
}

String _fmtNumber(double value) {
  final fixed =
      value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
  return fixed.replaceAll('.', ',');
}

double? _parseDoubleOrNull(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;
  return double.tryParse(text.replaceAll(',', '.'));
}

double? _numOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return _parseDoubleOrNull(value);
  return null;
}

// ══════════════════════════════════════════════════════════════════════════════
// SETA DO TOOLTIP
// ══════════════════════════════════════════════════════════════════════════════

class _ArrowDown extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    c.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(s.width / 2, s.height)
        ..lineTo(s.width, 0)
        ..close(),
      Paint()
        ..color = const Color(0xFF1D1D1F)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
