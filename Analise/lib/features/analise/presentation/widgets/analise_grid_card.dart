import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

enum AnaliseGridCardAction { viewDetails, delete }

class AnaliseGridCard extends StatelessWidget {
  const AnaliseGridCard({
    super.key,
    required this.analise,
    required this.onTap,
    required this.onDelete,
  });

  final AnaliseSolo analise;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final data = DateFormat('dd/MM/yyyy').format(analise.dataCadastro);
    final titulo =
        analise.talhao.trim().isEmpty ? 'Sem talhao' : analise.talhao;
    final subtitulo = '${analise.cultura.label} · $data';

    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: () => _onLongPress(context),
        child: Ink(
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(12),
            border: palette.isDark
                ? Border.all(color: palette.border, width: 0.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.science,
                  size: 48,
                  color: analise.cultura.color,
                ),
                const SizedBox(height: 12),
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onLongPress(BuildContext context) async {
    final palette = context.appPalette;
    final action = await showModalBottomSheet<AnaliseGridCardAction>(
      context: context,
      backgroundColor: palette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.visibility_outlined, color: palette.accent),
                title: Text('Ver detalhes',
                    style: TextStyle(color: palette.textPrimary)),
                onTap: () => Navigator.of(context)
                    .pop(AnaliseGridCardAction.viewDetails),
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Excluir'),
                textColor: AppColors.error,
                onTap: () =>
                    Navigator.of(context).pop(AnaliseGridCardAction.delete),
              ),
            ],
          ),
        );
      },
    );

    if (action == AnaliseGridCardAction.viewDetails) {
      onTap();
    } else if (action == AnaliseGridCardAction.delete) {
      onDelete();
    }
  }
}
