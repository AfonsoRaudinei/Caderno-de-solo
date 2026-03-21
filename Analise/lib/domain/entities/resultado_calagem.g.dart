// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resultado_calagem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ResultadoCalagemImpl _$$ResultadoCalagemImplFromJson(
        Map<String, dynamic> json) =>
    _$ResultadoCalagemImpl(
      metodo: $enumDecode(_$MetodoCalagemEnumMap, json['metodo']),
      ncBase: (json['ncBase'] as num?)?.toDouble() ?? 0.0,
      ncProfundidade: (json['ncProfundidade'] as num?)?.toDouble() ?? 0.0,
      ncPRNT: (json['ncPRNT'] as num?)?.toDouble() ?? 0.0,
      doseFinal: (json['doseFinal'] as num?)?.toDouble() ?? 0.0,
      caAdicionado: (json['caAdicionado'] as num?)?.toDouble() ?? 0.0,
      mgAdicionado: (json['mgAdicionado'] as num?)?.toDouble() ?? 0.0,
      CTCnova: (json['CTCnova'] as num?)?.toDouble() ?? 0.0,
      pctCa: (json['pctCa'] as num?)?.toDouble() ?? 0.0,
      pctMg: (json['pctMg'] as num?)?.toDouble() ?? 0.0,
      pctK: (json['pctK'] as num?)?.toDouble() ?? 0.0,
      vPctFinal: (json['vPctFinal'] as num?)?.toDouble() ?? 0.0,
      v2Desejado: (json['v2Desejado'] as num?)?.toDouble() ?? 0.0,
      prntAplicado: (json['prntAplicado'] as num?)?.toDouble() ?? 100.0,
      profFator: (json['profFator'] as num?)?.toDouble() ?? 1.0,
      scFator: (json['scFator'] as num?)?.toDouble() ?? 1.0,
      tipoCalcario: json['tipoCalcario'] as String? ?? 'Dolomítico',
      yUtilizado: (json['yUtilizado'] as num?)?.toDouble() ?? 0.0,
      observacoes: (json['observacoes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ResultadoCalagemImplToJson(
        _$ResultadoCalagemImpl instance) =>
    <String, dynamic>{
      'metodo': _$MetodoCalagemEnumMap[instance.metodo]!,
      'ncBase': instance.ncBase,
      'ncProfundidade': instance.ncProfundidade,
      'ncPRNT': instance.ncPRNT,
      'doseFinal': instance.doseFinal,
      'caAdicionado': instance.caAdicionado,
      'mgAdicionado': instance.mgAdicionado,
      'CTCnova': instance.CTCnova,
      'pctCa': instance.pctCa,
      'pctMg': instance.pctMg,
      'pctK': instance.pctK,
      'vPctFinal': instance.vPctFinal,
      'v2Desejado': instance.v2Desejado,
      'prntAplicado': instance.prntAplicado,
      'profFator': instance.profFator,
      'scFator': instance.scFator,
      'tipoCalcario': instance.tipoCalcario,
      'yUtilizado': instance.yUtilizado,
      'observacoes': instance.observacoes,
    };

const _$MetodoCalagemEnumMap = {
  MetodoCalagem.saturacaoBases: 'saturacaoBases',
  MetodoCalagem.embrapa: 'embrapa',
  MetodoCalagem.caMg: 'caMg',
  MetodoCalagem.supercalagem: 'supercalagem',
  MetodoCalagem.albrecht: 'albrecht',
  MetodoCalagem.albrechtY: 'albrechtY',
  MetodoCalagem.correcaoMg: 'correcaoMg',
};
