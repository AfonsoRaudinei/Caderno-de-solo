import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
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
    final data = DateFormat('dd/MM/yyyy').format(analise.dataCadastro);
    final titulo = analise.talhao.trim().isEmpty ? 'Sem talhao' : analise.talhao;
    final subtitulo = '${analise.cultura.label} · $data';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: () => _onLongPress(context),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
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
                    color: const Color(0xFF1D1D1F),
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
                    color: const Color(0xFF86868B),
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
    final action = await showModalBottomSheet<AnaliseGridCardAction>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('Ver detalhes'),
                onTap: () => Navigator.of(context).pop(AnaliseGridCardAction.viewDetails),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFFF3B30)),
                title: const Text('Excluir'),
                textColor: const Color(0xFFFF3B30),
                onTap: () => Navigator.of(context).pop(AnaliseGridCardAction.delete),
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
