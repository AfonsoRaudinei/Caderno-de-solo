import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:soloforte/features/analise/data/models/analise_solo_model.dart';
import 'package:soloforte/features/analise/data/models/produtor_model.dart';
import 'package:soloforte/features/analise/data/datasources/analise_datasource.dart';
import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';

class BatchFaultInjection {
  final int? failAfterPendingWrites;
  final bool failBeforeFinalCommit;
  final bool skipCompensationOnFailure;
  final bool leaveBatchPersistingOnFailure;

  const BatchFaultInjection({
    this.failAfterPendingWrites,
    this.failBeforeFinalCommit = false,
    this.skipCompensationOnFailure = false,
    this.leaveBatchPersistingOnFailure = false,
  });
}

class _BatchRecord {
  final String batchId;
  final String idempotencyKey;
  final SaveBatchStatus status;
  final SaveStrategy strategy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int attempt;
  final String? lastError;
  final List<String> resultAnaliseIds;

  const _BatchRecord({
    required this.batchId,
    required this.idempotencyKey,
    required this.status,
    required this.strategy,
    required this.createdAt,
    required this.updatedAt,
    required this.attempt,
    this.lastError,
    this.resultAnaliseIds = const <String>[],
  });

  _BatchRecord copyWith({
    SaveBatchStatus? status,
    DateTime? updatedAt,
    int? attempt,
    String? lastError,
    List<String>? resultAnaliseIds,
  }) {
    return _BatchRecord(
      batchId: batchId,
      idempotencyKey: idempotencyKey,
      status: status ?? this.status,
      strategy: strategy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attempt: attempt ?? this.attempt,
      lastError: lastError ?? this.lastError,
      resultAnaliseIds: resultAnaliseIds ?? this.resultAnaliseIds,
    );
  }
}

class AnaliseLocalDatasource implements AnaliseDataSource {
  final List<AnaliseSoloModel> _analisesMock = [];
  final _streamController =
      StreamController<List<AnaliseSoloModel>>.broadcast();
  bool _mockLoaded = false;
  final bool _useAssetSeed;
  final BatchFaultInjection _faultInjection;

  final Map<String, SaveBatchStatus> _persistStatusById = {};
  final Map<String, String?> _saveBatchIdById = {};
  final Map<String, _BatchRecord> _batchByKey = {};

  int _batchCounter = 0;

  AnaliseLocalDatasource({
    bool useAssetSeed = true,
    BatchFaultInjection faultInjection = const BatchFaultInjection(),
  })  : _useAssetSeed = useAssetSeed,
        _faultInjection = faultInjection;

  static const List<String> _jsonFiles = [
    'assets/lab_data/exata_brasil_16723_2024.json',
    'assets/lab_data/exata_brasil_17259_2025.json',
    'assets/lab_data/ibra_237526_2025.json',
    'assets/lab_data/mb_78416_2025.json',
    'assets/lab_data/sellar_6077_2025.json',
    'assets/lab_data/ibra_235421_2025.json',
    'assets/lab_data/mb_78418_2025.json',
    'assets/lab_data/exata_brasil_16738_2025.json',
    'assets/lab_data/exata_brasil_20573_2024.json',
  ];

  Future<void> _loadMockData() async {
    if (_mockLoaded) return;
    if (!_useAssetSeed) {
      _mockLoaded = true;
      return;
    }
    try {
      for (final file in _jsonFiles) {
        final jsonString = await rootBundle.loadString(file);
        final data = jsonDecode(jsonString) as Map<String, dynamic>;

        final relatorio = data['relatorio'] as String? ??
            data['os'] as String? ??
            data['laudoNumero'] as String? ??
            'N/A';
        final proprietario = data['proprietario'] as String? ??
            data['solicitante'] as String? ??
            'N/A';
        final propriedade = data['propriedade'] as String? ?? 'N/A';
        final dataEmissao = data['dataEmissao'] as String? ??
            data['dataGeracao'] as String? ??
            DateTime.now().toIso8601String();
        final laboratorio =
            data['laboratorio'] as String? ?? data['fonte'] as String? ?? 'N/A';

        String safra = '2023/2024';
        if (dataEmissao.length >= 4) {
          final year = int.tryParse(dataEmissao.substring(0, 4));
          if (year != null) {
            safra = '${year - 1}/$year';
          }
        }

        final amostras = data['amostras'] as List<dynamic>? ?? [];

        double? asDouble(dynamic v) {
          if (v == null) return null;
          if (v is num) return v.toDouble();
          if (v is String) return double.tryParse(v.replaceAll(',', '.'));
          if (v is Map) return null; // Algumas amostras podem ter sub-objetos
          return null;
        }

        for (var item in amostras) {
          if (item is! Map<String, dynamic>) continue;

          final numeroAmostra = (item['numeroAmostra'] ??
                  item['numeroSellar'] ??
                  item['amostra'] ??
                  'N/A')
              .toString();

          // Tratamento para K (mg/dm3 para mmolc/dm3 se necessário)
          dynamic kRaw = item['k_mgdm3'] ?? item['k'];
          double? kVal = asDouble(kRaw);
          if (kVal != null &&
              kRaw != null &&
              (item.containsKey('k_mgdm3') || (kVal > 10))) {
            // Se for mg/dm3 (geralmente > 10), converte para mmolc/dm3
            kVal = kVal / 391.0;
          }

          final mappedJson = <String, dynamic>{
            ...item,
            'id': '${relatorio}_$numeroAmostra',
            'cultura': 'soja',
            'safra': safra,
            'dataCadastro': dataEmissao,
            'fazenda': propriedade,
            'produtor': proprietario,
            'laboratorio': laboratorio,
            'k': kVal,
            'cu': asDouble(item['cu_meh'] ?? item['cu_dtpa'] ?? item['cu']),
            'fe': asDouble(item['fe_meh'] ?? item['fe_dtpa'] ?? item['fe']),
            'mn': asDouble(item['mn_meh'] ?? item['mn_dtpa'] ?? item['mn']),
            'zn': asDouble(item['zn_meh'] ?? item['zn_dtpa'] ?? item['zn']),
            'argila': asDouble(item['argila']),
            'p': asDouble(item['pMehlich'] ?? item['pResina'] ?? item['P']),
          };

          _analisesMock.add(AnaliseSoloModel.fromJson(mappedJson));
          _persistStatusById[mappedJson['id'] as String] =
              SaveBatchStatus.committed;
          _saveBatchIdById[mappedJson['id'] as String] = null;
        }
      }

      _mockLoaded = true;
    } catch (e) {
      assert(false, 'Falha ao carregar mock data: $e');
    }
  }

