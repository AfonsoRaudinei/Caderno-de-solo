import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/core/constants/app_strings.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/core/widgets/app_visual_components.dart';
import 'package:soloforte/features/auth/presentation/recuperar_senha/recuperar_senha_controller.dart';

/// Tela de Recuperar Senha
class RecuperarSenhaPage extends HookConsumerWidget {
  const RecuperarSenhaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final state = ref.watch(recuperarSenhaControllerProvider);
    final linkEnviado = ref.watch(linkEnviadoProvider);

    // Listener para erros
    ref.listen<AsyncValue<void>>(
      recuperarSenhaControllerProvider,
      (previous, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error.toString()),
              backgroundColor: const Color(0xFFFF3B30),
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          );
        } else if (previous?.isLoading == true && state.hasValue) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'E-mail enviado! Verifique sua caixa de entrada e a pasta de spam.',
              ),
              backgroundColor: Color(0xFF34C759),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        title: const Text(AppStrings.recuperarSenha),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: linkEnviado
              ? const _SucessoView()
              : Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSurface(
                        borderRadius: AppDimens.radiusXl,
                        child: Column(
                          children: [
                            const AppIconFrame(
                              icon: Icons.lock_reset_rounded,
                              size: 64,
                              iconSize: 34,
                            ),
                            const SizedBox(height: AppDimens.md),
                            Text(
                              'Esqueceu sua senha?',
                              style: AppTextStyles.headline,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppDimens.sm),
                            Text(
                              'Informe seu e-mail cadastrado. Enviaremos um link para você redefinir sua senha.',
                              style: AppTextStyles.body,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimens.lg),
                      AppSurface(
                        showShadow: false,
                        showBorder: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppInput(
                              controller: emailController,
                              label: AppStrings.email,
                              hint: 'seu@email.com',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) {
                                if (formKey.currentState!.validate()) {
                                  ref
                                      .read(recuperarSenhaControllerProvider
                                          .notifier)
                                      .enviarLink(emailController.text);
                                }
                              },
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return AppStrings.campoObrigatorio;
                                }
                                if (!v.contains('@')) {
                                  return AppStrings.emailInvalido;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimens.lg),
                      AppButton(
                        label: AppStrings.enviarLink,
                        icon: Icons.mail_outline_rounded,
                        isLoading: state.isLoading,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            ref
                                .read(recuperarSenhaControllerProvider.notifier)
                                .enviarLink(emailController.text);
                          }
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _SucessoView extends StatelessWidget {
  const _SucessoView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppSurface(
          borderRadius: AppDimens.radiusXl,
          child: Column(
            children: [
              const AppIconFrame(
                icon: Icons.mark_email_read_rounded,
                size: 72,
                iconSize: 38,
                iconColor: AppColors.success,
                backgroundColor: Color(0x1A34C759),
              ),
              const SizedBox(height: AppDimens.lg),
              Text(
                'E-mail enviado!',
                style: AppTextStyles.headline,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.sm),
              Text(
                'Verifique sua caixa de entrada (e a pasta de spam) para redefinir sua senha.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.xl),
        AppButtonSecondary(
          label: AppStrings.voltarLogin,
          icon: Icons.arrow_back_rounded,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
