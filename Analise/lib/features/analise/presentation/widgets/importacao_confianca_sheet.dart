import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/data/lab_templates/lab_detector.dart';

class ImportacaoConfiancaSheet extends StatefulWidget {
  final List<LabDetectionCandidate> ranking;
  final String? suggestedLabId;
  final double confidence;
  final List<String> sampleHints;
  final ValueChanged<String> onConfirm;

  const ImportacaoConfiancaSheet({
    super.key,
    required this.ranking,
    required this.suggestedLabId,
    required this.confidence,
    required this.sampleHints,
    required this.onConfirm,
  });

  @override
  State<ImportacaoConfiancaSheet> createState() =>
      _ImportacaoConfiancaSheetState();
}

class _ImportacaoConfiancaSheetState extends State<ImportacaoConfiancaSheet> {
  late String _selectedLabId;

  @override
  void initState() {
    super.initState();
    _selectedLabId = widget.suggestedLabId ?? _orderedLabIds.first;
  }

  @override
  Widget build(BuildContext context) {
    final confidencePct =
        (widget.confidence * 100).clamp(0, 100).toStringAsFixed(0);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Confirmar laboratório',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Detecção automática com baixa confiança ($confidencePct%). '
              'Selecione o laboratório e confirme para continuar.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedLabId,
              decoration: InputDecoration(
                labelText: 'Laboratório',
                filled: true,
                fillColor: AppColors.bgSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _orderedLabIds.map((labId) {
                return DropdownMenuItem<String>(
                  value: labId,
                  child: Text(_labelForLab(labId)),
                );
              }).toList(growable: false),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedLabId = value);
              },
            ),
            if (widget.sampleHints.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Pré-visualização de amostras identificadas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.sampleHints
                    .take(6)
                    .map(
                      (hint) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          hint,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () => widget.onConfirm(_selectedLabId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Importar com este laboratório',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bgSecondary,
                  foregroundColor: const Color(0xFF1D1D1F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> get _orderedLabIds {
    final rankedIds =
        widget.ranking.map((c) => c.labId).toList(growable: false);
    final unique = <String>{
      ...rankedIds,
      'sellar',
      'exata_brasil',
      'ibra',
      'mb'
    };
    return unique.toList(growable: false);
  }

  String _labelForLab(String labId) {
    switch (labId) {
      case 'sellar':
        return 'Sellar';
      case 'exata_brasil':
        return 'Exata Brasil';
      case 'ibra':
        return 'IBRA';
      case 'mb':
      case 'mb_agronegocios':
        return 'MB Agronegócios';
      default:
        return labId;
    }
  }
}
