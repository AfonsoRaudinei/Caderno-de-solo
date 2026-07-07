import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';

class LabReferenciasPage extends StatelessWidget {
  const LabReferenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referências'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ListTile(
            title: Text(
              'Referências Técnicas',
              style: TextStyle(color: palette.textPrimary),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: palette.textTertiary,
            ),
            onTap: () => context.push(AppRoutes.labRefTecnicas),
          ),
          Divider(
            height: 0.5,
            color: palette.border,
          ),
          ListTile(
            title: Text(
              'Tabelas Agronômicas',
              style: TextStyle(color: palette.textPrimary),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: palette.textTertiary,
            ),
            onTap: () => context.push(AppRoutes.labRefMetricas),
          ),
          Divider(
            height: 0.5,
            color: palette.border,
          ),
          ListTile(
            title: Text(
              'Absorção de Nutrientes',
              style: TextStyle(color: palette.textPrimary),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: palette.textTertiary,
            ),
            onTap: () => context.push(AppRoutes.labRefAbsorcaoNutrientes),
          ),
        ],
      ),
    );
  }
}
