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
    void Function(LatLng center, double zoom)? onCameraChanged,
    void Function(MapPin pin)? onPinTap,
    String? selectedPinId,
  }) {
    return const Center(
      child: Text('Google Maps — em breve'),
    );
  }
}
