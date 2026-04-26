import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'analise_model.freezed.dart';
part 'analise_model.g.dart';

enum FonteP {
  resina,
  mehlich,
}

@freezed
class FosforoData with _$FosforoData {
  const FosforoData._();

  const factory FosforoData({
    double? pResina,
    double? pMehlich,
    double? pRemanescente,
    @Default(FonteP.resina) FonteP fontePrincipal,
  }) = _FosforoData;

  /// Valor de P utilizado no cálculo de recomendação, respeitando a fonte
  /// principal e aplicando fallback automático para a outra fonte.
  double get valorParaCalculo {
    if (fontePrincipal == FonteP.resina) {
      return pResina ?? pMehlich ?? 0.0;
    }
    return pMehlich ?? pResina ?? 0.0;
  }

  factory FosforoData.fromJson(Map<String, dynamic> json) => FosforoData(
        pResina: (json['pResina'] ?? json['p_resina'] ?? json['resina'] as num?)
            ?.toDouble(),
        pMehlich:
            (json['pMehlich'] ?? json['p_mehlich'] ?? json['fosforo'] as num?)
                ?.toDouble(),
        pRemanescente:
            (json['pRemanescente'] ?? json['pRem'] ?? json['p_rem'] as num?)
                ?.toDouble(),
        fontePrincipal: json['fontePrincipal'] == 'resina' ||
                json['fontePrincipal'] == FonteP.resina.name
            ? FonteP.resina
            : FonteP.mehlich,
      );

  @override
  Map<String, dynamic> toJson() => {
        'pResina': pResina,
        'pMehlich': pMehlich,
        'pRemanescente': pRemanescente,
        'fontePrincipal': fontePrincipal.name,
      };
}

@freezed
class AnaliseModel with _$AnaliseModel {
  const AnaliseModel._();

