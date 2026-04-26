import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/theme/app_colors.dart';

/// Tela principal do Laboratório com abas internas.
class LabPage extends StatelessWidget {
  const LabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Laboratório'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ListTile(
            title: const Text('Calibração'),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFFC7C7CC),
            ),
            onTap: () => context.push(AppRoutes.labCalibracao),
          ),
          const Divider(
            height: 0.5,
            color: Color(0xFFE5E5E7),
          ),
          ListTile(
            title: const Text('Recomendação'),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFFC7C7CC),
            ),
            onTap: () => context.push(AppRoutes.labRecomendacao),
          ),
          const Divider(
            height: 0.5,
            color: Color(0xFFE5E5E7),
          ),
          ListTile(
            title: const Text('Referências'),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFFC7C7CC),
            ),
            onTap: () => context.push(AppRoutes.labReferencias),
          ),
          const Divider(
            height: 0.5,
            color: Color(0xFFE5E5E7),
          ),
          ListTile(
            leading: const Icon(
              Icons.history_rounded,
              color: AppColors.primary,
            ),
            title: const Text('Histórico'),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFFC7C7CC),
            ),
            onTap: () => context.push(AppRoutes.labHistorico),
          ),
        ],
      ),
    );
  }
}
