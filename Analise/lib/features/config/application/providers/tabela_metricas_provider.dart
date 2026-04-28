import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloforte/features/config/data/datasources/tabela_metricas_hive_datasource.dart';
import 'package:soloforte/features/config/data/repositories/tabela_metricas_repository_impl.dart';
import 'package:soloforte/features/config/domain/entities/tabela_metricas.dart';
import 'package:soloforte/features/config/domain/entities/tabela_metricas_defaults.dart';
import 'package:soloforte/features/config/domain/repositories/tabela_metricas_repository.dart';
import 'package:soloforte/features/config/domain/usecases/tabela_metricas_usecases.dart';

final tabelaMetricasHiveDatasourceProvider =
    Provider<TabelaMetricasHiveDatasource>((ref) {
  return TabelaMetricasHiveDatasource();
});

final tabelaMetricasRepositoryProvider =
    Provider<TabelaMetricasRepository>((ref) {
  return TabelaMetricasRepositoryImpl(
    ref.watch(tabelaMetricasHiveDatasourceProvider),
  );
});

final getTabelasMetricasUsecaseProvider =
    Provider<GetTabelasMetricasUsecase>((ref) {
  return GetTabelasMetricasUsecase(ref.watch(tabelaMetricasRepositoryProvider));
});

final salvarTabelaMetricasUsecaseProvider =
    Provider<SalvarTabelaMetricasUsecase>((ref) {
  return SalvarTabelaMetricasUsecase(
    ref.watch(tabelaMetricasRepositoryProvider),
  );
});

final resetarTabelaMetricasUsecaseProvider =
    Provider<ResetarTabelaMetricasUsecase>((ref) {
  return ResetarTabelaMetricasUsecase(
    ref.watch(tabelaMetricasRepositoryProvider),
  );
});

class TabelaMetricasNotifier extends AsyncNotifier<List<TabelaMetricas>> {
  @override
  Future<List<TabelaMetricas>> build() async {
    return ref.read(getTabelasMetricasUsecaseProvider).call();
  }

  Future<void> salvar(TabelaMetricas tabela) async {
    await ref.read(salvarTabelaMetricasUsecaseProvider).call(tabela);
    ref.invalidateSelf();
  }

  Future<void> resetarParaDefaults() async {
    await ref.read(resetarTabelaMetricasUsecaseProvider).call();
    ref.invalidateSelf();
  }
}

final tabelaMetricasProvider =
    AsyncNotifierProvider<TabelaMetricasNotifier, List<TabelaMetricas>>(
  TabelaMetricasNotifier.new,
);

TabelaMetricas tabelaPorChave(
  List<TabelaMetricas> tabelas,
  String chave,
) {
  return tabelas.firstWhere(
    (t) => t.chave == chave,
    orElse: () => TabelaMetricasDefaults.build()
        .firstWhere((d) => d.chave == chave, orElse: () => _tabelaVazia(chave)),
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

double ncFosforoResina({
  required double argilaPercent,
  required List<TabelaMetricas> tabelas,
}) {
  return tabelaPorChave(tabelas, TabelaMetricasDefaults.kFosforoNcResina)
      .valorParaArgila(argilaPercent, fallback: 30.0);
}

double fepBaseTabela({
  required double argilaPercent,
  required List<TabelaMetricas> tabelas,
}) {
  return tabelaPorChave(tabelas, TabelaMetricasDefaults.kFosforoFep)
      .valorParaArgila(argilaPercent, fallback: 15.0);
}

double fatorSoloTabela({
  required double argilaPercent,
  required List<TabelaMetricas> tabelas,
}) {
  return tabelaPorChave(tabelas, TabelaMetricasDefaults.kFosforoFatorSolo)
      .valorParaArgila(argilaPercent, fallback: 4.0);
}

double ncPotassioTeorTabela({
  required double argilaPercent,
  required List<TabelaMetricas> tabelas,
}) {
  return tabelaPorChave(tabelas, TabelaMetricasDefaults.kPotassioNcTeor)
      .valorParaArgila(argilaPercent, fallback: 80.0);
}

double fekBaseTabela({
  required double argilaPercent,
  required List<TabelaMetricas> tabelas,
}) {
  return tabelaPorChave(tabelas, TabelaMetricasDefaults.kPotassioFek)
      .valorParaArgila(argilaPercent, fallback: 65.0);
}

({double limiteKCtc, double limiteKMg, double limiteKCa}) antagonismosTabela(
    List<TabelaMetricas> tabelas) {
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
    limiteKCtc: buscarChaveValor('limite_k_ctc_pct', 6.0),
    limiteKMg: buscarChaveValor('limite_k_mg', 0.5),
    limiteKCa: buscarChaveValor('limite_k_ca', 0.3),
  );
}

({double caPct, double mgPct, double kPct}) metasAlbrechtTabela(
  List<TabelaMetricas> tabelas,
) {
  final tab =
      tabelaPorChave(tabelas, TabelaMetricasDefaults.kCalagemMetasAlbrecht);

  double buscar(String chaveValor, double fallback) {
    for (final linha in tab.linhas) {
      if (linha['chaveValor'] == chaveValor) {
        final v = linha['valor'];
        if (v is num) return v.toDouble();
      }
    }
    return fallback;
  }

  return (
    caPct: buscar('ca_pct_ctc', 65.0),
    mgPct: buscar('mg_pct_ctc', 15.0),
    kPct: buscar('k_pct_ctc', 4.0),
  );
}

double? ncSmpTabela({
  required double phSmp,
  required double vDesejado,
  required List<TabelaMetricas> tabelas,
}) {
  final tab = tabelaPorChave(tabelas, TabelaMetricasDefaults.kCalagemSmp);
  for (final linha in tab.linhas) {
    final min = (linha['phMin'] as num?)?.toDouble() ?? 0.0;
    final max = (linha['phMax'] as num?)?.toDouble() ?? 14.0;
    if (phSmp < min || phSmp > max) continue;
    final key = vDesejado >= 70
        ? 'doseV70'
        : vDesejado >= 65
            ? 'doseV65'
            : 'doseV60';
    final value = linha[key];
    if (value is num) return value.toDouble();
  }
  return null;
}
