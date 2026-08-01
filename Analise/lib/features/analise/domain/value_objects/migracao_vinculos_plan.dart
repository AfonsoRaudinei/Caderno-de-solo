import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

/// Plano de migração calculado antes da persistência.
class MigracaoVinculosPlan {
  const MigracaoVinculosPlan({
    this.reparos = const [],
    this.pendentes = const [],
    this.jaVinculadas = 0,
  });

  final List<AnaliseSolo> reparos;
  final List<AnaliseSolo> pendentes;
  final int jaVinculadas;

  int get totalAlteracoes => reparos.length + pendentes.length;

  bool get isEmpty => totalAlteracoes == 0;
}
