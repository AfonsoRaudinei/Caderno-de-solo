import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/analise/domain/value_objects/migracao_vinculos_result.dart';

/// Ação opcional de migração em massa Cliente ↔ Análises (Config).
class MigracaoVinculosActionTile extends ConsumerStatefulWidget {
  const MigracaoVinculosActionTile({super.key});

  @override
  ConsumerState<MigracaoVinculosActionTile> createState() =>
      _MigracaoVinculosActionTileState();
}

class _MigracaoVinculosActionTileState
    extends ConsumerState<MigracaoVinculosActionTile> {
  bool _isRunning = false;

  Future<void> _executar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vincular análises legadas'),
        content: const Text(
          'Tenta associar análises antigas aos clientes cadastrados por '
          'correspondência de nomes. Análises sem match recebem status '
          '"Vínculo pendente". Nenhum registro será apagado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Executar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    setState(() => _isRunning = true);
    MigracaoVinculosResult result;
    try {
      result = await ref
          .read(analiseNotifierProvider.notifier)
          .executarMigracaoVinculosLegados();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRunning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha na migração: $e')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isRunning = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_mensagemResultado(result))),
    );
  }

  String _mensagemResultado(MigracaoVinculosResult result) {
    if (!result.executada) {
      return 'Migração não executada. Verifique login e cadastro de clientes.';
    }
    if (!result.teveAlteracao && result.falhas == 0) {
      return 'Nenhuma análise precisou de migração (${result.jaVinculadas} já vinculadas).';
    }
    final partes = <String>[
      if (result.reparadas > 0) '${result.reparadas} vinculada(s)',
      if (result.marcadasPendentes > 0)
        '${result.marcadasPendentes} pendente(s)',
      if (result.falhas > 0) '${result.falhas} falha(s)',
    ];
    return 'Migração concluída: ${partes.join(', ')}.';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return InkWell(
      onTap: _isRunning ? null : _executar,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vincular análises legadas',
                    style: TextStyle(
                      fontSize: 15,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Associa laudos antigos aos clientes por nome',
                    style: AppTextStyles.caption.copyWith(
                      color: palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (_isRunning)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else
              Icon(
                Icons.sync_rounded,
                size: 20,
                color: palette.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
