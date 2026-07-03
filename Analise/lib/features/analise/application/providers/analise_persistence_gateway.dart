import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';
import 'package:soloforte/features/analise/domain/persistence/save_batch.dart';
import 'package:soloforte/features/analise/presentation/providers/analise_provider.dart';

abstract class AnalisePersistenceGateway {
  Future<SaveBatchResult> salvarLote(List<AnaliseSolo> analises);
  Future<void> recarregar();
}

class RiverpodAnalisePersistenceGateway implements AnalisePersistenceGateway {
  RiverpodAnalisePersistenceGateway(this.ref);

  final Ref ref;

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
