import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/agronomic_progress_bar.dart';
import 'package:soloforte/core/widgets/nivel_gradiente_bar.dart';
import 'package:soloforte/core/widgets/nutrient_ph_bar_chart.dart';
import 'package:soloforte/core/services/app_observability.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/domain/formulas/classificacao_nivel.dart';
import 'package:soloforte/domain/models/resultado_recomendacao.dart';
import 'package:soloforte/domain/entities/resultado_gesso.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/auth/application/providers/auth_usecase_providers.dart';
import 'package:soloforte/features/laboratorio/domain/entities/laudo_recomendacao.dart';
import 'package:soloforte/features/laboratorio/application/providers/laudo_provider.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
import 'package:soloforte/features/laboratorio/presentation/providers/recomendacao_provider_real.dart';
import 'package:soloforte/features/laboratorio/presentation/recomendacao/recomendacao_header_footer.dart';
import 'package:soloforte/features/laboratorio/services/laudo_pdf_generator.dart';
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
  bool _salvando = false;
  bool _exportando = false;

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
    final request = RecomendacaoRequest(
      analiseId: _analiseIdSelecionada,
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
                  label: 'Gerar Recomendação',
                  icon: Icons.auto_awesome_rounded,
                  onPressed:
                      (analiseSelecionada != null && perfilSelecionado != null)
                          ? () {
                              ref.invalidate(recomendacaoProvider(request));
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
            _buildIdentificacao(resultado),
            const Divider(height: 32, thickness: 0.5, color: Color(0xFFE5E5E7)),

            // BLOCO 2 — Qualidade do Solo
            _buildQualidadeSolo(resultado),
            const Divider(height: 32, thickness: 0.5, color: Color(0xFFE5E5E7)),

            // BLOCO 3 — Correções
            _buildCalcario(resultado),
            _buildGesso(resultado),
            _buildBasesDashboard(resultado),
            const SizedBox(height: 12),
            _buildGraficoAntesDepois(resultado),
            const Divider(height: 32, thickness: 0.5, color: Color(0xFFE5E5E7)),

            // BLOCO 4 — Nutrientes
            _buildFosforo(resultado),
            _buildPotassio(resultado),
            _buildMicros(resultado),
            const Divider(height: 32, thickness: 0.5, color: Color(0xFFE5E5E7)),

            // BLOCO 5 — O Que Comprar
            _buildOQueComprar(resultado),
            const Divider(height: 32, thickness: 0.5, color: Color(0xFFE5E5E7)),

            // BLOCO 6 — Micronutrientes por Aplicação
            _buildMicrosSolo(resultado),
            _buildMicrosFoliar(resultado),

            // Avisos e Argumentos (mantidos no final)
            _buildAvisos(resultado),
            const SizedBox(height: 12),
            _buildArgumentos(resultado),
            const SizedBox(height: 12),
            AppCardSection(
              title: 'Ações',
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      key: const Key('btn_salvar_recomendacao'),
                      label: 'Salvar Recomendação',
                      icon: Icons.save_alt_rounded,
                      isLoading: _salvando,
                      onPressed: (_salvando || _exportando)
                          ? null
                          : () => _salvarResultado(resultado),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButtonSecondary(
                      key: const Key('btn_exportar_pdf'),
                      label: _exportando ? 'Gerando...' : 'Exportar PDF',
                      icon: Icons.picture_as_pdf_outlined,
                      onPressed: (_salvando || _exportando)
                          ? null
                          : () => _exportarPdf(resultado),
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

  Widget _buildQualidadeSolo(ResultadoRecomendacao resultado) {
    final analise = resultado.analise;

    return AppCardSection(
      title: 'QUALIDADE DO SOLO',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gráfico pH ──────────────────────────────────────────
          NutrientPhBarChart(ph: analise.ph),

          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),

          // ── Argila + Classe Textural ────────────────────────────────────
          _buildArgilaCard(
            analise.argila.toDouble(),
            silte: analise.silte,
            areiaTotal: analise.areiaTotal,
          ),

          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),

          // ── Matéria Orgânica ─────────────────────────────────────
          _buildMOCard(analise.mo),

          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),

          // ── Enxofre ──────────────────────────────────────────────
          _buildEnxofreCard(analise.s, s2040: analise.s2040),
        ],
      ),
    );
  }

  Widget _buildBasesDashboard(ResultadoRecomendacao resultado) {
    final a = resultado.analise;
    final ctc = a.ctc > 0 ? a.ctc : 1.0;

    double pct(double val) => (val / ctc * 100).clamp(0.0, 100.0);

    final alPct = pct(a.al);
    final relCaMg = a.mg > 0 ? a.ca / a.mg : 0.0;
    final relCaK = a.k > 0 ? a.ca / a.k : 0.0;
    final relMgK = a.k > 0 ? a.mg / a.k : 0.0;

    Color corV() {
      if (a.vPercent < 40) return const Color(0xFFFF3B30);
      if (a.vPercent < 60) return const Color(0xFFFF9500);
      if (a.vPercent < 80) return const Color(0xFF34C759);
      return const Color(0xFF007AFF);
    }

    Color corAl() {
      if (alPct < 5) return const Color(0xFF34C759);
      if (alPct < 15) return const Color(0xFFFF9500);
      return const Color(0xFFFF3B30);
    }

    return AppCardSection(
      title: 'BASES DO SOLO',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'SOMA DE BASES E ACIDEZ',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF86868B),
                letterSpacing: 0.5,
              ),
            ),
          ),
          _baseRow('Ca', a.ca, pct(a.ca), nutriente: 'ca'),
          _baseRow('Mg', a.mg, pct(a.mg), nutriente: 'mg'),
          _baseRow('K', a.k, pct(a.k), nutriente: 'k'),
          _baseRow('Al', a.al, pct(a.al), nutriente: null, corFixa: const Color(0xFFFF3B30)),
          _baseRow('H+Al', a.hAl, pct(a.hAl), nutriente: null, corFixa: const Color(0xFFFF9500)),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                Expanded(child: _blocoValor('SB', _fmt(a.sb, 2), 'cmolc/dm³', const Color(0xFF34C759))),
                const SizedBox(width: 8),
                Expanded(child: _blocoValor('CTC', _fmt(a.ctc, 2), 'cmolc/dm³', const Color(0xFF007AFF))),
                const SizedBox(width: 8),
                Expanded(child: _blocoValor('V%', '${_fmt(a.vPercent, 0)}%', '', corV())),
                const SizedBox(width: 8),
                Expanded(child: _blocoValor('Al%', '${_fmt(alPct, 0)}%', '', corAl())),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'RELAÇÕES DE BASES',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF86868B),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(child: _relacaoCol('Ca/Mg', relCaMg, '3–5')),
                Expanded(child: _relacaoCol('Ca/K', relCaK, '10–30')),
                Expanded(child: _relacaoCol('Mg/K', relMgK, '3–10')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _baseRow(String nome, double valor, double barPct, {
    String? nutriente,
    Color? corFixa,
  }) {
    String? rotulo;
    if (nutriente != null) {
      rotulo = ClassificacaoNivel.classificar(nutriente: nutriente, valor: valor);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              nome,
              style: const TextStyle(fontSize: 13, color: Color(0xFF86868B)),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              valor.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          if (rotulo != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9500).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFF9500).withValues(alpha: 0.3), width: 0.5),
              ),
              child: Text(
                rotulo,
                style: const TextStyle(fontSize: 10, color: Color(0xFFFF9500), fontWeight: FontWeight.w500),
              ),
            ),
          ] else ...[
            const SizedBox(width: 48),
          ],
          const SizedBox(width: 8),
          Expanded(
            child: corFixa != null
                ? _barraSimples(barPct, corFixa)
                : AgronomicProgressBar(value: barPct),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 34,
            child: Text(
              '${barPct.toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 10, color: Color(0xFF86868B)),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraSimples(double pct, Color cor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: pct / 100.0,
        backgroundColor: const Color(0xFFE5E5E7),
        valueColor: AlwaysStoppedAnimation<Color>(cor),
        minHeight: 8,
      ),
    );
  }

  Widget _blocoValor(String label, String valor, String unidade, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cor.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cor)),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cor),
          ),
          if (unidade.isNotEmpty)
            Text(
              unidade,
              style: const TextStyle(fontSize: 8, color: Color(0xFF86868B)),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _relacaoCol(String label, double valor, String faixa) {
    Color cor = const Color(0xFF86868B);
    if (label == 'Ca/Mg') {
      if (valor >= 3 && valor <= 5) {
        cor = const Color(0xFF34C759);
      } else if (valor < 3) {
        cor = const Color(0xFFFF9500);
      } else {
        cor = const Color(0xFFFF3B30);
      }
    } else if (label == 'Ca/K') {
      if (valor >= 10 && valor <= 30) {
        cor = const Color(0xFF34C759);
      } else if (valor < 10) {
        cor = const Color(0xFFFF9500);
      } else {
        cor = const Color(0xFFFF3B30);
      }
    } else if (label == 'Mg/K') {
      if (valor >= 3 && valor <= 10) {
        cor = const Color(0xFF34C759);
      } else if (valor < 3) {
        cor = const Color(0xFFFF9500);
      } else {
        cor = const Color(0xFFFF3B30);
      }
    }

    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF86868B))),
        const SizedBox(height: 4),
        Text(
          valor.toStringAsFixed(1),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cor),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          height: 3,
          width: 40,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 2),
        Text(faixa, style: const TextStyle(fontSize: 9, color: Color(0xFFC7C7CC))),
      ],
    );
  }

  Widget _miniBloco(String label, String valor, Color cor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF86868B))),
        const SizedBox(height: 2),
        Text(
          valor,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildComparativoVPercent(ResultadoRecomendacao resultado) {
    final vAtual = resultado.analise.vPercent;
    final vDepois = resultado.vEsperado;
    const maxV = 100.0;

    return AppCardSection(
      title: 'SATURAÇÃO POR BASES — ANTES E DEPOIS',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _barraComparativa(
              label: 'Antes',
              valor: vAtual,
              maxV: maxV,
              cor: const Color(0xFFFF3B30),
            ),
            _barraComparativa(
              label: 'Depois',
              valor: vDepois,
              maxV: maxV,
              cor: const Color(0xFF007AFF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barraComparativa({
    required String label,
    required double valor,
    required double maxV,
    required Color cor,
  }) {
    final proporcao = (valor / maxV).clamp(0.0, 1.0);
    const alturaMax = 80.0;
    return Column(
      children: [
        Text(
          '${valor.toStringAsFixed(1)}%',
          style: AppTextStyles.value.copyWith(color: cor),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 48,
          height: alturaMax * proporcao,
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildGraficoAntesDepois(ResultadoRecomendacao resultado) {
    final analise = resultado.analise;

    final grupos = [
      _GrupoBar('Ca', analise.ca, resultado.caEsperado, 'cmolc'),
      _GrupoBar('Mg', analise.mg, resultado.mgEsperado, 'cmolc'),
      _GrupoBar('K', analise.k, analise.k, 'cmolc'),
      _GrupoBar('V%', analise.vPercent, resultado.vEsperado, '%'),
    ];

    return AppCardSection(
      title: 'ANTES E DEPOIS DA CORREÇÃO',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendaPill('Antes', const Color(0xFF34C759)),
                const SizedBox(width: 16),
                _legendaPill('Depois', const Color(0xFF007AFF)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: grupos.map((g) => _buildGrupoBarras(g)).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: grupos
                  .map(
                    (g) => SizedBox(
                      width: 56,
                      child: Text(
                        g.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF86868B),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            const Text(
              '* K sem alteração — recomendação de K calculada separadamente',
              style: TextStyle(fontSize: 10, color: Color(0xFFC7C7CC)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrupoBarras(_GrupoBar g) {
    const alturaMax = 150.0;
    const larguraBarra = 22.0;

    final maxVal = [g.antes, g.depois, 0.001].reduce((a, b) => a > b ? a : b);
    final propAntes = (g.antes / maxVal).clamp(0.0, 1.0);
    final propDepois = (g.depois / maxVal).clamp(0.0, 1.0);

    final corAntes = g.antes < g.depois
        ? const Color(0xFFFF3B30).withValues(alpha: 0.75)
        : const Color(0xFF34C759).withValues(alpha: 0.85);
    const corDepois = Color(0xFF007AFF);

    Widget barra(double proporcao, Color cor, double valor, String unidade) {
      final altura = (alturaMax * proporcao).clamp(4.0, alturaMax);
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            _fmtBar(valor, unidade),
            style: const TextStyle(fontSize: 9, color: Color(0xFF1D1D1F)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: larguraBarra,
            height: altura,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: 56,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          barra(propAntes, corAntes, g.antes, g.unidade),
          const SizedBox(width: 3),
          barra(propDepois, corDepois, g.depois, g.unidade),
        ],
      ),
    );
  }

  Widget _legendaPill(String label, Color cor) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF86868B))),
      ],
    );
  }

  String _fmtBar(double v, String unidade) {
    if (unidade == '%') return '${v.toStringAsFixed(0)}%';
    return v.toStringAsFixed(1);
  }

  Widget _buildOQueComprar(ResultadoRecomendacao resultado) {
    final itens = <Map<String, String>>[];

    final calcario = resultado.doseCalcarioTHa;
    if (calcario > 0) {
      itens.add({
        'nome': 'Calcário',
        'dose': '${calcario.toStringAsFixed(2)} t/ha',
        'icone': '🪨'
      });
    }

    final gessoDose = resultado.gesso.doseKgHa;
    if (gessoDose > 0) {
      itens.add({
        'nome': 'Gesso Agrícola',
        'dose': '${gessoDose.toStringAsFixed(0)} kg/ha',
        'icone': '🔵'
      });
    }

    final fosforo = resultado.doseP2O5KgHa;
    if (fosforo > 0) {
      itens.add({
        'nome': 'Fertilizante Fosfatado',
        'dose': '${fosforo.toStringAsFixed(1)} kg P₂O₅/ha',
        'icone': '🟠'
      });
    }

    final potassio = resultado.doseK2OKgHa;
    if (potassio > 0) {
      itens.add({
        'nome': 'Fertilizante Potássico',
        'dose': '${potassio.toStringAsFixed(1)} kg K₂O/ha',
        'icone': '🟡'
      });
    }

    return AppCardSection(
      title: 'O QUE COMPRAR',
      child: itens.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nenhuma correção necessária.',
                style: TextStyle(color: Color(0xFF86868B), fontSize: 14),
              ),
            )
          : Column(
              children: List.generate(itens.length * 2 - 1, (i) {
                if (i.isOdd) {
                  return const Divider(
                      height: 1, thickness: 0.5, color: Color(0xFFE5E5E7));
                }
                final item = itens[i ~/ 2];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(item['icone']!, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(item['nome']!, style: AppTextStyles.label),
                      ),
                      Text(item['dose']!, style: AppTextStyles.value),
                    ],
                  ),
                );
              }),
            ),
    );
  }

  Widget _buildMicrosSolo(ResultadoRecomendacao resultado) {
    return _buildMicrosAgrupados(
      resultado: resultado,
      titulo: 'MICRONUTRIENTES — APLICAÇÃO NO SOLO',
      filtroVia: const ['Solo', 'Ambas'],
      campoExtra: (m) => 'Produto: ${m?.doseProdutoLabel ?? '-'}',
    );
  }

  Widget _buildMicrosFoliar(ResultadoRecomendacao resultado) {
    return _buildMicrosAgrupados(
      resultado: resultado,
      titulo: 'MICRONUTRIENTES — APLICAÇÃO FOLIAR',
      filtroVia: const ['Foliar', 'Ambas'],
      campoExtra: (m) => 'Produto: ${m?.doseProdutoLabel ?? '-'}',
    );
  }

  Widget _buildMicrosAgrupados({
    required ResultadoRecomendacao resultado,
    required String titulo,
    required List<String> filtroVia,
    required String? Function(dynamic) campoExtra,
  }) {
    final micros = resultado.micros
        .where((m) {
          final via = m.via;
          return filtroVia.any((f) => via.contains(f));
        })
        .toList();

    if (micros.isEmpty) return const SizedBox.shrink();

    return AppCardSection(
      title: titulo,
      child: Column(
        children: micros.asMap().entries.map((entry) {
          final i = entry.key;
          final m = entry.value;
          final nome = m.elemento;
          final teor = m.valorAtual;
          final extra = campoExtra(m);

          return Column(
            children: [
              if (i > 0)
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(nome, style: AppTextStyles.label),
                        const Spacer(),
                        Text(
                          '${teor.toStringAsFixed(2)} mg/dm³',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    if (extra != null) ...[
                      const SizedBox(height: 4),
                      Text(extra, style: AppTextStyles.caption),
                    ],
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalcario(ResultadoRecomendacao resultado) {
    final corretivos = (resultado.calibracao.parametrosCards['corretivos']
            as Map<String, dynamic>?) ?? {};
    Map<String, dynamic> asMap(dynamic v) => v is Map<String, dynamic> ? v : {};
    num asNum(dynamic v, [num fb = 0]) => v is num ? v : fb;
    bool asBool(dynamic v) => v is bool ? v : false;
    String asStr(dynamic v, [String fb = '']) => v is String ? v : fb;

    final tipoCalcario = asStr(corretivos['tipoCalcario'], 'Dolomítico');
    final calcario1 = asMap(corretivos['calcario1']);
    final calcario2 = asMap(corretivos['calcario2']);
    final usarC2 = asBool(corretivos['usarSegundoCalcario']);
    final prop1 = asNum(corretivos['proporcaoCalcario1'], 50).toDouble();
    final prop2 = (100.0 - prop1).clamp(0.0, 100.0);
    final prnt1 = asNum(calcario1['prnt'], 80).toDouble();
    final caO1 = asNum(calcario1['caO'], 30).toDouble();
    final mgO1 = asNum(calcario1['mgO'], 16).toDouble();
    final prnt2 = asNum(calcario2['prnt'], 75).toDouble();
    final caO2 = asNum(calcario2['caO'], 42).toDouble();
    final mgO2 = asNum(calcario2['mgO'], 3).toDouble();
    final dose = resultado.doseCalcarioTHa;
    final temDose = dose > 0;
    final analise = resultado.analise;

    String iconeCalcario(String tipo) {
      switch (tipo) {
        case 'Calcítico':
          return '🟡';
        case 'Magnesiano':
          return '🟣';
        default:
          return '🪨';
      }
    }

    return AppCardSection(
      title: 'CALCÁRIO',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Badge(
                  icon: Icons.science_outlined,
                  color: AppColors.primary,
                  label: resultado.metodoCalagem,
                ),
                _Badge(
                  icon: Icons.grain,
                  color: const Color(0xFF86868B),
                  label: '${iconeCalcario(tipoCalcario)} $tipoCalcario',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  temDose ? dose.toStringAsFixed(2) : '—',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: temDose ? AppColors.primary : const Color(0xFF86868B),
                  ),
                ),
                if (temDose) ...[
                  const SizedBox(width: 6),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text('t/ha',
                        style: TextStyle(fontSize: 15, color: Color(0xFF86868B))),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(child: _miniBloco('V% Atual', '${_fmt(analise.vPercent, 0)}%', const Color(0xFFFF3B30))),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFC7C7CC)),
                ),
                Expanded(child: _miniBloco('V% Esperado', '${_fmt(resultado.vEsperado, 0)}%', const Color(0xFF34C759))),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
          _infoRow('Ca', '${_fmt(analise.ca, 2)} → ${_fmt(resultado.caEsperado, 2)} cmolc/dm³'),
          _infoRow('Mg', '${_fmt(analise.mg, 2)} → ${_fmt(resultado.mgEsperado, 2)} cmolc/dm³'),
          _infoRow('Rel. Ca:Mg', '${_fmt(resultado.relacaoCaMg, 1)}:1'),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Text(
              usarC2 ? 'Calcário 1 — ${prop1.toStringAsFixed(0)}%' : 'Calcário',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF86868B),
                letterSpacing: 0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Expanded(child: _miniBloco('CaO', '${caO1.toStringAsFixed(0)}%', const Color(0xFF007AFF))),
                Expanded(child: _miniBloco('MgO', '${mgO1.toStringAsFixed(0)}%', const Color(0xFF34C759))),
                Expanded(child: _miniBloco('PRNT', '${prnt1.toStringAsFixed(0)}%', const Color(0xFF86868B))),
              ],
            ),
          ),
          if (usarC2) ...[
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Text(
                'Calcário 2 — ${prop2.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF86868B),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  Expanded(child: _miniBloco('CaO', '${caO2.toStringAsFixed(0)}%', const Color(0xFF007AFF))),
                  Expanded(child: _miniBloco('MgO', '${mgO2.toStringAsFixed(0)}%', const Color(0xFF34C759))),
                  Expanded(child: _miniBloco('PRNT', '${prnt2.toStringAsFixed(0)}%', const Color(0xFF86868B))),
                ],
              ),
            ),
          ],
          if (resultado.parcelamento.isNotEmpty) ...[
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Parcelamento', style: TextStyle(fontSize: 11, color: Color(0xFF86868B))),
                  const SizedBox(height: 4),
                  ...resultado.parcelamento.map(
                    (item) => Text('• $item', style: AppTextStyles.caption),
                  ),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildGesso(ResultadoRecomendacao resultado) {
    final g = resultado.gesso;

    return AppCardSection(
      title: 'GESSO AGRÍCOLA',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Badge(
                  icon: Icons.layers_outlined,
                  color: AppColors.primary,
                  label: g.metodo.nome,
                ),
                _Badge(
                  icon: g.indicado ? Icons.check_circle_outline : Icons.info_outline,
                  color: g.indicado ? AppColors.success : AppColors.textSecond,
                  label: g.indicado ? '🟡 Gessagem indicada' : '✅ Não indicada',
                ),
              ],
            ),
          ),
          if (g.indicado) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _fmt(g.doseKgHa, 0),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF007AFF),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text('kg/ha', style: TextStyle(fontSize: 15, color: Color(0xFF86868B))),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(child: _miniBloco('S fornecido', '${_fmt(g.sFornecidoKgHa, 1)} kg/ha', const Color(0xFFFF9500))),
                  Expanded(child: _miniBloco('Ca fornecido', '${_fmt(g.caFornecidoKgHa, 1)} kg/ha', const Color(0xFF007AFF))),
                  Expanded(child: _miniBloco('Ca +cmolc', '+${_fmt(g.caAumentoCmolcDm3, 2)}', const Color(0xFF34C759))),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 8),
          if (g.observacoes.isNotEmpty) ...[
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: g.observacoes
                    .map((obs) => Text('• $obs', style: AppTextStyles.caption))
                    .toList(),
              ),
            ),
          ] else
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFosforo(ResultadoRecomendacao resultado) {
    final analise = resultado.analise;
    final p = analise.p;
    final argila = analise.argila;
    final nc = resultado.ncFosforo;
    final dose = resultado.doseP2O5KgHa;
    final temDose = dose > 0;
    final pRelNC = nc > 0 ? (p / nc * 100).clamp(0.0, 150.0) : 0.0;
    final acimaNc = p >= nc;
    final rotulo = ClassificacaoNivel.classificar(
      nutriente: 'p',
      valor: p,
      argila: argila,
    );

    final temMehlich = analise.pMehlich != null && analise.pMehlich! > 0;
    final temResina = analise.pResina != null && analise.pResina! > 0;
    final temPRem = analise.pRem != null;

    // NC por extrator — usar ncFosforo como referência base
    final ncMehlich = nc;
    final ncResina = nc * 0.88; // proporção empírica Resina ≈ 88% do Mehlich

    Color corP(double pVal, double ncVal) {
      final rel = ncVal > 0 ? (pVal / ncVal * 100) : 0.0;
      if (rel < 40) return const Color(0xFFFF3B30);
      if (rel < 70) return const Color(0xFFFF9500);
      if (rel < 100) return const Color(0xFFFFCC00);
      return const Color(0xFF34C759);
    }

    final corPrincipal = corP(p, nc);

    return AppCardSection(
      title: 'FÓSFORO',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── P principal em destaque ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  p.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: corPrincipal,
                  ),
                ),
                const SizedBox(width: 6),
                const Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text('mg/dm³',
                      style: TextStyle(fontSize: 13, color: Color(0xFF86868B))),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: corPrincipal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: corPrincipal.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    rotulo,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: corPrincipal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Barra principal ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: NivelGradienteBar(
              valor: p,
              min: NivelEscala.escala('p', argila: argila).$1,
              max: NivelEscala.escala('p', argila: argila).$2,
              rotulo: rotulo,
            ),
          ),
          // ── NC + % do NC ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Row(
              children: [
                Text(
                  'NC: ${nc.toStringAsFixed(2)} mg/dm³',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF86868B)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: acimaNc
                        ? const Color(0xFF34C759).withValues(alpha: 0.12)
                        : const Color(0xFFFF9500).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${pRelNC.toStringAsFixed(0)}% do NC',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: acimaNc
                          ? const Color(0xFF34C759)
                          : const Color(0xFFFF9500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Extratores (quando disponíveis) ─────────────────────
          if (temMehlich || temResina) ...[
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'EXTRATORES',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF86868B),
                    letterSpacing: 0.5),
              ),
            ),
            if (temMehlich)
              _buildExtratorRow(
                label: 'P Mehlich',
                valor: analise.pMehlich!,
                nc: ncMehlich,
                argila: argila,
                cor: corP(analise.pMehlich!, ncMehlich),
              ),
            if (temResina)
              _buildExtratorRow(
                label: 'P Resina',
                valor: analise.pResina!,
                nc: ncResina,
                argila: argila,
                cor: corP(analise.pResina!, ncResina),
              ),
            if (temPRem)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    const Text('P-rem',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF86868B))),
                    const SizedBox(width: 8),
                    Text(
                      '${analise.pRem!.toStringAsFixed(1)} mg/L',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D1D1F)),
                    ),
                  ],
                ),
              ),
          ],
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
          // ── Modo ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
            child: Text(
              resultado.modoFosforo,
              style: const TextStyle(fontSize: 11, color: Color(0xFF86868B)),
            ),
          ),
          // ── Dose P₂O₅ ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  temDose ? dose.toStringAsFixed(1) : '—',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color:
                        temDose ? AppColors.fosforo : const Color(0xFF86868B),
                  ),
                ),
                if (temDose) ...[
                  const SizedBox(width: 6),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text('kg P₂O₅/ha',
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF86868B))),
                  ),
                ],
              ],
            ),
          ),
          // ── Mini-blocos ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: _miniBloco(
                    'P Solo',
                    '${p.toStringAsFixed(1)} mg',
                    corPrincipal,
                  ),
                ),
                Expanded(
                  child: _miniBloco(
                    'P NC',
                    '${nc.toStringAsFixed(1)} mg',
                    const Color(0xFF86868B),
                  ),
                ),
                Expanded(
                  child: _miniBloco(
                    'Absorção',
                    resultado.doseAbsorcaoP != null
                        ? '${resultado.doseAbsorcaoP!.toStringAsFixed(1)} kg'
                        : '—',
                    resultado.doseAbsorcaoP != null
                        ? const Color(0xFF007AFF)
                        : const Color(0xFFC7C7CC),
                  ),
                ),
              ],
            ),
          ),
          // ── Legacy badge ─────────────────────────────────────────
          if (resultado.legacyP) ...[
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: _Badge(
                icon: Icons.info_outline,
                color: AppColors.warning,
                label: 'Solo acima do NC — dose mínima de manutenção aplicada.',
              ),
            ),
          ] else
            const SizedBox(height: 4),
        ],
      ),
    );
  }

  /// Linha de extrator: label | valor | barra | NC
  Widget _buildExtratorRow({
    required String label,
    required double valor,
    required double nc,
    required double argila,
    required Color cor,
  }) {
    final rotulo = ClassificacaoNivel.classificar(
      nutriente: 'p',
      valor: valor,
      argila: argila,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1D1D1F))),
              ),
              Text('${valor.toStringAsFixed(1)} mg/dm³',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cor)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(rotulo,
                    style: TextStyle(
                        fontSize: 10,
                        color: cor,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          NivelGradienteBar(
            valor: valor,
            min: NivelEscala.escala('p', argila: argila).$1,
            max: NivelEscala.escala('p', argila: argila).$2,
            rotulo: rotulo,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 4),
            child: Text('NC: ${nc.toStringAsFixed(2)} mg/dm³',
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFFC7C7CC))),
          ),
        ],
      ),
    );
  }

  Widget _buildPotassio(ResultadoRecomendacao resultado) {
    final analise = resultado.analise;
    final k = analise.k;
    final kMg = k * 391.0;
    final nc = resultado.ncPotassio;
    final ncMg = nc * 391.0;
    final dose = resultado.doseK2OKgHa;
    final temDose = dose > 0;
    final rotulo = ClassificacaoNivel.classificar(nutriente: 'k', valor: k);
    final kPct = resultado.relacoesK.kNaCTC;

    Color corKPct() {
      if (kPct < 2) return const Color(0xFFFF3B30);
      if (kPct < 4) return const Color(0xFFFF9500);
      if (kPct < 6) return const Color(0xFF34C759);
      return const Color(0xFF007AFF);
    }

    return AppCardSection(
      title: 'POTÁSSIO',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      k.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.potassio,
                      ),
                    ),
                    const Text(
                      'cmolc/dm³',
                      style: TextStyle(fontSize: 11, color: Color(0xFF86868B)),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kMg.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                    const Text(
                      'mg/dm³',
                      style: TextStyle(fontSize: 11, color: Color(0xFF86868B)),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.potassio.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.potassio.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    rotulo,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.potassio,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: NivelGradienteBar(
              valor: k,
              min: NivelEscala.escala('k').$1,
              max: NivelEscala.escala('k').$2,
              rotulo: rotulo,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Text(
              'NC: ${nc.toStringAsFixed(2)} cmolc/dm³  ·  ${ncMg.toStringAsFixed(0)} mg/dm³',
              style: const TextStyle(fontSize: 11, color: Color(0xFF86868B)),
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  temDose ? dose.toStringAsFixed(1) : '—',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: temDose ? AppColors.potassio : const Color(0xFF86868B),
                  ),
                ),
                if (temDose) ...[
                  const SizedBox(width: 6),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text('kg K₂O/ha',
                        style: TextStyle(fontSize: 13, color: Color(0xFF86868B))),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              resultado.criterioPotassio,
              style: const TextStyle(fontSize: 12, color: Color(0xFF86868B)),
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: _miniBloco(
                    'K% CTC',
                    '${kPct.toStringAsFixed(1)}%',
                    corKPct(),
                  ),
                ),
                Expanded(
                  child: _miniBloco(
                    'K:Mg',
                    resultado.relacoesK.relKMg.toStringAsFixed(2),
                    const Color(0xFF86868B),
                  ),
                ),
                Expanded(
                  child: _miniBloco(
                    'K:Ca',
                    resultado.relacoesK.relKCa.toStringAsFixed(2),
                    const Color(0xFF86868B),
                  ),
                ),
              ],
            ),
          ),
          if (resultado.relacoesK.alertas.isNotEmpty) ...[
            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: resultado.relacoesK.alertas.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _Badge(
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      label: item,
                    ),
                  ),
                ).toList(),
              ),
            ),
          ] else
            const SizedBox(height: 4),
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

  _AnaliseOption _toAnaliseOption(AnaliseSolo analise) {
    final label =
        '${analise.talhao} · ${analise.laboratorio} · ${DateFormat('dd/MM/yyyy').format(analise.dataCadastro)}';
    return _AnaliseOption(
      id: analise.id,
      label: label,
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
      final uid = ref.read(getCurrentUserIdUsecaseProvider)() ?? '';
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
      final uid = ref.read(getCurrentUserIdUsecaseProvider)() ?? '';
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

  Widget _buildEnxofreCard(double s, {double? s2040}) {
    final barPercent = (s / 30.0 * 100).clamp(0.0, 100.0);
    final rotulo = ClassificacaoNivel.classificar(nutriente: 's', valor: s);

    Widget buildCamada({
      required String profundidade,
      required double valor,
      required double barPct,
      required String rotuloCamada,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  'Enxofre (S) · $profundidade',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF86868B)),
                ),
                const Spacer(),
                Text(
                  '${valor.toStringAsFixed(1)} mg/dm³',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: AgronomicProgressBar(value: barPct),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Text(
              rotuloCamada,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Camada 0–20 cm (sempre presente)
        buildCamada(
          profundidade: '0–20 cm',
          valor: s,
          barPct: barPercent,
          rotuloCamada: rotulo,
        ),

        // Divisor entre camadas
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 1, color: Color(0xFFE5E5E7)),
        ),

        // Camada 20–40 cm (condicional)
        if (s2040 != null)
          buildCamada(
            profundidade: '20–40 cm',
            valor: s2040,
            barPct: (s2040 / 30.0 * 100).clamp(0.0, 100.0),
            rotuloCamada: ClassificacaoNivel.classificar(nutriente: 's', valor: s2040),
          )
        else
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              '⚠️ Camada 20–40 cm não disponível nesta análise',
              style: TextStyle(fontSize: 11, color: Color(0xFFC7C7CC)),
            ),
          ),
      ],
    );
  }

  Widget _buildArgilaCard(double argila, {double? silte, double? areiaTotal}) {
    // Converter g/kg → %
    final argilaPct = argila / 10.0;
    final siltePct = silte != null ? silte / 10.0 : null;
    final areiaPct = areiaTotal != null ? areiaTotal / 10.0 : null;

    // Calcular areia por diferença se silte existir mas areia não
    final areiaPctFinal = areiaPct ??
        (siltePct != null ? (100.0 - argilaPct - siltePct).clamp(0.0, 100.0) : null);

    // Classe textural (EMBRAPA — por % argila)
    String classeTextural;
    if (argilaPct < 15) {
      classeTextural = 'Arenosa';
    } else if (argilaPct < 35) {
      classeTextural = 'Franco-Arenosa';
    } else if (argilaPct < 60) {
      classeTextural = 'Franco-Argilosa';
    } else {
      classeTextural = 'Argilosa';
    }

    // Barra: escala 0–100% de argila
    final barPercent = argilaPct.clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Linha principal: label + valor em %
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              const Text(
                'Argila',
                style: TextStyle(fontSize: 14, color: Color(0xFF86868B)),
              ),
              const Spacer(),
              Text(
                '${argilaPct.toStringAsFixed(1)} %  ·  ${argila.toStringAsFixed(0)} g/kg',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
        ),

        // Barra agronômica
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: AgronomicProgressBar(value: barPercent),
        ),

        // Classe textural
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            classeTextural,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D1D1F),
            ),
          ),
        ),

        // Areia e Silte — exibe se disponíveis, caso contrário nota discreta
        if (siltePct != null || areiaPctFinal != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                if (areiaPctFinal != null)
                  _texturaPill('Areia', areiaPctFinal, const Color(0xFFF5A623)),
                if (areiaPctFinal != null && siltePct != null)
                  const SizedBox(width: 8),
                if (siltePct != null)
                  _texturaPill('Silte', siltePct, const Color(0xFF5AC8FA)),
                const SizedBox(width: 8),
                _texturaPill('Argila', argilaPct, const Color(0xFF34C759)),
              ],
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              '· Areia e Silte não disponíveis nesta análise',
              style: TextStyle(fontSize: 11, color: Color(0xFFC7C7CC)),
            ),
          ),
      ],
    );
  }

  Widget _texturaPill(String label, double pct, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        '$label ${pct.toStringAsFixed(1)}%',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: cor.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildMOCard(double mo) {
    // Cálculos agronômicos
    final carbono = mo / 1.724;           // Van Bemmelen
    final nitrogenio = mo * 1.0;          // Fancelli/ESALQ (t/ha estimada)

    // Percentual relativo para a barra (escala 0–50 g/dm³ → 0–100%)
    final barPercent = (mo / 50.0 * 100).clamp(0.0, 100.0);

    // Classificação textual
    final rotulo = ClassificacaoNivel.classificar(nutriente: 'mo', valor: mo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              const Text(
                'Matéria Orgânica',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF86868B),
                ),
              ),
              const Spacer(),
              Text(
                '${mo.toStringAsFixed(1)} g/dm³',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
        ),

        // Barra agronômica
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: AgronomicProgressBar(value: barPercent),
        ),

        // Label de classificação
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Text(
            rotulo,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF86868B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Box de dados derivados
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E5E7), width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carbono
                Row(
                  children: [
                    const Text(
                      'Carbono (C)',
                      style: TextStyle(fontSize: 13, color: Color(0xFF1D1D1F)),
                    ),
                    const Spacer(),
                    Text(
                      '${carbono.toStringAsFixed(2)} %',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),
                const SizedBox(height: 6),
                // Nitrogênio estimado
                Row(
                  children: [
                    const Text(
                      'N estimado (Fancelli)',
                      style: TextStyle(fontSize: 13, color: Color(0xFF1D1D1F)),
                    ),
                    const Spacer(),
                    Text(
                      '${nitrogenio.toStringAsFixed(2)} t/ha',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
  });

  final String id;
  final String label;
}

class _GrupoBar {
  const _GrupoBar(this.label, this.antes, this.depois, this.unidade);

  final String label;
  final double antes;
  final double depois;
  final String unidade;
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