  const factory AnaliseModel({
    required String id,
    required String userId,
    String? fazenda,
    String? produtor,
    String? talhao,
    @Default('') String numeroAmostra,
    @Default('') String laboratorio,
    @Default('') String profundidade,
    @Default('') String dataColeta,
    @Default('') String status,
    @Default('') String cultura,
    @Default('') String safra,
    double? latitude,
    double? longitude,
    String? descricaoLocal,
    String? pdfUrl,
    double? argila,
    double? silte,
    double? areiaTotal,
    double? phAgua,
    double? phSmp,
    double? phCaCl2,
    double? materiaOrganica,
    double? carbonoOrganico,
    double? pMehlich,
    double? pResina,
    double? pRem,
    double? s020,
    double? s2040,
    double? k,
    double? ca,
    double? mg,
    double? al,
    double? hMaisAl,
    double? na,
    double? b,
    double? cu,
    double? fe,
    double? mn,
    double? zn,
    double? ni,
    double? mo,
    double? se,
    @Default(FonteP.mehlich) FonteP fontePrincipalP,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _AnaliseModel;

  factory AnaliseModel.fromJson(Map<String, dynamic> json) =>
      AnaliseModel(
        id: (json['id'] ?? '') as String,
        userId: (json['userId'] ?? json['user_id'] ?? '') as String,
        fazenda: (json['fazenda'] ??
                json['fazenda_nome'] ??
                json['fazendaNome'] ??
                json['propriedade'] ??
                '') as String,
        produtor: (json['produtor'] ?? '') as String,
        talhao: (json['talhao'] ??
                json['talhao_nome'] ??
                json['talhaoNome'] ??
                '') as String,
        numeroAmostra:
            (json['numeroAmostra'] ?? json['numero_amostra'] ?? '') as String,
        laboratorio: (json['laboratorio'] ?? '') as String,
        profundidade: (json['profundidade'] ?? '') as String,
        dataColeta: (json['dataColeta'] ?? json['data_coleta'] ?? '') as String,
        status: (json['status'] ?? '') as String,
        cultura: (json['cultura'] ?? '') as String,
        safra: (json['safra'] ?? '') as String,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        descricaoLocal: (json['descricao_local'] ?? json['descricaoLocal']) as String?,
        pdfUrl: (json['pdf_url'] ?? json['pdfUrl']) as String?,
        argila: (json['argila'] as num?)?.toDouble(),
        silte: (json['silte'] as num?)?.toDouble(),
        areiaTotal: (json['areiaTotal'] as num?)?.toDouble(),
        phAgua: ((json['phAgua'] ?? json['ph']) as num?)?.toDouble(),
        phSmp: (json['phSmp'] as num?)?.toDouble(),
        phCaCl2: (json['phCaCl2'] as num?)?.toDouble(),
        materiaOrganica: (json['materiaOrganica'] as num?)?.toDouble(),
        carbonoOrganico: (json['carbonoOrganico'] as num?)?.toDouble(),
        pMehlich: ((json['p_mehlich'] ?? json['pMehlich'] ?? json['fosforo'])
                as num?)
            ?.toDouble(),
        pResina: (json['pResina'] as num?)?.toDouble(),
        pRem: (json['pRem'] as num?)?.toDouble(),
        s020: (json['s020'] as num?)?.toDouble(),
        s2040: (json['s2040'] as num?)?.toDouble(),
        k: ((json['k'] ?? json['potassio']) as num?)?.toDouble(),
        ca: ((json['ca'] ?? json['calcio']) as num?)?.toDouble(),
        mg: ((json['mg'] ?? json['magnesio']) as num?)?.toDouble(),
        al: (json['al'] as num?)?.toDouble(),
        hMaisAl: (json['hMaisAl'] as num?)?.toDouble(),
        na: (json['na'] as num?)?.toDouble(),
        b: (json['b'] as num?)?.toDouble(),
        cu: (json['cu'] as num?)?.toDouble(),
        fe: (json['fe'] as num?)?.toDouble(),
        mn: (json['mn'] as num?)?.toDouble(),
        zn: (json['zn'] as num?)?.toDouble(),
        ni: (json['ni'] as num?)?.toDouble(),
        mo: (json['mo'] as num?)?.toDouble(),
        se: (json['se'] as num?)?.toDouble(),
        fontePrincipalP: json['fontePrincipalP'] == FonteP.resina.name ||
                json['fontePrincipalP'] == 'resina'
            ? FonteP.resina
            : FonteP.mehlich,
        createdAt: const TimestampConverter().fromJson(json['createdAt']),
        updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      );

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'fazenda_nome': fazenda,
        'fazendaNome': fazenda,
        'propriedade': fazenda,
        'produtor': produtor,
        'talhao': talhao,
        'talhao_nome': talhao,
        'talhaoNome': talhao,
        'numeroAmostra': numeroAmostra,
        'laboratorio': laboratorio,
        'profundidade': profundidade,
        'dataColeta': dataColeta,
        'status': status,
        'cultura': cultura,
        'safra': safra,
        'latitude': latitude,
        'longitude': longitude,
        'descricao_local': descricaoLocal,
        'pdf_url': pdfUrl,
        'argila': argila,
        'silte': silte,
        'areiaTotal': areiaTotal,
        'phAgua': phAgua,
        'phSmp': phSmp,
        'phCaCl2': phCaCl2,
        'materiaOrganica': materiaOrganica,
        'carbonoOrganico': carbonoOrganico,
        'p_mehlich': pMehlich,
        'pResina': pResina,
        'pRem': pRem,
        's020': s020,
        's2040': s2040,
        'k': k,
        'ca': ca,
        'mg': mg,
        'al': al,
        'hMaisAl': hMaisAl,
        'na': na,
        'b': b,
        'cu': cu,
        'fe': fe,
        'mn': mn,
        'zn': zn,
        'ni': ni,
        'mo': mo,
        'se': se,
        'fontePrincipalP': fontePrincipalP.name,
        'createdAt': const TimestampConverter().toJson(createdAt),
        'updatedAt': const TimestampConverter().toJson(updatedAt),
        'fosforo': pMehlich,
        'potassio': k,
        'calcio': ca,
        'magnesio': mg,
      };

  double get sb => (ca ?? 0) + (mg ?? 0) + (k ?? 0);

  double get ctcTotal => sb + (hMaisAl ?? 0);

  double get vPct {
    if (ctcTotal == 0) return 0;
    return (sb / ctcTotal) * 100;
  }

  double get argilaPercent => (argila ?? 0) / 10.0;

  FosforoData get fosforoData => FosforoData(
        pResina: pResina,
        pMehlich: pMehlich,
        pRemanescente: pRem,
        fontePrincipal: fontePrincipalP,
      );
}

class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json);
    return null;
  }

  @override
  Object? toJson(DateTime? object) {
    if (object == null) return null;
    return Timestamp.fromDate(object);
  }
}
