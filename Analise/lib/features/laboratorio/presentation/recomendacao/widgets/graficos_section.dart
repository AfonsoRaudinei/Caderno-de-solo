import 'package:flutter/material.dart';
import 'package:soloforte/core/theme/app_theme_palette.dart';
import 'package:soloforte/core/widgets/app_card.dart';
import 'package:soloforte/core/widgets/agronomic_progress_bar.dart';
import 'package:soloforte/domain/formulas/classificacao_nivel.dart';
import 'package:soloforte/domain/usecases/recomendacao_engine.dart';

class RecomendacaoBasesDashboard extends StatelessWidget {
  const RecomendacaoBasesDashboard({super.key, required this.resultado});

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    final a = resultado.analise;
    final palette = context.appPalette;
    final ctc = a.ctc > 0 ? a.ctc : 1.0;

    double pct(double val) => (val / ctc * 100).clamp(0.0, 100.0);

    final alPct = pct(a.al);
    final relCaMg = a.mg > 0 ? a.ca / a.mg : 0.0;
    final relCaK = a.k > 0 ? a.ca / a.k : 0.0;
    final relMgK = a.k > 0 ? a.mg / a.k : 0.0;

    Color corV() {
      if (a.vPercent < 40) return const Color(0xFFFF3B30);
      if (a.vPercent < 60) return const Color(0xFFFF9500);
      if (a.vPercent < 80) return const Color(0xFF34C759);
      return const Color(0xFF007AFF);
    }

    Color corAl() {
      if (alPct < 5) return const Color(0xFF34C759);
      if (alPct < 15) return const Color(0xFFFF9500);
      return const Color(0xFFFF3B30);
    }

    return AppCardSection(
      title: 'BASES DO SOLO',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'SOMA DE BASES E ACIDEZ',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: palette.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          _baseRow('Ca', a.ca, pct(a.ca), palette, nutriente: 'ca'),
          _baseRow('Mg', a.mg, pct(a.mg), palette, nutriente: 'mg'),
          _baseRow('K', a.k, pct(a.k), palette, nutriente: 'k'),
          _baseRow('Al', a.al, pct(a.al), palette,
              nutriente: null, corFixa: const Color(0xFFFF3B30)),
          _baseRow('H+Al', a.hAl, pct(a.hAl), palette,
              nutriente: null, corFixa: const Color(0xFFFF9500)),
          Divider(height: 1, thickness: 0.5, color: palette.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                Expanded(
                    child: _blocoValor('SB', _fmt(a.sb, 2), 'cmolc/dm³',
                        const Color(0xFF34C759), palette)),
                const SizedBox(width: 8),
                Expanded(
                    child: _blocoValor('CTC', _fmt(a.ctc, 2), 'cmolc/dm³',
                        const Color(0xFF007AFF), palette)),
                const SizedBox(width: 8),
                Expanded(
                    child: _blocoValor(
                        'V%', '${_fmt(a.vPercent, 0)}%', '', corV(), palette)),
                const SizedBox(width: 8),
                Expanded(
                    child: _blocoValor(
                        'Al%', '${_fmt(alPct, 0)}%', '', corAl(), palette)),
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: palette.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'RELAÇÕES DE BASES',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: palette.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(child: _relacaoCol('Ca/Mg', relCaMg, '3–5', palette)),
                Expanded(child: _relacaoCol('Ca/K', relCaK, '10–30', palette)),
                Expanded(child: _relacaoCol('Mg/K', relMgK, '3–10', palette)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _baseRow(
    String nome,
    double valor,
    double barPct,
    AppThemePalette palette, {
    String? nutriente,
    Color? corFixa,
  }) {
    String? rotulo;
    if (nutriente != null) {
      rotulo =
          ClassificacaoNivel.classificar(nutriente: nutriente, valor: valor);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              nome,
              style: TextStyle(fontSize: 13, color: palette.textSecondary),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              valor.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          if (rotulo != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9500).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: const Color(0xFFFF9500).withValues(alpha: 0.3),
                    width: 0.5),
              ),
              child: Text(
                rotulo,
                style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFFF9500),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ] else ...[
            const SizedBox(width: 48),
          ],
          const SizedBox(width: 8),
          Expanded(
            child: corFixa != null
                ? _barraSimples(barPct, corFixa, palette)
                : AgronomicProgressBar(value: barPct),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 34,
            child: Text(
              '${barPct.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 10, color: palette.textSecondary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraSimples(double pct, Color cor, AppThemePalette palette) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: pct / 100.0,
        backgroundColor: palette.border,
        valueColor: AlwaysStoppedAnimation<Color>(cor),
        minHeight: 8,
      ),
    );
  }

  Widget _blocoValor(
    String label,
    String valor,
    String unidade,
    Color cor,
    AppThemePalette palette,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cor.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: cor)),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: cor),
          ),
          if (unidade.isNotEmpty)
            Text(
              unidade,
              style: TextStyle(fontSize: 8, color: palette.textSecondary),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _relacaoCol(
    String label,
    double valor,
    String faixa,
    AppThemePalette palette,
  ) {
    Color cor = palette.textSecondary;
    if (label == 'Ca/Mg') {
      if (valor >= 3 && valor <= 5) {
        cor = const Color(0xFF34C759);
      } else if (valor < 3) {
        cor = const Color(0xFFFF9500);
      } else {
        cor = const Color(0xFFFF3B30);
      }
    } else if (label == 'Ca/K') {
      if (valor >= 10 && valor <= 30) {
        cor = const Color(0xFF34C759);
      } else if (valor < 10) {
        cor = const Color(0xFFFF9500);
      } else {
        cor = const Color(0xFFFF3B30);
      }
    } else if (label == 'Mg/K') {
      if (valor >= 3 && valor <= 10) {
        cor = const Color(0xFF34C759);
      } else if (valor < 3) {
        cor = const Color(0xFFFF9500);
      } else {
        cor = const Color(0xFFFF3B30);
      }
    }

    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: palette.textSecondary)),
        const SizedBox(height: 4),
        Text(
          valor.toStringAsFixed(1),
          style:
              TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cor),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          height: 3,
          width: 40,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 2),
        Text(faixa, style: TextStyle(fontSize: 9, color: palette.textTertiary)),
      ],
    );
  }

  String _fmt(double value, [int decimals = 2]) {
    final text = value.toStringAsFixed(decimals);
    return text.replaceAll('.', ',');
  }
}

