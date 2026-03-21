import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_data_model.freezed.dart';
part 'location_data_model.g.dart';

@freezed
class LocationDataModel with _$LocationDataModel {
  const factory LocationDataModel({
    required double latitude,
    required double longitude,
    required double accuracy,
    String? municipio,
    String? estado,
    String? descricao,
  }) = _LocationDataModel;

  factory LocationDataModel.fromJson(Map<String, dynamic> json) => _$LocationDataModelFromJson(json);
}
