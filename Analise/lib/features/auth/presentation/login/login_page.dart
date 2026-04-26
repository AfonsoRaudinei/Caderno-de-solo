import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:soloforte/core/constants/app_routes.dart';
import 'package:soloforte/core/constants/app_strings.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/features/auth/presentation/login/login_controller.dart';

/// Tela de Login
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final senhaController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final reveal = useState(false);

    useEffect(() {
      Future<void>.microtask(() => reveal.value = true);
      return null;
    }, const []);

    final loginState = ref.watch(loginControllerProvider);

    void submitLogin() {
      if (formKey.currentState!.validate()) {
        ref.read(loginControllerProvider.notifier).login(
              emailController.text,
              senhaController.text,
            );
      }
    }

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
          context.go(AppRoutes.home);
        }
      },
    );

    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;
    final shortest = media.size.shortestSide;
    final isCompact = media.size.height < 860;
    final scale = (shortest / 390).clamp(0.88, 1.0) * (isCompact ? 0.94 : 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const _DarkBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    18 * scale,
                    10 * scale,
                    18 * scale,
                    (bottomInset > 0 ? bottomInset : AppDimens.xl) + 10,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (kDebugMode) const _DevBanner(),
                        AnimatedSlide(
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.easeOutCubic,
                          offset:
                              reveal.value ? Offset.zero : const Offset(0, .05),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 380),
                            opacity: reveal.value ? 1 : 0,
                            child: _LoginHeader(scale: scale),
                          ),
                        ),
                        SizedBox(height: 12 * scale),
                        AnimatedSlide(
                          duration: const Duration(milliseconds: 460),
                          curve: Curves.easeOutCubic,
                          offset: reveal.value
                              ? Offset.zero
                              : const Offset(0, .045),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 420),
                            opacity: reveal.value ? 1 : 0,
                            child: _AuthSegmentedControl(scale: scale),
                          ),
                        ),
                        SizedBox(height: 14 * scale),
                        AnimatedSlide(
                          duration: const Duration(milliseconds: 520),
                          curve: Curves.easeOutCubic,
                          offset: reveal.value
                              ? Offset.zero
                              : const Offset(0, .035),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 520),
                            opacity: reveal.value ? 1 : 0,
                            child: _DarkLoginCard(
                              emailController: emailController,
                              senhaController: senhaController,
                              isLoading: loginState.isLoading,
                              onSubmit: submitLogin,
                              scale: scale,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _DarkBackground extends StatelessWidget {
  const _DarkBackground();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        DecoratedBox(
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
        Positioned(
          top: -140,
          right: -70,
          child: _AmbientGlow(
            size: 300,
            color: Color(0x3355C66A),
          ),
        ),
        Positioned(
          top: 180,
          left: -80,
          child: _AmbientGlow(
            size: 250,
            color: Color(0x224BC15A),
          ),
        ),
        Positioned(
          bottom: -90,
          right: -30,
          child: _AmbientGlow(
            size: 260,
            color: Color(0x1E3EA84D),
          ),
        ),
        Positioned.fill(child: _LeafDetailLayer()),
      ],
    );
  }
}

class _LeafDetailLayer extends StatelessWidget {
  const _LeafDetailLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -6,
            child: Opacity(
              opacity: 0.22,
              child: SizedBox(
                width: 160,
                height: 220,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topRight,
                    widthFactor: 0.24,
                    child: Image.asset('assets/images/LOGIN.png',
                        fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -24,
            bottom: -10,
            child: Opacity(
              opacity: 0.16,
              child: SizedBox(
                width: 180,
                height: 200,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    widthFactor: 0.24,
                    child: Image.asset('assets/images/LOGIN.png',
                        fit: BoxFit.cover),
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

class _DevBanner extends StatelessWidget {
  const _DevBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.only(bottom: AppDimens.xl),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3324),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x3342B75A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF8FD39D), size: 16),
          const SizedBox(width: 8),
          Text(
            'Modo Dev: Qualquer login válido',
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF8FD39D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  final double scale;
  const _LoginHeader({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LogoIcon(assetPath: 'assets/soloforte.png', size: 58 * scale),
            SizedBox(width: 12 * scale),
            _LogoDivider(height: 44 * scale),
            SizedBox(width: 12 * scale),
            _LogoIcon(assetPath: 'assets/icons/icon.png', size: 72 * scale),
          ],
        ),
        SizedBox(height: 12 * scale),
        _BrandHeroBlock(scale: scale),
      ],
    );
  }
}

class _LogoIcon extends StatelessWidget {
  final String assetPath;
  final double size;

