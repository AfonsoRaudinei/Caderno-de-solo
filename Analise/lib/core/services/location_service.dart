import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<({double latitude, double longitude})?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      return (
        latitude: double.parse(position.latitude.toStringAsFixed(8)),
        longitude: double.parse(position.longitude.toStringAsFixed(8)),
      );
    } catch (e) {
      return null;
    }
  }
}
