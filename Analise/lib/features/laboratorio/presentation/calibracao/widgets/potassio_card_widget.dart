// lib/presentation/lab/calibracao/widgets/potassio_card_widget.dart
//
// Card 3 — Potássio  ·  Versão final
//
// ══════════════════════════════════════════════════════════════════════════════
// DIFERENCIAL DO K vs P: dois critérios de NC simultâneos
//
//   • NC teor    → disponibilidade absoluta (mg/dm³)
//   • NC % CTC   → equilíbrio iônico na CTC
//   • Critério "Ambos — usar o maior" → calcula os dois, adota maior dose
//
// ══════════════════════════════════════════════════════════════════════════════
// REFERÊNCIAS E NC:
//
//  ┌──────────────────┬──────────────────┬──────────────┬──────────────┐
//  │ Referência       │ Extrator         │ NC teor      │ NC % CTC     │
//  ├──────────────────┼──────────────────┼──────────────┼──────────────┤
//  │ IAC Bol.100      │ Resina IAC       │ 80 mg/dm³    │ 4%           │
//  │ Embrapa Cerrado  │ Mehlich-1        │ 46 mg/dm³    │ 3%           │
//  │ Embrapa RS/SC    │ Resina/Mehlich-1 │ 80 mg/dm³    │ 4%           │
//  │ UFLA / CFSEMG    │ Mehlich-1        │ placeholder  │ placeholder  │
//  └──────────────────┴──────────────────┴──────────────┴──────────────┘
//
//  Fontes: Raij et al. (1996), Sousa & Lobato (2004), CQFS RS/SC (2004)
//
// ══════════════════════════════════════════════════════════════════════════════
// FEK (%) — Fator de Eficiência do fertilizante potassado
//
//  Origem: Vitti (2011) — f da fórmula ADUBAÇÃO = (PLANTA - SOLO) × f
//  Não é constante de nenhuma referência; é parâmetro de manejo editável.
//  Defaults por modo de aplicação baseados em literatura geral (Vitti, 2011):
//    • Lanço incorporado → 65%
//    • Lanço plantio direto → 50%
//    • Sulco de plantio → 80%
//    • Cobertura → 55%
//
// ══════════════════════════════════════════════════════════════════════════════
// REGRA ABSOLUTA: NC teor e NC %CTC são sempre read-only badges.
// FEK é o único campo editável — é parâmetro de manejo, não de referência.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/nutriente_card.dart';
import 'package:soloforte/data/culturas_data.dart';

// ══════════════════════════════════════════════════════════════════════════════
// DOMÍNIO
// ══════════════════════════════════════════════════════════════════════════════

enum ExtratorK { resinaIAC, mehlich1, resinaOuMehlich }

enum ReferenciaK { iacBol100, embrapasCerrado, embrapaRsSc, ufla }

enum CamadaK { c0a20, c20a40 }

enum CriterioNC { teor, ctc, ambosUsarMaior }

enum ModoCalculo { correcaoSolo, manutencao, exportacao }

enum ModoAplicacao { lancoIncorporado, lancoPD, sulco, cobertura }

extension ModoAplicacaoX on ModoAplicacao {
  String get label {
    switch (this) {
      case ModoAplicacao.lancoIncorporado:
        return 'Lanço incorporado';
      case ModoAplicacao.lancoPD:
        return 'Lanço plantio direto';
      case ModoAplicacao.sulco:
        return 'Sulco de plantio';
      case ModoAplicacao.cobertura:
        return 'Cobertura';
    }
  }

  // Defaults Vitti (2011) — f da fórmula ADUBAÇÃO = (PLANTA - SOLO) × f
  double get fekDefault {
    switch (this) {
      case ModoAplicacao.lancoIncorporado:
        return 65;
      case ModoAplicacao.lancoPD:
        return 50;
      case ModoAplicacao.sulco:
        return 80;
      case ModoAplicacao.cobertura:
        return 55;
    }
  }
}

// ─── Descriptor NC por referência ────────────────────────────────────────────

class _NcK {
  final double? ncTeor; // mg/dm³
  final double? ncCtcPct; // %
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
        '"Ambos — usar o maior": calcula a dose pelos dois critérios\n'
        'e adota a maior dose resultante (Raij et al., 1996).';
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

// ─── Descriptor NC por referência ────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
// WIDGET
// ══════════════════════════════════════════════════════════════════════════════

class PotassioCardWidget extends StatefulWidget {
  const PotassioCardWidget({
    super.key,
    this.initialData,
    this.cultura,
    this.onChanged,
  });

  final Map<String, dynamic>? initialData;
  final String? cultura;
  final ValueChanged<Map<String, dynamic>>? onChanged;

