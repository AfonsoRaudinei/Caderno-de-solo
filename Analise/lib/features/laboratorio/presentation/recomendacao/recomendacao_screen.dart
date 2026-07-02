import 'package:soloforte/features/laboratorio/application/recomendacao_export_context_builder.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/recomendacao_html_exporter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soloforte/domain/models/recomendacao_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/features/config/application/providers/perfil_assets_provider.dart';
import 'package:soloforte/features/config/presentation/config_controller.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.analiseId != null && widget.analiseId!.isNotEmpty) {
      _analiseIdsSelecionados = [widget.analiseId!];
    }
  }

  @override
  Widget build(BuildContext context) {
    final calibracaoState = ref.watch(calibracaoControllerProvider);
    final analisesAsync = ref.watch(analiseNotifierProvider);
    final perfis = calibracaoState.profiles;

    final opcoesAnalise =
        analisesAsync.valueOrNull?.map(_toAnaliseOption).toList() ?? [];
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
                _SeletorAmostras(
                  analises: opcoesAnalise,
                  selecionados: _analiseIdsSelecionados,
                  onChanged: (ids) {
                    setState(() {
                      _analiseIdsSelecionados = ids;
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
                          });
                          ref
                              .read(calibracaoUsadaNaRecomendacaoProvider
                                  .notifier)
                              .state = value;
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
            const Divider(height: 32, thickness: 0.5, color: Color(0xFFE5E5E7)),

            // BLOCO 2 — Qualidade do Solo
            RecomendacaoQualidadeSoloSection(resultado: resultado),
            const Divider(height: 32, thickness: 0.5, color: Color(0xFFE5E5E7)),

            // BLOCO 3 — Correções
            RecomendacaoCalcarioGessoSection(resultado: resultado),
            const SizedBox(height: 12),
            RecomendacaoBasesDashboard(resultado: resultado),
            const SizedBox(height: 12),
            RecomendacaoGraficosSection(resultado: resultado),
            const Divider(height: 32, thickness: 0.5, color: Color(0xFFE5E5E7)),

            // BLOCO 4 — Nutrientes
            RecomendacaoFosforoSection(resultado: resultado),
            RecomendacaoPotassioSection(resultado: resultado),
            const Divider(height: 32, thickness: 0.5, color: Color(0xFFE5E5E7)),

            // BLOCO 5 — Micronutrientes por Aplicação
            RecomendacaoMicrosUnificadosSection(resultado: resultado),

            const Divider(height: 32, thickness: 0.5, color: Color(0xFFE5E5E7)),

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
                        backgroundColor: AppColors.primary,
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
                          : () => _exportarPdf(resultado),
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Exportar relatorio'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF666666),
                        side: const BorderSide(color: Color(0xFFD1D1D6)),
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

  _AnaliseOption _toAnaliseOption(AnaliseSolo analise) {
    final label =
        '${analise.talhao} · ${analise.numeroAmostra} · ${analise.laboratorio} · ${DateFormat('dd/MM/yyyy').format(analise.dataCadastro)}';
    return _AnaliseOption(
      id: analise.id,
      label: label,
      profundidade: analise.profundidade,
      laboratorio: analise.laboratorio,
    );
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Future<void> _exportarPdf(ResultadoRecomendacao resultado) async {
    setState(() => _exportando = true);
    try {
      final analises = ref.read(analiseNotifierProvider).valueOrNull ?? [];
      AnaliseSolo? analiseSolo;
      for (final a in analises) {
        if (a.id == resultado.analise.id) {
          analiseSolo = a;
          break;
        }
      }

      final perfilAssets = ref.read(perfilAssetsProvider);
      final perfil = ref.read(configControllerProvider).valueOrNull;

      final exportContext =
          await const RecomendacaoExportContextBuilder().build(
        resultado: resultado,
        analiseSolo: analiseSolo,
        perfil: perfil,
        logoUrl: perfilAssets.logoUrl,
      );

      await const RecomendacaoHtmlExporter().exportar(exportContext);
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

class _SeletorAmostras extends StatelessWidget {
  const _SeletorAmostras({
    required this.analises,
    required this.selecionados,
    required this.onChanged,
  });

  final List<_AnaliseOption> analises;
  final List<String> selecionados;
  final ValueChanged<List<String>> onChanged;

  String _normalizarProfundidade(String raw) {
    final s = raw.trim();
    return s.isEmpty ? '0-20' : s;
  }

  @override
  Widget build(BuildContext context) {
    String? profAtiva;
    String? laboratorioAtivo;
    if (selecionados.isNotEmpty) {
      final primeira = analises.firstWhere(
        (a) => a.id == selecionados.first,
        orElse: () => const _AnaliseOption(id: '', label: ''),
      );
      if (primeira.id.isNotEmpty) {
        profAtiva = _normalizarProfundidade(primeira.profundidade ?? '');
        laboratorioAtivo = primeira.laboratorio;
      }
    }

    final resumo = selecionados.isEmpty
        ? 'Selecione as amostras'
        : selecionados.length == 1
            ? _labelSelecionado(selecionados.first)
            : '${selecionados.length} amostras selecionadas';

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: ExpansionTile(
          key: const Key('seletor_amostras_dropdown'),
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          iconColor: AppColors.textSecond,
          collapsedIconColor: AppColors.textSecond,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selecionar Amostras', style: AppTextStyles.label),
              const SizedBox(height: 4),
              Text(
                resumo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: selecionados.isEmpty
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          children: [
            if (profAtiva != null || laboratorioAtivo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    if (profAtiva != null)
                      _ContextLabel(
                        icon: Icons.layers_outlined,
                        label: 'Profundidade: $profAtiva',
                      ),
                    if (laboratorioAtivo != null)
                      _ContextLabel(
                        icon: Icons.science_outlined,
                        label: 'Laboratório: $laboratorioAtivo',
                      ),
                  ],
                ),
              ),
            ...analises.map((analise) {
              final id = analise.id;
              final label = analise.label;
              final prof = _normalizarProfundidade(analise.profundidade ?? '');
              final laboratorio = analise.laboratorio;

              final isSelecionado = selecionados.contains(id);
              final laboratorioDiferente = laboratorioAtivo != null &&
                  !isSelecionado &&
                  laboratorio != laboratorioAtivo;
              final profundidadeDiferente =
                  profAtiva != null && !isSelecionado && prof != profAtiva;
              final isBloqueado = laboratorioDiferente || profundidadeDiferente;

              return Opacity(
                opacity: isBloqueado ? 0.35 : 1.0,
                child: InkWell(
                  key: Key('amostra_option_$id'),
                  onTap: isBloqueado
                      ? null
                      : () {
                          final novos = List<String>.from(selecionados);
                          if (isSelecionado) {
                            novos.remove(id);
                          } else {
                            novos.add(id);
                          }
                          onChanged(novos);
                        },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelecionado
                          ? const Color(0xFF007AFF).withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelecionado
                            ? const Color(0xFF007AFF).withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelecionado
                              ? Icons.check_circle
                              : isBloqueado
                                  ? Icons.remove_circle_outline
                                  : Icons.radio_button_unchecked,
                          size: 20,
                          color: isSelecionado
                              ? const Color(0xFF007AFF)
                              : isBloqueado
                                  ? const Color(0xFFC7C7CC)
                                  : const Color(0xFF86868B),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelecionado
                                  ? const Color(0xFF007AFF)
                                  : const Color(0xFF1D1D1F),
                              fontWeight: isSelecionado
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _DepthBadge(label: prof),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _labelSelecionado(String id) {
    final selecionado = analises.firstWhere(
      (a) => a.id == id,
      orElse: () => const _AnaliseOption(id: '', label: ''),
    );
    return selecionado.id.isEmpty ? '1 amostra selecionada' : selecionado.label;
  }
}

class _ContextLabel extends StatelessWidget {
  const _ContextLabel({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF86868B)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF86868B),
          ),
        ),
      ],
    );
  }
}

class _DepthBadge extends StatelessWidget {
  const _DepthBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF86868B),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AnaliseOption {
  const _AnaliseOption({
    required this.id,
    required this.label,
    this.profundidade,
    this.laboratorio,
  });

  final String id;
  final String label;
  final String? profundidade;
  final String? laboratorio;
}
