import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/usecases/calcular_derivados_analise.dart';
import 'package:soloforte/features/mapa/domain/map_engine.dart';
import 'package:soloforte/features/mapa/providers/map_engine_provider.dart';
import 'package:soloforte/features/mapa/providers/mapa_analise_provider.dart';

class MapaPage extends ConsumerStatefulWidget {
  const MapaPage({super.key, this.initialAnaliseId});

  final String? initialAnaliseId;

  @override
  ConsumerState<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends ConsumerState<MapaPage> {
  static const LatLng _initialCenter = LatLng(-15.0, -53.0);
  static const double _initialZoom = 4.5;
  static const double _minZoom = 3.5;
  static const double _maxZoom = 18.0;
  static const _calc = CalcularDerivadosAnalise();

  final MapControllerAdapter _controller = MapControllerAdapter();
  LatLng _cameraCenter = _initialCenter;
  double _cameraZoom = _initialZoom;
  MapPin? _selectedPin;
  String? _focusAnaliseId;
  bool _focusRequestHandled = false;

  @override
  void initState() {
    super.initState();
    _focusAnaliseId = _normalizeAnaliseId(widget.initialAnaliseId);
  }

  @override
  void didUpdateWidget(covariant MapaPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldId = _normalizeAnaliseId(oldWidget.initialAnaliseId);
    final newId = _normalizeAnaliseId(widget.initialAnaliseId);
    if (oldId != newId) {
      _focusAnaliseId = newId;
      _focusRequestHandled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(mapEngineProvider);
    final pinsAsync = ref.watch(mapaAnaliseProvider);
    final analises = ref.watch(analiseNotifierProvider).valueOrNull ?? [];
    final pins = pinsAsync.valueOrNull ?? const <MapPin>[];
    final selectedAnalise = _selectedPin == null
        ? null
        : _findAnaliseById(analises, _selectedPin!.id);
    _tryFocusRequestedPin(pins);
    _clearSelectionWhenPinIsRemoved(pins);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: engine.buildMap(
              center: _initialCenter,
              zoom: _initialZoom,
              pins: pins,
              controller: _controller,
              onCameraChanged: _onCameraChanged,
              onPinTap: _onPinTap,
              selectedPinId: _selectedPin?.id,
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            right: 14,
            child: Column(
              children: [
                _MapZoomControl(
                  onZoomIn: _aproximarMapa,
                  onZoomOut: _afastarMapa,
                ),
                const SizedBox(height: 10),
                _MapLocationButton(onPressed: _centralizarUsuario),
              ],
            ),
          ),
          if (pinsAsync.isLoading && pins.isEmpty)
            const Positioned(
              top: 24,
              left: 16,
              child: _MapStatusBadge(
                icon: Icons.hourglass_top_rounded,
                text: 'Carregando pontos...',
              ),
            ),
          if (pinsAsync.hasError)
            const Positioned(
              top: 24,
              left: 16,
              child: _MapStatusBadge(
                icon: Icons.warning_amber_rounded,
                text: 'Nao foi possivel carregar os pins',
                isError: true,
              ),
            ),
          if (_selectedPin != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.sizeOf(context).height * 0.86,
              child: _AnaliseMapSheet(
                analise: selectedAnalise,
                pin: _selectedPin!,
                onClose: () => setState(() => _selectedPin = null),
              ),
            ),
        ],
      ),
    );
  }

  void _aproximarMapa() => _alterarZoom(1.0);

  void _afastarMapa() => _alterarZoom(-1.0);

  void _alterarZoom(double delta) {
    final novoZoom = (_cameraZoom + delta).clamp(_minZoom, _maxZoom).toDouble();
    if ((novoZoom - _cameraZoom).abs() < 0.0001) {
      return;
    }
    _controller.move(_cameraCenter, novoZoom);
    setState(() => _cameraZoom = novoZoom);
  }

  void _onCameraChanged(LatLng center, double zoom) {
    final centerInalterado =
        (center.latitude - _cameraCenter.latitude).abs() < 0.000001 &&
            (center.longitude - _cameraCenter.longitude).abs() < 0.000001;
    final zoomInalterado = (zoom - _cameraZoom).abs() < 0.0001;
    if (centerInalterado && zoomInalterado) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _cameraCenter = center;
      _cameraZoom = zoom;
    });
  }

  void _onPinTap(MapPin pin) {
    const focusZoom = 11.5;
    final shouldZoom = _cameraZoom < focusZoom;
    if (shouldZoom) {
      _controller.move(pin.position, focusZoom);
    }
    setState(() {
      _selectedPin = pin;
      _cameraCenter = pin.position;
      if (shouldZoom) {
        _cameraZoom = focusZoom;
      }
    });
  }

  String? _normalizeAnaliseId(String? id) {
    final value = id?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  void _tryFocusRequestedPin(List<MapPin> pins) {
    if (_focusRequestHandled) {
      return;
    }
    final targetId = _focusAnaliseId;
    if (targetId == null) {
      _focusRequestHandled = true;
      return;
    }
    if (pins.isEmpty) {
      return;
    }

    MapPin? target;
    for (final pin in pins) {
      if (pin.id == targetId) {
        target = pin;
        break;
      }
    }
    _focusRequestHandled = true;
    if (target == null) {
      return;
    }
    final targetPin = target;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      const targetZoom = 13.0;
      _controller.move(targetPin.position, targetZoom);
      setState(() {
        _selectedPin = targetPin;
        _cameraCenter = targetPin.position;
        _cameraZoom = targetZoom;
      });
    });
  }

  void _clearSelectionWhenPinIsRemoved(List<MapPin> pins) {
    final selectedId = _selectedPin?.id;
    if (selectedId == null) {
      return;
    }
    final stillExists = pins.any((pin) => pin.id == selectedId);
    if (stillExists) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedPin == null) {
        return;
      }
      setState(() => _selectedPin = null);
    });
  }

  AnaliseSolo? _findAnaliseById(List<AnaliseSolo> analises, String id) {
    for (final analise in analises) {
      if (analise.id == id) {
        return analise;
      }
    }
    return null;
  }

  Future<void> _centralizarUsuario() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final centroUsuario = LatLng(pos.latitude, pos.longitude);
    const zoomUsuario = 14.0;
    _controller.move(centroUsuario, zoomUsuario);
    setState(() {
      _cameraCenter = centroUsuario;
      _cameraZoom = zoomUsuario;
    });
  }
}

