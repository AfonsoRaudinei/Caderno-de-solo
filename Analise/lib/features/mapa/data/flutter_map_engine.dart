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
    void Function(LatLng center, double zoom)? onCameraChanged,
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
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'br.com.cadernodesolo',
        ),
        MarkerLayer(
          markers: pins.map(
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
                    color: selected ? AppColors.primaryDark : AppColors.primary,
                    size: selected ? 44 : 40,
                  ),
                ),
              );
            },
          ).toList(growable: false),
        ),
      ],
    );
  }
}
