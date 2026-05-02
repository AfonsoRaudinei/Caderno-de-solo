// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analise_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnaliseEntityImpl _$$AnaliseEntityImplFromJson(Map<String, dynamic> json) =>
    _$AnaliseEntityImpl(
      id: json['id'] as String,
      nome: json['nome'] as String,
      consultor: json['consultor'] as String,
      fazenda: json['fazenda'] as String,
      talhao: json['talhao'] as String,
      localizacao: json['localizacao'] as String,
      cultura: json['cultura'] as String,
      ph: (json['ph'] as num).toDouble(),
      mo: (json['mo'] as num).toDouble(),
      p: (json['p'] as num).toDouble(),
      k: (json['k'] as num).toDouble(),
      ca: (json['ca'] as num).toDouble(),
      mg: (json['mg'] as num).toDouble(),
      hAl: (json['hAl'] as num).toDouble(),
      al: (json['al'] as num).toDouble(),
      s: (json['s'] as num).toDouble(),
      b: (json['b'] as num).toDouble(),
      cu: (json['cu'] as num).toDouble(),
      fe: (json['fe'] as num).toDouble(),
      mn: (json['mn'] as num).toDouble(),
      zn: (json['zn'] as num).toDouble(),
      sb: (json['sb'] as num).toDouble(),
      ctc: (json['ctc'] as num).toDouble(),
      vPercent: (json['vPercent'] as num).toDouble(),
      argila: (json['argila'] as num).toDouble(),
      pMehlich: (json['pMehlich'] as num?)?.toDouble(),
      pResina: (json['pResina'] as num?)?.toDouble(),
      pRem: (json['pRem'] as num?)?.toDouble(),
      s2040: (json['s2040'] as num?)?.toDouble(),
      silte: (json['silte'] as num?)?.toDouble(),
      areiaTotal: (json['areiaTotal'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$AnaliseEntityImplToJson(_$AnaliseEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'consultor': instance.consultor,
      'fazenda': instance.fazenda,
      'talhao': instance.talhao,
      'localizacao': instance.localizacao,
      'cultura': instance.cultura,
      'ph': instance.ph,
      'mo': instance.mo,
      'p': instance.p,
      'k': instance.k,
      'ca': instance.ca,
      'mg': instance.mg,
      'hAl': instance.hAl,
      'al': instance.al,
      's': instance.s,
      'b': instance.b,
      'cu': instance.cu,
      'fe': instance.fe,
      'mn': instance.mn,
      'zn': instance.zn,
      'sb': instance.sb,
      'ctc': instance.ctc,
      'vPercent': instance.vPercent,
      'argila': instance.argila,
      'pMehlich': instance.pMehlich,
      'pResina': instance.pResina,
      'pRem': instance.pRem,
      's2040': instance.s2040,
      'silte': instance.silte,
      'areiaTotal': instance.areiaTotal,
    };
