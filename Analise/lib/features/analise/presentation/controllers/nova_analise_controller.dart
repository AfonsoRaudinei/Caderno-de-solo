import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/domain/services/location_service.dart';
import 'package:soloforte/features/analise/application/observability/analise_telemetry.dart';
import 'package:soloforte/features/analise/application/providers/analise_telemetry_provider.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/models/analise_draft.dart';
import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';
import 'package:soloforte/features/analise/domain/usecases/calcular_derivados_analise.dart';
import 'package:soloforte/features/analise/domain/validation/analise_data_contract.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';
import 'package:uuid/uuid.dart';

/// Estado do controller da tabela de nova análise
class NovaAnaliseState {
  final List<AnaliseDraft> analises;
  final bool isSaving;
  final String? error;
  final ValidationSnapshot validation;
  final String? highlightedCellKey;
  final int issueCursor;

  // Campos globais de nível de laudo (Zona 1)
  final String laudoProdutor;
  final String laudoFazenda;
  final String laudoLaboratorio;
  final String laudoSafra;

  const NovaAnaliseState({
    required this.analises,
    this.isSaving = false,
    this.error,
    this.validation = ValidationSnapshot.empty,
    this.highlightedCellKey,
    this.issueCursor = 0,
    this.laudoProdutor = '',
    this.laudoFazenda = '',
    this.laudoLaboratorio = '',
    this.laudoSafra = '',
  });

  NovaAnaliseState copyWith({
    List<AnaliseDraft>? analises,
    bool? isSaving,
    String? error,
    bool clearError = false,
    ValidationSnapshot? validation,
    String? highlightedCellKey,
    bool clearHighlightedCell = false,
    int? issueCursor,
    String? laudoProdutor,
    String? laudoFazenda,
    String? laudoLaboratorio,
    String? laudoSafra,
  }) {
    return NovaAnaliseState(
      analises: analises ?? this.analises,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      validation: validation ?? this.validation,
      highlightedCellKey: clearHighlightedCell
          ? null
          : (highlightedCellKey ?? this.highlightedCellKey),
      issueCursor: issueCursor ?? this.issueCursor,
      laudoProdutor: laudoProdutor ?? this.laudoProdutor,
      laudoFazenda: laudoFazenda ?? this.laudoFazenda,
      laudoLaboratorio: laudoLaboratorio ?? this.laudoLaboratorio,
      laudoSafra: laudoSafra ?? this.laudoSafra,
    );
  }
}

abstract class AnalisePersistenceGateway {
  Future<SaveBatchResult> salvarLote(List<AnaliseSolo> analises);
  Future<void> recarregar();
}

class RiverpodAnalisePersistenceGateway implements AnalisePersistenceGateway {
  final Ref ref;

  RiverpodAnalisePersistenceGateway(this.ref);

  @override
  Future<SaveBatchResult> salvarLote(List<AnaliseSolo> analises) async {
    return ref.read(analiseNotifierProvider.notifier).salvarLote(analises);
  }

  @override
  Future<void> recarregar() async {
    await ref.read(analiseNotifierProvider.notifier).recarregar();
  }
}

final analisePersistenceGatewayProvider = Provider<AnalisePersistenceGateway>(
  (ref) => RiverpodAnalisePersistenceGateway(ref),
);

/// Controller para a tela NovaAnalise em formato tabela planilha.
class NovaAnaliseController extends StateNotifier<NovaAnaliseState> {
  final Ref _ref;
  final _calc = const CalcularDerivadosAnalise();
  final _validator = const AnaliseValidationEngine();
  final _uuid = const Uuid();
  final LocationService _locationService = LocationServiceImpl();

  /// Máximo de colunas (amostras) permitido
  static const int maxColunas = 6;

  NovaAnaliseController(this._ref, {AnaliseSolo? analiseParaEditar})
      : super(
          NovaAnaliseState(
            analises: analiseParaEditar != null
                ? [AnaliseDraft.fromAnaliseSolo(analiseParaEditar)]
                : [AnaliseDraft.empty()],
            laudoProdutor: analiseParaEditar?.produtor ?? '',
            laudoFazenda: analiseParaEditar?.fazenda ?? '',
            laudoLaboratorio: analiseParaEditar?.laboratorio ?? '',
            laudoSafra: analiseParaEditar?.safra ?? '',
          ),
        ) {
    _refreshValidation();
  }

  // ── Gerência de colunas ────────────────────────────────────────────────

  void adicionarAnalise() {
    if (state.analises.length >= maxColunas) return;
    state = state.copyWith(
      analises: [...state.analises, AnaliseDraft.empty()],
      issueCursor: 0,
      clearHighlightedCell: true,
    );
    _refreshValidation();
  }

