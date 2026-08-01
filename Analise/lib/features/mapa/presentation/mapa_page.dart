import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/core/theme/app_text_styles.dart';
import 'package:soloforte/core/theme/app_theme.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/usecases/calcular_derivados_analise.dart';
import 'package:soloforte/features/mapa/domain/map_engine.dart';
import 'package:soloforte/features/mapa/providers/map_engine_provider.dart';
import 'package:soloforte/features/mapa/providers/mapa_analise_provider.dart';

class MapaPage extends ConsumerStatefulWidget {
  const MapaPage({
    super.key,
    this.initialAnaliseId,
    this.selectionMode = false,
  });

  final String? initialAnaliseId;
  final bool selectionMode;

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
  bool _isEditingPolygon = false;
  LatLng? _selectedLocation;
  final List<LatLng> _polygonDraft = <LatLng>[];
  final List<LatLng> _redoStack = <LatLng>[];

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
    final targetAnaliseId = _normalizeAnaliseId(widget.initialAnaliseId);
    final pinsAsync = targetAnaliseId == null
        ? ref.watch(mapaAnaliseProvider)
        : ref.watch(mapaAnaliseFiltradaProvider(targetAnaliseId));
    final analises = ref.watch(analiseNotifierProvider).valueOrNull ?? [];
    final targetAnalise = targetAnaliseId == null
        ? null
        : _findAnaliseById(analises, targetAnaliseId);
    final basePins = pinsAsync.valueOrNull ?? const <MapPin>[];
    final pins = _pinsForCurrentMode(basePins, targetAnalise);
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
              polygons: _polygonDraft.isEmpty
                  ? const <MapPolygon>[]
                  : [
                      MapPolygon(
                        id: 'draft',
                        points: List<LatLng>.unmodifiable(_polygonDraft),
                        editable: _isEditingPolygon,
                      ),
                    ],
              onCameraChanged: _onCameraChanged,
              onMapTap: widget.selectionMode
                  ? (point) => _onMapTapSelection(point, targetAnalise)
                  : (_isEditingPolygon ? _onMapTapEditing : null),
              onPinTap: _onPinTap,
              selectedPinId: _selectedPin?.id,
            ),
          ),
          if (widget.selectionMode) ...[
            Positioned(
              top: MediaQuery.paddingOf(context).top + 14,
              left: 16,
              right: 16,
              child: _MapStatusBadge(
                icon: Icons.add_location_alt_rounded,
                text: _selectedLocation == null
                    ? 'Toque no mapa para selecionar o ponto'
                    : 'Ponto selecionado',
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: MediaQuery.paddingOf(context).bottom + 24,
              child: _LocationSelectionActions(
                canConfirm: _selectedLocation != null,
                onCancel: () => Navigator.of(context).pop(),
                onConfirm: _confirmarSelecaoLocalizacao,
              ),
            ),
          ],
          if (_isEditingPolygon && !widget.selectionMode) ...[
            Positioned(
              top: MediaQuery.paddingOf(context).top + 14,
              left: 0,
              right: 0,
              child: Center(
                child: _EditingBadge(
                  text: 'Editando vertices',
                  vertexCount: _polygonDraft.length,
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: MediaQuery.paddingOf(context).top + 82,
              child: _AreaBadge(areaHa: _polygonAreaHa(_polygonDraft)),
            ),
            Positioned(
              right: 18,
              bottom: MediaQuery.paddingOf(context).bottom + 96,
              child: _EditingActions(
                canConfirm: _polygonDraft.length >= 3,
                canUndo: _polygonDraft.isNotEmpty,
                canRedo: _redoStack.isNotEmpty,
                onConfirm: _confirmarEdicaoPoligono,
                onUndo: _desfazerVertice,
                onRedo: _refazerVertice,
                onCancel: _cancelarEdicaoPoligono,
              ),
            ),
          ],
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
                if (!widget.selectionMode) ...[
                  const SizedBox(height: 10),
                  _MapEditButton(onPressed: _iniciarEdicaoPoligono),
                ],
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
          if (_selectedPin != null &&
              !_isEditingPolygon &&
              !widget.selectionMode)
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
    if (_isEditingPolygon || widget.selectionMode) {
      return;
    }
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

  void _onMapTapEditing(LatLng point) {
    setState(() {
      _polygonDraft.add(point);
      _redoStack.clear();
    });
  }

  void _iniciarEdicaoPoligono() {
    setState(() {
      _isEditingPolygon = true;
      _selectedPin = null;
      _polygonDraft.clear();
      _redoStack.clear();
    });
  }

  void _onMapTapSelection(LatLng point, AnaliseSolo? targetAnalise) {
    if (targetAnalise == null) {
      return;
    }
    final previewPin = pinFromAnaliseForPreview(targetAnalise, point);
    setState(() {
      _selectedLocation = point;
      _selectedPin = previewPin;
      _cameraCenter = point;
    });
  }

  void _confirmarSelecaoLocalizacao() {
    final selected = _selectedLocation;
    if (selected == null) {
      return;
    }
    Navigator.of(context).pop(selected);
  }

  void _desfazerVertice() {
    if (_polygonDraft.isEmpty) {
      return;
    }
    setState(() => _redoStack.add(_polygonDraft.removeLast()));
  }

  void _refazerVertice() {
    if (_redoStack.isEmpty) {
      return;
    }
    setState(() => _polygonDraft.add(_redoStack.removeLast()));
  }

  void _cancelarEdicaoPoligono() {
    setState(() {
      _isEditingPolygon = false;
      _polygonDraft.clear();
      _redoStack.clear();
    });
  }

  void _confirmarEdicaoPoligono() {
    if (_polygonDraft.length < 3) {
      return;
    }
    setState(() {
      _isEditingPolygon = false;
      _redoStack.clear();
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
        if (widget.selectionMode) {
          _selectedLocation = targetPin.position;
        }
        _cameraCenter = targetPin.position;
        _cameraZoom = targetZoom;
      });
    });
  }

  List<MapPin> _pinsForCurrentMode(
    List<MapPin> basePins,
    AnaliseSolo? targetAnalise,
  ) {
    if (!widget.selectionMode) {
      return basePins;
    }
    final selected = _selectedLocation;
    if (selected != null && targetAnalise != null) {
      return [pinFromAnaliseForPreview(targetAnalise, selected)];
    }
    return basePins;
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

double _polygonAreaHa(List<LatLng> points) {
  if (points.length < 3) {
    return 0;
  }

  final refLatRad = points.map((p) => p.latitude).reduce((a, b) => a + b) /
      points.length *
      math.pi /
      180;
  const metersPerDegreeLat = 111320.0;
  final metersPerDegreeLng = metersPerDegreeLat * math.cos(refLatRad);

  final projected = points
      .map(
        (p) => Offset(
          p.longitude * metersPerDegreeLng,
          p.latitude * metersPerDegreeLat,
        ),
      )
      .toList(growable: false);

  var area = 0.0;
  for (var i = 0; i < projected.length; i++) {
    final current = projected[i];
    final next = projected[(i + 1) % projected.length];
    area += current.dx * next.dy - next.dx * current.dy;
  }
  return area.abs() / 2 / 10000;
}

class _EditingBadge extends StatelessWidget {
  const _EditingBadge({
    required this.text,
    required this.vertexCount,
  });

  final String text;
  final int vertexCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFAF52DE),
      elevation: 4,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              '$text · $vertexCount',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AreaBadge extends StatelessWidget {
  const _AreaBadge({required this.areaHa});

  final double areaHa;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC000000),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${areaHa.toStringAsFixed(areaHa >= 100 ? 0 : 2)} ha',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _UnitChip(label: 'ha', active: true),
                SizedBox(width: 6),
                _UnitChip(label: 'm2'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({
    required this.label,
    this.active = false,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active ? AppColors.success : const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _EditingActions extends StatelessWidget {
  const _EditingActions({
    required this.canConfirm,
    required this.canUndo,
    required this.canRedo,
    required this.onConfirm,
    required this.onUndo,
    required this.onRedo,
    required this.onCancel,
  });

  final bool canConfirm;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onConfirm;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xE61D1D1F),
      borderRadius: BorderRadius.circular(34),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RoundActionButton(
              icon: Icons.check_rounded,
              color: AppColors.success,
              onPressed: canConfirm ? onConfirm : null,
              tooltip: 'Confirmar desenho',
            ),
            const SizedBox(height: 10),
            _RoundActionButton(
              icon: Icons.undo_rounded,
              color: const Color(0xFF8E8E93),
              onPressed: canUndo ? onUndo : null,
              tooltip: 'Desfazer vertice',
            ),
            const SizedBox(height: 10),
            _RoundActionButton(
              icon: Icons.redo_rounded,
              color: const Color(0xFF8E8E93),
              onPressed: canRedo ? onRedo : null,
              tooltip: 'Refazer vertice',
            ),
            const SizedBox(height: 10),
            _RoundActionButton(
              icon: Icons.close_rounded,
              color: AppColors.error,
              onPressed: onCancel,
              tooltip: 'Cancelar desenho',
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.45 : 1,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: color,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 58,
              height: 58,
              child: Icon(icon, color: Colors.white, size: 34),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationSelectionActions extends StatelessWidget {
  const _LocationSelectionActions({
    required this.canConfirm,
    required this.onCancel,
    required this.onConfirm,
  });

  final bool canConfirm;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return _MapFloatingSurface(
      padding: const EdgeInsets.all(AppDimens.md),
      borderRadius: AppDimens.radius2xl,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.close_rounded),
              label: const Text('Cancelar'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.borderSoft),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.sm),
          Expanded(
            child: FilledButton.icon(
              onPressed: canConfirm ? onConfirm : null,
              icon: Icon(
                Icons.check_rounded,
                color: canConfirm ? Colors.white : AppColors.textTertiary,
              ),
              label: Text(canConfirm ? 'Usar ponto' : 'Selecione'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: AppColors.primary,
                disabledBackgroundColor:
                    AppColors.borderSoft.withValues(alpha: 0.72),
                disabledForegroundColor: AppColors.textTertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapFloatingSurface extends StatelessWidget {
  const _MapFloatingSurface({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius = AppDimens.radiusLg,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.bgPrimary.withValues(alpha: 0.76),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
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
    final bg = isError ? AppColors.bgError : AppColors.bgPrimary;
    final fg = isError ? AppColors.error : AppColors.textPrimary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: AppColors.borderSoft.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isError
                    ? AppColors.error.withValues(alpha: 0.12)
                    : AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 15, color: fg),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: AppTextStyles.caption.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
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
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radius2xl),
            ),
            border: Border.all(
              color: AppColors.bgPrimary.withValues(alpha: 0.82),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.10),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radius2xl),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(18, 10, 18, bottomPadding),
              child: analise == null
                  ? _PinFallbackDetails(pin: pin, onClose: onClose)
                  : _AnaliseDetailsContent(analise: analise!, onClose: onClose),
            ),
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
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: AppColors.borderSoft.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: analise.cultura.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                ),
                alignment: Alignment.center,
                child: Text(
                  analise.cultura.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Text(
                  analise.cultura.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headline.copyWith(
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
    return Container(
      margin: const EdgeInsets.only(top: AppDimens.md),
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.borderSoft.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimens.sm),
          ...rows.map((row) => _AnaliseDataRow(row: row)),
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
    return SizedBox(
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 46,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _RoundMapButton(
              tooltip: 'Fechar',
              icon: Icons.close_rounded,
              onPressed: onClose,
              size: 34,
              iconSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundMapButton extends StatelessWidget {
  const _RoundMapButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.size = 52,
    this.iconSize = 24,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return _MapFloatingSurface(
      borderRadius: AppDimens.radiusPill,
      child: SizedBox.square(
        dimension: size,
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: Icon(icon, color: AppColors.primary, size: iconSize),
          visualDensity: VisualDensity.compact,
        ),
      ),
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

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return _MapFloatingSurface(
      borderRadius: AppDimens.radiusPill,
      child: SizedBox(
        width: 52,
        height: 116,
        child: Column(
          children: [
            Expanded(
              child: IconButton(
                onPressed: onZoomIn,
                icon: const Icon(
                  CupertinoIcons.add,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 13),
              height: 1,
              color: AppColors.borderSoft,
            ),
            Expanded(
              child: IconButton(
                onPressed: onZoomOut,
                icon: const Icon(
                  CupertinoIcons.minus,
                  size: 24,
                  color: AppColors.primary,
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
    return _MapFloatingSurface(
      borderRadius: AppDimens.radiusPill,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox.square(
          dimension: 52,
          child: Center(
            child: Icon(
              Icons.my_location_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapEditButton extends StatelessWidget {
  const _MapEditButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _RoundMapButton(
      tooltip: 'Editar vertices',
      icon: Icons.edit_location_alt_rounded,
      onPressed: onPressed,
    );
  }
}
