import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/core/widgets/nutriente_card.dart';
import 'package:soloforte/data/culturas_data.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_state.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/calibracao_footer_card.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/calibracao_header_card.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/calibracao_status_badge.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/calibracao_subsection_title.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart';
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

  final Map<String, bool> _expandedMicros = {};
  final Map<String, bool> _editandoInline = {};

  // Referência de Absorção — Micros (T3C)
  String _microTipoFonte = 'Autores';
  String? _microFonteNome;

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
    final elementos = _asMap(micros['elementos']);
    final grupos = _asListMap(micros['grupos']);
    // Sincronizar campos de absorção lidos do draft (T3C)
    final microTipoFonteDraft = micros['microTipoFonte']?.toString();
    final microFonteNomeDraft = micros['microFonteNome']?.toString();
    if (microTipoFonteDraft != null && microTipoFonteDraft != _microTipoFonte) {
      // Usar SchedulerBinding para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _microTipoFonte = microTipoFonteDraft;
            _microFonteNome = microFonteNomeDraft;
          });
        }
      });
    }
    for (final simbolo in _elementosMicros) {
      _expandedMicros.putIfAbsent(simbolo, () => false);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.appPalette.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Calibração',
          style: AppTextStyles.label.copyWith(
            color: context.appPalette.textPrimary,
          ),
        ),
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
          NutrienteCard(
            nutriente: 'Micronutrientes',
            icon: Icons.biotech_outlined,
            cor: AppColors.micronut,
            initiallyExpanded: false,
            isExpanded: _expandedCards['micros'] ?? false,
            onToggle: () => setState(
              () => _expandedCards['micros'] =
                  !(_expandedCards['micros'] ?? false),
            ),
            children: [
              _buildMicrosCard(
                draftKey: draftKey,
                micros: micros,
                elementos: elementos,
                grupos: grupos,
                microTipoFonte: _microTipoFonte,
                microFonteNome: _microFonteNome,
                onMicroAbsorcaoChanged: (tipo, nome) {
                  setState(() {
                    _microTipoFonte = tipo;
                    _microFonteNome = nome;
                  });
                },
                onChanged: (map) => controller
                    .updateMicros(MicronutrientesState(parametros: map)),
              ),
            ],
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

  Widget _buildMicrosCard({
    required String draftKey,
    required Map<String, dynamic> micros,
    required Map<String, dynamic> elementos,
    required List<Map<String, dynamic>> grupos,
    required ValueChanged<Map<String, dynamic>> onChanged,
    String microTipoFonte = 'Autores',
    String? microFonteNome,
    void Function(String tipo, String? nome)? onMicroAbsorcaoChanged,
  }) {
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
            onMicroAbsorcaoChanged?.call(v, novoNome);
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
            onMicroAbsorcaoChanged?.call(microTipoFonte, v);
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
        const CalibracaoSubsectionTitle('Grupos de Aplicação'),
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
        const CalibracaoSubsectionTitle('Nutrientes Individuais'),
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
                color: context.appPalette.card,
                border: Border.all(color: context.appPalette.border),
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
                    title: Text(
                      _nomeMicro(simbolo),
                      style: AppTextStyles.label.copyWith(
                        color: context.appPalette.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Classe: $classe',
                      style: AppTextStyles.caption.copyWith(
                        color: context.appPalette.textSecondary,
                      ),
                    ),
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
    final palette = context.appPalette;

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
        style: AppTextStyles.input.copyWith(color: palette.textPrimary),
        onChanged: onChanged,
        onEditingComplete: onFinalizar,
        decoration: InputDecoration(
          filled: true,
          fillColor: palette.inputFill,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: palette.borderStrong),
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
