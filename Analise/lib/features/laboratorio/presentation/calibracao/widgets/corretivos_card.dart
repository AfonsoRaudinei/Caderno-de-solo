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
    final summaryLines = _collapsedSummaryLines();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                CorretivosCard.title,
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
              ..._buildSummaryWidgets(summaryLines),
            ],
          ),
        ),
        _buildChevron(onTap: widget.onToggle),
      ],
    );
  }

  List<String> _collapsedSummaryLines() {
    final calcario1 = _asMap(widget.corretivos['calcario1']);
    final tipoCalagem = _string(widget.corretivos['tipoCalagem']);
    final tipoCalcario = _string(widget.corretivos['tipoCalcario']);
    final metodoCalagem =
        _limparPrefixo(_string(widget.corretivos['metodoCalagem']));
    final metodoIncorp = _string(widget.corretivos['metodoIncorporacao']);
    final mes = _string(widget.corretivos['mesAplicacao']);

    return [
      _joinSegments([
        tipoCalagem,
        tipoCalcario,
        _percentSegment('PRNT', calcario1['prnt']),
      ]),
      _joinSegments([
        _percentSegment('CaO', calcario1['caO']),
        _percentSegment('MgO', calcario1['mgO']),
        _percentSegment('PN', calcario1['pn']),
        _percentSegment('RE', calcario1['re']),
      ]),
      _joinSegments([metodoCalagem, metodoIncorp, mes]),
    ].where((line) => line.isNotEmpty).toList();
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
