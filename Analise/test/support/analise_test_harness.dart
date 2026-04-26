import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';
import 'package:soloforte/features/analise/presentation/controllers/nova_analise_controller.dart';
import 'package:soloforte/features/analise/presentation/screens/nova_analise_screen.dart';

class InMemoryBatchGateway implements AnalisePersistenceGateway {
  final Map<String, AnaliseSolo> _storeById = {};
  final Map<String, SaveBatchResult> _resultByIdempotency = {};
  bool recarregou = false;
  bool failWithCompensation = false;
  bool failInProgress = false;
  Duration artificialDelay = Duration.zero;
  int saveCalls = 0;

  List<AnaliseSolo> get committed => _storeById.values.toList(growable: false)
    ..sort((a, b) => a.id.compareTo(b.id));

  @override
  Future<SaveBatchResult> salvarLote(List<AnaliseSolo> analises) async {
    saveCalls++;
    if (artificialDelay > Duration.zero) {
      await Future<void>.delayed(artificialDelay);
    }
    final idem = _buildIdempotency(analises);
    final replay = _resultByIdempotency[idem];
    if (replay != null) {
      return SaveBatchResult(
        batchId: replay.batchId,
        idempotencyKey: replay.idempotencyKey,
        status: replay.status,
        strategy: replay.strategy,
        savedCount: replay.savedCount,
        isReplay: true,
        code: SaveBatchCode.saveIdempotentReplay,
      );
    }

    if (failInProgress) {
      throw const SaveBatchException(
        code: SaveBatchCode.saveInProgress,
        message: 'Lote já está em processamento.',
      );
    }

    if (failWithCompensation) {
      throw const SaveBatchException(
        code: SaveBatchCode.saveCompensated,
        message: 'Falha simulada com compensação.',
      );
    }

    for (final analise in analises) {
      _storeById[analise.id] = analise;
    }

    final result = SaveBatchResult(
      batchId: 'inmem-batch-$saveCalls',
      idempotencyKey: idem,
      status: SaveBatchStatus.committed,
      strategy: SaveStrategy.atomic,
      savedCount: analises.length,
      isReplay: false,
    );
    _resultByIdempotency[idem] = result;
    return result;
  }

  @override
  Future<void> recarregar() async {
    recarregou = true;
  }

  String _buildIdempotency(List<AnaliseSolo> analises) {
    final canonical = analises..sort((a, b) => a.id.compareTo(b.id));
    final raw = canonical
        .map((a) => jsonEncode({
              'id': a.id,
              'talhao': a.talhao,
              'numeroAmostra': a.numeroAmostra,
              'phCaCl2': a.phCaCl2,
              'k': a.k,
              'ca': a.ca,
              'mg': a.mg,
            }))
        .join('|');
    return raw;
  }
}

Future<void> setTestSurface(
  WidgetTester tester, {
  required Size size,
  double devicePixelRatio = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

ProviderContainer makeAnaliseContainer({
  InMemoryBatchGateway? gateway,
}) {
  final resolvedGateway = gateway ?? InMemoryBatchGateway();
  return ProviderContainer(
    overrides: [
      analisePersistenceGatewayProvider.overrideWithValue(resolvedGateway),
    ],
  );
}

Widget makeNovaAnaliseApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NovaAnaliseScreen(),
    ),
  );
}
