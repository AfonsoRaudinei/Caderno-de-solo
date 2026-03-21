// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analise_solo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AnaliseSolo _$AnaliseSoloFromJson(Map<String, dynamic> json) {
  return _AnaliseSolo.fromJson(json);
}

/// @nodoc
mixin _$AnaliseSolo {
  String get id =>
      throw _privateConstructorUsedError; // ─── Identificação ───────────────────────────────────────
  String get clienteNome => throw _privateConstructorUsedError;
  String get fazendaNome => throw _privateConstructorUsedError;
  String get talhaoNome => throw _privateConstructorUsedError;
  String get cultura => throw _privateConstructorUsedError;
  String get laboratorio => throw _privateConstructorUsedError;
  String? get data =>
      throw _privateConstructorUsedError; // ─── pH ──────────────────────────────────────────────────
  /// pH em CaCl₂ 0,01 mol/L
  double get pH => throw _privateConstructorUsedError;

  /// pH em água
  double get phAgua => throw _privateConstructorUsedError;

  /// pH tampão SMP (para calcular H+Al)
  double get phSmp =>
      throw _privateConstructorUsedError; // ─── Matéria Orgânica ─────────────────────────────────────
  /// MO em g/dm³
  double get MO =>
      throw _privateConstructorUsedError; // ─── Macronutrientes (cmolc/dm³) ─────────────────────────
  /// Cálcio trocável (cmolc/dm³)
  double get Ca => throw _privateConstructorUsedError;

  /// Magnésio trocável (cmolc/dm³)
  double get Mg => throw _privateConstructorUsedError;

  /// Potássio trocável (cmolc/dm³ — converter de mg/dm³ se necessário)
  double get K => throw _privateConstructorUsedError;

  /// Acidez potencial H+Al (cmolc/dm³)
  double get HAl => throw _privateConstructorUsedError;

  /// Alumínio trocável (cmolc/dm³)
  double get Al =>
      throw _privateConstructorUsedError; // ─── Fósforo e P-rem ─────────────────────────────────────
  /// Fósforo disponível (mg/dm³)
  double get P => throw _privateConstructorUsedError;

  /// Fósforo remanescente (P-rem) em mg/L — para calcular Y
  double? get Prem => throw _privateConstructorUsedError;

  /// Extrator de fósforo utilizado
  String get extrator =>
      throw _privateConstructorUsedError; // ─── Textura ──────────────────────────────────────────────
  /// Argila em % (0–100)
  double get argila =>
      throw _privateConstructorUsedError; // ─── Enxofre (mg/dm³) ────────────────────────────────────
  double get S =>
      throw _privateConstructorUsedError; // ─── Micronutrientes (mg/dm³) ────────────────────────────
  double get B => throw _privateConstructorUsedError;
  double get Cu => throw _privateConstructorUsedError;
  double get Fe => throw _privateConstructorUsedError;
  double get Mn => throw _privateConstructorUsedError;
  double get Zn =>
      throw _privateConstructorUsedError; // ─── Geolocalização ──────────────────────────────────────
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String get endereco =>
      throw _privateConstructorUsedError; // ─── Calculados automaticamente ───────────────────────────
// Nota: SB, CTC, Vat, mat calculados pelo motor dinamicamente.
// Podem ser cacheados aqui após o cálculo.
  double get SB =>
      throw _privateConstructorUsedError; // Soma de Bases = Ca + Mg + K
  double get CTC =>
      throw _privateConstructorUsedError; // Capacidade de Troca = SB + H+Al
  double get Vat =>
      throw _privateConstructorUsedError; // Saturação por bases V% = SB/CTC × 100
  double get mat =>
      throw _privateConstructorUsedError; // Saturação por Al m% = Al/(SB+Al) × 100
  double get Y => throw _privateConstructorUsedError;

  /// Serializes this AnaliseSolo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnaliseSolo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnaliseSoloCopyWith<AnaliseSolo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnaliseSoloCopyWith<$Res> {
  factory $AnaliseSoloCopyWith(
          AnaliseSolo value, $Res Function(AnaliseSolo) then) =
      _$AnaliseSoloCopyWithImpl<$Res, AnaliseSolo>;
  @useResult
  $Res call(
      {String id,
      String clienteNome,
      String fazendaNome,
      String talhaoNome,
      String cultura,
      String laboratorio,
      String? data,
      double pH,
      double phAgua,
      double phSmp,
      double MO,
      double Ca,
      double Mg,
      double K,
      double HAl,
      double Al,
      double P,
      double? Prem,
      String extrator,
      double argila,
      double S,
      double B,
      double Cu,
      double Fe,
      double Mn,
      double Zn,
      double latitude,
      double longitude,
      String endereco,
      double SB,
      double CTC,
      double Vat,
      double mat,
      double Y});
}

