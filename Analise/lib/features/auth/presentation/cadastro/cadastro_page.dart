import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/core/constants/app_strings.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/widgets/app_dropdown.dart';
import 'package:soloforte/features/auth/presentation/cadastro/cadastro_controller.dart';

/// Tela de Cadastro em 3 etapas (visual dark premium)
class CadastroPage extends HookConsumerWidget {
  const CadastroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentStep = ref.watch(cadastroStepProvider);
    final cadastroState = ref.watch(cadastroControllerProvider);

    final formKey1 = useMemoized(() => GlobalKey<FormState>());
    final formKey2 = useMemoized(() => GlobalKey<FormState>());
    final formKey3 = useMemoized(() => GlobalKey<FormState>());

    final nomeController = useTextEditingController();
    final perfilNotifier = useValueNotifier<String?>(null);
    final estadoNotifier = useValueNotifier<String?>(null);
    final cidadeController = useTextEditingController();
    final emailController = useTextEditingController();
    final senhaController = useTextEditingController();
    final confirmarSenhaController = useTextEditingController();

    final media = MediaQuery.of(context);
    final shortest = media.size.shortestSide;
    final isCompact = media.size.height < 860;
    final scale = (shortest / 390).clamp(0.88, 1.0) * (isCompact ? 0.94 : 1.0);

