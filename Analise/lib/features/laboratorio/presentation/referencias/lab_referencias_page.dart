import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';

class LabReferenciasPage extends StatelessWidget {
  const LabReferenciasPage({super.key});

  static const String _referenciasTecnicasIcon =
      'assets/icons/referencias_tecnicas.png';
  static const String _tabelasAgronomicasIcon =
      'assets/icons/tabelas_agronomicas.png';
  static const String _absorcaoIcon = 'assets/icons/absorcao.png';

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Referências'),
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
                  title: 'Referências Técnicas',
                  assetPath: _referenciasTecnicasIcon,
                  onTap: () => context.push(AppRoutes.labRefTecnicas),
                ),
                Divider(
                  height: 0.5,
                  color: palette.border,
                ),
                AppActionListRow(
                  title: 'Tabelas Agronômicas',
                  assetPath: _tabelasAgronomicasIcon,
                  onTap: () => context.push(AppRoutes.labRefMetricas),
                ),
                Divider(
                  height: 0.5,
                  color: palette.border,
                ),
                AppActionListRow(
                  title: 'Absorção de Nutrientes',
                  assetPath: _absorcaoIcon,
                  onTap: () => context.push(AppRoutes.labRefAbsorcaoNutrientes),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
