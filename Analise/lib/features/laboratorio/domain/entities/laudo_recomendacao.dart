/// Entidade de domínio — representa a "fotografia" imutável de uma
/// recomendação agronômica no momento exato em que foi gerada.
///
/// Contém todos os resultados calculados (doses, métodos, avisos),
/// os snaphots de identificação (talhão, cultura, calibração) e
/// os argumentos técnicos com referências bibliográficas.
class LaudoRecomendacao {
  const LaudoRecomendacao({
    required this.id,
    required this.userId,
    required this.analiseId,
    required this.calibracaoId,
    required this.geradaEm,
    // ── Identificação ──────────────────────────────────────
    required this.talhao,
    required this.fazenda,
    required this.cliente,
    required this.cultura,
    required this.safra,
    required this.laboratorio,
    required this.nomeCalibra,
    // ── Calcário ───────────────────────────────────────────
    required this.metodoCalagem,
    required this.doseCalcarioTHa,
    required this.vAtual,
    required this.vEsperado,
    required this.caAtual,
    required this.caEsperado,
    required this.mgAtual,
    required this.mgEsperado,
    required this.relacaoCaMg,
    required this.parcelamento,
    // ── Gesso ──────────────────────────────────────────────
    required this.gessoIndicado,
    required this.gessoKgHa,
    // ── Fósforo ────────────────────────────────────────────
    required this.modoFosforo,
    required this.pSoloMgDm3,
    required this.ncFosforo,
    required this.doseP2O5KgHa,
    required this.legacyP,
    // ── Potássio ───────────────────────────────────────────
    required this.criterioPotassio,
    required this.kSolo,
    required this.ncPotassio,
    required this.doseK2OKgHa,
    // ── Micronutrientes ────────────────────────────────────
    required this.micros,
    // ── Qualidade ──────────────────────────────────────────
    required this.avisos,
    required this.argumentos,
    // ── Status ─────────────────────────────────────────────
    this.status = LaudoStatus.completo,
  });

  final String id;
  final String userId;
  final String analiseId;
  final String calibracaoId;
  final DateTime geradaEm;

  // Identificação (snapshot no momento da geração)
  final String talhao;
  final String fazenda;
  final String cliente;
  final String cultura;
  final String safra;
  final String laboratorio;
  final String nomeCalibra;

  // Calcário
  final String metodoCalagem;
  final double doseCalcarioTHa;
  final double vAtual;
  final double vEsperado;
  final double caAtual;
  final double caEsperado;
  final double mgAtual;
  final double mgEsperado;
  final double relacaoCaMg;
  final List<String> parcelamento;

  // Gesso
  final bool gessoIndicado;
  final double gessoKgHa;

  // Fósforo
  final String modoFosforo;
  final double pSoloMgDm3;
  final double ncFosforo;
  final double doseP2O5KgHa;
  final bool legacyP;

  // Potássio
  final String criterioPotassio;
  final double kSolo;
  final double ncPotassio;
  final double doseK2OKgHa;

  // Micronutrientes — lista de mapas simples {simbolo, dose, via, fonte}
  final List<Map<String, dynamic>> micros;

  // Qualidade
  final List<String> avisos;
  final String argumentos;

  // Status do laudo
  final LaudoStatus status;
}

enum LaudoStatus { completo, rascunho }
