import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
import 'package:soloforte/features/mapa/domain/map_engine.dart';

final mapaAnaliseProvider = Provider<AsyncValue<List<MapPin>>>((ref) {
  final analisesAsync = ref.watch(analiseNotifierProvider);

  return analisesAsync.whenData((analises) {
    return analises
        .where(
            (analise) => analise.latitude != null && analise.longitude != null)
        .map(_pinFromAnalise)
        .toList(growable: false);
  });
});

final mapaAnaliseFiltradaProvider =
    Provider.family<AsyncValue<List<MapPin>>, String>((ref, analiseId) {
  final analisesAsync = ref.watch(analiseNotifierProvider);

  return analisesAsync.whenData((analises) {
    for (final analise in analises) {
      if (analise.id != analiseId) continue;
      if (analise.latitude == null || analise.longitude == null) {
        return const <MapPin>[];
      }
      return [_pinFromAnalise(analise)];
    }
    return const <MapPin>[];
  });
});

MapPin pinFromAnaliseForPreview(AnaliseSolo analise, LatLng position) {
  return MapPin(
    id: analise.id,
    titulo: analise.talhao.isNotEmpty ? analise.talhao : analise.id,
    position: position,
    numeroAmostra: analise.numeroAmostra,
    produtor: analise.produtor,
    fazenda: analise.fazenda,
    laboratorio: analise.laboratorio,
    cultura: analise.cultura.label,
    safra: analise.safra,
    profundidade: analise.profundidade,
    descricaoLocal: analise.descricaoLocal,
  );
}

MapPin _pinFromAnalise(AnaliseSolo analise) {
  return pinFromAnaliseForPreview(
    analise,
    LatLng(analise.latitude!, analise.longitude!),
  );
}
