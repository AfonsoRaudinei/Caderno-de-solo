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

  factory FosforoData.fromJson(Map<String, dynamic> json) =>
      _$FosforoDataFromJson(json);
}

@freezed
class AnaliseModel with _$AnaliseModel {
  const factory AnaliseModel({
    required String id,
    required String userId,
    required String fazendaNome,
    required String talhaoNome,
    required String dataColeta,
    required String status,
    required String cultura,
    required double ph,
    required FosforoData fosforo,
    required double potassio,
    required double calcio,
    required double magnesio,
    required double ctc,
    required double saturacaoBases,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _AnaliseModel;

  factory AnaliseModel.fromJson(Map<String, dynamic> json) => _$AnaliseModelFromJson(json);
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