class _MapStatusBadge extends StatelessWidget {
  const _MapStatusBadge({
    required this.icon,
    required this.text,
    this.isError = false,
  });

  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final bg = isError ? const Color(0xFFFFF3F0) : Colors.white;
    final fg = isError ? AppColors.error : AppColors.textPrimary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnaliseMapSheet extends StatelessWidget {
  const _AnaliseMapSheet({
    required this.analise,
    required this.pin,
    required this.onClose,
  });

  final AnaliseSolo? analise;
  final MapPin pin;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 88;

    return DraggableScrollableSheet(
      initialChildSize: 0.46,
      minChildSize: 0.24,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Material(
          color: Colors.white,
          elevation: 10,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(18, 10, 18, bottomPadding),
            child: analise == null
                ? _PinFallbackDetails(pin: pin, onClose: onClose)
                : _AnaliseDetailsContent(analise: analise!, onClose: onClose),
          ),
        );
      },
    );
  }
}

class _AnaliseDetailsContent extends StatelessWidget {
  const _AnaliseDetailsContent({
    required this.analise,
    required this.onClose,
  });

  final AnaliseSolo analise;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final derivados = _MapaPageState._calc.call({
      'ca': analise.ca,
      'mg': analise.mg,
      'k': analise.k,
      'na': analise.na,
      'al': analise.al,
      'hMaisAl': analise.hMaisAl,
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHandle(onClose: onClose),
        _AnaliseMapHeader(analise: analise),
        const SizedBox(height: 14),
        _AnaliseDataSection(
          title: 'Composição Física',
          rows: [
            _DataRowSpec('Argila (g/kg)', _fmt(analise.argila)),
            _DataRowSpec('Silte (g/kg)', _fmt(analise.silte)),
            _DataRowSpec('Areia Total (g/kg)', _fmt(analise.areiaTotal)),
            _DataRowSpec('Profundidade', analise.profundidade),
          ],
        ),
        _AnaliseDataSection(
          title: 'pH',
          rows: [
            _DataRowSpec('pH Água', _fmt(analise.phAgua)),
            _DataRowSpec('pH SMP', _fmt(analise.phSmp)),
            _DataRowSpec('pH CaCl₂', _fmt(analise.phCaCl2)),
          ],
        ),
        _AnaliseDataSection(
          title: 'Matéria Orgânica',
          rows: [
            _DataRowSpec('MO (dag/kg)', _fmt(analise.materiaOrganica)),
            _DataRowSpec(
                'Carbono orgânico (dag/kg)', _fmt(analise.carbonoOrganico)),
          ],
        ),
        _AnaliseDataSection(
          title: 'Macronutrientes',
          rows: [
            _DataRowSpec(
              analise.pResina != null && analise.pMehlich == null
                  ? 'P Resina (mg/dm³)'
                  : 'P Mehlich (mg/dm³)',
              _fmt(analise.pResina ?? analise.pMehlich),
            ),
            _DataRowSpec('P Rem (mg/L)', _fmt(analise.pRem)),
            _DataRowSpec('Potássio (cmolc/dm³)', _fmt(analise.k)),
            _DataRowSpec('Cálcio (cmolc/dm³)', _fmt(analise.ca)),
            _DataRowSpec('Magnésio (cmolc/dm³)', _fmt(analise.mg)),
            _DataRowSpec('Sódio (cmolc/dm³)', _fmt(analise.na)),
            _DataRowSpec('S 0-20 (mg/dm³)', _fmt(analise.s020)),
            _DataRowSpec('S 20-40 (mg/dm³)', _fmt(analise.s2040)),
          ],
        ),
        _AnaliseDataSection(
          title: 'Acidez',
          rows: [
            _DataRowSpec('Alumínio (cmolc/dm³)', _fmt(analise.al)),
            _DataRowSpec('H+Al (cmolc/dm³)', _fmt(analise.hMaisAl)),
          ],
        ),
        _AnaliseDataSection(
          title: 'Calculados Automáticos',
          rows: [
            _DataRowSpec('SB', _fmt(derivados['sb'])),
            _DataRowSpec('CTC T', _fmt(derivados['ctcTotal'])),
            _DataRowSpec('CTC efetiva', _fmt(derivados['ctcEfetiva'])),
            _DataRowSpec('V%', _fmt(derivados['vPct'])),
            _DataRowSpec('m%', _fmt(derivados['mPct'])),
          ],
        ),
        _AnaliseDataSection(
          title: 'Micronutrientes (mg/dm³)',
          rows: [
            _DataRowSpec('Boro', _fmt(analise.b)),
            _DataRowSpec('Cobre', _fmt(analise.cu)),
            _DataRowSpec('Ferro', _fmt(analise.fe)),
            _DataRowSpec('Manganês', _fmt(analise.mn)),
            _DataRowSpec('Zinco', _fmt(analise.zn)),
            _DataRowSpec('Níquel', _fmt(analise.ni)),
            _DataRowSpec('Molibdênio', _fmt(analise.mo)),
            _DataRowSpec('Selênio', _fmt(analise.se)),
          ],
        ),
      ],
    );
  }

  String _fmt(num? value) => _formatDecimal(value);
}