/// @nodoc
class _$AnaliseSoloCopyWithImpl<$Res, $Val extends AnaliseSolo>
    implements $AnaliseSoloCopyWith<$Res> {
  _$AnaliseSoloCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnaliseSolo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clienteNome = null,
    Object? fazendaNome = null,
    Object? talhaoNome = null,
    Object? cultura = null,
    Object? laboratorio = null,
    Object? data = freezed,
    Object? pH = null,
    Object? phAgua = null,
    Object? phSmp = null,
    Object? MO = null,
    Object? Ca = null,
    Object? Mg = null,
    Object? K = null,
    Object? HAl = null,
    Object? Al = null,
    Object? P = null,
    Object? Prem = freezed,
    Object? extrator = null,
    Object? argila = null,
    Object? S = null,
    Object? B = null,
    Object? Cu = null,
    Object? Fe = null,
    Object? Mn = null,
    Object? Zn = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? endereco = null,
    Object? SB = null,
    Object? CTC = null,
    Object? Vat = null,
    Object? mat = null,
    Object? Y = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      clienteNome: null == clienteNome
          ? _value.clienteNome
          : clienteNome // ignore: cast_nullable_to_non_nullable
              as String,
      fazendaNome: null == fazendaNome
          ? _value.fazendaNome
          : fazendaNome // ignore: cast_nullable_to_non_nullable
              as String,
      talhaoNome: null == talhaoNome
          ? _value.talhaoNome
          : talhaoNome // ignore: cast_nullable_to_non_nullable
              as String,
      cultura: null == cultura
          ? _value.cultura
          : cultura // ignore: cast_nullable_to_non_nullable
              as String,
      laboratorio: null == laboratorio
          ? _value.laboratorio
          : laboratorio // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as String?,
      pH: null == pH
          ? _value.pH
          : pH // ignore: cast_nullable_to_non_nullable
              as double,
      phAgua: null == phAgua
          ? _value.phAgua
          : phAgua // ignore: cast_nullable_to_non_nullable
              as double,
      phSmp: null == phSmp
          ? _value.phSmp
          : phSmp // ignore: cast_nullable_to_non_nullable
              as double,
      MO: null == MO
          ? _value.MO
          : MO // ignore: cast_nullable_to_non_nullable
              as double,
      Ca: null == Ca
          ? _value.Ca
          : Ca // ignore: cast_nullable_to_non_nullable
              as double,
      Mg: null == Mg
          ? _value.Mg
          : Mg // ignore: cast_nullable_to_non_nullable
              as double,
      K: null == K
          ? _value.K
          : K // ignore: cast_nullable_to_non_nullable
              as double,
      HAl: null == HAl
          ? _value.HAl
          : HAl // ignore: cast_nullable_to_non_nullable
              as double,
      Al: null == Al
          ? _value.Al
          : Al // ignore: cast_nullable_to_non_nullable
              as double,
      P: null == P
          ? _value.P
          : P // ignore: cast_nullable_to_non_nullable
              as double,
      Prem: freezed == Prem
          ? _value.Prem
          : Prem // ignore: cast_nullable_to_non_nullable
              as double?,
      extrator: null == extrator
          ? _value.extrator
          : extrator // ignore: cast_nullable_to_non_nullable
              as String,
      argila: null == argila
          ? _value.argila
          : argila // ignore: cast_nullable_to_non_nullable
              as double,
      S: null == S
          ? _value.S
          : S // ignore: cast_nullable_to_non_nullable
              as double,
      B: null == B
          ? _value.B
          : B // ignore: cast_nullable_to_non_nullable
              as double,
      Cu: null == Cu
          ? _value.Cu
          : Cu // ignore: cast_nullable_to_non_nullable
              as double,
      Fe: null == Fe
          ? _value.Fe
          : Fe // ignore: cast_nullable_to_non_nullable
              as double,
      Mn: null == Mn
          ? _value.Mn
          : Mn // ignore: cast_nullable_to_non_nullable
              as double,
      Zn: null == Zn
          ? _value.Zn
          : Zn // ignore: cast_nullable_to_non_nullable
              as double,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      endereco: null == endereco
          ? _value.endereco
          : endereco // ignore: cast_nullable_to_non_nullable
              as String,
      SB: null == SB
          ? _value.SB
          : SB // ignore: cast_nullable_to_non_nullable
              as double,
      CTC: null == CTC
          ? _value.CTC
          : CTC // ignore: cast_nullable_to_non_nullable
              as double,
      Vat: null == Vat
          ? _value.Vat
          : Vat // ignore: cast_nullable_to_non_nullable
              as double,
      mat: null == mat
          ? _value.mat
          : mat // ignore: cast_nullable_to_non_nullable
              as double,
      Y: null == Y
          ? _value.Y
          : Y // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnaliseSoloImplCopyWith<$Res>
    implements $AnaliseSoloCopyWith<$Res> {
  factory _$$AnaliseSoloImplCopyWith(
          _$AnaliseSoloImpl value, $Res Function(_$AnaliseSoloImpl) then) =
      __$$AnaliseSoloImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String clienteNome,
      String fazendaNome,
      String talhaoNome,
      String cultura,
      String laboratorio,
      String? data,
      double pH,
      double phAgua,
      double phSmp,
      double MO,
      double Ca,
      double Mg,
      double K,
      double HAl,
      double Al,
      double P,
      double? Prem,
      String extrator,
      double argila,
      double S,
      double B,
      double Cu,
      double Fe,
      double Mn,
      double Zn,
      double latitude,
      double longitude,
      String endereco,
      double SB,
      double CTC,
      double Vat,
      double mat,
      double Y});
}

