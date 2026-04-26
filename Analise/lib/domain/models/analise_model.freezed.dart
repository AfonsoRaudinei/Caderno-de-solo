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
  String? get fazenda => throw _privateConstructorUsedError;
  String? get produtor => throw _privateConstructorUsedError;
  String? get talhao => throw _privateConstructorUsedError;
  String get numeroAmostra => throw _privateConstructorUsedError;
  String get laboratorio => throw _privateConstructorUsedError;
  String get profundidade => throw _privateConstructorUsedError;
  String get dataColeta => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get cultura => throw _privateConstructorUsedError;
  String get safra => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get descricaoLocal => throw _privateConstructorUsedError;
  String? get pdfUrl => throw _privateConstructorUsedError;
  double? get argila => throw _privateConstructorUsedError;
  double? get silte => throw _privateConstructorUsedError;
  double? get areiaTotal => throw _privateConstructorUsedError;
  double? get phAgua => throw _privateConstructorUsedError;
  double? get phSmp => throw _privateConstructorUsedError;
  double? get phCaCl2 => throw _privateConstructorUsedError;
  double? get materiaOrganica => throw _privateConstructorUsedError;
  double? get carbonoOrganico => throw _privateConstructorUsedError;
  double? get pMehlich => throw _privateConstructorUsedError;
  double? get pResina => throw _privateConstructorUsedError;
  double? get pRem => throw _privateConstructorUsedError;
  double? get s020 => throw _privateConstructorUsedError;
  double? get s2040 => throw _privateConstructorUsedError;
  double? get k => throw _privateConstructorUsedError;
  double? get ca => throw _privateConstructorUsedError;
  double? get mg => throw _privateConstructorUsedError;
  double? get al => throw _privateConstructorUsedError;
  double? get hMaisAl => throw _privateConstructorUsedError;
  double? get na => throw _privateConstructorUsedError;
  double? get b => throw _privateConstructorUsedError;
  double? get cu => throw _privateConstructorUsedError;
  double? get fe => throw _privateConstructorUsedError;
  double? get mn => throw _privateConstructorUsedError;
  double? get zn => throw _privateConstructorUsedError;
  double? get ni => throw _privateConstructorUsedError;
  double? get mo => throw _privateConstructorUsedError;
  double? get se => throw _privateConstructorUsedError;
  FonteP get fontePrincipalP => throw _privateConstructorUsedError;
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
      String? fazenda,
      String? produtor,
      String? talhao,
      String numeroAmostra,
      String laboratorio,
      String profundidade,
      String dataColeta,
      String status,
      String cultura,
      String safra,
      double? latitude,
      double? longitude,
      String? descricaoLocal,
      String? pdfUrl,
      double? argila,
      double? silte,
      double? areiaTotal,
      double? phAgua,
      double? phSmp,
      double? phCaCl2,
      double? materiaOrganica,
      double? carbonoOrganico,
      double? pMehlich,
      double? pResina,
      double? pRem,
      double? s020,
      double? s2040,
      double? k,
      double? ca,
      double? mg,
      double? al,
      double? hMaisAl,
      double? na,
      double? b,
      double? cu,
      double? fe,
      double? mn,
      double? zn,
      double? ni,
      double? mo,
      double? se,
      FonteP fontePrincipalP,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
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
    Object? fazenda = freezed,
    Object? produtor = freezed,
    Object? talhao = freezed,
    Object? numeroAmostra = null,
    Object? laboratorio = null,
    Object? profundidade = null,
    Object? dataColeta = null,
    Object? status = null,
    Object? cultura = null,
    Object? safra = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? descricaoLocal = freezed,
    Object? pdfUrl = freezed,
    Object? argila = freezed,
    Object? silte = freezed,
    Object? areiaTotal = freezed,
    Object? phAgua = freezed,
    Object? phSmp = freezed,
    Object? phCaCl2 = freezed,
    Object? materiaOrganica = freezed,
    Object? carbonoOrganico = freezed,
    Object? pMehlich = freezed,
    Object? pResina = freezed,
    Object? pRem = freezed,
    Object? s020 = freezed,
    Object? s2040 = freezed,
    Object? k = freezed,
    Object? ca = freezed,
    Object? mg = freezed,
    Object? al = freezed,
    Object? hMaisAl = freezed,
    Object? na = freezed,
    Object? b = freezed,
    Object? cu = freezed,
    Object? fe = freezed,
    Object? mn = freezed,
    Object? zn = freezed,
    Object? ni = freezed,
    Object? mo = freezed,
    Object? se = freezed,
    Object? fontePrincipalP = null,
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
      fazenda: freezed == fazenda
          ? _value.fazenda
          : fazenda // ignore: cast_nullable_to_non_nullable
              as String?,
      produtor: freezed == produtor
          ? _value.produtor
          : produtor // ignore: cast_nullable_to_non_nullable
              as String?,
      talhao: freezed == talhao
          ? _value.talhao
          : talhao // ignore: cast_nullable_to_non_nullable
              as String?,
      numeroAmostra: null == numeroAmostra
          ? _value.numeroAmostra
          : numeroAmostra // ignore: cast_nullable_to_non_nullable
              as String,
      laboratorio: null == laboratorio
          ? _value.laboratorio
          : laboratorio // ignore: cast_nullable_to_non_nullable
              as String,
      profundidade: null == profundidade
          ? _value.profundidade
          : profundidade // ignore: cast_nullable_to_non_nullable
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
      safra: null == safra
          ? _value.safra
          : safra // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      descricaoLocal: freezed == descricaoLocal
          ? _value.descricaoLocal
          : descricaoLocal // ignore: cast_nullable_to_non_nullable
              as String?,
      pdfUrl: freezed == pdfUrl
          ? _value.pdfUrl
          : pdfUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      argila: freezed == argila
          ? _value.argila
          : argila // ignore: cast_nullable_to_non_nullable
              as double?,
      silte: freezed == silte
          ? _value.silte
          : silte // ignore: cast_nullable_to_non_nullable
              as double?,
      areiaTotal: freezed == areiaTotal
          ? _value.areiaTotal
          : areiaTotal // ignore: cast_nullable_to_non_nullable
              as double?,
      phAgua: freezed == phAgua
          ? _value.phAgua
          : phAgua // ignore: cast_nullable_to_non_nullable
              as double?,
      phSmp: freezed == phSmp
          ? _value.phSmp
          : phSmp // ignore: cast_nullable_to_non_nullable
              as double?,
      phCaCl2: freezed == phCaCl2
          ? _value.phCaCl2
          : phCaCl2 // ignore: cast_nullable_to_non_nullable
              as double?,
      materiaOrganica: freezed == materiaOrganica
          ? _value.materiaOrganica
          : materiaOrganica // ignore: cast_nullable_to_non_nullable
              as double?,
      carbonoOrganico: freezed == carbonoOrganico
          ? _value.carbonoOrganico
          : carbonoOrganico // ignore: cast_nullable_to_non_nullable
              as double?,
      pMehlich: freezed == pMehlich
          ? _value.pMehlich
          : pMehlich // ignore: cast_nullable_to_non_nullable
              as double?,
      pResina: freezed == pResina
          ? _value.pResina
          : pResina // ignore: cast_nullable_to_non_nullable
              as double?,
      pRem: freezed == pRem
          ? _value.pRem
          : pRem // ignore: cast_nullable_to_non_nullable
              as double?,
      s020: freezed == s020
          ? _value.s020
          : s020 // ignore: cast_nullable_to_non_nullable
              as double?,
      s2040: freezed == s2040
          ? _value.s2040
          : s2040 // ignore: cast_nullable_to_non_nullable
              as double?,
      k: freezed == k
          ? _value.k
          : k // ignore: cast_nullable_to_non_nullable
              as double?,
      ca: freezed == ca
          ? _value.ca
          : ca // ignore: cast_nullable_to_non_nullable
              as double?,
      mg: freezed == mg
          ? _value.mg
          : mg // ignore: cast_nullable_to_non_nullable
              as double?,
      al: freezed == al
          ? _value.al
          : al // ignore: cast_nullable_to_non_nullable
              as double?,
      hMaisAl: freezed == hMaisAl
          ? _value.hMaisAl
          : hMaisAl // ignore: cast_nullable_to_non_nullable
              as double?,
      na: freezed == na
          ? _value.na
          : na // ignore: cast_nullable_to_non_nullable
              as double?,
      b: freezed == b
          ? _value.b
          : b // ignore: cast_nullable_to_non_nullable
              as double?,
      cu: freezed == cu
          ? _value.cu
          : cu // ignore: cast_nullable_to_non_nullable
              as double?,
      fe: freezed == fe
          ? _value.fe
          : fe // ignore: cast_nullable_to_non_nullable
              as double?,
      mn: freezed == mn
          ? _value.mn
          : mn // ignore: cast_nullable_to_non_nullable
              as double?,
      zn: freezed == zn
          ? _value.zn
          : zn // ignore: cast_nullable_to_non_nullable
              as double?,
      ni: freezed == ni
          ? _value.ni
          : ni // ignore: cast_nullable_to_non_nullable
              as double?,
      mo: freezed == mo
          ? _value.mo
          : mo // ignore: cast_nullable_to_non_nullable
              as double?,
      se: freezed == se
          ? _value.se
          : se // ignore: cast_nullable_to_non_nullable
              as double?,
      fontePrincipalP: null == fontePrincipalP
          ? _value.fontePrincipalP
          : fontePrincipalP // ignore: cast_nullable_to_non_nullable
              as FonteP,
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
      String? fazenda,
      String? produtor,
      String? talhao,
      String numeroAmostra,
      String laboratorio,
      String profundidade,
      String dataColeta,
      String status,
      String cultura,
      String safra,
      double? latitude,
      double? longitude,
      String? descricaoLocal,
      String? pdfUrl,
      double? argila,
      double? silte,
      double? areiaTotal,
      double? phAgua,
      double? phSmp,
      double? phCaCl2,
      double? materiaOrganica,
      double? carbonoOrganico,
      double? pMehlich,
      double? pResina,
      double? pRem,
      double? s020,
      double? s2040,
      double? k,
      double? ca,
      double? mg,
      double? al,
      double? hMaisAl,
      double? na,
      double? b,
      double? cu,
      double? fe,
      double? mn,
      double? zn,
      double? ni,
      double? mo,
      double? se,
      FonteP fontePrincipalP,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
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
    Object? fazenda = freezed,
    Object? produtor = freezed,
    Object? talhao = freezed,
    Object? numeroAmostra = null,
    Object? laboratorio = null,
    Object? profundidade = null,
    Object? dataColeta = null,
    Object? status = null,
    Object? cultura = null,
    Object? safra = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? descricaoLocal = freezed,
    Object? pdfUrl = freezed,
    Object? argila = freezed,
    Object? silte = freezed,
    Object? areiaTotal = freezed,
    Object? phAgua = freezed,
    Object? phSmp = freezed,
    Object? phCaCl2 = freezed,
    Object? materiaOrganica = freezed,
    Object? carbonoOrganico = freezed,
    Object? pMehlich = freezed,
    Object? pResina = freezed,
    Object? pRem = freezed,
    Object? s020 = freezed,
    Object? s2040 = freezed,
    Object? k = freezed,
    Object? ca = freezed,
    Object? mg = freezed,
    Object? al = freezed,
    Object? hMaisAl = freezed,
    Object? na = freezed,
    Object? b = freezed,
    Object? cu = freezed,
    Object? fe = freezed,
    Object? mn = freezed,
    Object? zn = freezed,
    Object? ni = freezed,
    Object? mo = freezed,
    Object? se = freezed,
    Object? fontePrincipalP = null,
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
      fazenda: freezed == fazenda
          ? _value.fazenda
          : fazenda // ignore: cast_nullable_to_non_nullable
              as String?,
      produtor: freezed == produtor
          ? _value.produtor
          : produtor // ignore: cast_nullable_to_non_nullable
              as String?,
      talhao: freezed == talhao
          ? _value.talhao
          : talhao // ignore: cast_nullable_to_non_nullable
              as String?,
      numeroAmostra: null == numeroAmostra
          ? _value.numeroAmostra
          : numeroAmostra // ignore: cast_nullable_to_non_nullable
              as String,
      laboratorio: null == laboratorio
          ? _value.laboratorio
          : laboratorio // ignore: cast_nullable_to_non_nullable
              as String,
      profundidade: null == profundidade
          ? _value.profundidade
          : profundidade // ignore: cast_nullable_to_non_nullable
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
      safra: null == safra
          ? _value.safra
          : safra // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      descricaoLocal: freezed == descricaoLocal
          ? _value.descricaoLocal
          : descricaoLocal // ignore: cast_nullable_to_non_nullable
              as String?,
      pdfUrl: freezed == pdfUrl
          ? _value.pdfUrl
          : pdfUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      argila: freezed == argila
          ? _value.argila
          : argila // ignore: cast_nullable_to_non_nullable
              as double?,
      silte: freezed == silte
          ? _value.silte
          : silte // ignore: cast_nullable_to_non_nullable
              as double?,
      areiaTotal: freezed == areiaTotal
          ? _value.areiaTotal
          : areiaTotal // ignore: cast_nullable_to_non_nullable
              as double?,
      phAgua: freezed == phAgua
          ? _value.phAgua
          : phAgua // ignore: cast_nullable_to_non_nullable
              as double?,
      phSmp: freezed == phSmp
          ? _value.phSmp
          : phSmp // ignore: cast_nullable_to_non_nullable
              as double?,
      phCaCl2: freezed == phCaCl2
          ? _value.phCaCl2
          : phCaCl2 // ignore: cast_nullable_to_non_nullable
              as double?,
      materiaOrganica: freezed == materiaOrganica
          ? _value.materiaOrganica
          : materiaOrganica // ignore: cast_nullable_to_non_nullable
              as double?,
      carbonoOrganico: freezed == carbonoOrganico
          ? _value.carbonoOrganico
          : carbonoOrganico // ignore: cast_nullable_to_non_nullable
              as double?,
      pMehlich: freezed == pMehlich
          ? _value.pMehlich
          : pMehlich // ignore: cast_nullable_to_non_nullable
              as double?,
      pResina: freezed == pResina
          ? _value.pResina
          : pResina // ignore: cast_nullable_to_non_nullable
              as double?,
      pRem: freezed == pRem
          ? _value.pRem
          : pRem // ignore: cast_nullable_to_non_nullable
              as double?,
      s020: freezed == s020
          ? _value.s020
          : s020 // ignore: cast_nullable_to_non_nullable
              as double?,
      s2040: freezed == s2040
          ? _value.s2040
          : s2040 // ignore: cast_nullable_to_non_nullable
              as double?,
      k: freezed == k
          ? _value.k
          : k // ignore: cast_nullable_to_non_nullable
              as double?,
      ca: freezed == ca
          ? _value.ca
          : ca // ignore: cast_nullable_to_non_nullable
              as double?,
      mg: freezed == mg
          ? _value.mg
          : mg // ignore: cast_nullable_to_non_nullable
              as double?,
      al: freezed == al
          ? _value.al
          : al // ignore: cast_nullable_to_non_nullable
              as double?,
      hMaisAl: freezed == hMaisAl
          ? _value.hMaisAl
          : hMaisAl // ignore: cast_nullable_to_non_nullable
              as double?,
      na: freezed == na
          ? _value.na
          : na // ignore: cast_nullable_to_non_nullable
              as double?,
      b: freezed == b
          ? _value.b
          : b // ignore: cast_nullable_to_non_nullable
              as double?,
      cu: freezed == cu
          ? _value.cu
          : cu // ignore: cast_nullable_to_non_nullable
              as double?,
      fe: freezed == fe
          ? _value.fe
          : fe // ignore: cast_nullable_to_non_nullable
              as double?,
      mn: freezed == mn
          ? _value.mn
          : mn // ignore: cast_nullable_to_non_nullable
              as double?,
      zn: freezed == zn
          ? _value.zn
          : zn // ignore: cast_nullable_to_non_nullable
              as double?,
      ni: freezed == ni
          ? _value.ni
          : ni // ignore: cast_nullable_to_non_nullable
              as double?,
      mo: freezed == mo
          ? _value.mo
          : mo // ignore: cast_nullable_to_non_nullable
              as double?,
      se: freezed == se
          ? _value.se
          : se // ignore: cast_nullable_to_non_nullable
              as double?,
      fontePrincipalP: null == fontePrincipalP
          ? _value.fontePrincipalP
          : fontePrincipalP // ignore: cast_nullable_to_non_nullable
              as FonteP,
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
class _$AnaliseModelImpl extends _AnaliseModel {
  const _$AnaliseModelImpl(
      {required this.id,
      required this.userId,
      this.fazenda,
      this.produtor,
      this.talhao,
      this.numeroAmostra = '',
      this.laboratorio = '',
      this.profundidade = '',
      this.dataColeta = '',
      this.status = '',
      this.cultura = '',
      this.safra = '',
      this.latitude,
      this.longitude,
      this.descricaoLocal,
      this.pdfUrl,
      this.argila,
      this.silte,
      this.areiaTotal,
      this.phAgua,
      this.phSmp,
      this.phCaCl2,
      this.materiaOrganica,
      this.carbonoOrganico,
      this.pMehlich,
      this.pResina,
      this.pRem,
      this.s020,
      this.s2040,
      this.k,
      this.ca,
      this.mg,
      this.al,
      this.hMaisAl,
      this.na,
      this.b,
      this.cu,
      this.fe,
      this.mn,
      this.zn,
      this.ni,
      this.mo,
      this.se,
      this.fontePrincipalP = FonteP.mehlich,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.updatedAt})
      : super._();

