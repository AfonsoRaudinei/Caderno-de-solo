// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analise_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FosforoData _$FosforoDataFromJson(Map<String, dynamic> json) {
  return _FosforoData.fromJson(json);
}

/// @nodoc
mixin _$FosforoData {
  double? get pResina => throw _privateConstructorUsedError;
  double? get pMehlich => throw _privateConstructorUsedError;
  double? get pRemanescente => throw _privateConstructorUsedError;
  FonteP get fontePrincipal => throw _privateConstructorUsedError;

  /// Serializes this FosforoData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FosforoData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FosforoDataCopyWith<FosforoData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FosforoDataCopyWith<$Res> {
  factory $FosforoDataCopyWith(
          FosforoData value, $Res Function(FosforoData) then) =
      _$FosforoDataCopyWithImpl<$Res, FosforoData>;
  @useResult
  $Res call(
      {double? pResina,
      double? pMehlich,
      double? pRemanescente,
      FonteP fontePrincipal});
}

/// @nodoc
class _$FosforoDataCopyWithImpl<$Res, $Val extends FosforoData>
    implements $FosforoDataCopyWith<$Res> {
  _$FosforoDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FosforoData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pResina = freezed,
    Object? pMehlich = freezed,
    Object? pRemanescente = freezed,
    Object? fontePrincipal = null,
  }) {
    return _then(_value.copyWith(
      pResina: freezed == pResina
          ? _value.pResina
          : pResina // ignore: cast_nullable_to_non_nullable
              as double?,
      pMehlich: freezed == pMehlich
          ? _value.pMehlich
          : pMehlich // ignore: cast_nullable_to_non_nullable
              as double?,
      pRemanescente: freezed == pRemanescente
          ? _value.pRemanescente
          : pRemanescente // ignore: cast_nullable_to_non_nullable
              as double?,
      fontePrincipal: null == fontePrincipal
          ? _value.fontePrincipal
          : fontePrincipal // ignore: cast_nullable_to_non_nullable
              as FonteP,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FosforoDataImplCopyWith<$Res>
    implements $FosforoDataCopyWith<$Res> {
  factory _$$FosforoDataImplCopyWith(
          _$FosforoDataImpl value, $Res Function(_$FosforoDataImpl) then) =
      __$$FosforoDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double? pResina,
      double? pMehlich,
      double? pRemanescente,
      FonteP fontePrincipal});
}

/// @nodoc
class __$$FosforoDataImplCopyWithImpl<$Res>
    extends _$FosforoDataCopyWithImpl<$Res, _$FosforoDataImpl>
    implements _$$FosforoDataImplCopyWith<$Res> {
  __$$FosforoDataImplCopyWithImpl(
      _$FosforoDataImpl _value, $Res Function(_$FosforoDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of FosforoData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pResina = freezed,
    Object? pMehlich = freezed,
    Object? pRemanescente = freezed,
    Object? fontePrincipal = null,
  }) {
    return _then(_$FosforoDataImpl(
      pResina: freezed == pResina
          ? _value.pResina
          : pResina // ignore: cast_nullable_to_non_nullable
              as double?,
      pMehlich: freezed == pMehlich
          ? _value.pMehlich
          : pMehlich // ignore: cast_nullable_to_non_nullable
              as double?,
      pRemanescente: freezed == pRemanescente
          ? _value.pRemanescente
          : pRemanescente // ignore: cast_nullable_to_non_nullable
              as double?,
      fontePrincipal: null == fontePrincipal
          ? _value.fontePrincipal
          : fontePrincipal // ignore: cast_nullable_to_non_nullable
              as FonteP,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FosforoDataImpl extends _FosforoData {
  const _$FosforoDataImpl(
      {this.pResina,
      this.pMehlich,
      this.pRemanescente,
      this.fontePrincipal = FonteP.resina})
      : super._();

  factory _$FosforoDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$FosforoDataImplFromJson(json);

  @override
  final double? pResina;
  @override
  final double? pMehlich;
  @override
  final double? pRemanescente;
  @override
  @JsonKey()
  final FonteP fontePrincipal;

  @override
  String toString() {
    return 'FosforoData(pResina: $pResina, pMehlich: $pMehlich, pRemanescente: $pRemanescente, fontePrincipal: $fontePrincipal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FosforoDataImpl &&
            (identical(other.pResina, pResina) || other.pResina == pResina) &&
            (identical(other.pMehlich, pMehlich) ||
                other.pMehlich == pMehlich) &&
            (identical(other.pRemanescente, pRemanescente) ||
                other.pRemanescente == pRemanescente) &&
            (identical(other.fontePrincipal, fontePrincipal) ||
                other.fontePrincipal == fontePrincipal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, pResina, pMehlich, pRemanescente, fontePrincipal);

  /// Create a copy of FosforoData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FosforoDataImplCopyWith<_$FosforoDataImpl> get copyWith =>
      __$$FosforoDataImplCopyWithImpl<_$FosforoDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FosforoDataImplToJson(
      this,
    );
  }
}

abstract class _FosforoData extends FosforoData {
  const factory _FosforoData(
      {final double? pResina,
      final double? pMehlich,
      final double? pRemanescente,
      final FonteP fontePrincipal}) = _$FosforoDataImpl;
  const _FosforoData._() : super._();

  factory _FosforoData.fromJson(Map<String, dynamic> json) =
      _$FosforoDataImpl.fromJson;

  @override
  double? get pResina;
  @override
  double? get pMehlich;
  @override
  double? get pRemanescente;
  @override
  FonteP get fontePrincipal;

  /// Create a copy of FosforoData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FosforoDataImplCopyWith<_$FosforoDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AnaliseModel _$AnaliseModelFromJson(Map<String, dynamic> json) {
  return _AnaliseModel.fromJson(json);
}

/// @nodoc
mixin _$AnaliseModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get fazendaNome => throw _privateConstructorUsedError;
  String get talhaoNome => throw _privateConstructorUsedError;
  String get dataColeta => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get cultura => throw _privateConstructorUsedError;
  double get ph => throw _privateConstructorUsedError;
  FosforoData get fosforo => throw _privateConstructorUsedError;
  double get potassio => throw _privateConstructorUsedError;
  double get calcio => throw _privateConstructorUsedError;
  double get magnesio => throw _privateConstructorUsedError;
  double get ctc => throw _privateConstructorUsedError;
  double get saturacaoBases => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AnaliseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnaliseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnaliseModelCopyWith<AnaliseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnaliseModelCopyWith<$Res> {
  factory $AnaliseModelCopyWith(
          AnaliseModel value, $Res Function(AnaliseModel) then) =
      _$AnaliseModelCopyWithImpl<$Res, AnaliseModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String fazendaNome,
      String talhaoNome,
      String dataColeta,
      String status,
      String cultura,
      double ph,
      FosforoData fosforo,
      double potassio,
      double calcio,
      double magnesio,
      double ctc,
      double saturacaoBases,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});

  $FosforoDataCopyWith<$Res> get fosforo;
}

/// @nodoc
class _$AnaliseModelCopyWithImpl<$Res, $Val extends AnaliseModel>
    implements $AnaliseModelCopyWith<$Res> {
  _$AnaliseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnaliseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? fazendaNome = null,
    Object? talhaoNome = null,
    Object? dataColeta = null,
    Object? status = null,
    Object? cultura = null,
    Object? ph = null,
    Object? fosforo = null,
    Object? potassio = null,
    Object? calcio = null,
    Object? magnesio = null,
    Object? ctc = null,
    Object? saturacaoBases = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      fazendaNome: null == fazendaNome
          ? _value.fazendaNome
          : fazendaNome // ignore: cast_nullable_to_non_nullable
              as String,
      talhaoNome: null == talhaoNome
          ? _value.talhaoNome
          : talhaoNome // ignore: cast_nullable_to_non_nullable
              as String,
      dataColeta: null == dataColeta
          ? _value.dataColeta
          : dataColeta // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      cultura: null == cultura
          ? _value.cultura
          : cultura // ignore: cast_nullable_to_non_nullable
              as String,
      ph: null == ph
          ? _value.ph
          : ph // ignore: cast_nullable_to_non_nullable
              as double,
      fosforo: null == fosforo
          ? _value.fosforo
          : fosforo // ignore: cast_nullable_to_non_nullable
              as FosforoData,
      potassio: null == potassio
          ? _value.potassio
          : potassio // ignore: cast_nullable_to_non_nullable
              as double,
      calcio: null == calcio
          ? _value.calcio
          : calcio // ignore: cast_nullable_to_non_nullable
              as double,
      magnesio: null == magnesio
          ? _value.magnesio
          : magnesio // ignore: cast_nullable_to_non_nullable
              as double,
      ctc: null == ctc
          ? _value.ctc
          : ctc // ignore: cast_nullable_to_non_nullable
              as double,
      saturacaoBases: null == saturacaoBases
          ? _value.saturacaoBases
          : saturacaoBases // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of AnaliseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FosforoDataCopyWith<$Res> get fosforo {
    return $FosforoDataCopyWith<$Res>(_value.fosforo, (value) {
      return _then(_value.copyWith(fosforo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AnaliseModelImplCopyWith<$Res>
    implements $AnaliseModelCopyWith<$Res> {
  factory _$$AnaliseModelImplCopyWith(
          _$AnaliseModelImpl value, $Res Function(_$AnaliseModelImpl) then) =
      __$$AnaliseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String fazendaNome,
      String talhaoNome,
      String dataColeta,
      String status,
      String cultura,
      double ph,
      FosforoData fosforo,
      double potassio,
      double calcio,
      double magnesio,
      double ctc,
      double saturacaoBases,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});

  @override
  $FosforoDataCopyWith<$Res> get fosforo;
}

/// @nodoc
class __$$AnaliseModelImplCopyWithImpl<$Res>
    extends _$AnaliseModelCopyWithImpl<$Res, _$AnaliseModelImpl>
    implements _$$AnaliseModelImplCopyWith<$Res> {
  __$$AnaliseModelImplCopyWithImpl(
      _$AnaliseModelImpl _value, $Res Function(_$AnaliseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnaliseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? fazendaNome = null,
    Object? talhaoNome = null,
    Object? dataColeta = null,
    Object? status = null,
    Object? cultura = null,
    Object? ph = null,
    Object? fosforo = null,
    Object? potassio = null,
    Object? calcio = null,
    Object? magnesio = null,
    Object? ctc = null,
    Object? saturacaoBases = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$AnaliseModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      fazendaNome: null == fazendaNome
          ? _value.fazendaNome
          : fazendaNome // ignore: cast_nullable_to_non_nullable
              as String,
      talhaoNome: null == talhaoNome
          ? _value.talhaoNome
          : talhaoNome // ignore: cast_nullable_to_non_nullable
              as String,
      dataColeta: null == dataColeta
          ? _value.dataColeta
          : dataColeta // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      cultura: null == cultura
          ? _value.cultura
          : cultura // ignore: cast_nullable_to_non_nullable
              as String,
      ph: null == ph
          ? _value.ph
          : ph // ignore: cast_nullable_to_non_nullable
              as double,
      fosforo: null == fosforo
          ? _value.fosforo
          : fosforo // ignore: cast_nullable_to_non_nullable
              as FosforoData,
      potassio: null == potassio
          ? _value.potassio
          : potassio // ignore: cast_nullable_to_non_nullable
              as double,
      calcio: null == calcio
          ? _value.calcio
          : calcio // ignore: cast_nullable_to_non_nullable
              as double,
      magnesio: null == magnesio
          ? _value.magnesio
          : magnesio // ignore: cast_nullable_to_non_nullable
              as double,
      ctc: null == ctc
          ? _value.ctc
          : ctc // ignore: cast_nullable_to_non_nullable
              as double,
      saturacaoBases: null == saturacaoBases
          ? _value.saturacaoBases
          : saturacaoBases // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnaliseModelImpl implements _AnaliseModel {
  const _$AnaliseModelImpl(
      {required this.id,
      required this.userId,
      required this.fazendaNome,
      required this.talhaoNome,
      required this.dataColeta,
      required this.status,
      required this.cultura,
      required this.ph,
      required this.fosforo,
      required this.potassio,
      required this.calcio,
      required this.magnesio,
      required this.ctc,
      required this.saturacaoBases,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.updatedAt});

  factory _$AnaliseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnaliseModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String fazendaNome;
  @override
  final String talhaoNome;
  @override
  final String dataColeta;
  @override
  final String status;
  @override
  final String cultura;
  @override
  final double ph;
  @override
  final FosforoData fosforo;
  @override
  final double potassio;
  @override
  final double calcio;
  @override
  final double magnesio;
  @override
  final double ctc;
  @override
  final double saturacaoBases;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AnaliseModel(id: $id, userId: $userId, fazendaNome: $fazendaNome, talhaoNome: $talhaoNome, dataColeta: $dataColeta, status: $status, cultura: $cultura, ph: $ph, fosforo: $fosforo, potassio: $potassio, calcio: $calcio, magnesio: $magnesio, ctc: $ctc, saturacaoBases: $saturacaoBases, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnaliseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fazendaNome, fazendaNome) ||
                other.fazendaNome == fazendaNome) &&
            (identical(other.talhaoNome, talhaoNome) ||
                other.talhaoNome == talhaoNome) &&
            (identical(other.dataColeta, dataColeta) ||
                other.dataColeta == dataColeta) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.cultura, cultura) || other.cultura == cultura) &&
            (identical(other.ph, ph) || other.ph == ph) &&
            (identical(other.fosforo, fosforo) || other.fosforo == fosforo) &&
            (identical(other.potassio, potassio) ||
                other.potassio == potassio) &&
            (identical(other.calcio, calcio) || other.calcio == calcio) &&
            (identical(other.magnesio, magnesio) ||
                other.magnesio == magnesio) &&
            (identical(other.ctc, ctc) || other.ctc == ctc) &&
            (identical(other.saturacaoBases, saturacaoBases) ||
                other.saturacaoBases == saturacaoBases) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      fazendaNome,
      talhaoNome,
      dataColeta,
      status,
      cultura,
      ph,
      fosforo,
      potassio,
      calcio,
      magnesio,
      ctc,
      saturacaoBases,
      createdAt,
      updatedAt);

  /// Create a copy of AnaliseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnaliseModelImplCopyWith<_$AnaliseModelImpl> get copyWith =>
      __$$AnaliseModelImplCopyWithImpl<_$AnaliseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnaliseModelImplToJson(
      this,
    );
  }
}

abstract class _AnaliseModel implements AnaliseModel {
  const factory _AnaliseModel(
      {required final String id,
      required final String userId,
      required final String fazendaNome,
      required final String talhaoNome,
      required final String dataColeta,
      required final String status,
      required final String cultura,
      required final double ph,
      required final FosforoData fosforo,
      required final double potassio,
      required final double calcio,
      required final double magnesio,
      required final double ctc,
      required final double saturacaoBases,
      @TimestampConverter() final DateTime? createdAt,
      @TimestampConverter() final DateTime? updatedAt}) = _$AnaliseModelImpl;

  factory _AnaliseModel.fromJson(Map<String, dynamic> json) =
      _$AnaliseModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get fazendaNome;
  @override
  String get talhaoNome;
  @override
  String get dataColeta;
  @override
  String get status;
  @override
  String get cultura;
  @override
  double get ph;
  @override
  FosforoData get fosforo;
  @override
  double get potassio;
  @override
  double get calcio;
  @override
  double get magnesio;
  @override
  double get ctc;
  @override
  double get saturacaoBases;
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of AnaliseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnaliseModelImplCopyWith<_$AnaliseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
