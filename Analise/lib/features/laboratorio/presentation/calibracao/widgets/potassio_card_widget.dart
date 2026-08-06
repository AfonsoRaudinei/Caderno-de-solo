// Potássio — card de calibração
//
// Correção do solo (exclusiva):
//   • Nível crítico (mg/dm³)
//   • % K na CTC
//
// Reposição da planta (exclusiva):
//   • Sem reposição / Exportação / Extração

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/data/culturas_data.dart';
import 'package:soloforte/domain/formulas/potassio_formula.dart';

enum ExtratorK { resinaIAC, mehlich1, resinaOuMehlich }

enum ReferenciaK { iacBol100, embrapasCerrado, embrapaRsSc, ufla }

enum CamadaK { c0a20, c20a40 }

enum MetodoCorrecaoK { nivelCritico, percentualKCtc }

class _NcK {
  final double? ncTeor;
  final double? ncCtcPct;
  final bool placeholder;

  const _NcK({this.ncTeor, this.ncCtcPct, this.placeholder = false});
}

class _RefK {
  final String label;
  final ExtratorK extrator;
  final _NcK nc;
  final String fonte;

  const _RefK({
    required this.label,
    required this.extrator,
    required this.nc,
    required this.fonte,
  });

  String get tooltipText {
    if (nc.placeholder) {
      return 'Valores NC provisórios — tabela CFSEMG/UFLA pendente.\n'
          'Substitua pelos dados de Ribeiro et al. (1999) quando disponível.';
    }
    return 'Referência: $fonte\n'
        'NC teor: ${nc.ncTeor?.toInt() ?? "—"} mg/dm³  ·  '
        'NC % CTC: ${nc.ncCtcPct?.toInt() ?? "—"}%\n\n'
        'Selecione apenas um método de correção por vez.';
  }
}

const _refsK = <ReferenciaK, _RefK>{
  ReferenciaK.iacBol100: _RefK(
    label: 'IAC Bol.100',
    extrator: ExtratorK.resinaIAC,
    nc: _NcK(ncTeor: 80, ncCtcPct: 4),
    fonte: 'Raij et al., 1996',
  ),
  ReferenciaK.embrapasCerrado: _RefK(
    label: 'Embrapa Cerrado',
    extrator: ExtratorK.mehlich1,
    nc: _NcK(ncTeor: 46, ncCtcPct: 3),
    fonte: 'Sousa & Lobato, 2004',
  ),
  ReferenciaK.embrapaRsSc: _RefK(
    label: 'Embrapa RS/SC',
    extrator: ExtratorK.resinaOuMehlich,
    nc: _NcK(ncTeor: 80, ncCtcPct: 4),
    fonte: 'CQFS RS/SC, 2004',
  ),
  ReferenciaK.ufla: _RefK(
    label: 'UFLA / CFSEMG',
    extrator: ExtratorK.mehlich1,
    nc: _NcK(placeholder: true),
    fonte: 'CFSEMG, 1999 (pendente)',
  ),
};

class PotassioCard extends StatefulWidget {
  const PotassioCard({
    super.key,
    this.initialData,
    this.cultura,
    required this.isExpanded,
    required this.onToggle,
    this.onChanged,
  });

  static const title = 'Potássio';
  static const Color accentColor = AppColors.potassio;

  final Map<String, dynamic>? initialData;
  final String? cultura;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<Map<String, dynamic>>? onChanged;

  @override
  State<PotassioCard> createState() => _PotassioCardState();
}

class _PotassioCardState extends State<PotassioCard> {
  static const Duration _animDuration = Duration(milliseconds: 250);

  final GlobalKey _cardKey = GlobalKey();
  ReferenciaK _ref = ReferenciaK.iacBol100;
  CamadaK _camada = CamadaK.c0a20;
  bool _corrigirSolo = true;
  MetodoCorrecaoK _metodoCorrecao = MetodoCorrecaoK.nivelCritico;
  String _reposicaoPotassio = 'nenhuma';

