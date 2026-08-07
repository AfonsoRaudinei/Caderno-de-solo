import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';
import 'package:soloforte/features/mapa/domain/map_engine.dart';

// TODO: implementar quando google_maps_flutter for adicionado ao pubspec
class GoogleMapEngine implements MapEngine {
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
    return const Center(
      child: Text('Google Maps — em breve'),
    );
  }
}
