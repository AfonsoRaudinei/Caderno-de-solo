// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recomendacao_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecomendacaoModelImpl _$$RecomendacaoModelImplFromJson(
        Map<String, dynamic> json) =>
    _$RecomendacaoModelImpl(
      id: json['id'] as String,
      analiseId: json['analiseId'] as String,
      userId: json['userId'] as String?,
      cultura: json['cultura'] as String,
      necessidadeCalagem: (json['necessidadeCalagem'] as num).toDouble(),
      prnt: (json['prnt'] as num).toDouble(),
      doseCalcario: (json['doseCalcario'] as num).toDouble(),
      p2o5: (json['p2o5'] as num).toDouble(),
      k2o: (json['k2o'] as num).toDouble(),
      citacaoCalagem: json['citacaoCalagem'] == null
          ? CitacaoCalibracaoModel.calagem
          : CitacaoCalibracaoModel.fromJson(
              json['citacaoCalagem'] as Map<String, dynamic>),
      citacaoGesso: json['citacaoGesso'] == null
          ? CitacaoCalibracaoModel.gesso
          : CitacaoCalibracaoModel.fromJson(
              json['citacaoGesso'] as Map<String, dynamic>),
      citacaoFosforo: json['citacaoFosforo'] == null
          ? CitacaoCalibracaoModel.fosforo
          : CitacaoCalibracaoModel.fromJson(
              json['citacaoFosforo'] as Map<String, dynamic>),
      citacaoPotassio: json['citacaoPotassio'] == null
          ? CitacaoCalibracaoModel.potassio
          : CitacaoCalibracaoModel.fromJson(
              json['citacaoPotassio'] as Map<String, dynamic>),
      citacaoEnxofre: json['citacaoEnxofre'] == null
          ? CitacaoCalibracaoModel.enxofre
          : CitacaoCalibracaoModel.fromJson(
              json['citacaoEnxofre'] as Map<String, dynamic>),
      citacaoMicronutrientes: json['citacaoMicronutrientes'] == null
          ? CitacaoCalibracaoModel.micronutrientes
          : CitacaoCalibracaoModel.fromJson(
              json['citacaoMicronutrientes'] as Map<String, dynamic>),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$RecomendacaoModelImplToJson(
        _$RecomendacaoModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'analiseId': instance.analiseId,
      'userId': instance.userId,
      'cultura': instance.cultura,
      'necessidadeCalagem': instance.necessidadeCalagem,
      'prnt': instance.prnt,
      'doseCalcario': instance.doseCalcario,
      'p2o5': instance.p2o5,
      'k2o': instance.k2o,
      'citacaoCalagem': instance.citacaoCalagem,
      'citacaoGesso': instance.citacaoGesso,
      'citacaoFosforo': instance.citacaoFosforo,
      'citacaoPotassio': instance.citacaoPotassio,
      'citacaoEnxofre': instance.citacaoEnxofre,
      'citacaoMicronutrientes': instance.citacaoMicronutrientes,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
