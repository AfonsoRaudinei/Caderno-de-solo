import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';

/// Tela principal do Laboratório com abas internas.
class LabPage extends StatelessWidget {
  const LabPage({super.key});

  static const String _calibracaoIcon = 'assets/icons/calibracao.png';
  static const String _recomendacaoIcon = 'assets/icons/recomendacao.png';
  static const String _referenciasIcon = 'assets/icons/referencias.png';
  static const String _historicoIcon = 'assets/icons/historico.png';

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Laboratório'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.screenPadding,
          AppDimens.lg,
          AppDimens.screenPadding,
          AppDimens.section,
        ),
        children: [
          AppSurface(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                AppActionListRow(
                  title: 'Calibração',
                  assetPath: _calibracaoIcon,
                  onTap: () => context.push(AppRoutes.labCalibracao),
                ),
                Divider(
                  height: 0.5,
                  color: palette.border,
                ),
                AppActionListRow(
                  title: 'Recomendação',
                  assetPath: _recomendacaoIcon,
                  onTap: () => context.push(AppRoutes.labRecomendacao),
                ),
                Divider(
                  height: 0.5,
                  color: palette.border,
                ),
                AppActionListRow(
                  title: 'Referências',
                  assetPath: _referenciasIcon,
                  onTap: () => context.push(AppRoutes.labReferencias),
                ),
                Divider(
                  height: 0.5,
                  color: palette.border,
                ),
                AppActionListRow(
                  title: 'Histórico',
                  assetPath: _historicoIcon,
                  onTap: () => context.push(AppRoutes.labHistorico),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
