import 'package:soloforte/domain/models/calibracao_profile.dart';

abstract class CalibracaoRepository {
  Future<List<CalibracaoProfile>> carregarPerfis();

  Future<void> salvarPerfis({
    required List<CalibracaoProfile> perfis,
    required CalibracaoProfile perfilSincronizar,
  });

  Future<void> excluirPerfil({
    required List<CalibracaoProfile> perfisRestantes,
    required String perfilId,
  });
}
