// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recomendacao_engine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RelacoesK {
  double get relKMg => throw _privateConstructorUsedError;
  double get relKCa => throw _privateConstructorUsedError;
  List<String> get alertas => throw _privateConstructorUsedError;
  double get kNaCTC => throw _privateConstructorUsedError;

  /// Create a copy of RelacoesK
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RelacoesKCopyWith<RelacoesK> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RelacoesKCopyWith<$Res> {
  factory $RelacoesKCopyWith(RelacoesK value, $Res Function(RelacoesK) then) =
      _$RelacoesKCopyWithImpl<$Res, RelacoesK>;
  @useResult
  $Res call(
      {double relKMg, double relKCa, List<String> alertas, double kNaCTC});
}

/// @nodoc
class _$RelacoesKCopyWithImpl<$Res, $Val extends RelacoesK>
    implements $RelacoesKCopyWith<$Res> {
  _$RelacoesKCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RelacoesK
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? relKMg = null,
    Object? relKCa = null,
    Object? alertas = null,
    Object? kNaCTC = null,
  }) {
    return _then(_value.copyWith(
      relKMg: null == relKMg
          ? _value.relKMg
          : relKMg // ignore: cast_nullable_to_non_nullable
              as double,
      relKCa: null == relKCa
          ? _value.relKCa
          : relKCa // ignore: cast_nullable_to_non_nullable
              as double,
      alertas: null == alertas
          ? _value.alertas
          : alertas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      kNaCTC: null == kNaCTC
          ? _value.kNaCTC
          : kNaCTC // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RelacoesKImplCopyWith<$Res>
    implements $RelacoesKCopyWith<$Res> {
  factory _$$RelacoesKImplCopyWith(
          _$RelacoesKImpl value, $Res Function(_$RelacoesKImpl) then) =
      __$$RelacoesKImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double relKMg, double relKCa, List<String> alertas, double kNaCTC});
}

/// @nodoc
class __$$RelacoesKImplCopyWithImpl<$Res>
    extends _$RelacoesKCopyWithImpl<$Res, _$RelacoesKImpl>
    implements _$$RelacoesKImplCopyWith<$Res> {
  __$$RelacoesKImplCopyWithImpl(
      _$RelacoesKImpl _value, $Res Function(_$RelacoesKImpl) _then)
      : super(_value, _then);

  /// Create a copy of RelacoesK
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? relKMg = null,
    Object? relKCa = null,
    Object? alertas = null,
    Object? kNaCTC = null,
  }) {
    return _then(_$RelacoesKImpl(
      relKMg: null == relKMg
          ? _value.relKMg
          : relKMg // ignore: cast_nullable_to_non_nullable
              as double,
      relKCa: null == relKCa
          ? _value.relKCa
          : relKCa // ignore: cast_nullable_to_non_nullable
              as double,
      alertas: null == alertas
          ? _value._alertas
          : alertas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      kNaCTC: null == kNaCTC
          ? _value.kNaCTC
          : kNaCTC // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$RelacoesKImpl implements _RelacoesK {
  const _$RelacoesKImpl(
      {required this.relKMg,
      required this.relKCa,
      required final List<String> alertas,
      required this.kNaCTC})
      : _alertas = alertas;

  @override
  final double relKMg;
  @override
  final double relKCa;
  final List<String> _alertas;
  @override
  List<String> get alertas {
    if (_alertas is EqualUnmodifiableListView) return _alertas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alertas);
  }

  @override
  final double kNaCTC;

  @override
  String toString() {
    return 'RelacoesK(relKMg: $relKMg, relKCa: $relKCa, alertas: $alertas, kNaCTC: $kNaCTC)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RelacoesKImpl &&
            (identical(other.relKMg, relKMg) || other.relKMg == relKMg) &&
            (identical(other.relKCa, relKCa) || other.relKCa == relKCa) &&
            const DeepCollectionEquality().equals(other._alertas, _alertas) &&
            (identical(other.kNaCTC, kNaCTC) || other.kNaCTC == kNaCTC));
  }

  @override
  int get hashCode => Object.hash(runtimeType, relKMg, relKCa,
      const DeepCollectionEquality().hash(_alertas), kNaCTC);

  /// Create a copy of RelacoesK
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RelacoesKImplCopyWith<_$RelacoesKImpl> get copyWith =>
      __$$RelacoesKImplCopyWithImpl<_$RelacoesKImpl>(this, _$identity);
}

abstract class _RelacoesK implements RelacoesK {
  const factory _RelacoesK(
      {required final double relKMg,
      required final double relKCa,
      required final List<String> alertas,
      required final double kNaCTC}) = _$RelacoesKImpl;

  @override
  double get relKMg;
  @override
  double get relKCa;
  @override
  List<String> get alertas;
  @override
  double get kNaCTC;

