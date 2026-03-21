// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recomendacao_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RecomendacaoModel _$RecomendacaoModelFromJson(Map<String, dynamic> json) {
  return _RecomendacaoModel.fromJson(json);
}

/// @nodoc
mixin _$RecomendacaoModel {
  String get id => throw _privateConstructorUsedError;
  String get analiseId => throw _privateConstructorUsedError;
  String get cultura => throw _privateConstructorUsedError;
  double get necessidadeCalagem => throw _privateConstructorUsedError;
  double get prnt => throw _privateConstructorUsedError;
  double get doseCalcario => throw _privateConstructorUsedError;
  double get p2o5 => throw _privateConstructorUsedError;
  double get k2o => throw _privateConstructorUsedError;
  CitacaoCalibracaoModel get citacaoCalagem =>
      throw _privateConstructorUsedError;
  CitacaoCalibracaoModel get citacaoGesso => throw _privateConstructorUsedError;
  CitacaoCalibracaoModel get citacaoFosforo =>
      throw _privateConstructorUsedError;
  CitacaoCalibracaoModel get citacaoPotassio =>
      throw _privateConstructorUsedError;
  CitacaoCalibracaoModel get citacaoEnxofre =>
      throw _privateConstructorUsedError;
  CitacaoCalibracaoModel get citacaoMicronutrientes =>
      throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this RecomendacaoModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecomendacaoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecomendacaoModelCopyWith<RecomendacaoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecomendacaoModelCopyWith<$Res> {
  factory $RecomendacaoModelCopyWith(
          RecomendacaoModel value, $Res Function(RecomendacaoModel) then) =
      _$RecomendacaoModelCopyWithImpl<$Res, RecomendacaoModel>;
  @useResult
  $Res call(
      {String id,
      String analiseId,
      String cultura,
      double necessidadeCalagem,
      double prnt,
      double doseCalcario,
      double p2o5,
      double k2o,
      CitacaoCalibracaoModel citacaoCalagem,
      CitacaoCalibracaoModel citacaoGesso,
      CitacaoCalibracaoModel citacaoFosforo,
      CitacaoCalibracaoModel citacaoPotassio,
      CitacaoCalibracaoModel citacaoEnxofre,
      CitacaoCalibracaoModel citacaoMicronutrientes,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class _$RecomendacaoModelCopyWithImpl<$Res, $Val extends RecomendacaoModel>
    implements $RecomendacaoModelCopyWith<$Res> {
  _$RecomendacaoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecomendacaoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? analiseId = null,
    Object? cultura = null,
    Object? necessidadeCalagem = null,
    Object? prnt = null,
    Object? doseCalcario = null,
    Object? p2o5 = null,
    Object? k2o = null,
    Object? citacaoCalagem = null,
    Object? citacaoGesso = null,
    Object? citacaoFosforo = null,
    Object? citacaoPotassio = null,
    Object? citacaoEnxofre = null,
    Object? citacaoMicronutrientes = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      analiseId: null == analiseId
          ? _value.analiseId
          : analiseId // ignore: cast_nullable_to_non_nullable
              as String,
      cultura: null == cultura
          ? _value.cultura
          : cultura // ignore: cast_nullable_to_non_nullable
              as String,
      necessidadeCalagem: null == necessidadeCalagem
          ? _value.necessidadeCalagem
          : necessidadeCalagem // ignore: cast_nullable_to_non_nullable
              as double,
      prnt: null == prnt
          ? _value.prnt
          : prnt // ignore: cast_nullable_to_non_nullable
              as double,
      doseCalcario: null == doseCalcario
          ? _value.doseCalcario
          : doseCalcario // ignore: cast_nullable_to_non_nullable
              as double,
      p2o5: null == p2o5
          ? _value.p2o5
          : p2o5 // ignore: cast_nullable_to_non_nullable
              as double,
      k2o: null == k2o
          ? _value.k2o
          : k2o // ignore: cast_nullable_to_non_nullable
              as double,
      citacaoCalagem: null == citacaoCalagem
          ? _value.citacaoCalagem
          : citacaoCalagem // ignore: cast_nullable_to_non_nullable
              as CitacaoCalibracaoModel,
      citacaoGesso: null == citacaoGesso
          ? _value.citacaoGesso
          : citacaoGesso // ignore: cast_nullable_to_non_nullable
              as CitacaoCalibracaoModel,
      citacaoFosforo: null == citacaoFosforo
          ? _value.citacaoFosforo
          : citacaoFosforo // ignore: cast_nullable_to_non_nullable
              as CitacaoCalibracaoModel,
      citacaoPotassio: null == citacaoPotassio
          ? _value.citacaoPotassio
          : citacaoPotassio // ignore: cast_nullable_to_non_nullable
              as CitacaoCalibracaoModel,
      citacaoEnxofre: null == citacaoEnxofre
          ? _value.citacaoEnxofre
          : citacaoEnxofre // ignore: cast_nullable_to_non_nullable
              as CitacaoCalibracaoModel,
      citacaoMicronutrientes: null == citacaoMicronutrientes
          ? _value.citacaoMicronutrientes
          : citacaoMicronutrientes // ignore: cast_nullable_to_non_nullable
              as CitacaoCalibracaoModel,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecomendacaoModelImplCopyWith<$Res>
    implements $RecomendacaoModelCopyWith<$Res> {
  factory _$$RecomendacaoModelImplCopyWith(_$RecomendacaoModelImpl value,
          $Res Function(_$RecomendacaoModelImpl) then) =
      __$$RecomendacaoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String analiseId,
      String cultura,
      double necessidadeCalagem,
      double prnt,
      double doseCalcario,
      double p2o5,
      double k2o,
      CitacaoCalibracaoModel citacaoCalagem,
      CitacaoCalibracaoModel citacaoGesso,
      CitacaoCalibracaoModel citacaoFosforo,
      CitacaoCalibracaoModel citacaoPotassio,
      CitacaoCalibracaoModel citacaoEnxofre,
      CitacaoCalibracaoModel citacaoMicronutrientes,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class __$$RecomendacaoModelImplCopyWithImpl<$Res>
    extends _$RecomendacaoModelCopyWithImpl<$Res, _$RecomendacaoModelImpl>
    implements _$$RecomendacaoModelImplCopyWith<$Res> {
  __$$RecomendacaoModelImplCopyWithImpl(_$RecomendacaoModelImpl _value,
      $Res Function(_$RecomendacaoModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecomendacaoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? analiseId = null,
    Object? cultura = null,
    Object? necessidadeCalagem = null,
    Object? prnt = null,
    Object? doseCalcario = null,
    Object? p2o5 = null,
    Object? k2o = null,
    Object? citacaoCalagem = null,
    Object? citacaoGesso = null,
    Object? citacaoFosforo = null,
    Object? citacaoPotassio = null,
    Object? citacaoEnxofre = null,
    Object? citacaoMicronutrientes = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$RecomendacaoModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      analiseId: null == analiseId
          ? _value.analiseId
          : analiseId // ignore: cast_nullable_to_non_nullable
              as String,
      cultura: null == cultura
          ? _value.cultura
          : cultura // ignore: cast_nullable_to_non_nullable
              as String,
      necessidadeCalagem: null == necessidadeCalagem
          ? _value.necessidadeCalagem
          : necessidadeCalagem // ignore: cast_nullable_to_non_nullable
              as double,
      prnt: null == prnt
          ? _value.prnt
          : prnt // ignore: cast_nullable_to_non_nullable
              as double,
      doseCalcario: null == doseCalcario
          ? _value.doseCalcario
          : doseCalcario // ignore: cast_nullable_to_non_nullable
              as double,
      p2o5: null == p2o5
          ? _value.p2o5
          : p2o5 // ignore: cast_nullable_to_non_nullable
              as double,
      k2o: null == k2o
          ? _value.k2o
          : k2o // ignore: cast_nullable_to_non_nullable
              as double,
      citacaoCalagem: null == citacaoCalagem
          ? _value.citacaoCalagem
          : citacaoCalagem // ignore: cast_nullable_to_non_nullable
              as CitacaoCalibracaoModel,
      citacaoGesso: null == citacaoGesso
          ? _value.citacaoGesso
          : citacaoGesso // ignore: cast_nullable_to_non_nullable
              as CitacaoCalibracaoModel,
      citacaoFosforo: null == citacaoFosforo
          ? _value.citacaoFosforo
          : citacaoFosforo // ignore: cast_nullable_to_non_nullable
              as CitacaoCalibracaoModel,
      citacaoPotassio: null == citacaoPotassio
          ? _value.citacaoPotassio
          : citacaoPotassio // ignore: cast_nullable_to_non_nullable
              as CitacaoCalibracaoModel,
      citacaoEnxofre: null == citacaoEnxofre
          ? _value.citacaoEnxofre
          : citacaoEnxofre // ignore: cast_nullable_to_non_nullable
              as CitacaoCalibracaoModel,
      citacaoMicronutrientes: null == citacaoMicronutrientes
          ? _value.citacaoMicronutrientes
          : citacaoMicronutrientes // ignore: cast_nullable_to_non_nullable
              as CitacaoCalibracaoModel,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecomendacaoModelImpl implements _RecomendacaoModel {
  const _$RecomendacaoModelImpl(
      {required this.id,
      required this.analiseId,
      required this.cultura,
      required this.necessidadeCalagem,
      required this.prnt,
      required this.doseCalcario,
      required this.p2o5,
      required this.k2o,
      this.citacaoCalagem = CitacaoCalibracaoModel.calagem,
      this.citacaoGesso = CitacaoCalibracaoModel.gesso,
      this.citacaoFosforo = CitacaoCalibracaoModel.fosforo,
      this.citacaoPotassio = CitacaoCalibracaoModel.potassio,
      this.citacaoEnxofre = CitacaoCalibracaoModel.enxofre,
      this.citacaoMicronutrientes = CitacaoCalibracaoModel.micronutrientes,
      @TimestampConverter() this.createdAt});

  factory _$RecomendacaoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecomendacaoModelImplFromJson(json);

  @override
  final String id;
  @override
  final String analiseId;
  @override
  final String cultura;
  @override
  final double necessidadeCalagem;
  @override
  final double prnt;
  @override
  final double doseCalcario;
  @override
  final double p2o5;
  @override
  final double k2o;
  @override
  @JsonKey()
  final CitacaoCalibracaoModel citacaoCalagem;
  @override
  @JsonKey()
  final CitacaoCalibracaoModel citacaoGesso;
  @override
  @JsonKey()
  final CitacaoCalibracaoModel citacaoFosforo;
  @override
  @JsonKey()
  final CitacaoCalibracaoModel citacaoPotassio;
  @override
  @JsonKey()
  final CitacaoCalibracaoModel citacaoEnxofre;
  @override
  @JsonKey()
  final CitacaoCalibracaoModel citacaoMicronutrientes;
  @override
  @TimestampConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'RecomendacaoModel(id: $id, analiseId: $analiseId, cultura: $cultura, necessidadeCalagem: $necessidadeCalagem, prnt: $prnt, doseCalcario: $doseCalcario, p2o5: $p2o5, k2o: $k2o, citacaoCalagem: $citacaoCalagem, citacaoGesso: $citacaoGesso, citacaoFosforo: $citacaoFosforo, citacaoPotassio: $citacaoPotassio, citacaoEnxofre: $citacaoEnxofre, citacaoMicronutrientes: $citacaoMicronutrientes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecomendacaoModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.analiseId, analiseId) ||
                other.analiseId == analiseId) &&
            (identical(other.cultura, cultura) || other.cultura == cultura) &&
            (identical(other.necessidadeCalagem, necessidadeCalagem) ||
                other.necessidadeCalagem == necessidadeCalagem) &&
            (identical(other.prnt, prnt) || other.prnt == prnt) &&
            (identical(other.doseCalcario, doseCalcario) ||
                other.doseCalcario == doseCalcario) &&
            (identical(other.p2o5, p2o5) || other.p2o5 == p2o5) &&
            (identical(other.k2o, k2o) || other.k2o == k2o) &&
            (identical(other.citacaoCalagem, citacaoCalagem) ||
                other.citacaoCalagem == citacaoCalagem) &&
            (identical(other.citacaoGesso, citacaoGesso) ||
                other.citacaoGesso == citacaoGesso) &&
            (identical(other.citacaoFosforo, citacaoFosforo) ||
                other.citacaoFosforo == citacaoFosforo) &&
            (identical(other.citacaoPotassio, citacaoPotassio) ||
                other.citacaoPotassio == citacaoPotassio) &&
            (identical(other.citacaoEnxofre, citacaoEnxofre) ||
                other.citacaoEnxofre == citacaoEnxofre) &&
            (identical(other.citacaoMicronutrientes, citacaoMicronutrientes) ||
                other.citacaoMicronutrientes == citacaoMicronutrientes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      analiseId,
      cultura,
      necessidadeCalagem,
      prnt,
      doseCalcario,
      p2o5,
      k2o,
      citacaoCalagem,
      citacaoGesso,
      citacaoFosforo,
      citacaoPotassio,
      citacaoEnxofre,
      citacaoMicronutrientes,
      createdAt);

  /// Create a copy of RecomendacaoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecomendacaoModelImplCopyWith<_$RecomendacaoModelImpl> get copyWith =>
      __$$RecomendacaoModelImplCopyWithImpl<_$RecomendacaoModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecomendacaoModelImplToJson(
      this,
    );
  }
}

abstract class _RecomendacaoModel implements RecomendacaoModel {
  const factory _RecomendacaoModel(
          {required final String id,
          required final String analiseId,
          required final String cultura,
          required final double necessidadeCalagem,
          required final double prnt,
          required final double doseCalcario,
          required final double p2o5,
          required final double k2o,
          final CitacaoCalibracaoModel citacaoCalagem,
          final CitacaoCalibracaoModel citacaoGesso,
          final CitacaoCalibracaoModel citacaoFosforo,
          final CitacaoCalibracaoModel citacaoPotassio,
          final CitacaoCalibracaoModel citacaoEnxofre,
          final CitacaoCalibracaoModel citacaoMicronutrientes,
          @TimestampConverter() final DateTime? createdAt}) =
      _$RecomendacaoModelImpl;

  factory _RecomendacaoModel.fromJson(Map<String, dynamic> json) =
      _$RecomendacaoModelImpl.fromJson;

  @override
  String get id;
  @override
  String get analiseId;
  @override
  String get cultura;
  @override
  double get necessidadeCalagem;
  @override
  double get prnt;
  @override
  double get doseCalcario;
  @override
  double get p2o5;
  @override
  double get k2o;
  @override
  CitacaoCalibracaoModel get citacaoCalagem;
  @override
  CitacaoCalibracaoModel get citacaoGesso;
  @override
  CitacaoCalibracaoModel get citacaoFosforo;
  @override
  CitacaoCalibracaoModel get citacaoPotassio;
  @override
  CitacaoCalibracaoModel get citacaoEnxofre;
  @override
  CitacaoCalibracaoModel get citacaoMicronutrientes;
  @override
  @TimestampConverter()
  DateTime? get createdAt;

  /// Create a copy of RecomendacaoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecomendacaoModelImplCopyWith<_$RecomendacaoModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