  factory _$AnaliseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnaliseModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? fazenda;
  @override
  final String? produtor;
  @override
  final String? talhao;
  @override
  @JsonKey()
  final String numeroAmostra;
  @override
  @JsonKey()
  final String laboratorio;
  @override
  @JsonKey()
  final String profundidade;
  @override
  @JsonKey()
  final String dataColeta;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String cultura;
  @override
  @JsonKey()
  final String safra;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? descricaoLocal;
  @override
  final String? pdfUrl;
  @override
  final double? argila;
  @override
  final double? silte;
  @override
  final double? areiaTotal;
  @override
  final double? phAgua;
  @override
  final double? phSmp;
  @override
  final double? phCaCl2;
  @override
  final double? materiaOrganica;
  @override
  final double? carbonoOrganico;
  @override
  final double? pMehlich;
  @override
  final double? pResina;
  @override
  final double? pRem;
  @override
  final double? s020;
  @override
  final double? s2040;
  @override
  final double? k;
  @override
  final double? ca;
  @override
  final double? mg;
  @override
  final double? al;
  @override
  final double? hMaisAl;
  @override
  final double? na;
  @override
  final double? b;
  @override
  final double? cu;
  @override
  final double? fe;
  @override
  final double? mn;
  @override
  final double? zn;
  @override
  final double? ni;
  @override
  final double? mo;
  @override
  final double? se;
  @override
  @JsonKey()
  final FonteP fontePrincipalP;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AnaliseModel(id: $id, userId: $userId, fazenda: $fazenda, produtor: $produtor, talhao: $talhao, numeroAmostra: $numeroAmostra, laboratorio: $laboratorio, profundidade: $profundidade, dataColeta: $dataColeta, status: $status, cultura: $cultura, safra: $safra, latitude: $latitude, longitude: $longitude, descricaoLocal: $descricaoLocal, pdfUrl: $pdfUrl, argila: $argila, silte: $silte, areiaTotal: $areiaTotal, phAgua: $phAgua, phSmp: $phSmp, phCaCl2: $phCaCl2, materiaOrganica: $materiaOrganica, carbonoOrganico: $carbonoOrganico, pMehlich: $pMehlich, pResina: $pResina, pRem: $pRem, s020: $s020, s2040: $s2040, k: $k, ca: $ca, mg: $mg, al: $al, hMaisAl: $hMaisAl, na: $na, b: $b, cu: $cu, fe: $fe, mn: $mn, zn: $zn, ni: $ni, mo: $mo, se: $se, fontePrincipalP: $fontePrincipalP, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnaliseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fazenda, fazenda) || other.fazenda == fazenda) &&
            (identical(other.produtor, produtor) ||
                other.produtor == produtor) &&
            (identical(other.talhao, talhao) || other.talhao == talhao) &&
            (identical(other.numeroAmostra, numeroAmostra) ||
                other.numeroAmostra == numeroAmostra) &&
            (identical(other.laboratorio, laboratorio) ||
                other.laboratorio == laboratorio) &&
            (identical(other.profundidade, profundidade) ||
                other.profundidade == profundidade) &&
            (identical(other.dataColeta, dataColeta) ||
                other.dataColeta == dataColeta) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.cultura, cultura) || other.cultura == cultura) &&
            (identical(other.safra, safra) || other.safra == safra) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.descricaoLocal, descricaoLocal) ||
                other.descricaoLocal == descricaoLocal) &&
            (identical(other.pdfUrl, pdfUrl) || other.pdfUrl == pdfUrl) &&
            (identical(other.argila, argila) || other.argila == argila) &&
            (identical(other.silte, silte) || other.silte == silte) &&
            (identical(other.areiaTotal, areiaTotal) ||
                other.areiaTotal == areiaTotal) &&
            (identical(other.phAgua, phAgua) || other.phAgua == phAgua) &&
            (identical(other.phSmp, phSmp) || other.phSmp == phSmp) &&
            (identical(other.phCaCl2, phCaCl2) || other.phCaCl2 == phCaCl2) &&
            (identical(other.materiaOrganica, materiaOrganica) ||
                other.materiaOrganica == materiaOrganica) &&
            (identical(other.carbonoOrganico, carbonoOrganico) ||
                other.carbonoOrganico == carbonoOrganico) &&
            (identical(other.pMehlich, pMehlich) ||
                other.pMehlich == pMehlich) &&
            (identical(other.pResina, pResina) || other.pResina == pResina) &&
            (identical(other.pRem, pRem) || other.pRem == pRem) &&
            (identical(other.s020, s020) || other.s020 == s020) &&
            (identical(other.s2040, s2040) || other.s2040 == s2040) &&
            (identical(other.k, k) || other.k == k) &&
            (identical(other.ca, ca) || other.ca == ca) &&
            (identical(other.mg, mg) || other.mg == mg) &&
            (identical(other.al, al) || other.al == al) &&
            (identical(other.hMaisAl, hMaisAl) || other.hMaisAl == hMaisAl) &&
            (identical(other.na, na) || other.na == na) &&
            (identical(other.b, b) || other.b == b) &&
            (identical(other.cu, cu) || other.cu == cu) &&
            (identical(other.fe, fe) || other.fe == fe) &&
            (identical(other.mn, mn) || other.mn == mn) &&
            (identical(other.zn, zn) || other.zn == zn) &&
            (identical(other.ni, ni) || other.ni == ni) &&
            (identical(other.mo, mo) || other.mo == mo) &&
            (identical(other.se, se) || other.se == se) &&
            (identical(other.fontePrincipalP, fontePrincipalP) ||
                other.fontePrincipalP == fontePrincipalP) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        fazenda,
        produtor,
        talhao,
        numeroAmostra,
        laboratorio,
        profundidade,
        dataColeta,
        status,
        cultura,
        safra,
        latitude,
        longitude,
        descricaoLocal,
        pdfUrl,
        argila,
        silte,
        areiaTotal,
        phAgua,
        phSmp,
        phCaCl2,
        materiaOrganica,
        carbonoOrganico,
        pMehlich,
        pResina,
        pRem,
        s020,
        s2040,
        k,
        ca,
        mg,
        al,
        hMaisAl,
        na,
        b,
        cu,
        fe,
        mn,
        zn,
        ni,
        mo,
        se,
        fontePrincipalP,
        createdAt,
        updatedAt
      ]);

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