  void removerAnalise(int index) {
    if (state.analises.length <= 1) return;
    final updated = [...state.analises]..removeAt(index);
    state = state.copyWith(
      analises: updated,
      issueCursor: 0,
      clearHighlightedCell: true,
    );
    _refreshValidation();
  }

  void atualizarCampo(int index, String campo, dynamic valor) {
    final updated = [...state.analises];
    updated[index] = updated[index].withField(campo, valor?.toString() ?? '');
    state = state.copyWith(
      analises: updated,
      clearError: true,
    );
    _refreshValidation();
  }

  void atualizarLaudoProdutor(String valor) {
    state = state.copyWith(
      laudoProdutor: valor,
      clearError: true,
    );
  }

  void atualizarLaudoFazenda(String valor) {
    state = state.copyWith(
      laudoFazenda: valor,
      clearError: true,
    );
  }

  void atualizarLaudoLaboratorio(String valor) {
    state = state.copyWith(
      laudoLaboratorio: valor,
      issueCursor: 0,
      clearHighlightedCell: true,
      clearError: true,
    );
    _refreshValidation();
  }

  void atualizarLaudoSafra(String valor) {
    state = state.copyWith(
      laudoSafra: valor,
      clearError: true,
    );
  }

  Future<String?> capturarGps(int analiseIndex) async {
    try {
      final location = await _locationService.capturar();
      atualizarCampo(
        analiseIndex,
        'latitude',
        location.latitude.toStringAsFixed(8),
      );
      atualizarCampo(
        analiseIndex,
        'longitude',
        location.longitude.toStringAsFixed(8),
      );
      atualizarCampo(analiseIndex, 'descricaoLocal', location.enderecoResumido);
      return null;
    } on LocationException catch (e) {
      return e.message;
    } catch (_) {
      return 'Não foi possível capturar o GPS agora. Tente novamente.';
    }
  }

  // ── Derivados ──────────────────────────────────────────────────────────

  Map<String, double> calcularDerivados(AnaliseDraft analise) {
    return _calc.call({
      'ca': analise.doubleValue('ca'),
      'mg': analise.doubleValue('mg'),
      'k': analise.doubleValue('k'),
      'na': analise.doubleValue('na') ?? 0.0,
      'al': analise.doubleValue('al'),
      'hMaisAl': analise.doubleValue('hMaisAl'),
    });
  }

  List<Map<String, double>> get todosDerivados =>
      state.analises.map(calcularDerivados).toList();

  // ── Importação ─────────────────────────────────────────────────────────

  /// Carrega dados importados de um laboratório.
  /// Cada item da lista é um mapa com chaves canônicas.
  void carregarDeImportacao(List<Map<String, dynamic>> dados) {
    if (dados.isEmpty) return;
    final drafts = dados.map(AnaliseDraft.fromImportMap).toList();
    state = state.copyWith(
      analises: drafts,
      issueCursor: 0,
      clearHighlightedCell: true,
      clearError: true,
    );
    _refreshValidation();
  }

  /// Converte uma [AnaliseSolo] importada para o formato de rascunho.
  void carregarDeAnaliseSolo(List<AnaliseSolo> analises) {
    if (analises.isEmpty) return;

    final first = analises.first;
    final drafts = analises.map(AnaliseDraft.fromAnaliseSolo).toList();
    state = state.copyWith(
      analises: drafts,
      laudoProdutor: first.produtor,
      laudoFazenda: first.fazenda,
      laudoLaboratorio: first.laboratorio,
      laudoSafra: first.safra,
      issueCursor: 0,
      clearHighlightedCell: true,
      clearError: true,
    );
    _refreshValidation();
  }

  ValidationIssue? destacarProximaCelulaInvalida() {
    final ordered = [
      ...state.validation.issues
          .where((i) => i.severity == ValidationSeverity.error),
      ...state.validation.issues
          .where((i) => i.severity == ValidationSeverity.warning),
    ]..sort((a, b) {
        if (a.columnIndex != b.columnIndex) {
          return a.columnIndex.compareTo(b.columnIndex);
        }
        return a.fieldLabel.compareTo(b.fieldLabel);
      });
    if (ordered.isEmpty) return null;

    final cursor = state.issueCursor % ordered.length;
    final issue = ordered[cursor];
    state = state.copyWith(
      highlightedCellKey: issue.cellKey,
      issueCursor: cursor + 1,
    );
    return issue;
  }

  // ── Persistência ───────────────────────────────────────────────────────

