import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/presentation/lab/calibracao/calibracao_controller.dart';

class CalibracaoPage extends ConsumerStatefulWidget {
  const CalibracaoPage({super.key});

  @override
  ConsumerState<CalibracaoPage> createState() => _CalibracaoPageState();
}

class _CalibracaoPageState extends ConsumerState<CalibracaoPage> {
  final Map<String, bool> _expandedCards = {
    'corretivos': false,
    'fosforo': false,
    'potassio': false,
    'micros': false,
  };

  final Map<String, bool> _expandedMicros = {};

  static const List<String> _culturas = [
    'Soja',
    'Milho',
    'Feijão',
    'Algodão',
  ];

  static const List<String> _tiposCalcario = [
    'Dolomítico',
    'Calcítico',
    'Magnesiano',
    'Calcinado',
    'Filler',
    'Personalizado',
  ];

  static const List<String> _tiposCalagem = [
    'Corretiva',
    'Manutenção PD',
  ];

  static const List<String> _metodosCalagemCorretiva = [
    '① Saturação por Bases (V%)',
    '② EMBRAPA (fator H+Al)',
    '③ Ca+Mg',
    '④ Supercalagem',
    '⑤ Albrecht',
    '⑥ Albrecht + Y',
    '⑦ Correção Mg',
  ];

  static const List<String> _metodosCalagemPd = [
    '① Saturação por Bases (V%)',
    '⑤ Albrecht',
    '⑥ Albrecht + Y',
  ];

  static const List<String> _metodosIncorporacao = [
    'Sem incorporação',
    'Grade leve',
    'Grade pesada',
    'Arado disco',
    'Escarificador',
  ];

  static const List<String> _tiposGrade = ['22"', '24"', '26"', '28"', '32"'];

  static const Map<String, double> _superficieContato = {
    '100% incorporado total': 1.0,
    '90% incorporado parcial': 0.9,
    '85% superfície com chuva': 0.85,
    '80% superfície PD': 0.8,
  };