abstract class _AnaliseModel extends AnaliseModel {
  const factory _AnaliseModel(
      {required final String id,
      required final String userId,
      final String? fazenda,
      final String? produtor,
      final String? talhao,
      final String numeroAmostra,
      final String laboratorio,
      final String profundidade,
      final String dataColeta,
      final String status,
      final String cultura,
      final String safra,
      final double? latitude,
      final double? longitude,
      final String? descricaoLocal,
      final String? pdfUrl,
      final double? argila,
      final double? silte,
      final double? areiaTotal,
      final double? phAgua,
      final double? phSmp,
      final double? phCaCl2,
      final double? materiaOrganica,
      final double? carbonoOrganico,
      final double? pMehlich,
      final double? pResina,
      final double? pRem,
      final double? s020,
      final double? s2040,
      final double? k,
      final double? ca,
      final double? mg,
      final double? al,
      final double? hMaisAl,
      final double? na,
      final double? b,
      final double? cu,
      final double? fe,
      final double? mn,
      final double? zn,
      final double? ni,
      final double? mo,
      final double? se,
      final FonteP fontePrincipalP,
      @TimestampConverter() final DateTime? createdAt,
      @TimestampConverter() final DateTime? updatedAt}) = _$AnaliseModelImpl;
  const _AnaliseModel._() : super._();