class _AnaliseMapHeader extends StatelessWidget {
  const _AnaliseMapHeader({required this.analise});

  final AnaliseSolo analise;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: analise.cultura.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(analise.cultura.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  analise.cultura.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: analise.cultura.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _HeaderLine(label: 'Talhão', value: analise.talhao),
          _HeaderLine(label: 'Amostra', value: analise.numeroAmostra),
          _HeaderLine(label: 'Produtor', value: analise.produtor),
          _HeaderLine(label: 'Fazenda', value: analise.fazenda),
          _HeaderLine(label: 'Safra', value: analise.safra),
          _HeaderLine(label: 'Laboratório', value: analise.laboratorio),
          _HeaderLine(label: 'Local', value: analise.descricaoLocal),
          _HeaderLine(
            label: 'Coordenadas',
            value: analise.latitude == null || analise.longitude == null
                ? null
                : '${analise.latitude!.toStringAsFixed(6)}, ${analise.longitude!.toStringAsFixed(6)}',
          ),
        ],
      ),
    );
  }
}

class _HeaderLine extends StatelessWidget {
  const _HeaderLine({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final text = _displayText(value);

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            height: 1.25,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}

class _AnaliseDataSection extends StatelessWidget {
  const _AnaliseDataSection({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<_DataRowSpec> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          ...rows.map((row) => _AnaliseDataRow(row: row)),
          const Divider(height: 14, color: AppColors.borderSoft),
        ],
      ),
    );
  }
}

class _AnaliseDataRow extends StatelessWidget {
  const _AnaliseDataRow({required this.row});

  final _DataRowSpec row;

