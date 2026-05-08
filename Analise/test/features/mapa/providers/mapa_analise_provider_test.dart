import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/mapa/providers/mapa_analise_provider.dart';

class _FakeAnaliseNotifier extends AnaliseNotifier {
  _FakeAnaliseNotifier(this._analises);

  final List<AnaliseSolo> _analises;

  @override
  Stream<List<AnaliseSolo>> build() => Stream.value(_analises);
}

AnaliseSolo _analise({
  required String id,
  required String talhao,
  double? latitude,
  double? longitude,
}) {
  return AnaliseSolo(
    id: id,
    fazenda: 'Fazenda $talhao',
    produtor: 'Produtor $talhao',
    talhao: talhao,
    numeroAmostra: 'AM-$talhao',
    cultura: Cultura.soja,
    safra: '2025/2026',
    laboratorio: 'IBRA',
    dataCadastro: DateTime(2026, 5, 8),
    profundidade: '0-20',
    latitude: latitude,
    longitude: longitude,
  );
}

void main() {
  test('gera pins apenas para análises com coordenadas e preserva metadados',
      () async {
    final container = ProviderContainer(
      overrides: [
        analiseNotifierProvider.overrideWith(
          () => _FakeAnaliseNotifier(
            [
              _analise(
                id: 'a1',
                talhao: 'T-01',
                latitude: -12.34,
                longitude: -45.67,
              ),
              _analise(
                id: 'a2',
                talhao: 'T-02',
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(analiseNotifierProvider.future);
    final pinsAsync = container.read(mapaAnaliseProvider);
    final pins = pinsAsync.valueOrNull;

    expect(pins, isNotNull);
    expect(pins, hasLength(1));
    expect(pins!.single.id, 'a1');
    expect(pins.single.titulo, 'T-01');
    expect(pins.single.numeroAmostra, 'AM-T-01');
    expect(pins.single.laboratorio, 'IBRA');
    expect(pins.single.profundidade, '0-20');
    expect(pins.single.position.latitude, -12.34);
    expect(pins.single.position.longitude, -45.67);
  });
}
