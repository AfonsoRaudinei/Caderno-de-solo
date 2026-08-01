import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _mensagemController = TextEditingController();
  String _tipo = 'Sugestão';
  bool _permitirContato = true;

  @override
  void dispose() {
    _mensagemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Enviar Feedback'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSurface(
              showBorder: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppIconFrame(
                    icon: Icons.chat_bubble_outline_rounded,
                    size: AppDimens.cardIconSize,
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sua opinião é muito importante',
                          style: AppTextStyles.headline.copyWith(
                            fontSize: 20,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimens.xs),
                        Text(
                          'Encontrou um erro ou tem uma sugestão? Conte para nós.',
                          style: AppTextStyles.body.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            AppSurface(
              showBorder: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppDropdown<String>(
                    label: 'Tipo de Mensagem',
                    hint: 'Selecione',
                    value: _tipo,
                    items: const [
                      AppDropdownItem(value: 'Bug', label: 'Bug/Erro'),
                      AppDropdownItem(value: 'Sugestão', label: 'Sugestão'),
                      AppDropdownItem(value: 'Elogio', label: 'Elogio'),
                      AppDropdownItem(value: 'Outro', label: 'Outro'),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _tipo = value);
                    },
                  ),
                  const SizedBox(height: AppDimens.md),
                  AppTextArea(
                    controller: _mensagemController,
                    label: 'Mensagem',
                    hint: 'Digite aqui os detalhes...',
                    maxLines: 5,
                  ),
                  const SizedBox(height: AppDimens.md),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Permitir contato via e-mail',
                          style: AppTextStyles.body.copyWith(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Switch.adaptive(
                        value: _permitirContato,
                        activeTrackColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() => _permitirContato = value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.xl),
            AppButton(
              label: 'Enviar Feedback',
              onPressed: _enviar,
            ),
          ],
        ),
      ),
    );
  }

  void _enviar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Obrigado! Recebemos seu feedback ($_tipo).'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }
}
