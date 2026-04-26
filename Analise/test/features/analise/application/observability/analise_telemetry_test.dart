import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:soloforte/features/analise/application/observability/analise_telemetry.dart';

class _MemorySink implements AnaliseTelemetrySink {
  final List<Map<String, Object?>> events = [];

  @override
  void emit(Map<String, Object?> event) {
    events.add(Map<String, Object?>.from(event));
  }
}

void main() {
  group('AnaliseTelemetry', () {
    test('eventos críticos carregam campos obrigatórios', () {
      final sink = _MemorySink();
      final telemetry = AnaliseTelemetry(
        sink: sink,
        now: () => DateTime.utc(2026, 4, 6, 12, 0, 0),
        operationIdFactory: () => 'op-fixed',
        appVersion: '1.0.1',
        environment: 'production',
        platform: 'android',
      );

      for (final eventName in AnaliseTelemetryEvents.critical) {
        telemetry.emit(
          eventName: eventName,
          operationId: telemetry.newOperationId(),
          status: 'ok',
        );
      }

      expect(sink.events, hasLength(AnaliseTelemetryEvents.critical.length));
      for (final event in sink.events) {
        expect(event['telemetryVersion'], analiseTelemetryVersion);
        expect(event['eventName'], isA<String>());
        expect(event['timestampUtc'], isA<String>());
        expect(event['operationId'], isA<String>());
        expect(event['sessionId'], isA<String>());
        expect(event['appVersion'], '1.0.1');
        expect(event['platform'], 'android');
        expect(event['environment'], 'production');
      }
    });

    test('remove PII e converte idempotencyKey em hash', () {
      final sink = _MemorySink();
      final telemetry = AnaliseTelemetry(
        sink: sink,
        operationIdFactory: () => 'op-1',
      );

      telemetry.emit(
        eventName: AnaliseTelemetryEvents.saveStarted,
        operationId: telemetry.newOperationId(),
        context: const <String, Object?>{
          'produtor': 'Nome Sensível',
          'fazenda': 'Fazenda Sensível',
          'talhao': 'Talhão Sensível',
          'idempotencyKey': 'raw-key-123',
          'extra': 'ok',
        },
      );

      final event = sink.events.single;
      expect(event.containsKey('produtor'), isFalse);
      expect(event.containsKey('fazenda'), isFalse);
      expect(event.containsKey('talhao'), isFalse);
      expect(event['idempotencyKeyHash'], isA<String>());
      expect(event.containsKey('idempotencyKey'), isFalse);
      expect(event['extra'], 'ok');
    });

    test('composite sink replica evento para todos os sinks internos', () {
      final sinkA = _MemorySink();
      final sinkB = _MemorySink();
      final composite = CompositeAnaliseTelemetrySink(
        sinks: <AnaliseTelemetrySink>[sinkA, sinkB],
      );

      composite.emit(const <String, Object?>{
        'eventName': 'save_started',
        'operationId': 'op-composite',
      });

      expect(sinkA.events, hasLength(1));
      expect(sinkB.events, hasLength(1));
      expect(sinkA.events.single['operationId'], 'op-composite');
      expect(sinkB.events.single['operationId'], 'op-composite');
    });

    test('http sink envia payload com api key para endpoint configurado',
        () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() async {
        try {
          await server.close(force: true);
        } on Object {
          // Servidor já encerrado pelo fluxo do teste.
        }
      });

      final captured = Completer<Map<String, dynamic>>();
      unawaited(
        () async {
          final request = await server.first;
          final body = await utf8.decoder.bind(request).join();
          captured.complete(
            <String, dynamic>{
              'method': request.method,
              'path': request.uri.path,
              'apiKey': request.headers.value('X-API-Key'),
              'body': jsonDecode(body) as Map<String, dynamic>,
            },
          );
          request.response.statusCode = 200;
          await request.response.close();
        }(),
      );

      final sink = HttpAnaliseTelemetrySink(
        dio: Dio(),
        endpoint: Uri.parse('http://127.0.0.1:${server.port}/collect'),
        apiKey: 'test-key',
      );
      sink.emit(const <String, Object?>{
        'eventName': 'import_started',
        'operationId': 'op-http',
      });

      final result = await captured.future.timeout(const Duration(seconds: 3));
      final body = result['body'] as Map<String, dynamic>;
      expect(result['method'], 'POST');
      expect(result['path'], '/collect');
      expect(result['apiKey'], 'test-key');
      expect(body['eventName'], 'import_started');
      expect(body['operationId'], 'op-http');
    });
  });
}