  String _potassioTipoFonte = 'Autores';
  String? _potassioFonteNome;
  bool _ncTeorManual = false;
  bool _ncCtcManual = false;

  late TextEditingController _ncTeorCtrl;
  late TextEditingController _ncCtcCtrl;
  late TextEditingController _kSoloCtrl;
  late TextEditingController _eficienciaSoloCtrl;
  late TextEditingController _indiceExportacaoCtrl;
  late TextEditingController _indiceExtracaoCtrl;

  Map<String, dynamic> _baseData = const {};
  double? _persistedNcTeor;
  double? _persistedNcCtc;
  final _ncBadgeKey = GlobalKey();
  OverlayEntry? _tip;

  String? _ncTeorError;
  String? _ncCtcError;
  String? _eficienciaError;
  String? _indiceExportacaoError;
  String? _indiceExtracaoError;
  String? _kSoloError;

  @override
  void initState() {
    super.initState();
    _ncTeorCtrl = TextEditingController();
    _ncCtcCtrl = TextEditingController();
    _kSoloCtrl = TextEditingController(text: '100');
    _eficienciaSoloCtrl = TextEditingController(text: '15');
    _indiceExportacaoCtrl = TextEditingController();
    _indiceExtracaoCtrl = TextEditingController();
    _syncFromExternalData(widget.initialData);
  }

  @override
  void didUpdateWidget(covariant PotassioCard oldWidget) {
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
    _ncTeorCtrl.dispose();
    _ncCtcCtrl.dispose();
    _kSoloCtrl.dispose();
    _eficienciaSoloCtrl.dispose();
    _indiceExportacaoCtrl.dispose();
    _indiceExtracaoCtrl.dispose();
    _removeTip();
    super.dispose();
  }

  _RefK get _d => _refsK[_ref]!;

  String get _extratorLabel {
    switch (_d.extrator) {
      case ExtratorK.resinaIAC:
        return 'Resina IAC';
      case ExtratorK.mehlich1:
        return 'Mehlich-1';
      case ExtratorK.resinaOuMehlich:
        return 'Resina IAC / Mehlich-1';
    }
  }

  String get _camadaLabel => _camada == CamadaK.c0a20 ? '0–20 cm' : '20–40 cm';

  double? get _ncTeorAtual => _ncTeorManual
      ? _parseDoubleOrNull(_ncTeorCtrl.text)
      : _ncTeorAutomatico();

  double? get _percentualKObjetivo =>
      _ncCtcManual ? _parseDoubleOrNull(_ncCtcCtrl.text) : _ncCtcAutomatico();

  double? _kAtualMgDm3() {
    return _numOrNull(_baseData['kMgDm3']) ??
        _numOrNull(_baseData['k_mgdm3']) ??
        (_numOrNull(_baseData['k']) != null
            ? _numOrNull(_baseData['k'])! * 391.0
            : null);
  }

  double? _kAtualCmolc() {
    return _numOrNull(_baseData['k']) ??
        (_kAtualMgDm3() != null ? _kAtualMgDm3()! / 391.0 : null);
  }

  double? _ctcAtual() => _numOrNull(_baseData['ctc']);

  double? _participacaoKAtual() {
    final k = _kAtualCmolc();
    final ctc = _ctcAtual();
    if (k == null || ctc == null || ctc <= 0) return null;
    return PotassioFormula.participacaoAtual(kAtual: k, ctc: ctc);
  }

  double? _argilaPercentual() {
    return _numOrNull(_baseData['argila']) ??
        _numOrNull(_baseData['argilaPercent']) ??
        _numOrNull(_baseData['argilaPercentual']) ??
        _numOrNull(_baseData['teorArgila']);
  }

  double? _ncTeorAutomatico() {
    if (_ref == ReferenciaK.iacBol100) {
      final argila = _argilaPercentual();
      if (argila == null) return _d.nc.ncTeor;
      if (argila < 15) return 120;
      if (argila <= 35) return 100;
      return 70;
    }
    return _d.nc.ncTeor;
  }

  double? _ncCtcAutomatico() => _d.nc.ncCtcPct;