class RecomendacaoGraficosSection extends StatelessWidget {
  const RecomendacaoGraficosSection({super.key, required this.resultado});

  final ResultadoRecomendacao resultado;

  @override
  Widget build(BuildContext context) {
    final analise = resultado.analise;
    final palette = context.appPalette;

    final grupos = [
      _GrupoBar('Ca', analise.ca, resultado.caEsperado, 'cmolc'),
      _GrupoBar('Mg', analise.mg, resultado.mgEsperado, 'cmolc'),
      _GrupoBar('K', analise.k, analise.k, 'cmolc'),
      _GrupoBar('V%', analise.vPercent, resultado.vEsperado, '%'),
    ];

    return AppCardSection(
      title: 'ANTES E DEPOIS DA CORREÇÃO',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendaPill('Antes', const Color(0xFFFF9500), palette),
                const SizedBox(width: 16),
                _legendaPill('Depois', const Color(0xFF34C759), palette),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    grupos.map((g) => _buildGrupoBarras(g, palette)).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: grupos
                  .map(
                    (g) => SizedBox(
                      width: 56,
                      child: Text(
                        g.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            Text(
              '* K sem alteração — recomendação de K calculada separadamente',
              style: TextStyle(fontSize: 10, color: palette.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrupoBarras(_GrupoBar g, AppThemePalette palette) {
    const alturaMax = 150.0;
    const larguraBarra = 22.0;

    final maxVal = [g.antes, g.depois, 0.001].reduce((a, b) => a > b ? a : b);
    final propAntes = (g.antes / maxVal).clamp(0.0, 1.0);
    final propDepois = (g.depois / maxVal).clamp(0.0, 1.0);

    const corAntes = Color(0xFFFF9500); // laranja iOS — série "Antes"
    const corDepois = Color(0xFF34C759); // verde iOS — série "Depois"

    Widget barra(double proporcao, Color cor, double valor, String unidade,
        String label) {
      final altura = (alturaMax * proporcao).clamp(4.0, alturaMax);
      return SizedBox(
        width: 26.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              _fmtBar(valor, unidade, label),
              style: const TextStyle(fontSize: 9, color: Color(0xFF1D1D1F)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: larguraBarra,
              height: altura,
              decoration: BoxDecoration(
                color: cor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(5)),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: 56,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          barra(propAntes, corAntes, g.antes, g.unidade, g.label),
          const SizedBox(width: 3),
          barra(propDepois, corDepois, g.depois, g.unidade, g.label),
        ],
      ),
    );
  }

  Widget _legendaPill(String label, Color cor, AppThemePalette palette) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
              BoxDecoration(color: cor, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 11, color: palette.textSecondary)),
      ],
    );
  }

  String _fmtBar(double v, String unidade, String label) {
    if (unidade == '%') return '${v.toStringAsFixed(0)}%';
    if (unidade == 'cmolc' && label == 'K') return v.toStringAsFixed(2);
    return v.toStringAsFixed(1);
  }
}

class _GrupoBar {
  const _GrupoBar(this.label, this.antes, this.depois, this.unidade);

  final String label;
  final double antes;
  final double depois;
  final String unidade;
}