  @override
  Future<List<AnaliseSoloModel>> getAnalises() async {
    await _loadMockData();
    await Future.delayed(const Duration(milliseconds: 300));
    final visible = _analisesMock.where((a) {
      final status = _persistStatusById[a.id] ?? SaveBatchStatus.committed;
      return status == SaveBatchStatus.committed;
    }).toList(growable: false);
    return List.unmodifiable(visible);
  }

  @override
  Future<void> saveAnalise(AnaliseSoloModel analise) async {
    await saveAnalisesBatch([analise]);
  }

  @override
  Stream<List<AnaliseSoloModel>> watchAnalises({required String userId}) async* {
    yield await getAnalises();
    yield* _streamController.stream;
  }

  Future<void> _notify() async {
    _streamController.add(await getAnalises());
  }

  @override
  Future<SaveBatchResult> saveAnalisesBatch(
      List<AnaliseSoloModel> analises) async {
    await _loadMockData();
    if (analises.isEmpty) {
      final emptyBatchId = _nextBatchId();
      return SaveBatchResult(
        batchId: emptyBatchId,
        idempotencyKey: 'empty',
        status: SaveBatchStatus.committed,
        strategy: SaveStrategy.compensating,
        savedCount: 0,
        isReplay: false,
      );
    }

    await Future.delayed(const Duration(milliseconds: 250));

    final idempotencyKey = SaveBatchIdempotency.build(
      userId: 'local',
      payloads: analises.map((a) => a.toJson()).toList(growable: false),
      context: 'analise_batch_save',
    );
    final now = DateTime.now();
    final existing = _batchByKey[idempotencyKey];
    if (existing != null) {
      if (existing.status == SaveBatchStatus.committed) {
        return SaveBatchResult(
          batchId: existing.batchId,
          idempotencyKey: idempotencyKey,
          status: SaveBatchStatus.committed,
          strategy: existing.strategy,
          savedCount: existing.resultAnaliseIds.length,
          isReplay: true,
          code: SaveBatchCode.saveIdempotentReplay,
        );
      }
      if (existing.status == SaveBatchStatus.persisting ||
          existing.status == SaveBatchStatus.received ||
          existing.status == SaveBatchStatus.validating) {
        throw SaveBatchException(
          code: SaveBatchCode.saveInProgress,
          message: 'Há um lote ainda em processamento para esta operação.',
          batchId: existing.batchId,
          idempotencyKey: idempotencyKey,
        );
      }
    }

    final batchId = existing?.batchId ?? _nextBatchId();
    final attempt = (existing?.attempt ?? 0) + 1;
    _batchByKey[idempotencyKey] = _BatchRecord(
      batchId: batchId,
      idempotencyKey: idempotencyKey,
      status: SaveBatchStatus.persisting,
      strategy: SaveStrategy.compensating,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      attempt: attempt,
    );

    final previousById = <String, AnaliseSoloModel?>{};
    final previousStatusById = <String, SaveBatchStatus>{};
    final touchedIds = <String>[];

    try {
      var writes = 0;
      for (var i = 0; i < analises.length; i++) {
        final analise = analises[i];
        final id = analise.id;
        final oldIndex = _analisesMock.indexWhere((a) => a.id == id);
        previousById[id] = oldIndex >= 0 ? _analisesMock[oldIndex] : null;
        previousStatusById[id] =
            _persistStatusById[id] ?? SaveBatchStatus.committed;

        if (oldIndex >= 0) {
          _analisesMock[oldIndex] = analise;
        } else {
          _analisesMock.add(analise);
        }

        _persistStatusById[id] = SaveBatchStatus.persisting;
        _saveBatchIdById[id] = batchId;
        touchedIds.add(id);
        writes++;

        if (_faultInjection.failAfterPendingWrites != null &&
            writes >= _faultInjection.failAfterPendingWrites!) {
          throw Exception(
              'Falha simulada após gravação pendente de A${i + 1}.');
        }
      }

      if (_faultInjection.failBeforeFinalCommit) {
        throw Exception('Falha simulada antes do commit final.');
      }

      for (final id in touchedIds) {
        _persistStatusById[id] = SaveBatchStatus.committed;
      }

      _batchByKey[idempotencyKey] = _batchByKey[idempotencyKey]!.copyWith(
        status: SaveBatchStatus.committed,
        updatedAt: DateTime.now(),
        resultAnaliseIds: touchedIds,
      );

      await _notify();

      return SaveBatchResult(
        batchId: batchId,
        idempotencyKey: idempotencyKey,
        status: SaveBatchStatus.committed,
        strategy: SaveStrategy.compensating,
        savedCount: touchedIds.length,
        isReplay: false,
      );
    } catch (e) {
      if (!_faultInjection.skipCompensationOnFailure) {
        for (final id in touchedIds) {
          final old = previousById[id];
          if (old == null) {
            _analisesMock.removeWhere((a) => a.id == id);
            _persistStatusById.remove(id);
            _saveBatchIdById.remove(id);
          } else {
            final idx = _analisesMock.indexWhere((a) => a.id == id);
            if (idx >= 0) {
              _analisesMock[idx] = old;
            } else {
              _analisesMock.add(old);
            }
            _persistStatusById[id] =
                previousStatusById[id] ?? SaveBatchStatus.committed;
            _saveBatchIdById[id] = null;
          }
        }
      }

      _batchByKey[idempotencyKey] = _batchByKey[idempotencyKey]!.copyWith(
        status: _faultInjection.leaveBatchPersistingOnFailure
            ? SaveBatchStatus.persisting
            : (_faultInjection.skipCompensationOnFailure
                ? SaveBatchStatus.failed
                : SaveBatchStatus.compensated),
        updatedAt: DateTime.now(),
        lastError: e.toString(),
      );

      throw SaveBatchException(
        code: SaveBatchCode.saveCompensated,
        message:
            'Falha na persistência do lote; compensação aplicada para evitar estado parcial.',
        batchId: batchId,
        idempotencyKey: idempotencyKey,
        cause: e,
      );
    }
  }