  void _syncNcControllersFromMode(Map<String, dynamic> source) {
    final ncTeor =
        _ncTeorManual ? _numOrNull(source['ncTeor']) : _ncTeorAutomatico();
    final ncCtc = _ncCtcManual
        ? _numOrNull(source['percentualKObjetivoCtc'] ?? source['ncPctCtc'])
        : _ncCtcAutomatico();
    _ncTeorCtrl.text = ncTeor == null ? '' : _fmtNumber(ncTeor);
    _ncCtcCtrl.text = ncCtc == null ? '' : _fmtNumber(ncCtc);
  }

  void _resetNcTeorParaAutomatico() {
    _ncTeorManual = false;
    final nc = _ncTeorAutomatico();
    _ncTeorCtrl.text = nc == null ? '' : _fmtNumber(nc);
  }

  void _resetNcCtcParaAutomatico() {
    _ncCtcManual = false;
    final nc = _ncCtcAutomatico();
    _ncCtcCtrl.text = nc == null ? '' : _fmtNumber(nc);
  }

  void _syncFromExternalData(Map<String, dynamic>? data) {
    final source = data ?? const <String, dynamic>{};
    _baseData = Map<String, dynamic>.from(source);

    _ref = _referenciaFromString(source['referencia']?.toString());
    _camada = _camadaFromString(source['camada']?.toString());
    _corrigirSolo = _corrigirSoloFromData(source);
    _metodoCorrecao = _metodoCorrecaoFromData(source);
    _reposicaoPotassio = _reposicaoFromData(source);
    _ncTeorManual = source['ncTeorManual'] as bool? ?? false;
    _ncCtcManual = source['ncCtcManual'] as bool? ?? false;
    _potassioTipoFonte = source['potassioTipoFonte']?.toString() ?? 'Autores';
    _potassioFonteNome = source['potassioFonteNome']?.toString();

    final usoKSolo =
        source['percentualKSoloConsiderado'] ?? source['percentualUsoKSolo'];
    _kSoloCtrl.text = _fmtNumber(
      _numOrNull(usoKSolo) ?? (_reposicaoPotassio == 'extracao' ? 100.0 : 0.0),
    );
    _eficienciaSoloCtrl.text = _fmtNumber(_eficienciaSoloFromSource(source));
    _indiceExportacaoCtrl.text = _fmtNumber(
      _numOrNull(source['indiceExportacaoK2O']),
      emptyWhenNull: true,
    );
    _indiceExtracaoCtrl.text = _fmtNumber(
      _numOrNull(source['indiceExtracaoK2O']),
      emptyWhenNull: true,
    );
    _syncNcControllersFromMode(source);
    _persistedNcTeor = _numOrNull(source['ncTeor']) ?? _ncTeorAutomatico();
    _persistedNcCtc = _numOrNull(
          source['percentualKObjetivoCtc'] ?? source['ncPctCtc'],
        ) ??
        _ncCtcAutomatico();
    _validateFields();
  }

  double _eficienciaSoloFromSource(Map<String, dynamic> source) {
    final eficiencia = _numOrNull(source['ajusteEficienciaSolo']) ??
        _numOrNull(source['eficienciaSolo']) ??
        _numOrNull(source['fekBase']) ??
        15.0;
    return eficiencia.clamp(0.0, 100.0);
  }

  double _eficienciaSoloEfetiva() {
    final parsed = _parseDoubleOrNull(_eficienciaSoloCtrl.text);
    final raw = parsed ?? _eficienciaSoloFromSource(_baseData);
    return raw.clamp(0.0, 100.0);
  }

  void _validateFields() {
    _ncTeorError = _validateNcTeor(_ncTeorAtual);
    _ncCtcError = _validatePercentual(_percentualKObjetivo, 'objetivo');
    _eficienciaError =
        _validatePercentual(_eficienciaSoloEfetiva(), 'eficiência');
    _indiceExportacaoError =
        _validateIndice(_parseDoubleOrNull(_indiceExportacaoCtrl.text));
    _indiceExtracaoError =
        _validateIndice(_parseDoubleOrNull(_indiceExtracaoCtrl.text));
    _kSoloError = _validatePercentual(
      _parseDoubleOrNull(_kSoloCtrl.text),
      'solo considerado',
    );
  }

