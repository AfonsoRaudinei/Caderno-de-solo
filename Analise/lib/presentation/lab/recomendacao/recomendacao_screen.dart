import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/domain/entities/analise_entity.dart';
import 'package:soloforte/domain/entities/calibracao_entity.dart' as legacy;
import 'package:soloforte/domain/entities/citacao_calibracao_model.dart';
import 'package:soloforte/domain/entities/resultado_gesso.dart';
import 'package:soloforte/domain/formulas/calcario_formula.dart';
import 'package:soloforte/domain/formulas/fosforo_formula.dart';
import 'package:soloforte/domain/formulas/gesso_engine.dart';
import 'package:soloforte/domain/formulas/potassio_formula.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';
import 'package:soloforte/domain/usecases/calcular_recomendacao_usecase.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
import 'package:soloforte/presentation/lab/calibracao/calibracao_controller.dart';
import 'package:soloforte/presentation/lab/recomendacao/recomendacao_header_footer.dart';

class RecomendacaoScreen extends ConsumerStatefulWidget {
  const RecomendacaoScreen({super.key});

  @override
  ConsumerState<RecomendacaoScreen> createState() => _RecomendacaoScreenState();
}

class _RecomendacaoScreenState extends ConsumerState<RecomendacaoScreen> {
  final _useCase = CalcularRecomendacaoUseCase();

  String? _analiseIdSelecionada;
  String? _calibracaoIdSelecionada;
  bool _gerando = false;
  _ResultadoRecomendacao? _resultado;