  /// Create a copy of RelacoesK
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RelacoesKImplCopyWith<_$RelacoesKImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MicroResultado {
  /// Símbolo do elemento (ex: 'Zn', 'B', 'Cu')
  String get elemento => throw _privateConstructorUsedError;

  /// Teor atual na análise
  double get valorAtual => throw _privateConstructorUsedError;

  /// Nível crítico de referência
  double get nc => throw _privateConstructorUsedError;

  /// Dose recomendada do nutriente puro
  double get dose => throw _privateConstructorUsedError;

  /// Unidade da dose (ex: 'kg/ha', 'g/ha')
  String get unidade => throw _privateConstructorUsedError;

  /// true quando valorAtual < nc
  bool get deficiente =>
      throw _privateConstructorUsedError; // -- Dados migrados da tela (UI) --
  String get via => throw _privateConstructorUsedError;
  String get fonte => throw _privateConstructorUsedError;
  double get doseProduto => throw _privateConstructorUsedError;
  String get doseProdutoLabel => throw _privateConstructorUsedError;

  /// Citação científica da referência usada
  String? get referencia => throw _privateConstructorUsedError;

  /// Create a copy of MicroResultado
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MicroResultadoCopyWith<MicroResultado> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MicroResultadoCopyWith<$Res> {
  factory $MicroResultadoCopyWith(
          MicroResultado value, $Res Function(MicroResultado) then) =
      _$MicroResultadoCopyWithImpl<$Res, MicroResultado>;
  @useResult
  $Res call(
      {String elemento,
      double valorAtual,
      double nc,
      double dose,
      String unidade,
      bool deficiente,
      String via,
      String fonte,
      double doseProduto,
      String doseProdutoLabel,
      String? referencia});
}

/// @nodoc
class _$MicroResultadoCopyWithImpl<$Res, $Val extends MicroResultado>
    implements $MicroResultadoCopyWith<$Res> {
  _$MicroResultadoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MicroResultado
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? elemento = null,
    Object? valorAtual = null,
    Object? nc = null,
    Object? dose = null,
    Object? unidade = null,
    Object? deficiente = null,
    Object? via = null,
    Object? fonte = null,
    Object? doseProduto = null,
    Object? doseProdutoLabel = null,
    Object? referencia = freezed,
  }) {
    return _then(_value.copyWith(
      elemento: null == elemento
          ? _value.elemento
          : elemento // ignore: cast_nullable_to_non_nullable
              as String,
      valorAtual: null == valorAtual
          ? _value.valorAtual
          : valorAtual // ignore: cast_nullable_to_non_nullable
              as double,
      nc: null == nc
          ? _value.nc
          : nc // ignore: cast_nullable_to_non_nullable
              as double,
      dose: null == dose
          ? _value.dose
          : dose // ignore: cast_nullable_to_non_nullable
              as double,
      unidade: null == unidade
          ? _value.unidade
          : unidade // ignore: cast_nullable_to_non_nullable
              as String,
      deficiente: null == deficiente
          ? _value.deficiente
          : deficiente // ignore: cast_nullable_to_non_nullable
              as bool,
      via: null == via
          ? _value.via
          : via // ignore: cast_nullable_to_non_nullable
              as String,
      fonte: null == fonte
          ? _value.fonte
          : fonte // ignore: cast_nullable_to_non_nullable
              as String,
      doseProduto: null == doseProduto
          ? _value.doseProduto
          : doseProduto // ignore: cast_nullable_to_non_nullable
              as double,
      doseProdutoLabel: null == doseProdutoLabel
          ? _value.doseProdutoLabel
          : doseProdutoLabel // ignore: cast_nullable_to_non_nullable
              as String,
      referencia: freezed == referencia
          ? _value.referencia
          : referencia // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MicroResultadoImplCopyWith<$Res>
    implements $MicroResultadoCopyWith<$Res> {
  factory _$$MicroResultadoImplCopyWith(_$MicroResultadoImpl value,
          $Res Function(_$MicroResultadoImpl) then) =
      __$$MicroResultadoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String elemento,
      double valorAtual,
      double nc,
      double dose,
      String unidade,
      bool deficiente,
      String via,
      String fonte,
      double doseProduto,
      String doseProdutoLabel,
      String? referencia});
}

/// @nodoc
class __$$MicroResultadoImplCopyWithImpl<$Res>
    extends _$MicroResultadoCopyWithImpl<$Res, _$MicroResultadoImpl>
    implements _$$MicroResultadoImplCopyWith<$Res> {
  __$$MicroResultadoImplCopyWithImpl(
      _$MicroResultadoImpl _value, $Res Function(_$MicroResultadoImpl) _then)
      : super(_value, _then);

  /// Create a copy of MicroResultado
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? elemento = null,
    Object? valorAtual = null,
    Object? nc = null,
    Object? dose = null,
    Object? unidade = null,
    Object? deficiente = null,
    Object? via = null,
    Object? fonte = null,
    Object? doseProduto = null,
    Object? doseProdutoLabel = null,
    Object? referencia = freezed,
  }) {
    return _then(_$MicroResultadoImpl(
      elemento: null == elemento
          ? _value.elemento
          : elemento // ignore: cast_nullable_to_non_nullable
              as String,
      valorAtual: null == valorAtual
          ? _value.valorAtual
          : valorAtual // ignore: cast_nullable_to_non_nullable
              as double,
      nc: null == nc
          ? _value.nc
          : nc // ignore: cast_nullable_to_non_nullable
              as double,
      dose: null == dose
          ? _value.dose
          : dose // ignore: cast_nullable_to_non_nullable
              as double,
      unidade: null == unidade
          ? _value.unidade
          : unidade // ignore: cast_nullable_to_non_nullable
              as String,
      deficiente: null == deficiente
          ? _value.deficiente
          : deficiente // ignore: cast_nullable_to_non_nullable
              as bool,
      via: null == via
          ? _value.via
          : via // ignore: cast_nullable_to_non_nullable
              as String,
      fonte: null == fonte
          ? _value.fonte
          : fonte // ignore: cast_nullable_to_non_nullable
              as String,
      doseProduto: null == doseProduto
          ? _value.doseProduto
          : doseProduto // ignore: cast_nullable_to_non_nullable
              as double,
      doseProdutoLabel: null == doseProdutoLabel
          ? _value.doseProdutoLabel
          : doseProdutoLabel // ignore: cast_nullable_to_non_nullable
              as String,
      referencia: freezed == referencia
          ? _value.referencia
          : referencia // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$MicroResultadoImpl implements _MicroResultado {
  const _$MicroResultadoImpl(
      {required this.elemento,
      required this.valorAtual,
      required this.nc,
      required this.dose,
      required this.unidade,
      required this.deficiente,
      required this.via,
      required this.fonte,
      required this.doseProduto,
      required this.doseProdutoLabel,
      this.referencia});

  /// Símbolo do elemento (ex: 'Zn', 'B', 'Cu')
  @override
  final String elemento;

  /// Teor atual na análise
  @override
  final double valorAtual;

  /// Nível crítico de referência
  @override
  final double nc;

  /// Dose recomendada do nutriente puro
  @override
  final double dose;

  /// Unidade da dose (ex: 'kg/ha', 'g/ha')
  @override
  final String unidade;

  /// true quando valorAtual < nc
  @override
  final bool deficiente;
// -- Dados migrados da tela (UI) --
  @override
  final String via;
  @override
  final String fonte;
  @override
  final double doseProduto;
  @override
  final String doseProdutoLabel;

  /// Citação científica da referência usada
  @override
  final String? referencia;

  @override
  String toString() {
    return 'MicroResultado(elemento: $elemento, valorAtual: $valorAtual, nc: $nc, dose: $dose, unidade: $unidade, deficiente: $deficiente, via: $via, fonte: $fonte, doseProduto: $doseProduto, doseProdutoLabel: $doseProdutoLabel, referencia: $referencia)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MicroResultadoImpl &&
            (identical(other.elemento, elemento) ||
                other.elemento == elemento) &&
            (identical(other.valorAtual, valorAtual) ||
                other.valorAtual == valorAtual) &&
            (identical(other.nc, nc) || other.nc == nc) &&
            (identical(other.dose, dose) || other.dose == dose) &&
            (identical(other.unidade, unidade) || other.unidade == unidade) &&
            (identical(other.deficiente, deficiente) ||
                other.deficiente == deficiente) &&
            (identical(other.via, via) || other.via == via) &&
            (identical(other.fonte, fonte) || other.fonte == fonte) &&
            (identical(other.doseProduto, doseProduto) ||
                other.doseProduto == doseProduto) &&
            (identical(other.doseProdutoLabel, doseProdutoLabel) ||
                other.doseProdutoLabel == doseProdutoLabel) &&
            (identical(other.referencia, referencia) ||
                other.referencia == referencia));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      elemento,
      valorAtual,
      nc,
      dose,
      unidade,
      deficiente,
      via,
      fonte,
      doseProduto,
      doseProdutoLabel,
      referencia);

  /// Create a copy of MicroResultado
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MicroResultadoImplCopyWith<_$MicroResultadoImpl> get copyWith =>
      __$$MicroResultadoImplCopyWithImpl<_$MicroResultadoImpl>(
          this, _$identity);
}

abstract class _MicroResultado implements MicroResultado {
  const factory _MicroResultado(
      {required final String elemento,
      required final double valorAtual,
      required final double nc,
      required final double dose,
      required final String unidade,
      required final bool deficiente,
      required final String via,
      required final String fonte,
      required final double doseProduto,
      required final String doseProdutoLabel,
      final String? referencia}) = _$MicroResultadoImpl;

  /// Símbolo do elemento (ex: 'Zn', 'B', 'Cu')
  @override
  String get elemento;

  /// Teor atual na análise
  @override
  double get valorAtual;

  /// Nível crítico de referência
  @override
  double get nc;

  /// Dose recomendada do nutriente puro
  @override
  double get dose;

  /// Unidade da dose (ex: 'kg/ha', 'g/ha')
  @override
  String get unidade;

  /// true quando valorAtual < nc
  @override
  bool get deficiente; // -- Dados migrados da tela (UI) --
  @override
  String get via;
  @override
  String get fonte;
  @override
  double get doseProduto;
  @override
  String get doseProdutoLabel;

  /// Citação científica da referência usada
  @override
  String? get referencia;

  /// Create a copy of MicroResultado
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MicroResultadoImplCopyWith<_$MicroResultadoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GrupoResultado {
  /// Nome do grupo (ex: 'Grupo NPK', 'Micros solo')
  String get nomeGrupo => throw _privateConstructorUsedError;

  /// Elementos que compõem este grupo
  List<MicroResultado> get micros =>
      throw _privateConstructorUsedError; // -- Dados migrados da tela (UI) --
  String get via => throw _privateConstructorUsedError;
  String get produto => throw _privateConstructorUsedError;
  String get doseProdutoKgLabel => throw _privateConstructorUsedError;
  String get fornecimento => throw _privateConstructorUsedError;

  /// Create a copy of GrupoResultado
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GrupoResultadoCopyWith<GrupoResultado> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GrupoResultadoCopyWith<$Res> {
  factory $GrupoResultadoCopyWith(
          GrupoResultado value, $Res Function(GrupoResultado) then) =
      _$GrupoResultadoCopyWithImpl<$Res, GrupoResultado>;
  @useResult
  $Res call(
      {String nomeGrupo,
      List<MicroResultado> micros,
      String via,
      String produto,
      String doseProdutoKgLabel,
      String fornecimento});
}

/// @nodoc
class _$GrupoResultadoCopyWithImpl<$Res, $Val extends GrupoResultado>
    implements $GrupoResultadoCopyWith<$Res> {
  _$GrupoResultadoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GrupoResultado
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nomeGrupo = null,
    Object? micros = null,
    Object? via = null,
    Object? produto = null,
    Object? doseProdutoKgLabel = null,
    Object? fornecimento = null,
  }) {
    return _then(_value.copyWith(
      nomeGrupo: null == nomeGrupo
          ? _value.nomeGrupo
          : nomeGrupo // ignore: cast_nullable_to_non_nullable
              as String,
      micros: null == micros
          ? _value.micros
          : micros // ignore: cast_nullable_to_non_nullable
              as List<MicroResultado>,
      via: null == via
          ? _value.via
          : via // ignore: cast_nullable_to_non_nullable
              as String,
      produto: null == produto
          ? _value.produto
          : produto // ignore: cast_nullable_to_non_nullable
              as String,
      doseProdutoKgLabel: null == doseProdutoKgLabel
          ? _value.doseProdutoKgLabel
          : doseProdutoKgLabel // ignore: cast_nullable_to_non_nullable
              as String,
      fornecimento: null == fornecimento
          ? _value.fornecimento
          : fornecimento // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GrupoResultadoImplCopyWith<$Res>
    implements $GrupoResultadoCopyWith<$Res> {
  factory _$$GrupoResultadoImplCopyWith(_$GrupoResultadoImpl value,
          $Res Function(_$GrupoResultadoImpl) then) =
      __$$GrupoResultadoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String nomeGrupo,
      List<MicroResultado> micros,
      String via,
      String produto,
      String doseProdutoKgLabel,
      String fornecimento});
}

/// @nodoc
class __$$GrupoResultadoImplCopyWithImpl<$Res>
    extends _$GrupoResultadoCopyWithImpl<$Res, _$GrupoResultadoImpl>
    implements _$$GrupoResultadoImplCopyWith<$Res> {
  __$$GrupoResultadoImplCopyWithImpl(
      _$GrupoResultadoImpl _value, $Res Function(_$GrupoResultadoImpl) _then)
      : super(_value, _then);

  /// Create a copy of GrupoResultado
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nomeGrupo = null,
    Object? micros = null,
    Object? via = null,
    Object? produto = null,
    Object? doseProdutoKgLabel = null,
    Object? fornecimento = null,
  }) {
    return _then(_$GrupoResultadoImpl(
      nomeGrupo: null == nomeGrupo
          ? _value.nomeGrupo
          : nomeGrupo // ignore: cast_nullable_to_non_nullable
              as String,
      micros: null == micros
          ? _value._micros
          : micros // ignore: cast_nullable_to_non_nullable
              as List<MicroResultado>,
      via: null == via
          ? _value.via
          : via // ignore: cast_nullable_to_non_nullable
              as String,
      produto: null == produto
          ? _value.produto
          : produto // ignore: cast_nullable_to_non_nullable
              as String,
      doseProdutoKgLabel: null == doseProdutoKgLabel
          ? _value.doseProdutoKgLabel
          : doseProdutoKgLabel // ignore: cast_nullable_to_non_nullable
              as String,
      fornecimento: null == fornecimento
          ? _value.fornecimento
          : fornecimento // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GrupoResultadoImpl implements _GrupoResultado {
  const _$GrupoResultadoImpl(
      {required this.nomeGrupo,
      required final List<MicroResultado> micros,
      required this.via,
      required this.produto,
      required this.doseProdutoKgLabel,
      required this.fornecimento})
      : _micros = micros;

  /// Nome do grupo (ex: 'Grupo NPK', 'Micros solo')
  @override
  final String nomeGrupo;

  /// Elementos que compõem este grupo
  final List<MicroResultado> _micros;

  /// Elementos que compõem este grupo
  @override
  List<MicroResultado> get micros {
    if (_micros is EqualUnmodifiableListView) return _micros;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_micros);
  }

// -- Dados migrados da tela (UI) --
  @override
  final String via;
  @override
  final String produto;
  @override
  final String doseProdutoKgLabel;
  @override
  final String fornecimento;

  @override
  String toString() {
    return 'GrupoResultado(nomeGrupo: $nomeGrupo, micros: $micros, via: $via, produto: $produto, doseProdutoKgLabel: $doseProdutoKgLabel, fornecimento: $fornecimento)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GrupoResultadoImpl &&
            (identical(other.nomeGrupo, nomeGrupo) ||
                other.nomeGrupo == nomeGrupo) &&
            const DeepCollectionEquality().equals(other._micros, _micros) &&
            (identical(other.via, via) || other.via == via) &&
            (identical(other.produto, produto) || other.produto == produto) &&
            (identical(other.doseProdutoKgLabel, doseProdutoKgLabel) ||
                other.doseProdutoKgLabel == doseProdutoKgLabel) &&
            (identical(other.fornecimento, fornecimento) ||
                other.fornecimento == fornecimento));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      nomeGrupo,
      const DeepCollectionEquality().hash(_micros),
      via,
      produto,
      doseProdutoKgLabel,
      fornecimento);

  /// Create a copy of GrupoResultado
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GrupoResultadoImplCopyWith<_$GrupoResultadoImpl> get copyWith =>
      __$$GrupoResultadoImplCopyWithImpl<_$GrupoResultadoImpl>(
          this, _$identity);
}

abstract class _GrupoResultado implements GrupoResultado {
  const factory _GrupoResultado(
      {required final String nomeGrupo,
      required final List<MicroResultado> micros,
      required final String via,
      required final String produto,
      required final String doseProdutoKgLabel,
      required final String fornecimento}) = _$GrupoResultadoImpl;

  /// Nome do grupo (ex: 'Grupo NPK', 'Micros solo')
  @override
  String get nomeGrupo;

  /// Elementos que compõem este grupo
  @override
  List<MicroResultado> get micros; // -- Dados migrados da tela (UI) --
  @override
  String get via;
  @override
  String get produto;
  @override
  String get doseProdutoKgLabel;
  @override
  String get fornecimento;

  /// Create a copy of GrupoResultado
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GrupoResultadoImplCopyWith<_$GrupoResultadoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ResultadoRecomendacao {
  AnaliseEntity get analise => throw _privateConstructorUsedError;
  CalibracaoProfile get calibracao => throw _privateConstructorUsedError;
  RecomendacaoModel? get base => throw _privateConstructorUsedError;
  String? get labelAnalise => throw _privateConstructorUsedError;
  DateTime? get geradaEm => throw _privateConstructorUsedError;
  String get metodoCalagem =>
      throw _privateConstructorUsedError; // ── Calcário ──────────────────────────────────────────────────────────
  double get doseCalcarioTHa => throw _privateConstructorUsedError;
  double get vEsperado => throw _privateConstructorUsedError;
  double get caEsperado => throw _privateConstructorUsedError;
  double get mgEsperado => throw _privateConstructorUsedError;
  double get relacaoCaMg => throw _privateConstructorUsedError;

  /// Parcelas de aplicação quando dose > 4 t/ha
  List<String> get parcelamento =>
      throw _privateConstructorUsedError; // ── Gesso ─────────────────────────────────────────────────────────────
  ResultadoGesso get gesso =>
      throw _privateConstructorUsedError; // ── Fósforo ───────────────────────────────────────────────────────────
  /// Modo de cálculo selecionado (ex: '① Correção do solo')
  String get modoFosforo => throw _privateConstructorUsedError;
  double get ncFosforo => throw _privateConstructorUsedError;
  double get doseP2O5KgHa => throw _privateConstructorUsedError;
  bool get legacyP =>
      throw _privateConstructorUsedError; // ── Potássio ──────────────────────────────────────────────────────────
  /// Critério selecionado (ex: '% K na CTC', 'Teor absoluto')
  String get criterioPotassio => throw _privateConstructorUsedError;
  double get ncPotassio => throw _privateConstructorUsedError;
  double get doseK2OKgHa => throw _privateConstructorUsedError;
  RelacoesK get relacoesK =>
      throw _privateConstructorUsedError; // ── Micronutrientes ───────────────────────────────────────────────────
  List<MicroResultado> get micros => throw _privateConstructorUsedError;
  List<GrupoResultado> get grupos =>
      throw _privateConstructorUsedError; // ── Absorção / Exportação (T4 — informativo, NÃO somado à dose solo) ────
  /// Dose de P₂O₅ kg/ha necessária para repor o P absorvido/exportado pela cultura.
  /// null quando productividade ou referência de absorção não estão configuradas.
  double? get doseAbsorcaoP => throw _privateConstructorUsedError;

  /// Dose de K₂O kg/ha necessária para repor o K absorvido/exportado pela cultura.
  /// null quando productividade ou referência de absorção não estão configuradas.
  double? get doseAbsorcaoK =>
      throw _privateConstructorUsedError; // ── Diagnóstico ───────────────────────────────────────────────────────
  List<String> get avisos => throw _privateConstructorUsedError;
  String get argumentos => throw _privateConstructorUsedError;

  /// Citações acadêmicas agrupadas por nutriente
  Map<String, String>? get citacoes => throw _privateConstructorUsedError;

  /// Create a copy of ResultadoRecomendacao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultadoRecomendacaoCopyWith<ResultadoRecomendacao> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultadoRecomendacaoCopyWith<$Res> {
  factory $ResultadoRecomendacaoCopyWith(ResultadoRecomendacao value,
          $Res Function(ResultadoRecomendacao) then) =
      _$ResultadoRecomendacaoCopyWithImpl<$Res, ResultadoRecomendacao>;
  @useResult
  $Res call(
      {AnaliseEntity analise,
      CalibracaoProfile calibracao,
      RecomendacaoModel? base,
      String? labelAnalise,
      DateTime? geradaEm,
      String metodoCalagem,
      double doseCalcarioTHa,
      double vEsperado,
      double caEsperado,
      double mgEsperado,
      double relacaoCaMg,
      List<String> parcelamento,
      ResultadoGesso gesso,
      String modoFosforo,
      double ncFosforo,
      double doseP2O5KgHa,
      bool legacyP,
      String criterioPotassio,
      double ncPotassio,
      double doseK2OKgHa,
      RelacoesK relacoesK,
      List<MicroResultado> micros,
      List<GrupoResultado> grupos,
      double? doseAbsorcaoP,
      double? doseAbsorcaoK,
      List<String> avisos,
      String argumentos,
      Map<String, String>? citacoes});

  $AnaliseEntityCopyWith<$Res> get analise;
  $RecomendacaoModelCopyWith<$Res>? get base;
  $RelacoesKCopyWith<$Res> get relacoesK;
}

/// @nodoc
class _$ResultadoRecomendacaoCopyWithImpl<$Res,
        $Val extends ResultadoRecomendacao>
    implements $ResultadoRecomendacaoCopyWith<$Res> {
  _$ResultadoRecomendacaoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResultadoRecomendacao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? analise = null,
    Object? calibracao = null,
    Object? base = freezed,
    Object? labelAnalise = freezed,
    Object? geradaEm = freezed,
    Object? metodoCalagem = null,
    Object? doseCalcarioTHa = null,
    Object? vEsperado = null,
    Object? caEsperado = null,
    Object? mgEsperado = null,
    Object? relacaoCaMg = null,
    Object? parcelamento = null,
    Object? gesso = null,
    Object? modoFosforo = null,
    Object? ncFosforo = null,
    Object? doseP2O5KgHa = null,
    Object? legacyP = null,
    Object? criterioPotassio = null,
    Object? ncPotassio = null,
    Object? doseK2OKgHa = null,
    Object? relacoesK = null,
    Object? micros = null,
    Object? grupos = null,
    Object? doseAbsorcaoP = freezed,
    Object? doseAbsorcaoK = freezed,
    Object? avisos = null,
    Object? argumentos = null,
    Object? citacoes = freezed,
  }) {
    return _then(_value.copyWith(
      analise: null == analise
          ? _value.analise
          : analise // ignore: cast_nullable_to_non_nullable
              as AnaliseEntity,
      calibracao: null == calibracao
          ? _value.calibracao
          : calibracao // ignore: cast_nullable_to_non_nullable
              as CalibracaoProfile,
      base: freezed == base
          ? _value.base
          : base // ignore: cast_nullable_to_non_nullable
              as RecomendacaoModel?,
      labelAnalise: freezed == labelAnalise
          ? _value.labelAnalise
          : labelAnalise // ignore: cast_nullable_to_non_nullable
              as String?,
      geradaEm: freezed == geradaEm
          ? _value.geradaEm
          : geradaEm // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metodoCalagem: null == metodoCalagem
          ? _value.metodoCalagem
          : metodoCalagem // ignore: cast_nullable_to_non_nullable
              as String,
      doseCalcarioTHa: null == doseCalcarioTHa
          ? _value.doseCalcarioTHa
          : doseCalcarioTHa // ignore: cast_nullable_to_non_nullable
              as double,
      vEsperado: null == vEsperado
          ? _value.vEsperado
          : vEsperado // ignore: cast_nullable_to_non_nullable
              as double,
      caEsperado: null == caEsperado
          ? _value.caEsperado
          : caEsperado // ignore: cast_nullable_to_non_nullable
              as double,
      mgEsperado: null == mgEsperado
          ? _value.mgEsperado
          : mgEsperado // ignore: cast_nullable_to_non_nullable
              as double,
      relacaoCaMg: null == relacaoCaMg
          ? _value.relacaoCaMg
          : relacaoCaMg // ignore: cast_nullable_to_non_nullable
              as double,
      parcelamento: null == parcelamento
          ? _value.parcelamento
          : parcelamento // ignore: cast_nullable_to_non_nullable
              as List<String>,
      gesso: null == gesso
          ? _value.gesso
          : gesso // ignore: cast_nullable_to_non_nullable
              as ResultadoGesso,
      modoFosforo: null == modoFosforo
          ? _value.modoFosforo
          : modoFosforo // ignore: cast_nullable_to_non_nullable
              as String,
      ncFosforo: null == ncFosforo
          ? _value.ncFosforo
          : ncFosforo // ignore: cast_nullable_to_non_nullable
              as double,
      doseP2O5KgHa: null == doseP2O5KgHa
          ? _value.doseP2O5KgHa
          : doseP2O5KgHa // ignore: cast_nullable_to_non_nullable
              as double,
      legacyP: null == legacyP
          ? _value.legacyP
          : legacyP // ignore: cast_nullable_to_non_nullable
              as bool,
      criterioPotassio: null == criterioPotassio
          ? _value.criterioPotassio
          : criterioPotassio // ignore: cast_nullable_to_non_nullable
              as String,
      ncPotassio: null == ncPotassio
          ? _value.ncPotassio
          : ncPotassio // ignore: cast_nullable_to_non_nullable
              as double,
      doseK2OKgHa: null == doseK2OKgHa
          ? _value.doseK2OKgHa
          : doseK2OKgHa // ignore: cast_nullable_to_non_nullable
              as double,
      relacoesK: null == relacoesK
          ? _value.relacoesK
          : relacoesK // ignore: cast_nullable_to_non_nullable
              as RelacoesK,
      micros: null == micros
          ? _value.micros
          : micros // ignore: cast_nullable_to_non_nullable
              as List<MicroResultado>,
      grupos: null == grupos
          ? _value.grupos
          : grupos // ignore: cast_nullable_to_non_nullable
              as List<GrupoResultado>,
      doseAbsorcaoP: freezed == doseAbsorcaoP
          ? _value.doseAbsorcaoP
          : doseAbsorcaoP // ignore: cast_nullable_to_non_nullable
              as double?,
      doseAbsorcaoK: freezed == doseAbsorcaoK
          ? _value.doseAbsorcaoK
          : doseAbsorcaoK // ignore: cast_nullable_to_non_nullable
              as double?,
      avisos: null == avisos
          ? _value.avisos
          : avisos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      argumentos: null == argumentos
          ? _value.argumentos
          : argumentos // ignore: cast_nullable_to_non_nullable
              as String,
      citacoes: freezed == citacoes
          ? _value.citacoes
          : citacoes // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ) as $Val);
  }

  /// Create a copy of ResultadoRecomendacao
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnaliseEntityCopyWith<$Res> get analise {
    return $AnaliseEntityCopyWith<$Res>(_value.analise, (value) {
      return _then(_value.copyWith(analise: value) as $Val);
    });
  }

  /// Create a copy of ResultadoRecomendacao
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecomendacaoModelCopyWith<$Res>? get base {
    if (_value.base == null) {
      return null;
    }

    return $RecomendacaoModelCopyWith<$Res>(_value.base!, (value) {
      return _then(_value.copyWith(base: value) as $Val);
    });
  }

  /// Create a copy of ResultadoRecomendacao
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RelacoesKCopyWith<$Res> get relacoesK {
    return $RelacoesKCopyWith<$Res>(_value.relacoesK, (value) {
      return _then(_value.copyWith(relacoesK: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ResultadoRecomendacaoImplCopyWith<$Res>
    implements $ResultadoRecomendacaoCopyWith<$Res> {
  factory _$$ResultadoRecomendacaoImplCopyWith(
          _$ResultadoRecomendacaoImpl value,
          $Res Function(_$ResultadoRecomendacaoImpl) then) =
      __$$ResultadoRecomendacaoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AnaliseEntity analise,
      CalibracaoProfile calibracao,
      RecomendacaoModel? base,
      String? labelAnalise,
      DateTime? geradaEm,
      String metodoCalagem,
      double doseCalcarioTHa,
      double vEsperado,
      double caEsperado,
      double mgEsperado,
      double relacaoCaMg,
      List<String> parcelamento,
      ResultadoGesso gesso,
      String modoFosforo,
      double ncFosforo,
      double doseP2O5KgHa,
      bool legacyP,
      String criterioPotassio,
      double ncPotassio,
      double doseK2OKgHa,
      RelacoesK relacoesK,
      List<MicroResultado> micros,
      List<GrupoResultado> grupos,
      double? doseAbsorcaoP,
      double? doseAbsorcaoK,
      List<String> avisos,
      String argumentos,
      Map<String, String>? citacoes});

  @override
  $AnaliseEntityCopyWith<$Res> get analise;
  @override
  $RecomendacaoModelCopyWith<$Res>? get base;
  @override
  $RelacoesKCopyWith<$Res> get relacoesK;
}

/// @nodoc
class __$$ResultadoRecomendacaoImplCopyWithImpl<$Res>
    extends _$ResultadoRecomendacaoCopyWithImpl<$Res,
        _$ResultadoRecomendacaoImpl>
    implements _$$ResultadoRecomendacaoImplCopyWith<$Res> {
  __$$ResultadoRecomendacaoImplCopyWithImpl(_$ResultadoRecomendacaoImpl _value,
      $Res Function(_$ResultadoRecomendacaoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResultadoRecomendacao
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? analise = null,
    Object? calibracao = null,
    Object? base = freezed,
    Object? labelAnalise = freezed,
    Object? geradaEm = freezed,
    Object? metodoCalagem = null,
    Object? doseCalcarioTHa = null,
    Object? vEsperado = null,
    Object? caEsperado = null,
    Object? mgEsperado = null,
    Object? relacaoCaMg = null,
    Object? parcelamento = null,
    Object? gesso = null,
    Object? modoFosforo = null,
    Object? ncFosforo = null,
    Object? doseP2O5KgHa = null,
    Object? legacyP = null,
    Object? criterioPotassio = null,
    Object? ncPotassio = null,
    Object? doseK2OKgHa = null,
    Object? relacoesK = null,
    Object? micros = null,
    Object? grupos = null,
    Object? doseAbsorcaoP = freezed,
    Object? doseAbsorcaoK = freezed,
    Object? avisos = null,
    Object? argumentos = null,
    Object? citacoes = freezed,
  }) {
    return _then(_$ResultadoRecomendacaoImpl(
      analise: null == analise
          ? _value.analise
          : analise // ignore: cast_nullable_to_non_nullable
              as AnaliseEntity,
      calibracao: null == calibracao
          ? _value.calibracao
          : calibracao // ignore: cast_nullable_to_non_nullable
              as CalibracaoProfile,
      base: freezed == base
          ? _value.base
          : base // ignore: cast_nullable_to_non_nullable
              as RecomendacaoModel?,
      labelAnalise: freezed == labelAnalise
          ? _value.labelAnalise
          : labelAnalise // ignore: cast_nullable_to_non_nullable
              as String?,
      geradaEm: freezed == geradaEm
          ? _value.geradaEm
          : geradaEm // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metodoCalagem: null == metodoCalagem
          ? _value.metodoCalagem
          : metodoCalagem // ignore: cast_nullable_to_non_nullable
              as String,
      doseCalcarioTHa: null == doseCalcarioTHa
          ? _value.doseCalcarioTHa
          : doseCalcarioTHa // ignore: cast_nullable_to_non_nullable
              as double,
      vEsperado: null == vEsperado
          ? _value.vEsperado
          : vEsperado // ignore: cast_nullable_to_non_nullable
              as double,
      caEsperado: null == caEsperado
          ? _value.caEsperado
          : caEsperado // ignore: cast_nullable_to_non_nullable
              as double,
      mgEsperado: null == mgEsperado
          ? _value.mgEsperado
          : mgEsperado // ignore: cast_nullable_to_non_nullable
              as double,
      relacaoCaMg: null == relacaoCaMg
          ? _value.relacaoCaMg
          : relacaoCaMg // ignore: cast_nullable_to_non_nullable
              as double,
      parcelamento: null == parcelamento
          ? _value._parcelamento
          : parcelamento // ignore: cast_nullable_to_non_nullable
              as List<String>,
      gesso: null == gesso
          ? _value.gesso
          : gesso // ignore: cast_nullable_to_non_nullable
              as ResultadoGesso,
      modoFosforo: null == modoFosforo
          ? _value.modoFosforo
          : modoFosforo // ignore: cast_nullable_to_non_nullable
              as String,
      ncFosforo: null == ncFosforo
          ? _value.ncFosforo
          : ncFosforo // ignore: cast_nullable_to_non_nullable
              as double,
      doseP2O5KgHa: null == doseP2O5KgHa
          ? _value.doseP2O5KgHa
          : doseP2O5KgHa // ignore: cast_nullable_to_non_nullable
              as double,
      legacyP: null == legacyP
          ? _value.legacyP
          : legacyP // ignore: cast_nullable_to_non_nullable
              as bool,
      criterioPotassio: null == criterioPotassio
          ? _value.criterioPotassio
          : criterioPotassio // ignore: cast_nullable_to_non_nullable
              as String,
      ncPotassio: null == ncPotassio
          ? _value.ncPotassio
          : ncPotassio // ignore: cast_nullable_to_non_nullable
              as double,
      doseK2OKgHa: null == doseK2OKgHa
          ? _value.doseK2OKgHa
          : doseK2OKgHa // ignore: cast_nullable_to_non_nullable
              as double,
      relacoesK: null == relacoesK
          ? _value.relacoesK
          : relacoesK // ignore: cast_nullable_to_non_nullable
              as RelacoesK,
      micros: null == micros
          ? _value._micros
          : micros // ignore: cast_nullable_to_non_nullable
              as List<MicroResultado>,
      grupos: null == grupos
          ? _value._grupos
          : grupos // ignore: cast_nullable_to_non_nullable
              as List<GrupoResultado>,
      doseAbsorcaoP: freezed == doseAbsorcaoP
          ? _value.doseAbsorcaoP
          : doseAbsorcaoP // ignore: cast_nullable_to_non_nullable
              as double?,
      doseAbsorcaoK: freezed == doseAbsorcaoK
          ? _value.doseAbsorcaoK
          : doseAbsorcaoK // ignore: cast_nullable_to_non_nullable
              as double?,
      avisos: null == avisos
          ? _value._avisos
          : avisos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      argumentos: null == argumentos
          ? _value.argumentos
          : argumentos // ignore: cast_nullable_to_non_nullable
              as String,
      citacoes: freezed == citacoes
          ? _value._citacoes
          : citacoes // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ));
  }
}

/// @nodoc

class _$ResultadoRecomendacaoImpl implements _ResultadoRecomendacao {
  const _$ResultadoRecomendacaoImpl(
      {required this.analise,
      required this.calibracao,
      this.base,
      this.labelAnalise,
      this.geradaEm,
      required this.metodoCalagem,
      required this.doseCalcarioTHa,
      required this.vEsperado,
      required this.caEsperado,
      required this.mgEsperado,
      required this.relacaoCaMg,
      required final List<String> parcelamento,
      required this.gesso,
      required this.modoFosforo,
      required this.ncFosforo,
      required this.doseP2O5KgHa,
      required this.legacyP,
      required this.criterioPotassio,
      required this.ncPotassio,
      required this.doseK2OKgHa,
      required this.relacoesK,
      required final List<MicroResultado> micros,
      required final List<GrupoResultado> grupos,
      this.doseAbsorcaoP = null,
      this.doseAbsorcaoK = null,
      required final List<String> avisos,
      required this.argumentos,
      final Map<String, String>? citacoes})
      : _parcelamento = parcelamento,
        _micros = micros,
        _grupos = grupos,
        _avisos = avisos,
        _citacoes = citacoes;

  @override
  final AnaliseEntity analise;
  @override
  final CalibracaoProfile calibracao;
  @override
  final RecomendacaoModel? base;
  @override
  final String? labelAnalise;
  @override
  final DateTime? geradaEm;
  @override
  final String metodoCalagem;
// ── Calcário ──────────────────────────────────────────────────────────
  @override
  final double doseCalcarioTHa;
  @override
  final double vEsperado;
  @override
  final double caEsperado;
  @override
  final double mgEsperado;
  @override
  final double relacaoCaMg;

  /// Parcelas de aplicação quando dose > 4 t/ha
  final List<String> _parcelamento;

  /// Parcelas de aplicação quando dose > 4 t/ha
  @override
  List<String> get parcelamento {
    if (_parcelamento is EqualUnmodifiableListView) return _parcelamento;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_parcelamento);
  }

// ── Gesso ─────────────────────────────────────────────────────────────
  @override
  final ResultadoGesso gesso;
// ── Fósforo ───────────────────────────────────────────────────────────
  /// Modo de cálculo selecionado (ex: '① Correção do solo')
  @override
  final String modoFosforo;
  @override
  final double ncFosforo;
  @override
  final double doseP2O5KgHa;
  @override
  final bool legacyP;
// ── Potássio ──────────────────────────────────────────────────────────
  /// Critério selecionado (ex: '% K na CTC', 'Teor absoluto')
  @override
  final String criterioPotassio;
  @override
  final double ncPotassio;
  @override
  final double doseK2OKgHa;
  @override
  final RelacoesK relacoesK;
// ── Micronutrientes ───────────────────────────────────────────────────
  final List<MicroResultado> _micros;
// ── Micronutrientes ───────────────────────────────────────────────────
  @override
  List<MicroResultado> get micros {
    if (_micros is EqualUnmodifiableListView) return _micros;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_micros);
  }

  final List<GrupoResultado> _grupos;
  @override
  List<GrupoResultado> get grupos {
    if (_grupos is EqualUnmodifiableListView) return _grupos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_grupos);
  }

// ── Absorção / Exportação (T4 — informativo, NÃO somado à dose solo) ────
  /// Dose de P₂O₅ kg/ha necessária para repor o P absorvido/exportado pela cultura.
  /// null quando productividade ou referência de absorção não estão configuradas.
  @override
  @JsonKey()
  final double? doseAbsorcaoP;

  /// Dose de K₂O kg/ha necessária para repor o K absorvido/exportado pela cultura.
  /// null quando productividade ou referência de absorção não estão configuradas.
  @override
  @JsonKey()
  final double? doseAbsorcaoK;
// ── Diagnóstico ───────────────────────────────────────────────────────
  final List<String> _avisos;
// ── Diagnóstico ───────────────────────────────────────────────────────
  @override
  List<String> get avisos {
    if (_avisos is EqualUnmodifiableListView) return _avisos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_avisos);
  }

  @override
  final String argumentos;

  /// Citações acadêmicas agrupadas por nutriente
  final Map<String, String>? _citacoes;

  /// Citações acadêmicas agrupadas por nutriente
  @override
  Map<String, String>? get citacoes {
    final value = _citacoes;
    if (value == null) return null;
    if (_citacoes is EqualUnmodifiableMapView) return _citacoes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ResultadoRecomendacao(analise: $analise, calibracao: $calibracao, base: $base, labelAnalise: $labelAnalise, geradaEm: $geradaEm, metodoCalagem: $metodoCalagem, doseCalcarioTHa: $doseCalcarioTHa, vEsperado: $vEsperado, caEsperado: $caEsperado, mgEsperado: $mgEsperado, relacaoCaMg: $relacaoCaMg, parcelamento: $parcelamento, gesso: $gesso, modoFosforo: $modoFosforo, ncFosforo: $ncFosforo, doseP2O5KgHa: $doseP2O5KgHa, legacyP: $legacyP, criterioPotassio: $criterioPotassio, ncPotassio: $ncPotassio, doseK2OKgHa: $doseK2OKgHa, relacoesK: $relacoesK, micros: $micros, grupos: $grupos, doseAbsorcaoP: $doseAbsorcaoP, doseAbsorcaoK: $doseAbsorcaoK, avisos: $avisos, argumentos: $argumentos, citacoes: $citacoes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultadoRecomendacaoImpl &&
            (identical(other.analise, analise) || other.analise == analise) &&
            (identical(other.calibracao, calibracao) ||
                other.calibracao == calibracao) &&
            (identical(other.base, base) || other.base == base) &&
            (identical(other.labelAnalise, labelAnalise) ||
                other.labelAnalise == labelAnalise) &&
            (identical(other.geradaEm, geradaEm) ||
                other.geradaEm == geradaEm) &&
            (identical(other.metodoCalagem, metodoCalagem) ||
                other.metodoCalagem == metodoCalagem) &&
            (identical(other.doseCalcarioTHa, doseCalcarioTHa) ||
                other.doseCalcarioTHa == doseCalcarioTHa) &&
            (identical(other.vEsperado, vEsperado) ||
                other.vEsperado == vEsperado) &&
            (identical(other.caEsperado, caEsperado) ||
                other.caEsperado == caEsperado) &&
            (identical(other.mgEsperado, mgEsperado) ||
                other.mgEsperado == mgEsperado) &&
            (identical(other.relacaoCaMg, relacaoCaMg) ||
                other.relacaoCaMg == relacaoCaMg) &&
            const DeepCollectionEquality()
                .equals(other._parcelamento, _parcelamento) &&
            (identical(other.gesso, gesso) || other.gesso == gesso) &&
            (identical(other.modoFosforo, modoFosforo) ||
                other.modoFosforo == modoFosforo) &&
            (identical(other.ncFosforo, ncFosforo) ||
                other.ncFosforo == ncFosforo) &&
            (identical(other.doseP2O5KgHa, doseP2O5KgHa) ||
                other.doseP2O5KgHa == doseP2O5KgHa) &&
            (identical(other.legacyP, legacyP) || other.legacyP == legacyP) &&
            (identical(other.criterioPotassio, criterioPotassio) ||
                other.criterioPotassio == criterioPotassio) &&
            (identical(other.ncPotassio, ncPotassio) ||
                other.ncPotassio == ncPotassio) &&
            (identical(other.doseK2OKgHa, doseK2OKgHa) ||
                other.doseK2OKgHa == doseK2OKgHa) &&
            (identical(other.relacoesK, relacoesK) ||
                other.relacoesK == relacoesK) &&
            const DeepCollectionEquality().equals(other._micros, _micros) &&
            const DeepCollectionEquality().equals(other._grupos, _grupos) &&
            (identical(other.doseAbsorcaoP, doseAbsorcaoP) ||
                other.doseAbsorcaoP == doseAbsorcaoP) &&
            (identical(other.doseAbsorcaoK, doseAbsorcaoK) ||
                other.doseAbsorcaoK == doseAbsorcaoK) &&
            const DeepCollectionEquality().equals(other._avisos, _avisos) &&
            (identical(other.argumentos, argumentos) ||
                other.argumentos == argumentos) &&
            const DeepCollectionEquality().equals(other._citacoes, _citacoes));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        analise,
        calibracao,
        base,
        labelAnalise,
        geradaEm,
        metodoCalagem,
        doseCalcarioTHa,
        vEsperado,
        caEsperado,
        mgEsperado,
        relacaoCaMg,
        const DeepCollectionEquality().hash(_parcelamento),
        gesso,
        modoFosforo,
        ncFosforo,
        doseP2O5KgHa,
        legacyP,
        criterioPotassio,
        ncPotassio,
        doseK2OKgHa,
        relacoesK,
        const DeepCollectionEquality().hash(_micros),
        const DeepCollectionEquality().hash(_grupos),
        doseAbsorcaoP,
        doseAbsorcaoK,
        const DeepCollectionEquality().hash(_avisos),
        argumentos,
        const DeepCollectionEquality().hash(_citacoes)
      ]);

  /// Create a copy of ResultadoRecomendacao
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultadoRecomendacaoImplCopyWith<_$ResultadoRecomendacaoImpl>
      get copyWith => __$$ResultadoRecomendacaoImplCopyWithImpl<
          _$ResultadoRecomendacaoImpl>(this, _$identity);
}

abstract class _ResultadoRecomendacao implements ResultadoRecomendacao {
  const factory _ResultadoRecomendacao(
      {required final AnaliseEntity analise,
      required final CalibracaoProfile calibracao,
      final RecomendacaoModel? base,
      final String? labelAnalise,
      final DateTime? geradaEm,
      required final String metodoCalagem,
      required final double doseCalcarioTHa,
      required final double vEsperado,
      required final double caEsperado,
      required final double mgEsperado,
      required final double relacaoCaMg,
      required final List<String> parcelamento,
      required final ResultadoGesso gesso,
      required final String modoFosforo,
      required final double ncFosforo,
      required final double doseP2O5KgHa,
      required final bool legacyP,
      required final String criterioPotassio,
      required final double ncPotassio,
      required final double doseK2OKgHa,
      required final RelacoesK relacoesK,
      required final List<MicroResultado> micros,
      required final List<GrupoResultado> grupos,
      final double? doseAbsorcaoP,
      final double? doseAbsorcaoK,
      required final List<String> avisos,
      required final String argumentos,
      final Map<String, String>? citacoes}) = _$ResultadoRecomendacaoImpl;

  @override
  AnaliseEntity get analise;
  @override
  CalibracaoProfile get calibracao;
  @override
  RecomendacaoModel? get base;
  @override
  String? get labelAnalise;
  @override
  DateTime? get geradaEm;
  @override
  String
      get metodoCalagem; // ── Calcário ──────────────────────────────────────────────────────────
  @override
  double get doseCalcarioTHa;
  @override
  double get vEsperado;
  @override
  double get caEsperado;
  @override
  double get mgEsperado;
  @override
  double get relacaoCaMg;

  /// Parcelas de aplicação quando dose > 4 t/ha
  @override
  List<String>
      get parcelamento; // ── Gesso ─────────────────────────────────────────────────────────────
  @override
  ResultadoGesso
      get gesso; // ── Fósforo ───────────────────────────────────────────────────────────
  /// Modo de cálculo selecionado (ex: '① Correção do solo')
  @override
  String get modoFosforo;
  @override
  double get ncFosforo;
  @override
  double get doseP2O5KgHa;
  @override
  bool
      get legacyP; // ── Potássio ──────────────────────────────────────────────────────────
  /// Critério selecionado (ex: '% K na CTC', 'Teor absoluto')
  @override
  String get criterioPotassio;
  @override
  double get ncPotassio;
  @override
  double get doseK2OKgHa;
  @override
  RelacoesK
      get relacoesK; // ── Micronutrientes ───────────────────────────────────────────────────
  @override
  List<MicroResultado> get micros;
  @override
  List<GrupoResultado>
      get grupos; // ── Absorção / Exportação (T4 — informativo, NÃO somado à dose solo) ────
  /// Dose de P₂O₅ kg/ha necessária para repor o P absorvido/exportado pela cultura.
  /// null quando productividade ou referência de absorção não estão configuradas.
  @override
  double? get doseAbsorcaoP;

  /// Dose de K₂O kg/ha necessária para repor o K absorvido/exportado pela cultura.
  /// null quando productividade ou referência de absorção não estão configuradas.
  @override
  double?
      get doseAbsorcaoK; // ── Diagnóstico ───────────────────────────────────────────────────────
  @override
  List<String> get avisos;
  @override
  String get argumentos;

  /// Citações acadêmicas agrupadas por nutriente
  @override
  Map<String, String>? get citacoes;

  /// Create a copy of ResultadoRecomendacao
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultadoRecomendacaoImplCopyWith<_$ResultadoRecomendacaoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
