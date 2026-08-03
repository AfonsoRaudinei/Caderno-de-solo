// lib/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart
//
// Card 2 — Fósforo · Correção do solo + Reposição da planta + Eficiência

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/nutriente_card.dart';
import 'package:soloforte/data/culturas_data.dart';
import 'package:soloforte/domain/formulas/fosforo_calibracao_config.dart';
import 'package:soloforte/features/analise/domain/formulas/fosforo_provider.dart';

class FosforoCardWidget extends ConsumerStatefulWidget {
  const FosforoCardWidget({
    super.key,
    this.initialData,
    this.cultura,
    this.onChanged,
  });

  final Map<String, dynamic>? initialData;
  final String? cultura;
  final ValueChanged<Map<String, dynamic>>? onChanged;

  @override
  ConsumerState<FosforoCardWidget> createState() => _FosforoCardWidgetState();
}

class _FosforoCardWidgetState extends ConsumerState<FosforoCardWidget> {
  ReferenciaP _ref = ReferenciaP.iacBol100;
  CamadaP _camada = CamadaP.c0a20;
  FaixaArgila _faixa = FaixaArgila.f3;
  bool _correcaoSoloAtiva = true;
  ModoReposicaoP _modoReposicao = ModoReposicaoP.semReposicao;

  String _fosforoTipoFonte = 'Autores';
  String? _fosforoFonteNome;

  final _pSoloCtrl = TextEditingController(text: '0');
  final _ajusteEficienciaCtrl = TextEditingController(text: '0');
  Map<String, dynamic> _baseData = const {};
  final _ncBadgeKey = GlobalKey();
  OverlayEntry? _tip;

  String? _percentualError;
  String? _ajusteError;

  bool get _showReposicao => _modoReposicao != ModoReposicaoP.semReposicao;
  bool get _showPercentualPSolo => _modoReposicao == ModoReposicaoP.extracao;
  bool get _showAjusteEficiencia => _showReposicao;

  @override
  void initState() {
    super.initState();
    _syncFromExternalData(widget.initialData);
  }

