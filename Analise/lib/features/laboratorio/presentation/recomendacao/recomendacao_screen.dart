import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/nivel_gradiente_bar.dart';
import 'package:soloforte/core/services/app_observability.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/domain/formulas/classificacao_nivel.dart';
import 'package:soloforte/domain/models/resultado_recomendacao.dart';
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
            _buildComparativoVPercent(resultado),
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
    final ph = analise.ph;
    final mo = analise.mo;
    final s = analise.s;
    final argila = analise.argila;

    return AppCardSection(
      title: 'QUALIDADE DO SOLO',
      child: Column(
        children: [
          // pH
          AppCardRow(
            label: 'pH (CaCl₂)',
            value: ph.toStringAsFixed(1),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: NivelGradienteBar(
              valor: ph,
              min: 4.0,
              max: 7.5,
              rotulo: ClassificacaoNivel.classificar(
                nutriente: 'ph',
                valor: ph,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),

          // Argila
          AppCardRow(
            label: 'Argila',
            value: '${argila.toStringAsFixed(0)} g/kg',
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),

          // Matéria Orgânica
          AppCardRow(
            label: 'Matéria Orgânica',
            value: '${mo.toStringAsFixed(1)} g/dm³',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: NivelGradienteBar(
              valor: mo,
              min: 0.0,
              max: 50.0,
              rotulo: ClassificacaoNivel.classificar(
                nutriente: 'mo',
                valor: mo,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5E7)),

          // Enxofre
          AppCardRow(
            label: 'Enxofre (S)',
            value: '${s.toStringAsFixed(1)} mg/dm³',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: NivelGradienteBar(
              valor: s,
              min: 0.0,
              max: 30.0,
              rotulo: ClassificacaoNivel.classificar(
                nutriente: 's',
                valor: s,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: NivelGradienteBar(
              valor: resultado.analise.p,
              min: NivelEscala.escala('p', argila: resultado.analise.argila).$1,
              max: NivelEscala.escala('p', argila: resultado.analise.argila).$2,
              rotulo: ClassificacaoNivel.classificar(
                nutriente: 'p',
                valor: resultado.analise.p,
                argila: resultado.analise.argila,
              ),
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: NivelGradienteBar(
              valor: resultado.analise.k,
              min: NivelEscala.escala('k').$1,
              max: NivelEscala.escala('k').$2,
              rotulo: ClassificacaoNivel.classificar(
                nutriente: 'k',
                valor: resultado.analise.k,
              ),
            ),
          ),
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

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
