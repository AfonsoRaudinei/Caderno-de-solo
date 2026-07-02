import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';

/// Título de subseção em uppercase.
/// Extraído de calibracao_page.dart (_SubSectionTitle).
class CalibracaoSubsectionTitle extends StatelessWidget {
  const CalibracaoSubsectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.sectionLabel.copyWith(color: palette.textSecondary),
    );
  }
}
