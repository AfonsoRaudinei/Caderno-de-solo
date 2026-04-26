// lib/presentation/lab/calibracao/widgets/fosforo_card_widget.dart
//
// Card 2 — Fósforo  ·  Versão final com tabelas científicas corretas
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

// ══════════════════════════════════════════════════════════════════════════════
// DOMÍNIO
// ══════════════════════════════════════════════════════════════════════════════

enum ExtratorP { resinaIAC, mehlich1 }

enum ReferenciaP { iacBol100, embrapasCerrado, embrapaRsSc, ufla }

enum CamadaP { c0a20, c20a40 }

enum ModoCalculo { correcaoSolo, manutencao, exportacao }

enum TipoCalculo { exportacao, manutencao }

// ─── Faixas de argila ─────────────────────────────────────────────────────────
// RS/SC usa faixas menores (5 classes); Cerrado usa 4 classes.
// Usamos as 5 classes RS/SC como padrão — compatível com ambas as referências.
enum FaixaArgila {
  f1, // < 10%
  f2, // 10–20%
  f3, // 21–40%
  f4, // 41–60%
  f5, // > 60%
}

extension FaixaArgilaX on FaixaArgila {
  String get label {
    switch (this) {
      case FaixaArgila.f1:
        return '< 10%';
      case FaixaArgila.f2:
        return '10–20%';
      case FaixaArgila.f3:
        return '21–40%';
      case FaixaArgila.f4:
        return '41–60%';
      case FaixaArgila.f5:
        return '> 60%';
    }
  }

  // Representante numérico para lookup
  double get rep {
    switch (this) {
      case FaixaArgila.f1:
        return 5;
      case FaixaArgila.f2:
        return 15;
      case FaixaArgila.f3:
        return 30;
      case FaixaArgila.f4:
        return 50;
      case FaixaArgila.f5:
        return 70;
    }
  }
}

// ─── Tabelas NC por argila ────────────────────────────────────────────────────

// Embrapa Cerrado — Mehlich-1 (Sousa & Lobato, 2004) — 4 faixas originais
// Mapeado para as 5 faixas RS/SC:
double _ncCerrado(FaixaArgila f) {
  switch (f) {
    case FaixaArgila.f1:
      return 15; // < 15%
    case FaixaArgila.f2:
      return 15; // 10–20% → faixa <15 + 16–35 do Cerrado
    case FaixaArgila.f3:
      return 8; // 21–40% → 16–35%
    case FaixaArgila.f4:
      return 4; // 41–60% → 36–60%
    case FaixaArgila.f5:
      return 3; // > 60%
  }
}

// Embrapa RS/SC — Mehlich-1 (CQFS RS/SC, 2004) — 5 faixas
double _ncRsSc(FaixaArgila f) {
  switch (f) {
    case FaixaArgila.f1:
      return 21; // < 10%
    case FaixaArgila.f2:
      return 18; // 10–20%
    case FaixaArgila.f3:
      return 12; // 21–40%
    case FaixaArgila.f4:
      return 9; // 41–60%
    case FaixaArgila.f5:
      return 6; // > 60%
  }
}

// UFLA / CFSEMG — Mehlich-1 — PLACEHOLDER (tabela oficial pendente)
// TODO: substituir por Ribeiro et al. (1999) / CFSEMG quando confirmado
double _ncUfla(FaixaArgila f) {
  switch (f) {
    case FaixaArgila.f1:
      return 20; // placeholder
    case FaixaArgila.f2:
      return 16; // placeholder
    case FaixaArgila.f3:
      return 10; // placeholder
    case FaixaArgila.f4:
      return 6; // placeholder
    case FaixaArgila.f5:
      return 4; // placeholder
  }
}

// ─── Descriptor por referência ────────────────────────────────────────────────

class _RefDesc {
  final String label;
  final ExtratorP extrator;
  final bool fixo;
  final bool placeholder; // UFLA — valores pendentes
  final String fonte; // para o tooltip ⓘ

