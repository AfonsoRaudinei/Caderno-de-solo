import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';

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
      elevation: 6,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.dashboard_outlined, color: AppColors.bgPrimary),
    );
  }
}
