import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';

/// Card expansível (accordion) para cada nutriente na tela de Calibração
class NutrienteCard extends StatefulWidget {
  const NutrienteCard({
    super.key,
    required this.nutriente,
    required this.icon,
    required this.cor,
    required this.children,
    this.initiallyExpanded = false,
    this.trailing,
  });

  /// Nome do nutriente (ex: 'Calcário')
  final String nutriente;

  /// Emoji ou ícone representativo
  final String icon;

  /// Cor identificadora da borda lateral
  final Color cor;

  /// Conteúdo do card quando expandido (campos de calibração)
  final List<Widget> children;

  /// Se começa expandido
  final bool initiallyExpanded;

  /// Widget adicional na linha do header (ex: badge com status)
  final Widget? trailing;

  @override
  State<NutrienteCard> createState() => _NutrienteCardState();
}

class _NutrienteCardState extends State<NutrienteCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.initiallyExpanded ? 1.0 : 0.0,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.borderSoft, width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header (clicável) ─────────────────────────
            GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.lg,
                  vertical: AppDimens.md,
                ),
                decoration: BoxDecoration(
                  color: _expanded
                      ? widget.cor.withValues(alpha: 0.06)
                      : Colors.white,
                ),
                child: Row(
                  children: [
                    // Barra colorida lateral
                    Container(
                      width: 4,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.cor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppDimens.md),

                    // Emoji/Ícone
                    Text(
                      widget.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: AppDimens.sm),

                    // Nome do nutriente
                    Expanded(
                      child: Text(
                        widget.nutriente,
                        style: AppTextStyles.value.copyWith(
                          color: _expanded
                              ? widget.cor.withValues(alpha: 0.85)
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),

                    // Trailing opcional
                    if (widget.trailing != null) ...[
                      widget.trailing!,
                      const SizedBox(width: AppDimens.sm),
                    ],

                    // Seta animada
                    RotationTransition(
                      turns: _rotateAnimation,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _expanded ? widget.cor : AppColors.textSecond,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Conteúdo expansível ──────────────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              firstCurve: Curves.easeOut,
              secondCurve: Curves.easeIn,
              crossFadeState: _expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.lg,
                  AppDimens.md,
                  AppDimens.lg,
                  AppDimens.lg,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: widget.cor.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < widget.children.length; i++) ...[
                      widget.children[i],
                      if (i < widget.children.length - 1)
                        const SizedBox(height: AppDimens.md),
                    ],
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 150.ms)
                  .slideY(begin: -0.05, end: 0, duration: 200.ms),
              secondChild: const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