/// @nodoc
class __$$AnaliseSoloImplCopyWithImpl<$Res>
    extends _$AnaliseSoloCopyWithImpl<$Res, _$AnaliseSoloImpl>
    implements _$$AnaliseSoloImplCopyWith<$Res> {
  __$$AnaliseSoloImplCopyWithImpl(
      _$AnaliseSoloImpl _value, $Res Function(_$AnaliseSoloImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnaliseSolo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clienteNome = null,
    Object? fazendaNome = null,
    Object? talhaoNome = null,
    Object? cultura = null,
    Object? laboratorio = null,
    Object? data = freezed,
    Object? pH = null,
    Object? phAgua = null,
    Object? phSmp = null,
    Object? MO = null,
    Object? Ca = null,
    Object? Mg = null,
    Object? K = null,
    Object? HAl = null,
    Object? Al = null,
    Object? P = null,
    Object? Prem = freezed,
    Object? extrator = null,
    Object? argila = null,
    Object? S = null,
    Object? B = null,
    Object? Cu = null,
    Object? Fe = null,
    Object? Mn = null,
    Object? Zn = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? endereco = null,
    Object? SB = null,
    Object? CTC = null,
    Object? Vat = null,
    Object? mat = null,
    Object? Y = null,
  }) {
    return _then(_$AnaliseSoloImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      clienteNome: null == clienteNome
          ? _value.clienteNome
          : clienteNome // ignore: cast_nullable_to_non_nullable
              as String,
      fazendaNome: null == fazendaNome
          ? _value.fazendaNome
          : fazendaNome // ignore: cast_nullable_to_non_nullable
              as String,
      talhaoNome: null == talhaoNome
          ? _value.talhaoNome
          : talhaoNome // ignore: cast_nullable_to_non_nullable
              as String,
      cultura: null == cultura
          ? _value.cultura
          : cultura // ignore: cast_nullable_to_non_nullable
              as String,
      laboratorio: null == laboratorio
          ? _value.laboratorio
          : laboratorio // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as String?,
      pH: null == pH
          ? _value.pH
          : pH // ignore: cast_nullable_to_non_nullable
              as double,
      phAgua: null == phAgua
          ? _value.phAgua
          : phAgua // ignore: cast_nullable_to_non_nullable
              as double,
      phSmp: null == phSmp
          ? _value.phSmp
          : phSmp // ignore: cast_nullable_to_non_nullable
              as double,
      MO: null == MO
          ? _value.MO
          : MO // ignore: cast_nullable_to_non_nullable
              as double,
      Ca: null == Ca
          ? _value.Ca
          : Ca // ignore: cast_nullable_to_non_nullable
              as double,
      Mg: null == Mg
          ? _value.Mg
          : Mg // ignore: cast_nullable_to_non_nullable
              as double,
      K: null == K
          ? _value.K
          : K // ignore: cast_nullable_to_non_nullable
              as double,
      HAl: null == HAl
          ? _value.HAl
          : HAl // ignore: cast_nullable_to_non_nullable
              as double,
      Al: null == Al
          ? _value.Al
          : Al // ignore: cast_nullable_to_non_nullable
              as double,
      P: null == P
          ? _value.P
          : P // ignore: cast_nullable_to_non_nullable
              as double,
      Prem: freezed == Prem
          ? _value.Prem
          : Prem // ignore: cast_nullable_to_non_nullable
              as double?,
      extrator: null == extrator
          ? _value.extrator
          : extrator // ignore: cast_nullable_to_non_nullable
              as String,
      argila: null == argila
          ? _value.argila
          : argila // ignore: cast_nullable_to_non_nullable
              as double,
      S: null == S
          ? _value.S
          : S // ignore: cast_nullable_to_non_nullable
              as double,
      B: null == B
          ? _value.B
          : B // ignore: cast_nullable_to_non_nullable
              as double,
      Cu: null == Cu
          ? _value.Cu
          : Cu // ignore: cast_nullable_to_non_nullable
              as double,
      Fe: null == Fe
          ? _value.Fe
          : Fe // ignore: cast_nullable_to_non_nullable
              as double,
      Mn: null == Mn
          ? _value.Mn
          : Mn // ignore: cast_nullable_to_non_nullable
              as double,
      Zn: null == Zn
          ? _value.Zn
          : Zn // ignore: cast_nullable_to_non_nullable
              as double,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      endereco: null == endereco
          ? _value.endereco
          : endereco // ignore: cast_nullable_to_non_nullable
              as String,
      SB: null == SB
          ? _value.SB
          : SB // ignore: cast_nullable_to_non_nullable
              as double,
      CTC: null == CTC
          ? _value.CTC
          : CTC // ignore: cast_nullable_to_non_nullable
              as double,
      Vat: null == Vat
          ? _value.Vat
          : Vat // ignore: cast_nullable_to_non_nullable
              as double,
      mat: null == mat
          ? _value.mat
          : mat // ignore: cast_nullable_to_non_nullable
              as double,
      Y: null == Y
          ? _value.Y
          : Y // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnaliseSoloImpl implements _AnaliseSolo {
  const _$AnaliseSoloImpl(
      {required this.id,
      this.clienteNome = '',
      this.fazendaNome = '',
      this.talhaoNome = '',
      this.cultura = '',
      this.laboratorio = '',
      this.data,
      this.pH = 0.0,
      this.phAgua = 0.0,
      this.phSmp = 0.0,
      this.MO = 0.0,
      this.Ca = 0.0,
      this.Mg = 0.0,
      this.K = 0.0,
      this.HAl = 0.0,
      this.Al = 0.0,
      this.P = 0.0,
      this.Prem,
      this.extrator = 'Resina',
      this.argila = 0.0,
      this.S = 0.0,
      this.B = 0.0,
      this.Cu = 0.0,
      this.Fe = 0.0,
      this.Mn = 0.0,
      this.Zn = 0.0,
      this.latitude = 0.0,
      this.longitude = 0.0,
      this.endereco = '',
      this.SB = 0.0,
      this.CTC = 0.0,
      this.Vat = 0.0,
      this.mat = 0.0,
      this.Y = 0.0});

  factory _$AnaliseSoloImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnaliseSoloImplFromJson(json);

  @override
  final String id;
// ─── Identificação ───────────────────────────────────────
  @override
  @JsonKey()
  final String clienteNome;
  @override
  @JsonKey()
  final String fazendaNome;
  @override
  @JsonKey()
  final String talhaoNome;
  @override
  @JsonKey()
  final String cultura;
  @override
  @JsonKey()
  final String laboratorio;
  @override
  final String? data;
// ─── pH ──────────────────────────────────────────────────
  /// pH em CaCl₂ 0,01 mol/L
  @override
  @JsonKey()
  final double pH;

  /// pH em água
  @override
  @JsonKey()
  final double phAgua;

  /// pH tampão SMP (para calcular H+Al)
  @override
  @JsonKey()
  final double phSmp;
// ─── Matéria Orgânica ─────────────────────────────────────
  /// MO em g/dm³
  @override
  @JsonKey()
  final double MO;
// ─── Macronutrientes (cmolc/dm³) ─────────────────────────
  /// Cálcio trocável (cmolc/dm³)
  @override
  @JsonKey()
  final double Ca;

  /// Magnésio trocável (cmolc/dm³)
  @override
  @JsonKey()
  final double Mg;

  /// Potássio trocável (cmolc/dm³ — converter de mg/dm³ se necessário)
  @override
  @JsonKey()
  final double K;

  /// Acidez potencial H+Al (cmolc/dm³)
  @override
  @JsonKey()
  final double HAl;

  /// Alumínio trocável (cmolc/dm³)
  @override
  @JsonKey()
  final double Al;
// ─── Fósforo e P-rem ─────────────────────────────────────
  /// Fósforo disponível (mg/dm³)
  @override
  @JsonKey()
  final double P;

  /// Fósforo remanescente (P-rem) em mg/L — para calcular Y
  @override
  final double? Prem;

  /// Extrator de fósforo utilizado
  @override
  @JsonKey()
  final String extrator;
// ─── Textura ──────────────────────────────────────────────
  /// Argila em % (0–100)
  @override
  @JsonKey()
  final double argila;
// ─── Enxofre (mg/dm³) ────────────────────────────────────
  @override
  @JsonKey()
  final double S;
// ─── Micronutrientes (mg/dm³) ────────────────────────────
  @override
  @JsonKey()
  final double B;
  @override
  @JsonKey()
  final double Cu;
  @override
  @JsonKey()
  final double Fe;
  @override
  @JsonKey()
  final double Mn;
  @override
  @JsonKey()
  final double Zn;
// ─── Geolocalização ──────────────────────────────────────
  @override
  @JsonKey()
  final double latitude;
  @override
  @JsonKey()
  final double longitude;
  @override
  @JsonKey()
  final String endereco;
// ─── Calculados automaticamente ───────────────────────────
// Nota: SB, CTC, Vat, mat calculados pelo motor dinamicamente.
// Podem ser cacheados aqui após o cálculo.
  @override
  @JsonKey()
  final double SB;
// Soma de Bases = Ca + Mg + K
  @override
  @JsonKey()
  final double CTC;
// Capacidade de Troca = SB + H+Al
  @override
  @JsonKey()
  final double Vat;
// Saturação por bases V% = SB/CTC × 100
  @override
  @JsonKey()
  final double mat;
// Saturação por Al m% = Al/(SB+Al) × 100
  @override
  @JsonKey()
  final double Y;

  @override
  String toString() {
    return 'AnaliseSolo(id: $id, clienteNome: $clienteNome, fazendaNome: $fazendaNome, talhaoNome: $talhaoNome, cultura: $cultura, laboratorio: $laboratorio, data: $data, pH: $pH, phAgua: $phAgua, phSmp: $phSmp, MO: $MO, Ca: $Ca, Mg: $Mg, K: $K, HAl: $HAl, Al: $Al, P: $P, Prem: $Prem, extrator: $extrator, argila: $argila, S: $S, B: $B, Cu: $Cu, Fe: $Fe, Mn: $Mn, Zn: $Zn, latitude: $latitude, longitude: $longitude, endereco: $endereco, SB: $SB, CTC: $CTC, Vat: $Vat, mat: $mat, Y: $Y)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnaliseSoloImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.clienteNome, clienteNome) ||
                other.clienteNome == clienteNome) &&
            (identical(other.fazendaNome, fazendaNome) ||
                other.fazendaNome == fazendaNome) &&
            (identical(other.talhaoNome, talhaoNome) ||
                other.talhaoNome == talhaoNome) &&
            (identical(other.cultura, cultura) || other.cultura == cultura) &&
            (identical(other.laboratorio, laboratorio) ||
                other.laboratorio == laboratorio) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.pH, pH) || other.pH == pH) &&
            (identical(other.phAgua, phAgua) || other.phAgua == phAgua) &&
            (identical(other.phSmp, phSmp) || other.phSmp == phSmp) &&
            (identical(other.MO, MO) || other.MO == MO) &&
            (identical(other.Ca, Ca) || other.Ca == Ca) &&
            (identical(other.Mg, Mg) || other.Mg == Mg) &&
            (identical(other.K, K) || other.K == K) &&
            (identical(other.HAl, HAl) || other.HAl == HAl) &&
            (identical(other.Al, Al) || other.Al == Al) &&
            (identical(other.P, P) || other.P == P) &&
            (identical(other.Prem, Prem) || other.Prem == Prem) &&
            (identical(other.extrator, extrator) ||
                other.extrator == extrator) &&
            (identical(other.argila, argila) || other.argila == argila) &&
            (identical(other.S, S) || other.S == S) &&
            (identical(other.B, B) || other.B == B) &&
            (identical(other.Cu, Cu) || other.Cu == Cu) &&
            (identical(other.Fe, Fe) || other.Fe == Fe) &&
            (identical(other.Mn, Mn) || other.Mn == Mn) &&
            (identical(other.Zn, Zn) || other.Zn == Zn) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.endereco, endereco) ||
                other.endereco == endereco) &&
            (identical(other.SB, SB) || other.SB == SB) &&
            (identical(other.CTC, CTC) || other.CTC == CTC) &&
            (identical(other.Vat, Vat) || other.Vat == Vat) &&
            (identical(other.mat, mat) || other.mat == mat) &&
            (identical(other.Y, Y) || other.Y == Y));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        clienteNome,
        fazendaNome,
        talhaoNome,
        cultura,
        laboratorio,
        data,
        pH,
        phAgua,
        phSmp,
        MO,
        Ca,
        Mg,
        K,
        HAl,
        Al,
        P,
        Prem,
        extrator,
        argila,
        S,
        B,
        Cu,
        Fe,
        Mn,
        Zn,
        latitude,
        longitude,
        endereco,
        SB,
        CTC,
        Vat,
        mat,
        Y
      ]);

  /// Create a copy of AnaliseSolo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnaliseSoloImplCopyWith<_$AnaliseSoloImpl> get copyWith =>
      __$$AnaliseSoloImplCopyWithImpl<_$AnaliseSoloImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnaliseSoloImplToJson(
      this,
    );
  }
}

