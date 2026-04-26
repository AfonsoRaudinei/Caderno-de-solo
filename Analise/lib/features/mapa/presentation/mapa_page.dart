import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:soloforte/core/theme/app_colors.dart';
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
    final pins = pinsAsync.valueOrNull ?? const <MapPin>[];
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
              left: 14,
              right: 14,
              bottom: MediaQuery.paddingOf(context).bottom + 14,
              child: _PinDetailsCard(
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

class _PinDetailsCard extends StatelessWidget {
  const _PinDetailsCard({
    required this.pin,
    required this.onClose,
  });

  final MapPin pin;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_pin,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    pin.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  tooltip: 'Fechar',
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (_hasValue(pin.cultura)) _PinChip(label: pin.cultura!),
                if (_hasValue(pin.safra)) _PinChip(label: pin.safra!),
                if (_hasValue(pin.profundidade))
                  _PinChip(label: 'Prof. ${pin.profundidade} cm'),
              ],
            ),
            const SizedBox(height: 8),
            _PinInfoLine(label: 'Amostra', value: pin.numeroAmostra),
            _PinInfoLine(label: 'Produtor', value: pin.produtor),
            _PinInfoLine(label: 'Fazenda', value: pin.fazenda),
            _PinInfoLine(label: 'Laboratorio', value: pin.laboratorio),
            _PinInfoLine(label: 'Local', value: pin.descricaoLocal),
            _PinInfoLine(
              label: 'Coordenadas',
              value:
                  '${pin.position.latitude.toStringAsFixed(6)}, ${pin.position.longitude.toStringAsFixed(6)}',
            ),
          ],
        ),
      ),
    );
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
}

class _PinChip extends StatelessWidget {
  const _PinChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryDark,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PinInfoLine extends StatelessWidget {
  const _PinInfoLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final text = (value?.trim().isNotEmpty ?? false) ? value!.trim() : '-';
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecond,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapZoomControl extends StatelessWidget {
  const _MapZoomControl({
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(28),
      elevation: 4,
      child: SizedBox(
        width: 56,
        height: 128,
        child: Column(
          children: [
            Expanded(
              child: IconButton(
                onPressed: onZoomIn,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 30,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              height: 1,
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
            Expanded(
              child: IconButton(
                onPressed: onZoomOut,
                icon: const Icon(
                  Icons.remove_rounded,
                  size: 30,
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

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.my_location_rounded,
            color: AppColors.bgPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
