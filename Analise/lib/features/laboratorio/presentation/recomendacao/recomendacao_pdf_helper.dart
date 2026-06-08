import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';
import 'package:soloforte/features/config/domain/entities/perfil_assets.dart';

class RecomendacaoPdfHelper {
  static Future<void> exportar({
    required ResultadoRecomendacao resultado,
    required BuildContext context,
    required PerfilAssets perfilAssets,
  }) async {
    final pdf = pw.Document();
    final pdfAssets = await _loadPdfAssets(perfilAssets);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 40),
        header: (ctx) => _buildHeader(
          resultado,
          ctx.pageNumber,
          pdfAssets.logo,
        ),
        footer: (ctx) => _buildFooter(ctx),
        build: (ctx) => [
          _secao('IDENTIFICAÇÃO', _buildIdentificacao(resultado)),
          pw.SizedBox(height: 16),
          _secao('ANÁLISE DE SOLO', _buildAnalise(resultado)),
          pw.SizedBox(height: 16),
          _secao('CALAGEM', _buildCalagem(resultado)),
          if (resultado.gesso.indicado) ...[
            pw.SizedBox(height: 16),
            _secao('GESSAGEM', _buildGessagem(resultado)),
          ],
          pw.SizedBox(height: 16),
          _secao('FÓSFORO (P₂O₅)', _buildFosforo(resultado)),
          pw.SizedBox(height: 16),
          _secao('POTÁSSIO (K₂O)', _buildPotassio(resultado)),
          if (resultado.micros.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _secao('MICRONUTRIENTES', _buildMicros(resultado)),
          ],
          if (resultado.grupos.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _secao('GRUPOS DE APLICAÇÃO', _buildGrupos(resultado)),
          ],
          if (resultado.avisos.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _secao('AVISOS', _buildAvisos(resultado)),
          ],
          pw.SizedBox(height: 16),
          _secao('ARGUMENTOS TÉCNICOS', _buildArgumentos(resultado)),
          pw.SizedBox(height: 16),
          _secao('CITAÇÕES', _buildCitacoes(resultado)),
          if (pdfAssets.assinatura != null) ...[
            pw.SizedBox(height: 20),
            _buildAssinatura(pdfAssets.assinatura!),
          ],
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'recomendacao_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf',
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────

  static Future<_PdfAssets> _loadPdfAssets(PerfilAssets perfilAssets) async {
    final logo = await _loadNetworkImage(perfilAssets.logoUrl);
    final assinatura = await _loadNetworkImage(perfilAssets.assinaturaUrl);
    return _PdfAssets(logo: logo, assinatura: assinatura);
  }

  static Future<pw.ImageProvider?> _loadNetworkImage(String? url) async {
    if (url == null || url.trim().isEmpty) return null;
    try {
      return await networkImage(url);
    } catch (_) {
      return null;
    }
  }

  static pw.Widget _buildHeader(
    ResultadoRecomendacao r,
    int pageNumber,
    pw.ImageProvider? logo,
  ) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blueAccent700, width: 2),
        ),
      ),
      padding: const pw.EdgeInsets.only(bottom: 8),
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              if (logo != null) ...[
                pw.Container(
                  width: 86,
                  height: 42,
                  margin: const pw.EdgeInsets.only(right: 10),
                  child: pw.Image(logo, fit: pw.BoxFit.contain),
                ),
              ],
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Caderno de Solo — Recomendação de Adubação',
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    r.calibracao.nome,
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ),
            ],
          ),
          pw.Text(
            'Pág. $pageNumber',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAssinatura(pw.ImageProvider assinatura) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          width: 180,
          height: 64,
          child: pw.Image(assinatura, fit: pw.BoxFit.contain),
        ),
        pw.Container(
          width: 220,
          margin: const pw.EdgeInsets.only(top: 2),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.grey600, width: 0.6),
            ),
          ),
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Text(
            'Responsável técnico',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ),
      ],
    );
  }

  // ─── FOOTER ────────────────────────────────────────────────────────────────

  static pw.Widget _buildFooter(pw.Context ctx) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      padding: const pw.EdgeInsets.only(top: 6),
      margin: const pw.EdgeInsets.only(top: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Gerado em: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
          pw.Text(
            'Caderno de Solo',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  // ─── SEÇÃO WRAPPER ─────────────────────────────────────────────────────────

  static pw.Widget _secao(String titulo, pw.Widget conteudo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            titulo,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
              letterSpacing: 0.8,
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        conteudo,
      ],
    );
  }

  // ─── BLOCOS DE CONTEÚDO ───────────────────────────────────────────────────

  static pw.Widget _buildIdentificacao(ResultadoRecomendacao r) {
    final analise = r.analise;
    final calibracao = r.calibracao;
    final geradaEm = r.geradaEm != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(r.geradaEm!)
        : '—';

    return _tabela([
      ['Talhão', analise.talhao, 'Fazenda', calibracao.fazenda],
      ['Cliente', calibracao.cliente, 'Cultura', calibracao.cultura],
      ['Safra', calibracao.safra, 'Laboratório', analise.nome],
      ['Calibração', calibracao.nome, 'Gerado em', geradaEm],
    ]);
  }

  static pw.Widget _buildAnalise(ResultadoRecomendacao r) {
    final a = r.analise;
    return pw.Column(
      children: [
        _tabela([
          ['pH', _f(a.ph, 1), 'M.O. (g/dm³)', _f(a.mo, 1)],
          [
            'V% atual',
            '${_f(a.vPercent, 1)}%',
            'Argila (%)',
            '${_f(a.argila, 0)}%'
          ],
          ['CTC (mmolc/dm³)', _f(a.ctc, 1), 'H+Al', _f(a.hAl, 1)],
          ['Ca (mmolc/dm³)', _f(a.ca, 1), 'Mg (mmolc/dm³)', _f(a.mg, 1)],
          ['K (mmolc/dm³)', _f(a.k, 3), 'Al (mmolc/dm³)', _f(a.al, 1)],
          ['P (mg/dm³)', _f(a.p, 1), 'S (mg/dm³)', _f(a.s, 1)],
          ['B (mg/dm³)', _f(a.b, 2), 'Cu (mg/dm³)', _f(a.cu, 2)],
          ['Fe (mg/dm³)', _f(a.fe, 1), 'Mn (mg/dm³)', _f(a.mn, 2)],
          ['Zn (mg/dm³)', _f(a.zn, 2), 'SB (mmolc/dm³)', _f(a.sb, 1)],
        ]),
      ],
    );
  }

  static pw.Widget _buildCalagem(ResultadoRecomendacao r) {
    final rows = <pw.Widget>[
      _tabela([
        ['Método', r.metodoCalagem, 'Dose', '${_f(r.doseCalcarioTHa, 2)} t/ha'],
        [
          'V% alvo',
          '${_f(r.vEsperado, 1)}%',
          'V% atual',
          '${_f(r.analise.vPercent, 1)}%'
        ],
        [
          'Ca esperado',
          '${_f(r.caEsperado, 2)} mmolc/dm³',
          'Mg esperado',
          '${_f(r.mgEsperado, 2)} mmolc/dm³'
        ],
        ['Relação Ca:Mg', _f(r.relacaoCaMg, 2), '', ''],
      ]),
    ];

    if (r.parcelamento.isNotEmpty) {
      rows.add(pw.SizedBox(height: 6));
      rows.add(_label('Parcelamento:'));
      for (final p in r.parcelamento) {
        rows.add(_bullet(p));
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: rows,
    );
  }

  static pw.Widget _buildGessagem(ResultadoRecomendacao r) {
    final g = r.gesso;
    return _tabela([
      [
        'Indicado',
        g.indicado ? 'Sim' : 'Não',
        'Dose',
        '${_f(g.doseKgHa, 0)} kg/ha'
      ],
      [
        'Dose (t/ha)',
        '${_f(g.doseTHa, 2)} t/ha',
        'S fornecido',
        '${_f(g.sFornecidoKgHa, 1)} kg/ha'
      ],
      [
        'Ca fornecido',
        '${_f(g.caFornecidoKgHa, 1)} kg/ha',
        'Ca aumento',
        '${_f(g.caAumentoCmolcDm3, 2)} mmolc/dm³'
      ],
    ]);
  }

  static pw.Widget _buildFosforo(ResultadoRecomendacao r) {
    final rows = <pw.Widget>[
      _tabela([
        ['Modo', r.modoFosforo, 'P atual', '${_f(r.analise.p, 1)} mg/dm³'],
        [
          'NC fósforo',
          '${_f(r.ncFosforo, 1)} mg/dm³',
          'Dose P₂O₅',
          '${_f(r.doseP2O5KgHa, 1)} kg/ha'
        ],
        ['Legacy P', r.legacyP ? 'Sim — piso de manutenção' : 'Não', '', ''],
      ]),
    ];

    if (r.doseAbsorcaoP != null) {
      rows.add(pw.SizedBox(height: 4));
      rows.add(_infoLine('Absorção/Exportação (informativo):',
          '${_f(r.doseAbsorcaoP!, 1)} kg/ha P₂O₅'));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: rows,
    );
  }

  static pw.Widget _buildPotassio(ResultadoRecomendacao r) {
    final rows = <pw.Widget>[
      _tabela([
        [
          'Critério',
          r.criterioPotassio,
          'K atual',
          '${_f(r.analise.k, 3)} mmolc/dm³'
        ],
        [
          'NC potássio',
          _f(r.ncPotassio, 1),
          'Dose K₂O',
          '${_f(r.doseK2OKgHa, 1)} kg/ha'
        ],
        ['K% na CTC', '${_f(r.relacoesK.kNaCTC, 2)}%', '', ''],
      ]),
    ];

    final alertas = r.relacoesK.alertas;
    if (alertas.isNotEmpty) {
      rows.add(pw.SizedBox(height: 4));
      rows.add(_label('Antagonismos:'));
      for (final a in alertas) {
        rows.add(_bullet(a));
      }
    }

    if (r.doseAbsorcaoK != null) {
      rows.add(pw.SizedBox(height: 4));
      rows.add(_infoLine('Absorção/Exportação (informativo):',
          '${_f(r.doseAbsorcaoK!, 1)} kg/ha K₂O'));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: rows,
    );
  }

  static pw.Widget _buildMicros(ResultadoRecomendacao r) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1.2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(1.8),
      },
      children: [
        // Cabeçalho
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: ['Elemento', 'Via', 'Atual', 'NC', 'Dose', 'Produto']
              .map((h) => _celulaCabecalho(h))
              .toList(),
        ),
        // Linhas
        ...r.micros.map(
          (m) => pw.TableRow(
            children: [
              _celula(m.elemento),
              _celula(m.via),
              _celula('${_f(m.valorAtual, 2)} mg/dm³'),
              _celula('${_f(m.nc, 2)} mg/dm³'),
              _celula('${_f(m.dose, 1)} ${m.unidade}'),
              _celula(m.doseProdutoLabel),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildGrupos(ResultadoRecomendacao r) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: r.grupos.map((g) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                g.nomeGrupo,
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              ),
              pw.SizedBox(height: 4),
              _infoLine('Via:', g.via),
              _infoLine('Produto:', g.produto),
              _infoLine('Dose produto:', g.doseProdutoKgLabel),
              _infoLine('Fornecimento:', g.fornecimento),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildAvisos(ResultadoRecomendacao r) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: r.avisos
          .map((a) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 4),
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange50,
                  border: pw.Border.all(color: PdfColors.orange200, width: 0.5),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('⚠ ',
                        style: const pw.TextStyle(
                            color: PdfColors.orange800, fontSize: 9)),
                    pw.Expanded(
                      child: pw.Text(a,
                          style: const pw.TextStyle(
                              fontSize: 9, color: PdfColors.orange900)),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  static pw.Widget _buildArgumentos(ResultadoRecomendacao r) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        r.argumentos,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
      ),
    );
  }

  static pw.Widget _buildCitacoes(ResultadoRecomendacao r) {
    final citacoes = (r.citacoes ?? const <String, String>{})
        .entries
        .where((e) => !e.key.startsWith('doseAbsorcao_'))
        .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: citacoes.map((e) {
        final chave = e.key[0].toUpperCase() + e.key.substring(1);
        return _bullet('$chave: ${e.value}');
      }).toList(),
    );
  }

  // ─── HELPERS DE LAYOUT ────────────────────────────────────────────────────

  /// Tabela de 2 colunas (chave → valor, chave → valor por linha).
  static pw.Widget _tabela(List<List<String>> linhas) {
    return pw.Table(
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(1.8),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1.8),
      },
      children: linhas.map((row) {
        return pw.TableRow(
          children: [
            _celulaLabel(row[0]),
            _celulaValor(row[1]),
            _celulaLabel(row.length > 2 ? row[2] : ''),
            _celulaValor(row.length > 3 ? row[3] : ''),
          ],
        );
      }).toList(),
    );
  }

  static pw.Widget _celulaLabel(String text) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: pw.Text(
          text,
          style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700),
        ),
      );

  static pw.Widget _celulaValor(String text) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
      );

  static pw.Widget _celulaCabecalho(String text) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: pw.Text(
          text,
          style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800),
        ),
      );

  static pw.Widget _celula(String text) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 8)),
      );

  static pw.Widget _bullet(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(left: 4, bottom: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('• ', style: const pw.TextStyle(fontSize: 9)),
            pw.Expanded(
              child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
            ),
          ],
        ),
      );

  static pw.Widget _label(String text) => pw.Text(
        text,
        style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700),
      );

  static pw.Widget _infoLine(String label, String value) => pw.Row(
        children: [
          pw.Text('$label ',
              style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
        ],
      );

  /// Formata double com [decimals] casas, usando vírgula.
  static String _f(double value, int decimals) {
    return value.toStringAsFixed(decimals).replaceAll('.', ',');
  }
}

class _PdfAssets {
  const _PdfAssets({
    required this.logo,
    required this.assinatura,
  });

  final pw.ImageProvider? logo;
  final pw.ImageProvider? assinatura;
}
