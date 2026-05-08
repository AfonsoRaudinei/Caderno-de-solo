import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:soloforte/features/analise/application/providers/analise_provider.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/mapa/domain/map_engine.dart';
import 'package:soloforte/features/mapa/presentation/mapa_page.dart';
import 'package:soloforte/features/mapa/providers/map_engine_provider.dart';

class _FakeAnaliseNotifier extends AnaliseNotifier {
  _FakeAnaliseNotifier(this._analises);

  final List<AnaliseSolo> _analises;

  @override
  Stream<List<AnaliseSolo>> build() => Stream.value(_analises);
}

class _FakeMapEngine implements MapEngine {
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
    return Material(
      child: Column(
        children: [
          Text('selected:${selectedPinId ?? 'none'}'),
          for (final pin in pins)
            TextButton(
              key: Key('pin-${pin.id}'),
              onPressed: () => onPinTap?.call(pin),
              child: Text(pin.titulo),
            ),
        ],
      ),
    );
  }
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
    laboratorio: 'Exata Brasil',
    dataCadastro: DateTime(2026, 5, 8),
    profundidade: '0-20',
    latitude: latitude,
    longitude: longitude,
    phCaCl2: 5.4,
    k: 0.21,
    ca: 2.8,
    mg: 1.4,
  );
}

void main() {
  testWidgets('abre a ficha completa ao focar um pin inicial', (tester) async {
    final container = ProviderContainer(
      overrides: [
        analiseNotifierProvider.overrideWith(
          () => _FakeAnaliseNotifier(
            [
              _analise(
                id: 'a1',
                talhao: 'T-01',
                latitude: -10.1234,
                longitude: -48.9876,
              ),
            ],
          ),
        ),
        mapEngineProvider.overrideWithValue(_FakeMapEngine()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: MapaPage(initialAnaliseId: 'a1'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('selected:a1'), findsOneWidget);
    expect(find.text('Composição Física'), findsOneWidget);
    expect(find.text('Macronutrientes'), findsOneWidget);
    expect(find.text('Potássio (cmolc/dm³)'), findsOneWidget);
    expect(find.text('Soja'), findsOneWidget);
  });

  testWidgets('seleciona um pin ao tocar no mapa fake', (tester) async {
    final container = ProviderContainer(
      overrides: [
        analiseNotifierProvider.overrideWith(
          () => _FakeAnaliseNotifier(
            [
              _analise(
                id: 'a1',
                talhao: 'T-01',
                latitude: -10.1234,
                longitude: -48.9876,
              ),
              _analise(
                id: 'a2',
                talhao: 'T-02',
                latitude: -10.2234,
                longitude: -48.8876,
              ),
            ],
          ),
        ),
        mapEngineProvider.overrideWithValue(_FakeMapEngine()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MapaPage()),
      ),
    );

    await tester.pump();
    await tester.tap(find.byKey(const Key('pin-a2')));
    await tester.pumpAndSettle();

    expect(find.text('selected:a2'), findsOneWidget);
    expect(find.text('T-02'), findsAtLeastNWidgets(1));
    expect(find.text('Composição Física'), findsOneWidget);
  });
}
