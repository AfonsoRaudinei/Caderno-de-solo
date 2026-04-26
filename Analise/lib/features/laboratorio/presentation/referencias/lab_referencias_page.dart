import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/constants/app_routes.dart';

class LabReferenciasPage extends StatelessWidget {
  const LabReferenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Referências'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ListTile(
            title: const Text('Referências Técnicas'),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFFC7C7CC),
            ),
            onTap: () => context.push(AppRoutes.labRefTecnicas),
          ),
          const Divider(
            height: 0.5,
            color: Color(0xFFE5E5E7),
          ),
          ListTile(
            title: const Text('Tabelas Agronômicas'),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFFC7C7CC),
            ),
            onTap: () => context.push(AppRoutes.labRefMetricas),
          ),
          const Divider(
            height: 0.5,
            color: Color(0xFFE5E5E7),
          ),
          ListTile(
            title: const Text('Absorção de Nutrientes'),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFFC7C7CC),
            ),
            onTap: () => context.push(AppRoutes.labRefAbsorcaoNutrientes),
          ),
        ],
      ),
    );
  }
}
