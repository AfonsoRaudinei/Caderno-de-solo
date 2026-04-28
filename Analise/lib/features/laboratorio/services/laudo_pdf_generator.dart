import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:soloforte/features/laboratorio/domain/entities/laudo_recomendacao.dart';

/// Motor de geração e compartilhamento de PDF para o Laudo de Recomendação.
///
/// Produz um documento técnico de 2-3 páginas com:
/// - Capa (identificação, datas, calibração usada)
/// - Página de Calcário e Gesso (com V% antes/depois, dose, parcelamento)
/// - Página de Nutrientes (Fósforo, Potássio e Micronutrientes lado a lado)
/// - Rodapé com Argumentos Bibliográficos e Avisos de qualidade
class LaudoPdfGenerator {
  const LaudoPdfGenerator._();

  // ── Palette ──────────────────────────────────────────────────────────────

  static const _verde = PdfColor.fromInt(0xFF1B5E20);
  static const _verdeClaro = PdfColor.fromInt(0xFF4CAF50);
  static const _laranjaAgro = PdfColor.fromInt(0xFFE65100);
  static const _azul = PdfColor.fromInt(0xFF0D47A1);
  static const _cinzaFundo = PdfColor.fromInt(0xFFF5F5F5);
  static const _cinzaBorda = PdfColor.fromInt(0xFFBDBDBD);
  static const _preto = PdfColor.fromInt(0xFF212121);
  static const _cinzaTexto = PdfColor.fromInt(0xFF616161);
  static const _branco = PdfColors.white;

  // ── Ponto de entrada público ─────────────────────────────────────────────

