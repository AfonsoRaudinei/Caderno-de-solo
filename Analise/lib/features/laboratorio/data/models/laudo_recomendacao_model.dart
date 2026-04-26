import 'package:soloforte/features/laboratorio/domain/entities/laudo_recomendacao.dart';

/// Serialização / Desserialização de [LaudoRecomendacao] para JSON.
/// Usado tanto pelo Hive (local) quanto pelo Firestore (nuvem).
class LaudoRecomendacaoModel extends LaudoRecomendacao {
  const LaudoRecomendacaoModel({
    required super.id,
    required super.userId,
    required super.analiseId,
    required super.calibracaoId,
    required super.geradaEm,
    required super.talhao,
    required super.fazenda,
    required super.cliente,
    required super.cultura,
    required super.safra,
    required super.laboratorio,
    required super.nomeCalibra,
    required super.metodoCalagem,
    required super.doseCalcarioTHa,
    required super.vAtual,
    required super.vEsperado,
    required super.caAtual,
    required super.caEsperado,
    required super.mgAtual,
    required super.mgEsperado,
    required super.relacaoCaMg,
    required super.parcelamento,
    required super.gessoIndicado,
    required super.gessoKgHa,
    required super.modoFosforo,
    required super.pSoloMgDm3,
    required super.ncFosforo,
    required super.doseP2O5KgHa,
    required super.legacyP,
    required super.criterioPotassio,
    required super.kSolo,
    required super.ncPotassio,
    required super.doseK2OKgHa,
    required super.micros,
    required super.avisos,
    required super.argumentos,
    super.status,
  });

  // ── fromJson ─────────────────────────────────────────────────────────────

  factory LaudoRecomendacaoModel.fromJson(Map<String, dynamic> json) {
    double d(String key, [double fallback = 0]) {
      final v = json[key];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? fallback;
      return fallback;
    }

    List<String> stringList(String key) {
      final v = json[key];
      if (v is List) return v.map((e) => e.toString()).toList();
      return const [];
    }

    List<Map<String, dynamic>> mapList(String key) {
      final v = json[key];
      if (v is List) {
        return v
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return const [];
    }

    return LaudoRecomendacaoModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      analiseId: (json['analiseId'] ?? '').toString(),
      calibracaoId: (json['calibracaoId'] ?? '').toString(),
      geradaEm: _parseDate(json['geradaEm']),
      talhao: (json['talhao'] ?? '').toString(),
      fazenda: (json['fazenda'] ?? '').toString(),
      cliente: (json['cliente'] ?? '').toString(),
      cultura: (json['cultura'] ?? '').toString(),
      safra: (json['safra'] ?? '').toString(),
      laboratorio: (json['laboratorio'] ?? '').toString(),
      nomeCalibra: (json['nomeCalibra'] ?? '').toString(),
      metodoCalagem: (json['metodoCalagem'] ?? '').toString(),
      doseCalcarioTHa: d('doseCalcarioTHa'),
      vAtual: d('vAtual'),
      vEsperado: d('vEsperado'),
      caAtual: d('caAtual'),
      caEsperado: d('caEsperado'),
      mgAtual: d('mgAtual'),
      mgEsperado: d('mgEsperado'),
      relacaoCaMg: d('relacaoCaMg'),
      parcelamento: stringList('parcelamento'),
      gessoIndicado: (json['gessoIndicado'] as bool?) ?? false,
      gessoKgHa: d('gessoKgHa'),
      modoFosforo: (json['modoFosforo'] ?? '').toString(),
      pSoloMgDm3: d('pSoloMgDm3'),
      ncFosforo: d('ncFosforo'),
      doseP2O5KgHa: d('doseP2O5KgHa'),
      legacyP: (json['legacyP'] as bool?) ?? false,
      criterioPotassio: (json['criterioPotassio'] ?? '').toString(),
      kSolo: d('kSolo'),
      ncPotassio: d('ncPotassio'),
      doseK2OKgHa: d('doseK2OKgHa'),
      micros: mapList('micros'),
      avisos: stringList('avisos'),
      argumentos: (json['argumentos'] ?? '').toString(),
      status: LaudoStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => LaudoStatus.completo,
      ),
    );
  }

  // ── toJson ───────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'analiseId': analiseId,
      'calibracaoId': calibracaoId,
      'geradaEm': geradaEm.toIso8601String(),
      'talhao': talhao,
      'fazenda': fazenda,
      'cliente': cliente,
      'cultura': cultura,
      'safra': safra,
      'laboratorio': laboratorio,
      'nomeCalibra': nomeCalibra,
      'metodoCalagem': metodoCalagem,
      'doseCalcarioTHa': doseCalcarioTHa,
      'vAtual': vAtual,
      'vEsperado': vEsperado,
      'caAtual': caAtual,
      'caEsperado': caEsperado,
      'mgAtual': mgAtual,
      'mgEsperado': mgEsperado,
      'relacaoCaMg': relacaoCaMg,
      'parcelamento': parcelamento,
      'gessoIndicado': gessoIndicado,
      'gessoKgHa': gessoKgHa,
      'modoFosforo': modoFosforo,
      'pSoloMgDm3': pSoloMgDm3,
      'ncFosforo': ncFosforo,
      'doseP2O5KgHa': doseP2O5KgHa,
      'legacyP': legacyP,
      'criterioPotassio': criterioPotassio,
      'kSolo': kSolo,
      'ncPotassio': ncPotassio,
      'doseK2OKgHa': doseK2OKgHa,
      'micros': micros,
      'avisos': avisos,
      'argumentos': argumentos,
      'status': status.name,
    };
  }

  // ── helper ───────────────────────────────────────────────────────────────

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
