import 'package:soloforte/features/laboratorio/presentation/providers/recomendacao_export_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/features/config/application/providers/calculos_provider.dart';
import 'package:soloforte/features/config/presentation/config_controller.dart';
import 'package:soloforte/features/config/application/providers/perfil_assets_provider.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/laboratorio/domain/entities/laudo_recomendacao.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
import 'package:soloforte/features/laboratorio/presentation/providers/recomendacao_provider_real.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/widgets/calcario_gesso_section.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/widgets/fosforo_section.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/widgets/graficos_section.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/widgets/micros_section.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/widgets/potassio_section.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/widgets/avisos_section.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/widgets/qualidade_solo_section.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/widgets/recomendacao_selecao_analises.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/recomendacao_header_footer.dart';
import 'package:uuid/uuid.dart';

class RecomendacaoScreen extends ConsumerStatefulWidget {
  final String? analiseId;
  const RecomendacaoScreen({super.key, this.analiseId});

  @override
  ConsumerState<RecomendacaoScreen> createState() => _RecomendacaoScreenState();
}

class _RecomendacaoScreenState extends ConsumerState<RecomendacaoScreen> {
  final _uuid = const Uuid();
  List<String> _analiseIdsSelecionados = [];
  String? _calibracaoIdSelecionada;
  bool _salvando = false;
  bool _exportando = false;
  String? _clienteIdInicial;

