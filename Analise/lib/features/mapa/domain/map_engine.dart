import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

abstract class MapEngine {
  Widget buildMap({
    required LatLng center,
    required double zoom,
    required List<MapPin> pins,
    required AbstractMapController controller,
    void Function(LatLng center, double zoom)? onCameraChanged,
    void Function(MapPin pin)? onPinTap,
    String? selectedPinId,
  });
}

class MapPin {
  final String id;
  final String titulo;
  final LatLng position;
  final String? numeroAmostra;
  final String? produtor;
  final String? fazenda;
  final String? laboratorio;
  final String? cultura;
  final String? safra;
  final String? profundidade;
  final String? descricaoLocal;

  const MapPin({
    required this.id,
    required this.titulo,
    required this.position,
    this.numeroAmostra,
    this.produtor,
    this.fazenda,
    this.laboratorio,
    this.cultura,
    this.safra,
    this.profundidade,
    this.descricaoLocal,
  });
}

abstract class AbstractMapController {
  void move(LatLng position, double zoom);
}

class MapControllerAdapter implements AbstractMapController {
  void Function(LatLng position, double zoom)? _moveDelegate;

  void attach(void Function(LatLng position, double zoom) moveDelegate) {
    _moveDelegate = moveDelegate;
  }

  @override
  void move(LatLng position, double zoom) {
    _moveDelegate?.call(position, zoom);
  }
}
