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
      fazendaNome: json['fazendaNome'] as String,
      talhaoNome: json['talhaoNome'] as String,
      dataColeta: json['dataColeta'] as String,
      status: json['status'] as String,
      cultura: json['cultura'] as String,
      ph: (json['ph'] as num).toDouble(),
      fosforo: FosforoData.fromJson(json['fosforo'] as Map<String, dynamic>),
      potassio: (json['potassio'] as num).toDouble(),
      calcio: (json['calcio'] as num).toDouble(),
      magnesio: (json['magnesio'] as num).toDouble(),
      ctc: (json['ctc'] as num).toDouble(),
      saturacaoBases: (json['saturacaoBases'] as num).toDouble(),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$AnaliseModelImplToJson(_$AnaliseModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'fazendaNome': instance.fazendaNome,
      'talhaoNome': instance.talhaoNome,
      'dataColeta': instance.dataColeta,
      'status': instance.status,
      'cultura': instance.cultura,
      'ph': instance.ph,
      'fosforo': instance.fosforo,
      'potassio': instance.potassio,
      'calcio': instance.calcio,
      'magnesio': instance.magnesio,
      'ctc': instance.ctc,
      'saturacaoBases': instance.saturacaoBases,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
