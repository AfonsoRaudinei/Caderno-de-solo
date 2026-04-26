import 'package:freezed_annotation/freezed_annotation.dart';

part 'fosforo_input.freezed.dart';

@freezed
class FosforoInput with _$FosforoInput {
  const factory FosforoInput({
    required double argila,
    required double pAtual,
    required double nc,
    required String referencia,
  }) = _FosforoInput;
}

@freezed
class FosforoResult with _$FosforoResult {
  const factory FosforoResult({
    required double doseRecomendada,
    required String formula,
  }) = _FosforoResult;
}
