import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_theme.dart';

class MapaFabModulos extends StatelessWidget {
  final VoidCallback onPressed;

  const MapaFabModulos({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      heroTag: 'fab_modulos',
      elevation: 8,
      highlightElevation: 4,
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: const Icon(
        Icons.apps_rounded,
        color: AppColors.bgPrimary,
        size: 26,
      ),
    );
  }
}