  @override
  State<PotassioCardWidget> createState() => _PotassioCardWidgetState();
}

class _PotassioCardWidgetState extends State<PotassioCardWidget> {
  ReferenciaK _ref = ReferenciaK.iacBol100;
  CamadaK _camada = CamadaK.c0a20;
  CriterioNC _criterio = CriterioNC.ambosUsarMaior;
  ModoCalculo _modo = ModoCalculo.correcaoSolo;
  ModoAplicacao _aplicacao = ModoAplicacao.lancoIncorporado;

  // Referência de Absorção bibliográfica (T3B)
  String _potassioTipoFonte = 'Autores';
  String? _potassioFonteNome;
  String _potassioModoAbsorcao = 'extracao';

  late TextEditingController _fekCtrl;
  Map<String, dynamic> _baseData = const {};
  final _ncBadgeKey = GlobalKey();
  OverlayEntry? _tip;

  @override
  void initState() {
    super.initState();
    _fekCtrl = TextEditingController(
      text: _aplicacao.fekDefault.toInt().toString(),
    );
    _syncFromExternalData(widget.initialData);
  }

  @override
  void didUpdateWidget(covariant PotassioCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(oldWidget.initialData, widget.initialData) ||
        oldWidget.cultura != widget.cultura) {
      _syncFromExternalData(widget.initialData);
    }
  }