  String? _validateNcTeor(double? value) {
    if (!_corrigirSolo || _metodoCorrecao != MetodoCorrecaoK.nivelCritico) {
      return null;
    }
    if (value == null) return 'Informe o NC de K';
    if (value < 0) return 'NC não pode ser negativo';
    return null;
  }

  String? _validatePercentual(double? value, String label) {
    if (value == null) return null;
    if (value < 0 || value > 100) {
      return '$label deve estar entre 0 e 100%';
    }
    return null;
  }

  String? _validateIndice(double? value) {
    if (value == null) return null;
    if (value < 0) return 'Índice não pode ser negativo';
    return null;
  }

  void _emitChange() {
    if (widget.onChanged == null) return;
    _validateFields();

    final cultura =
        widget.cultura ?? _baseData['cultivar']?.toString() ?? 'Soja';
    final percentualKSolo = _reposicaoPotassio == 'extracao'
        ? (_parseDoubleOrNull(_kSoloCtrl.text) ?? 100.0)
        : 0.0;
    final ajusteEficiencia = _eficienciaSoloEfetiva();
    final indiceExportacao = _parseDoubleOrNull(_indiceExportacaoCtrl.text);
    final indiceExtracao = _parseDoubleOrNull(_indiceExtracaoCtrl.text);

    final ncTeorSalvo =
        _parseDoubleOrNull(_ncTeorCtrl.text) ?? _persistedNcTeor;
    final ncCtcSalvo = _parseDoubleOrNull(_ncCtcCtrl.text) ?? _persistedNcCtc;
    final ncTeorFinal = ncTeorSalvo ?? _ncTeorAutomatico() ?? 46.0;
    final ncCtcFinal = ncCtcSalvo ?? _ncCtcAutomatico() ?? 3.0;
    _persistedNcTeor = ncTeorFinal;
    _persistedNcCtc = ncCtcFinal;

    final payload = <String, dynamic>{
      ..._baseData,
      'extrator': _extratorLabel,
      'referencia': _d.label,
      'camada': _camadaLabel,
      'corrigirSolo': _corrigirSolo,
      'metodoCorrecao': _metodoCorrecaoPayload(_metodoCorrecao),
      'criterioNc': _criterioNcPayload(_metodoCorrecao),
      'ncTeor': ncTeorFinal,
      'ncPctCtc': ncCtcFinal,
      'percentualKObjetivoCtc': ncCtcFinal,
      'ncTeorManual': _ncTeorManual,
      'ncCtcManual': _ncCtcManual,
      'reposicaoPotassio': _reposicaoPotassio,
      'modoCalculo': _modoLabelForPayload(),
      'cultivar': cultura,
      'tipoDadoCultivar': _tipoFromReposicao(_reposicaoPotassio),
      'percentualUsoKSolo': percentualKSolo,
      'percentualKSoloConsiderado': percentualKSolo,
      'indiceExportacaoK2O': indiceExportacao,
      'indiceExtracaoK2O': indiceExtracao,
      'ajusteEficienciaSolo': ajusteEficiencia,
      'fekBase': ajusteEficiencia,
      'potassioTipoFonte': _potassioTipoFonte,
      'potassioFonteNome': _potassioFonteNome ??
          (_fontesParaTipoK(_potassioTipoFonte).isNotEmpty
              ? _fontesParaTipoK(_potassioTipoFonte).first
              : ''),
      'potassioModoAbsorcao':
          _reposicaoPotassio == 'exportacao' ? 'exportacao' : 'extracao',
    };

    widget.onChanged!(payload);
  }

  ReferenciaK _referenciaFromString(String? value) {
    switch (value) {
      case 'Embrapa Cerrado':
        return ReferenciaK.embrapasCerrado;
      case 'Embrapa RS/SC':
        return ReferenciaK.embrapaRsSc;
      case 'UFLA / CFSEMG':
        return ReferenciaK.ufla;
      case 'IAC Bol.100':
      default:
        return ReferenciaK.iacBol100;
    }
  }