  @override
  void initState() {
    super.initState();
    if (widget.analiseId != null && widget.analiseId!.isNotEmpty) {
      _analiseIdsSelecionados = [widget.analiseId!];
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolverClienteInicial();
      _syncCalculosSelecao();
    });
  }

  void _resolverClienteInicial() {
    final id = widget.analiseId?.trim();
    if (id == null || id.isEmpty) return;
    final analises = ref.read(analiseNotifierProvider).valueOrNull ?? const [];
    final match = analises.where((a) => a.id == id).firstOrNull;
    final clienteId = match?.clienteId?.trim();
    if (clienteId != null && clienteId.isNotEmpty && mounted) {
      setState(() => _clienteIdInicial = clienteId);
    }
  }

  void _syncCalculosSelecao() {
    ref.read(calculosSelectedAnaliseIdsProvider.notifier).state =
        List<String>.from(_analiseIdsSelecionados);
    ref.read(calculosSelectedCalibracaoIdProvider.notifier).state =
        _calibracaoIdSelecionada;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final calibracaoState = ref.watch(calibracaoControllerProvider);
    final analisesAsync = ref.watch(analiseNotifierProvider);
    final perfis = calibracaoState.profiles;

    final n = _analiseIdsSelecionados.length;
    final labelBotao =
        n > 1 ? '✦ Gerar Média de $n Amostras' : '✦ Gerar Recomendação';
    final request = RecomendacaoRequest(
      analiseIds: _analiseIdsSelecionados,
      calibracaoId: _calibracaoIdSelecionada,
    );
    final result = ref.watch(recomendacaoProvider(request));
    final resultado = result.recomendacao;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: palette.textPrimary,
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
          style: AppTextStyles.headline.copyWith(color: palette.accent),
        ),
        centerTitle: false,
      ),
      body: ListView(
        key: const Key('recomendacao_body_scroll'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          AppCardSection(
            title: 'Seleção',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RecomendacaoSelecaoAnalises(
                  key: ValueKey('selecao-${_clienteIdInicial ?? 'none'}'),
                  selecionados: _analiseIdsSelecionados,
                  initialClienteId: _clienteIdInicial,
                  onChanged: (ids) {
                    setState(() => _analiseIdsSelecionados = ids);
                    _syncCalculosSelecao();
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
                          });
                          ref
                              .read(
                                calibracaoUsadaNaRecomendacaoProvider.notifier,
                              )
                              .state = value;
                          _syncCalculosSelecao();
                        },
                ),
                const SizedBox(height: 12),
                AppButton(
                  key: const Key('btn_gerar_recomendacao'),
                  label: labelBotao,
                  icon: Icons.auto_awesome_rounded,
                  onPressed: (_analiseIdsSelecionados.isEmpty ||
                          _calibracaoIdSelecionada == null)
                      ? null
                      : () {
                          _syncCalculosSelecao();
                          ref.invalidate(recomendacaoProvider(request));
                        },
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
                if (!result.diagnostico.valido) ...[
                  const SizedBox(height: 10),
                  _Badge(
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    label: result.diagnostico.erros.join(' | '),
                  ),
                ],
              ],
            ),
          ),
          if (resultado != null) ...[
            const SizedBox(height: 14),
            const RecomendacaoHeader(),
            const SizedBox(height: 12),

            // BLOCO 1 — Identificação
            RecomendacaoIdentificacaoSection(resultado: resultado),
            Divider(height: 32, thickness: 0.5, color: palette.border),

            // BLOCO 2 — Qualidade do Solo
            RecomendacaoQualidadeSoloSection(resultado: resultado),
            Divider(height: 32, thickness: 0.5, color: palette.border),

            // BLOCO 3 — Correções
            RecomendacaoCalcarioGessoSection(resultado: resultado),
            const SizedBox(height: 12),
            RecomendacaoBasesDashboard(resultado: resultado),
            const SizedBox(height: 12),
            RecomendacaoGraficosSection(resultado: resultado),
            Divider(height: 32, thickness: 0.5, color: palette.border),

            // BLOCO 4 — Nutrientes
            RecomendacaoFosforoSection(resultado: resultado),
            RecomendacaoPotassioSection(resultado: resultado),
            Divider(height: 32, thickness: 0.5, color: palette.border),

            // BLOCO 5 — Micronutrientes por Aplicação
            RecomendacaoMicrosUnificadosSection(resultado: resultado),

            Divider(height: 32, thickness: 0.5, color: palette.border),

            // Avisos e Argumentos (mantidos no final)
            RecomendacaoAvisosSection(resultado: resultado),
            const SizedBox(height: 12),
            RecomendacaoArgumentosSection(resultado: resultado),
            const SizedBox(height: 12),
            AppCardSection(
              title: 'Ações',
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('btn_salvar_recomendacao'),
                      onPressed: (_salvando || _exportando)
                          ? null
                          : () => _salvarResultado(resultado),
                      icon: const Icon(Icons.bookmark, size: 18),
                      label: const Text(
                        'Salvar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const Key('btn_exportar_pdf'),
                      onPressed: (_salvando || _exportando)
                          ? null
                          : () => _exportarRelatorio(resultado),
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Exportar relatorio'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.textSecondary,
                        side: BorderSide(color: palette.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  void _showMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _salvarResultado(ResultadoRecomendacao resultado) async {
    setState(() => _salvando = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

      final model = RecomendacaoModel(
        id: const Uuid().v4(),
        analiseId: resultado.analise.id,
        userId: uid,
        cultura: resultado.calibracao.nome,
        necessidadeCalagem: resultado.doseCalcarioTHa,
        prnt: 100.0,
        doseCalcario: resultado.doseCalcarioTHa,
        p2o5: 0.0,
        k2o: 0.0,
      );

      await ref
          .read(salvarRecomendacaoProvider.notifier)
          .salvarRecomendacao(model);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Recomendação salva com sucesso'),
          backgroundColor: const Color(0xFF34C759),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showMensagem('Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _exportarRelatorio(ResultadoRecomendacao resultado) async {
    setState(() => _exportando = true);
    try {
      final analises = ref.read(analiseNotifierProvider).valueOrNull ?? [];
      AnaliseSolo? analiseSolo;
      final analisesSelecionadas = <AnaliseSolo>[];
      for (final a in analises) {
        if (_analiseIdsSelecionados.contains(a.id)) {
          analisesSelecionadas.add(a);
        }
        if (a.id == resultado.analise.id) {
          analiseSolo = a;
        }
      }

      final perfilAssets = ref.read(perfilAssetsProvider);
      final perfil = ref.read(configControllerProvider).valueOrNull;

      await ref.read(exportRecomendacaoProvider)(
        resultado: resultado,
        analiseSolo: analiseSolo,
        analisesSelecionadas: analisesSelecionadas,
        perfil: perfil,
        logoUrl: perfilAssets.logoUrl,
      );
    } catch (e) {
      if (!mounted) return;
      _showMensagem('Erro exportar relatorio: $e');
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  // ignore: unused_element
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
          .map(
            (m) => {
              'simbolo': m.elemento,
              'via': m.via,
              'fonte': m.fonte,
              'doseElemento': m.dose,
              'doseProduto': m.doseProduto,
              'doseProdutoLabel': m.doseProdutoLabel,
            },
          )
          .toList(),
      avisos: resultado.avisos,
      argumentos: resultado.argumentos,
      status: LaudoStatus.completo,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.color, required this.label});

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
