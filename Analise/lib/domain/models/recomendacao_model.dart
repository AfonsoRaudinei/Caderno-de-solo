import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloforte/domain/converters/timestamp_converter.dart';
import 'package:soloforte/domain/entities/citacao_calibracao_model.dart';

export 'package:soloforte/domain/converters/timestamp_converter.dart';

part 'recomendacao_model.freezed.dart';
part 'recomendacao_model.g.dart';

@freezed
class RecomendacaoModel with _$RecomendacaoModel {
  const factory RecomendacaoModel({
    required String id,
    required String analiseId,
    String? userId,
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

  factory RecomendacaoModel.fromJson(Map<String, dynamic> json) =>
      _$RecomendacaoModelFromJson(json);
}
