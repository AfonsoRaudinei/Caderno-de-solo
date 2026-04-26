// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calcario_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CalcarioInput {
  double get vd => throw _privateConstructorUsedError; // saturação desejada (%)
  double get va => throw _privateConstructorUsedError; // saturação atual (%)
  double get ctcPh7 =>
      throw _privateConstructorUsedError; // CTC a pH 7 (cmolc/dm³)
  double get prnt => throw _privateConstructorUsedError; // PRNT do calcário (%)
  double get profundidade => throw _privateConstructorUsedError;

  /// Create a copy of CalcarioInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalcarioInputCopyWith<CalcarioInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalcarioInputCopyWith<$Res> {
  factory $CalcarioInputCopyWith(
          CalcarioInput value, $Res Function(CalcarioInput) then) =
      _$CalcarioInputCopyWithImpl<$Res, CalcarioInput>;
  @useResult
  $Res call(
      {double vd, double va, double ctcPh7, double prnt, double profundidade});
}

/// @nodoc
class _$CalcarioInputCopyWithImpl<$Res, $Val extends CalcarioInput>
    implements $CalcarioInputCopyWith<$Res> {
  _$CalcarioInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalcarioInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vd = null,
    Object? va = null,
    Object? ctcPh7 = null,
    Object? prnt = null,
    Object? profundidade = null,
  }) {
    return _then(_value.copyWith(
      vd: null == vd
          ? _value.vd
          : vd // ignore: cast_nullable_to_non_nullable
              as double,
      va: null == va
          ? _value.va
          : va // ignore: cast_nullable_to_non_nullable
              as double,
      ctcPh7: null == ctcPh7
          ? _value.ctcPh7
          : ctcPh7 // ignore: cast_nullable_to_non_nullable
              as double,
      prnt: null == prnt
          ? _value.prnt
          : prnt // ignore: cast_nullable_to_non_nullable
              as double,
      profundidade: null == profundidade
          ? _value.profundidade
          : profundidade // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalcarioInputImplCopyWith<$Res>
    implements $CalcarioInputCopyWith<$Res> {
  factory _$$CalcarioInputImplCopyWith(
          _$CalcarioInputImpl value, $Res Function(_$CalcarioInputImpl) then) =
      __$$CalcarioInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double vd, double va, double ctcPh7, double prnt, double profundidade});
}

/// @nodoc
class __$$CalcarioInputImplCopyWithImpl<$Res>
    extends _$CalcarioInputCopyWithImpl<$Res, _$CalcarioInputImpl>
    implements _$$CalcarioInputImplCopyWith<$Res> {
  __$$CalcarioInputImplCopyWithImpl(
      _$CalcarioInputImpl _value, $Res Function(_$CalcarioInputImpl) _then)
      : super(_value, _then);

  /// Create a copy of CalcarioInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vd = null,
    Object? va = null,
    Object? ctcPh7 = null,
    Object? prnt = null,
    Object? profundidade = null,
  }) {
    return _then(_$CalcarioInputImpl(
      vd: null == vd
          ? _value.vd
          : vd // ignore: cast_nullable_to_non_nullable
              as double,
      va: null == va
          ? _value.va
          : va // ignore: cast_nullable_to_non_nullable
              as double,
      ctcPh7: null == ctcPh7
          ? _value.ctcPh7
          : ctcPh7 // ignore: cast_nullable_to_non_nullable
              as double,
      prnt: null == prnt
          ? _value.prnt
          : prnt // ignore: cast_nullable_to_non_nullable
              as double,
      profundidade: null == profundidade
          ? _value.profundidade
          : profundidade // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$CalcarioInputImpl implements _CalcarioInput {
  const _$CalcarioInputImpl(
      {required this.vd,
      required this.va,
      required this.ctcPh7,
      required this.prnt,
      required this.profundidade});

  @override
  final double vd;
// saturação desejada (%)
  @override
  final double va;
// saturação atual (%)
  @override
  final double ctcPh7;
// CTC a pH 7 (cmolc/dm³)
  @override
  final double prnt;
// PRNT do calcário (%)
  @override
  final double profundidade;

  @override
  String toString() {
    return 'CalcarioInput(vd: $vd, va: $va, ctcPh7: $ctcPh7, prnt: $prnt, profundidade: $profundidade)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalcarioInputImpl &&
            (identical(other.vd, vd) || other.vd == vd) &&
            (identical(other.va, va) || other.va == va) &&
            (identical(other.ctcPh7, ctcPh7) || other.ctcPh7 == ctcPh7) &&
            (identical(other.prnt, prnt) || other.prnt == prnt) &&
            (identical(other.profundidade, profundidade) ||
                other.profundidade == profundidade));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, vd, va, ctcPh7, prnt, profundidade);

  /// Create a copy of CalcarioInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalcarioInputImplCopyWith<_$CalcarioInputImpl> get copyWith =>
      __$$CalcarioInputImplCopyWithImpl<_$CalcarioInputImpl>(this, _$identity);
}

abstract class _CalcarioInput implements CalcarioInput {
  const factory _CalcarioInput(
      {required final double vd,
      required final double va,
      required final double ctcPh7,
      required final double prnt,
      required final double profundidade}) = _$CalcarioInputImpl;

  @override
  double get vd; // saturação desejada (%)
  @override
  double get va; // saturação atual (%)
  @override
  double get ctcPh7; // CTC a pH 7 (cmolc/dm³)
  @override
  double get prnt; // PRNT do calcário (%)
  @override
  double get profundidade;

  /// Create a copy of CalcarioInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalcarioInputImplCopyWith<_$CalcarioInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CalcarioResult {
  double get ncToneladas =>
      throw _privateConstructorUsedError; // necessidade de calcário (t/ha)
  String get formula => throw _privateConstructorUsedError;

  /// Create a copy of CalcarioResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalcarioResultCopyWith<CalcarioResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalcarioResultCopyWith<$Res> {
  factory $CalcarioResultCopyWith(
          CalcarioResult value, $Res Function(CalcarioResult) then) =
      _$CalcarioResultCopyWithImpl<$Res, CalcarioResult>;
  @useResult
  $Res call({double ncToneladas, String formula});
}

/// @nodoc
class _$CalcarioResultCopyWithImpl<$Res, $Val extends CalcarioResult>
    implements $CalcarioResultCopyWith<$Res> {
  _$CalcarioResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalcarioResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ncToneladas = null,
    Object? formula = null,
  }) {
    return _then(_value.copyWith(
      ncToneladas: null == ncToneladas
          ? _value.ncToneladas
          : ncToneladas // ignore: cast_nullable_to_non_nullable
              as double,
      formula: null == formula
          ? _value.formula
          : formula // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalcarioResultImplCopyWith<$Res>
    implements $CalcarioResultCopyWith<$Res> {
  factory _$$CalcarioResultImplCopyWith(_$CalcarioResultImpl value,
          $Res Function(_$CalcarioResultImpl) then) =
      __$$CalcarioResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double ncToneladas, String formula});
}

/// @nodoc
class __$$CalcarioResultImplCopyWithImpl<$Res>
    extends _$CalcarioResultCopyWithImpl<$Res, _$CalcarioResultImpl>
    implements _$$CalcarioResultImplCopyWith<$Res> {
  __$$CalcarioResultImplCopyWithImpl(
      _$CalcarioResultImpl _value, $Res Function(_$CalcarioResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of CalcarioResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ncToneladas = null,
    Object? formula = null,
  }) {
    return _then(_$CalcarioResultImpl(
      ncToneladas: null == ncToneladas
          ? _value.ncToneladas
          : ncToneladas // ignore: cast_nullable_to_non_nullable
              as double,
      formula: null == formula
          ? _value.formula
          : formula // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CalcarioResultImpl implements _CalcarioResult {
  const _$CalcarioResultImpl(
      {required this.ncToneladas, required this.formula});

  @override
  final double ncToneladas;
// necessidade de calcário (t/ha)
  @override
  final String formula;

  @override
  String toString() {
    return 'CalcarioResult(ncToneladas: $ncToneladas, formula: $formula)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalcarioResultImpl &&
            (identical(other.ncToneladas, ncToneladas) ||
                other.ncToneladas == ncToneladas) &&
            (identical(other.formula, formula) || other.formula == formula));
  }

  @override
  int get hashCode => Object.hash(runtimeType, ncToneladas, formula);

  /// Create a copy of CalcarioResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalcarioResultImplCopyWith<_$CalcarioResultImpl> get copyWith =>
      __$$CalcarioResultImplCopyWithImpl<_$CalcarioResultImpl>(
          this, _$identity);
}

abstract class _CalcarioResult implements CalcarioResult {
  const factory _CalcarioResult(
      {required final double ncToneladas,
      required final String formula}) = _$CalcarioResultImpl;

  @override
  double get ncToneladas; // necessidade de calcário (t/ha)
  @override
  String get formula;

  /// Create a copy of CalcarioResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalcarioResultImplCopyWith<_$CalcarioResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
