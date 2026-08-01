import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloforte/core/config/app_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:soloforte/data/datasources/remote/analise_firestore_datasource.dart';
import 'package:soloforte/features/analise/data/datasources/analise_datasource.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/entities/produtor.dart';
import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';
import 'package:soloforte/features/analise/domain/usecases/get_analises_usecase.dart';
import 'package:soloforte/features/analise/domain/usecases/save_analise_usecase.dart';
import 'package:soloforte/features/analise/domain/usecases/delete_analise_usecase.dart';
import 'package:soloforte/features/analise/domain/services/cliente_analises_filter.dart';
import 'package:soloforte/features/analise/domain/services/produtor_resolucao_service.dart';
import 'package:soloforte/features/analise/application/providers/produtor_configurado_provider.dart';
import 'package:soloforte/features/analise/application/mappers/cliente_hierarquia_mapper.dart';
import 'package:soloforte/features/analise/domain/usecases/reparar_vinculos_legados_usecase.dart';
import 'package:soloforte/features/clientes/application/providers/cliente_provider.dart';
import 'package:soloforte/features/clientes/data/repositories/cliente_repository.dart';
import 'package:soloforte/features/clientes/domain/entities/cliente_entity.dart';
import 'package:soloforte/features/analise/domain/repositories/analise_repository.dart';
import 'package:soloforte/features/analise/data/repositories/analise_repository_impl.dart';
import 'package:soloforte/features/analise/data/datasources/analise_local_datasource.dart';

part 'analise_provider.g.dart';

@riverpod
AnaliseLocalDatasource analiseLocalDatasource(AnaliseLocalDatasourceRef ref) {
  return AnaliseLocalDatasource();
}

final analiseFirestoreDatasourceProvider =
    Provider<AnaliseFirestoreDatasource>((ref) {
  return AnaliseFirestoreDatasource();
});

final analiseDataSourceProvider = Provider<AnaliseDataSource>((ref) {
  return ref.watch(analiseFirestoreDatasourceProvider);
});

@riverpod
AnaliseRepository analiseRepository(AnaliseRepositoryRef ref) {
  final dataSource = ref.watch(analiseDataSourceProvider);
  return AnaliseRepositoryImpl(dataSource: dataSource);
}

@riverpod
GetAnalisesUsecase getAnalisesUsecase(GetAnalisesUsecaseRef ref) {
  final repository = ref.watch(analiseRepositoryProvider);
  return GetAnalisesUsecase(repository);
}

@riverpod
SaveAnaliseUsecase saveAnaliseUsecase(SaveAnaliseUsecaseRef ref) {
  final repository = ref.watch(analiseRepositoryProvider);
  return SaveAnaliseUsecase(repository);
}

@riverpod
DeleteAnaliseUsecase deleteAnaliseUsecase(DeleteAnaliseUsecaseRef ref) {
  final repository = ref.watch(analiseRepositoryProvider);
  return DeleteAnaliseUsecase(repository);
}

@riverpod
Stream<User?> authState(AuthStateRef ref) {
  if (!kDebugMode) return FirebaseAuth.instance.authStateChanges();

  debugPrint('🟢 [authState] Stream iniciada');
  return FirebaseAuth.instance.authStateChanges().map((user) {
    debugPrint('🟢 [authState] Evento recebido: uid=${user?.uid}');
    return user;
  });
}

/// Expõe apenas o UID do usuário logado (ou null).
/// Por ser String?, só muda em login/logout real — nunca em refresh de token.
/// É seguro usar ref.watch neste provider dentro de um gerador async*.
@riverpod
String? currentUserId(CurrentUserIdRef ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
}