  @override
  void dispose() {
    _fekCtrl.dispose();
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

  bool get _showTeor =>
      _criterio == CriterioNC.teor || _criterio == CriterioNC.ambosUsarMaior;
  bool get _showCtc =>
      _criterio == CriterioNC.ctc || _criterio == CriterioNC.ambosUsarMaior;
  bool get _isAmbos => _criterio == CriterioNC.ambosUsarMaior;

  void _syncFromExternalData(Map<String, dynamic>? data) {
    final source = data ?? const <String, dynamic>{};
    _baseData = Map<String, dynamic>.from(source);

    _ref = _referenciaFromString(source['referencia']?.toString());
    _camada = _camadaFromString(source['camada']?.toString());
    _criterio = _criterioFromString(source['criterioNc']?.toString());
    _modo = _modoFromString(source['modoCalculo']?.toString());
    _aplicacao = _aplicacaoFromString(source['modoAplicacao']?.toString());
    _potassioTipoFonte = source['potassioTipoFonte']?.toString() ?? 'Autores';
    _potassioFonteNome = source['potassioFonteNome']?.toString();
    _potassioModoAbsorcao =
        source['potassioModoAbsorcao']?.toString() ?? 'extracao';

    final fek = source['fekBase'];
    final fekTexto =
        fek == null ? _aplicacao.fekDefault.toString() : fek.toString();
    _fekCtrl.text = fekTexto.replaceAll('.', ',');
  }

  void _emitChange() {
    if (widget.onChanged == null) return;

    final fekBase = double.tryParse(_fekCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final cultura =
        widget.cultura ?? _baseData['cultivar']?.toString() ?? 'Soja';

    final payload = <String, dynamic>{
      ..._baseData,
      'extrator': _extratorLabel,
      'referencia': _d.label,
      'criterioNc': _criterioLabelForPayload(_criterio),
      'ncTeor': _d.nc.ncTeor ?? _baseData['ncTeor'] ?? 80.0,
      'ncPctCtc': _d.nc.ncCtcPct ?? _baseData['ncPctCtc'] ?? 4.0,
      'camada': _camada == CamadaK.c0a20 ? '0–20 cm' : '20–40 cm',
      'modoCalculo': _modoLabelForPayload(_modo),
      'modoAplicacao': _aplicacao.label,
      'fekBase': fekBase,
      'cultivar': cultura,
      'tipoDadoCultivar': _tipoFromModo(_modo),
      'potassioTipoFonte': _potassioTipoFonte,
      'potassioFonteNome': _potassioFonteNome ??
          (_fontesParaTipoK(_potassioTipoFonte).isNotEmpty
              ? _fontesParaTipoK(_potassioTipoFonte).first
              : ''),
      'potassioModoAbsorcao': _potassioModoAbsorcao,
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
    return value == '20–40 cm' ? CamadaK.c20a40 : CamadaK.c0a20;
  }

  CriterioNC _criterioFromString(String? value) {
    switch (value) {
      case 'Teor absoluto':
        return CriterioNC.teor;
      case '% K na CTC':
        return CriterioNC.ctc;
      case 'Ambos — usar o maior':
      default:
        return CriterioNC.ambosUsarMaior;
    }
  }

  ModoCalculo _modoFromString(String? value) {
    if (value == null) return ModoCalculo.correcaoSolo;
    if (value.contains('Extração')) return ModoCalculo.exportacao;
    if (value.contains('Manutenção')) return ModoCalculo.manutencao;
    return ModoCalculo.correcaoSolo;
  }

  ModoAplicacao _aplicacaoFromString(String? value) {
    switch (value) {
      case 'Lanço plantio direto':
      case 'Lanço sem incorporação':
        return ModoAplicacao.lancoPD;
      case 'Sulco de plantio':
      case 'Sulco':
        return ModoAplicacao.sulco;
      case 'Cobertura':
        return ModoAplicacao.cobertura;
      case 'Lanço incorporado':
      default:
        return ModoAplicacao.lancoIncorporado;
    }
  }

  String _criterioLabelForPayload(CriterioNC criterio) {
    switch (criterio) {
      case CriterioNC.teor:
        return 'Teor absoluto';
      case CriterioNC.ctc:
        return '% K na CTC';
      case CriterioNC.ambosUsarMaior:
        return 'Ambos — usar o maior';
    }
  }

  String _modoLabelForPayload(ModoCalculo modo) {
    switch (modo) {
      case ModoCalculo.correcaoSolo:
        return '① Correção do solo';
      case ModoCalculo.manutencao:
        return '② Manutenção';
      case ModoCalculo.exportacao:
        return '② Extração';
    }
  }

  String _tipoFromModo(ModoCalculo modo) {
    return modo == ModoCalculo.manutencao ? 'Extração total' : 'Exportação';
  }
  // ── T3B: Helpers de Referência de Absorção ───────────────────────────────────────

  List<String> _fontesParaTipoK(String tipo) {
    if (tipo == 'Guidorizzi') return kTecnologias.keys.toList();
    if (tipo == 'Cultivar') return kCultivares.keys.toList();
    return kAutores.keys.toList();
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
        const SizedBox(height: AppDimens.sm),
        _lbl('Extração / Exportação'),
        const SizedBox(height: AppDimens.xs),
        _modoAbsorcaoToggleK(),
      ],
    );
  }

  Widget _modoAbsorcaoToggleK() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _toggleBtnK(
          label: 'Extração',
          selected: _potassioModoAbsorcao == 'extracao',
          onTap: () {
            setState(() => _potassioModoAbsorcao = 'extracao');
            _emitChange();
          },
          isLeft: true,
        ),
        _toggleBtnK(
          label: 'Exportação',
          selected: _potassioModoAbsorcao == 'exportacao',
          onTap: () {
            setState(() => _potassioModoAbsorcao = 'exportacao');
            _emitChange();
          },
          isLeft: false,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.borderSoft,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(8) : Radius.zero,
            right: isLeft ? Radius.zero : const Radius.circular(8),
          ),
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
  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return NutrienteCard(
      nutriente: 'Card 3 — Potássio',
      icon: Icons.bolt_outlined,
      cor: AppColors.potassio,
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
                      _emitChange();
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.sm),

        // 3 · Critério NC
        _lbl('Critério NC'),
        const SizedBox(height: AppDimens.xs),
        _drop<CriterioNC>(
          value: _criterio,
          items: CriterioNC.values,
          labelOf: (c) {
            switch (c) {
              case CriterioNC.teor:
                return 'NC teor';
              case CriterioNC.ctc:
                return 'NC % CTC';
              case CriterioNC.ambosUsarMaior:
                return 'Ambos — usar o maior';
            }
          },
          onChanged: (v) => setState(() {
            _criterio = v!;
            _emitChange();
          }),
        ),
        const SizedBox(height: AppDimens.sm),

        // 4 · Badges NC — layout dinâmico por critério
        _buildNcSection(),
        const SizedBox(height: AppDimens.sm),

        // 5 · Camada
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

        // 6 · Modo de cálculo
        _lbl('Modo de cálculo'),
        const SizedBox(height: AppDimens.xs),
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
          onChanged: (v) => setState(() {
            _modo = v!;
            _emitChange();
          }),
        ),
        const SizedBox(height: AppDimens.sm),

        // 7 · Modo de aplicação
        _lbl('Modo de aplicação'),
        const SizedBox(height: AppDimens.xs),
        _drop<ModoAplicacao>(
          value: _aplicacao,
          items: ModoAplicacao.values,
          labelOf: (a) => a.label,
          onChanged: (v) => setState(() {
            _aplicacao = v!;
            _fekCtrl.text = v.fekDefault.toInt().toString();
            _emitChange();
          }),
        ),
        const SizedBox(height: AppDimens.sm),