abstract class _AnaliseSolo implements AnaliseSolo {
  const factory _AnaliseSolo(
      {required final String id,
      final String clienteNome,
      final String fazendaNome,
      final String talhaoNome,
      final String cultura,
      final String laboratorio,
      final String? data,
      final double pH,
      final double phAgua,
      final double phSmp,
      final double MO,
      final double Ca,
      final double Mg,
      final double K,
      final double HAl,
      final double Al,
      final double P,
      final double? Prem,
      final String extrator,
      final double argila,
      final double S,
      final double B,
      final double Cu,
      final double Fe,
      final double Mn,
      final double Zn,
      final double latitude,
      final double longitude,
      final String endereco,
      final double SB,
      final double CTC,
      final double Vat,
      final double mat,
      final double Y}) = _$AnaliseSoloImpl;

  factory _AnaliseSolo.fromJson(Map<String, dynamic> json) =
      _$AnaliseSoloImpl.fromJson;

  @override
  String get id; // ─── Identificação ───────────────────────────────────────
  @override
  String get clienteNome;
  @override
  String get fazendaNome;
  @override
  String get talhaoNome;
  @override
  String get cultura;
  @override
  String get laboratorio;
  @override
  String? get data; // ─── pH ──────────────────────────────────────────────────
  /// pH em CaCl₂ 0,01 mol/L
  @override
  double get pH;

