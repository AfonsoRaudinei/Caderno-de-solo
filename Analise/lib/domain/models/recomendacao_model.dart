import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloforte/domain/entities/citacao_calibracao_model.dart';

part 'recomendacao_model.freezed.dart';
part 'recomendacao_model.g.dart';

@freezed
class RecomendacaoModel with _$RecomendacaoModel {
  const factory RecomendacaoModel({
    required String id,
    required String analiseId,
    required String cultura,
    required double necessidadeCalagem,
    required double prnt,
    required double doseCalcario,
    required double p2o5,
    required double k2o,
    @Default(CitacaoCalibracaoModel.calagem)
    CitacaoCalibracaoModel citacaoCalagem,
    @Default(CitacaoCalibracaoModel.gesso) CitacaoCalibracaoModel citacaoGesso,
    @Default(CitacaoCalibracaoModel.fosforo)
    CitacaoCalibracaoModel citacaoFosforo,
    @Default(CitacaoCalibracaoModel.potassio)
    CitacaoCalibracaoModel citacaoPotassio,
    @Default(CitacaoCalibracaoModel.enxofre)
    CitacaoCalibracaoModel citacaoEnxofre,
    @Default(CitacaoCalibracaoModel.micronutrientes)
    CitacaoCalibracaoModel citacaoMicronutrientes,
    @TimestampConverter() DateTime? createdAt,
  }) = _RecomendacaoModel;

  factory RecomendacaoModel.fromJson(Map<String, dynamic> json) => _$RecomendacaoModelFromJson(json);
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
