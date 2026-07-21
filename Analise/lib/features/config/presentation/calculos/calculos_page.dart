import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
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
      ref.read(calculosProvider.notifier).carregarAnalises(ids);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculosProvider);

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.chevron_back,
            size: 18,
            color: Color(0xFF1D1D1F),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Expanded(
            child: TabelaAnalisesWidget(
              media: state.media,
              analises: state.analises,
            ),
          ),
        ],
      ),
    );
  }
}
