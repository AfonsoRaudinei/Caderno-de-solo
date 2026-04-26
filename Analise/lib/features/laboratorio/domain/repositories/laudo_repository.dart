import 'package:soloforte/features/laboratorio/domain/entities/laudo_recomendacao.dart';

/// Contrato de acesso a dados — CRUD de Laudos de Recomendação.
abstract class LaudoRepository {
  /// Retorna todos os laudos do usuário autenticado, ordenados decrescente.
  Future<List<LaudoRecomendacao>> getLaudos();

  /// Persiste um laudo (upsert por [LaudoRecomendacao.id]).
  Future<void> saveLaudo(LaudoRecomendacao laudo);

  /// Remove permanentemente um laudo pelo id.
  Future<void> deleteLaudo(String id);
}
