import 'package:freezed_annotation/freezed_annotation.dart';

part 'gesso_input.freezed.dart';

@freezed
class GessoInput with _$GessoInput {
  const factory GessoInput({
    required double ctcEfetiva,
    required double ca,
    required String metodo,
  }) = _GessoInput;
}

@freezed
class GessoResult with _$GessoResult {
  const factory GessoResult({
    required double ncToneladas,
    required String formula,
  }) = _GessoResult;
}
