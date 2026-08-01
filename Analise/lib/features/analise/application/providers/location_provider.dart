import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/domain/services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationServiceImpl();
});

sealed class LocationState {
  const LocationState();
}

class LocationIdle extends LocationState {
  const LocationIdle();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationSuccess extends LocationState {
  final LocationResult result;
  const LocationSuccess(this.result);
}

class LocationError extends LocationState {
  final String message;
  const LocationError(this.message);
}

final locationNotifierProvider =
    StateNotifierProvider.autoDispose<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref.watch(locationServiceProvider));
});

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationService _service;

  LocationNotifier(this._service) : super(const LocationIdle());

  Future<void> capturar() async {
    state = const LocationLoading();
    try {
      final result = await _service.capturar();
      state = LocationSuccess(result);
    } on LocationException catch (e) {
      state = LocationError(e.message);
    } catch (_) {
      state = const LocationError('Erro inesperado ao capturar localização.');
    }
  }

  void resetar() => state = const LocationIdle();
}