  const _LogoIcon({
    required this.assetPath,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(assetPath, fit: BoxFit.contain),
    );
  }
}

class _LogoDivider extends StatelessWidget {
  final double height;
  const _LogoDivider({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: height,
      color: const Color(0x40698173),
    );
  }
}

class _BrandHeroBlock extends StatelessWidget {
  final double scale;
  const _BrandHeroBlock({required this.scale});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showHero = constraints.maxWidth > 320;
        return Stack(
          children: [
            if (showHero)
              Positioned(
                right: 0,
                top: 4 * scale,
                bottom: 2,
                child: _HeroIllustrationSlot(scale: scale),
              ),
            Padding(
              padding: EdgeInsets.only(right: showHero ? 126 * scale : 0),
              child: _BrandCopy(scale: scale),
            ),
          ],
        );
      },
    );
  }
}

class _BrandCopy extends StatelessWidget {
  final double scale;
  const _BrandCopy({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.largeTitle.copyWith(
              fontSize: 43 * scale,
              height: 1.0,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
            children: const [
              TextSpan(
                  text: 'Caderno\n',
                  style: TextStyle(color: Color(0xFFE8ECEC))),
              TextSpan(text: 'de ', style: TextStyle(color: Color(0xFFE8ECEC))),
              TextSpan(
                  text: 'Solo', style: TextStyle(color: Color(0xFF7ACC49))),
            ],
          ),
        ),
        SizedBox(height: 8 * scale),
        Container(
          width: 50 * scale,
          height: 3.6 * scale,
          decoration: BoxDecoration(
            color: const Color(0xFF79C84A),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        SizedBox(height: 10 * scale),
        _BrandMessageCarousel(scale: scale),
      ],
    );
  }
}

class _HeroIllustrationSlot extends StatelessWidget {
  final double scale;
  const _HeroIllustrationSlot({required this.scale});

