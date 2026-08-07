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
    List<MapPolygon> polygons = const <MapPolygon>[],
    List<MapPolyline> polylines = const <MapPolyline>[],
    MapDrawingMode drawingMode = MapDrawingMode.none,
    void Function(LatLng center, double zoom)? onCameraChanged,
    void Function(LatLng point)? onMapTap,
    void Function(MapPin pin)? onPinTap,
    void Function(LatLng point)? onDrawPointerDown,
    void Function(LatLng point)? onDrawPointerMove,
    void Function(LatLng point)? onDrawPointerUp,
    String? selectedPinId,
  }) {
    return Material(
      child: Column(
        children: [
          Text('selected:${selectedPinId ?? 'none'}'),
          Text('pins:${pins.map((pin) => pin.id).join(',')}'),
          Text('polygons:${polygons.length}'),
          Text('polylines:${polylines.length}'),
          Text('drawing:${drawingMode.name}'),
          Text(
              'vertices:${polygons.isEmpty ? 0 : polygons.first.points.length}'),
          TextButton(
            key: const Key('fake-map-tap'),
            onPressed: () => onMapTap?.call(const LatLng(-10.1, -48.1)),
            child: const Text('Tap map'),
          ),
          TextButton(
            key: const Key('fake-draw-down'),
            onPressed: () =>
                onDrawPointerDown?.call(const LatLng(-10.11, -48.11)),
            child: const Text('Draw down'),
          ),
          TextButton(
            key: const Key('fake-draw-move'),
            onPressed: () =>
                onDrawPointerMove?.call(const LatLng(-10.12, -48.12)),
            child: const Text('Draw move'),
          ),
          TextButton(
            key: const Key('fake-draw-up'),
            onPressed: () =>
                onDrawPointerUp?.call(const LatLng(-10.13, -48.13)),
            child: const Text('Draw up'),
          ),
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

  testWidgets('edita desenho com adicionar, desfazer, refazer e confirmar',
      (tester) async {
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
        child: const MaterialApp(home: MapaPage()),
      ),
    );

    await tester.pump();
    await tester.tap(find.byTooltip('Ferramentas de desenho'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Polígono'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Editando vertices'), findsOneWidget);

    await tester.tap(find.byKey(const Key('fake-map-tap')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('fake-map-tap')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('fake-map-tap')));
    await tester.pump();

    expect(find.text('vertices:3'), findsOneWidget);

    await tester.tap(find.byTooltip('Desfazer vertice'));
    await tester.pump();
    expect(find.text('vertices:2'), findsOneWidget);

    await tester.tap(find.byTooltip('Refazer vertice'));
    await tester.pump();
    expect(find.text('vertices:3'), findsOneWidget);

    await tester.tap(find.byTooltip('Confirmar desenho'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Editando vertices'), findsNothing);
    expect(find.text('polygons:1'), findsOneWidget);
  });

  testWidgets('desenho livre captura traco e confirma polyline',
      (tester) async {
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
        child: const MaterialApp(home: MapaPage()),
      ),
    );

    await tester.pump();
    await tester.tap(find.byTooltip('Ferramentas de desenho'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Livre'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Desenhando livre'), findsOneWidget);
    expect(find.text('drawing:freehand'), findsOneWidget);

    await tester.tap(find.byKey(const Key('fake-draw-down')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('fake-draw-move')));
    await tester.pump();

    await tester.tap(find.byTooltip('Confirmar desenho'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Desenhando livre'), findsNothing);
    expect(find.text('polylines:1'), findsOneWidget);
  });

  testWidgets('modo selecao mostra pin unico e retorna ponto tocado',
      (tester) async {
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

    LatLng? selected;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return TextButton(
                key: const Key('open-selection'),
                onPressed: () async {
                  selected = await Navigator.of(context).push<LatLng>(
                    MaterialPageRoute(
                      builder: (_) => const MapaPage(
                        initialAnaliseId: 'a1',
                        selectionMode: true,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-selection')));
    await tester.pumpAndSettle();

    expect(find.text('pins:a1,a2'), findsNothing);
    expect(find.byKey(const Key('fake-map-tap')), findsOneWidget);

    await tester.tap(find.byKey(const Key('fake-map-tap')));
    await tester.pumpAndSettle();

    expect(find.text('pins:a1'), findsOneWidget);
    expect(find.text('Ponto selecionado'), findsOneWidget);
    await tester.tap(find.text('Usar ponto'));
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    final selectedPoint = selected!;
    expect(selectedPoint.latitude, -10.1);
    expect(selectedPoint.longitude, -48.1);
  });
}