        // 8 · FEK — único campo editável do card
        _buildFekSection(), const SizedBox(height: AppDimens.sm),
        _buildAbsorcaoSecaoK(),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEÇÃO NC — badges dinâmicos + chip "ambos"
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildNcSection() {
    final isPlaceholder = _d.nc.placeholder;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // NC teor
            if (_showTeor)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _lbl('NC teor (mg/dm³)'),
                    const SizedBox(height: AppDimens.xs),
                    _ncBadge(
                      key: _ncBadgeKey,
                      value: _d.nc.ncTeor != null
                          ? _d.nc.ncTeor!.toInt().toString()
                          : '—',
                      unit: isPlaceholder ? '*' : 'mg/dm³',
                      isPlaceholder: isPlaceholder,
                    ),
                  ],
                ),
              ),
            if (_showTeor && _showCtc) const SizedBox(width: 12),
            // NC % CTC
            if (_showCtc)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _lbl('NC % CTC'),
                    const SizedBox(height: AppDimens.xs),
                    _ncBadge(
                      value: _d.nc.ncCtcPct != null
                          ? _d.nc.ncCtcPct!.toInt().toString()
                          : '—',
                      unit: isPlaceholder ? '*' : '%',
                      isPlaceholder: isPlaceholder,
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
            _infoBtn(_d.tooltipText),
          ],
        ),

        // Chip verde "usar o maior"
        if (_isAmbos) ...[
          const SizedBox(height: AppDimens.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.bgSuccess,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.5), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    size: 13, color: AppColors.success),
                SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'O app calcula pelos dois critérios e usa a maior dose',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Nota placeholder UFLA
        if (isPlaceholder)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              '* Valores NC provisórios — tabela CFSEMG/UFLA pendente.',
              style: TextStyle(
                fontSize: 10.5,
                color: Color(0xFFBF360C),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  // ─── Badge NC ─────────────────────────────────────────────────────────────

  Widget _ncBadge({
    Key? key,
    required String value,
    required String unit,
    required bool isPlaceholder,
  }) {
    final bg = isPlaceholder ? AppColors.bgWarning : const Color(0xFFEEF4FF);
    final bdr = isPlaceholder ? AppColors.warning : const Color(0xFFB8D4FF);
    final valC = isPlaceholder ? const Color(0xFFBF360C) : AppColors.primary;

    return Container(
      key: key,
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
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: valC,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 5),
          Text(unit,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textSecond)),
          const Spacer(),
          Icon(Icons.lock_outline_rounded,
              size: 13, color: valC.withValues(alpha: 0.35)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEÇÃO FEK
  // ══════════════════════════════════════════════════════════════════════════
  //
  // FEK = fator f da fórmula ADUBAÇÃO = (PLANTA - SOLO) × f (Vitti, 2011)
  // É o único campo editável do card: depende do fertilizante e do manejo,
  // não de uma referência científica fixa.
  // O valor padrão é preenchido automaticamente ao trocar o modo de aplicação.

  Widget _buildFekSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _lbl('FEK (%)'),
            const SizedBox(width: 6),
            _infoBtn(
              'Fator de Eficiência do fertilizante potassado.\n'
              'Representa o "f" da fórmula de Vitti (2011):\n'
              'ADUBAÇÃO = (PLANTA − SOLO) × f\n\n'
              'Defaults por modo de aplicação:\n'
              '· Lanço incorporado → 65%\n'
              '· Lanço plantio direto → 50%\n'
              '· Sulco de plantio → 80%\n'
              '· Cobertura → 55%\n\n'
              'Edite se o fertilizante ou as condições forem diferentes.',
            ),
          ],
        ),
        const SizedBox(height: AppDimens.xs),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fekCtrl,
                  onChanged: (_) => _emitChange(),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(7),
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.textPrimary),
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
              // Botão reset para o padrão do modo atual
              GestureDetector(
                onTap: () => setState(() {
                  _fekCtrl.text = _aplicacao.fekDefault.toInt().toString();
                  _emitChange();
                }),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Text(
                    'Padrão: ${_aplicacao.fekDefault.toInt()}%',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecond,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Preenchido automaticamente pelo modo de aplicação. Edite se necessário.',
          style: TextStyle(
            fontSize: 10.5,
            color: AppColors.textSecond,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TOOLTIP ⓘ (overlay iOS)
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
                          fontSize: 12, color: Colors.white, height: 1.5),
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

  // ─── Helpers UI ───────────────────────────────────────────────────────────

  Widget _lbl(String t) => Text(
        t,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecond,
            letterSpacing: 0.3),
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
          border: Border.all(color: AppColors.border, width: 1),
        ),
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
}

// ─── Seta tooltip ─────────────────────────────────────────────────────────────

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