    void submitCadastro() {
      if (!formKey3.currentState!.validate()) return;
      ref.read(cadastroControllerProvider.notifier).registrar(
            nome: nomeController.text,
            tipoPerfil: perfilNotifier.value ?? '',
            estado: estadoNotifier.value ?? '',
            cidade: cidadeController.text,
            email: emailController.text,
            senha: senhaController.text,
          );
    }

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
              content: Text(
                'Conta criada. Verifique seu e-mail para acessar o app.',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
      },
    );

    void nextStep(int step, GlobalKey<FormState> formKey) {
      if (!formKey.currentState!.validate()) return;

      if (step == 1 && perfilNotifier.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione seu perfil.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (step == 2 && estadoNotifier.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione um estado.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      ref.read(cadastroStepProvider.notifier).state = step;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    void prevStep(int step) {
      ref.read(cadastroStepProvider.notifier).state = step - 2;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const _CadastroDarkBackground(),
          SafeArea(
            child: Column(
              children: [
                _CadastroHeader(
                  step: currentStep,
                  scale: scale,
                  onBack: currentStep == 0
                      ? () => context.pop()
                      : () => prevStep(currentStep + 1),
                ),
                _StepProgressBar(currentStep: currentStep, scale: scale),
                Expanded(
                  child: PageView(
                    controller: pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _CadastroStepScroll(
                        scale: scale,
                        child: Form(
                          key: formKey1,
                          child: _CadastroCard(
                            scale: scale,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _StepTitle(
                                  title: 'Sobre você',
                                  subtitle:
                                      'Vamos conhecer seu perfil para personalizar sua experiência no campo.',
                                  scale: scale,
                                ),
                                SizedBox(height: 16 * scale),
                                _DarkTextField(
                                  controller: nomeController,
                                  label: AppStrings.nomeCompleto,
                                  hint: 'Seu nome completo',
                                  prefixIcon: Icons.person_outline_rounded,
                                  textInputAction: TextInputAction.next,
                                  scale: scale,
                                  validator: (v) => v == null || v.isEmpty
                                      ? AppStrings.campoObrigatorio
                                      : null,
                                ),
                                SizedBox(height: 12 * scale),
                                ValueListenableBuilder<String?>(
                                  valueListenable: perfilNotifier,
                                  builder: (context, val, _) {
                                    return _DarkDropdownField<String>(
                                      label: 'Perfil principal',
                                      hint: 'Selecione seu perfil',
                                      value: val,
                                      prefixIcon: Icons.agriculture_rounded,
                                      scale: scale,
                                      items: perfisUsuario,
                                      onChanged: (v) =>
                                          perfilNotifier.value = v,
                                    );
                                  },
                                ),
                                SizedBox(height: 18 * scale),
                                _GreenGradientButton(
                                  label: 'Próximo',
                                  icon: Icons.arrow_forward_rounded,
                                  scale: scale,
                                  onPressed: () => nextStep(1, formKey1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _CadastroStepScroll(
                        scale: scale,
                        child: Form(
                          key: formKey2,
                          child: _CadastroCard(
                            scale: scale,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _StepTitle(
                                  title: 'Onde você atua?',
                                  subtitle:
                                      'Esses dados ajudam nas recomendações agronômicas da sua região.',
                                  scale: scale,
                                ),
                                SizedBox(height: 16 * scale),
                                ValueListenableBuilder<String?>(
                                  valueListenable: estadoNotifier,
                                  builder: (context, val, _) {
                                    return _DarkDropdownField<String>(
                                      label: 'Estado (UF)',
                                      hint: 'Selecione o estado',
                                      value: val,
                                      prefixIcon: Icons.map_outlined,
                                      scale: scale,
                                      items: estadosBrasileiros,
                                      onChanged: (v) =>
                                          estadoNotifier.value = v,
                                    );
                                  },
                                ),
                                SizedBox(height: 12 * scale),
                                _DarkTextField(
                                  controller: cidadeController,
                                  label: 'Cidade base ou região',
                                  hint: 'Ex: Rio Verde',
                                  prefixIcon: Icons.location_city_outlined,
                                  textInputAction: TextInputAction.done,
                                  scale: scale,
                                  onSubmitted: (_) => nextStep(2, formKey2),
                                  validator: (v) => v == null || v.isEmpty
                                      ? AppStrings.campoObrigatorio
                                      : null,
                                ),
                                SizedBox(height: 18 * scale),
                                _GreenGradientButton(
                                  label: 'Próximo',
                                  icon: Icons.arrow_forward_rounded,
                                  scale: scale,
                                  onPressed: () => nextStep(2, formKey2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _CadastroStepScroll(
                        scale: scale,
                        child: Form(
                          key: formKey3,
                          child: _CadastroCard(
                            scale: scale,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _StepTitle(
                                  title: 'Crie seu acesso',
                                  subtitle:
                                      'Defina um e-mail e uma senha segura para entrar no Caderno de Solo.',
                                  scale: scale,
                                ),
                                SizedBox(height: 16 * scale),
                                _DarkTextField(
                                  controller: emailController,
                                  label: AppStrings.email,
                                  hint: 'seu@email.com',
                                  prefixIcon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  scale: scale,
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
                                SizedBox(height: 12 * scale),
                                _DarkTextField(
                                  controller: senhaController,
                                  label: AppStrings.senha,
                                  hint: '••••••••',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  obscureText: true,
                                  textInputAction: TextInputAction.next,
                                  scale: scale,
                                  validator: (v) => (v == null || v.length < 6)
                                      ? AppStrings.senhaMinimo6
                                      : null,
                                ),
                                SizedBox(height: 12 * scale),
                                _DarkTextField(
                                  controller: confirmarSenhaController,
                                  label: AppStrings.confirmarSenha,
                                  hint: '••••••••',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  scale: scale,
                                  onSubmitted: (_) {
                                    submitCadastro();
                                  },
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return AppStrings.campoObrigatorio;
                                    }
                                    if (v != senhaController.text) {
                                      return AppStrings.senhasNaoCoincidem;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 18 * scale),
                                _GreenGradientButton(
                                  label: 'Finalizar Cadastro',
                                  icon: Icons.arrow_forward_rounded,
                                  isLoading: cadastroState.isLoading,
                                  scale: scale,
                                  onPressed: submitCadastro,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CadastroDarkBackground extends StatelessWidget {
  const _CadastroDarkBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF030907),
                Color(0xFF06110E),
                Color(0xFF071814),
                Color(0xFF020706),
              ],
              stops: [0.0, 0.35, 0.7, 1.0],
            ),
          ),
          child: SizedBox.expand(),
        ),
        const Positioned(
          top: -120,
          right: -80,
          child: _AmbientGlow(size: 290, color: Color(0x2B59C563)),
        ),
        const Positioned(
          bottom: -100,
          left: -70,
          child: _AmbientGlow(size: 260, color: Color(0x1C4FA05C)),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: [
                Positioned(
                  right: -16,
                  top: -8,
                  child: Opacity(
                    opacity: 0.20,
                    child: SizedBox(
                      width: 160,
                      height: 210,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topRight,
                          widthFactor: 0.24,
                          child: Image.asset(
                            'assets/images/LOGIN.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -22,
                  bottom: -16,
                  child: Opacity(
                    opacity: 0.16,
                    child: SizedBox(
                      width: 180,
                      height: 220,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          widthFactor: 0.24,
                          child: Image.asset(
                            'assets/images/LOGIN.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CadastroHeader extends StatelessWidget {
  final int step;
  final double scale;
  final VoidCallback onBack;

  const _CadastroHeader({
    required this.step,
    required this.scale,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8 * scale, 2 * scale, 8 * scale, 6 * scale),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFE7ECE9),
            ),
          ),
          Expanded(
            child: Text(
              'Cadastro (${step + 1}/3)',
              textAlign: TextAlign.center,
              style: AppTextStyles.value.copyWith(
                color: const Color(0xFFE7ECE9),
                fontSize: 20 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 48 * scale),
        ],
      ),
    );
  }
}

class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  final double scale;

  const _StepProgressBar({required this.currentStep, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20 * scale, 0, 20 * scale, 10 * scale),
      child: Row(
        children: List.generate(3, (index) {
          final active = index <= currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 7 * scale : 0),
              height: 5 * scale,
              decoration: BoxDecoration(
                color:
                    active ? const Color(0xFF76C84A) : const Color(0xFF2B3A36),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CadastroStepScroll extends StatelessWidget {
  final Widget child;
  final double scale;

  const _CadastroStepScroll({required this.child, required this.scale});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        6 * scale,
        18 * scale,
        bottomInset + (18 * scale),
      ),
      child: child,
    );
  }
}

class _CadastroCard extends StatelessWidget {
  final Widget child;
  final double scale;

  const _CadastroCard({required this.child, required this.scale});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28 * scale),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 11, sigmaY: 11),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xDD091311),
            borderRadius: BorderRadius.circular(28 * scale),
            border: Border.all(color: const Color(0x335BC852), width: 1.1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            18 * scale,
            18 * scale,
            18 * scale,
            16 * scale,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final double scale;

  const _StepTitle({
    required this.title,
    required this.subtitle,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headline.copyWith(
            color: const Color(0xFFE7ECEA),
            fontSize: 28 * scale,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          subtitle,
          style: AppTextStyles.body.copyWith(
            color: const Color(0xFFABB5B1),
            fontSize: 15 * scale,
            height: 1.32,
          ),
        ),
      ],
    );
  }
}

class _DarkTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final double scale;

  const _DarkTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.scale,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
  });

  @override
  State<_DarkTextField> createState() => _DarkTextFieldState();
}

class _DarkTextFieldState extends State<_DarkTextField> {
  late final FocusNode _focusNode;
  bool _focused = false;
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _obscured = widget.obscureText;
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.label.copyWith(
            color: const Color(0xFFC4CECA),
            fontSize: 13 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6 * scale),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onFieldSubmitted: widget.onSubmitted,
          style: AppTextStyles.input.copyWith(
            color: const Color(0xFFE8EEEA),
            fontSize: 16 * scale,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.input.copyWith(
              color: const Color(0xFF6D7A74),
              fontSize: 16 * scale,
            ),
            filled: true,
            fillColor: const Color(0xFF0D1714),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 14 * scale, vertical: 14 * scale),
            prefixIcon: Icon(
              widget.prefixIcon,
              color: const Color(0xFF74C84A),
              size: 21 * scale,
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF8A9591),
                      size: 21 * scale,
                    ),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * scale),
              borderSide: BorderSide(
                color: _focused
                    ? const Color(0xFF76C84A)
                    : const Color(0xFF34413D),
                width: 1.15,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * scale),
              borderSide:
                  const BorderSide(color: Color(0xFF76C84A), width: 1.3),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * scale),
              borderSide:
                  const BorderSide(color: Color(0xFFE75A63), width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * scale),
              borderSide:
                  const BorderSide(color: Color(0xFFE75A63), width: 1.35),
            ),
            errorStyle:
                AppTextStyles.error.copyWith(color: const Color(0xFFF18088)),
          ),
        ),
      ],
    );
  }
}

class _DarkDropdownField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final IconData prefixIcon;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final double scale;

  const _DarkDropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.prefixIcon,
    required this.items,
    required this.onChanged,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: const Color(0xFFC4CECA),
            fontSize: 13 * scale,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6 * scale),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item.value,
                  child: Text(
                    item.label,
                    style: AppTextStyles.body.copyWith(
                      color: const Color(0xFFE8EEEA),
                      fontSize: 15 * scale,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          dropdownColor: const Color(0xFF12201C),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: const Color(0xFF8A9591),
            size: 22 * scale,
          ),
          style: AppTextStyles.body.copyWith(
            color: const Color(0xFFE8EEEA),
            fontSize: 15 * scale,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(
              color: const Color(0xFF6D7A74),
              fontSize: 15 * scale,
            ),
            filled: true,
            fillColor: const Color(0xFF0D1714),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 14 * scale, vertical: 14 * scale),
            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFF74C84A),
              size: 21 * scale,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * scale),
              borderSide:
                  const BorderSide(color: Color(0xFF34413D), width: 1.15),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16 * scale),
              borderSide:
                  const BorderSide(color: Color(0xFF76C84A), width: 1.3),
            ),
          ),
        ),
      ],
    );
  }
}

class _GreenGradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final double scale;

  const _GreenGradientButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.scale,
    this.isLoading = false,
  });

  @override
  State<_GreenGradientButton> createState() => _GreenGradientButtonState();
}

class _GreenGradientButtonState extends State<_GreenGradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed && !widget.isLoading ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30 * widget.scale),
          gradient: const LinearGradient(
            colors: [Color(0xFF74C945), Color(0xFF3E9228)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3D72C94A),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30 * widget.scale),
          child: InkWell(
            borderRadius: BorderRadius.circular(30 * widget.scale),
            onTap: widget.isLoading ? null : widget.onPressed,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: SizedBox(
              height: 56 * widget.scale,
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.label,
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                              fontSize: 18 * widget.scale,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8 * widget.scale),
                          Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 24 * widget.scale,
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

class _AmbientGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _AmbientGlow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
