import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_controller.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/calibracao_state.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/calibracao_footer_card.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/calibracao_header_card.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/corretivos_card.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/fosforo_card_widget.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/micronutrientes_card.dart';
import 'package:soloforte/features/laboratorio/presentation/calibracao/widgets/potassio_card_widget.dart';

class CalibracaoPage extends ConsumerStatefulWidget {
  const CalibracaoPage({super.key});

  @override
  ConsumerState<CalibracaoPage> createState() => _CalibracaoPageState();
}

class _CalibracaoPageState extends ConsumerState<CalibracaoPage> {
  static const List<String> _culturas = [
    'Soja',
    'Milho',
    'Feijão',
    'Algodão',
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Calibração', style: AppTextStyles.label),
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
            state: state,
            isExpanded: state.isHeaderExpanded,
            onToggle: controller.toggleHeader,
            culturas: _culturas
                .map((cultura) =>
                    AppDropdownItem(value: cultura, label: cultura))
                .toList(),
            onNomeChanged: controller.atualizarNome,
            onCulturaChanged: controller.atualizarCultura,
            onSafraChanged: controller.atualizarSafra,
            onClienteChanged: controller.atualizarCliente,
            onProdutividadeChanged: controller.atualizarProdutividade,
            onUnidadeChanged: (_) {},
          ),
          CorretivosCard(
            draft: draft,
            draftKey: draftKey,
            corretivos: corretivos,
            isExpanded: state.isCorretivosExpanded,
            onToggle: controller.toggleCorretivos,
            onChanged: (map) =>
                controller.updateCalcario(CalcarioState(parametros: map)),
          ),
          FosforoCard(
            key: ValueKey('fosforo-$draftKey'),
            initialData: fosforo,
            cultura: draft.cultura,
            isExpanded: state.isFosforoExpanded,
            onToggle: controller.toggleFosforo,
            onChanged: (map) =>
                controller.updateFosforo(FosforoState(parametros: map)),
          ),
          const SizedBox(height: AppDimens.md),
          PotassioCard(
            key: ValueKey('potassio-$draftKey'),
            initialData: _asMap(draft.parametrosCards['potassio']),
            cultura: draft.cultura,
            isExpanded: state.isPotassioExpanded,
            onToggle: controller.togglePotassio,
            onChanged: (map) =>
                controller.updatePotassio(PotassioState(parametros: map)),
          ),
          MicronutrientesCard(
            draftKey: draftKey,
            micros: micros,
            elementos: elementos,
            grupos: grupos,
            isExpanded: state.isMicronutrientesExpanded,
            onToggle: controller.toggleMicronutrientes,
            onChanged: (map) =>
                controller.updateMicros(MicronutrientesState(parametros: map)),
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
            (entry) => entry.map((key, val) => MapEntry(key.toString(), val)),
          )
          .toList();
    }
    return <Map<String, dynamic>>[];
  }
}
