import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';

// Importações dos placeholders
import 'package:soloforte/presentation/lab/calibracao/calibracao_page.dart';
import 'package:soloforte/presentation/lab/recomendacao/recomendacao_screen.dart';

/// Tela principal do Laboratório com abas internas.
class LabPage extends StatelessWidget {
  const LabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bgSecondary,
        appBar: AppBar(
          title: const Text('Laboratório'),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecond,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: AppTextStyles.label,
            unselectedLabelStyle:
                AppTextStyles.label.copyWith(fontWeight: FontWeight.normal),
            tabs: const [
              Tab(text: 'Calibração'),
              Tab(text: 'Recomendação'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CalibracaoPage(),
            RecomendacaoScreen(),
          ],
        ),
      ),
    );
  }
}
