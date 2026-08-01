import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/domain/usecases/calcular_fosforo_calculos_usecase.dart';
import 'package:soloforte/domain/usecases/calcular_gesso_calculos_usecase.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/domain/usecases/calcular_calagem_calculos_usecase.dart';
import 'package:soloforte/features/config/presentation/calculos/calculos_provider.dart';
import 'package:soloforte/features/config/presentation/calculos/widgets/tabela_analises_widget.dart';

class CalculosPage extends ConsumerStatefulWidget {
  const CalculosPage({super.key});

  @override
  ConsumerState<CalculosPage> createState() => _CalculosPageState();
}

class _CalculosPageState extends ConsumerState<CalculosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ids = ref.read(calculosSelectedAnaliseIdsProvider);
      final calibracaoId = ref.read(calculosSelectedCalibracaoIdProvider);
      ref.read(calculosProvider.notifier).carregarDados(ids, calibracaoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculosProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.chevron_back,
            size: 18,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Cálculos',
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CalculosState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    if (state.erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                state.erro!,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecond,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (state.analises.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.science_outlined,
                size: 48,
                color: AppColors.textSecond,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma análise selecionada.\nSelecione análises na tela de Recomendação.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecond,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      child: ListView(
        children: [
          Text(
            'Tabela de análises',
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${state.analises.length} amostra(s) selecionada(s) e média simples na primeira coluna.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecond,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 420,
            child: TabelaAnalisesWidget(
              media: state.media,
              analises: state.analises,
            ),
          ),
          const SizedBox(height: 20),
          _CalagemSection(
            calibracaoNome: state.calibracao?.nome,
            resultado: state.resultadoCalagem,
          ),
          const SizedBox(height: 16),
          _GessoSection(
            calibracaoNome: state.calibracao?.nome,
            resultado: state.resultadoGesso,
          ),
          const SizedBox(height: 16),
          _FosforoSection(
            calibracaoNome: state.calibracao?.nome,
            resultado: state.resultadoFosforo,
          ),
        ],
      ),
    );
  }
}

class _CalagemSection extends StatelessWidget {
  const _CalagemSection({
    required this.calibracaoNome,
    required this.resultado,
  });

