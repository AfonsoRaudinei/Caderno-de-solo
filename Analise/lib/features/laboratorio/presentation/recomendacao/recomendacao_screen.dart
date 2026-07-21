import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/services/produtor_resolucao_service.dart';
import 'package:soloforte/features/config/presentation/calculos/calculos_provider.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
import 'package:soloforte/features/laboratorio/presentation/providers/recomendacao_provider_real.dart';

bool analiseMatchesProdutorBusca(AnaliseSolo analise, String busca) {
  final query = busca.trim();
  if (query.isEmpty) return true;
  final q = query.toLowerCase();
  final produtor =
      ProdutorResolucaoService.produtorEfetivo(analise).toLowerCase();
  return produtor.contains(q) ||
      analise.fazenda.toLowerCase().contains(q) ||
      analise.talhao.toLowerCase().contains(q) ||
      analise.numeroAmostra.toLowerCase().contains(q);
}

class RecomendacaoScreen extends ConsumerStatefulWidget {
  final String? analiseId;

  const RecomendacaoScreen({super.key, this.analiseId});

  @override
  ConsumerState<RecomendacaoScreen> createState() => _RecomendacaoScreenState();
}

class _RecomendacaoScreenState extends ConsumerState<RecomendacaoScreen> {
  final _buscaProdutorController = TextEditingController();
  List<String> _analiseIdsSelecionados = [];
  String? _calibracaoIdSelecionada;

  @override
  void initState() {
    super.initState();
    if (widget.analiseId != null && widget.analiseId!.isNotEmpty) {
      _analiseIdsSelecionados = [widget.analiseId!];
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calculosSelectedAnaliseIdsProvider.notifier).state =
          List<String>.from(_analiseIdsSelecionados);
    });
  }

  @override
  void dispose() {
    _buscaProdutorController.dispose();
    super.dispose();
  }

  bool _isProfundidade0a20(AnaliseSolo analise) {
    final profundidade =
        analise.profundidade.replaceAll('–', '-').replaceAll(' ', '').trim();
    return profundidade.isEmpty || profundidade == '0-20';
  }

  @override
  Widget build(BuildContext context) {
    final calibracaoState = ref.watch(calibracaoControllerProvider);
    final analisesVisiveis = ref.watch(analisesVisiveisProvider);
    final buscaProdutor = ref.watch(recomendacaoSearchQueryProvider);
    final perfis = calibracaoState.profiles;

    final analisesRaw = analisesVisiveis.where(_isProfundidade0a20).toList(
          growable: false,
        );
    final analisesFiltradas = analisesRaw
        .where((analise) => analiseMatchesProdutorBusca(analise, buscaProdutor))
        .toList(growable: false);
    final opcoesAnalise = analisesFiltradas.map(_toAnaliseOption).toList();
    final podeGerar =
        _analiseIdsSelecionados.isNotEmpty && _calibracaoIdSelecionada != null;
    final request = RecomendacaoRequest(
      analiseIds: _analiseIdsSelecionados,
      calibracaoId: _calibracaoIdSelecionada,
    );

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        centerTitle: true,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(
                  CupertinoIcons.chevron_back,
                  color: AppColors.primary,
                ),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          'Recomendação',
          style: AppTextStyles.headline.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const _RecomendacaoHeaderCard(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
                child: Text(
                  'SELEÇÃO',
                  style: AppTextStyles.sectionLabel,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPadding,
                ),
                padding: const EdgeInsets.all(AppDimens.screenPadding),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(color: AppColors.border, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppInput(
                      controller: _buscaProdutorController,
                      hint: 'Buscar produtor...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecond,
                        size: 20,
                      ),
                      textInputAction: TextInputAction.search,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) {
                        ref
                            .read(recomendacaoSearchQueryProvider.notifier)
                            .state = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    _AmostrasDropdown(
                      analises: opcoesAnalise,
                      selecionados: _analiseIdsSelecionados,
                      onChanged: (ids) {
                        setState(() {
                          _analiseIdsSelecionados = ids;
                        });
                        ref
                            .read(calculosSelectedAnaliseIdsProvider.notifier)
                            .state = List<String>.from(ids);
                      },
                    ),
                    const SizedBox(height: 12),
                    AppDropdown<String>(
                      label: 'Selecionar Calibração',
                      hint: calibracaoState.loading
                          ? 'Carregando calibrações...'
                          : 'Selecione',
                      value: _calibracaoIdSelecionada,
                      items: perfis
                          .map(
                            (perfil) => AppDropdownItem<String>(
                              value: perfil.id,
                              label: perfil.nome.isEmpty
                                  ? 'Sem nome'
                                  : perfil.nome,
                            ),
                          )
                          .toList(),
                      onChanged: perfis.isEmpty
                          ? null
                          : (value) {
                              setState(() {
                                _calibracaoIdSelecionada = value;
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      key: const Key('btn_gerar_recomendacao'),
                      label: '✦ Gerar Recomendação',
                      icon: Icons.auto_awesome,
                      onPressed: podeGerar
                          ? () {
                              ref
                                  .read(calculosSelectedAnaliseIdsProvider
                                      .notifier)
                                  .state = List<String>.from(
                                _analiseIdsSelecionados,
                              );
                              ref.invalidate(recomendacaoProvider(request));
                              ref.read(recomendacaoProvider(request));
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecomendacaoHeaderCard extends StatelessWidget {
  const _RecomendacaoHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.borderSoft, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.science,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recomendação de Adubação',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'SoloForte · ESALQ/USP',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecond,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmostrasDropdown extends StatelessWidget {
  const _AmostrasDropdown({
    required this.analises,
    required this.selecionados,
    required this.onChanged,
  });

  final List<_AnaliseOption> analises;
  final List<String> selecionados;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final resumo = selecionados.isEmpty
        ? 'Nenhuma selecionada'
        : '${selecionados.length} amostras selecionadas';

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Material(
        color: AppColors.bgPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          key: const Key('seletor_amostras_dropdown'),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          iconColor: AppColors.textSecond,
          collapsedIconColor: AppColors.textSecond,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecionar Amostras',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecond,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                resumo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: selecionados.isEmpty
                      ? AppColors.textSecond
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          children: [
            if (analises.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nenhuma amostra encontrada.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecond,
                    ),
                  ),
                ),
              )
            else
              ...analises.map((analise) {
                final isSelecionada = selecionados.contains(analise.id);
                return CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: isSelecionada,
                  activeColor: AppColors.primary,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    analise.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onChanged: (_) {
                    final next = List<String>.from(selecionados);
                    if (isSelecionada) {
                      next.remove(analise.id);
                    } else {
                      next.add(analise.id);
                    }
                    onChanged(next);
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _AnaliseOption {
  const _AnaliseOption({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

_AnaliseOption _toAnaliseOption(AnaliseSolo analise) {
  final produtor = ProdutorResolucaoService.produtorEfetivo(analise);
  final produtorLabel = produtor.isEmpty ? 'Produtor não informado' : produtor;
  final amostra = analise.numeroAmostra.trim();
  final amostraLabel = amostra.isEmpty ? '' : ' · $amostra';

  return _AnaliseOption(
    id: analise.id,
    label:
        '$produtorLabel · ${analise.fazenda} · ${analise.talhao}$amostraLabel',
  );
}
