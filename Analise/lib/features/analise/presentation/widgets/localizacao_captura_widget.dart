import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/domain/services/location_service.dart';
import 'package:soloforte/features/analise/presentation/providers/location_provider.dart';

class LocalizacaoCaptura extends ConsumerWidget {
  final void Function(double latitude, double longitude) onCapturada;

  const LocalizacaoCaptura({super.key, required this.onCapturada});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationNotifierProvider);

    ref.listen<LocationState>(locationNotifierProvider, (_, next) {
      if (next is LocationSuccess) {
        onCapturada(next.result.latitude, next.result.longitude);
      }
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Localização', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 12),
          switch (state) {
            LocationIdle() => _botaoCapturar(ref),
            LocationLoading() => _carregando(),
            LocationSuccess(result: final r) => _sucesso(r, ref),
            LocationError(message: final m) => _erro(m, ref),
          },
        ],
      ),
    );
  }

  Widget _botaoCapturar(WidgetRef ref) => AppButton(
        label: 'Capturar localização',
        icon: Icons.gps_fixed_outlined,
        onPressed: () => ref.read(locationNotifierProvider.notifier).capturar(),
      );

  Widget _carregando() => Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text('Obtendo GPS...', style: AppTextStyles.body),
        ],
      );

  Widget _sucesso(LocationResult r, WidgetRef ref) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.success, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  r.enderecoResumido,
                  style: AppTextStyles.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            r.coordenadasFormatadas +
                (r.accuracy != null
                    ? ' · precisão ${r.accuracy!.toStringAsFixed(0)} m'
                    : ''),
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          AppButtonSecondary(
            label: 'Recapturar',
            icon: Icons.refresh,
            onPressed: () =>
                ref.read(locationNotifierProvider.notifier).capturar(),
          ),
        ],
      );

  Widget _erro(String message, WidgetRef ref) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: AppColors.error, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Tentar novamente',
            icon: Icons.gps_fixed_outlined,
            onPressed: () =>
                ref.read(locationNotifierProvider.notifier).capturar(),
          ),
        ],
      );
}