  final String? calibracaoNome;
  final CalculoCalagemResultado? resultado;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      borderRadius: AppDimens.radiusLg,
      showBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cálculo de Calagem',
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            calibracaoNome == null || calibracaoNome!.trim().isEmpty
                ? 'Selecione e gere uma calibração na tela de Recomendação para calcular o calcário.'
                : 'Calibração ativa: $calibracaoNome',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecond,
            ),
          ),
          if (resultado != null) ...[
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  resultado!.doseFinalTHa.toStringAsFixed(2),
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 36,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    't/ha',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecond,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _InfoLine(label: 'Método', value: resultado!.metodo),
            _InfoLine(label: 'Referência', value: resultado!.referencia),
            _InfoLine(
                label: 'Tipo de calcário', value: resultado!.tipoCalcario),
            _InfoLine(
              label: 'NC base',
              value: '${resultado!.ncBase.toStringAsFixed(2)} t/ha',
            ),
            _InfoLine(
              label: 'PRNT aplicado',
              value: '${resultado!.prnt.toStringAsFixed(1)}%',
            ),
            _InfoLine(
              label: 'Profundidade',
              value:
                  '${resultado!.profundidadeCm.toStringAsFixed(1)} cm · p ${resultado!.fatorProfundidade.toStringAsFixed(2)}',
            ),
            _InfoLine(
              label: 'Superfície de contato',
              value: resultado!.superficieContato.toStringAsFixed(2),
            ),
            _InfoLine(
              label: 'V% atual',
              value: '${resultado!.vAtual.toStringAsFixed(1)}%',
            ),
            if (resultado!.vAlvo != null)
              _InfoLine(
                label: 'V% alvo',
                value: '${resultado!.vAlvo!.toStringAsFixed(1)}%',
              ),
            if (resultado!.y != null)
              _InfoLine(
                label: 'Y',
                value: resultado!.y!.toStringAsFixed(2),
              ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                resultado!.resumoCalculo,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecond,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FosforoCalibracaoResumo extends StatelessWidget {
  const _FosforoCalibracaoResumo({required this.resultado});

  final CalculoFosforoResultado resultado;

  @override
  Widget build(BuildContext context) {
    final usaAbsorcao = resultado.tipoDadoAbsorcao != 'Nenhum';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados da calibração',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecond,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _InfoLine(label: 'Modo', value: resultado.modo),
          _InfoLine(label: 'Referência P', value: resultado.referencia),
          _InfoLine(
            label: 'NC / FEP',
            value:
                '${resultado.nc.toStringAsFixed(1)} mg/dm³ · ${resultado.fep.toStringAsFixed(1)}%',
          ),
          if (usaAbsorcao) ...[
            _InfoLine(
              label: 'Absorção',
              value:
                  '${resultado.tipoFonteAbsorcao} · ${resultado.fonteAbsorcao}',
            ),
            _InfoLine(
              label: 'Tipo de dado',
              value: resultado.tipoDadoAbsorcao,
            ),
            if (resultado.produtividadeEsperadaTha != null)
              _InfoLine(
                label: 'Produtividade',
                value:
                    '${resultado.produtividadeEsperadaTha!.toStringAsFixed(2)} t/ha',
              ),
            if (resultado.referenciaAbsorcaoKgPorT != null)
              _InfoLine(
                label: 'Referência',
                value:
                    '${resultado.referenciaAbsorcaoKgPorT!.toStringAsFixed(2)} kg/t P · ${resultado.qualidadeReferenciaAbsorcao}',
              ),
            if (resultado.percentualUsoSolo > 0)
              _InfoLine(
                label: '% P solo',
                value: '${resultado.percentualUsoSolo.toStringAsFixed(0)}%',
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecond,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GessoSection extends StatelessWidget {
  const _GessoSection({
    required this.calibracaoNome,
    required this.resultado,
  });

  final String? calibracaoNome;
  final CalculoGessoResultado? resultado;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      borderRadius: AppDimens.radiusLg,
      showBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cálculo de Gesso',
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            calibracaoNome == null || calibracaoNome!.trim().isEmpty
                ? 'Selecione e gere uma calibração na tela de Recomendação para calcular o gesso.'
                : 'Calibração ativa: $calibracaoNome',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecond,
            ),
          ),
          if (resultado != null) ...[
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  resultado!.resultado.doseTHa.toStringAsFixed(2),
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 36,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    't/ha',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecond,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _InfoLine(label: 'Método', value: resultado!.metodo),
            _InfoLine(label: 'Referência', value: resultado!.referencia),
            _InfoLine(
              label: 'Diagnóstico',
              value:
                  resultado!.diagnostico.indicado ? 'Indicado' : 'Não indicado',
            ),
            _InfoLine(
              label: 'Ca_sub estimado',
              value: '${resultado!.caSubEstimado.toStringAsFixed(2)} cmolc/dm³',
            ),
            _InfoLine(
              label: 'Al_sub estimado',
              value: '${resultado!.alSubEstimado.toStringAsFixed(2)} cmolc/dm³',
            ),
            _InfoLine(
              label: 'm%_sub estimado',
              value: '${resultado!.mSubEstimado.toStringAsFixed(1)}%',
            ),
            _InfoLine(
              label: 'Dose',
              value:
                  '${resultado!.resultado.doseKgHa.toStringAsFixed(0)} kg/ha',
            ),
            _InfoLine(
              label: 'S fornecido',
              value:
                  '${resultado!.resultado.sFornecidoKgHa.toStringAsFixed(0)} kg/ha',
            ),
            _InfoLine(
              label: 'Ca fornecido',
              value:
                  '${resultado!.resultado.caFornecidoKgHa.toStringAsFixed(0)} kg/ha',
            ),
            if (resultado!.resultado.observacoes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  resultado!.resultado.observacoes.join(' '),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecond,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                resultado!.resumoCalculo,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecond,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FosforoSection extends StatelessWidget {
  const _FosforoSection({
    required this.calibracaoNome,
    required this.resultado,
  });

  final String? calibracaoNome;
  final CalculoFosforoResultado? resultado;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(AppDimens.screenPadding),
      borderRadius: AppDimens.radiusLg,
      showBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cálculo de Fósforo',
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            calibracaoNome == null || calibracaoNome!.trim().isEmpty
                ? 'Selecione e gere uma calibração na tela de Recomendação para calcular o fósforo.'
                : 'Calibração ativa: $calibracaoNome',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecond,
            ),
          ),
          if (resultado != null) ...[
            const SizedBox(height: 18),
            _FosforoCalibracaoResumo(resultado: resultado!),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  resultado!.doseTotalP2O5KgHa.toStringAsFixed(0),
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 36,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'kg/ha P₂O₅',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecond,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _InfoLine(label: 'Modo', value: resultado!.modo),
            _InfoLine(label: 'Referência', value: resultado!.referencia),
            _InfoLine(
              label: 'P atual',
              value: '${resultado!.pAtual.toStringAsFixed(1)} mg/dm³',
            ),
            _InfoLine(
              label: 'NC',
              value: '${resultado!.nc.toStringAsFixed(1)} mg/dm³',
            ),
            _InfoLine(
              label: 'FEP',
              value: '${resultado!.fep.toStringAsFixed(1)}%',
            ),
            _InfoLine(
              label: 'Correção',
              value:
                  '${resultado!.doseCorrecaoP2O5KgHa.toStringAsFixed(0)} kg/ha',
            ),
            _InfoLine(
              label: 'Exportação',
              value:
                  '${resultado!.doseExportacaoP2O5KgHa.toStringAsFixed(0)} kg/ha',
            ),
            _InfoLine(
              label: 'Extração',
              value:
                  '${resultado!.doseExtracaoP2O5KgHa.toStringAsFixed(0)} kg/ha',
            ),
            if (resultado!.percentualUsoSolo > 0)
              _InfoLine(
                label: 'P solo usado',
                value:
                    '${resultado!.percentualUsoSolo.toStringAsFixed(0)}% · ${resultado!.pSoloCreditadoP2O5KgHa.toStringAsFixed(0)} kg/ha P₂O₅',
              ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                resultado!.resumoCalculo,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecond,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