  factory _AnaliseModel.fromJson(Map<String, dynamic> json) =
      _$AnaliseModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String? get fazenda;
  @override
  String? get produtor;
  @override
  String? get talhao;
  @override
  String get numeroAmostra;
  @override
  String get laboratorio;
  @override
  String get profundidade;
  @override
  String get dataColeta;
  @override
  String get status;
  @override
  String get cultura;
  @override
  String get safra;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get descricaoLocal;
  @override
  String? get pdfUrl;
  @override
  double? get argila;
  @override
  double? get silte;
  @override
  double? get areiaTotal;
  @override
  double? get phAgua;
  @override
  double? get phSmp;
  @override
  double? get phCaCl2;
  @override
  double? get materiaOrganica;
  @override
  double? get carbonoOrganico;
  @override
  double? get pMehlich;
  @override
  double? get pResina;
  @override
  double? get pRem;
  @override
  double? get s020;
  @override
  double? get s2040;
  @override
  double? get k;
  @override
  double? get ca;
  @override
  double? get mg;
  @override
  double? get al;
  @override
  double? get hMaisAl;
  @override
  double? get na;
  @override
  double? get b;
  @override
  double? get cu;
  @override
  double? get fe;
  @override
  double? get mn;
  @override
  double? get zn;
  @override
  double? get ni;
  @override
  double? get mo;
  @override
  double? get se;
  @override
  FonteP get fontePrincipalP;
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
