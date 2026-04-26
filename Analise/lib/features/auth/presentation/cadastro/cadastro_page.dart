import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/core/constants/app_strings.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/core/widgets/app_button.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/core/widgets/app_input.dart';
import 'package:soloforte/features/auth/presentation/cadastro/cadastro_controller.dart';

/// Tela de Cadastro em 3 etapas
class CadastroPage extends HookConsumerWidget {
  const CadastroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentStep = ref.watch(cadastroStepProvider);
    final cadastroState = ref.watch(cadastroControllerProvider);

    // Form Keys para cada etapa
    final formKey1 = useMemoized(() => GlobalKey<FormState>());
    final formKey2 = useMemoized(() => GlobalKey<FormState>());
    final formKey3 = useMemoized(() => GlobalKey<FormState>());

    // Controllers
    final nomeController = useTextEditingController();
    final perfilNotifier = useValueNotifier<String?>(null);
    final estadoNotifier = useValueNotifier<String?>(null);
    final cidadeController = useTextEditingController();
    final emailController = useTextEditingController();
    final senhaController = useTextEditingController();
    final confirmarSenhaController = useTextEditingController();

    // Listener para feedback final
    ref.listen<AsyncValue<void>>(
      cadastroControllerProvider,
      (_, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state.hasValue && !state.isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta criada com sucesso! Faça login.'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop(); // Volta pro login
        }
      },
    );

    void nextStep(int step, GlobalKey<FormState> formKey) {
      if (formKey.currentState!.validate()) {
        if (step == 1 && perfilNotifier.value == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Selecione seu perfil.'),
                backgroundColor: AppColors.error),
          );
          return;
        }
        if (step == 2 && estadoNotifier.value == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Selecione um estado.'),
                backgroundColor: AppColors.error),
          );
          return;
        }

        ref.read(cadastroStepProvider.notifier).state = step;
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    void prevStep(int step) {
      ref.read(cadastroStepProvider.notifier).state = step - 2;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      appBar: AppBar(
        leading: currentStep == 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => context.pop(),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => prevStep(currentStep + 1),
              ),
        title: Text('${AppStrings.cadastro} (${currentStep + 1}/3)'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de Progresso (Stepper visual)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.lg, vertical: AppDimens.md),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= currentStep
                            ? AppColors.primary
                            : AppColors.borderSoft,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // PageView para as etapas
            Expanded(
              child: PageView(
                controller: pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Impede swipe manual
                children: [
                  // ETAPA 1: Dados Pessoais
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimens.lg),
                    child: Form(
                      key: formKey1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Sobre Você', style: AppTextStyles.headline),
                          const SizedBox(height: 8),
                          Text(
                            'Vamos conhecer um pouco sobre seu perfil para personalizar a experiência.',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textSecond),
                          ),
                          const SizedBox(height: AppDimens.xl),
                          AppInput(
                            controller: nomeController,
                            label: AppStrings.nomeCompleto,
                            hint: 'Seu nome completo',
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                v!.isEmpty ? AppStrings.campoObrigatorio : null,
                          ),
                          const SizedBox(height: AppDimens.lg),
                          ValueListenableBuilder<String?>(
                            valueListenable: perfilNotifier,
                            builder: (context, val, _) {
                              return AppDropdown<String>(
                                label: 'Perfil Principal',
                                hint: 'Selecione seu perfil',
                                value: val,
                                items: perfisUsuario,
                                onChanged: (v) => perfilNotifier.value = v,
                              );
                            },
                          ),
                          const SizedBox(height: AppDimens.section),
                          AppButton(
                            label: AppStrings.proximo,
                            onPressed: () => nextStep(1, formKey1),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ETAPA 2: Localização
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimens.lg),
                    child: Form(
                      key: formKey2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Onde você atua?',
                              style: AppTextStyles.headline),
                          const SizedBox(height: 8),
                          Text(
                            'Esses dados ajudam na precisão das recomendações agronômicas da sua região.',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textSecond),
                          ),
                          const SizedBox(height: AppDimens.xl),
                          ValueListenableBuilder<String?>(
                            valueListenable: estadoNotifier,
                            builder: (context, val, _) {
                              return AppDropdown<String>(
                                label: 'Estado (UF)',
                                hint: 'Selecione o estado',
                                value: val,
                                items: estadosBrasileiros,
                                onChanged: (v) => estadoNotifier.value = v,
                              );
                            },
                          ),
                          const SizedBox(height: AppDimens.lg),
                          AppInput(
                            controller: cidadeController,
                            label: 'Cidade base ou região',
                            hint: 'Ex: Rio Verde',
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => nextStep(2, formKey2),
                            validator: (v) =>
                                v!.isEmpty ? AppStrings.campoObrigatorio : null,
                          ),
                          const SizedBox(height: AppDimens.section),
                          AppButton(
                            label: AppStrings.proximo,
                            onPressed: () => nextStep(2, formKey2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ETAPA 3: Credenciais
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimens.lg),
                    child: Form(
                      key: formKey3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Crie seu acesso',
                              style: AppTextStyles.headline),
                          const SizedBox(height: 8),
                          Text(
                            'Defina um e-mail e uma senha segura para entrar no aplicativo Analise.',
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textSecond),
                          ),
                          const SizedBox(height: AppDimens.xl),
                          AppInput(
                            controller: emailController,
                            label: AppStrings.email,
                            hint: 'seu@email.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v!.isEmpty) {
                                return AppStrings.campoObrigatorio;
                              }
                              if (!v.contains('@')) {
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
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                v!.length < 6 ? AppStrings.senhaMinimo6 : null,
                          ),
                          const SizedBox(height: AppDimens.lg),
                          AppInput(
                            controller: confirmarSenhaController,
                            label: AppStrings.confirmarSenha,
                            hint: '••••••••',
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              if (formKey3.currentState!.validate()) {
                                ref
                                    .read(cadastroControllerProvider.notifier)
                                    .registrar(
                                      nome: nomeController.text,
                                      email: emailController.text,
                                      senha: senhaController.text,
                                    );
                              }
                            },
                            validator: (v) {
                              if (v!.isEmpty) {
                                return AppStrings.campoObrigatorio;
                              }
                              if (v != senhaController.text) {
                                return AppStrings.senhasNaoCoincidem;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimens.section),
                          AppButton(
                            label: 'Finalizar Cadastro',
                            isLoading: cadastroState.isLoading,
                            onPressed: () {
                              if (formKey3.currentState!.validate()) {
                                ref
                                    .read(cadastroControllerProvider.notifier)
                                    .registrar(
                                      nome: nomeController.text,
                                      email: emailController.text,
                                      senha: senhaController.text,
                                    );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
