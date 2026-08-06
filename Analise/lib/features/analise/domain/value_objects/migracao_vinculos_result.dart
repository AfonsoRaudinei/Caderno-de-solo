/// Resultado da execução da migração em massa de vínculos.
class MigracaoVinculosResult {
  const MigracaoVinculosResult({
    required this.totalAnalises,
    required this.jaVinculadas,
    required this.reparadas,
    required this.marcadasPendentes,
    required this.falhas,
    required this.executada,
  });

  final int totalAnalises;
  final int jaVinculadas;
  final int reparadas;
  final int marcadasPendentes;
  final int falhas;
  final bool executada;

  bool get teveAlteracao => reparadas > 0 || marcadasPendentes > 0;

  factory MigracaoVinculosResult.naoExecutada({required int totalAnalises}) {
    return MigracaoVinculosResult(
      totalAnalises: totalAnalises,
      jaVinculadas: 0,
      reparadas: 0,
      marcadasPendentes: 0,
      falhas: 0,
      executada: false,
    );
  }
}