  CamadaK _camadaFromString(String? value) {
    if (value == '20–40 cm' || value == '20-40') return CamadaK.c20a40;
    return CamadaK.c0a20;
  }

  bool _corrigirSoloFromData(Map<String, dynamic> source) {
    final explicit = source['corrigirSolo'];
    if (explicit is bool) return explicit;
    final modo = source['modoCalculo']?.toString() ?? 'Correção do solo';
    if (modo.contains('Manutenção') ||
        modo.contains('Exportação') ||
        modo.contains('Extração')) {
      return false;
    }
    return modo.contains('Correção') || modo.startsWith('①');
  }

  MetodoCorrecaoK _metodoCorrecaoFromData(Map<String, dynamic> source) {
    final explicit = source['metodoCorrecao']?.toString();
    if (explicit == 'percentual_k_ctc') {
      return MetodoCorrecaoK.percentualKCtc;
    }
    if (explicit == 'nivel_critico') {
      return MetodoCorrecaoK.nivelCritico;
    }
    final criterio = source['criterioNc']?.toString() ?? 'Teor absoluto';
    if (criterio == '% K na CTC') return MetodoCorrecaoK.percentualKCtc;
    return MetodoCorrecaoK.nivelCritico;
  }

  String _reposicaoFromData(Map<String, dynamic> source) {
    final explicit = source['reposicaoPotassio']?.toString();
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

  String _metodoCorrecaoPayload(MetodoCorrecaoK metodo) {
    return metodo == MetodoCorrecaoK.percentualKCtc
        ? 'percentual_k_ctc'
        : 'nivel_critico';
  }

  String _criterioNcPayload(MetodoCorrecaoK metodo) {
    return metodo == MetodoCorrecaoK.percentualKCtc
        ? '% K na CTC'
        : 'Teor absoluto';
  }

  String _modoLabelForPayload() {
    final parts = <String>[
      if (_corrigirSolo) 'Correção do solo',
      if (_reposicaoPotassio == 'exportacao') 'Exportação',
      if (_reposicaoPotassio == 'extracao') 'Extração',
    ];
    return parts.isEmpty ? 'Sem potássio' : parts.join(' + ');
  }

  String _tipoFromReposicao(String reposicao) {
    if (reposicao == 'exportacao') return 'Exportação';
    if (reposicao == 'extracao') return 'Extração';
    return 'Nenhum';
  }

  List<String> _fontesParaTipoK(String tipo) {
    if (tipo == 'Guidorizzi') return kTecnologias.keys.toList();
    if (tipo == 'Cultivar') return kCultivares.keys.toList();
    return kAutores.keys.toList();
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
                color: AppColors.potassio,
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
                    'Potássio',
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
                            key: const ValueKey('potassio-resumo'),
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
                color: AppColors.textSecond,
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
    final metodo =
        _metodoCorrecao == MetodoCorrecaoK.percentualKCtc ? '% CTC' : 'NC teor';
    final ncTeor = _ncTeorAtual;
    final ncCtc = _percentualKObjetivo;
    final teorSuffix = _ncTeorManual ? '*' : '';
    final ctcSuffix = _ncCtcManual ? '*' : '';

    return [
      _joinSegments([_extratorLabel, _d.label, _camadaLabel]),
      if (_corrigirSolo)
        _joinSegments([
          metodo,
          if (_metodoCorrecao == MetodoCorrecaoK.nivelCritico && ncTeor != null)
            'NC ${_fmtNumber(ncTeor)} mg/dm³$teorSuffix',
          if (_metodoCorrecao == MetodoCorrecaoK.percentualKCtc &&
              ncCtc != null)
            'Alvo ${_fmtNumber(ncCtc)}% CTC$ctcSuffix',
        ]),
      _joinSegments([_modoLabelForPayload()]),
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
                  _readOnly(_extratorLabel),
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
                  _drop<ReferenciaK>(
                    value: _ref,
                    items: ReferenciaK.values,
                    labelOf: (r) => _refsK[r]!.label,
                    onChanged: (v) => setState(() {
                      _ref = v!;
                      _removeTip();
                      if (!_ncTeorManual) _resetNcTeorParaAutomatico();
                      if (!_ncCtcManual) _resetNcCtcParaAutomatico();
                      _emitChange();
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.sm),
        _lbl('Camada'),
        const SizedBox(height: AppDimens.xs),
        _drop<CamadaK>(
          value: _camada,
          items: CamadaK.values,
          labelOf: (c) => c == CamadaK.c0a20 ? '0–20 cm' : '20–40 cm',
          onChanged: (v) => setState(() {
            _camada = v!;
            _emitChange();
          }),
        ),
        const SizedBox(height: AppDimens.sm),
        _buildComposicaoCalculo(),
        if (_corrigirSolo) ...[
          const SizedBox(height: AppDimens.sm),
          _lbl('Método de correção'),
          const SizedBox(height: AppDimens.xs),
          _metodoCorrecaoToggle(),
          const SizedBox(height: AppDimens.sm),
          _buildMetodoCorrecaoCampos(),
        ],
        const SizedBox(height: AppDimens.sm),
        _cultivarRow(),
        _buildCampoPercentualKSolo(),
        if (_reposicaoPotassio != 'nenhuma') ...[
          const SizedBox(height: AppDimens.sm),
          _buildAbsorcaoSecaoK(),
          const SizedBox(height: AppDimens.sm),
          _buildIndicesReposicao(),
          const SizedBox(height: AppDimens.sm),
          _buildEficienciaSolo(),
        ],
      ],
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
      ],
    );
  }

  Widget _reposicaoChip(String value, String label) {
    final selected = _reposicaoPotassio == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _reposicaoPotassio = value;
          if (value == 'extracao' &&
              (_kSoloCtrl.text.trim().isEmpty ||
                  _parseDoubleOrNull(_kSoloCtrl.text) == 0)) {
            _kSoloCtrl.text = '100';
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

  Widget _metodoCorrecaoToggle() {
    return Row(
      children: [
        Expanded(
          child: _toggleBtnK(
            label: 'Nível crítico',
            selected: _metodoCorrecao == MetodoCorrecaoK.nivelCritico,
            onTap: () {
              setState(() => _metodoCorrecao = MetodoCorrecaoK.nivelCritico);
              _emitChange();
            },
            isLeft: true,
          ),
        ),
        Expanded(
          child: _toggleBtnK(
            label: '% K na CTC',
            selected: _metodoCorrecao == MetodoCorrecaoK.percentualKCtc,
            onTap: () {
              setState(() => _metodoCorrecao = MetodoCorrecaoK.percentualKCtc);
              _emitChange();
            },
            isLeft: false,
          ),
        ),
      ],
    );
  }

  Widget _toggleBtnK({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.borderSoft,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(8) : Radius.zero,
            right: isLeft ? Radius.zero : const Radius.circular(8),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecond,
          ),
        ),
      ),
    );
  }

