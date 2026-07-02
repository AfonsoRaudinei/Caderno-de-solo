import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';

/// Tela principal do Laboratório com abas internas.
class LabPage extends StatelessWidget {
  const LabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratório'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ListTile(
            title: Text(
              'Calibração',
              style: TextStyle(color: palette.textPrimary),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: palette.textTertiary,
            ),
            onTap: () => context.push(AppRoutes.labCalibracao),
          ),
          Divider(
            height: 0.5,
            color: palette.border,
          ),
          ListTile(
            title: Text(
              'Recomendação',
              style: TextStyle(color: palette.textPrimary),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: palette.textTertiary,
            ),
            onTap: () => context.push(AppRoutes.labRecomendacao),
          ),
          Divider(
            height: 0.5,
            color: palette.border,
          ),
          ListTile(
            title: Text(
              'Referências',
              style: TextStyle(color: palette.textPrimary),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: palette.textTertiary,
            ),
            onTap: () => context.push(AppRoutes.labReferencias),
          ),
          Divider(
            height: 0.5,
            color: palette.border,
          ),
          ListTile(
            leading: const Icon(
              Icons.history_rounded,
              color: AppColors.primary,
            ),
            title: Text(
              'Histórico',
              style: TextStyle(color: palette.textPrimary),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: palette.textTertiary,
            ),
            onTap: () => context.push(AppRoutes.labHistorico),
          ),
        ],
      ),
    );
  }
}
