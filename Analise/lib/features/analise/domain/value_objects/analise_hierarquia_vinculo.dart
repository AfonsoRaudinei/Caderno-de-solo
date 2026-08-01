import 'package:soloforte/features/analise/domain/entities/analise_solo.dart';

/// Referência estruturada Cliente → Fazenda → Talhão para uma análise.
class AnaliseHierarquiaVinculo {
  const AnaliseHierarquiaVinculo({
    required this.clienteId,
    required this.fazendaId,
    required this.talhaoId,
    required this.status,
    this.clienteNome,
    this.fazendaNome,
    this.talhaoNome,
  });

  final String clienteId;
  final String fazendaId;
  final String talhaoId;
  final AnaliseVinculoStatus status;
  final String? clienteNome;
  final String? fazendaNome;
  final String? talhaoNome;

  bool get isCompleto =>
      clienteId.trim().isNotEmpty &&
      fazendaId.trim().isNotEmpty &&
      talhaoId.trim().isNotEmpty;
}
