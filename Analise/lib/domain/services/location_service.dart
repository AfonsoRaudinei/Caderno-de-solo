import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Resultado da captura de localização.
class LocationResult {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String? cidade;
  final String? estado;
  final String? pais;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.cidade,
    this.estado,
    this.pais,
  });

  String get coordenadasFormatadas =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  String get enderecoResumido {
    final partes = [cidade, estado, pais].whereType<String>().toList();
    return partes.isNotEmpty ? partes.join(', ') : coordenadasFormatadas;
  }
}

abstract class LocationService {
  Future<LocationResult> capturar();
}

class LocationServiceImpl implements LocationService {
  @override
  Future<LocationResult> capturar() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'GPS desativado. Ative a localização nas configurações do dispositivo.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException(
          'Permissão de localização negada. Permita o acesso nas configurações do app.',
        );
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Localização bloqueada permanentemente. Habilite em Configurações > SoloForte > Localização.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );

    String? cidade, estado, pais;
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        cidade = p.subAdministrativeArea ?? p.locality;
        estado = p.administrativeArea;
        pais = p.country;
      }
    } catch (_) {
      // Geocodificação é opcional; retorna coordenadas mesmo sem endereço.
    }

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      cidade: cidade,
      estado: estado,
      pais: pais,
    );
  }
}

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => message;
}