@Riverpod(keepAlive: true)
class AnaliseNotifier extends _$AnaliseNotifier {
  @override
  Stream<List<AnaliseSolo>> build() async* {
    if (kDebugMode) debugPrint('🔵 [AnaliseNotifier] build() iniciado');
    final authState = await ref.watch(authStateProvider.future);
    final uid = authState?.uid;
    if (kDebugMode) debugPrint('🟡 [AnaliseNotifier] Auth resolvido: uid=$uid');

    if (uid == null) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [AnaliseNotifier] Usuário não autenticado — yield [] permanente',
        );
      }
      yield [];
      return;
    }

    if (kDebugMode) {
      debugPrint('✅ [AnaliseNotifier] UID válido — iniciando stream Firestore');
    }
    yield* ref.read(getAnalisesUsecaseProvider).stream(userId: uid).handleError(
      (Object error, StackTrace stackTrace) {
        if (kDebugMode) {
          debugPrint('❌ [AnaliseNotifier] Erro na stream: $error');
        }
        debugPrint('Erro ao carregar análises do Firestore: $error');
        throw error;
      },
    );
  }

  Future<void> salvar(AnaliseSolo analise) async {
    if (AppConfig.useFirestore && FirebaseAuth.instance.currentUser == null) {
      throw Exception('Sessão expirada. Faça login novamente para salvar.');
    }
    await ref.read(saveAnaliseUsecaseProvider).call(analise);
  }

  Future<SaveBatchResult> salvarLote(List<AnaliseSolo> analises) async {
    if (AppConfig.useFirestore && FirebaseAuth.instance.currentUser == null) {
      throw const SaveBatchException(
        code: SaveBatchCode.saveAtomicFailed,
        message: 'Sessão expirada. Faça login novamente para salvar.',
      );
    }
    return ref.read(analiseRepositoryProvider).saveAnalisesBatch(analises);
  }

  Future<void> recarregar() async {
    // O stream do Firestore já emite alterações após salvar/excluir/mover.
    // Manter este método como no-op evita que o caminho de save force reload
    // do StreamNotifier e volte para AsyncLoading na tela de Pastas.
  }

  Future<void> repararProdutoresLegados() async {
    final configurado =
        ref.read(produtorConfiguradoProvider).valueOrNull?.trim() ?? '';
    if (configurado.isEmpty) return;

    final lista = state.valueOrNull ?? const <AnaliseSolo>[];
    final reparos = <AnaliseSolo>[];

    for (final analise in lista) {
      if (!ProdutorResolucaoService.isProdutorInvalido(analise.produtor)) {
        continue;
      }

      final reparada = ProdutorResolucaoService.aplicarProdutorConfigurado(
        analise,
        configurado,
      );
      if (reparada.produtor.trim().isEmpty ||
          reparada.produtor == analise.produtor) {
        continue;
      }
      reparos.add(reparada);
    }

    for (final analise in reparos) {
      await atualizarAnalise(analise);
    }
  }

  Future<void> repararVinculosLegados() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null || uid.isEmpty) return;

    List<ClienteEntity> clientes;
    try {
      clientes = await ref.read(clienteRepositoryProvider).listarClientes(uid);
    } catch (_) {
      return;
    }
    if (clientes.isEmpty) return;

    final snapshots = mapClientesParaHierarquia(clientes);
    final lista = state.valueOrNull ?? const <AnaliseSolo>[];
    final reparos = const RepararVinculosLegadosUsecase()(
      analises: lista,
      clientes: snapshots,
    );

    for (final analise in reparos) {
      await atualizarAnalise(analise);
      final clienteId = analise.clienteId?.trim() ?? '';
      if (clienteId.isEmpty) continue;
      try {
        await ref
            .read(clienteRepositoryProvider)
            .adicionarAnaliseId(clienteId, analise.id);
      } catch (_) {
        // Falha no índice denormalizado não deve bloquear o vínculo na análise.
      }
    }
  }

  /// Atualiza `cliente.analiseIds` após save com FKs já definidas.
  Future<void> registrarVinculosPosSalvar(List<AnaliseSolo> analises) async {
    for (final analise in analises) {
      final clienteId = analise.clienteId?.trim() ?? '';
      if (clienteId.isEmpty) continue;
      try {
        await ref
            .read(clienteRepositoryProvider)
            .adicionarAnaliseId(clienteId, analise.id);
      } catch (_) {
        // Índice denormalizado não bloqueia persistência da análise.
      }
    }
  }

  Future<void> deletar(String id) async {
    await ref.read(deleteAnaliseUsecaseProvider).call(id);
  }

  Future<void> atualizarAnalise(AnaliseSolo analiseAtualizada) async {
    final estadoAnterior = state.valueOrNull ?? const <AnaliseSolo>[];
    final index =
        estadoAnterior.indexWhere((a) => a.id == analiseAtualizada.id);
    if (index == -1) {
      await ref.read(saveAnaliseUsecaseProvider).call(analiseAtualizada);
      return;
    }

    final atualizadas = [...estadoAnterior];
    atualizadas[index] = analiseAtualizada;
    state = AsyncData(atualizadas);

    try {
      await ref.read(saveAnaliseUsecaseProvider).call(analiseAtualizada);
    } catch (e) {
      state = AsyncData(estadoAnterior);
      rethrow;
    }
  }

  Future<void> excluirAnalise(String analiseId) async {
    await ref.read(deleteAnaliseUsecaseProvider).call(analiseId);
  }

  Future<void> excluirPasta(List<String> analiseIds) async {
    for (final analiseId in analiseIds) {
      await ref.read(deleteAnaliseUsecaseProvider).call(analiseId);
    }
  }

  Future<void> moverAnalise({
    required String analiseId,
    required String destinoLaboratorio,
    required String destinoOs,
    String destinoGroupId = '',
    String destinoGroupTitle = '',
  }) async {
    final lista = state.valueOrNull ?? const <AnaliseSolo>[];
    final index = lista.indexWhere((a) => a.id == analiseId);
    if (index == -1) return;

    final original = lista[index];
    final metadataAtual =
        Map<String, dynamic>.from(original.laudoMetadata ?? {});
    if (destinoGroupId.isNotEmpty) {
      metadataAtual['groupId'] = destinoGroupId;
    } else {
      metadataAtual.remove('groupId');
    }
    if (destinoGroupTitle.isNotEmpty) {
      metadataAtual['groupTitle'] = destinoGroupTitle;
    } else {
      metadataAtual.remove('groupTitle');
    }
    if (destinoOs.isNotEmpty) {
      metadataAtual['os'] = destinoOs;
    } else {
      metadataAtual.remove('os');
      metadataAtual.remove('relatorio');
      metadataAtual.remove('laudoNumero');
      metadataAtual.remove('analise');
    }

    final analiseAtualizada = original.copyWith(
      laboratorio: destinoLaboratorio,
      laudoMetadata: metadataAtual.isEmpty ? null : metadataAtual,
    );

    final novaLista = List<AnaliseSolo>.from(lista);
    novaLista[index] = analiseAtualizada;
    state = AsyncData(novaLista);

    try {
      await ref.read(saveAnaliseUsecaseProvider).call(analiseAtualizada);
    } catch (e) {
      state = AsyncData(lista);
      rethrow;
    }
  }

  Future<void> renomearPasta({
    required List<String> analiseIds,
    required String novoNome,
  }) async {
    final estadoAnterior = state.valueOrNull ?? const <AnaliseSolo>[];
    final ids = analiseIds.toSet();
    if (ids.isEmpty) return;

    final atualizadas = estadoAnterior.map((analise) {
      if (!ids.contains(analise.id)) return analise;

      final metadataAtual =
          Map<String, dynamic>.from(analise.laudoMetadata ?? {});
      if (metadataAtual.containsKey('groupTitle')) {
        metadataAtual['groupTitle'] = novoNome;
      }

      return analise.copyWith(
        laboratorio: novoNome,
        laudoMetadata: metadataAtual.isEmpty ? null : metadataAtual,
      );
    }).toList(growable: false);

    state = AsyncData(atualizadas);

    try {
      for (final analise in atualizadas.where((a) => ids.contains(a.id))) {
        await ref.read(saveAnaliseUsecaseProvider).call(analise);
      }
    } catch (e) {
      state = AsyncData(estadoAnterior);
      rethrow;
    }
  }
}

