import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Gráfico estático de disponibilidade de nutrientes por pH do solo.
/// O pH é fixo (vindo da análise) — sem slider interativo.
class NutrientPhBarChart extends StatelessWidget {
  const NutrientPhBarChart({
    super.key,
    required this.ph,
  });

  final double ph;

  static const List<String> _nutrientOrder = [
    'Mn, Cu, Fe, Zn',
    'P',
    'N, S, B',
    'K, Ca, Mg',
    'Mo, Cl',
    'Al',
  ];

  static const Map<String, Color> _nutrientColors = {
    'Mn, Cu, Fe, Zn': Color(0xFF8CC63F),
    'P':              Color(0xFF58CFA3),
    'N, S, B':        Color(0xFF48C7D5),
    'K, Ca, Mg':      Color(0xFF3FA7DC),
    'Mo, Cl':         Color(0xFF3F85D8),
    'Al':             Color(0xFFE74C3C),
  };

  static final Map<double, Map<String, double>> _referenceData = {
    4.0: {'Mn, Cu, Fe, Zn': 100, 'P': 33,  'N, S, B': 24,  'K, Ca, Mg': 0,   'Mo, Cl': 10, 'Al': 90},
    4.5: {'Mn, Cu, Fe, Zn': 93,  'P': 42,  'N, S, B': 37,  'K, Ca, Mg': 12,  'Mo, Cl': 20, 'Al': 70},
    5.0: {'Mn, Cu, Fe, Zn': 87,  'P': 50,  'N, S, B': 61,  'K, Ca, Mg': 71,  'Mo, Cl': 35, 'Al': 50},
    5.5: {'Mn, Cu, Fe, Zn': 76,  'P': 67,  'N, S, B': 85,  'K, Ca, Mg': 100, 'Mo, Cl': 45, 'Al': 30},
    6.0: {'Mn, Cu, Fe, Zn': 67,  'P': 92,  'N, S, B': 95,  'K, Ca, Mg': 100, 'Mo, Cl': 65, 'Al': 10},
    6.5: {'Mn, Cu, Fe, Zn': 60,  'P': 100, 'N, S, B': 100, 'K, Ca, Mg': 100, 'Mo, Cl': 75, 'Al': 5},
    7.0: {'Mn, Cu, Fe, Zn': 51,  'P': 97,  'N, S, B': 100, 'K, Ca, Mg': 100, 'Mo, Cl': 85, 'Al': 2},
    7.5: {'Mn, Cu, Fe, Zn': 40,  'P': 87,  'N, S, B': 98,  'K, Ca, Mg': 98,  'Mo, Cl': 90, 'Al': 0},
    8.0: {'Mn, Cu, Fe, Zn': 27,  'P': 67,  'N, S, B': 88,  'K, Ca, Mg': 100, 'Mo, Cl': 93, 'Al': 0},
    8.5: {'Mn, Cu, Fe, Zn': 13,  'P': 58,  'N, S, B': 73,  'K, Ca, Mg': 100, 'Mo, Cl': 95, 'Al': 0},
  };

