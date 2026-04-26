import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';

class AnaliseSectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;

  const AnaliseSectionHeader({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.bgSecondary,
      padding: padding,
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          color: AppColors.textSecond,
        ),
      ),
    );
  }
}