  @override
  Widget build(BuildContext context) {
    final isMissing = _isMissing(row.value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              row.label,
              style: const TextStyle(
                color: AppColors.textSecond,
                fontSize: 15,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              isMissing ? 'Não informado' : row.value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isMissing ? AppColors.warning : AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinFallbackDetails extends StatelessWidget {
  const _PinFallbackDetails({
    required this.pin,
    required this.onClose,
  });

  final MapPin pin;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHandle(onClose: onClose),
        Text(
          pin.titulo,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        _AnaliseDataSection(
          title: 'Resumo',
          rows: [
            _DataRowSpec('Amostra', pin.numeroAmostra ?? '-'),
            _DataRowSpec('Produtor', pin.produtor ?? '-'),
            _DataRowSpec('Fazenda', pin.fazenda ?? '-'),
            _DataRowSpec('Laboratório', pin.laboratorio ?? '-'),
            _DataRowSpec('Cultura', pin.cultura ?? '-'),
            _DataRowSpec('Safra', pin.safra ?? '-'),
            _DataRowSpec('Profundidade', pin.profundidade ?? '-'),
            _DataRowSpec('Local', pin.descricaoLocal ?? '-'),
            _DataRowSpec(
              'Coordenadas',
              '${pin.position.latitude.toStringAsFixed(6)}, ${pin.position.longitude.toStringAsFixed(6)}',
            ),
          ],
        ),
      ],
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onClose,
              tooltip: 'Fechar',
              icon: const Icon(Icons.close_rounded),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ],
    );
  }
}

class _DataRowSpec {
  const _DataRowSpec(this.label, this.value);

  final String label;
  final String value;
}

String _displayText(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty || text == '-' || text == 'N/A') {
    return 'Não informado';
  }
  return text;
}

bool _isMissing(String value) {
  final text = value.trim();
  return text.isEmpty || text == '-' || text == 'N/A' || text == 'null';
}

String _formatDecimal(
  num? value, {
  int decimals = 3,
  bool keepIntegers = true,
}) {
  if (value == null) return '-';

  final asDouble = value.toDouble();
  if (asDouble.isNaN || asDouble.isInfinite) return '-';

  if (keepIntegers && asDouble == asDouble.truncateToDouble()) {
    return asDouble.toStringAsFixed(0);
  }

  return asDouble.toStringAsFixed(decimals);
}

class _MapZoomControl extends StatelessWidget {
  const _MapZoomControl({
    required this.onZoomIn,
    required this.onZoomOut,
  });

  static const _backgroundColor = Color(0xFFEFF4D7);
  static const _borderColor = Color(0x1A000000);
  static const _dividerColor = Color(0x26000000);

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: _borderColor),
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 56,
        height: 128,
        child: Column(
          children: [
            Expanded(
              child: IconButton(
                onPressed: onZoomIn,
                icon: const Icon(
                  CupertinoIcons.add,
                  size: 28,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              height: 1,
              color: _dividerColor,
            ),
            Expanded(
              child: IconButton(
                onPressed: onZoomOut,
                icon: const Icon(
                  CupertinoIcons.minus,
                  size: 28,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapLocationButton extends StatelessWidget {
  const _MapLocationButton({required this.onPressed});

  static const _backgroundColor = Color(0xFFF7F7F2);
  static const _borderColor = Color(0x1A000000);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _backgroundColor,
      shape: const CircleBorder(side: BorderSide(color: _borderColor)),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Center(
            child: SizedBox(
              width: 34,
              height: 34,
              child: CustomPaint(painter: _CompassPainter()),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  const _CompassPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final ringPaint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, radius, ringPaint);

    final tickPaint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    const ticks = 12;
    for (var i = 0; i < ticks; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / ticks);
      final isMajor = i % 3 == 0;
      final inner = radius * (isMajor ? 0.70 : 0.78);
      final outer = radius * (isMajor ? 0.92 : 0.90);
      final p1 = Offset(
        center.dx + inner * math.cos(angle),
        center.dy + inner * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + outer * math.cos(angle),
        center.dy + outer * math.sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }

    final arrowPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.fill;
    final arrowWidth = radius * 0.30;
    final arrowHeight = radius * 0.28;
    final arrowTop = center.dy - radius * 0.98;
    final arrowPath = Path()
      ..moveTo(center.dx, arrowTop)
      ..lineTo(center.dx - arrowWidth / 2, arrowTop + arrowHeight)
      ..lineTo(center.dx + arrowWidth / 2, arrowTop + arrowHeight)
      ..close();
    canvas.drawPath(arrowPath, arrowPaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
          color: Color(0xFF111111),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2 + radius * 0.08,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
