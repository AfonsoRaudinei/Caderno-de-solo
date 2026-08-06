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
    void Function(LatLng center, double zoom)? onCameraChanged,
    void Function(LatLng point)? onMapTap,
    void Function(MapPin pin)? onPinTap,
    String? selectedPinId,
  }) {
    if (controller is MapControllerAdapter) {
      controller.attach((position, targetZoom) {
        _mapController.move(position, targetZoom);
      });
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        minZoom: 3.5,
        maxZoom: 18.0,
        onPositionChanged: (position, _) {
          final center = position.center;
          final currentZoom = position.zoom;
          onCameraChanged?.call(center, currentZoom);
        },
        onTap: (_, point) => onMapTap?.call(point),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'br.com.cadernodesolo',
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
