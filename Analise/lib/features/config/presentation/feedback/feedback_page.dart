import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Enviar Feedback'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sua opinião é muito importante!',
              style: AppTextStyles.headline.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Encontrou um erro ou tem uma sugestão? Conte para nós.',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecond),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                children: [
                  AppDropdown<String>(
                    label: 'Tipo de Mensagem',
                    hint: 'Selecione',
                    value: 'Sugestão',
                    items: const [
                      AppDropdownItem(value: 'Bug', label: 'Bug/Erro'),
                      AppDropdownItem(value: 'Sugestão', label: 'Sugestão'),
                      AppDropdownItem(value: 'Elogio', label: 'Elogio'),
                      AppDropdownItem(value: 'Outro', label: 'Outro'),
                    ],
                    onChanged: (v) {},
                  ),
                  const SizedBox(height: 16),
                  const AppInput(
                    label: 'Mensagem',
                    hint: 'Digite aqui os detalhes...',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Permitir contato via e-mail'),
                      Switch.adaptive(
                        value: true,
                        activeTrackColor: AppColors.primary,
                        onChanged: (v) {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Enviar Feedback',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Obrigado! Recebemos seu feedback.')),
                );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