@riverpod
List<AnaliseSolo> analisesFiltradas(
  AnalisesFiltradasRef ref, {
  Cultura? cultura,
  String? produtorId,
  String? safra,
  String? busca,
}) {
  final lista = ref.watch(analiseNotifierProvider).valueOrNull ?? [];
  return lista.where((a) {
    if (cultura != null && a.cultura != cultura) return false;
    if (produtorId != null && a.produtor != produtorId) return false;
    if (safra != null && a.safra != safra) return false;
    if (busca != null && busca.isNotEmpty) {
      final q = busca.toLowerCase();
      return a.talhao.toLowerCase().contains(q) ||
          a.laboratorio.toLowerCase().contains(q) ||
          a.produtor.toLowerCase().contains(q) ||
          a.fazenda.toLowerCase().contains(q);
    }
    return true;
  }).toList();
}

final analisesVisiveisProvider = Provider<List<AnaliseSolo>>((ref) {
  final analises = ref.watch(analiseNotifierProvider).valueOrNull ?? const [];
  final configurado =
      ref.watch(produtorConfiguradoProvider).valueOrNull?.trim() ?? '';
  if (configurado.isEmpty) return analises;
  return analises
      .where(
        (analise) => ProdutorResolucaoService.compativelComConfigurado(
          analise,
          configurado,
        ),
      )
      .toList(growable: false);
});

