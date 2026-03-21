import 'package:freezed_annotation/freezed_annotation.dart';

part 'analise_entity.freezed.dart';
part 'analise_entity.g.dart';

@freezed
class AnaliseEntity with _$AnaliseEntity {
  const factory AnaliseEntity({
    required String id,
    required String nome,
    required String consultor,
    required String fazenda,
    required String talhao,
    required String localizacao,
    required String cultura,
    required double ph,
    required double mo,
    required double p,
    required double k,
    required double ca,
    required double mg,
    required double hAl,
    required double al,
    required double s,
    required double b,
    required double cu,
    required double fe,
    required double mn,
    required double zn,
    required double sb,
    required double ctc,
    required double vPercent,
    required double argila,
  }) = _AnaliseEntity;

  factory AnaliseEntity.fromJson(Map<String, dynamic> json) =>
      _$AnaliseEntityFromJson(json);
}
