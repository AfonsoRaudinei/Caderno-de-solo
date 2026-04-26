// CalibracaoEntity — domínio puro (sem Riverpod, sem estado de UI)
//
// O estado do controller (CalibracaoState) e o provider usam Freezed
// e estão em:
//   lib/features/laboratorio/presentation/calibracao/calibracao_state.dart
//   lib/features/laboratorio/presentation/calibracao/calibracao_controller.dart

class CalibracaoEntity {
  final String? id;
  final String nomePerfil; // ex: "Soja SP - ESALQ 2024"
  final DateTime? criadoEm;

  // Calagem
  final String metodoCalagemSelecionado;
  final String referenciaCalagemSelecionada;
  final String estadoSelecionado;
  final String tipoSoloSelecionado;

  // Gessagem
  final String metodoGessagemSelecionado;
  final String referenciaGessagemSelecionada;

  // Fósforo
  final String metodoPosforoSelecionado;
  final String referenciaPosforoSelecionada;

  // Potássio
  final String metodoKaliumSelecionado;
  final String referenciaKaliumSelecionada;

  // Micronutrientes
  final String metodoMicroSelecionado;
  final String referenciaMicroSelecionada;

  const CalibracaoEntity({
    this.id,
    required this.nomePerfil,
    this.criadoEm,
    required this.metodoCalagemSelecionado,
    required this.referenciaCalagemSelecionada,
    required this.estadoSelecionado,
    required this.tipoSoloSelecionado,
    required this.metodoGessagemSelecionado,
    required this.referenciaGessagemSelecionada,
    required this.metodoPosforoSelecionado,
    required this.referenciaPosforoSelecionada,
    required this.metodoKaliumSelecionado,
    required this.referenciaKaliumSelecionada,
    required this.metodoMicroSelecionado,
    required this.referenciaMicroSelecionada,
  });

  CalibracaoEntity copyWith({
    String? id,
    String? nomePerfil,
    DateTime? criadoEm,
    String? metodoCalagemSelecionado,
    String? referenciaCalagemSelecionada,
    String? estadoSelecionado,
    String? tipoSoloSelecionado,
    String? metodoGessagemSelecionado,
    String? referenciaGessagemSelecionada,
    String? metodoPosforoSelecionado,
    String? referenciaPosforoSelecionada,
    String? metodoKaliumSelecionado,
    String? referenciaKaliumSelecionada,
    String? metodoMicroSelecionado,
    String? referenciaMicroSelecionada,
  }) {
    return CalibracaoEntity(
      id: id ?? this.id,
      nomePerfil: nomePerfil ?? this.nomePerfil,
      criadoEm: criadoEm ?? this.criadoEm,
      metodoCalagemSelecionado:
          metodoCalagemSelecionado ?? this.metodoCalagemSelecionado,
      referenciaCalagemSelecionada:
          referenciaCalagemSelecionada ?? this.referenciaCalagemSelecionada,
      estadoSelecionado: estadoSelecionado ?? this.estadoSelecionado,
      tipoSoloSelecionado: tipoSoloSelecionado ?? this.tipoSoloSelecionado,
      metodoGessagemSelecionado:
          metodoGessagemSelecionado ?? this.metodoGessagemSelecionado,
      referenciaGessagemSelecionada:
          referenciaGessagemSelecionada ?? this.referenciaGessagemSelecionada,
      metodoPosforoSelecionado:
          metodoPosforoSelecionado ?? this.metodoPosforoSelecionado,
      referenciaPosforoSelecionada:
          referenciaPosforoSelecionada ?? this.referenciaPosforoSelecionada,
      metodoKaliumSelecionado:
          metodoKaliumSelecionado ?? this.metodoKaliumSelecionado,
      referenciaKaliumSelecionada:
          referenciaKaliumSelecionada ?? this.referenciaKaliumSelecionada,
      metodoMicroSelecionado:
          metodoMicroSelecionado ?? this.metodoMicroSelecionado,
      referenciaMicroSelecionada:
          referenciaMicroSelecionada ?? this.referenciaMicroSelecionada,
    );
  }
}