  List<_NutrientBarData> _interpolate(double rawPh) {
    final safePH = rawPh.clamp(4.0, 8.5);

    if (_referenceData.containsKey(safePH)) {
      return _nutrientOrder.map((g) => _NutrientBarData(
        label: g,
        value: _referenceData[safePH]![g]!,
        color: _nutrientColors[g]!,
        isToxicity: g == 'Al',
      )).toList();
    }

    final phValues = _referenceData.keys.toList()..sort();
    double prev = phValues.first;
    double next = phValues.last;
    for (final v in phValues) {
      if (v <= safePH) prev = v;
      if (v >= safePH) { next = v; break; }
    }

    final factor = (next == prev) ? 0.0 : (safePH - prev) / (next - prev);

    return _nutrientOrder.map((g) {
      final pv = _referenceData[prev]![g]!;
      final nv = _referenceData[next]![g]!;
      return _NutrientBarData(
        label: g,
        value: double.parse((pv + factor * (nv - pv)).toStringAsFixed(1)),
        color: _nutrientColors[g]!,
        isToxicity: g == 'Al',
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = _interpolate(ph);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            children: [
              const Text(
                'DISPONIBILIDADE DE NUTRIENTES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: Color(0xFF86868B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF007AFF), width: 0.5),
                ),
                child: Text(
                  'pH ${ph.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Aviso Al
          const Row(
            children: [
              Text('⚠️', style: TextStyle(fontSize: 11)),
              SizedBox(width: 4),
              Text(
                'Al = Toxicidade — quanto maior, pior',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFFE74C3C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Gráfico
          SizedBox(
            height: 340,
            child: CustomPaint(
              size: Size.infinite,
              painter: _NutrientBarChartPainter(data: data),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class _NutrientBarData {
  const _NutrientBarData({
    required this.label,
    required this.value,
    required this.color,
    required this.isToxicity,
  });
  final String label;
  final double value;
  final Color color;
  final bool isToxicity;
}

// ─── Painter ──────────────────────────────────────────────────────────────────

class _NutrientBarChartPainter extends CustomPainter {
  const _NutrientBarChartPainter({required this.data});
  final List<_NutrientBarData> data;

  static const _left   = 38.0;
  static const _right  = 12.0;
  static const _top    = 10.0;
  static const _bottom = 86.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cw = size.width - _left - _right;
    final ch = size.height - _top - _bottom;
    const cl = _left;
    const ct = _top;
    final cb = ct + ch;

    _drawBands(canvas, cl, ct, cw, ch);
    _drawGrid(canvas, cl, ct, cw, ch, cb);
    _drawBars(canvas, cl, ct, cw, ch, cb);
    _drawAxis(canvas, cl, cb, cw);
  }

  void _drawBands(Canvas canvas, double cl, double ct, double cw, double ch) {
    final p = Paint()..color = const Color(0xFFF7F7F7);
    final iw = cw / data.length;
    for (int i = 1; i < data.length; i += 2) {
      canvas.drawRect(Rect.fromLTWH(cl + iw * i, ct, iw * 0.78, ch), p);
    }
  }

  void _drawGrid(Canvas canvas, double cl, double ct, double cw, double ch, double cb) {
    final lp = Paint()..color = const Color(0xFFE7E7E7)..strokeWidth = 0.8;
    for (int i = 0; i <= 10; i++) {
      final y = cb - ch * i / 10;
      canvas.drawLine(Offset(cl, y), Offset(cl + cw, y), lp);
      _drawText(canvas, '${i * 10}',
        style: const TextStyle(fontSize: 9, color: Color(0xFFB6B6B6)),
        offset: Offset(0, y - 6), width: 32, align: TextAlign.right);
    }
  }

  void _drawBars(Canvas canvas, double cl, double ct, double cw, double ch, double cb) {
    final iw = cw / data.length;
    final bw = math.min(34.0, iw * 0.34);

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final cx = cl + iw * i + iw / 2;
      final bh = ch * item.value / 100;
      final bl = cx - bw / 2;
      final bt = cb - bh;

      // Barra
      final rect = Rect.fromLTWH(bl, bt, bw, bh);
      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [item.color.withValues(alpha: 0.80), item.color],
        ).createShader(rect);

      final path = Path()
        ..moveTo(bl, cb)
        ..lineTo(bl, bt + 14)
        ..quadraticBezierTo(bl, bt, bl + 14, bt)
        ..lineTo(bl + bw - 14, bt)
        ..quadraticBezierTo(bl + bw, bt, bl + bw, bt + 14)
        ..lineTo(bl + bw, cb)
        ..close();
      canvas.drawPath(path, barPaint);

      // Highlight lateral
      final hl = Paint()..color = Colors.white.withValues(alpha: 0.16)..strokeWidth = 1.5;
      canvas.drawLine(Offset(bl + 6, bt + 10), Offset(bl + 6, cb - 4), hl);

      // Bolinha com valor
      _drawBubble(canvas, cx, bt + 18, item.value, item.color, item.isToxicity);

      // Label abaixo
      _drawLabel(canvas, item, cx, cb);
    }
  }

  void _drawBubble(Canvas canvas, double cx, double cy, double value, Color color, bool isToxicity) {
    // Sombra
    canvas.drawCircle(Offset(cx + 1.5, cy + 2), 19,
      Paint()..color = const Color(0x22000000)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    // Fundo branco
    canvas.drawCircle(Offset(cx, cy), 19, Paint()..color = Colors.white);
    // Borda colorida
    canvas.drawCircle(Offset(cx, cy), 19,
      Paint()..color = color..strokeWidth = 3.5..style = PaintingStyle.stroke);

    // Valor
    final label = value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
    _drawText(canvas, label,
      style: TextStyle(fontSize: 11, color: isToxicity ? const Color(0xFFE74C3C) : const Color(0xFF4A4A4A), fontWeight: FontWeight.w700),
      offset: Offset(cx - 19, cy - 7), width: 38, align: TextAlign.center);
  }

  void _drawLabel(Canvas canvas, _NutrientBarData item, double cx, double cb) {
    // Nome do grupo
    _drawText(canvas, item.label,
      style: TextStyle(fontSize: 10, color: item.color, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      offset: Offset(cx - 36, cb + 12), width: 72, align: TextAlign.center);

    // Descrição
    _drawText(canvas, _desc(item.label),
      style: const TextStyle(fontSize: 8, color: Color(0xFFB0B0B0)),
      offset: Offset(cx - 38, cb + 44), width: 76, align: TextAlign.center);
  }

  String _desc(String label) {
    switch (label) {
      case 'Mn, Cu, Fe, Zn': return 'Micronutrientes\nmetálicos';
      case 'P':               return 'Fósforo\nno solo';
      case 'N, S, B':         return 'Nitrogênio,\nenxofre e boro';
      case 'K, Ca, Mg':       return 'Bases trocáveis\ndo solo';
      case 'Mo, Cl':          return 'Molibdênio\ne cloro';
      case 'Al':              return '⚠️ Toxicidade\nquanto maior, pior';
      default:                return '';
    }
  }

  void _drawAxis(Canvas canvas, double cl, double cb, double cw) {
    canvas.drawLine(Offset(cl, cb), Offset(cl + cw, cb),
      Paint()..color = const Color(0xFFBBBBBB)..strokeWidth = 1.0);
  }

  void _drawText(Canvas canvas, String text, {
    required TextStyle style,
    required Offset offset,
    required double width,
    TextAlign align = TextAlign.left,
  }) {
    final builder = ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: align, maxLines: 3))
      ..pushStyle(ui.TextStyle(
        color: style.color,
        fontSize: style.fontSize,
        fontWeight: style.fontWeight,
        letterSpacing: style.letterSpacing,
      ))
      ..addText(text);
    final p = builder.build()..layout(ui.ParagraphConstraints(width: width));
    canvas.drawParagraph(p, offset);
  }

  @override
  bool shouldRepaint(covariant _NutrientBarChartPainter old) => old.data != data;
}
