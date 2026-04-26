import 'package:freezed_annotation/freezed_annotation.dart';

part 'calcario_input.freezed.dart';

@freezed
class CalcarioInput with _$CalcarioInput {
  const factory CalcarioInput({
    required double vd,        // saturação desejada (%)
    required double va,        // saturação atual (%)
    required double ctcPh7,    // CTC a pH 7 (cmolc/dm³)
    required double prnt,      // PRNT do calcário (%)
    required double profundidade, // fator p ou cm
  }) = _CalcarioInput;
}

@freezed
class CalcarioResult with _$CalcarioResult {
  const factory CalcarioResult({
    required double ncToneladas, // necessidade de calcário (t/ha)
    required String formula,     // fórmula usada (para auditoria)
  }) = _CalcarioResult;
}