  @override
  Widget build(BuildContext context) {
    final calibracaoState = ref.watch(calibracaoControllerProvider);
    final analisesAsync = ref.watch(analiseNotifierProvider);
    final perfis = calibracaoState.profiles;

    final opcoesAnalise =
        analisesAsync.valueOrNull?.map(_toAnaliseOption).toList() ?? [];
    final analiseSelecionada =
        opcoesAnalise.where((e) => e.id == _analiseIdSelecionada).firstOrNull;
    final perfilSelecionado =
        perfis.where((p) => p.id == _calibracaoIdSelecionada).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          AppCardSection(
            title: 'Recomendação',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppDropdown<String>(
                  label: 'Selecionar Análise de Solo',
                  hint: analisesAsync.isLoading
                      ? 'Carregando análises...'
                      : 'Selecione',
                  value: _analiseIdSelecionada,
                  items: opcoesAnalise
                      .map(
                        (opcao) => AppDropdownItem<String>(
                          value: opcao.id,
                          label: opcao.label,
                        ),
                      )
                      .toList(),
                  onChanged: opcoesAnalise.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            _analiseIdSelecionada = value;
                            _resultado = null;
                          });
                        },
                ),
                const SizedBox(height: 8),
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
                          label: perfil.nome.isEmpty ? 'Sem nome' : perfil.nome,
                        ),
                      )
                      .toList(),
                  onChanged: perfis.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            _calibracaoIdSelecionada = value;
                            _resultado = null;
                          });
                        },
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Gerar Recomendação',
                  icon: Icons.auto_awesome_rounded,
                  isLoading: _gerando,
                  onPressed: (analiseSelecionada != null &&
                          perfilSelecionado != null &&
                          !_gerando)
                      ? () => _gerar(
                          analiseSelecionada: analiseSelecionada,
                          perfilSelecionado: perfilSelecionado)
                      : null,
                ),
                if (analisesAsync.hasError) ...[
                  const SizedBox(height: 10),
                  const _Badge(
                    icon: Icons.error_outline,
                    color: AppColors.error,
                    label: 'Não foi possível carregar análises salvas.',
                  ),
                ],
                if (perfis.isEmpty && !calibracaoState.loading) ...[
                  const SizedBox(height: 10),
                  const _Badge(
                    icon: Icons.info_outline,
                    color: AppColors.warning,
                    label:
                        'Nenhuma calibração salva. Cadastre na aba Calibração.',
                  ),
                ],
                if (opcoesAnalise.isEmpty &&
                    !analisesAsync.isLoading &&
                    !analisesAsync.hasError) ...[
                  const SizedBox(height: 10),
                  const _Badge(
                    icon: Icons.info_outline,
                    color: AppColors.warning,
                    label: 'Nenhuma análise salva. Cadastre em Análise.',
                  ),
                ],
              ],
            ),
          ),
          if (_resultado != null) ...[
            const SizedBox(height: 14),
            const RecomendacaoHeader(),
            const SizedBox(height: 12),
            _buildIdentificacao(_resultado!),
            const SizedBox(height: 12),
            _buildCalcario(_resultado!),
            const SizedBox(height: 12),
            _buildGesso(_resultado!),
            const SizedBox(height: 12),
            _buildFosforo(_resultado!),
            const SizedBox(height: 12),
            _buildPotassio(_resultado!),
            const SizedBox(height: 12),
            _buildMicros(_resultado!),
            const SizedBox(height: 12),
            _buildAvisos(_resultado!),
            const SizedBox(height: 12),
            _buildArgumentos(_resultado!),
            const SizedBox(height: 12),
            AppCardSection(
              title: 'Ações',
              child: Row(
                children: [
                  Expanded(
                    child: AppButtonSecondary(
                      label: 'Salvar Recomendação',
                      icon: Icons.save_alt_rounded,
                      onPressed: () => _showMensagem(
                          'Recomendação pronta para persistência.'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButtonSecondary(
                      label: 'Exportar PDF',
                      icon: Icons.picture_as_pdf_outlined,
                      onPressed: () => _showMensagem(
                          'Exportação PDF será conectada no próximo passo.'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIdentificacao(_ResultadoRecomendacao resultado) {
    final analise = resultado.analise;
    final perfil = resultado.calibracao;
    return AppCardSection(
      title: 'Identificação',
      child: Column(
        children: [
          _infoRow('Cliente', perfil.cliente),
          _infoRow('Fazenda', perfil.fazenda),
          _infoRow('Talhão', perfil.talhao),
          _infoRow('Cultura', perfil.cultura),
          _infoRow('Safra', perfil.safra),
          _infoRow('Análise', resultado.labelAnalise),
          _infoRow('Calibração', perfil.nome),
          _infoRow('Gerada em',
              DateFormat('dd/MM/yyyy HH:mm').format(resultado.geradaEm)),
          _infoRow('pH / V%',
              '${_fmt(analise.ph, 1)} · ${_fmt(analise.vPercent, 1)}%'),
        ],
      ),
    );
  }

  Widget _buildCalcario(_ResultadoRecomendacao resultado) {
    final analise = resultado.analise;
    final metodo = resultado.metodoCalagem;
    return AppCardSection(
      title: 'Calcário',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Badge(
            icon: Icons.verified_outlined,
            color: AppColors.primary,
            label: 'Método: $metodo',
          ),
          const SizedBox(height: 8),
          Text(
            '${_fmt(resultado.doseCalcarioTHa, 2)} t/ha',
            style: AppTextStyles.headline.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          _infoRow('V% atual', '${_fmt(analise.vPercent, 1)}%'),
          _infoRow('V% esperado', '${_fmt(resultado.vEsperado, 1)}%'),
          _infoRow('Ca',
              '${_fmt(analise.ca, 2)} → ${_fmt(resultado.caEsperado, 2)} cmolc/dm³'),
          _infoRow('Mg',
              '${_fmt(analise.mg, 2)} → ${_fmt(resultado.mgEsperado, 2)} cmolc/dm³'),
          _infoRow('Relação Ca:Mg', '${_fmt(resultado.relacaoCaMg, 2)}:1'),
          if (resultado.parcelamento.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...resultado.parcelamento.map(
              (item) => Text('• $item', style: AppTextStyles.caption),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGesso(_ResultadoRecomendacao resultado) {
    return AppCardSection(
      title: 'Gesso',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Badge(
            icon: resultado.gesso.indicado
                ? Icons.check_circle_outline
                : Icons.info_outline,
            color: resultado.gesso.indicado
                ? AppColors.success
                : AppColors.textSecond,
            label: resultado.gesso.indicado
                ? '🟡 Gessagem indicada'
                : '✅ Gessagem não indicada',
          ),
          const SizedBox(height: 8),
          if (resultado.gesso.indicado) ...[
            _infoRow('Dose', '${_fmt(resultado.gesso.doseKgHa, 0)} kg/ha'),
            _infoRow('S fornecido',
                '${_fmt(resultado.gesso.sFornecidoKgHa, 1)} kg/ha'),
            _infoRow('Ca fornecido',
                '${_fmt(resultado.gesso.caFornecidoKgHa, 1)} kg/ha'),
          ],
          if (resultado.gesso.observacoes.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...resultado.gesso.observacoes
                .map((item) => Text('• $item', style: AppTextStyles.caption)),
          ],
        ],
      ),
    );
  }

  Widget _buildFosforo(_ResultadoRecomendacao resultado) {
    return AppCardSection(
      title: 'Fósforo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Modo', resultado.modoFosforo),
          _infoRow('P solo / NC',
              '${_fmt(resultado.analise.p, 2)} / ${_fmt(resultado.ncFosforo, 2)} mg/dm³'),
          Text(
            '${_fmt(resultado.doseP2O5KgHa, 1)} kg P₂O₅/ha',
            style: AppTextStyles.value.copyWith(color: AppColors.fosforo),
          ),
          if (resultado.legacyP) ...[
            const SizedBox(height: 8),
            const _Badge(
              icon: Icons.warning_amber_rounded,
              color: AppColors.warning,
              label: 'Solo acima do NC — dose mínima de manutenção aplicada.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPotassio(_ResultadoRecomendacao resultado) {
    return AppCardSection(
      title: 'Potássio',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Critério', resultado.criterioPotassio),
          _infoRow('K solo / NC',
              '${_fmt(resultado.analise.k, 2)} / ${_fmt(resultado.ncPotassio, 2)}'),
          Text(
            '${_fmt(resultado.doseK2OKgHa, 1)} kg K₂O/ha',
            style: AppTextStyles.value.copyWith(color: AppColors.potassio),
          ),
          const SizedBox(height: 8),
          _infoRow('Relação K:Mg', _fmt(resultado.relacoesK.relacaoKMg, 2)),
          _infoRow('Relação K:Ca', _fmt(resultado.relacoesK.relacaoKCa, 2)),
          if (resultado.relacoesK.alertas.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...resultado.relacoesK.alertas.map(
              (item) => _Badge(
                icon: Icons.warning_amber_rounded,
                color: AppColors.warning,
                label: item,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMicros(_ResultadoRecomendacao resultado) {
    return AppCardSection(
      title: 'Micronutrientes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (resultado.micros.isEmpty)
            const Text(
                'Nenhuma dose de micronutriente > 0 nesta configuração.'),
          ...resultado.micros.map(
            (micro) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${micro.simbolo}: ${_fmt(micro.doseElemento, 1)} g/ha via ${micro.via} — Fonte: ${micro.fonte} — ${micro.doseProdutoLabel}',
                style: AppTextStyles.caption,
              ),
            ),
          ),
          if (resultado.grupos.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...resultado.grupos.map(
              (grupo) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '📦 ${grupo.nome}: ${grupo.elementos.join(' + ')} — ${grupo.via}\nProduto: ${grupo.produto} · Dose: ${grupo.doseProdutoKgLabel}\nFornece: ${grupo.fornecimento}',
                    style: AppTextStyles.caption,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvisos(_ResultadoRecomendacao resultado) {
    return AppCardSection(
      title: 'Avisos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (resultado.avisos.isEmpty)
            const Text('Sem avisos críticos para os parâmetros atuais.')
          else
            ...resultado.avisos.map(
              (aviso) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _Badge(
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  label: aviso,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArgumentos(_ResultadoRecomendacao resultado) {
    return AppCardSection(
      title: 'Argumentos Técnicos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(resultado.argumentos, style: AppTextStyles.body),
          const SizedBox(height: 10),
          _citacao('Calagem', resultado.base.citacaoCalagem),
          _citacao('Gesso', resultado.base.citacaoGesso),
          _citacao('Fósforo', resultado.base.citacaoFosforo),
          _citacao('Potássio', resultado.base.citacaoPotassio),
          _citacao('Micronutrientes', resultado.base.citacaoMicronutrientes),
        ],
      ),
    );
  }

  Widget _citacao(String titulo, CitacaoCalibracaoModel citacao) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$titulo: ${citacao.autor} (${citacao.ano}) · ${citacao.instituicao}',
        style: AppTextStyles.caption,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _gerar({
    required _AnaliseOption analiseSelecionada,
    required CalibracaoProfile perfilSelecionado,
  }) async {
    setState(() => _gerando = true);
    try {
      final resultado = _calcularResultado(
        analise: analiseSelecionada,
        perfil: perfilSelecionado,
      );
      ref.read(calibracaoUsadaNaRecomendacaoProvider.notifier).state =
          perfilSelecionado.id;
      setState(() {
        _resultado = resultado;
      });
    } catch (_) {
      _showMensagem(
          'Falha ao gerar recomendação para os parâmetros selecionados.');
    } finally {
      setState(() => _gerando = false);
    }
  }

  _ResultadoRecomendacao _calcularResultado({
    required _AnaliseOption analise,
    required CalibracaoProfile perfil,
  }) {
    final corretivos = _asMap(perfil.parametrosCards['corretivos']);
    final fosforo = _asMap(perfil.parametrosCards['fosforo']);
    final potassio = _asMap(perfil.parametrosCards['potassio']);
    final micros = _asMap(perfil.parametrosCards['micros']);

    final calEntity = _toCalibracaoEntity(perfil);
    final base =
        _useCase.fromEntities(calibracao: calEntity, analise: analise.entity);

    final metodoCalagem =
        _string(corretivos['metodoCalagem'], '① Saturação por Bases (V%)');
    final calcario1 = _asMap(corretivos['calcario1']);
    final albrecht = _asMap(corretivos['albrecht']);
    final prnt = _num(calcario1['prnt'], 80);
    final caO = _num(calcario1['caO'], 30);
    final mgO = _num(calcario1['mgO'], 16);
    final profundidade = _profundidade(corretivos);
    final sc = _num(corretivos['sc'], 1.0);

    final doseCalcario = _doseCalcario(
      metodo: metodoCalagem,
      analise: analise.entity,
      prnt: prnt,
      profundidade: profundidade,
      sc: sc,
      corretivos: corretivos,
      albrecht: albrecht,
      caO: caO,
      mgO: mgO,
    );

    final gessoConfig = _asMap(corretivos['gesso']);
    final usaGesso = _bool(gessoConfig['usarGesso']);
    final diagnostico = GessoEngine.diagnosticar(
      caSub: analise.entity.ca * 0.4,
      alSub: analise.entity.al * 0.8,
      mSub: _mSubEstimado(analise.entity),
    );

    final resultadoGesso = usaGesso
        ? _calcularGesso(
            metodo: _string(gessoConfig['metodo'],
                '① EMBRAPA / Souza et al. (2004) — argila %'),
            analise: analise.entity,
            diagnostico: diagnostico,
          )
        : const ResultadoGesso(
            metodo: MetodoGesso.argilaEmbrapa,
            indicado: false,
            doseKgHa: 0,
            doseTHa: 0,
            sFornecidoKgHa: 0,
            caFornecidoKgHa: 0,
            caAumentoCmolcDm3: 0,
            observacoes: ['Gesso desativado na calibração.'],
          );

    final modoP = _string(fosforo['modoCalculo'], '① Correção do solo');
    final ncP = _num(
      fosforo['nc'],
      FosforoFormula.nivelCriticoResina(analise.entity.argila),
    );
    var doseP = modoP.startsWith('①')
        ? FosforoFormula.recomendacaoCorrecao(
            pSolo: analise.entity.p,
            nivelCritico: ncP,
            argilaPercent: analise.entity.argila,
            percentualCorrecao: _num(fosforo['percentualCorrecao'], 100),
            fep: _num(fosforo['fepBase'],
                FosforoFormula.fepBase(analise.entity.argila)),
          )
        : FosforoFormula.recomendacaoExtracao(
            pSolo: analise.entity.p,
            percentualUsoSolo: _num(fosforo['percentualUsoPSolo'], 0),
            profundidadeCm: 20,
            extracaoP2O5: _extracaoP2O5(perfil.cultura),
            fepFinal: _num(fosforo['fepBase'],
                FosforoFormula.fepBase(analise.entity.argila)),
          );
    final legacyInfo = FosforoFormula.avaliarLegacyP(
      pSolo: analise.entity.p,
      nivelCritico: ncP,
      exportacaoGrao: _extracaoP2O5(perfil.cultura),
    );
    if (legacyInfo.legacyP && doseP < legacyInfo.doseMinima) {
      doseP = legacyInfo.doseMinima;
    }

    final modoK = _string(potassio['modoCalculo'], '① Correção do solo');
    final criterioK = _string(potassio['criterioNc'], 'Ambos — usar o maior');
    final ncK = criterioK == '% K na CTC'
        ? _num(potassio['ncPctCtc'], 4)
        : _num(potassio['ncTeor'],
            PotassioFormula.nivelCriticoTeorAbsoluto(analise.entity.argila));

    final doseK = modoK.startsWith('①')
        ? PotassioFormula.recomendacao(
            ctc: analise.entity.ctc,
            kAtual: analise.entity.k,
            participacaoDesejada: _num(potassio['ncPctCtc'],
                perfil.cultura.toLowerCase().contains('algod') ? 5 : 4),
            cultura: perfil.cultura,
            usarCriterioTeorAbsoluto: criterioK != '% K na CTC',
            kAtualMgDm3: analise.entity.k * 391.0,
            argilaPercent: analise.entity.argila,
            percentualCorrecaoTeor: _num(potassio['percentualCorrecao'], 100),
          )
        : PotassioFormula.recomendacaoExtracao(
            kSolo: analise.entity.k,
            percentualUsoSolo: _num(potassio['percentualUsoKSolo'], 0),
            extracaoK2O: _extracaoK2O(perfil.cultura),
            fek: _num(
              potassio['fekBase'],
              PotassioFormula.fekFinal(
                  argilaPercent: analise.entity.argila,
                  cultura: perfil.cultura),
            ),
          );

    final antagonismos = PotassioFormula.calcularAntagonismos(
      kTotal: analise.entity.k,
      ctc: analise.entity.ctc,
      mgAtual: analise.entity.mg,
      caAtual: analise.entity.ca,
    );

    final microsResultado = _calcularMicros(
      micros: micros,
      analise: analise.entity,
    );
    final gruposResultado = _calcularGrupos(
      grupos: _asListMap(micros['grupos']),
      micros: microsResultado,
    );

    final relacaoCaMg =
        analise.entity.mg > 0 ? analise.entity.ca / analise.entity.mg : 0.0;
    final vEsperado = _vEsperado(metodoCalagem, corretivos);
    final caEsperado = analise.entity.ca + (doseCalcario * (caO / 100) * 0.2);
    final mgEsperado = analise.entity.mg + (doseCalcario * (mgO / 100) * 0.12);

    final avisos = <String>[
      if (legacyInfo.legacyP)
        'Fósforo acima do NC: aplicado piso de manutenção.',
      if (antagonismos.avisoKCTC)
        'K% na CTC acima de 7%. Risco de desequilíbrio.',
      if (antagonismos.avisoKMg) 'Relação K:Mg elevada. Monitorar antagonismo.',
      if (antagonismos.avisoKCa)
        'Relação K:Ca elevada. Avaliar parcelamento de K.',
      if (PotassioFormula.avisoSulco(
        modoAplicacao: _string(potassio['modoAplicacao'], 'Sulco'),
        doseK2O: doseK,
      ))
        'Dose de K₂O em sulco acima de 40 kg/ha.',
      ...resultadoGesso.observacoes.where((item) => item.contains('monitorar')),
    ];

    final argumentos =
        'A recomendação cruza a análise selecionada com as regras da calibração. '
        'Calcário foi calculado por $metodoCalagem com V% alvo de ${_fmt(vEsperado, 1)}. '
        'Fósforo foi calculado no modo $modoP com NC ${_fmt(ncP, 1)} mg/dm³ e FEP configurado. '
        'Potássio considerou o critério "$criterioK" e FEK da calibração. '
        'Micronutrientes foram gerados apenas para doses positivas e agrupados conforme os grupos ativos.';

    final parcelamento = doseCalcario > 4
        ? <String>[
            'Aplicação 1: 60% = ${_fmt(doseCalcario * 0.6, 2)} t/ha — ${_string(corretivos['mesAplicacao'], 'Setembro')}',
            'Aplicação 2: 40% = ${_fmt(doseCalcario * 0.4, 2)} t/ha — ${_mesSeguinte(_string(corretivos['mesAplicacao'], 'Setembro'))}',
          ]
        : <String>[];

    return _ResultadoRecomendacao(
      analise: analise.entity,
      labelAnalise: analise.label,
      calibracao: perfil,
      base: base,
      geradaEm: DateTime.now(),
      metodoCalagem: metodoCalagem,
      doseCalcarioTHa: doseCalcario,
      vEsperado: vEsperado,
      caEsperado: caEsperado,
      mgEsperado: mgEsperado,
      relacaoCaMg: relacaoCaMg,
      parcelamento: parcelamento,
      gesso: resultadoGesso,
      modoFosforo: modoP,
      ncFosforo: ncP,
      doseP2O5KgHa: doseP,
      legacyP: legacyInfo.legacyP,
      criterioPotassio: criterioK,
      ncPotassio: ncK,
      doseK2OKgHa: doseK,
      relacoesK: _RelacoesK(
        relacaoKMg: antagonismos.relKMg,
        relacaoKCa: antagonismos.relKCa,
        alertas: [
          if (antagonismos.avisoKCTC) 'K% CTC elevado',
          if (antagonismos.avisoKMg) 'K:Mg crítico',
          if (antagonismos.avisoKCa) 'K:Ca crítico',
        ],
      ),
      micros: microsResultado,
      grupos: gruposResultado,
      avisos: avisos,
      argumentos: argumentos,
    );
  }

  List<_MicroResultado> _calcularMicros({
    required Map<String, dynamic> micros,
    required AnaliseEntity analise,
  }) {
    final elementos = _asMap(micros['elementos']);
    final resultados = <_MicroResultado>[];
    for (final entry in elementos.entries) {
      final simbolo = entry.key;
      final config = _asMap(entry.value);
      final via = _string(config['viaAplicacao'], 'Solo (correção)');
      final teor = via.contains('Solo')
          ? _num(config['teorFonteSolo'], 0)
          : _num(config['teorFonteFoliar'], 0);
      final eficiencia = via.contains('Solo')
          ? _num(config['eficienciaSolo'], 0)
          : _num(config['eficienciaFoliar'], 0);
      final doseElemento = via.contains('Solo')
          ? ((_num(config['ncSolo']) - _valorMicroAnalise(simbolo, analise))
                  .clamp(0, double.infinity) *
              200 *
              (_num(config['percentualCorrecaoSolo'], 100) / 100))
          : _num(config['doseElementoFoliar'], 0);
      if (doseElemento <= 0) continue;

      final doseProduto = (teor > 0 && eficiencia > 0)
          ? doseElemento / (teor / 100) / (eficiencia / 100)
          : 0.0;
      final doseProdutoLabel = doseProduto >= 1000
          ? '${_fmt(doseProduto / 1000, 2)} kg/ha produto'
          : '${_fmt(doseProduto, 1)} g/ha produto';
      resultados.add(
        _MicroResultado(
          simbolo: simbolo,
          via: via,
          fonte: via.contains('Solo')
              ? _string(config['fonteSolo'], 'Fonte solo')
              : _string(config['fonteFoliar'], 'Fonte foliar'),
          doseElemento: doseElemento,
          doseProduto: doseProduto,
          doseProdutoLabel: doseProdutoLabel,
        ),
      );
    }
    return resultados;
  }

  List<_GrupoResultado> _calcularGrupos({
    required List<Map<String, dynamic>> grupos,
    required List<_MicroResultado> micros,
  }) {
    final resultados = <_GrupoResultado>[];
    for (final grupo in grupos) {
      final elementos = List<String>.from(
          (grupo['elementos'] as List?)?.map((e) => e.toString()) ?? const []);
      final microsGrupo =
          micros.where((item) => elementos.contains(item.simbolo)).toList();
      if (microsGrupo.isEmpty) continue;
      final doseProdutoKg =
          microsGrupo.fold<double>(0, (sum, item) => sum + item.doseProduto) /
              1000;
      final fornecimento = microsGrupo
          .map((item) => '${item.simbolo} ${_fmt(item.doseElemento, 1)}g/ha')
          .join(' · ');
      resultados.add(
        _GrupoResultado(
          nome: _string(grupo['nome'], 'Grupo'),
          via: _string(grupo['via'], 'Foliar'),
          elementos: elementos,
          produto: _string(grupo['produto'], 'Mistura manual'),
          doseProdutoKgLabel: '${_fmt(doseProdutoKg, 2)} kg/ha',
          fornecimento: fornecimento,
        ),
      );
    }
    return resultados;
  }

  double _doseCalcario({
    required String metodo,
    required AnaliseEntity analise,
    required double prnt,
    required double profundidade,
    required double sc,
    required Map<String, dynamic> corretivos,
    required Map<String, dynamic> albrecht,
    required double caO,
    required double mgO,
  }) {
    if (metodo.startsWith('①')) {
      return CalcarioFormula.metodoV(
        ctc: analise.ctc,
        vAtual: analise.vPercent,
        vDesejado: _num(corretivos['v2'], 70),
        prnt: prnt,
        profundidadeCm: profundidade,
        sc: sc,
      );
    }
    if (metodo.startsWith('②')) {
      return CalcarioFormula.metodoEmbrapa(
        hAl: analise.hAl,
        fator: _num(corretivos['fatorHAl'], 0.5),
        prnt: prnt,
        profundidadeCm: profundidade,
        sc: sc,
      );
    }
    if (metodo.startsWith('③')) {
      return CalcarioFormula.metodoCaMg(
        caAtual: analise.ca,
        mgAtual: analise.mg,
        prnt: prnt,
        profundidadeCm: profundidade,
        sc: sc,
      );
    }
    if (metodo.startsWith('④')) {
      return CalcarioFormula.metodoSupercalagem(
        doseFixa: _num(corretivos['doseFixa'], 1.5),
        prnt: prnt,
        profundidadeCm: profundidade,
        sc: sc,
      );
    }
    if (metodo.startsWith('⑤')) {
      return CalcarioFormula.metodoAlbrecht(
        ctc: analise.ctc,
        caAtual: analise.ca,
        mgAtual: analise.mg,
        kAtual: analise.k,
        pctCaAlvo: _num(albrecht['caAlvo'], 65),
        pctMgAlvo: _num(albrecht['mgAlvo'], 15),
        pctKAlvo: _num(albrecht['kAlvo'], 4),
        caO: caO,
        prnt: prnt,
        pisoCaCmolc: _num(albrecht['ncCa'], 2.0),
        pisoMgCmolc: _num(albrecht['ncMg'], 0.8),
        pisoKCmolc: _num(albrecht['ncK'], 0.15),
        profundidadeCm: profundidade,
        sc: sc,
      );
    }
    if (metodo.startsWith('⑥')) {
      return CalcarioFormula.metodoAlbrechtY(
        ctc: analise.ctc,
        caAtual: analise.ca,
        mgAtual: analise.mg,
        kAtual: analise.k,
        pctCaAlvo: _num(albrecht['caAlvo'], 65),
        pctMgAlvo: _num(albrecht['mgAlvo'], 15),
        pctKAlvo: _num(albrecht['kAlvo'], 4),
        caO: caO,
        argilaPercent: analise.argila,
        prnt: prnt,
        pisoCaCmolc: _num(albrecht['ncCa'], 2.0),
        pisoMgCmolc: _num(albrecht['ncMg'], 0.8),
        pisoKCmolc: _num(albrecht['ncK'], 0.15),
        profundidadeCm: profundidade,
        sc: sc,
      );
    }
    return CalcarioFormula.metodoCorrecaoMg(
      mgDesejado: _num(corretivos['mgDesejado'], 0.8),
      mgAtual: analise.mg,
      fatorMgCalcario: CalcarioFormula.fatorMg(mgO: mgO),
      prnt: prnt,
      profundidadeCm: profundidade,
      sc: sc,
    );
  }

  ResultadoGesso _calcularGesso({
    required String metodo,
    required AnaliseEntity analise,
    required DiagnosticoGesso diagnostico,
  }) {
    if (metodo.startsWith('②')) {
      return GessoEngine.metodo2Textura(
        argilaPercent: analise.argila,
        diagnostico: diagnostico,
      );
    }
    if (metodo.startsWith('③')) {
      return GessoEngine.metodo3VSubCTC(
        vaSub: analise.vPercent * 0.75,
        ctcSubMmolcDm3: analise.ctc * 0.7,
        diagnostico: diagnostico,
      );
    }
    if (metodo.startsWith('④')) {
      final ctcEfetiva = analise.ca + analise.mg + analise.k + analise.al;
      return GessoEngine.metodo4CTCeCa(
        ctcESubCmolcDm3: ctcEfetiva * 0.7,
        caSubCmolcDm3: analise.ca * 0.4,
        diagnostico: diagnostico,
      );
    }
    return GessoEngine.metodo1Argila(
      argilaPercent: analise.argila,
      culturaPerena: false,
      diagnostico: diagnostico,
    );
  }

  _AnaliseOption _toAnaliseOption(AnaliseSolo analise) {
    final entity = AnaliseEntity(
      id: analise.id,
      nome: analise.nomeArea,
      consultor: 'Consultor',
      fazenda: analise.nomeArea,
      talhao: analise.nomeArea,
      localizacao: analise.descricaoLocal ?? '-',
      cultura: analise.cultura.label,
      ph: analise.phAgua ?? analise.phCacl2 ?? analise.phSmp ?? 0,
      mo: 0,
      p: analise.fosforo ?? 0,
      k: analise.potassio ?? 0,
      ca: analise.calcio ?? 0,
      mg: analise.magnesio ?? 0,
      hAl: analise.hMaisAl ?? 0,
      al: analise.aluminio ?? 0,
      s: analise.enxofre ?? 0,
      b: analise.boro ?? 0,
      cu: analise.cobre ?? 0,
      fe: analise.ferro ?? 0,
      mn: analise.manganes ?? 0,
      zn: analise.zinco ?? 0,
      sb: (analise.calcio ?? 0) +
          (analise.magnesio ?? 0) +
          (analise.potassio ?? 0),
      ctc: analise.ctc,
      vPercent: analise.vPorcento,
      argila: _argilaPorTextura(analise.textura),
    );
    final label =
        '${analise.nomeArea} · ${analise.laboratorio} · ${DateFormat('dd/MM/yyyy').format(analise.dataCadastro)}';
    return _AnaliseOption(
      id: analise.id,
      label: label,
      entity: entity,
    );
  }

  legacy.CalibracaoEntity _toCalibracaoEntity(CalibracaoProfile perfil) {
    final corretivos = _asMap(perfil.parametrosCards['corretivos']);
    final fosforo = _asMap(perfil.parametrosCards['fosforo']);
    final potassio = _asMap(perfil.parametrosCards['potassio']);
    final micros = _asMap(perfil.parametrosCards['micros']);
    return legacy.CalibracaoEntity(
      id: perfil.id,
      nomePerfil: perfil.nome,
      criadoEm: perfil.createdAt,
      metodoCalagemSelecionado:
          _string(corretivos['metodoCalagem'], '① Saturação por Bases (V%)'),
      referenciaCalagemSelecionada:
          _string(corretivos['referencia'], '01 — Calagem: Motor de Cálculo'),
      estadoSelecionado: 'N/D',
      tipoSoloSelecionado: 'N/D',
      metodoGessagemSelecionado: _string(_asMap(corretivos['gesso'])['metodo'],
          '① EMBRAPA / Souza et al. (2004) — argila %'),
      referenciaGessagemSelecionada:
          _string(corretivos['referencia'], '02 — Gesso: Motor de Cálculo'),
      metodoPosforoSelecionado: _string(fosforo['extrator'], 'Resina IAC'),
      referenciaPosforoSelecionada:
          _string(fosforo['referencia'], '03 — Fósforo (P): Motor de Cálculo'),
      metodoKaliumSelecionado:
          _string(potassio['criterioNc'], 'Ambos — usar o maior'),
      referenciaKaliumSelecionada: _string(
          potassio['referencia'], '04 — Potássio (K): Motor de Cálculo'),
      metodoMicroSelecionado: _string(
          micros['referencia'], '06 — Micronutrientes: Motor de Cálculo'),
      referenciaMicroSelecionada: _string(
          micros['referencia'], '06 — Micronutrientes: Motor de Cálculo'),
    );
  }

  double _valorMicroAnalise(String simbolo, AnaliseEntity analise) {
    switch (simbolo) {
      case 'B':
        return analise.b;
      case 'Cu':
        return analise.cu;
      case 'Fe':
        return analise.fe;
      case 'Mn':
        return analise.mn;
      case 'Zn':
        return analise.zn;
      default:
        return 0;
    }
  }

  double _argilaPorTextura(TexturaSolo textura) {
    switch (textura) {
      case TexturaSolo.argiloso:
        return 60;
      case TexturaSolo.medio:
        return 35;
      case TexturaSolo.arenoso:
        return 12;
    }
  }

  double _vEsperado(String metodo, Map<String, dynamic> corretivos) {
    if (metodo.startsWith('①')) return _num(corretivos['v2'], 70);
    if (metodo.startsWith('②')) return 65;
    if (metodo.startsWith('⑤') || metodo.startsWith('⑥')) {
      final albrecht = _asMap(corretivos['albrecht']);
      return _num(albrecht['caAlvo']) +
          _num(albrecht['mgAlvo']) +
          _num(albrecht['kAlvo']);
    }
    return 70;
  }

  String _mesSeguinte(String mes) {
    const meses = [
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
    final index = meses.indexOf(mes);
    if (index == -1) return meses.first;
    return meses[(index + 1) % 12];
  }

  double _profundidade(Map<String, dynamic> corretivos) {
    final metodo =
        _string(corretivos['metodoIncorporacao'], 'Sem incorporação');
    if (metodo.contains('Grade')) {
      final diametro = _num(corretivos['diametroGradePol'], 32);
      final folga = _num(corretivos['folgaMancal'], 25);
      final raio = diametro * 2.54 / 2;
      return (raio - folga / 2).clamp(0, 40);
    }
    return _num(corretivos['profundidadeManual'], 20);
  }

  double _mSubEstimado(AnaliseEntity analise) {
    final t = analise.ca + analise.mg + analise.k + analise.al;
    if (t <= 0) return 0;
    return (analise.al / t) * 100;
  }

  double _extracaoP2O5(String cultura) {
    final c = cultura.toLowerCase();
    if (c.contains('milho')) return 110;
    if (c.contains('algod')) return 130;
    if (c.contains('feij')) return 90;
    return 100;
  }

  double _extracaoK2O(String cultura) {
    final c = cultura.toLowerCase();
    if (c.contains('milho')) return 120;
    if (c.contains('algod')) return 150;
    if (c.contains('feij')) return 100;
    return 110;
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

  String _string(dynamic value, String fallback) {
    final text = value?.toString() ?? '';
    if (text.isEmpty) return fallback;
    return text;
  }

  bool _bool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  double _num(dynamic value, [double fallback = 0]) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? fallback;
    }
    return fallback;
  }

  String _fmt(double value, [int decimals = 2]) {
    final text = value.toStringAsFixed(decimals);
    return text.replaceAll('.', ',');
  }

  void _showMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
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
          const SizedBox(width: 8),
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

class _AnaliseOption {
  const _AnaliseOption({
    required this.id,
    required this.label,
    required this.entity,
  });

  final String id;
  final String label;
  final AnaliseEntity entity;
}

class _RelacoesK {
  const _RelacoesK({
    required this.relacaoKMg,
    required this.relacaoKCa,
    required this.alertas,
  });

  final double relacaoKMg;
  final double relacaoKCa;
  final List<String> alertas;
}

class _MicroResultado {
  const _MicroResultado({
    required this.simbolo,
    required this.via,
    required this.fonte,
    required this.doseElemento,
    required this.doseProduto,
    required this.doseProdutoLabel,
  });

  final String simbolo;
  final String via;
  final String fonte;
  final double doseElemento;
  final double doseProduto;
  final String doseProdutoLabel;
}

class _GrupoResultado {
  const _GrupoResultado({
    required this.nome,
    required this.via,
    required this.elementos,
    required this.produto,
    required this.doseProdutoKgLabel,
    required this.fornecimento,
  });

  final String nome;
  final String via;
  final List<String> elementos;
  final String produto;
  final String doseProdutoKgLabel;
  final String fornecimento;
}

class _ResultadoRecomendacao {
  const _ResultadoRecomendacao({
    required this.analise,
    required this.labelAnalise,
    required this.calibracao,
    required this.base,
    required this.geradaEm,
    required this.metodoCalagem,
    required this.doseCalcarioTHa,
    required this.vEsperado,
    required this.caEsperado,
    required this.mgEsperado,
    required this.relacaoCaMg,
    required this.parcelamento,
    required this.gesso,
    required this.modoFosforo,
    required this.ncFosforo,
    required this.doseP2O5KgHa,
    required this.legacyP,
    required this.criterioPotassio,
    required this.ncPotassio,
    required this.doseK2OKgHa,
    required this.relacoesK,
    required this.micros,
    required this.grupos,
    required this.avisos,
    required this.argumentos,
  });

  final AnaliseEntity analise;
  final String labelAnalise;
  final CalibracaoProfile calibracao;
  final RecomendacaoModel base;
  final DateTime geradaEm;
  final String metodoCalagem;
  final double doseCalcarioTHa;
  final double vEsperado;
  final double caEsperado;
  final double mgEsperado;
  final double relacaoCaMg;
  final List<String> parcelamento;
  final ResultadoGesso gesso;
  final String modoFosforo;
  final double ncFosforo;
  final double doseP2O5KgHa;
  final bool legacyP;
  final String criterioPotassio;
  final double ncPotassio;
  final double doseK2OKgHa;
  final _RelacoesK relacoesK;
  final List<_MicroResultado> micros;
  final List<_GrupoResultado> grupos;
  final List<String> avisos;
  final String argumentos;
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