  /// pH em água
  @override
  double get phAgua;

  /// pH tampão SMP (para calcular H+Al)
  @override
  double
      get phSmp; // ─── Matéria Orgânica ─────────────────────────────────────
  /// MO em g/dm³
  @override
  double get MO; // ─── Macronutrientes (cmolc/dm³) ─────────────────────────
  /// Cálcio trocável (cmolc/dm³)
  @override
  double get Ca;

  /// Magnésio trocável (cmolc/dm³)
  @override
  double get Mg;

  /// Potássio trocável (cmolc/dm³ — converter de mg/dm³ se necessário)
  @override
  double get K;

  /// Acidez potencial H+Al (cmolc/dm³)
  @override
  double get HAl;

  /// Alumínio trocável (cmolc/dm³)
  @override
  double get Al; // ─── Fósforo e P-rem ─────────────────────────────────────
  /// Fósforo disponível (mg/dm³)
  @override
  double get P;

  /// Fósforo remanescente (P-rem) em mg/L — para calcular Y
  @override
  double? get Prem;

  /// Extrator de fósforo utilizado
  @override
  String
      get extrator; // ─── Textura ──────────────────────────────────────────────
  /// Argila em % (0–100)
  @override
  double
      get argila; // ─── Enxofre (mg/dm³) ────────────────────────────────────
  @override
  double get S; // ─── Micronutrientes (mg/dm³) ────────────────────────────
  @override
  double get B;
  @override
  double get Cu;
  @override
  double get Fe;
  @override
  double get Mn;
  @override
  double get Zn; // ─── Geolocalização ──────────────────────────────────────
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String
      get endereco; // ─── Calculados automaticamente ───────────────────────────
// Nota: SB, CTC, Vat, mat calculados pelo motor dinamicamente.
// Podem ser cacheados aqui após o cálculo.
  @override
  double get SB; // Soma de Bases = Ca + Mg + K
  @override
  double get CTC; // Capacidade de Troca = SB + H+Al
  @override
  double get Vat; // Saturação por bases V% = SB/CTC × 100
  @override
  double get mat; // Saturação por Al m% = Al/(SB+Al) × 100
  @override
  double get Y;

  /// Create a copy of AnaliseSolo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnaliseSoloImplCopyWith<_$AnaliseSoloImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