  Future<bool> salvar() async {
    if (state.isSaving) return false;
    final telemetry = _ref.read(analiseTelemetryProvider);
    final operationId = telemetry.newOperationId();
    final saveWatch = Stopwatch()..start();
    _refreshValidation();

    telemetry.emit(
      eventName: AnaliseTelemetryEvents.saveStarted,
      operationId: operationId,
      labId:
          state.laudoLaboratorio.trim().isEmpty ? null : state.laudoLaboratorio,
      columnCount: state.analises.length,
      status: 'started',
    );

    final erroValidacao = _validarAntesDeSalvar();
    if (erroValidacao != null) {
      telemetry.emit(
        eventName: AnaliseTelemetryEvents.saveValidationBlocked,
        operationId: operationId,
        labId: state.laudoLaboratorio.trim().isEmpty
            ? null
            : state.laudoLaboratorio,
        columnCount: state.analises.length,
        status: 'blocked',
        durationMs: saveWatch.elapsedMilliseconds,
        errorCode: 'SAVE_VALIDATION_BLOCKED',
        context: <String, Object?>{
          'issues': state.validation.issues.length,
          'errors': state.validation.totalErrors,
          'warnings': state.validation.totalWarnings,
        },
      );
      state = state.copyWith(
        isSaving: false,
        error: erroValidacao,
      );
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      clearError: true,
    );
    try {
      final persistence = _ref.read(analisePersistenceGatewayProvider);
      final total = state.analises.length;
      final analisesParaSalvar = <AnaliseSolo>[];

      for (var i = 0; i < total; i++) {
        final draftOriginal = state.analises[i];
        final normalizedFields = i < state.validation.normalizedColumns.length
            ? state.validation.normalizedColumns[i]
            : draftOriginal.fields;
        final draft = draftOriginal.copyWith(fields: normalizedFields);

        final analise = draft.toEntity(
          uuid: _uuid,
          laudoProdutor: state.laudoProdutor,
          laudoFazenda: state.laudoFazenda,
          laudoLaboratorio: state.laudoLaboratorio,
          laudoSafra: state.laudoSafra,
          validationSnapshot: state.validation.metadataForColumn(i),
        );
        analisesParaSalvar.add(analise);
      }

      telemetry.emit(
        eventName: AnaliseTelemetryEvents.savePersisting,
        operationId: operationId,
        labId: state.laudoLaboratorio.trim().isEmpty
            ? null
            : state.laudoLaboratorio,
        columnCount: analisesParaSalvar.length,
        status: 'persisting',
      );

      final result = await persistence.salvarLote(analisesParaSalvar);
      if (result.isReplay ||
          result.code == SaveBatchCode.saveIdempotentReplay) {
        telemetry.emit(
          eventName: AnaliseTelemetryEvents.saveIdempotentReplay,
          operationId: operationId,
          labId: state.laudoLaboratorio,
          columnCount: analisesParaSalvar.length,
          batchId: result.batchId,
          idempotencyKeyHash: telemetry.hashIdentifier(result.idempotencyKey),
          status: result.status.name,
          durationMs: saveWatch.elapsedMilliseconds,
          errorCode: 'SAVE_IDEMPOTENT_REPLAY',
          context: <String, Object?>{
            'strategy': result.strategy.name,
            'savedCount': result.savedCount,
          },
        );
      }
      if (result.status != SaveBatchStatus.committed) {
        throw SaveBatchException(
          code: SaveBatchCode.saveAtomicFailed,
          message: 'Lote não finalizou em estado committed.',
          batchId: result.batchId,
          idempotencyKey: result.idempotencyKey,
        );
      }

      await persistence.recarregar();
      telemetry.emit(
        eventName: AnaliseTelemetryEvents.saveCommitted,
        operationId: operationId,
        labId: state.laudoLaboratorio,
        columnCount: analisesParaSalvar.length,
        batchId: result.batchId,
        idempotencyKeyHash: telemetry.hashIdentifier(result.idempotencyKey),
        status: result.status.name,
        durationMs: saveWatch.elapsedMilliseconds,
        context: <String, Object?>{
          'strategy': result.strategy.name,
          'savedCount': result.savedCount,
          'replay': result.isReplay,
        },
      );
      state = state.copyWith(
        isSaving: false,
        clearError: true,
      );
      return true;
    } catch (e, st) {
      final saveCode = _saveErrorCode(e);
      final saveEvent = saveCode == 'SAVE_COMPENSATED'
          ? AnaliseTelemetryEvents.saveCompensated
          : AnaliseTelemetryEvents.saveFailed;
      String? batchId;
      String? idempotencyKeyHash;
      if (e is SaveBatchException) {
        batchId = e.batchId;
        idempotencyKeyHash = e.idempotencyKey == null
            ? null
            : telemetry.hashIdentifier(e.idempotencyKey!);
      }
      telemetry.emit(
        eventName: saveEvent,
        operationId: operationId,
        labId: state.laudoLaboratorio.trim().isEmpty
            ? null
            : state.laudoLaboratorio,
        columnCount: state.analises.length,
        batchId: batchId,
        idempotencyKeyHash: idempotencyKeyHash,
        status: 'failed',
        durationMs: saveWatch.elapsedMilliseconds,
        errorCode: saveCode,
        context: <String, Object?>{
          'message': e.toString(),
        },
      );
      debugPrint('Falha ao salvar análise: $e');
      debugPrintStack(stackTrace: st);
      state = state.copyWith(
        isSaving: false,
        error: _mapearErroSalvar(e),
      );
      return false;
    } finally {
      saveWatch.stop();
    }
  }