  const _RefDesc({
    required this.label,
    required this.extrator,
    required this.fonte,
    this.fixo = false,
    this.placeholder = false,
  });

  bool get porArgila => !fixo;

  double? resolveNc(FaixaArgila f, ReferenciaP ref) {
    if (fixo) return 30;
    switch (ref) {
      case ReferenciaP.embrapasCerrado:
        return _ncCerrado(f);
      case ReferenciaP.embrapaRsSc:
        return _ncRsSc(f);
      case ReferenciaP.ufla:
        return _ncUfla(f);
      default:
        return null;
    }
  }

  String get tooltipText {
    if (fixo) {
      return 'NC fixo definido pela referência IAC Bol.100\n'
          '(Raij et al., 1996 — Resina trocadora de ânions, SP)';
    }
    if (placeholder) {
      return 'Valores provisórios — tabela CFSEMG/UFLA pendente de confirmação.\n'
          'O NC varia por faixa de argila nesta referência (Mehlich-1).\n'
          'Substitua pelos valores de Ribeiro et al. (1999) quando disponível.';
    }
    return 'O NC varia conforme o teor de argila do solo — $fonte.\n'
        'Diferentes amostras de uma mesma propriedade podem ter texturas distintas.\n'
        'Confirme o boletim de análise antes de fixar a faixa.';
  }
}

const _refs = <ReferenciaP, _RefDesc>{
  ReferenciaP.iacBol100: _RefDesc(
    label: 'IAC Bol.100',
    extrator: ExtratorP.resinaIAC,
    fonte: 'Raij et al., 1996',
    fixo: true,
  ),
  ReferenciaP.embrapasCerrado: _RefDesc(
    label: 'Embrapa Cerrado',
    extrator: ExtratorP.mehlich1,
    fonte: 'Sousa & Lobato, 2004',
  ),
  ReferenciaP.embrapaRsSc: _RefDesc(
    label: 'Embrapa RS/SC',
    extrator: ExtratorP.mehlich1,
    fonte: 'CQFS RS/SC, 2004',
  ),
  ReferenciaP.ufla: _RefDesc(
    label: 'UFLA / CFSEMG',
    extrator: ExtratorP.mehlich1,
    fonte: 'CFSEMG, 1999 (pendente)',
    placeholder: true,
  ),
};

// ══════════════════════════════════════════════════════════════════════════════
// CORES  (substitua pelo import real do AppColors)
// ══════════════════════════════════════════════════════════════════════════════

class _C {
  static const primary = Color(0xFF007AFF);
  static const bgWhite = Color(0xFFFFFFFF);
  static const bgGray = Color(0xFFF5F5F7);
  static const txtMain = Color(0xFF1D1D1F);
  static const txtSub = Color(0xFF86868B);
  static const border = Color(0xFFD1D1D6);
  static const borderSoft = Color(0xFFE5E5E7);
  // NC badge — valor confiável
  static const ncBlueBg = Color(0xFFEEF4FF);
  static const ncBlueBorder = Color(0xFFB8D4FF);
  // NC badge — placeholder UFLA
  static const ncOrangeBg = Color(0xFFFFF3E0);
  static const ncOrangeBorder = Color(0xFFFFCC80);
  static const ncOrangeTxt = Color(0xFFBF360C);
}

// ══════════════════════════════════════════════════════════════════════════════
// WIDGET PRINCIPAL
// ══════════════════════════════════════════════════════════════════════════════

class FosforoCardWidget extends StatefulWidget {
  const FosforoCardWidget({super.key});

  @override
  State<FosforoCardWidget> createState() => _FosforoCardWidgetState();
}

class _FosforoCardWidgetState extends State<FosforoCardWidget> {
  bool _expanded = true;
  ReferenciaP _ref = ReferenciaP.iacBol100;
  CamadaP _camada = CamadaP.c0a20;
  ModoCalculo _modo = ModoCalculo.correcaoSolo;
  TipoCalculo _tipo = TipoCalculo.exportacao;
  FaixaArgila _faixa = FaixaArgila.f3; // 21–40% como padrão

