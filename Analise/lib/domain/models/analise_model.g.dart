// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analise_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FosforoDataImpl _$$FosforoDataImplFromJson(Map<String, dynamic> json) =>
    _$FosforoDataImpl(
      pResina: (json['pResina'] as num?)?.toDouble(),
      pMehlich: (json['pMehlich'] as num?)?.toDouble(),
      pRemanescente: (json['pRemanescente'] as num?)?.toDouble(),
      fontePrincipal:
          $enumDecodeNullable(_$FontePEnumMap, json['fontePrincipal']) ??
              FonteP.resina,
    );

Map<String, dynamic> _$$FosforoDataImplToJson(_$FosforoDataImpl instance) =>
    <String, dynamic>{
      'pResina': instance.pResina,
      'pMehlich': instance.pMehlich,
      'pRemanescente': instance.pRemanescente,
      'fontePrincipal': _$FontePEnumMap[instance.fontePrincipal]!,
    };

const _$FontePEnumMap = {
  FonteP.resina: 'resina',
  FonteP.mehlich: 'mehlich',
};

_$AnaliseModelImpl _$$AnaliseModelImplFromJson(Map<String, dynamic> json) =>
    _$AnaliseModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fazenda: json['fazenda'] as String?,
      produtor: json['produtor'] as String?,
      talhao: json['talhao'] as String?,
      numeroAmostra: json['numeroAmostra'] as String? ?? '',
      laboratorio: json['laboratorio'] as String? ?? '',
      profundidade: json['profundidade'] as String? ?? '',
      dataColeta: json['dataColeta'] as String? ?? '',
      status: json['status'] as String? ?? '',
      cultura: json['cultura'] as String? ?? '',
      safra: json['safra'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      descricaoLocal: json['descricaoLocal'] as String?,
      pdfUrl: json['pdfUrl'] as String?,
      argila: (json['argila'] as num?)?.toDouble(),
      silte: (json['silte'] as num?)?.toDouble(),
      areiaTotal: (json['areiaTotal'] as num?)?.toDouble(),
      phAgua: (json['phAgua'] as num?)?.toDouble(),
      phSmp: (json['phSmp'] as num?)?.toDouble(),
      phCaCl2: (json['phCaCl2'] as num?)?.toDouble(),
      materiaOrganica: (json['materiaOrganica'] as num?)?.toDouble(),
      carbonoOrganico: (json['carbonoOrganico'] as num?)?.toDouble(),
      pMehlich: (json['pMehlich'] as num?)?.toDouble(),
      pResina: (json['pResina'] as num?)?.toDouble(),
      pRem: (json['pRem'] as num?)?.toDouble(),
      s020: (json['s020'] as num?)?.toDouble(),
      s2040: (json['s2040'] as num?)?.toDouble(),
      k: (json['k'] as num?)?.toDouble(),
      ca: (json['ca'] as num?)?.toDouble(),
      mg: (json['mg'] as num?)?.toDouble(),
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
      fontePrincipalP:
          $enumDecodeNullable(_$FontePEnumMap, json['fontePrincipalP']) ??
              FonteP.mehlich,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$AnaliseModelImplToJson(_$AnaliseModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'fazenda': instance.fazenda,
      'produtor': instance.produtor,
      'talhao': instance.talhao,
      'numeroAmostra': instance.numeroAmostra,
      'laboratorio': instance.laboratorio,
      'profundidade': instance.profundidade,
      'dataColeta': instance.dataColeta,
      'status': instance.status,
      'cultura': instance.cultura,
      'safra': instance.safra,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'descricaoLocal': instance.descricaoLocal,
      'pdfUrl': instance.pdfUrl,
      'argila': instance.argila,
      'silte': instance.silte,
      'areiaTotal': instance.areiaTotal,
      'phAgua': instance.phAgua,
      'phSmp': instance.phSmp,
      'phCaCl2': instance.phCaCl2,
      'materiaOrganica': instance.materiaOrganica,
      'carbonoOrganico': instance.carbonoOrganico,
      'pMehlich': instance.pMehlich,
      'pResina': instance.pResina,
      'pRem': instance.pRem,
      's020': instance.s020,
      's2040': instance.s2040,
      'k': instance.k,
      'ca': instance.ca,
      'mg': instance.mg,
      'al': instance.al,
      'hMaisAl': instance.hMaisAl,
      'na': instance.na,
      'b': instance.b,
      'cu': instance.cu,
      'fe': instance.fe,
      'mn': instance.mn,
      'zn': instance.zn,
      'ni': instance.ni,
      'mo': instance.mo,
      'se': instance.se,
      'fontePrincipalP': _$FontePEnumMap[instance.fontePrincipalP]!,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