  /// Gera o PDF em memória, salva no temp e abre o diálogo de compartilhamento.
  static Future<void> gerarECompartilhar(LaudoRecomendacao laudo) async {
    final bytes = await _buildPdf(laudo);

    final dir = await getTemporaryDirectory();
    final nomeArquivo =
        'laudo_${laudo.talhao.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmm').format(laudo.geradaEm)}.pdf';
    final file = File('${dir.path}/$nomeArquivo');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'Laudo de Recomendação — ${laudo.talhao}',
      text: 'Segue o laudo agronômico gerado pelo Caderno de Solo.',
    );
  }

  // ── Builder principal ────────────────────────────────────────────────────

  static Future<List<int>> _buildPdf(LaudoRecomendacao laudo) async {
    final doc = pw.Document(
      title: 'Laudo de Recomendação — ${laudo.talhao}',
      author: 'Caderno de Solo · SoloForte',
      creator: 'SoloForte App',
    );

    final boldFont = pw.Font.helveticaBold();
    final regularFont = pw.Font.helvetica();
    final italicFont = pw.Font.helveticaOblique();

    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      italic: italicFont,
    );

    // ── Página 1: Capa + Calcário + Gesso ───────────────────────────────
    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 40),
          theme: theme,
          buildBackground: (context) => _buildBackground(),
        ),
        header: (context) => _buildHeader(laudo),
        footer: (context) => _buildFooter(context, laudo),
        build: (context) => [
          _buildIdentificacao(laudo),
          pw.SizedBox(height: 14),
          _buildSecaoCalcario(laudo),
          pw.SizedBox(height: 14),
          _buildSecaoGesso(laudo),
        ],
      ),
    );

    // ── Página 2: Nutrientes + Micros + Avisos + Argumentos ─────────────
    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 40),
          theme: theme,
          buildBackground: (context) => _buildBackground(),
        ),
        header: (context) => _buildHeader(laudo),
        footer: (context) => _buildFooter(context, laudo),
        build: (context) => [
          _buildSecaoNutrientes(laudo),
          pw.SizedBox(height: 14),
          if (laudo.micros.isNotEmpty) ...[
            _buildSecaoMicros(laudo),
            pw.SizedBox(height: 14),
          ],
          if (laudo.avisos.isNotEmpty) ...[
            _buildSecaoAvisos(laudo),
            pw.SizedBox(height: 14),
          ],
          _buildSecaoArgumentos(laudo),
        ],
      ),
    );

    return doc.save();
  }

  // ── Background watermark ────────────────────────────────────────────────

  static pw.Widget _buildBackground() {
    return pw.FullPage(
      ignoreMargins: true,
      child: pw.Positioned(
        bottom: 60,
        right: 30,
        child: pw.Opacity(
          opacity: 0.04,
          child: pw.Text(
            'CADERNO\nDE SOLO',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 72,
              fontWeight: pw.FontWeight.bold,
              color: _verde,
            ),
          ),
        ),
      ),
    );
  }

  // ── Cabeçalho ────────────────────────────────────────────────────────────

  static pw.Widget _buildHeader(LaudoRecomendacao laudo) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _verde, width: 2)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 8),
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'LAUDO DE RECOMENDAÇÃO AGRONÔMICA',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: _verde,
                ),
              ),
              pw.Text(
                'Caderno de Solo · SoloForte',
                style: const pw.TextStyle(fontSize: 8, color: _cinzaTexto),
              ),
            ],
          ),
          pw.Text(
            DateFormat('dd/MM/yyyy').format(laudo.geradaEm),
            style: const pw.TextStyle(fontSize: 9, color: _cinzaTexto),
          ),
        ],
      ),
    );
  }

  // ── Rodapé ───────────────────────────────────────────────────────────────

  static pw.Widget _buildFooter(pw.Context context, LaudoRecomendacao laudo) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: _cinzaBorda))),
      padding: const pw.EdgeInsets.only(top: 6),
      margin: const pw.EdgeInsets.only(top: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Calibração: ${laudo.nomeCalibra} · Gerado por SoloForte',
            style: const pw.TextStyle(fontSize: 7, color: _cinzaTexto),
          ),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 7, color: _cinzaTexto),
          ),
        ],
      ),
    );
  }

  // ── Seção: Identificação ─────────────────────────────────────────────────

  static pw.Widget _buildIdentificacao(LaudoRecomendacao laudo) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return _card(
      titulo: '📋  IDENTIFICAÇÃO',
      corTitulo: _verde,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoRow('Cliente', laudo.cliente),
                _infoRow('Fazenda', laudo.fazenda),
                _infoRow('Talhão / Área', laudo.talhao),
                _infoRow('Laboratório', laudo.laboratorio),
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoRow('Cultura', laudo.cultura),
                _infoRow('Safra', laudo.safra),
                _infoRow('Calibração', laudo.nomeCalibra),
                _infoRow('Emitido em', fmt.format(laudo.geradaEm)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Seção: Calcário ──────────────────────────────────────────────────────

  static pw.Widget _buildSecaoCalcario(LaudoRecomendacao laudo) {
    const f = _fmt;
    return _card(
      titulo: '🪨  CALCÁRIO',
      corTitulo: _azul,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _metodoBadge(laudo.metodoCalagem, _azul),
          pw.SizedBox(height: 8),
          // Dose principal em destaque
          pw.Container(
            width: double.infinity,
            padding:
                const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: pw.BoxDecoration(
              color: _azul,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              '${f(laudo.doseCalcarioTHa, 2)} t/ha de calcário',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: _branco,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          // Tabela evolução V% / Ca / Mg
          _tabelaEvolucao(
            linhas: [
              ['Parâmetro', 'Atual', 'Esperado após aplicação'],
              [
                'V% (Sat. de Bases)',
                '${f(laudo.vAtual, 1)}%',
                '${f(laudo.vEsperado, 1)}%'
              ],
              ['Ca (cmolc/dm³)', f(laudo.caAtual, 2), f(laudo.caEsperado, 2)],
              ['Mg (cmolc/dm³)', f(laudo.mgAtual, 2), f(laudo.mgEsperado, 2)],
              ['Relação Ca:Mg', '${f(laudo.relacaoCaMg, 2)}:1', '—'],
            ],
          ),
          // Parcelamento
          if (laudo.parcelamento.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _subtitulo('Parcelamento recomendado:'),
            ...laudo.parcelamento.map((item) => _bullet(item)),
          ],
        ],
      ),
    );
  }

  // ── Seção: Gesso ─────────────────────────────────────────────────────────

  static pw.Widget _buildSecaoGesso(LaudoRecomendacao laudo) {
    return _card(
      titulo: '🧱  GESSO AGRÍCOLA',
      corTitulo: _laranjaAgro,
      child: laudo.gessoIndicado
          ? pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _statusBadge('Gessagem Indicada', true),
                pw.SizedBox(height: 8),
                pw.Text(
                  '${_fmt(laudo.gessoKgHa, 0)} kg/ha',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: _laranjaAgro,
                  ),
                ),
              ],
            )
          : _statusBadge('Gessagem não indicada para esta amostra', false),
    );
  }

  // ── Seção: Nutrientes (P e K) ─────────────────────────────────────────────

  static pw.Widget _buildSecaoNutrientes(LaudoRecomendacao laudo) {
    const f = _fmt;
    return _card(
      titulo: '🌱  MACRONUTRIENTES',
      corTitulo: _verdeClaro,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Fósforo
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _subtitulo('Fósforo (P)'),
                _metodoBadge(laudo.modoFosforo, _verdeClaro),
                pw.SizedBox(height: 6),
                _infoRow('P solo', '${f(laudo.pSoloMgDm3, 1)} mg/dm³'),
                _infoRow(
                    'NC (nível crítico)', '${f(laudo.ncFosforo, 1)} mg/dm³'),
                _infoRow(
                    'Status',
                    laudo.pSoloMgDm3 >= laudo.ncFosforo
                        ? '✅ Acima do NC'
                        : '⚠️ Abaixo do NC'),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: _verdeClaro,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text(
                    '${f(laudo.doseP2O5KgHa, 1)} kg P₂O₅/ha',
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: _branco,
                    ),
                  ),
                ),
                if (laudo.legacyP) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Solo acima do NC — dose mínima de manutenção aplicada.',
                    style: pw.TextStyle(
                        fontSize: 7,
                        color: _laranjaAgro,
                        fontStyle: pw.FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          // Potássio
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _subtitulo('Potássio (K)'),
                _metodoBadge(laudo.criterioPotassio, _laranjaAgro),
                pw.SizedBox(height: 6),
                _infoRow('K solo', '${f(laudo.kSolo, 2)} cmolc/dm³'),
                _infoRow('NC', f(laudo.ncPotassio, 2)),
                _infoRow(
                    'Status',
                    laudo.kSolo >= laudo.ncPotassio
                        ? '✅ Acima do NC'
                        : '⚠️ Abaixo do NC'),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: _laranjaAgro,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Text(
                    '${f(laudo.doseK2OKgHa, 1)} kg K₂O/ha',
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: _branco,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Seção: Micronutrientes ────────────────────────────────────────────────

  static pw.Widget _buildSecaoMicros(LaudoRecomendacao laudo) {
    return _card(
      titulo: '🔬  MICRONUTRIENTES',
      corTitulo: _cinzaTexto,
      child: pw.Wrap(
        spacing: 8,
        runSpacing: 8,
        children: laudo.micros.map((m) {
          final simbolo = m['simbolo']?.toString() ?? '?';
          final dose = m['doseProdutoLabel']?.toString() ?? '';
          final via = m['via']?.toString() ?? '';
          final fonte = m['fonte']?.toString() ?? '';
          return pw.Container(
            width: 150,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: _cinzaFundo,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: _cinzaBorda),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(simbolo,
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                        color: _preto)),
                pw.Text(dose,
                    style: const pw.TextStyle(fontSize: 9, color: _azul)),
                pw.Text('Via: $via',
                    style: const pw.TextStyle(fontSize: 8, color: _cinzaTexto)),
                pw.Text('Fonte: $fonte',
                    style: const pw.TextStyle(fontSize: 8, color: _cinzaTexto)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Seção: Avisos ─────────────────────────────────────────────────────────

  static pw.Widget _buildSecaoAvisos(LaudoRecomendacao laudo) {
    return _card(
      titulo: '⚠️  AVISOS TÉCNICOS',
      corTitulo: _laranjaAgro,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: laudo.avisos
            .map((a) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFFFFF3E0),
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: _laranjaAgro),
                  ),
                  child: pw.Text(a,
                      style:
                          const pw.TextStyle(fontSize: 9, color: _laranjaAgro)),
                ))
            .toList(),
      ),
    );
  }

  // ── Seção: Argumentos Bibliográficos ─────────────────────────────────────

  static pw.Widget _buildSecaoArgumentos(LaudoRecomendacao laudo) {
    return _card(
      titulo: '📚  FUNDAMENTOS TÉCNICOS E REFERÊNCIAS BIBLIOGRÁFICAS',
      corTitulo: _preto,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            laudo.argumentos,
            style: const pw.TextStyle(fontSize: 8, color: _cinzaTexto),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _cinzaFundo,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: _cinzaBorda),
            ),
            child: pw.Text(
              'Este laudo foi gerado automaticamente com base nos dados inseridos '
              'e nos parâmetros de calibração configurados pelo responsável técnico. '
              'As recomendações devem ser validadas e assinadas por um Engenheiro '
              'Agrônomo habilitado conforme legislação vigente (CREA/CFMV).',
              style: pw.TextStyle(
                  fontSize: 7,
                  color: _cinzaTexto,
                  fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers construtores ─────────────────────────────────────────────────

  static pw.Widget _card({
    required String titulo,
    required pw.Widget child,
    required PdfColor corTitulo,
  }) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _cinzaBorda),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Cabeçalho do card
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: pw.BoxDecoration(
              color: corTitulo,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(7),
                topRight: pw.Radius.circular(7),
              ),
            ),
            child: pw.Text(
              titulo,
              style: pw.TextStyle(
                  fontSize: 10, fontWeight: pw.FontWeight.bold, color: _branco),
            ),
          ),
          // Corpo
          pw.Padding(
            padding: const pw.EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(
              '$label:',
              style: const pw.TextStyle(fontSize: 8, color: _cinzaTexto),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value.isEmpty ? '—' : value,
              style: pw.TextStyle(
                  fontSize: 8, fontWeight: pw.FontWeight.bold, color: _preto),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _subtitulo(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            fontSize: 9, fontWeight: pw.FontWeight.bold, color: _preto),
      ),
    );
  }

  static pw.Widget _bullet(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3, left: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('• ', style: const pw.TextStyle(fontSize: 8, color: _verde)),
          pw.Expanded(
              child: pw.Text(text,
                  style: const pw.TextStyle(fontSize: 8, color: _preto))),
        ],
      ),
    );
  }

  static pw.Widget _metodoBadge(String metodo, PdfColor cor) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: cor.shade(0.15),
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: cor),
      ),
      child: pw.Text(
        metodo,
        style: pw.TextStyle(fontSize: 7, color: cor),
      ),
    );
  }

  static pw.Widget _statusBadge(String texto, bool positivo) {
    final cor = positivo ? _laranjaAgro : const PdfColor.fromInt(0xFF388E3C);
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: cor.shade(0.1),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: cor),
      ),
      child: pw.Text(
        texto,
        style: pw.TextStyle(fontSize: 9, color: cor),
      ),
    );
  }

  static pw.Widget _tabelaEvolucao({required List<List<String>> linhas}) {
    return pw.Table(
      border: pw.TableBorder.all(color: _cinzaBorda, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.5),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(2),
      },
      children: linhas.asMap().entries.map((entry) {
        final isHeader = entry.key == 0;
        return pw.TableRow(
          decoration: pw.BoxDecoration(
            color:
                isHeader ? _azul : (entry.key.isEven ? _cinzaFundo : _branco),
          ),
          children: entry.value
              .map((cell) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 5),
                    child: pw.Text(
                      cell,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: isHeader
                            ? pw.FontWeight.bold
                            : pw.FontWeight.normal,
                        color: isHeader ? _branco : _preto,
                      ),
                    ),
                  ))
              .toList(),
        );
      }).toList(),
    );
  }

  static String _fmt(double value, int decimals) {
    return value.toStringAsFixed(decimals).replaceAll('.', ',');
  }
}