  final _pSoloCtrl = TextEditingController(text: '0');
  final _ncBadgeKey = GlobalKey();
  OverlayEntry? _tip;

  @override
  void dispose() {
    _pSoloCtrl.dispose();
    _removeTip();
    super.dispose();
  }

  _RefDesc get _d => _refs[_ref]!;
  double? get _nc => _d.resolveNc(_faixa, _ref);

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _C.bgWhite.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border, width: 0.5),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
          BoxShadow(
              color: Color(0x06000000), blurRadius: 24, offset: Offset(0, 6)),
        ],
      ),
      child: Column(children: [
        _header(),
        if (_expanded) ...[
          const Divider(height: 1, thickness: 0.5, color: _C.borderSoft),
          _body(),
        ],
      ]),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _header() => GestureDetector(
        onTap: () => setState(() {
          _expanded = !_expanded;
          _removeTip();
        }),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(children: [
            const Icon(Icons.science_outlined, color: _C.primary, size: 17),
            const SizedBox(width: 8),
            const Text('Card 2 — Fósforo',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _C.txtMain)),
            const Spacer(),
            AnimatedRotation(
              turns: _expanded ? 0 : -0.5,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.keyboard_arrow_up,
                  color: _C.txtSub, size: 20),
            ),
          ]),
        ),
      );

  // ─── Body ─────────────────────────────────────────────────────────────────

  Widget _body() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1 · Extrator read-only
            _lbl('Extrator'),
            const SizedBox(height: 6),
            _readOnly(_d.extrator == ExtratorP.resinaIAC
                ? 'Resina IAC'
                : 'Mehlich-1'),
            const SizedBox(height: 14),

            // 2 · Referência
            _lbl('Referência'),
            const SizedBox(height: 6),
            _drop<ReferenciaP>(
              value: _ref,
              items: ReferenciaP.values,
              labelOf: (r) => _refs[r]!.label,
              onChanged: (v) => setState(() {
                _ref = v!;
                _removeTip();
              }),
            ),
            const SizedBox(height: 14),

            // 3 · NC + Camada lado a lado
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _lbl('NC (mg/dm³)'),
                    const SizedBox(height: 6),
                    // Badge + ⓘ na mesma linha
                    Row(children: [
                      Expanded(child: _ncBadge()),
                      const SizedBox(width: 8),
                      _infoBtn(_d.tooltipText),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _lbl('Camada'),
                    const SizedBox(height: 6),
                    _drop<CamadaP>(
                      value: _camada,
                      items: CamadaP.values,
                      labelOf: (c) =>
                          c == CamadaP.c0a20 ? '0–20 cm' : '20–40 cm',
                      onChanged: (v) => setState(() => _camada = v!),
                    ),
                  ],
                ),
              ),
            ]),

            // 3b · Argila segmented — para todas as referências Mehlich-1
            if (_d.porArgila) ...[
              const SizedBox(height: 10),
              _argilaSegmented(),
            ],

            const SizedBox(height: 14),

            // 4 · Modo de cálculo
            _lbl('Modo de cálculo'),
            const SizedBox(height: 6),
            _drop<ModoCalculo>(
              value: _modo,
              items: ModoCalculo.values,
              labelOf: (m) {
                switch (m) {
                  case ModoCalculo.correcaoSolo:
                    return '⓪  Correção do solo';
                  case ModoCalculo.manutencao:
                    return 'Manutenção';
                  case ModoCalculo.exportacao:
                    return 'Exportação';
                }
              },
              onChanged: (v) => setState(() => _modo = v!),
            ),
            const SizedBox(height: 14),

            // 5 · Cultivar
            _cultivarRow(),
            const SizedBox(height: 14),

            // 6 · Tipo + % P do solo
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _lbl('Tipo'),
                  const SizedBox(height: 6),
                  _drop<TipoCalculo>(
                    value: _tipo,
                    items: TipoCalculo.values,
                    labelOf: (t) => t == TipoCalculo.exportacao
                        ? 'Exportação'
                        : 'Manutenção',
                    onChanged: (v) => setState(() => _tipo = v!),
                  ),
                ],
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _lbl('% P do solo que vai usar'),
                  const SizedBox(height: 6),
                  _numField(_pSoloCtrl),
                ],
              )),
            ]),
          ],
        ),
      );

  // ══════════════════════════════════════════════════════════════════════════
  // NC BADGE
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Estados visuais:
  //   Azul   → IAC fixo (30) ou Mehlich-1 com valor real (Cerrado / RS/SC)
  //   Laranja → UFLA placeholder

  Widget _ncBadge() {
    final nc = _nc;
    final isOrange = _d.placeholder;

    final Color bg = isOrange ? _C.ncOrangeBg : _C.ncBlueBg;
    final Color bdr = isOrange ? _C.ncOrangeBorder : _C.ncBlueBorder;
    final Color valC = isOrange ? _C.ncOrangeTxt : _C.primary;

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
      child: Row(children: [
        Text(val,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: valC,
                letterSpacing: -0.3)),
        const SizedBox(width: 5),
        Text(unit, style: const TextStyle(fontSize: 11, color: _C.txtSub)),
        const Spacer(),
        Icon(Icons.lock_outline_rounded,
            size: 13, color: valC.withValues(alpha: 0.35)),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ARGILA SEGMENTED CONTROL
  // ══════════════════════════════════════════════════════════════════════════

  Widget _argilaSegmented() {
    final accent = _d.placeholder ? _C.ncOrangeTxt : _C.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label com fonte
        Row(children: [
          const Icon(Icons.layers_outlined, size: 11, color: _C.txtSub),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '% Argila  ·  ${_d.fonte}',
              style: const TextStyle(
                  fontSize: 11, color: _C.txtSub, fontWeight: FontWeight.w500),
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
                onTap: () => setState(() => _faixa = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: f != FaixaArgila.f5 ? 4 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? accent : _C.bgWhite,
                    borderRadius: BorderRadius.circular(7),
                    border:
                        Border.all(color: sel ? accent : _C.border, width: 1),
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
                              color: sel ? Colors.white : _C.txtSub)),
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
                  color: _C.ncOrangeTxt,
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
        child: SizedBox(
          width: 30,
          height: 48,
          child: Center(
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _C.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('i',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _C.primary,
                        fontStyle: FontStyle.italic)),
              ),
            ),
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
            color: _C.bgGray, borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          const Text('Cultivar: Soja',
              style: TextStyle(fontSize: 13, color: _C.txtSub)),
          const Spacer(),
          GestureDetector(
            onTap: () {/* navegar para culturas */},
            child: const Text('Culturas',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _C.primary)),
          ),
        ]),
      );

  // ─── Helpers UI ───────────────────────────────────────────────────────────

  Widget _lbl(String t) => Text(t,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w500, color: _C.txtMain));

  Widget _readOnly(String v) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: _C.bgGray,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _C.borderSoft, width: 1)),
        alignment: Alignment.centerLeft,
        child: Text(v, style: const TextStyle(fontSize: 15, color: _C.txtSub)),
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
            color: _C.bgWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _C.border, width: 1)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down,
                color: _C.txtSub, size: 20),
            style: const TextStyle(fontSize: 15, color: _C.txtMain),
            onChanged: onChanged,
            items: items
                .map((e) =>
                    DropdownMenuItem<T>(value: e, child: Text(labelOf(e))))
                .toList(),
          ),
        ),
      );

  Widget _numField(TextEditingController ctrl) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: _C.bgWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _C.border, width: 1)),
        child: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            LengthLimitingTextInputFormatter(7),
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          style: const TextStyle(fontSize: 15, color: _C.txtMain),
          decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero),
        ),
      );
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