/// Análises vinculadas a um cliente (FK, índice `analiseIds` ou nome compatível).
final analisesPorClienteProvider =
    Provider.family<List<AnaliseSolo>, String>((ref, clienteId) {
  final analises =
      ref.watch(analiseNotifierProvider).valueOrNull ?? const [];
  final cliente = ref.watch(clienteProvider).clienteSelecionado;
  final normalizedId = clienteId.trim();
  final analiseIds = cliente?.id == normalizedId ? cliente!.analiseIds : const [];
  final clienteNome =
      cliente?.id == normalizedId ? cliente!.nome : '';

  return ClienteAnalisesFilter.filtrar(
    analises: analises,
    clienteId: normalizedId,
    analiseIds: Set<String>.from(analiseIds),
    clienteNome: clienteNome,
  );
});

/// Análises vinculadas a um talhão específico.
final analisesPorTalhaoProvider =
    Provider.family<List<AnaliseSolo>, String>((ref, talhaoId) {
  final normalizedId = talhaoId.trim();
  if (normalizedId.isEmpty) return const [];

  final analises = ref.watch(analiseNotifierProvider).valueOrNull ?? const [];
  return analises
      .where((analise) => analise.talhaoId == normalizedId)
      .toList(growable: false);
});

final produtoresAnaliseProvider = Provider<List<Produtor>>((ref) {
  final analises = ref.watch(analiseNotifierProvider).valueOrNull ?? const [];
  final produtores = <String, Produtor>{};

  for (final analise in analises) {
    if (analise.produtor.isEmpty) continue;

    final key = '${analise.produtor}_${analise.fazenda}';
    final existente = produtores[key];

    if (existente == null) {
      produtores[key] = Produtor(
        id: key,
        nome: analise.produtor,
        fazenda: analise.fazenda,
        totalAnalises: 1,
      );
      continue;
    }

    produtores[key] = Produtor(
      id: existente.id,
      nome: existente.nome,
      fazenda: existente.fazenda,
      totalAnalises: existente.totalAnalises + 1,
    );
  }

  final lista = produtores.values.toList()
    ..sort((a, b) => a.nome.compareTo(b.nome));
  return List.unmodifiable(lista);
});