  Widget _buildMetodoCorrecaoCampos() {
    final kAtual = _kAtualMgDm3();
    final participacao = _participacaoKAtual();
    final ctc = _ctcAtual();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (kAtual != null) ...[
          _lbl('K atual da análise'),
          const SizedBox(height: AppDimens.xs),
          _readOnly('${_fmtNumber(kAtual)} mg/dm³'),
          const SizedBox(height: AppDimens.sm),
        ],
        if (_metodoCorrecao == MetodoCorrecaoK.percentualKCtc &&
            participacao != null) ...[
          _lbl('% K atual na CTC'),
          const SizedBox(height: AppDimens.xs),
          _readOnly('${_fmtNumber(participacao)}%'),
          const SizedBox(height: AppDimens.sm),
        ],
        if (_metodoCorrecao == MetodoCorrecaoK.nivelCritico)
          _buildNcTeorSection()
        else
          _buildNcCtcSection(),
        if (_metodoCorrecao == MetodoCorrecaoK.percentualKCtc &&
            ctc != null) ...[
          const SizedBox(height: AppDimens.sm),
          _lbl('CTC utilizada no cálculo'),
          const SizedBox(height: AppDimens.xs),
          _readOnly('${_fmtNumber(ctc)} cmolc/dm³'),
        ],
      ],
    );
  }

  Widget _buildNcTeorSection() {
    final isPlaceholder = _d.nc.placeholder;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _lbl('NC de K (mg/dm³)'),
                  const SizedBox(height: AppDimens.xs),
                  _ncBadge(
                    key: _ncBadgeKey,
                    controller: _ncTeorCtrl,
                    value: _ncTeorAtual,
                    placeholder: '46',
                    unit: isPlaceholder ? 'mg/dm³ *' : 'mg/dm³',
                    manual: _ncTeorManual,
                    isPlaceholder: isPlaceholder,
                    onToggleManual: () {
                      setState(() {
                        _ncTeorManual = !_ncTeorManual;
                        if (_ncTeorManual) {
                          _ncTeorCtrl.text =
                              _fmtNumber(_ncTeorAutomatico() ?? 46);
                        } else {
                          _resetNcTeorParaAutomatico();
                        }
                      });
                      _emitChange();
                    },
                    onRestore: () {
                      setState(_resetNcTeorParaAutomatico);
                      _emitChange();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _infoBtn(_d.tooltipText),
          ],
        ),
        if (_ncTeorError != null) _inlineError(_ncTeorError!),
      ],
    );
  }

  Widget _buildNcCtcSection() {
    final isPlaceholder = _d.nc.placeholder;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _lbl('% K objetivo na CTC'),
                  const SizedBox(height: AppDimens.xs),
                  _ncBadge(
                    controller: _ncCtcCtrl,
                    value: _percentualKObjetivo,
                    placeholder: '3',
                    unit: isPlaceholder ? '% *' : '%',
                    manual: _ncCtcManual,
                    isPlaceholder: isPlaceholder,
                    onToggleManual: () {
                      setState(() {
                        _ncCtcManual = !_ncCtcManual;
                        if (_ncCtcManual) {
                          _ncCtcCtrl.text = _fmtNumber(_ncCtcAutomatico() ?? 3);
                        } else {
                          _resetNcCtcParaAutomatico();
                        }
                      });
                      _emitChange();
                    },
                    onRestore: () {
                      setState(_resetNcCtcParaAutomatico);
                      _emitChange();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _infoBtn(_d.tooltipText),
          ],
        ),
        if (_ncCtcError != null) _inlineError(_ncCtcError!),
      ],
    );
  }

  Widget _buildCampoPercentualKSolo() {
    final mostrarCampo = _reposicaoPotassio == 'extracao';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: mostrarCampo
          ? Column(
              key: const ValueKey('campo_k_solo'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  '% K DO SOLO CONSIDERADO',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecond,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                _numField(_kSoloCtrl, hint: '100,0', onChanged: _emitChange),
                if (_kSoloError != null) _inlineError(_kSoloError!),
                const SizedBox(height: 4),
                Text(
                  '100% = usa tudo do solo · 0% = ignora o solo',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecond,
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(key: ValueKey('campo_k_solo_hidden')),
    );
  }

  Widget _buildIndicesReposicao() {
    final isExportacao = _reposicaoPotassio == 'exportacao';
    final ctrl = isExportacao ? _indiceExportacaoCtrl : _indiceExtracaoCtrl;
    final error = isExportacao ? _indiceExportacaoError : _indiceExtracaoError;
    final label = isExportacao
        ? 'Índice de exportação (kg K₂O/t)'
        : 'Índice de extração (kg K₂O/t)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lbl(label),
        const SizedBox(height: AppDimens.xs),
        _numField(ctrl, hint: '0,0', onChanged: _emitChange),
        if (error != null) _inlineError(error),
        const SizedBox(height: 4),
        Text(
          'Opcional quando a referência de absorção estiver configurada.',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecond),
        ),
      ],
    );
  }

  Widget _buildEficienciaSolo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lbl('Ajuste de eficiência no solo (%)'),
        const SizedBox(height: AppDimens.xs),
        _numField(_eficienciaSoloCtrl, hint: '15', onChanged: _emitChange),
        if (_eficienciaError != null) _inlineError(_eficienciaError!),
        const SizedBox(height: 4),
        Text(
          '0–100% · acréscimo percentual sobre a necessidade base',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecond),
        ),
      ],
    );
  }

  Widget _buildAbsorcaoSecaoK() {
    const tiposDisponiveis = ['Autores', 'Guidorizzi', 'Cultivar'];
    final fontes = _fontesParaTipoK(_potassioTipoFonte);
    final fonteAtual = fontes.contains(_potassioFonteNome)
        ? _potassioFonteNome!
        : (fontes.isNotEmpty ? fontes.first : '');
    final labelFonte = _potassioTipoFonte == 'Guidorizzi'
        ? 'Tecnologia'
        : _potassioTipoFonte == 'Cultivar'
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
          value: _potassioTipoFonte,
          items: tiposDisponiveis,
          labelOf: (t) => t,
          onChanged: (v) {
            if (v == null) return;
            final novasFontes = _fontesParaTipoK(v);
            setState(() {
              _potassioTipoFonte = v;
              _potassioFonteNome =
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
            setState(() => _potassioFonteNome = v);
            _emitChange();
          },
        ),
      ],
    );
  }

  Widget _ncBadge({
    Key? key,
    required TextEditingController controller,
    required double? value,
    required String placeholder,
    required String unit,
    required bool manual,
    required bool isPlaceholder,
    required VoidCallback onToggleManual,
    required VoidCallback onRestore,
  }) {
    final bg = manual
        ? AppColors.bgPrimary
        : isPlaceholder
            ? AppColors.bgWarning
            : AppColors.primary.withValues(alpha: 0.06);
    final bdr = manual
        ? AppColors.border
        : isPlaceholder
            ? AppColors.warning
            : AppColors.primary.withValues(alpha: 0.3);
    final valC =
        isPlaceholder && !manual ? AppColors.warning : AppColors.primary;
    final textValue = value == null ? '' : _fmtNumber(value);

    if (!manual && controller.text != textValue) {
      controller.text = textValue;
    }

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: bdr, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: !manual,
                  onChanged: (_) => _emitChange(),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(7),
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                  ],
                  style: TextStyle(
                    fontSize: manual ? 15 : 18,
                    fontWeight: manual ? FontWeight.w500 : FontWeight.w600,
                    color: manual ? AppColors.textPrimary : valC,
                    letterSpacing: manual ? 0 : -0.3,
                  ),
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
                    hintText: placeholder,
                    suffixText: unit,
                    suffixStyle: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecond,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToggleManual,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    manual ? Icons.edit_outlined : Icons.lock_outline,
                    key: ValueKey(manual),
                    size: 16,
                    color: manual ? AppColors.textSecond : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (manual) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onRestore,
            child: Text(
              'Restaurar valor automático',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ],
    );
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
            const Text(
              'Culturas',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );

  Widget _inlineError(String message) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          message,
          style: AppTextStyles.caption.copyWith(color: AppColors.error),
        ),
      );

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
    final screenH = MediaQuery.of(context).size.height;

    _tip = OverlayEntry(
      builder: (ctx) => Stack(
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
            right: 20,
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
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.20),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
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
      ),
    );
    Overlay.of(context).insert(_tip!);
  }

  void _removeTip() {
    _tip?.remove();
    _tip = null;
  }

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
  }) =>
      Container(
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
                .map(
                  (e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text(labelOf(e)),
                  ),
                )
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
          border: Border.all(color: AppColors.border, width: 1),
        ),
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

String _joinSegments(Iterable<String> values) {
  return values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(' · ');
}

String _fmtNumber(double? value, {bool emptyWhenNull = false}) {
  if (value == null) return emptyWhenNull ? '' : '';
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
        ..color = AppColors.textPrimary
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
