import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/constants/app_strings.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/presentation/auth/login/login_controller.dart';

/// Tela de Login
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final senhaController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final loginState = ref.watch(loginControllerProvider);

    // Listener para erros ou sucesso
    ref.listen<AsyncValue<void>>(
      loginControllerProvider,
      (_, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error.toString()),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.hasValue && !state.isLoading) {
          // Sucesso no login -> ir para a home
          context.go(AppRoutes.home);
        }
      },
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.xl),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Modo Dev
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      margin: const EdgeInsets.only(bottom: AppDimens.xxl),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Modo Dev: Qualquer login válido',
                            style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                          ),
                        ],
                      ),
                    ),

                    // Logo
                    const _LoginHeader(),
                    const SizedBox(height: AppDimens.section),

                    // Segmented Control (Login | Cadastro)
                    const _AuthSegmentedControl(),
                    const SizedBox(height: AppDimens.xxl),

                    // Card de Login
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppInput(
                            controller: emailController,
                            label: AppStrings.email,
                            hint: 'seu@email.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.campoObrigatorio;
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return AppStrings.emailInvalido;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimens.lg),
                          AppInput(
                            controller: senhaController,
                            label: AppStrings.senha,
                            hint: '••••••••',
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              if (formKey.currentState!.validate()) {
                                ref
                                    .read(loginControllerProvider.notifier)
                                    .login(emailController.text, senhaController.text);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.campoObrigatorio;
                              }
                              if (value.length < 6) {
                                return AppStrings.senhaMinimo6;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimens.sm),
                          Align(
                            alignment: Alignment.centerRight,
                            child: AppButtonText(
                              label: AppStrings.esqueceuSenha,
                              onPressed: () => context.push(AppRoutes.recuperarSenha),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.section),

                    // Botão Entrar
                    AppButton(
                      label: AppStrings.entrar,
                      isLoading: loginState.isLoading,
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          ref
                              .read(loginControllerProvider.notifier)
                              .login(emailController.text, senhaController.text);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: AssetImage('assets/images/app_icon.png'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.lg),
        Text(
          AppStrings.appName,
          style: AppTextStyles.largeTitle,
        ),
        const SizedBox(height: AppDimens.xs),
        Text(
          AppStrings.appTagline,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecond,
          ),
        ),
      ],
    );
  }
}

class _AuthSegmentedControl extends StatelessWidget {
  const _AuthSegmentedControl();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.borderSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                AppStrings.login,
                textAlign: TextAlign.center,
                style: AppTextStyles.label,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.cadastro),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  AppStrings.cadastro,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecond,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
