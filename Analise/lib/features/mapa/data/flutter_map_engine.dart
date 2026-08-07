import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:soloforte/core/theme/app_colors.dart';
import 'package:soloforte/features/mapa/domain/map_engine.dart';

class FlutterMapEngine implements MapEngine {
  final MapController _mapController = MapController();

  @override
  Widget buildMap({
    required LatLng center,
    required double zoom,
    required List<MapPin> pins,
    required AbstractMapController controller,
    List<MapPolygon> polygons = const <MapPolygon>[],
    List<MapPolyline> polylines = const <MapPolyline>[],
    MapDrawingMode drawingMode = MapDrawingMode.none,
    void Function(LatLng center, double zoom)? onCameraChanged,
    void Function(LatLng point)? onMapTap,
    void Function(MapPin pin)? onPinTap,
    void Function(LatLng point)? onDrawPointerDown,
    void Function(LatLng point)? onDrawPointerMove,
    void Function(LatLng point)? onDrawPointerUp,
    String? selectedPinId,
  }) {
    if (controller is MapControllerAdapter) {
      controller.attach((position, targetZoom) {
        _mapController.move(position, targetZoom);
      });
    }

    final captureDrawGestures = drawingMode == MapDrawingMode.freehand;
    final draftPolylines = _buildDraftPolylines(polygons, polylines);
    final renderedPolylines = [
      ...polylines
          .where(
            (polyline) => polyline.points.length >= 2 && !polyline.editable,
          )
          .map(_toPolyline),
      ...draftPolylines,
    ];

    final map = FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        minZoom: 3.5,
        maxZoom: 18.0,
        interactionOptions: InteractionOptions(
          flags: captureDrawGestures
              ? InteractiveFlag.all & ~InteractiveFlag.drag
              : InteractiveFlag.all,
        ),
        onPositionChanged: (position, _) {
          onCameraChanged?.call(position.center, position.zoom);
        },
        onTap: (_, point) => onMapTap?.call(point),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'br.com.cadernodesolo',
        ),
        if (renderedPolylines.isNotEmpty)
          PolylineLayer(
            polylines: renderedPolylines,
          ),
        if (polygons.isNotEmpty)
          PolygonLayer(
            polygons: polygons
                .where((polygon) => polygon.points.length >= 3)
                .map(
                  (polygon) => Polygon(
                    points: polygon.points,
                    color: AppColors.primary.withValues(alpha: 0.20),
                    borderColor: AppColors.primary,
                    borderStrokeWidth: 3,
                  ),
                )
                .toList(growable: false),
          ),
        MarkerLayer(
          markers: [
            ...pins.map(
              (pin) {
                final selected = selectedPinId == pin.id;
                return Marker(
                  point: pin.position,
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onPinTap?.call(pin),
                    child: Icon(
                      Icons.location_pin,
                      color:
                          selected ? AppColors.primaryDark : AppColors.primary,
                      size: selected ? 44 : 40,
                    ),
                  ),
                );
              },
            ),
            ...polygons
                .where((polygon) => polygon.editable)
                .expand((polygon) => polygon.points)
                .map(
                  (point) => Marker(
                    point: point,
                    width: 34,
                    height: 34,
                    child: const _VertexHandle(),
                  ),
                ),
          ],
        ),
      ],
    );

    if (!captureDrawGestures) {
      return map;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        map,
        Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            final point = _pointToLatLng(event.localPosition);
            if (point != null) {
              onDrawPointerDown?.call(point);
            }
          },
          onPointerMove: (event) {
            final point = _pointToLatLng(event.localPosition);
            if (point != null) {
              onDrawPointerMove?.call(point);
            }
          },
          onPointerUp: (event) {
            final point = _pointToLatLng(event.localPosition);
            if (point != null) {
              onDrawPointerUp?.call(point);
            }
          },
          child: const SizedBox.expand(),
        ),
      ],
    );
  }

  LatLng? _pointToLatLng(Offset localPosition) {
    try {
      return _mapController.camera.pointToLatLng(
        math.Point<double>(localPosition.dx, localPosition.dy),
      );
    } catch (_) {
      return null;
    }
  }

  List<Polyline> _buildDraftPolylines(
    List<MapPolygon> polygons,
    List<MapPolyline> polylines,
  ) {
    final rendered = <Polyline>[];

    for (final polygon in polygons) {
      if (polygon.points.length < 2) {
        continue;
      }
      rendered.add(
        Polyline(
          points: polygon.points,
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      );
      if (polygon.editable && polygon.points.length >= 3) {
        rendered.add(
          Polyline(
            points: [polygon.points.last, polygon.points.first],
            color: AppColors.primary.withValues(alpha: 0.55),
            strokeWidth: 2,
            pattern: StrokePattern.dashed(segments: const [8, 8]),
          ),
        );
      }
    }

    for (final polyline in polylines) {
      if (polyline.editable && polyline.points.length >= 2) {
        rendered.add(_toPolyline(polyline));
      }
    }

    return rendered;
  }

  Polyline _toPolyline(MapPolyline polyline) {
    return Polyline(
      points: polyline.points,
      color: AppColors.primary,
      strokeWidth: 3,
    );
  }
}

class _VertexHandle extends StatelessWidget {
  const _VertexHandle();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
