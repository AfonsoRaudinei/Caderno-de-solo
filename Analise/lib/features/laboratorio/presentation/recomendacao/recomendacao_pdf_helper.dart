import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';

class RecomendacaoPdfHelper {
  static Future<void> exportar({
    required ResultadoRecomendacao resultado,
    required BuildContext context,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              pw.Text(
                'Caderno de Solo — Recomendação',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Gerado em: ${DateTime.now().toString().substring(0, 16)}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
              pw.Divider(height: 24),

              // Argumentos técnicos
              pw.Text(
                'CULTURA RECOMENDADA',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600,
                  letterSpacing: 0.5,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                resultado.calibracao.nome,
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 16),

              // Doses
              pw.Text(
                'DOSES RECOMENDADAS',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600,
                  letterSpacing: 0.5,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Dose de Calcário: ${resultado.doseCalcarioTHa.toStringAsFixed(2)} t/ha'),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'recomendacao_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}
