import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/analise/data/datasources/produtor_configurado_local_datasource.dart';

final produtorConfiguradoDatasourceProvider =
    Provider<ProdutorConfiguradoLocalDatasource>(
  (ref) => ProdutorConfiguradoLocalDatasource(),
);

final produtorConfiguradoProvider =
    AsyncNotifierProvider<ProdutorConfiguradoNotifier, String?>(
  ProdutorConfiguradoNotifier.new,
);

class ProdutorConfiguradoNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    return ref
        .read(produtorConfiguradoDatasourceProvider)
        .getProdutorConfigurado();
  }

  Future<void> salvar(String produtor) async {
    final trimmed = produtor.trim();
    if (trimmed.isEmpty) return;
    await ref
        .read(produtorConfiguradoDatasourceProvider)
        .setProdutorConfigurado(trimmed);
    state = AsyncData(trimmed);
  }
}