  static const List<String> _meses = [
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

  static const Map<String, int> _diasPorMes = {
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

  static const List<String> _metodosGesso = [
    '① EMBRAPA / Souza et al. (2004) — argila %',
    '② UFLA',
    '③ Vitti',
    '④ Caires',
  ];

  static const List<String> _extratores = [
    'Resina IAC',
    'Mehlich-1',
    'Mehlich-3',
  ];

  static const List<String> _referenciasPk = [
    'IAC Bol.100',
    'EMBRAPA Cerrado',
    'UFLA',
    'EMBRAPA Soja',
    'Personalizada',
  ];

  static const List<String> _camadas = [
    '0–20 cm',
    '20–40 cm',
  ];

  static const List<String> _modosPk = [
    '① Correção do solo',
    '② Extração',
  ];

  static const List<String> _tiposExtracao = [
    'Exportação',
    'Extração total',
  ];

  static const List<String> _modoAplicacaoP = [
    'Sulco',
    'Lanço incorporado',
    'Lanço sem incorporação',
    'Fertirrigação',
  ];

  static const List<String> _criteriosK = [
    'Teor absoluto',
    '% K na CTC',
    'Ambos — usar o maior',
  ];

  static const List<String> _modoAplicacaoK = [
    'Lanço incorporado',
    'Lanço sem incorporação',
    'Sulco',
    'Cobertura',
    'Fertirrigação',
  ];

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

  @override
  Widget build(BuildContext context) {
    ref.listen<CalibracaoState>(calibracaoControllerProvider, (previous, next) {
      final messenger = ScaffoldMessenger.of(context);
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(calibracaoControllerProvider.notifier).limparMensagens();
      }
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(calibracaoControllerProvider.notifier).limparMensagens();
      }
    });

    final state = ref.watch(calibracaoControllerProvider);
    final controller = ref.read(calibracaoControllerProvider.notifier);

    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final draft = state.draft;
    final draftKey = '${draft.id}_${draft.createdAt.microsecondsSinceEpoch}';
    final corretivos = _asMap(draft.parametrosCards['corretivos']);
    final fosforo = _asMap(draft.parametrosCards['fosforo']);
    final potassio = _asMap(draft.parametrosCards['potassio']);
    final micros = _asMap(draft.parametrosCards['micros']);
    final elementos = _asMap(micros['elementos']);
    final grupos = _asListMap(micros['grupos']);
    for (final simbolo in _elementosMicros) {
      _expandedMicros.putIfAbsent(simbolo, () => false);
    }

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          AppCardSection(
            title: 'Cabeçalho da Calibração',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppDropdown<String>(
                        label: 'Perfis salvos',
                        value: state.selectedProfileId,
                        hint: 'Selecione um perfil',
                        items: state.profiles
                            .map(
                              (profile) => AppDropdownItem<String>(
                                value: profile.id,
                                label: profile.nome.isEmpty
                                    ? 'Sem nome (${DateFormat('dd/MM/yyyy HH:mm').format(profile.updatedAt)})'
                                    : profile.nome,
                              ),
                            )
                            .toList(),
                        onChanged: controller.selecionarPerfil,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: controller.novo,
                        icon: const Icon(Icons.add),
                        label: const Text('+ Novo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ActionChip(
                      label: 'Salvar',
                      icon: Icons.save_outlined,
                      loading: state.saving,
                      onTap: () => controller.salvar(),
                    ),
                    _ActionChip(
                      label: 'Salvar como novo',
                      icon: Icons.copy_outlined,
                      onTap: () => controller.salvar(salvarComoNovo: true),
                    ),
                    _ActionChip(
                      label: 'Duplicar',
                      icon: Icons.control_point_duplicate_outlined,
                      onTap: controller.duplicarSelecionado,
                    ),
                    _ActionChip(
                      label: 'Excluir',
                      icon: Icons.delete_outline_rounded,
                      destructive: true,
                      onTap: _confirmarExclusao,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppInput(
                  key: ValueKey('nome-$draftKey'),
                  label: 'Nome',
                  initialValue: draft.nome,
                  onChanged: controller.atualizarNome,
                ),
                const SizedBox(height: 12),
                AppDropdown<String>(
                  label: 'Cultura',
                  value:
                      _culturas.contains(draft.cultura) ? draft.cultura : null,
                  hint: 'Selecione',
                  items: _culturas
                      .map((cultura) =>
                          AppDropdownItem(value: cultura, label: cultura))
                      .toList(),
                  onChanged: controller.atualizarCultura,
                ),
                const SizedBox(height: 12),
                AppInput(
                  key: ValueKey('safra-$draftKey'),
                  label: 'Safra',
                  hint: 'Ex.: 2026/2027',
                  initialValue: draft.safra,
                  onChanged: controller.atualizarSafra,
                ),
                const SizedBox(height: 12),
                AppInput(
                  key: ValueKey('cliente-$draftKey'),
                  label: 'Cliente',
                  initialValue: draft.cliente,
                  onChanged: controller.atualizarCliente,
                ),
                const SizedBox(height: 12),
                AppInput(
                  key: ValueKey('fazenda-$draftKey'),
                  label: 'Fazenda',
                  initialValue: draft.fazenda,
                  onChanged: controller.atualizarFazenda,
                ),
                const SizedBox(height: 12),
                AppInput(
                  key: ValueKey('talhao-$draftKey'),
                  label: 'Talhão',
                  initialValue: draft.talhao,
                  onChanged: controller.atualizarTalhao,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _CollapsibleCard(
            title: 'Card 1 — Corretivos (Calcário + Gesso)',
            icon: Icons.terrain_rounded,
            expanded: _expandedCards['corretivos'] ?? false,
            onToggle: () => setState(
              () => _expandedCards['corretivos'] =
                  !(_expandedCards['corretivos'] ?? false),
            ),
            child: _buildCorretivosCard(
              draft: draft,
              draftKey: draftKey,
              corretivos: corretivos,
              onChanged: (map) => controller.atualizarParametrosCorretivos(map),
            ),
          ),
          const SizedBox(height: 12),
          _CollapsibleCard(
            title: 'Card 2 — Fósforo',
            icon: Icons.science_outlined,
            expanded: _expandedCards['fosforo'] ?? false,
            onToggle: () => setState(
              () => _expandedCards['fosforo'] =
                  !(_expandedCards['fosforo'] ?? false),
            ),
            child: _buildFosforoCard(
              draft: draft,
              draftKey: draftKey,
              fosforo: fosforo,
              onChanged: (map) => controller.atualizarParametrosFosforo(map),
            ),
          ),
          const SizedBox(height: 12),
          _CollapsibleCard(
            title: 'Card 3 — Potássio',
            icon: Icons.bolt_outlined,
            expanded: _expandedCards['potassio'] ?? false,
            onToggle: () => setState(
              () => _expandedCards['potassio'] =
                  !(_expandedCards['potassio'] ?? false),
            ),
            child: _buildPotassioCard(
              draft: draft,
              draftKey: draftKey,
              potassio: potassio,
              onChanged: (map) => controller.atualizarParametrosPotassio(map),
            ),
          ),
          const SizedBox(height: 12),
          _CollapsibleCard(
            title: 'Card 4 — Micronutrientes',
            icon: Icons.biotech_outlined,
            expanded: _expandedCards['micros'] ?? false,
            onToggle: () => setState(
              () => _expandedCards['micros'] =
                  !(_expandedCards['micros'] ?? false),
            ),
            child: _buildMicrosCard(
              draftKey: draftKey,
              micros: micros,
              elementos: elementos,
              grupos: grupos,
              onChanged: (map) => controller.atualizarParametrosMicros(map),
            ),
          ),
          const SizedBox(height: 16),
          AppCardSection(
            title: 'Rodapé',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Salvar Calibração',
                        icon: Icons.save_rounded,
                        isLoading: state.saving,
                        onPressed: () => controller.salvar(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButtonSecondary(
                        label: 'Duplicar',
                        icon: Icons.copy_rounded,
                        onPressed: controller.duplicarSelecionado,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Última atualização: ${DateFormat('dd/MM/yyyy HH:mm').format(draft.updatedAt)}',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorretivosCard({
    required CalibracaoProfile draft,
    required String draftKey,
    required Map<String, dynamic> corretivos,
    required ValueChanged<Map<String, dynamic>> onChanged,
  }) {
    final tipoCalagem =
        _string(corretivos['tipoCalagem'], fallback: _tiposCalagem.first);
    final metodos = tipoCalagem == 'Manutenção PD'
        ? _metodosCalagemPd
        : _metodosCalagemCorretiva;
    var metodoCalagem =
        _string(corretivos['metodoCalagem'], fallback: metodos.first);
    if (!metodos.contains(metodoCalagem)) {
      metodoCalagem = metodos.first;
    }

    final calcario1 = _asMap(corretivos['calcario1']);
    final calcario2 = _asMap(corretivos['calcario2']);
    final usarSegundoCalcario = _bool(corretivos['usarSegundoCalcario']);
    final proporcao1 = _num(corretivos['proporcaoCalcario1'], fallback: 50);
    final proporcao2 = (100 - proporcao1).clamp(0, 100).toDouble();
    final prnt1 = _num(calcario1['prnt']);
    final prnt2 = _num(calcario2['prnt']);
    final prntPonderado = usarSegundoCalcario
        ? ((prnt1 * proporcao1) + (prnt2 * proporcao2)) / 100
        : prnt1;

    final albrecht = _asMap(corretivos['albrecht']);
    final metodoIncorp = _string(corretivos['metodoIncorporacao'],
        fallback: _metodosIncorporacao.first);
    final scAtual = _num(corretivos['sc'], fallback: 1.0);
    final scLabel = _superficieContato.entries
        .firstWhere(
          (entry) => (entry.value - scAtual).abs() < 0.001,
          orElse: () => _superficieContato.entries.first,
        )
        .key;
    final mes = _string(corretivos['mesAplicacao'], fallback: _meses.first);

    final gesso = _asMap(corretivos['gesso']);
    final usarGesso = _bool(gesso['usarGesso']);

    final qualidade = _qualidadeCalcario(prnt1);
    final scoreBars = (qualidade / 20).clamp(0, 5).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SubSectionTitle('Tipo de calagem'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: _tiposCalagem
              .map(
                (tipo) => ChoiceChip(
                  label: Text(tipo),
                  selected: tipoCalagem == tipo,
                  onSelected: (_) {
                    final atualizado = {...corretivos};
                    atualizado['tipoCalagem'] = tipo;
                    if (tipo == 'Manutenção PD' &&
                        !_metodosCalagemPd
                            .contains(atualizado['metodoCalagem'])) {
                      atualizado['metodoCalagem'] = _metodosCalagemPd.first;
                    }
                    onChanged(atualizado);
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 14),
        const _SubSectionTitle('Calcário'),
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: 'Tipo de calcário',
          value: _safeValue(
              _tiposCalcario,
              _string(corretivos['tipoCalcario'],
                  fallback: _tiposCalcario.first)),
          items: _tiposCalcario
              .map((tipo) => AppDropdownItem(value: tipo, label: tipo))
              .toList(),
          onChanged: (value) {
            final atualizado = {...corretivos};
            atualizado['tipoCalcario'] = value ?? _tiposCalcario.first;
            onChanged(atualizado);
          },
        ),
        const SizedBox(height: 10),
        _buildNumericPair(
          left: _buildNumericInput(
            keyValue: '$draftKey-c1-cao',
            label: 'CaO (%)',
            value: _num(calcario1['caO']),
            onChanged: (value) {
              final atualizado = {...corretivos};
              final c1 = {...calcario1, 'caO': value};
              atualizado['calcario1'] = c1;
              onChanged(atualizado);
            },
          ),
          right: _buildNumericInput(
            keyValue: '$draftKey-c1-mgo',
            label: 'MgO (%)',
            value: _num(calcario1['mgO']),
            onChanged: (value) {
              final atualizado = {...corretivos};
              final c1 = {...calcario1, 'mgO': value};
              atualizado['calcario1'] = c1;
              onChanged(atualizado);
            },
          ),
        ),
        const SizedBox(height: 8),
        _buildNumericPair(
          left: _buildNumericInput(
            keyValue: '$draftKey-c1-pn',
            label: 'PN (%)',
            value: _num(calcario1['pn']),
            onChanged: (value) {
              final atualizado = {...corretivos};
              final c1 = {...calcario1, 'pn': value};
              c1['prnt'] = _recalcularPrnt(c1);
              atualizado['calcario1'] = c1;
              onChanged(atualizado);
            },
          ),
          right: _buildNumericInput(
            keyValue: '$draftKey-c1-re',
            label: 'RE (%)',
            value: _num(calcario1['re']),
            onChanged: (value) {
              final atualizado = {...corretivos};
              final c1 = {...calcario1, 're': value};
              c1['prnt'] = _recalcularPrnt(c1);
              atualizado['calcario1'] = c1;
              onChanged(atualizado);
            },
          ),
        ),
        const SizedBox(height: 8),
        _buildNumericInput(
          keyValue: '$draftKey-c1-prnt',
          label: 'PRNT (%)',
          value: _num(calcario1['prnt']),
          onChanged: (value) {
            final atualizado = {...corretivos};
            atualizado['calcario1'] = {...calcario1, 'prnt': value};
            onChanged(atualizado);
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
                ? '✅ Qualidade alta para aplicação com resposta rápida.'
                : qualidade >= 60
                    ? 'ℹ️ Qualidade intermediária: atenção ao período de aplicação.'
                    : '⚠️ Qualidade baixa: considerar ajuste de fonte/época.',
            style: AppTextStyles.caption,
          ),
        ),
        const SizedBox(height: 10),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Usar 2º calcário?'),
          value: usarSegundoCalcario,
          onChanged: (value) {
            final atualizado = {...corretivos, 'usarSegundoCalcario': value};
            onChanged(atualizado);
          },
        ),
        if (usarSegundoCalcario) ...[
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '$draftKey-c2-cao',
              label: 'CaO 2º (%)',
              value: _num(calcario2['caO']),
              onChanged: (value) {
                final atualizado = {...corretivos};
                atualizado['calcario2'] = {...calcario2, 'caO': value};
                onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-c2-mgo',
              label: 'MgO 2º (%)',
              value: _num(calcario2['mgO']),
              onChanged: (value) {
                final atualizado = {...corretivos};
                atualizado['calcario2'] = {...calcario2, 'mgO': value};
                onChanged(atualizado);
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '$draftKey-c2-pn',
              label: 'PN 2º (%)',
              value: _num(calcario2['pn']),
              onChanged: (value) {
                final atualizado = {...corretivos};
                final c2 = {...calcario2, 'pn': value};
                c2['prnt'] = _recalcularPrnt(c2);
                atualizado['calcario2'] = c2;
                onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-c2-re',
              label: 'RE 2º (%)',
              value: _num(calcario2['re']),
              onChanged: (value) {
                final atualizado = {...corretivos};
                final c2 = {...calcario2, 're': value};
                c2['prnt'] = _recalcularPrnt(c2);
                atualizado['calcario2'] = c2;
                onChanged(atualizado);
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '$draftKey-c2-prnt',
              label: 'PRNT 2º (%)',
              value: _num(calcario2['prnt']),
              onChanged: (value) {
                final atualizado = {...corretivos};
                atualizado['calcario2'] = {...calcario2, 'prnt': value};
                onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-c2-prop',
              label: 'Proporção 1º (%)',
              value: proporcao1,
              onChanged: (value) {
                final atualizado = {
                  ...corretivos,
                  'proporcaoCalcario1': value.clamp(0, 100)
                };
                onChanged(atualizado);
              },
            ),
          ),
          const SizedBox(height: 6),
          _Badge(
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
              ...corretivos,
              'metodoCalagem': value ?? metodos.first
            };
            onChanged(atualizado);
          },
        ),
        const SizedBox(height: 10),
        if (metodoCalagem.startsWith('①'))
          _buildNumericInput(
            keyValue: '$draftKey-v2',
            label: 'V₂ desejado (%)',
            value: _num(corretivos['v2'], fallback: _sugestaoV2(draft.cultura)),
            onChanged: (value) {
              final atualizado = {...corretivos, 'v2': value};
              onChanged(atualizado);
            },
          ),
        if (metodoCalagem.startsWith('②'))
          _buildNumericInput(
            keyValue: '$draftKey-hal',
            label: 'Fator H+Al',
            value: _num(corretivos['fatorHAl'], fallback: 0.5),
            onChanged: (value) {
              final atualizado = {...corretivos, 'fatorHAl': value};
              onChanged(atualizado);
            },
          ),
        if (metodoCalagem.startsWith('④'))
          _buildNumericInput(
            keyValue: '$draftKey-dose-fixa',
            label: 'Dose fixa (t/ha)',
            value: _num(corretivos['doseFixa'], fallback: 1.0),
            onChanged: (value) {
              final atualizado = {...corretivos, 'doseFixa': value};
              onChanged(atualizado);
            },
          ),
        if (metodoCalagem.startsWith('⑦'))
          _buildNumericInput(
            keyValue: '$draftKey-mg-alvo',
            label: 'Mg desejado (cmolc/dm³)',
            value: _num(corretivos['mgDesejado'], fallback: 0.8),
            onChanged: (value) {
              final atualizado = {...corretivos, 'mgDesejado': value};
              onChanged(atualizado);
            },
          ),
        if (metodoCalagem.startsWith('⑤') || metodoCalagem.startsWith('⑥')) ...[
          const SizedBox(height: 14),
          const _SubSectionTitle('Bloco Albrecht'),
          const SizedBox(height: 8),
          _Badge(
            icon: Icons.grass_outlined,
            color: AppColors.primary,
            label: 'Cultura: ${draft.cultura}',
          ),
          const SizedBox(height: 8),
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '$draftKey-alb-ca',
              label: 'Ca alvo (%)',
              value: _num(albrecht['caAlvo'], fallback: 65),
              onChanged: (value) {
                final atualizado = {...corretivos};
                atualizado['albrecht'] = {...albrecht, 'caAlvo': value};
                onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-alb-ca-nc',
              label: 'NC Ca mín',
              value: _num(albrecht['ncCa'], fallback: 2.0),
              onChanged: (value) {
                final atualizado = {...corretivos};
                atualizado['albrecht'] = {...albrecht, 'ncCa': value};
                onChanged(atualizado);
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '$draftKey-alb-mg',
              label: 'Mg alvo (%)',
              value: _num(albrecht['mgAlvo'], fallback: 15),
              onChanged: (value) {
                final atualizado = {...corretivos};
                atualizado['albrecht'] = {...albrecht, 'mgAlvo': value};
                onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-alb-mg-nc',
              label: 'NC Mg mín',
              value: _num(albrecht['ncMg'], fallback: 0.8),
              onChanged: (value) {
                final atualizado = {...corretivos};
                atualizado['albrecht'] = {...albrecht, 'ncMg': value};
                onChanged(atualizado);
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '$draftKey-alb-k',
              label: 'K alvo (%)',
              value: _num(albrecht['kAlvo'], fallback: 4),
              onChanged: (value) {
                final atualizado = {...corretivos};
                atualizado['albrecht'] = {...albrecht, 'kAlvo': value};
                onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-alb-k-nc',
              label: 'NC K mín',
              value: _num(albrecht['ncK'], fallback: 0.15),
              onChanged: (value) {
                final atualizado = {...corretivos};
                atualizado['albrecht'] = {...albrecht, 'ncK': value};
                onChanged(atualizado);
              },
            ),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Na (usar meta)'),
            value: _bool(albrecht['incluirNa']),
            onChanged: (value) {
              final atualizado = {...corretivos};
              atualizado['albrecht'] = {...albrecht, 'incluirNa': value};
              onChanged(atualizado);
            },
          ),
          const SizedBox(height: 6),
          _Badge(
            icon: Icons.verified_outlined,
            color: _badgeAlbrechtColor(albrecht),
            label:
                'V% implícito: ${_fmt(_vImplicito(albrecht), decimals: 1)}% — ${_vImplicito(albrecht) >= 70 ? '✅ Adequado' : '⚠️ Fora da faixa'}',
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
            _Badge(
              icon: Icons.shield_outlined,
              color: AppColors.primaryDark,
              label:
                  'Painel Y: NC Albrecht ${_fmt(_num(corretivos['doseFixa'], fallback: 1.2), decimals: 2)} t/ha · Y do solo ${_fmt(_num(corretivos['doseFixa'], fallback: 1.2), decimals: 2)} t/ha',
            ),
          ],
        ],
        const SizedBox(height: 14),
        const _SubSectionTitle('Incorporação'),
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: 'Método de incorporação',
          value: _safeValue(_metodosIncorporacao, metodoIncorp),
          items: _metodosIncorporacao
              .map((metodo) => AppDropdownItem(value: metodo, label: metodo))
              .toList(),
          onChanged: (value) {
            final atualizado = {
              ...corretivos,
              'metodoIncorporacao': value ?? _metodosIncorporacao.first
            };
            onChanged(atualizado);
          },
        ),
        const SizedBox(height: 8),
        if (metodoIncorp.contains('Grade')) ...[
          _buildNumericPair(
            left: AppDropdown<String>(
              label: 'Tipo de grade',
              value: _safeValue(_tiposGrade,
                  '${_num(corretivos['diametroGradePol'], fallback: 32).round()}"'),
              items: _tiposGrade
                  .map((tipo) => AppDropdownItem(value: tipo, label: tipo))
                  .toList(),
              onChanged: (value) {
                final atualizado = {...corretivos};
                atualizado['diametroGradePol'] =
                    _parseDouble(value?.replaceAll('"', '') ?? '32');
                onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-folga',
              label: 'Folga mancal (cm)',
              value: _num(corretivos['folgaMancal'], fallback: 25),
              onChanged: (value) {
                final atualizado = {...corretivos, 'folgaMancal': value};
                onChanged(atualizado);
              },
            ),
          ),
          const SizedBox(height: 8),
          _Badge(
            icon: Icons.straighten_outlined,
            color: AppColors.primary,
            label:
                'Profundidade estimada: ${_fmt(_profundidadeGrade(corretivos), decimals: 1)} cm · Fator p: ${_fmt(_fatorP(corretivos), decimals: 2)}',
          ),
        ] else ...[
          _buildNumericInput(
            keyValue: '$draftKey-profundidade',
            label: 'Profundidade (cm)',
            value: _num(corretivos['profundidadeManual'], fallback: 20),
            onChanged: (value) {
              final atualizado = {...corretivos, 'profundidadeManual': value};
              onChanged(atualizado);
            },
          ),
          const SizedBox(height: 8),
          _Badge(
            icon: Icons.straighten_outlined,
            color: AppColors.primary,
            label: 'Fator p: ${_fmt(_fatorP(corretivos), decimals: 2)}',
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
              ...corretivos,
              'sc': _superficieContato[value] ?? 1.0
            };
            onChanged(atualizado);
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
              ...corretivos,
              'mesAplicacao': value ?? _meses.first
            };
            onChanged(atualizado);
          },
        ),
        const SizedBox(height: 6),
        _Badge(
          icon: Icons.calendar_month_outlined,
          color: AppColors.warning,
          label: 'Dias disponíveis: ${_diasPorMes[mes] ?? 30} dias',
        ),
        const SizedBox(height: 14),
        const _SubSectionTitle('Gesso'),
        const SizedBox(height: 8),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Vai usar gesso?'),
          value: usarGesso,
          onChanged: (value) {
            final atualizado = {...corretivos};
            atualizado['gesso'] = {...gesso, 'usarGesso': value};
            onChanged(atualizado);
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
              final atualizado = {...corretivos};
              atualizado['gesso'] = {
                ...gesso,
                'metodo': value ?? _metodosGesso.first
              };
              onChanged(atualizado);
            },
          ),
          const SizedBox(height: 8),
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '$draftKey-gesso-ca',
              label: 'Teor Ca (%)',
              value: _num(gesso['teorCa'], fallback: 20),
              onChanged: (value) {
                final atualizado = {...corretivos};
                atualizado['gesso'] = {...gesso, 'teorCa': value};
                onChanged(atualizado);
              },
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-gesso-s',
              label: 'Teor S (%)',
              value: _num(gesso['teorS'], fallback: 15),
              onChanged: (value) {
                final atualizado = {...corretivos};
                atualizado['gesso'] = {...gesso, 'teorS': value};
                onChanged(atualizado);
              },
            ),
          ),
          const SizedBox(height: 8),
          const _Badge(
            icon: Icons.auto_awesome_outlined,
            color: AppColors.warning,
            label:
                'Dados de subsolo virão da Análise · diagnóstico: 🟡 indicado',
          ),
        ],
      ],
    );
  }

  Widget _buildFosforoCard({
    required CalibracaoProfile draft,
    required String draftKey,
    required Map<String, dynamic> fosforo,
    required ValueChanged<Map<String, dynamic>> onChanged,
  }) {
    final modo = _string(fosforo['modoCalculo'], fallback: _modosPk.first);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropdown<String>(
          label: 'Extrator',
          value: _safeValue(_extratores,
              _string(fosforo['extrator'], fallback: _extratores.first)),
          items: _extratores
              .map((item) => AppDropdownItem(value: item, label: item))
              .toList(),
          onChanged: (value) =>
              onChanged({...fosforo, 'extrator': value ?? _extratores.first}),
        ),
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: 'Referência',
          value: _safeValue(_referenciasPk,
              _string(fosforo['referencia'], fallback: _referenciasPk.first)),
          items: _referenciasPk
              .map((item) => AppDropdownItem(value: item, label: item))
              .toList(),
          onChanged: (value) => onChanged(
              {...fosforo, 'referencia': value ?? _referenciasPk.first}),
        ),
        const SizedBox(height: 8),
        _buildNumericPair(
          left: _buildNumericInput(
            keyValue: '$draftKey-p-nc',
            label: 'NC (mg/dm³)',
            value: _num(fosforo['nc'], fallback: 20),
            onChanged: (value) => onChanged({...fosforo, 'nc': value}),
          ),
          right: AppDropdown<String>(
            label: 'Camada',
            value: _safeValue(
                _camadas, _string(fosforo['camada'], fallback: _camadas.first)),
            items: _camadas
                .map((item) => AppDropdownItem(value: item, label: item))
                .toList(),
            onChanged: (value) =>
                onChanged({...fosforo, 'camada': value ?? _camadas.first}),
          ),
        ),
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: 'Modo de cálculo',
          value: _safeValue(_modosPk, modo),
          items: _modosPk
              .map((item) => AppDropdownItem(value: item, label: item))
              .toList(),
          onChanged: (value) =>
              onChanged({...fosforo, 'modoCalculo': value ?? _modosPk.first}),
        ),
        const SizedBox(height: 8),
        if (modo.startsWith('①')) ...[
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '$draftKey-p-pct',
              label: '% correção por ciclo',
              value: _num(fosforo['percentualCorrecao'], fallback: 100),
              onChanged: (value) =>
                  onChanged({...fosforo, 'percentualCorrecao': value}),
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-p-fator-solo',
              label: 'Fator solo',
              value: _num(fosforo['fatorSolo'], fallback: 4),
              onChanged: (value) => onChanged({...fosforo, 'fatorSolo': value}),
            ),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Cultivar: ${_string(fosforo['cultivar'], fallback: draft.cultura)}',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.culturas),
                        child: const Text('Culturas'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildNumericPair(
            left: AppDropdown<String>(
              label: 'Tipo',
              value: _safeValue(
                _tiposExtracao,
                _string(fosforo['tipoDadoCultivar'],
                    fallback: _tiposExtracao.first),
              ),
              items: _tiposExtracao
                  .map((item) => AppDropdownItem(value: item, label: item))
                  .toList(),
              onChanged: (value) => onChanged({
                ...fosforo,
                'tipoDadoCultivar': value ?? _tiposExtracao.first
              }),
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-p-uso',
              label: '% P do solo que vai usar',
              value: _num(fosforo['percentualUsoPSolo'], fallback: 0),
              onChanged: (value) =>
                  onChanged({...fosforo, 'percentualUsoPSolo': value}),
            ),
          ),
        ],
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: 'Modo de aplicação',
          value: _safeValue(
              _modoAplicacaoP,
              _string(fosforo['modoAplicacao'],
                  fallback: _modoAplicacaoP.first)),
          items: _modoAplicacaoP
              .map((item) => AppDropdownItem(value: item, label: item))
              .toList(),
          onChanged: (value) => onChanged(
              {...fosforo, 'modoAplicacao': value ?? _modoAplicacaoP.first}),
        ),
        const SizedBox(height: 8),
        _buildNumericInput(
          keyValue: '$draftKey-p-fep',
          label: 'FEP (%)',
          value: _num(fosforo['fepBase'], fallback: 15),
          onChanged: (value) => onChanged({...fosforo, 'fepBase': value}),
        ),
      ],
    );
  }

  Widget _buildPotassioCard({
    required CalibracaoProfile draft,
    required String draftKey,
    required Map<String, dynamic> potassio,
    required ValueChanged<Map<String, dynamic>> onChanged,
  }) {
    final modo = _string(potassio['modoCalculo'], fallback: _modosPk.first);
    final criterio =
        _string(potassio['criterioNc'], fallback: _criteriosK.first);
    final culturaAlgodao = draft.cultura.toLowerCase() == 'algodão' ||
        draft.cultura.toLowerCase() == 'algodao';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropdown<String>(
          label: 'Extrator',
          value: _safeValue(_extratores,
              _string(potassio['extrator'], fallback: _extratores.first)),
          items: _extratores
              .map((item) => AppDropdownItem(value: item, label: item))
              .toList(),
          onChanged: (value) =>
              onChanged({...potassio, 'extrator': value ?? _extratores.first}),
        ),
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: 'Referência',
          value: _safeValue(_referenciasPk,
              _string(potassio['referencia'], fallback: _referenciasPk.first)),
          items: _referenciasPk
              .map((item) => AppDropdownItem(value: item, label: item))
              .toList(),
          onChanged: (value) => onChanged(
              {...potassio, 'referencia': value ?? _referenciasPk.first}),
        ),
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: 'Critério NC',
          value: _safeValue(_criteriosK, criterio),
          items: _criteriosK
              .map((item) => AppDropdownItem(value: item, label: item))
              .toList(),
          onChanged: (value) => onChanged(
              {...potassio, 'criterioNc': value ?? _criteriosK.first}),
        ),
        const SizedBox(height: 8),
        if (criterio == 'Teor absoluto')
          _buildNumericInput(
            keyValue: '$draftKey-k-nc-teor',
            label: 'NC (mg/dm³)',
            value: _num(potassio['ncTeor'], fallback: 80),
            onChanged: (value) => onChanged({...potassio, 'ncTeor': value}),
          ),
        if (criterio == '% K na CTC')
          _buildNumericInput(
            keyValue: '$draftKey-k-nc-ctc',
            label: 'NC (% K CTC)',
            value: _num(potassio['ncPctCtc'], fallback: culturaAlgodao ? 5 : 4),
            onChanged: (value) => onChanged({...potassio, 'ncPctCtc': value}),
          ),
        if (criterio == 'Ambos — usar o maior') ...[
          _buildNumericPair(
            left: _buildNumericInput(
              keyValue: '$draftKey-k-nc-teor-ambos',
              label: 'NC teor',
              value: _num(potassio['ncTeor'], fallback: 80),
              onChanged: (value) => onChanged({...potassio, 'ncTeor': value}),
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-k-nc-ctc-ambos',
              label: 'NC % CTC',
              value:
                  _num(potassio['ncPctCtc'], fallback: culturaAlgodao ? 5 : 4),
              onChanged: (value) => onChanged({...potassio, 'ncPctCtc': value}),
            ),
          ),
        ],
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: 'Camada',
          value: _safeValue(
              _camadas, _string(potassio['camada'], fallback: _camadas.first)),
          items: _camadas
              .map((item) => AppDropdownItem(value: item, label: item))
              .toList(),
          onChanged: (value) =>
              onChanged({...potassio, 'camada': value ?? _camadas.first}),
        ),
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: 'Modo de cálculo',
          value: _safeValue(_modosPk, modo),
          items: _modosPk
              .map((item) => AppDropdownItem(value: item, label: item))
              .toList(),
          onChanged: (value) =>
              onChanged({...potassio, 'modoCalculo': value ?? _modosPk.first}),
        ),
        const SizedBox(height: 8),
        if (modo.startsWith('①'))
          _buildNumericInput(
            keyValue: '$draftKey-k-pct',
            label: '% correção por ciclo',
            value: _num(potassio['percentualCorrecao'], fallback: 100),
            onChanged: (value) =>
                onChanged({...potassio, 'percentualCorrecao': value}),
          ),
        if (modo.startsWith('②')) ...[
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Cultivar: ${_string(potassio['cultivar'], fallback: draft.cultura)}',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.culturas),
                        child: const Text('Culturas'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildNumericPair(
            left: AppDropdown<String>(
              label: 'Tipo',
              value: _safeValue(
                _tiposExtracao,
                _string(potassio['tipoDadoCultivar'],
                    fallback: _tiposExtracao.first),
              ),
              items: _tiposExtracao
                  .map((item) => AppDropdownItem(value: item, label: item))
                  .toList(),
              onChanged: (value) => onChanged({
                ...potassio,
                'tipoDadoCultivar': value ?? _tiposExtracao.first
              }),
            ),
            right: _buildNumericInput(
              keyValue: '$draftKey-k-uso',
              label: '% K do solo que vai usar',
              value: _num(potassio['percentualUsoKSolo'], fallback: 0),
              onChanged: (value) =>
                  onChanged({...potassio, 'percentualUsoKSolo': value}),
            ),
          ),
        ],
        const SizedBox(height: 8),
        AppDropdown<String>(
          label: 'Modo de aplicação',
          value: _safeValue(
              _modoAplicacaoK,
              _string(potassio['modoAplicacao'],
                  fallback: _modoAplicacaoK.first)),
          items: _modoAplicacaoK
              .map((item) => AppDropdownItem(value: item, label: item))
              .toList(),
          onChanged: (value) => onChanged(
              {...potassio, 'modoAplicacao': value ?? _modoAplicacaoK.first}),
        ),
        const SizedBox(height: 8),
        _buildNumericInput(
          keyValue: '$draftKey-k-fek',
          label: 'FEK (%)',
          value: _num(potassio['fekBase'], fallback: culturaAlgodao ? 60 : 65),
          onChanged: (value) => onChanged({...potassio, 'fekBase': value}),
        ),
        if (culturaAlgodao) ...[
          const SizedBox(height: 8),
          const _Badge(
            icon: Icons.warning_amber_rounded,
            color: AppColors.warning,
            label: 'Algodão: NC ajustado para 5% CTC, FEK 60%',
          ),
        ],
      ],
    );
  }

  Widget _buildMicrosCard({
    required String draftKey,
    required Map<String, dynamic> micros,
    required Map<String, dynamic> elementos,
    required List<Map<String, dynamic>> grupos,
    required ValueChanged<Map<String, dynamic>> onChanged,
  }) {
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
        ..._elementosMicros.map((simbolo) {
          final elemento = _asMap(elementos[simbolo]);
          final aberto = _expandedMicros[simbolo] ?? false;
          final classe = _classeMicro(elemento);
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
                          AppDropdown<String>(
                            label: 'Referência',
                            value: _string(elemento['referencia'],
                                fallback:
                                    '06 — Micronutrientes: Motor de Cálculo'),
                            items: const [
                              AppDropdownItem(
                                value: '06 — Micronutrientes: Motor de Cálculo',
                                label: '06 — Micronutrientes: Motor de Cálculo',
                              ),
                              AppDropdownItem(
                                  value: 'EMBRAPA Soja', label: 'EMBRAPA Soja'),
                              AppDropdownItem(
                                  value: 'Personalizada',
                                  label: 'Personalizada'),
                            ],
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
                          ),
                          const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        const _SubSectionTitle('Grupos de Aplicação'),
        const SizedBox(height: 8),
        if (grupos.isEmpty)
          const _Badge(
            icon: Icons.info_outline,
            color: AppColors.textSecond,
            label: 'Nenhum grupo criado.',
          ),
        ...grupos.asMap().entries.map((entry) {
          final index = entry.key;
          final grupo = entry.value;
          final nome = grupo['nome']?.toString() ?? 'Grupo ${index + 1}';
          final via = grupo['via']?.toString() ?? _viasGrupo.first;
          final elementosGrupo = List<String>.from(
              (grupo['elementos'] as List?)?.map((e) => e.toString()) ??
                  const []);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.bgSecondary,
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Column(
                children: [
                  AppInput(
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
                  const SizedBox(height: 8),
                  AppDropdown<String>(
                    label: 'Via',
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Elementos', style: AppTextStyles.label),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _elementosMicros
                        .map(
                          (simbolo) => FilterChip(
                            label: Text(simbolo),
                            selected: elementosGrupo.contains(simbolo),
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
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  AppInput(
                    key: ValueKey('$draftKey-grupo-produto-$index'),
                    label: 'Fonte/produto',
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
                  const SizedBox(height: 8),
                  _buildNumericInput(
                    keyValue: '$draftKey-grupo-ef-$index',
                    label: 'Eficiência grupo (%)',
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

  Future<void> _confirmarExclusao() async {
    final controller = ref.read(calibracaoControllerProvider.notifier);
    final state = ref.read(calibracaoControllerProvider);
    if (state.selectedProfileId == null) {
      await controller.excluirSelecionado();
      return;
    }
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir calibração'),
          content: const Text('Deseja realmente excluir o perfil selecionado?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
    if (confirmar == true) {
      await controller.excluirSelecionado();
    }
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

  List<Map<String, dynamic>> _asListMap(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
              (entry) => entry.map((key, val) => MapEntry(key.toString(), val)))
          .toList();
    }
    return <Map<String, dynamic>>[];
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

class _CollapsibleCard extends StatelessWidget {
  const _CollapsibleCard({
    required this.title,
    required this.icon,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final IconData icon;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(title, style: AppTextStyles.label)),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (expanded)
            const Divider(
              height: 1,
              thickness: 0.5,
              color: AppColors.borderSoft,
            ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.all(14),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _SubSectionTitle extends StatelessWidget {
  const _SubSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.sectionLabel,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.loading = false,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool loading;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: loading
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: destructive ? AppColors.error : AppColors.primary,
              ),
            )
          : Icon(
              icon,
              size: 16,
              color: destructive ? AppColors.error : AppColors.primary,
            ),
      label: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: destructive ? AppColors.error : AppColors.primary,
        ),
      ),
      onPressed: loading ? null : onTap,
      backgroundColor: destructive
          ? AppColors.error.withValues(alpha: 0.08)
          : AppColors.primary.withValues(alpha: 0.08),
      side: BorderSide.none,
    );
  }
}