  void _refreshValidation() {
    final validation = _validator.validate(
      drafts: state.analises,
      labDisplayName: state.laudoLaboratorio,
    );
    final keepHighlight = state.highlightedCellKey != null &&
        validation.issues
            .any((issue) => issue.cellKey == state.highlightedCellKey);
    state = state.copyWith(
      validation: validation,
      clearHighlightedCell: !keepHighlight,
    );
  }

  String? _validarAntesDeSalvar() {
    final produtor = state.laudoProdutor.trim();
    final fazenda = state.laudoFazenda.trim();
    final laboratorio = state.laudoLaboratorio.trim();
    final safra = state.laudoSafra.trim();

    if (produtor.trim().isEmpty) return 'Informe o produtor antes de salvar.';
    if (fazenda.isEmpty) return 'Informe a fazenda antes de salvar.';
    if (laboratorio.isEmpty) return 'Selecione o laboratório antes de salvar.';
    if (safra.isEmpty) return 'Informe a safra antes de salvar.';

    if (state.analises.isEmpty) {
      return 'Adicione ao menos uma análise.';
    }

    return null; // avisos de validação não bloqueiam o salvamento
  }

  String _mapearErroSalvar(Object erro) {
    if (erro is SaveBatchException) {
      switch (erro.code) {
        case SaveBatchCode.saveAtomicFailed:
          return 'Falha ao persistir o lote. Tente novamente.';
        case SaveBatchCode.saveCompensated:
          return 'Falha durante o salvar, mas a compensação evitou estado parcial.';
        case SaveBatchCode.saveIdempotentReplay:
          return 'Reenvio detectado: lote já salvo anteriormente.';
        case SaveBatchCode.saveInProgress:
          return 'Ainda processando o último envio. Aguarde e tente novamente.';
      }
    }

    final raw = erro.toString().replaceFirst('Exception: ', '').trim();
    final msg = raw.toLowerCase();

    if (msg.contains('permission-denied') ||
        msg.contains('missing or insufficient permissions')) {
      return 'Sem permissão para salvar. Faça login novamente.';
    }

    if (msg.contains('unauthenticated') ||
        msg.contains('não autenticado') ||
        msg.contains('sessão expirada')) {
      return 'Sessão expirada. Entre novamente para salvar.';
    }

    if (msg.contains('unavailable') ||
        msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('timeout')) {
      return 'Falha de conexão. Verifique sua internet e tente novamente.';
    }

    if (raw.isEmpty) return 'Erro ao salvar. Tente novamente.';
    return raw;
  }

  String _saveErrorCode(Object erro) {
    if (erro is SaveBatchException) {
      return switch (erro.code) {
        SaveBatchCode.saveAtomicFailed => 'SAVE_ATOMIC_FAILED',
        SaveBatchCode.saveCompensated => 'SAVE_COMPENSATED',
        SaveBatchCode.saveIdempotentReplay => 'SAVE_IDEMPOTENT_REPLAY',
        SaveBatchCode.saveInProgress => 'SAVE_IN_PROGRESS',
      };
    }
    final raw = erro.toString().toLowerCase();
    if (raw.contains('timeout') ||
        raw.contains('socket') ||
        raw.contains('network')) {
      return 'SAVE_NETWORK_ERROR';
    }
    return 'SAVE_UNKNOWN_ERROR';
  }
}

// ── Provider ────────────────────────────────────────────────────────────────

final novaAnaliseControllerProvider = StateNotifierProvider.family
    .autoDispose<NovaAnaliseController, NovaAnaliseState, AnaliseSolo?>(
  (ref, analiseParaEditar) =>
      NovaAnaliseController(ref, analiseParaEditar: analiseParaEditar),
);
