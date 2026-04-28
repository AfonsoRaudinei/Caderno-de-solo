import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloforte/domain/models/calibracao_profile.dart';

part 'calibracao_state.freezed.dart';

@freezed
class CalcarioState with _$CalcarioState {
  const factory CalcarioState({
    @Default({}) Map<String, dynamic> parametros,
  }) = _CalcarioState;
}

@freezed
class GessoState with _$GessoState {
  const factory GessoState({
    @Default({}) Map<String, dynamic> parametros,
  }) = _GessoState;
}

@freezed
class FosforoState with _$FosforoState {
  const factory FosforoState({
    @Default({}) Map<String, dynamic> parametros,
  }) = _FosforoState;
}

@freezed
class PotassioState with _$PotassioState {
  const factory PotassioState({
    @Default({}) Map<String, dynamic> parametros,
  }) = _PotassioState;
}

@freezed
class MicronutrientesState with _$MicronutrientesState {
  const factory MicronutrientesState({
    @Default({}) Map<String, dynamic> parametros,
  }) = _MicronutrientesState;
}

@freezed
class CalibracaoState with _$CalibracaoState {
  const factory CalibracaoState({
    @Default(true) bool loading,
    @Default(false) bool saving,
    @Default([]) List<CalibracaoProfile> profiles,
    String? selectedProfileId,
    required CalibracaoProfile draft,
    String? errorMessage,
    String? successMessage,
    @Default(CalcarioState()) CalcarioState calcario,
    @Default(GessoState()) GessoState gesso,
    @Default(FosforoState()) FosforoState fosforo,
    @Default(PotassioState()) PotassioState potassio,
    @Default(MicronutrientesState()) MicronutrientesState micros,
  }) = _CalibracaoState;
}
