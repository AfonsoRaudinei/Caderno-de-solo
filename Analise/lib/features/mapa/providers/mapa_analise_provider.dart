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
        .map(
          (analise) => MapPin(
            id: analise.id,
            titulo: analise.talhao.isNotEmpty ? analise.talhao : analise.id,
            position: LatLng(analise.latitude!, analise.longitude!),
            numeroAmostra: analise.numeroAmostra,
            produtor: analise.produtor,
            fazenda: analise.fazenda,
            laboratorio: analise.laboratorio,
            cultura: analise.cultura.label,
            safra: analise.safra,
            profundidade: analise.profundidade,
            descricaoLocal: analise.descricaoLocal,
          ),
        )
        .toList(growable: false);
  });
});
