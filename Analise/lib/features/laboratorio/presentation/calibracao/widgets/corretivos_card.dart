import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/calibracao_status_badge.dart';

class CorretivosCard extends StatefulWidget {
  const CorretivosCard({
    super.key,
    required this.draft,
    required this.draftKey,
    required this.corretivos,
    required this.isExpanded,
    required this.onToggle,
    required this.onChanged,
  });

  static const title = 'I · Corretivos (Calagem/Gessagem)';

  final CalibracaoProfile draft;
  final String draftKey;
  final Map<String, dynamic> corretivos;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<Map<String, dynamic>> onChanged;

  @override
  State<CorretivosCard> createState() => _CorretivosCardState();
}

class _CorretivosCardState extends State<CorretivosCard> {
  static const Duration _animDuration = Duration(milliseconds: 250);

  final GlobalKey _cardKey = GlobalKey();

  @override
  void didUpdateWidget(covariant CorretivosCard oldWidget) {
    super.didUpdateWidget(oldWidget);
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
                color: const Color(0xFF007AFF),
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
                    'Corretivos',
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
                            key: const ValueKey('corretivos-resumo'),
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
    final lines = _collapsedSummaryLines();
    if (lines.isEmpty) return const SizedBox.shrink();

    final captionStyle = AppTextStyles.caption.copyWith(
      color: AppColors.textSecond,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines) ...[
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
    final calcario1 = _asMap(widget.corretivos['calcario1']);
    final albrecht = _asMap(widget.corretivos['albrecht']);
    final metodoCalagem = _labelMetodo(widget.corretivos['metodoCalagem']);
    final tipoCalcario = _string(widget.corretivos['tipoCalcario']);
    final usarNivelCritico = _bool(widget.corretivos['usarNivelCritico']);

    final caDesejadoPct = _numOrNull(widget.corretivos['caDesejadoPct']) ??
        _numOrNull(albrecht['caAlvo']);
    final mgDesejadoPct = _numOrNull(widget.corretivos['mgDesejadoPct']) ??
        _numOrNull(albrecht['mgAlvo']);
    final kDesejadoPct = _numOrNull(widget.corretivos['kDesejadoPct']) ??
        _numOrNull(albrecht['kAlvo']);
    final ncCa =
        _numOrNull(widget.corretivos['ncCa']) ?? _numOrNull(albrecht['ncCa']);
    final ncMg =
        _numOrNull(widget.corretivos['ncMg']) ?? _numOrNull(albrecht['ncMg']);
    final ncK =
        _numOrNull(widget.corretivos['ncK']) ?? _numOrNull(albrecht['ncK']);

    final criterio = usarNivelCritico
        ? _joinSegments([
            if (ncCa != null) 'Ca ${_fmt(ncCa)}',
            if (ncMg != null) 'Mg ${_fmt(ncMg)}',
            if (ncK != null) 'K ${_fmt(ncK)}',
          ])
        : _joinSegments([
            if (caDesejadoPct != null)
              'Ca ${_fmt(caDesejadoPct, decimals: 0)}%',
            if (mgDesejadoPct != null)
              'Mg ${_fmt(mgDesejadoPct, decimals: 0)}%',
            if (kDesejadoPct != null) 'K ${_fmt(kDesejadoPct, decimals: 0)}%',
          ]);

    return [
      _joinSegments([metodoCalagem ?? '', tipoCalcario]),
      _joinSegments([
        _percentSegment('PRNT', widget.corretivos['prnt'] ?? calcario1['prnt']),
        _percentSegment('CaO', calcario1['caO']),
        _percentSegment('MgO', calcario1['mgO']),
      ]),
      if (criterio.isNotEmpty)
        usarNivelCritico ? 'NC: $criterio cmolc/dm³' : 'Meta: $criterio',
    ].where((line) => line.isNotEmpty).toList();
  }

  Widget _buildConteudo() {
    final tipoCalagem = _string(widget.corretivos['tipoCalagem'],
        fallback: _tiposCalagem.first);
    final metodos = tipoCalagem == 'Manutenção PD'
        ? _metodosCalagemPd
        : _metodosCalagemCorretiva;
    var metodoCalagem =
        _string(widget.corretivos['metodoCalagem'], fallback: metodos.first);
    if (!metodos.contains(metodoCalagem)) {
      metodoCalagem = metodos.first;
    }

    final calcario1 = _asMap(widget.corretivos['calcario1']);
    final calcario2 = _asMap(widget.corretivos['calcario2']);
    final usarSegundoCalcario = _bool(widget.corretivos['usarSegundoCalcario']);
    final proporcao1 =
        _num(widget.corretivos['proporcaoCalcario1'], fallback: 50);
    final proporcao2 = (100 - proporcao1).clamp(0, 100).toDouble();
    final prnt1 = _num(calcario1['prnt']);
    final prnt2 = _num(calcario2['prnt']);
    final prntPonderado = usarSegundoCalcario
        ? ((prnt1 * proporcao1) + (prnt2 * proporcao2)) / 100
        : prnt1;

    final albrecht = _asMap(widget.corretivos['albrecht']);
    final metodoIncorp = _string(widget.corretivos['metodoIncorporacao'],
        fallback: _metodosIncorporacao.first);
    final scAtual = _num(widget.corretivos['sc'], fallback: 1.0);
    final scLabel = _superficieContato.entries
        .firstWhere(
          (entry) => (entry.value - scAtual).abs() < 0.001,
          orElse: () => _superficieContato.entries.first,
        )
        .key;
    final mes =
        _string(widget.corretivos['mesAplicacao'], fallback: _meses.first);

    final gesso = _asMap(widget.corretivos['gesso']);
    final usarGesso = _bool(gesso['usarGesso']);
    final usarNivelCritico = _bool(widget.corretivos['usarNivelCritico']);

    final qualidade = _qualidadeCalcario(prnt1);
    final scoreBars = (qualidade / 20).clamp(0, 5).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: _tiposCalagem
              .map(
                (tipo) => ChoiceChip(
                  label: Text(tipo),
                  selected: tipoCalagem == tipo,
                  onSelected: (_) {
                    final atualizado = {...widget.corretivos};
                    atualizado['tipoCalagem'] = tipo;
                    if (tipo == 'Manutenção PD' &&
                        !_metodosCalagemPd
                            .contains(atualizado['metodoCalagem'])) {
                      atualizado['metodoCalagem'] = _metodosCalagemPd.first;
                    }
                    widget.onChanged(atualizado);
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 14),
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: 'Tipo de calcário',
          value: _safeValue(
              _tiposCalcario,
              _string(widget.corretivos['tipoCalcario'],
                  fallback: _tiposCalcario.first)),
          items: _tiposCalcario
              .map((tipo) => AppDropdownItem(value: tipo, label: tipo))
              .toList(),
          onChanged: (value) {
            final atualizado = {...widget.corretivos};
            atualizado['tipoCalcario'] = value ?? _tiposCalcario.first;
            widget.onChanged(atualizado);
          },
        ),
        const SizedBox(height: 10),
        _buildNumericPair(
          left: _buildNumericInput(
            keyValue: '${widget.draftKey}-c1-cao',
            label: 'CaO (%)',
            value: _num(calcario1['caO']),
            onChanged: (value) {
              final atualizado = {...widget.corretivos};
              final c1 = {...calcario1, 'caO': value};
              atualizado['calcario1'] = c1;
              widget.onChanged(atualizado);
            },
          ),
          right: _buildNumericInput(
            keyValue: '${widget.draftKey}-c1-mgo',
            label: 'MgO (%)',
            value: _num(calcario1['mgO']),
            onChanged: (value) {
              final atualizado = {...widget.corretivos};
              final c1 = {...calcario1, 'mgO': value};
              atualizado['calcario1'] = c1;
              widget.onChanged(atualizado);
            },
          ),
        ),
        const SizedBox(height: 8),
        _buildNumericPair(
          left: _buildNumericInput(
            keyValue: '${widget.draftKey}-c1-pn',
            label: 'PN (%)',
            value: _num(calcario1['pn']),
            onChanged: (value) {
              final atualizado = {...widget.corretivos};
              final c1 = {...calcario1, 'pn': value};
              c1['prnt'] = _recalcularPrnt(c1);
              atualizado['calcario1'] = c1;
              widget.onChanged(atualizado);
            },
          ),
          right: _buildNumericInput(
            keyValue: '${widget.draftKey}-c1-re',
            label: 'RE (%)',
            value: _num(calcario1['re']),
            onChanged: (value) {
              final atualizado = {...widget.corretivos};
              final c1 = {...calcario1, 're': value};
              c1['prnt'] = _recalcularPrnt(c1);
              atualizado['calcario1'] = c1;
              widget.onChanged(atualizado);
            },
          ),
        ),
        const SizedBox(height: 8),
        _buildNumericInput(
          keyValue: '${widget.draftKey}-c1-prnt',
          label: 'PRNT (%)',
          value: _num(calcario1['prnt']),
          onChanged: (value) {
            final atualizado = {...widget.corretivos};
            atualizado['calcario1'] = {...calcario1, 'prnt': value};
            widget.onChanged(atualizado);
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text('Score de qualidade', style: AppTextStyles.label),
            const SizedBox(width: 8),
            Row(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(
                    Icons.square_rounded,
                    size: 12,
                    color: index < scoreBars
                        ? AppColors.primary
                        : AppColors.borderSoft,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'PN: ${_fmt(_num(calcario1['pn']), decimals: 1)}% · RE: ${_fmt(_num(calcario1['re']), decimals: 1)}% · Residual: ${_fmt(100 - _num(calcario1['re']), decimals: 1)}%',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            qualidade >= 80
                ? 'Qualidade alta para aplicação com resposta rápida.'
                : qualidade >= 60
                    ? 'Qualidade intermediária: atenção ao período de aplicação.'
                    : 'Qualidade baixa: considerar ajuste de fonte/época.',
            style: AppTextStyles.caption,
          ),
        ),
        const SizedBox(height: 10),
        _buildMetaCaMgKSection(
          usarNivelCritico: usarNivelCritico,
          albrecht: albrecht,
        ),
        const SizedBox(height: 10),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Usar 2º calcário?'),
          value: usarSegundoCalcario,
          onChanged: (value) {
            final atualizado = {
              ...widget.corretivos,
              'usarSegundoCalcario': value
            };
            widget.onChanged(atualizado);
          },
        ),
        if (usarSegundoCalcario) ...[
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '${widget.draftKey}-c2-cao',
              label: 'CaO 2º (%)',
              value: _num(calcario2['caO']),
              onChanged: (value) {
                final atualizado = {...widget.corretivos};
                atualizado['calcario2'] = {...calcario2, 'caO': value};
                widget.onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '${widget.draftKey}-c2-mgo',
              label: 'MgO 2º (%)',
              value: _num(calcario2['mgO']),
              onChanged: (value) {
                final atualizado = {...widget.corretivos};
                atualizado['calcario2'] = {...calcario2, 'mgO': value};
                widget.onChanged(atualizado);
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '${widget.draftKey}-c2-pn',
              label: 'PN 2º (%)',
              value: _num(calcario2['pn']),
              onChanged: (value) {
                final atualizado = {...widget.corretivos};
                final c2 = {...calcario2, 'pn': value};
                c2['prnt'] = _recalcularPrnt(c2);
                atualizado['calcario2'] = c2;
                widget.onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '${widget.draftKey}-c2-re',
              label: 'RE 2º (%)',
              value: _num(calcario2['re']),
              onChanged: (value) {
                final atualizado = {...widget.corretivos};
                final c2 = {...calcario2, 're': value};
                c2['prnt'] = _recalcularPrnt(c2);
                atualizado['calcario2'] = c2;
                widget.onChanged(atualizado);
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '${widget.draftKey}-c2-prnt',
              label: 'PRNT 2º (%)',
              value: _num(calcario2['prnt']),
              onChanged: (value) {
                final atualizado = {...widget.corretivos};
                atualizado['calcario2'] = {...calcario2, 'prnt': value};
                widget.onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '${widget.draftKey}-c2-prop',
              label: 'Proporção 1º (%)',
              value: proporcao1,
              onChanged: (value) {
                final atualizado = {
                  ...widget.corretivos,
                  'proporcaoCalcario1': value.clamp(0, 100)
                };
                widget.onChanged(atualizado);
              },
            ),
          ),
          const SizedBox(height: 6),
          CalibracaoStatusBadge(
            icon: Icons.analytics_outlined,
            color: AppColors.primary,
            label: 'PRNT ponderado: ${_fmt(prntPonderado, decimals: 1)}%',
          ),
        ],
        const SizedBox(height: 14),
        AppDropdown<String>(
          label: 'Método de calagem',
          value: _safeValue(metodos, metodoCalagem),
          items: metodos
              .map((metodo) => AppDropdownItem(value: metodo, label: metodo))
              .toList(),
          onChanged: (value) {
            final atualizado = {
              ...widget.corretivos,
              'metodoCalagem': value ?? metodos.first
            };
            widget.onChanged(atualizado);
          },
        ),
        const SizedBox(height: 10),
        if (metodoCalagem.startsWith('Saturação'))
          _buildNumericInput(
            keyValue: '${widget.draftKey}-v2',
            label: 'V₂ desejado (%)',
            value: _num(widget.corretivos['v2'],
                fallback: _sugestaoV2(widget.draft.cultura)),
            onChanged: (value) {
              final atualizado = {...widget.corretivos, 'v2': value};
              widget.onChanged(atualizado);
            },
          ),
        if (metodoCalagem.startsWith('②'))
          _buildNumericInput(
            keyValue: '${widget.draftKey}-hal',
            label: 'Fator H+Al',
            value: _num(widget.corretivos['fatorHAl'], fallback: 0.5),
            onChanged: (value) {
              final atualizado = {...widget.corretivos, 'fatorHAl': value};
              widget.onChanged(atualizado);
            },
          ),
        if (metodoCalagem.startsWith('④'))
          _buildNumericInput(
            keyValue: '${widget.draftKey}-dose-fixa',
            label: 'Dose fixa (t/ha)',
            value: _num(widget.corretivos['doseFixa'], fallback: 1.0),
            onChanged: (value) {
              final atualizado = {...widget.corretivos, 'doseFixa': value};
              widget.onChanged(atualizado);
            },
          ),
        if (metodoCalagem.startsWith('⑦'))
          _buildNumericInput(
            keyValue: '${widget.draftKey}-mg-alvo',
            label: 'Mg desejado (cmolc/dm³)',
            value: _num(widget.corretivos['mgDesejado'], fallback: 0.8),
            onChanged: (value) {
              final atualizado = {...widget.corretivos, 'mgDesejado': value};
              widget.onChanged(atualizado);
            },
          ),
        if (metodoCalagem.startsWith('Albrecht') ||
            metodoCalagem.startsWith('⑥')) ...[
          const SizedBox(height: 14),
          const SizedBox(height: 8),
          CalibracaoStatusBadge(
            icon: Icons.grass_outlined,
            color: AppColors.primary,
            label: 'Cultura: ${widget.draft.cultura}',
          ),
          const SizedBox(height: 8),
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '${widget.draftKey}-alb-ca',
              label: 'Ca alvo (%)',
              value: _num(albrecht['caAlvo'], fallback: 65),
              onChanged: (value) {
                final atualizado = {...widget.corretivos};
                atualizado['albrecht'] = {...albrecht, 'caAlvo': value};
                widget.onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '${widget.draftKey}-alb-ca-nc',
              label: 'NC Ca mín',
              value: _num(albrecht['ncCa'], fallback: 2.0),
              onChanged: (value) {
                final atualizado = {...widget.corretivos};
                atualizado['albrecht'] = {...albrecht, 'ncCa': value};
                widget.onChanged(atualizado);
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '${widget.draftKey}-alb-mg',
              label: 'Mg alvo (%)',
              value: _num(albrecht['mgAlvo'], fallback: 15),
              onChanged: (value) {
                final atualizado = {...widget.corretivos};
                atualizado['albrecht'] = {...albrecht, 'mgAlvo': value};
                widget.onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '${widget.draftKey}-alb-mg-nc',
              label: 'NC Mg mín',
              value: _num(albrecht['ncMg'], fallback: 0.8),
              onChanged: (value) {
                final atualizado = {...widget.corretivos};
                atualizado['albrecht'] = {...albrecht, 'ncMg': value};
                widget.onChanged(atualizado);
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '${widget.draftKey}-alb-k',
              label: 'K alvo (%)',
              value: _num(albrecht['kAlvo'], fallback: 4),
              onChanged: (value) {
                final atualizado = {...widget.corretivos};
                atualizado['albrecht'] = {...albrecht, 'kAlvo': value};
                widget.onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '${widget.draftKey}-alb-k-nc',
              label: 'NC K mín',
              value: _num(albrecht['ncK'], fallback: 0.15),
              onChanged: (value) {
                final atualizado = {...widget.corretivos};
                atualizado['albrecht'] = {...albrecht, 'ncK': value};
                widget.onChanged(atualizado);
              },
            ),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Na (usar meta)'),
            value: _bool(albrecht['incluirNa']),
            onChanged: (value) {
              final atualizado = {...widget.corretivos};
              atualizado['albrecht'] = {...albrecht, 'incluirNa': value};
              widget.onChanged(atualizado);
            },
          ),
          const SizedBox(height: 6),
          CalibracaoStatusBadge(
            icon: Icons.verified_outlined,
            color: _badgeAlbrechtColor(albrecht),
            label:
                'V% implícito: ${_fmt(_vImplicito(albrecht), decimals: 1)}% — ${_vImplicito(albrecht) >= 70 ? 'Adequado' : 'Fora da faixa'}',
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Painel de déficits em tempo real aparece quando houver análise vinculada.',
              style: AppTextStyles.caption,
            ),
          ),
          if (metodoCalagem.startsWith('⑥')) ...[
            const SizedBox(height: 8),
            CalibracaoStatusBadge(
              icon: Icons.shield_outlined,
              color: AppColors.primaryDark,
              label:
                  'Painel Y: NC Albrecht ${_fmt(_num(widget.corretivos['doseFixa'], fallback: 1.2), decimals: 2)} t/ha · Y do solo ${_fmt(_num(widget.corretivos['doseFixa'], fallback: 1.2), decimals: 2)} t/ha',
            ),
          ],
        ],
        const SizedBox(height: 14),
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: 'Método de incorporação',
          value: _safeValue(_metodosIncorporacao, metodoIncorp),
          items: _metodosIncorporacao
              .map((metodo) => AppDropdownItem(value: metodo, label: metodo))
              .toList(),
          onChanged: (value) {
            final atualizado = {
              ...widget.corretivos,
              'metodoIncorporacao': value ?? _metodosIncorporacao.first
            };
            widget.onChanged(atualizado);
          },
        ),
        const SizedBox(height: 8),
        if (metodoIncorp.contains('Grade')) ...[
          _buildNumericPair(
            left: AppDropdown<String>(
              label: 'Tipo de grade',
              value: _safeValue(_tiposGrade,
                  '${_num(widget.corretivos['diametroGradePol'], fallback: 32).round()}"'),
              items: _tiposGrade
                  .map((tipo) => AppDropdownItem(value: tipo, label: tipo))
                  .toList(),
              onChanged: (value) {
                final atualizado = {...widget.corretivos};
                atualizado['diametroGradePol'] =
                    _parseDouble(value?.replaceAll('"', '') ?? '32');
                widget.onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '${widget.draftKey}-folga',
              label: 'Folga mancal (cm)',
              value: _num(widget.corretivos['folgaMancal'], fallback: 25),
              onChanged: (value) {
                final atualizado = {...widget.corretivos, 'folgaMancal': value};
                widget.onChanged(atualizado);
              },
            ),
          ),
          const SizedBox(height: 8),
          CalibracaoStatusBadge(
            icon: Icons.straighten_outlined,
            color: AppColors.primary,
            label:
                'Profundidade estimada: ${_fmt(_profundidadeGrade(widget.corretivos), decimals: 1)} cm · Fator p: ${_fmt(_fatorP(widget.corretivos), decimals: 2)}',
          ),
        ] else ...[
          _buildNumericInput(
            keyValue: '${widget.draftKey}-profundidade',
            label: 'Profundidade (cm)',
            value: _num(widget.corretivos['profundidadeManual'], fallback: 20),
            onChanged: (value) {
              final atualizado = {
                ...widget.corretivos,
                'profundidadeManual': value
              };
              widget.onChanged(atualizado);
            },
          ),
          const SizedBox(height: 8),
          CalibracaoStatusBadge(
            icon: Icons.straighten_outlined,
            color: AppColors.primary,
            label: 'Fator p: ${_fmt(_fatorP(widget.corretivos), decimals: 2)}',
          ),
        ],
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: 'Superfície de contato',
          value: scLabel,
          items: _superficieContato.keys
              .map((item) => AppDropdownItem(value: item, label: item))
              .toList(),
          onChanged: (value) {
            final atualizado = {
              ...widget.corretivos,
              'sc': _superficieContato[value] ?? 1.0
            };
            widget.onChanged(atualizado);
          },
        ),
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: 'Mês de aplicação',
          value: _safeValue(_meses, mes),
          items: _meses
              .map((item) => AppDropdownItem(value: item, label: item))
              .toList(),
          onChanged: (value) {
            final atualizado = {
              ...widget.corretivos,
              'mesAplicacao': value ?? _meses.first
            };
            widget.onChanged(atualizado);
          },
        ),
        const SizedBox(height: 6),
        CalibracaoStatusBadge(
          icon: Icons.calendar_month_outlined,
          color: AppColors.warning,
          label: 'Dias disponíveis: ${_diasPorMes[mes] ?? 30} dias',
        ),
        const SizedBox(height: 14),
        const SizedBox(height: 8),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Vai usar gesso?'),
          value: usarGesso,
          onChanged: (value) {
            final atualizado = {...widget.corretivos};
            atualizado['gesso'] = {...gesso, 'usarGesso': value};
            widget.onChanged(atualizado);
          },
        ),
        if (usarGesso) ...[
          AppDropdown<String>(
            label: 'Método',
            value: _safeValue(_metodosGesso,
                _string(gesso['metodo'], fallback: _metodosGesso.first)),
            items: _metodosGesso
                .map((item) => AppDropdownItem(value: item, label: item))
                .toList(),
            onChanged: (value) {
              final atualizado = {...widget.corretivos};
              atualizado['gesso'] = {
                ...gesso,
                'metodo': value ?? _metodosGesso.first
              };
              widget.onChanged(atualizado);
            },
          ),
          const SizedBox(height: 8),
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '${widget.draftKey}-gesso-ca',
              label: 'Teor Ca (%)',
              value: _num(gesso['teorCa'], fallback: 20),
              onChanged: (value) {
                final atualizado = {...widget.corretivos};
                atualizado['gesso'] = {...gesso, 'teorCa': value};
                widget.onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '${widget.draftKey}-gesso-s',
              label: 'Teor S (%)',
              value: _num(gesso['teorS'], fallback: 15),
              onChanged: (value) {
                final atualizado = {...widget.corretivos};
                atualizado['gesso'] = {...gesso, 'teorS': value};
                widget.onChanged(atualizado);
              },
            ),
          ),
          const SizedBox(height: 8),
          const CalibracaoStatusBadge(
            icon: Icons.auto_awesome_outlined,
            color: AppColors.warning,
            label: 'Dados de subsolo virão da Análise · diagnóstico: indicado',
          ),
        ],
      ],
    );
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

  Widget _buildMetaCaMgKSection({
    required bool usarNivelCritico,
    required Map<String, dynamic> albrecht,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24, thickness: 0.5, color: Color(0xFFE5E5E7)),
        Text(
          'META DE CA, MG E K',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecond,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ToggleBtn(
                label: '% da CTC',
                selected: !usarNivelCritico,
                onTap: () => _updateCorretivoValue('usarNivelCritico', false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ToggleBtn(
                label: 'Nível Crítico',
                selected: usarNivelCritico,
                onTap: () => _updateCorretivoValue('usarNivelCritico', true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: usarNivelCritico
              ? _buildInputsNc(key: const ValueKey('nc'), albrecht: albrecht)
              : _buildInputsPct(key: const ValueKey('pct'), albrecht: albrecht),
        ),
      ],
    );
  }

  Widget _buildInputsPct({
    Key? key,
    required Map<String, dynamic> albrecht,
  }) {
    final ca = _numOrNull(widget.corretivos['caDesejadoPct']) ??
        _numOrNull(albrecht['caAlvo']);
    final mg = _numOrNull(widget.corretivos['mgDesejadoPct']) ??
        _numOrNull(albrecht['mgAlvo']);
    final k = _numOrNull(widget.corretivos['kDesejadoPct']) ??
        _numOrNull(albrecht['kAlvo']);

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _LabeledInput(
                label: 'Ca (%)',
                placeholder: '65',
                value: ca,
                onChanged: (value) =>
                    _updateCorretivoValue('caDesejadoPct', _numInput(value)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _LabeledInput(
                label: 'Mg (%)',
                placeholder: '15',
                value: mg,
                onChanged: (value) =>
                    _updateCorretivoValue('mgDesejadoPct', _numInput(value)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _LabeledInput(
                label: 'K (%)',
                placeholder: '5',
                value: k,
                onChanged: (value) =>
                    _updateCorretivoValue('kDesejadoPct', _numInput(value)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'A soma Ca + Mg + K define o V% desejado',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecond),
        ),
        const SizedBox(height: 4),
        _buildSomaV(ca: ca, mg: mg, k: k),
      ],
    );
  }

  Widget _buildInputsNc({
    Key? key,
    required Map<String, dynamic> albrecht,
  }) {
    final ncCa =
        _numOrNull(widget.corretivos['ncCa']) ?? _numOrNull(albrecht['ncCa']);
    final ncMg =
        _numOrNull(widget.corretivos['ncMg']) ?? _numOrNull(albrecht['ncMg']);
    final ncK =
        _numOrNull(widget.corretivos['ncK']) ?? _numOrNull(albrecht['ncK']);

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _LabeledInput(
                label: 'NC Ca',
                placeholder: '1,5',
                value: ncCa,
                onChanged: (value) =>
                    _updateCorretivoValue('ncCa', _numInput(value)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _LabeledInput(
                label: 'NC Mg',
                placeholder: '0,7',
                value: ncMg,
                onChanged: (value) =>
                    _updateCorretivoValue('ncMg', _numInput(value)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _LabeledInput(
                label: 'NC K',
                placeholder: '0,08',
                value: ncK,
                onChanged: (value) =>
                    _updateCorretivoValue('ncK', _numInput(value)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Valores mínimos no solo (cmolc/dm³)',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecond),
        ),
      ],
    );
  }

  Widget _buildSomaV({
    required double? ca,
    required double? mg,
    required double? k,
  }) {
    final caValue = ca ?? 0;
    final mgValue = mg ?? 0;
    final kValue = k ?? 0;
    final soma = caValue + mgValue + kValue;
    final temValor = caValue > 0 || mgValue > 0 || kValue > 0;
    if (!temValor) return const SizedBox.shrink();

    final color = soma >= 60 && soma <= 85
        ? const Color(0xFF34C759)
        : const Color(0xFFFF9500);
    final somaText = _fmt(soma, decimals: 0);
    return Text(
      'Soma: $somaText% → V% esperado: $somaText%',
      style: AppTextStyles.caption.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _updateCorretivoValue(String key, dynamic value) {
    final atualizado = {...widget.corretivos, key: value};

    if (key == 'caDesejadoPct' ||
        key == 'mgDesejadoPct' ||
        key == 'kDesejadoPct') {
      final albrecht = _asMap(widget.corretivos['albrecht']);
      final albrechtKey = key == 'caDesejadoPct'
          ? 'caAlvo'
          : key == 'mgDesejadoPct'
              ? 'mgAlvo'
              : 'kAlvo';
      atualizado['albrecht'] = {...albrecht, albrechtKey: value};
    } else if (key == 'ncCa' || key == 'ncMg' || key == 'ncK') {
      final albrecht = _asMap(widget.corretivos['albrecht']);
      atualizado['albrecht'] = {...albrecht, key: value};
    }

    widget.onChanged(atualizado);
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
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 36,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF007AFF).withValues(alpha: 0.10)
              : const Color(0xFFE5E5E7),
          border: Border.all(
            color: selected ? const Color(0xFF007AFF) : const Color(0xFFD1D1D6),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? const Color(0xFF007AFF) : const Color(0xFF86868B),
          ),
        ),
      ),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.placeholder,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String placeholder;
  final double? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecond,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        AppInput(
          key: ValueKey('$label-${value ?? placeholder}'),
          initialValue: value == null ? '' : _fmt(value!),
          hint: placeholder,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          maxLength: 7,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
            LengthLimitingTextInputFormatter(7),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ── Constantes ──────────────────────────────────────────────────────────────

const _tiposCalcario = [
  'Dolomítico',
  'Calcítico',
  'Magnesiano',
  'Calcinado',
  'Filler',
  'Personalizado',
];

const _tiposCalagem = [
  'Corretiva',
  'Manutenção PD',
];

const _metodosCalagemCorretiva = [
  '① Saturação por Bases (V%)',
  '② EMBRAPA (fator H+Al)',
  '③ Ca+Mg',
  '④ Supercalagem',
  '⑤ Albrecht',
  '⑥ Albrecht + Y',
  '⑦ Correção Mg',
];

const _metodosCalagemPd = [
  '① Saturação por Bases (V%)',
  '⑤ Albrecht',
  '⑥ Albrecht + Y',
];

const _metodosIncorporacao = [
  'Sem incorporação',
  'Grade leve',
  'Grade pesada',
  'Arado disco',
  'Escarificador',
];

const _tiposGrade = ['22"', '24"', '26"', '28"', '32"'];

const _superficieContato = {
  '100% incorporado total': 1.0,
  '90% incorporado parcial': 0.9,
  '85% superfície com chuva': 0.85,
  '80% superfície PD': 0.8,
};

const _meses = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

const _diasPorMes = {
  'Janeiro': 31,
  'Fevereiro': 28,
  'Março': 31,
  'Abril': 30,
  'Maio': 31,
  'Junho': 30,
  'Julho': 31,
  'Agosto': 31,
  'Setembro': 30,
  'Outubro': 31,
  'Novembro': 30,
  'Dezembro': 31,
};

const _metodosGesso = [
  '① EMBRAPA / Souza et al. (2004) — argila %',
  '② UFLA',
  '③ Vitti',
  '④ Caires',
];

// ── Helpers ─────────────────────────────────────────────────────────────────

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

double? _numInput(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;
  return double.tryParse(text.replaceAll(',', '.'));
}

String _joinSegments(Iterable<String> values) {
  return values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(' · ');
}

String _percentSegment(String label, dynamic value) {
  final number = _numOrNull(value);
  if (number == null) return '';
  return '$label ${_fmt(number, decimals: 0)}%';
}

String _limparPrefixo(String value) {
  return value
      .replaceFirst(RegExp(r'^[①②③④⑤⑥⑦⑧⑨⓪]\s*'), '')
      .replaceFirst(RegExp(r'^\d+\s*[-.)]?\s*'), '')
      .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
      .trim();
}

String? _labelMetodo(dynamic raw) {
  final value = _string(raw);
  if (value.isEmpty) return null;
  switch (value) {
    case 'saturacaoV':
      return 'Sat. V%';
    case 'albrecht':
      return 'Albrecht';
    case 'smp':
      return 'SMP';
    case 'iac':
      return 'IAC';
    default:
      final normalized = _limparPrefixo(value);
      if (normalized.startsWith('Saturação')) return 'Sat. V%';
      if (normalized.startsWith('Albrecht')) return 'Albrecht';
      if (normalized.startsWith('EMBRAPA')) return 'EMBRAPA';
      return normalized.isEmpty ? value : normalized;
  }
}

double? _numOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text.replaceAll(',', '.'));
  }
  return null;
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

double _recalcularPrnt(Map<String, dynamic> calcario) {
  final pn = _num(calcario['pn']);
  final re = _num(calcario['re']);
  return (pn * re) / 100;
}

double _qualidadeCalcario(double prnt) => prnt.clamp(0, 100).toDouble();

double _sugestaoV2(String cultura) {
  switch (cultura.toLowerCase()) {
    case 'algodão':
    case 'algodao':
      return 75;
    case 'milho':
      return 70;
    case 'feijão':
    case 'feijao':
      return 70;
    case 'soja':
    default:
      return 70;
  }
}

double _vImplicito(Map<String, dynamic> albrecht) {
  return _num(albrecht['caAlvo']) +
      _num(albrecht['mgAlvo']) +
      _num(albrecht['kAlvo']);
}

Color _badgeAlbrechtColor(Map<String, dynamic> albrecht) {
  return _vImplicito(albrecht) >= 70 ? AppColors.success : AppColors.warning;
}

double _profundidadeGrade(Map<String, dynamic> corretivos) {
  final diametro = _num(corretivos['diametroGradePol'], fallback: 32);
  final folga = _num(corretivos['folgaMancal'], fallback: 25);
  final raio = diametro * 2.54 / 2;
  final profundidade = raio - (folga / 2);
  return profundidade.clamp(0, 60);
}

double _fatorP(Map<String, dynamic> corretivos) {
  final metodo = _string(corretivos['metodoIncorporacao']);
  final profundidade = metodo.contains('Grade')
      ? _profundidadeGrade(corretivos)
      : _num(corretivos['profundidadeManual'], fallback: 20);
  if (profundidade <= 0) return 0;
  if (profundidade <= 20) return profundidade / 20;
  if (profundidade <= 40) return 1 + ((profundidade - 20) / 20) * 1.03;
  return 2.03 + ((profundidade - 40) / 20) * 0.97;
}