  static const String _heroAssetPath = 'assets/images/IMG_2664.jpeg';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148 * scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _AmbientGlow(size: 140 * scale, color: const Color(0x2D72C94A)),
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Color(0xFF47745D),
              BlendMode.multiply,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                _heroAssetPath,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMessageCarousel extends HookWidget {
  final double scale;
  const _BrandMessageCarousel({required this.scale});

  static const List<_BrandMessage> _messages = [
    _BrandMessage(
      highlight: 'Simples. Poderoso. Teu.',
      description: 'A experiência e a sabedoria falam alto na lavoura.',
    ),
    _BrandMessage(
      highlight: 'Tradição e tecnologia no mesmo solo.',
      description: 'Reúna prática de campo e decisão técnica com mais clareza.',
    ),
    _BrandMessage(
      highlight: 'Confiável para o dia a dia da propriedade.',
      description:
          'Acompanhe dados importantes sem perder o ritmo da operação.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(0);

    useEffect(() {
      final timer = Stream.periodic(const Duration(seconds: 4)).listen((_) {
        currentIndex.value = (currentIndex.value + 1) % _messages.length;
      });
      return timer.cancel;
    }, const []);

    return SizedBox(
      height: 96 * scale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.14),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Column(
              key: ValueKey<int>(currentIndex.value),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _messages[currentIndex.value].highlight,
                  style: AppTextStyles.label.copyWith(
                    color: const Color(0xFF73C847),
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  _messages[currentIndex.value].description,
                  style: AppTextStyles.body.copyWith(
                    color: const Color(0xFFA8B4B0),
                    fontSize: 14 * scale,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: List.generate(
              _messages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: currentIndex.value == index ? 12 * scale : 6 * scale,
                height: 6 * scale,
                margin: EdgeInsets.only(right: 6 * scale),
                decoration: BoxDecoration(
                  color: currentIndex.value == index
                      ? const Color(0xFF7BC94A)
                      : const Color(0xFF62706A),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMessage {
  final String highlight;
  final String description;

  const _BrandMessage({required this.highlight, required this.description});
}

class _AuthSegmentedControl extends StatelessWidget {
  final double scale;
  const _AuthSegmentedControl({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4 * scale),
      decoration: BoxDecoration(
        color: const Color(0xD0111E1A),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: const Color(0x33436152)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10 * scale),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11 * scale),
                gradient: const LinearGradient(
                  colors: [Color(0xFF5FBF3F), Color(0xFF3F8E28)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2E70C64A),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                AppStrings.login,
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(
                  color: Colors.white,
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.cadastro),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10 * scale),
                child: Text(
                  AppStrings.cadastro,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    color: const Color(0xFF8E9B96),
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w600,
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

class _DarkLoginCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final double scale;

  const _DarkLoginCard({
    required this.emailController,
    required this.senhaController,
    required this.isLoading,
    required this.onSubmit,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28 * scale),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xDD091311),
            borderRadius: BorderRadius.circular(28 * scale),
            border: Border.all(color: const Color(0x335BC852), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 26,
                offset: Offset(0, 14),
              ),
              BoxShadow(
                color: Color(0x1C5AB74D),
                blurRadius: 24,
                spreadRadius: -7,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            18 * scale,
            18 * scale,
            18 * scale,
            14 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RichText(
                text: TextSpan(
                  style: AppTextStyles.headline.copyWith(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Bem-vindo',
                      style: TextStyle(color: Color(0xFF7ECD49)),
                    ),
                    TextSpan(
                      text: ' de volta!',
                      style: TextStyle(color: Color(0xFFE7ECEA)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                'Faça login para continuar',
                style: AppTextStyles.body.copyWith(
                  color: const Color(0xFFADB6B2),
                  fontSize: 15 * scale,
                ),
              ),
              SizedBox(height: 14 * scale),
              _DarkInputField(
                controller: emailController,
                hint: 'seu@email.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.none,
                autofillHints: const [AutofillHints.email],
                prefixIcon: Icons.mail_outline,
                fontScale: scale,
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
              SizedBox(height: 10 * scale),
              _DarkInputField(
                controller: senhaController,
                hint: '••••••••',
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                prefixIcon: Icons.lock_outline,
                onSubmitted: (_) => onSubmit(),
                fontScale: scale,
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
              SizedBox(height: 3 * scale),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.recuperarSenha),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF79C84A),
                    padding: EdgeInsets.symmetric(
                      horizontal: 4 * scale,
                      vertical: 7 * scale,
                    ),
                  ),
                  child: Text(
                    AppStrings.esqueceuSenha,
                    style: AppTextStyles.label.copyWith(
                      color: const Color(0xFF79C84A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5 * scale),
              _PremiumLoginButton(
                label: AppStrings.entrar,
                isLoading: isLoading,
                onPressed: onSubmit,
                scale: scale,
              ),
              SizedBox(height: 12 * scale),
              _DividerWithText(text: 'ou', scale: scale),
              SizedBox(height: 12 * scale),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Novo por aqui?',
                    style: AppTextStyles.body.copyWith(
                      color: const Color(0xFFA6B0AC),
                      fontSize: 14 * scale,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.cadastro),
                    child: Text(
                      'Criar conta',
                      style: AppTextStyles.body.copyWith(
                        color: const Color(0xFF79C84A),
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final double fontScale;

  const _DarkInputField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.textInputAction,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onSubmitted,
    this.fontScale = 1,
  });

  @override
  State<_DarkInputField> createState() => _DarkInputFieldState();
}

class _DarkInputFieldState extends State<_DarkInputField> {
  late final FocusNode _focusNode;
  bool _focused = false;
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _obscured = widget.obscureText;
    _focusNode.addListener(() {
      if (mounted) {
        setState(() => _focused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        _focused ? const Color(0xFF76C84A) : const Color(0xFF34413D);

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      obscureText: _obscured,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      textCapitalization: widget.textCapitalization,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      style: AppTextStyles.input.copyWith(
        color: const Color(0xFFE8EEEA),
        fontSize: 16 * widget.fontScale,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTextStyles.input.copyWith(
          color: const Color(0xFF6D7A74),
          fontSize: 16 * widget.fontScale,
        ),
        filled: true,
        fillColor: const Color(0xFF0D1714),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        prefixIcon: Icon(
          widget.prefixIcon,
          color: const Color(0xFF74C84A),
          size: 22,
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
                onPressed: () => setState(() => _obscured = !_obscured),
                icon: Icon(
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF8A9591),
                  size: 22,
                ),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF76C84A), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE75A63), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE75A63), width: 1.4),
        ),
        errorStyle:
            AppTextStyles.error.copyWith(color: const Color(0xFFF18088)),
      ),
    );
  }
}

class _PremiumLoginButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final double scale;

  const _PremiumLoginButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    required this.scale,
  });

  @override
  State<_PremiumLoginButton> createState() => _PremiumLoginButtonState();
}

class _PremiumLoginButtonState extends State<_PremiumLoginButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.isLoading;

    return AnimatedScale(
      scale: _pressed && !disabled ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34 * widget.scale),
          gradient: const LinearGradient(
            colors: [Color(0xFF74C945), Color(0xFF3E9228)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3E72C94A),
              blurRadius: 18,
              offset: Offset(0, 9),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(34 * widget.scale),
          child: InkWell(
            borderRadius: BorderRadius.circular(34 * widget.scale),
            onTap: disabled ? null : widget.onPressed,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            child: SizedBox(
              height: 58 * widget.scale,
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: 0.35,
                            child: Icon(
                              Icons.spa_rounded,
                              color: const Color(0xFFBAE69C),
                              size: 20 * widget.scale,
                            ),
                          ),
                          SizedBox(width: 10 * widget.scale),
                          Text(
                            widget.label,
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                              fontSize: 20 * widget.scale,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(width: 14 * widget.scale),
                          Icon(
                            Icons.arrow_forward_rounded,
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

class _DividerWithText extends StatelessWidget {
  final String text;
  final double scale;

  const _DividerWithText({required this.text, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Color(0x3B70807A), thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10 * scale),
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: const Color(0xFF84918C),
              fontSize: 14 * scale,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: Color(0x3B70807A), thickness: 1),
        ),
      ],
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _AmbientGlow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
