import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/core/widgets/nutriente_card.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_state.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/calibracao_footer_card.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/calibracao_header_card.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/calibracao_status_badge.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/calibracao_subsection_title.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/micronutrientes_card_widget.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart';

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
    final micros = _asMap(draft.parametrosCards['micros']);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Calibração', style: AppTextStyles.label),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.screenPadding,
          AppDimens.md,
          AppDimens.screenPadding,
          120,
        ),
        children: [
          CalibracaoHeaderCard(
            draftKey: draftKey,
            nome: draft.nome,
            safra: draft.safra,
            cliente: draft.cliente,
            culturas: _culturas
                .map((cultura) =>
                    AppDropdownItem(value: cultura, label: cultura))
                .toList(),
            culturaSelecionada: _culturas.contains(draft.cultura)
                ? draft.cultura
                : _culturas.first,
            onNomeChanged: controller.atualizarNome,
            onCulturaChanged: controller.atualizarCultura,
            onSafraChanged: controller.atualizarSafra,
            onClienteChanged: controller.atualizarCliente,
            produtividadeEsperadaTha: draft.produtividadeEsperadaTha,
            onProdutividadeChanged: controller.atualizarProdutividade,
          ),
          NutrienteCard(
            nutriente: 'I · Corretivos (Calagem/Gessagem)',
            icon: Icons.layers_outlined,
            cor: AppColors.primary,
            initiallyExpanded: false,
            isExpanded: _expandedCards['corretivos'] ?? false,
            onToggle: () => setState(
              () => _expandedCards['corretivos'] =
                  !(_expandedCards['corretivos'] ?? false),
            ),
            children: [
              _buildCorretivosCard(
                draft: draft,
                draftKey: draftKey,
                corretivos: corretivos,
                onChanged: (map) =>
                    controller.updateCalcario(CalcarioState(parametros: map)),
              ),
            ],
          ),
          FosforoCardWidget(
            key: ValueKey('fosforo-$draftKey'),
            initialData: fosforo,
            cultura: draft.cultura,
            onChanged: (map) =>
                controller.updateFosforo(FosforoState(parametros: map)),
          ),
          const SizedBox(height: AppDimens.md),
          PotassioCardWidget(
            key: ValueKey('potassio-$draftKey'),
            initialData: _asMap(draft.parametrosCards['potassio']),
            cultura: draft.cultura,
            onChanged: (map) =>
                controller.updatePotassio(PotassioState(parametros: map)),
          ),
          MicronutrientesCardWidget(
            key: ValueKey('micros-$draftKey'),
            draftKey: draftKey,
            initialData: micros,
            isExpanded: _expandedCards['micros'] ?? false,
            onToggle: () => setState(
              () => _expandedCards['micros'] =
                  !(_expandedCards['micros'] ?? false),
            ),
            onChanged: (map) =>
                controller.updateMicros(MicronutrientesState(parametros: map)),
          ),
          const SizedBox(height: AppDimens.lg),
          CalibracaoFooterCard(
            onSalvar: () => controller.salvar(),
            salvando: state.saving,
            ultimaAtualizacao: draft.updatedAt,
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
        const CalibracaoSubsectionTitle('Tipo de calagem'),
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
        const CalibracaoSubsectionTitle('Calcário'),
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
              ...corretivos,
              'metodoCalagem': value ?? metodos.first
            };
            onChanged(atualizado);
          },
        ),
        const SizedBox(height: 10),
        if (metodoCalagem.startsWith('Saturação'))
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
        if (metodoCalagem.startsWith('Albrecht') ||
            metodoCalagem.startsWith('⑥')) ...[
          const SizedBox(height: 14),
          const CalibracaoSubsectionTitle('Bloco Albrecht'),
          const SizedBox(height: 8),
          CalibracaoStatusBadge(
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
                  'Painel Y: NC Albrecht ${_fmt(_num(corretivos['doseFixa'], fallback: 1.2), decimals: 2)} t/ha · Y do solo ${_fmt(_num(corretivos['doseFixa'], fallback: 1.2), decimals: 2)} t/ha',
            ),
          ],
        ],
        const SizedBox(height: 14),
        const CalibracaoSubsectionTitle('Incorporação'),
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
          CalibracaoStatusBadge(
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
          CalibracaoStatusBadge(
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
        CalibracaoStatusBadge(
          icon: Icons.calendar_month_outlined,
          color: AppColors.warning,
          label: 'Dias disponíveis: ${_diasPorMes[mes] ?? 30} dias',
        ),
        const SizedBox(height: 14),
        const CalibracaoSubsectionTitle('Gesso'),
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
}