  @override
  Future<void> recoverPendingBatches({
    Duration timeout = const Duration(minutes: 10),
  }) async {
    await _loadMockData();
    final now = DateTime.now();
    final stale = _batchByKey.entries
        .where(
          (entry) =>
              entry.value.status == SaveBatchStatus.persisting &&
              now.difference(entry.value.updatedAt) >= timeout,
        )
        .toList(growable: false);

    if (stale.isEmpty) return;
    for (final entry in stale) {
      final batchId = entry.value.batchId;
      for (final idEntry in _saveBatchIdById.entries) {
        if (idEntry.value == batchId &&
            _persistStatusById[idEntry.key] == SaveBatchStatus.persisting) {
          _persistStatusById[idEntry.key] = SaveBatchStatus.compensated;
        }
      }
      _batchByKey[entry.key] = entry.value.copyWith(
        status: SaveBatchStatus.compensated,
        updatedAt: now,
        lastError: 'Recovery converteu lote persisting órfão para compensated.',
      );
    }

    if (stale.isNotEmpty) {
      await _notify();
    }
  }

  @override
  Future<void> deleteAnalise(String id) async {
    await _loadMockData();
    await Future.delayed(const Duration(milliseconds: 300));
    _analisesMock.removeWhere((element) => element.id == id);
    _persistStatusById.remove(id);
    _saveBatchIdById.remove(id);
    await _notify();
  }

  @override
  Future<List<ProdutorModel>> getProdutores() async {
    await _loadMockData();
    await Future.delayed(const Duration(milliseconds: 300));
    final Map<String, ProdutorModel> map = {};
    for (final a in _analisesMock) {
      if (a.produtor.isEmpty) continue;
      final key = '${a.produtor}_${a.fazenda}';
      if (map.containsKey(key)) {
        final existing = map[key]!;
        map[key] = ProdutorModel(
          id: existing.id,
          nome: existing.nome,
          fazenda: existing.fazenda,
          totalAnalises: existing.totalAnalises + 1,
        );
      } else {
        map[key] = ProdutorModel(
          id: key,
          nome: a.produtor,
          fazenda: a.fazenda,
          totalAnalises: 1,
        );
      }
    }
    final list = map.values.toList();
    list.sort((a, b) => a.nome.compareTo(b.nome));
    return list;
  }

  String _nextBatchId() {
    _batchCounter++;
    return 'local-batch-${DateTime.now().millisecondsSinceEpoch}-$_batchCounter';
  }
}