  @override
  void didUpdateWidget(covariant FosforoCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(oldWidget.initialData, widget.initialData) ||
        oldWidget.cultura != widget.cultura) {
      _syncFromExternalData(widget.initialData);
    }
  }

  @override
  void dispose() {
    _pSoloCtrl.dispose();
    _ajusteEficienciaCtrl.dispose();
    _removeTip();
    super.dispose();
  }

  RefDesc get _d => ref.read(fosforoFormulaProvider)[_ref]!;
  double? get _nc => _d.resolveNc(_faixa, _ref);

  void _syncFromExternalData(Map<String, dynamic>? data) {
    final source = data ?? const <String, dynamic>{};
    _baseData = Map<String, dynamic>.from(source);

    final config = FosforoCalibracaoConfig.fromMap(source);

    _ref = _referenciaFromString(source['referencia']?.toString());
    _camada = _camadaFromString(source['camada']?.toString());
    _faixa = _faixaFromString(source['faixaArgila']?.toString());
    _correcaoSoloAtiva = config.correcaoSoloAtiva;
    _modoReposicao = config.modoReposicao;
    _fosforoTipoFonte = source['fosforoTipoFonte']?.toString() ?? 'Autores';
    _fosforoFonteNome = source['fosforoFonteNome']?.toString();

    _pSoloCtrl.text = _formatNumero(config.percentualUsoPSolo);
    _ajusteEficienciaCtrl.text = _formatNumero(config.ajusteEficienciaSolo);
    _percentualError = null;
    _ajusteError = null;
  }

  void _emitChange() {
    if (widget.onChanged == null) return;

    final percentualUsoPSolo =
        double.tryParse(_pSoloCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final ajusteEficiencia =
        double.tryParse(_ajusteEficienciaCtrl.text.replaceAll(',', '.')) ?? 0.0;

    _percentualError = validarPercentualFosforo(percentualUsoPSolo);
    _ajusteError = validarPercentualFosforo(ajusteEficiencia);

    final cultura =
        widget.cultura ?? _baseData['cultivar']?.toString() ?? 'Soja';

    final config = FosforoCalibracaoConfig(
      correcaoSoloAtiva: _correcaoSoloAtiva,
      modoReposicao: _modoReposicao,
      ajusteEficienciaSolo: ajusteEficiencia.clamp(0.0, 100.0),
      percentualUsoPSolo: percentualUsoPSolo.clamp(0.0, 100.0),
    );

    final payload = config.toPayload(
      base: _baseData,
      cultura: cultura,
      camposTecnicos: {
        'extrator': _d.extrator == ExtratorP.resinaIAC
            ? 'Resina IAC'
            : 'Mehlich-1',
        'referencia': _d.label,
        'faixaArgila': _faixa.label,
        'nc': _nc ?? 30.0,
        'camada': _camada == CamadaP.c0a20 ? '0–20 cm' : '20–40 cm',
        'fosforoTipoFonte': _fosforoTipoFonte,
        'fosforoFonteNome':
            _fosforoFonteNome ??
            (_fontesParaTipoP(_fosforoTipoFonte).isNotEmpty
                ? _fontesParaTipoP(_fosforoTipoFonte).first
                : ''),
      },
    );

    widget.onChanged!(payload);
  }

  String _formatNumero(double value) => value.toString().replaceAll('.', ',');

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

  List<String> _fontesParaTipoP(String tipo) {
    if (tipo == 'Guidorizzi') return kTecnologias.keys.toList();
    if (tipo == 'Cultivar') return kCultivares.keys.toList();
    return kAutores.keys.toList();
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
        _lbl('Tipo de fonte'),
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
              _fosforoFonteNome = novasFontes.isNotEmpty
                  ? novasFontes.first
                  : null;
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
      ],
    );
  }

  Widget _reposicaoToggle() {
    return Row(
      children: ModoReposicaoP.values.map((modo) {
        final isFirst = modo == ModoReposicaoP.semReposicao;
        final isLast = modo == ModoReposicaoP.extracao;
        final selected = _modoReposicao == modo;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _modoReposicao = modo);
              _emitChange();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.borderSoft,
                borderRadius: BorderRadius.horizontal(
                  left: isFirst ? const Radius.circular(8) : Radius.zero,
                  right: isLast ? const Radius.circular(8) : Radius.zero,
                ),
              ),
              child: Text(
                modo.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textSecond,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NutrienteCard(
      nutriente: 'Card 2 — Fósforo',
      icon: Icons.science_outlined,
      cor: AppColors.fosforo,
      initiallyExpanded: false,
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
                      _emitChange();
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _lbl('NC (mg/dm³)'),
                  const SizedBox(height: AppDimens.xs),
                  Row(
                    children: [
                      Expanded(child: _ncBadge()),
                      const SizedBox(width: 8),
                      _infoBtn(_d.tooltipText),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
            ),
          ],
        ),
        if (_d.porArgila) ...[
          const SizedBox(height: AppDimens.sm),
          _argilaSegmented(),
        ],
        const SizedBox(height: AppDimens.sm),
        Material(
          color: Colors.transparent,
          child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Correção do solo'),
            subtitle: const Text(
              'Elevar P do solo ao NC quando abaixo do alvo',
              style: TextStyle(fontSize: 12, color: AppColors.textSecond),
            ),
            value: _correcaoSoloAtiva,
            onChanged: (value) {
              setState(() => _correcaoSoloAtiva = value);
              _emitChange();
            },
          ),
        ),
        const SizedBox(height: AppDimens.xs),
        _lbl('Reposição da planta'),
        const SizedBox(height: AppDimens.xs),
        _reposicaoToggle(),
        if (_showReposicao) ...[
          const SizedBox(height: AppDimens.sm),
          _cultivarRow(),
        ],
        if (_showPercentualPSolo) ...[
          const SizedBox(height: AppDimens.sm),
          _lbl('% P do solo considerado'),
          const SizedBox(height: AppDimens.xs),
          _numField(_pSoloCtrl, errorText: _percentualError),
        ],
        if (_showReposicao) ...[
          const SizedBox(height: AppDimens.sm),
          _buildAbsorcaoSecaoP(),
        ],
        if (_showAjusteEficiencia) ...[
          const SizedBox(height: AppDimens.sm),
          _lbl('Ajuste de eficiência no solo (%)'),
          const SizedBox(height: AppDimens.xs),
          _numField(_ajusteEficienciaCtrl, errorText: _ajusteError),
        ],
      ],
    );
  }

  Widget _ncBadge() {
    final nc = _nc;
    final isOrange = _d.placeholder;

    final Color bg = isOrange ? AppColors.bgWarning : const Color(0xFFEEF4FF);
    final Color bdr = isOrange ? AppColors.warning : const Color(0xFFB8D4FF);
    final Color valC = isOrange ? const Color(0xFFBF360C) : AppColors.primary;

    final String val = nc != null
        ? (nc == nc.truncateToDouble()
              ? nc.toInt().toString()
              : nc.toStringAsFixed(1))
        : '—';

    final String unit = isOrange ? 'mg/dm³ *' : 'mg/dm³';

    return Container(
      key: _ncBadgeKey,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bdr, width: 1),
      ),
      child: Row(
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
            style: const TextStyle(fontSize: 11, color: AppColors.textSecond),
          ),
          const Spacer(),
          Icon(
            Icons.lock_outline_rounded,
            size: 13,
            color: valC.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }

  Widget _argilaSegmented() {
    final accent = _d.placeholder ? const Color(0xFFBF360C) : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.layers_outlined,
              size: 11,
              color: AppColors.textSecond,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '% Argila  ·  ${_d.fonte}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecond,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: FaixaArgila.values.map((f) {
            final sel = _faixa == f;
            final ncFaixa = _d.resolveNc(f, _ref);
            final ncLabel = ncFaixa != null ? '${ncFaixa.toInt()}' : '?';

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _faixa = f;
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
                      color: sel ? accent : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        f.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                          color: sel ? Colors.white : AppColors.textSecond,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ncLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: sel
                              ? Colors.white
                              : accent.withValues(alpha: 0.7),
                        ),
                      ),
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
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _infoBtn(String msg) => GestureDetector(
    onTap: () => _toggleTip(msg),
    child: const SizedBox(
      width: 30,
      height: 48,
      child: Center(child: _InfoIcon()),
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
    final w = rb.size.width + 38;

    _tip = OverlayEntry(
      builder: (ctx) {
        final screenH = MediaQuery.of(ctx).size.height;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeTip,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
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
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        msg,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ),
                    Center(
                      child: CustomPaint(
                        size: const Size(12, 6),
                        painter: _ArrowDown(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_tip!);
  }

  void _removeTip() {
    _tip?.remove();
    _tip = null;
  }

  Widget _cultivarRow() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.bgSecondary,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Text(
          'Cultura: ${widget.cultura ?? 'Soja'}',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecond),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Culturas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _lbl(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecond,
      letterSpacing: 0.3,
    ),
  );

  Widget _readOnly(String v) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppColors.bgSecondary,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.borderSoft, width: 1),
    ),
    alignment: Alignment.centerLeft,
    child: Text(
      v,
      style: const TextStyle(fontSize: 15, color: AppColors.textSecond),
    ),
  );

  Widget _drop<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T?> onChanged,
  }) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppColors.bgPrimary,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border, width: 1),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.textSecond,
          size: 20,
        ),
        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        onChanged: onChanged,
        items: items
            .map((e) => DropdownMenuItem<T>(value: e, child: Text(labelOf(e))))
            .toList(),
      ),
    ),
  );

  Widget _numField(TextEditingController ctrl, {String? errorText}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: errorText != null ? AppColors.error : AppColors.border,
            width: 1,
          ),
        ),
        child: TextField(
          controller: ctrl,
          onChanged: (_) {
            setState(() => _emitChange());
          },
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            LengthLimitingTextInputFormatter(7),
            FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*')),
          ],
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            isDense: true,
            isCollapsed: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
      if (errorText != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            errorText,
            style: const TextStyle(fontSize: 11, color: AppColors.error),
          ),
        ),
    ],
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
        child: Text(
          'i',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

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
