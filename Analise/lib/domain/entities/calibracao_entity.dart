import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// ─── Estado do controller ─────────────────────────────────────────────────────

enum CalibracaoStatus { idle, saving, saved, error }

class CalibracaoState {
  final CalibracaoEntity calibracao;
  final CalibracaoStatus status;
  final String? errorMessage;
  final List<CalibracaoEntity> perfisExistentes;

  const CalibracaoState({
    required this.calibracao,
    this.status = CalibracaoStatus.idle,
    this.errorMessage,
    this.perfisExistentes = const [],
  });

  CalibracaoState copyWith({
    CalibracaoEntity? calibracao,
    CalibracaoStatus? status,
    String? errorMessage,
    List<CalibracaoEntity>? perfisExistentes,
  }) {
    return CalibracaoState(
      calibracao: calibracao ?? this.calibracao,
      status: status ?? this.status,
      errorMessage: errorMessage,
      perfisExistentes: perfisExistentes ?? this.perfisExistentes,
    );
  }
}

const _defaultCalibracao = CalibracaoEntity(
  nomePerfil: '',
  metodoCalagemSelecionado: 'Saturação de Bases (V%)',
  referenciaCalagemSelecionada: '01 — Calagem: Motor de Cálculo',
  estadoSelecionado: 'SP',
  tipoSoloSelecionado: 'Latossolo Vermelho',
  metodoGessagemSelecionado: 'Critério ESALQ (Vitti et al., 2004)',
  referenciaGessagemSelecionada: 'ESALQ/USP',
  metodoPosforoSelecionado: 'Resina (IAC)',
  referenciaPosforoSelecionada: 'IAC/SP — Boletim 100',
  metodoKaliumSelecionado: 'Saturação de K na CTC (K/CTC %)',
  referenciaKaliumSelecionada: 'ESALQ/USP — Fancelli',
  metodoMicroSelecionado: 'DTPA-TEA (Zn, Cu, Fe, Mn)',
  referenciaMicroSelecionada: 'ESALQ/USP',
);

class CalibracaoController extends StateNotifier<CalibracaoState> {
  CalibracaoController()
      : super(const CalibracaoState(calibracao: _defaultCalibracao));

  void atualizarNomePerfil(String nome) {
    state = state.copyWith(
      calibracao: state.calibracao.copyWith(nomePerfil: nome),
      status: CalibracaoStatus.idle,
    );
  }

  void atualizarCalagem({String? metodo, String? referencia}) {
    state = state.copyWith(
      calibracao: state.calibracao.copyWith(
        metodoCalagemSelecionado: metodo,
        referenciaCalagemSelecionada: referencia,
      ),
      status: CalibracaoStatus.idle,
    );
  }

  void atualizarParametrosRegionais({String? estado, String? tipoSolo}) {
    state = state.copyWith(
      calibracao: state.calibracao.copyWith(
        estadoSelecionado: estado,
        tipoSoloSelecionado: tipoSolo,
      ),
      status: CalibracaoStatus.idle,
    );
  }

  void atualizarGessagem({String? metodo, String? referencia}) {
    state = state.copyWith(
      calibracao: state.calibracao.copyWith(
        metodoGessagemSelecionado: metodo,
        referenciaGessagemSelecionada: referencia,
      ),
      status: CalibracaoStatus.idle,
    );
  }

  void atualizarPosforo({String? metodo, String? referencia}) {
    state = state.copyWith(
      calibracao: state.calibracao.copyWith(
        metodoPosforoSelecionado: metodo,
        referenciaPosforoSelecionada: referencia,
      ),
      status: CalibracaoStatus.idle,
    );
  }

  void atualizarKalium({String? metodo, String? referencia}) {
    state = state.copyWith(
      calibracao: state.calibracao.copyWith(
        metodoKaliumSelecionado: metodo,
        referenciaKaliumSelecionada: referencia,
      ),
      status: CalibracaoStatus.idle,
    );
  }

  void atualizarMicro({String? metodo, String? referencia}) {
    state = state.copyWith(
      calibracao: state.calibracao.copyWith(
        metodoMicroSelecionado: metodo,
        referenciaMicroSelecionada: referencia,
      ),
      status: CalibracaoStatus.idle,
    );
  }

  void carregarPerfil(CalibracaoEntity perfil) {
    state = state.copyWith(calibracao: perfil, status: CalibracaoStatus.idle);
  }

  Future<void> salvarPerfil() async {
    if (state.calibracao.nomePerfil.trim().isEmpty) {
      state = state.copyWith(
        status: CalibracaoStatus.error,
        errorMessage: 'Informe um nome para o perfil antes de salvar.',
      );
      return;
    }
    state = state.copyWith(status: CalibracaoStatus.saving);
    await Future.delayed(const Duration(milliseconds: 600)); // simula I/O
    final novo = state.calibracao.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      criadoEm: DateTime.now(),
    );
    final atualizados = [...state.perfisExistentes, novo];
    state = state.copyWith(
      calibracao: novo,
      status: CalibracaoStatus.saved,
      perfisExistentes: atualizados,
    );
  }
}

final calibracaoControllerProvider =
    StateNotifierProvider<CalibracaoController, CalibracaoState>(
  (_) => CalibracaoController(),
);
