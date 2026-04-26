import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/mapa/data/flutter_map_engine.dart';
import 'package:soloforte/features/mapa/domain/map_engine.dart';

final mapEngineProvider = Provider<MapEngine>((ref) {
  return FlutterMapEngine();
  // Futuramente: return GoogleMapEngine();
});
