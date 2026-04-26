import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/config/data/datasources/tabela_metricas_hive_datasource.dart';
import 'package:soloforte/features/config/domain/entities/tabela_metricas.dart';
import 'package:soloforte/features/config/domain/entities/tabela_metricas_defaults.dart';

// ── Datasource ────────────────────────────────────────────────────────────────

final tabelaMetricasHiveDatasourceProvider =
    Provider<TabelaMetricasHiveDatasource>((ref) {
  return TabelaMetricasHiveDatasource();
});

// ── Notifier ──────────────────────────────────────────────────────────────────

class TabelaMetricasNotifier
    extends AsyncNotifier<List<TabelaMetricas>> {
  @override
  Future<List<TabelaMetricas>> build() async {
    return ref
        .read(tabelaMetricasHiveDatasourceProvider)
        .getTabelasOuSeed();
  }

  Future<void> salvar(TabelaMetricas tabela) async {
    await ref
        .read(tabelaMetricasHiveDatasourceProvider)
        .salvarTabela(tabela);
    ref.invalidateSelf();
  }

  Future<void> resetarParaDefaults() async {
    await ref
        .read(tabelaMetricasHiveDatasourceProvider)
        .resetarParaDefaults();
    ref.invalidateSelf();
  }
}

final tabelaMetricasProvider = AsyncNotifierProvider<
    TabelaMetricasNotifier, List<TabelaMetricas>>(
  TabelaMetricasNotifier.new,
);

// ── Seletor por chave (uso nos motores) ──────────────────────────────────────

/// Retorna uma [TabelaMetricas] pela [chave] canônica.
/// Fallback transparente para os defaults hardcoded quando o estado
/// ainda está carregando ou quando a chave não existe.
TabelaMetricas tabelaPorChave(
  List<TabelaMetricas> tabelas,
  String chave,
) {
  return tabelas.firstWhere(
    (t) => t.chave == chave,
    orElse: () => TabelaMetricasDefaults.build()
        .firstWhere((d) => d.chave == chave,
            orElse: () => _tabelaVazia(chave)),
  );
}

TabelaMetricas _tabelaVazia(String chave) => TabelaMetricas(
      id: '',
      chave: chave,
      nome: chave,
      descricao: '',
      unidade: '',
      linhas: const [],
      updatedAt: DateTime.now(),
    );

// ── Helpers para os motores ───────────────────────────────────────────────────

/// Calcula NC de Fósforo baseado na [referencia] e [faixaArgila].
/// Aceita a lista de tabelas injetadas via Provider.
double ncFosforoPorReferencia({
  required String referencia,
  required double argilaPercent,
  required List<TabelaMetricas> tabelas,
  double fallback = 8.0,
}) {
  String chave;
  switch (referencia) {
    case 'IAC Bol.100':
      chave = TabelaMetricasDefaults.kFosforoNcResina;
      break;
    case 'Embrapa Cerrado':
      chave = TabelaMetricasDefaults.kFosforoNcCerrado;
      break;
    case 'Embrapa RS/SC':
      chave = TabelaMetricasDefaults.kFosforoNcRsSc;
      break;
    case 'UFLA / CFSEMG':
      chave = TabelaMetricasDefaults.kFosforoNcUfla;
      break;
    default:
      return fallback;
  }
  return tabelaPorChave(tabelas, chave)
      .valorParaArgila(argilaPercent, fallback: fallback);
}

/// Nível Crítico de Fósforo — Resina (IAC).
double ncFosforoResina({
  required double argilaPercent,
  required List<TabelaMetricas> tabelas,
}) {
  return tabelaPorChave(tabelas, TabelaMetricasDefaults.kFosforoNcResina)
      .valorParaArgila(argilaPercent, fallback: 30.0);
}

/// FEP base para o solo.
double fepBaseTabela({
  required double argilaPercent,
  required List<TabelaMetricas> tabelas,
}) {
  return tabelaPorChave(tabelas, TabelaMetricasDefaults.kFosforoFep)
      .valorParaArgila(argilaPercent, fallback: 15.0);
}

/// Fator Solo para Fósforo.
double fatorSoloTabela({
  required double argilaPercent,
  required List<TabelaMetricas> tabelas,
}) {
  return tabelaPorChave(tabelas, TabelaMetricasDefaults.kFosforoFatorSolo)
      .valorParaArgila(argilaPercent, fallback: 4.0);
}

/// NC Potássio — Teor Absoluto.
double ncPotassioTeorTabela({
  required double argilaPercent,
  required List<TabelaMetricas> tabelas,
}) {
  return tabelaPorChave(tabelas, TabelaMetricasDefaults.kPotassioNcTeor)
      .valorParaArgila(argilaPercent, fallback: 80.0);
}

/// FEK base para o solo.
double fekBaseTabela({
  required double argilaPercent,
  required List<TabelaMetricas> tabelas,
}) {
  return tabelaPorChave(tabelas, TabelaMetricasDefaults.kPotassioFek)
      .valorParaArgila(argilaPercent, fallback: 65.0);
}

/// Limites de antagonismo do Potássio (K% CTC, K:Mg, K:Ca).
({double limiteKCtc, double limiteKMg, double limiteKCa})
    antagonismosTabela(List<TabelaMetricas> tabelas) {
  final tab =
      tabelaPorChave(tabelas, TabelaMetricasDefaults.kPotassioAntagonismos);

  double buscarChaveValor(String chaveValor, double fallback) {
    for (final linha in tab.linhas) {
      if (linha['chaveValor'] == chaveValor) {
        final v = linha['valor'];
        if (v is num) return v.toDouble();
      }
    }
    return fallback;
  }

  return (
    limiteKCtc: buscarChaveValor('limite_k_ctc', 7.0),
    limiteKMg: buscarChaveValor('limite_k_mg', 1.0),
    limiteKCa: buscarChaveValor('limite_k_ca', 0.4),
  );
}

/// Metas Albrecht dinâmicas.
({double pctCa, double pctMg, double pctK}) metasAlbrechtTabela(
    List<TabelaMetricas> tabelas) {
  final tab =
      tabelaPorChave(tabelas, TabelaMetricasDefaults.kCalagemMetasAlbrecht);

  double buscar(String chave, double fallback) {
    for (final linha in tab.linhas) {
      if (linha['chaveValor'] == chave) {
        final v = linha['valor'];
        if (v is num) return v.toDouble();
      }
    }
    return fallback;
  }

  return (
    pctCa: buscar('pct_ca', 65.0),
    pctMg: buscar('pct_mg', 15.0),
    pctK: buscar('pct_k', 4.0),
  );
}

/// Valor SMP da tabela baseada no pH atual.
double ncSmpTabela({
  required double phSmp,
  required List<TabelaMetricas> tabelas,
}) {
  final tab = tabelaPorChave(tabelas, TabelaMetricasDefaults.kCalagemSmp);
  for (final linha in tab.linhas) {
    final min = (linha['phMin'] as num?)?.toDouble() ?? 0.0;
    final max = (linha['phMax'] as num?)?.toDouble() ?? 9.9;
    if (phSmp >= min && phSmp < max) {
      final v = linha['valor'];
      if (v is num) return v.toDouble();
    }
  }
  return 0.0;
}

