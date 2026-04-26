import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/services/app_observability.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/domain/entities/analise_entity.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/laboratorio/services/laudo_pdf_generator.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/laboratorio/domain/entities/laudo_recomendacao.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/recomendacao_header_footer.dart';
import 'package:soloforte/features/config/application/providers/tabela_metricas_provider.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
import 'package:soloforte/features/laboratorio/application/providers/laudo_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class RecomendacaoScreen extends ConsumerStatefulWidget {
  final String? analiseId;
  const RecomendacaoScreen({super.key, this.analiseId});

  @override
  ConsumerState<RecomendacaoScreen> createState() => _RecomendacaoScreenState();
}

class _RecomendacaoScreenState extends ConsumerState<RecomendacaoScreen> {
  final _uuid = const Uuid();
  String? _analiseIdSelecionada;
  String? _calibracaoIdSelecionada;
  bool _gerando = false;
  bool _salvando = false;
  bool _exportando = false;
  ResultadoRecomendacao? _resultado;

  @override
  void initState() {
    super.initState();
    _analiseIdSelecionada = widget.analiseId;
  }

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
      appBar: AppBar(
        backgroundColor: AppColors.bgSecondary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go(AppRoutes.lab);
          },
        ),
        title: Text(
          'Recomendação',
          style: AppTextStyles.headline.copyWith(color: AppColors.primary),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          AppCardSection(
            title: 'Seleção',
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
                      ? () {
                          final tabelas =
                              (ref.read(tabelaMetricasProvider).valueOrNull ??
                                      const [])
                                  .map((tabela) => tabela.toJson())
                                  .toList(growable: false);
                          _gerar(
                            analiseSelecionada: analiseSelecionada,
                            perfilSelecionado: perfilSelecionado,
                            tabelas: tabelas,
                          );
                        }
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
                    child: AppButton(
                      label: 'Salvar Recomendação',
                      icon: Icons.save_alt_rounded,
                      isLoading: _salvando,
                      onPressed: (_salvando || _exportando)
                          ? null
                          : () => _salvarResultado(_resultado!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButtonSecondary(
                      label: _exportando ? 'Gerando...' : 'Exportar PDF',
                      icon: Icons.picture_as_pdf_outlined,
                      onPressed: (_salvando || _exportando)
                          ? null
                          : () => _exportarPdf(_resultado!),
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

  Widget _buildIdentificacao(ResultadoRecomendacao resultado) {
    final perfil = resultado.calibracao;
    return AppCardSection(
      title: 'Identificação',
      child: Column(
        children: [
          _buildInfoRow('Análise', resultado.labelAnalise ?? 'N/D'),
          _buildInfoRow('Cultura', perfil.cultura),
          _buildInfoRow('Safra', perfil.safra),
          if (resultado.geradaEm != null)
            _buildInfoRow('Data',
                DateFormat('dd/MM/yyyy HH:mm').format(resultado.geradaEm!)),
        ],
      ),
    );
  }

  Widget _buildCalcario(ResultadoRecomendacao resultado) {
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

  Widget _buildGesso(ResultadoRecomendacao resultado) {
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

  Widget _buildFosforo(ResultadoRecomendacao resultado) {
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

  Widget _buildPotassio(ResultadoRecomendacao resultado) {
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
          _infoRow('Relação K:Mg', _fmt(resultado.relacoesK.relKMg, 2)),
          _infoRow('Relação K:Ca', _fmt(resultado.relacoesK.relKCa, 2)),
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

  Widget _buildMicros(ResultadoRecomendacao resultado) {
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
                '${micro.elemento}: ${_fmt(micro.dose, 1)} g/ha via ${micro.via} — Fonte: ${micro.fonte} — ${micro.doseProdutoLabel}',
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
                    '📦 ${grupo.nomeGrupo}: ${grupo.micros.map((e) => e.elemento).join(' + ')} — ${grupo.via}\nProduto: ${grupo.produto} · Dose: ${grupo.doseProdutoKgLabel}\nFornece: ${grupo.fornecimento}',
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

  Widget _buildAvisos(ResultadoRecomendacao resultado) {
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

  Widget _buildArgumentos(ResultadoRecomendacao resultado) {
    final citacoes = resultado.citacoes;
    return AppCardSection(
      title: 'Argumentos Técnicos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(resultado.argumentos, style: AppTextStyles.body),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          _buildCitacao('Calcário', citacoes?['calagem']),
          _buildCitacao('Gesso', citacoes?['gesso']),
          _buildCitacao('Fósforo', citacoes?['fosforo']),
          _buildCitacao('Potássio', citacoes?['potassio']),
          _buildCitacao('Micronutrientes', citacoes?['micros']),
        ],
      ),
    );
  }

  Widget _buildCitacao(String nutriente, String? citacao) {
    if (citacao == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '• $nutriente: $citacao',
        style: AppTextStyles.label.copyWith(color: AppColors.textSecond),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$label: ', style: AppTextStyles.label),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }

  Future<void> _gerar({
    required _AnaliseOption analiseSelecionada,
    required CalibracaoProfile perfilSelecionado,
    required List<Map<String, dynamic>> tabelas,
  }) async {
    setState(() => _gerando = true);
    try {
      final resultado = await AppObservability.instance.trace(
        'recomendacao_generate',
        () async {
          const engine = RecomendacaoEngine();
          return engine.calcular(
            analise: analiseSelecionada.entity,
            labelAnalise: analiseSelecionada.label,
            calibracao: perfilSelecionado,
            tabelas: tabelas,
          );
        },
        attributes: {'flow': 'recomendacao', 'action': 'gerar'},
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

  _AnaliseOption _toAnaliseOption(AnaliseSolo analise) {
    final sb = (analise.ca ?? 0) +
        (analise.mg ?? 0) +
        (analise.k ?? 0) +
        (analise.na ?? 0);
    final ctcTotal = sb + (analise.hMaisAl ?? 0);
    final vPct = ctcTotal > 0 ? (sb / ctcTotal) * 100 : 0.0;
    final argilaPercent = (analise.argila ?? 0) / 10.0;

    final entity = AnaliseEntity(
      id: analise.id,
      nome: analise.talhao,
      consultor: 'Consultor',
      fazenda: analise.talhao,
      talhao: analise.talhao,
      localizacao: analise.descricaoLocal ?? '-',
      cultura: analise.cultura.label,
      ph: analise.phAgua ?? analise.phCaCl2 ?? analise.phSmp ?? 0,
      mo: analise.materiaOrganica ?? 0,
      p: analise.pMehlich ?? 0,
      k: analise.k ?? 0,
      ca: analise.ca ?? 0,
      mg: analise.mg ?? 0,
      hAl: analise.hMaisAl ?? 0,
      al: analise.al ?? 0,
      s: analise.s020 ?? 0,
      b: analise.b ?? 0,
      cu: analise.cu ?? 0,
      fe: analise.fe ?? 0,
      mn: analise.mn ?? 0,
      zn: analise.zn ?? 0,
      sb: sb,
      ctc: ctcTotal,
      vPercent: vPct,
      argila: argilaPercent,
    );
    final label =
        '${analise.talhao} · ${analise.laboratorio} · ${DateFormat('dd/MM/yyyy').format(analise.dataCadastro)}';
    return _AnaliseOption(
      id: analise.id,
      label: label,
      entity: entity,
    );
  }

  String _fmt(double value, [int decimals = 2]) {
    final text = value.toStringAsFixed(decimals);
    return text.replaceAll('.', ',');
  }

  void _showMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> _salvarResultado(ResultadoRecomendacao resultado) async {
    setState(() => _salvando = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await AppObservability.instance.trace(
        'recomendacao_save_laudo',
        () async {
          final laudo = _toLaudo(resultado, uid);
          await ref.read(laudoNotifierProvider.notifier).salvar(laudo);
        },
        attributes: {'flow': 'recomendacao', 'action': 'salvar'},
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Recomendação salva no Histórico!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(AppRoutes.labHistorico);
    } catch (e) {
      if (!mounted) return;
      _showMensagem('Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _exportarPdf(ResultadoRecomendacao resultado) async {
    setState(() => _exportando = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await AppObservability.instance.trace(
        'recomendacao_export_pdf',
        () async {
          final laudo = _toLaudo(resultado, uid);
          await LaudoPdfGenerator.gerarECompartilhar(laudo);
        },
        attributes: {'flow': 'recomendacao', 'action': 'exportar_pdf'},
      );
    } catch (e) {
      if (!mounted) return;
      _showMensagem('Erro ao gerar PDF: $e');
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  LaudoRecomendacao _toLaudo(ResultadoRecomendacao resultado, String uid) {
    return LaudoRecomendacao(
      id: _uuid.v4(),
      userId: uid,
      analiseId: resultado.analise.id,
      calibracaoId: resultado.calibracao.id,
      talhao: resultado.calibracao.talhao,
      fazenda: resultado.calibracao.fazenda,
      cliente: resultado.calibracao.cliente,
      cultura: resultado.calibracao.cultura,
      safra: resultado.calibracao.safra,
      laboratorio: resultado.analise.nome,
      nomeCalibra: resultado.calibracao.nome,
      geradaEm: resultado.geradaEm ?? DateTime.now(),
      metodoCalagem: resultado.metodoCalagem,
      doseCalcarioTHa: resultado.doseCalcarioTHa,
      vAtual: resultado.analise.vPercent,
      vEsperado: resultado.vEsperado,
      caAtual: resultado.analise.ca,
      caEsperado: resultado.caEsperado,
      mgAtual: resultado.analise.mg,
      mgEsperado: resultado.mgEsperado,
      relacaoCaMg: resultado.relacaoCaMg,
      parcelamento: resultado.parcelamento,
      gessoIndicado: resultado.gesso.indicado,
      gessoKgHa: resultado.gesso.doseKgHa.toDouble(),
      modoFosforo: resultado.modoFosforo,
      pSoloMgDm3: resultado.analise.p,
      ncFosforo: resultado.ncFosforo,
      doseP2O5KgHa: resultado.doseP2O5KgHa,
      legacyP: resultado.legacyP,
      criterioPotassio: resultado.criterioPotassio,
      kSolo: resultado.analise.k,
      ncPotassio: resultado.ncPotassio,
      doseK2OKgHa: resultado.doseK2OKgHa,
      micros: resultado.micros
          .map((m) => {
                'simbolo': m.elemento,
                'via': m.via,
                'fonte': m.fonte,
                'doseElemento': m.dose,
                'doseProduto': m.doseProduto,
                'doseProdutoLabel': m.doseProdutoLabel,
              })
          .toList(),
      avisos: resultado.avisos,
      argumentos: resultado.argumentos,
      status: LaudoStatus.completo,
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

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
