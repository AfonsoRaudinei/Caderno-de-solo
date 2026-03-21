// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resultado_calagem.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ResultadoCalagem _$ResultadoCalagemFromJson(Map<String, dynamic> json) {
  return _ResultadoCalagem.fromJson(json);
}

/// @nodoc
mixin _$ResultadoCalagem {
  MetodoCalagem get metodo =>
      throw _privateConstructorUsedError; // ─── Dose calculada ──────────────────────────────────────
  /// NC base, sem correções (t/ha)
  double get ncBase => throw _privateConstructorUsedError;

  /// NC ajustada pela profundidade (t/ha)
  double get ncProfundidade => throw _privateConstructorUsedError;

  /// NC ajustada por PRNT (t/ha)
  double get ncPRNT => throw _privateConstructorUsedError;

  /// Dose final após todas as correções (t/ha)
  double get doseFinal =>
      throw _privateConstructorUsedError; // ─── Nutrientes adicionados pelo calcário ─────────────────
  /// Ca adicionado (cmolc/dm³)  — Dose × FatorCa
  double get caAdicionado => throw _privateConstructorUsedError;

  /// Mg adicionado (cmolc/dm³)  — Dose × FatorMg
  double get mgAdicionado =>
      throw _privateConstructorUsedError; // ─── Novas saturações após calagem (Seção 7 do 01_calagem.md) ───
  /// Nova CTC estimada após calagem
  double get CTCnova => throw _privateConstructorUsedError;

  /// % Ca na CTC após calagem
  double get pctCa => throw _privateConstructorUsedError;

  /// % Mg na CTC após calagem
  double get pctMg => throw _privateConstructorUsedError;

  /// % K na CTC após calagem
  double get pctK => throw _privateConstructorUsedError;

  /// V% final estimada após calagem
  double get vPctFinal =>
      throw _privateConstructorUsedError; // ─── Metadados ─────────────────────────────────────────────
  /// V2 desejado (Método 1 - Saturação por Bases)
  double get v2Desejado => throw _privateConstructorUsedError;

  /// PRNT % do calcário utilizado
  double get prntAplicado => throw _privateConstructorUsedError;

  /// Fator de profundidade
  double get profFator => throw _privateConstructorUsedError;

  /// Fator de superfície de contato
  double get scFator => throw _privateConstructorUsedError;

  /// Tipo de calcário (Dolomítico / Calcítico / Magnesiano)
  String get tipoCalcario => throw _privateConstructorUsedError;

  /// Valor Y usado no cálculo
  double get yUtilizado => throw _privateConstructorUsedError;

  /// Mensagens diagnósticas
  List<String> get observacoes => throw _privateConstructorUsedError;

  /// Serializes this ResultadoCalagem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResultadoCalagem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultadoCalagemCopyWith<ResultadoCalagem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultadoCalagemCopyWith<$Res> {
  factory $ResultadoCalagemCopyWith(
          ResultadoCalagem value, $Res Function(ResultadoCalagem) then) =
      _$ResultadoCalagemCopyWithImpl<$Res, ResultadoCalagem>;
  @useResult
  $Res call(
      {MetodoCalagem metodo,
      double ncBase,
      double ncProfundidade,
      double ncPRNT,
      double doseFinal,
      double caAdicionado,
      double mgAdicionado,
      double CTCnova,
      double pctCa,
      double pctMg,
      double pctK,
      double vPctFinal,
      double v2Desejado,
      double prntAplicado,
      double profFator,
      double scFator,
      String tipoCalcario,
      double yUtilizado,
      List<String> observacoes});
}

/// @nodoc
class _$ResultadoCalagemCopyWithImpl<$Res, $Val extends ResultadoCalagem>
    implements $ResultadoCalagemCopyWith<$Res> {
  _$ResultadoCalagemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResultadoCalagem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metodo = null,
    Object? ncBase = null,
    Object? ncProfundidade = null,
    Object? ncPRNT = null,
    Object? doseFinal = null,
    Object? caAdicionado = null,
    Object? mgAdicionado = null,
    Object? CTCnova = null,
    Object? pctCa = null,
    Object? pctMg = null,
    Object? pctK = null,
    Object? vPctFinal = null,
    Object? v2Desejado = null,
    Object? prntAplicado = null,
    Object? profFator = null,
    Object? scFator = null,
    Object? tipoCalcario = null,
    Object? yUtilizado = null,
    Object? observacoes = null,
  }) {
    return _then(_value.copyWith(
      metodo: null == metodo
          ? _value.metodo
          : metodo // ignore: cast_nullable_to_non_nullable
              as MetodoCalagem,
      ncBase: null == ncBase
          ? _value.ncBase
          : ncBase // ignore: cast_nullable_to_non_nullable
              as double,
      ncProfundidade: null == ncProfundidade
          ? _value.ncProfundidade
          : ncProfundidade // ignore: cast_nullable_to_non_nullable
              as double,
      ncPRNT: null == ncPRNT
          ? _value.ncPRNT
          : ncPRNT // ignore: cast_nullable_to_non_nullable
              as double,
      doseFinal: null == doseFinal
          ? _value.doseFinal
          : doseFinal // ignore: cast_nullable_to_non_nullable
              as double,
      caAdicionado: null == caAdicionado
          ? _value.caAdicionado
          : caAdicionado // ignore: cast_nullable_to_non_nullable
              as double,
      mgAdicionado: null == mgAdicionado
          ? _value.mgAdicionado
          : mgAdicionado // ignore: cast_nullable_to_non_nullable
              as double,
      CTCnova: null == CTCnova
          ? _value.CTCnova
          : CTCnova // ignore: cast_nullable_to_non_nullable
              as double,
      pctCa: null == pctCa
          ? _value.pctCa
          : pctCa // ignore: cast_nullable_to_non_nullable
              as double,
      pctMg: null == pctMg
          ? _value.pctMg
          : pctMg // ignore: cast_nullable_to_non_nullable
              as double,
      pctK: null == pctK
          ? _value.pctK
          : pctK // ignore: cast_nullable_to_non_nullable
              as double,
      vPctFinal: null == vPctFinal
          ? _value.vPctFinal
          : vPctFinal // ignore: cast_nullable_to_non_nullable
              as double,
      v2Desejado: null == v2Desejado
          ? _value.v2Desejado
          : v2Desejado // ignore: cast_nullable_to_non_nullable
              as double,
      prntAplicado: null == prntAplicado
          ? _value.prntAplicado
          : prntAplicado // ignore: cast_nullable_to_non_nullable
              as double,
      profFator: null == profFator
          ? _value.profFator
          : profFator // ignore: cast_nullable_to_non_nullable
              as double,
      scFator: null == scFator
          ? _value.scFator
          : scFator // ignore: cast_nullable_to_non_nullable
              as double,
      tipoCalcario: null == tipoCalcario
          ? _value.tipoCalcario
          : tipoCalcario // ignore: cast_nullable_to_non_nullable
              as String,
      yUtilizado: null == yUtilizado
          ? _value.yUtilizado
          : yUtilizado // ignore: cast_nullable_to_non_nullable
              as double,
      observacoes: null == observacoes
          ? _value.observacoes
          : observacoes // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResultadoCalagemImplCopyWith<$Res>
    implements $ResultadoCalagemCopyWith<$Res> {
  factory _$$ResultadoCalagemImplCopyWith(_$ResultadoCalagemImpl value,
          $Res Function(_$ResultadoCalagemImpl) then) =
      __$$ResultadoCalagemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MetodoCalagem metodo,
      double ncBase,
      double ncProfundidade,
      double ncPRNT,
      double doseFinal,
      double caAdicionado,
      double mgAdicionado,
      double CTCnova,
      double pctCa,
      double pctMg,
      double pctK,
      double vPctFinal,
      double v2Desejado,
      double prntAplicado,
      double profFator,
      double scFator,
      String tipoCalcario,
      double yUtilizado,
      List<String> observacoes});
}

/// @nodoc
class __$$ResultadoCalagemImplCopyWithImpl<$Res>
    extends _$ResultadoCalagemCopyWithImpl<$Res, _$ResultadoCalagemImpl>
    implements _$$ResultadoCalagemImplCopyWith<$Res> {
  __$$ResultadoCalagemImplCopyWithImpl(_$ResultadoCalagemImpl _value,
      $Res Function(_$ResultadoCalagemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResultadoCalagem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metodo = null,
    Object? ncBase = null,
    Object? ncProfundidade = null,
    Object? ncPRNT = null,
    Object? doseFinal = null,
    Object? caAdicionado = null,
    Object? mgAdicionado = null,
    Object? CTCnova = null,
    Object? pctCa = null,
    Object? pctMg = null,
    Object? pctK = null,
    Object? vPctFinal = null,
    Object? v2Desejado = null,
    Object? prntAplicado = null,
    Object? profFator = null,
    Object? scFator = null,
    Object? tipoCalcario = null,
    Object? yUtilizado = null,
    Object? observacoes = null,
  }) {
    return _then(_$ResultadoCalagemImpl(
      metodo: null == metodo
          ? _value.metodo
          : metodo // ignore: cast_nullable_to_non_nullable
              as MetodoCalagem,
      ncBase: null == ncBase
          ? _value.ncBase
          : ncBase // ignore: cast_nullable_to_non_nullable
              as double,
      ncProfundidade: null == ncProfundidade
          ? _value.ncProfundidade
          : ncProfundidade // ignore: cast_nullable_to_non_nullable
              as double,
      ncPRNT: null == ncPRNT
          ? _value.ncPRNT
          : ncPRNT // ignore: cast_nullable_to_non_nullable
              as double,
      doseFinal: null == doseFinal
          ? _value.doseFinal
          : doseFinal // ignore: cast_nullable_to_non_nullable
              as double,
      caAdicionado: null == caAdicionado
          ? _value.caAdicionado
          : caAdicionado // ignore: cast_nullable_to_non_nullable
              as double,
      mgAdicionado: null == mgAdicionado
          ? _value.mgAdicionado
          : mgAdicionado // ignore: cast_nullable_to_non_nullable
              as double,
      CTCnova: null == CTCnova
          ? _value.CTCnova
          : CTCnova // ignore: cast_nullable_to_non_nullable
              as double,
      pctCa: null == pctCa
          ? _value.pctCa
          : pctCa // ignore: cast_nullable_to_non_nullable
              as double,
      pctMg: null == pctMg
          ? _value.pctMg
          : pctMg // ignore: cast_nullable_to_non_nullable
              as double,
      pctK: null == pctK
          ? _value.pctK
          : pctK // ignore: cast_nullable_to_non_nullable
              as double,
      vPctFinal: null == vPctFinal
          ? _value.vPctFinal
          : vPctFinal // ignore: cast_nullable_to_non_nullable
              as double,
      v2Desejado: null == v2Desejado
          ? _value.v2Desejado
          : v2Desejado // ignore: cast_nullable_to_non_nullable
              as double,
      prntAplicado: null == prntAplicado
          ? _value.prntAplicado
          : prntAplicado // ignore: cast_nullable_to_non_nullable
              as double,
      profFator: null == profFator
          ? _value.profFator
          : profFator // ignore: cast_nullable_to_non_nullable
              as double,
      scFator: null == scFator
          ? _value.scFator
          : scFator // ignore: cast_nullable_to_non_nullable
              as double,
      tipoCalcario: null == tipoCalcario
          ? _value.tipoCalcario
          : tipoCalcario // ignore: cast_nullable_to_non_nullable
              as String,
      yUtilizado: null == yUtilizado
          ? _value.yUtilizado
          : yUtilizado // ignore: cast_nullable_to_non_nullable
              as double,
      observacoes: null == observacoes
          ? _value._observacoes
          : observacoes // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResultadoCalagemImpl implements _ResultadoCalagem {
  const _$ResultadoCalagemImpl(
      {required this.metodo,
      this.ncBase = 0.0,
      this.ncProfundidade = 0.0,
      this.ncPRNT = 0.0,
      this.doseFinal = 0.0,
      this.caAdicionado = 0.0,
      this.mgAdicionado = 0.0,
      this.CTCnova = 0.0,
      this.pctCa = 0.0,
      this.pctMg = 0.0,
      this.pctK = 0.0,
      this.vPctFinal = 0.0,
      this.v2Desejado = 0.0,
      this.prntAplicado = 100.0,
      this.profFator = 1.0,
      this.scFator = 1.0,
      this.tipoCalcario = 'Dolomítico',
      this.yUtilizado = 0.0,
      final List<String> observacoes = const []})
      : _observacoes = observacoes;

  factory _$ResultadoCalagemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResultadoCalagemImplFromJson(json);

  @override
  final MetodoCalagem metodo;
// ─── Dose calculada ──────────────────────────────────────
  /// NC base, sem correções (t/ha)
  @override
  @JsonKey()
  final double ncBase;

  /// NC ajustada pela profundidade (t/ha)
  @override
  @JsonKey()
  final double ncProfundidade;

  /// NC ajustada por PRNT (t/ha)
  @override
  @JsonKey()
  final double ncPRNT;

  /// Dose final após todas as correções (t/ha)
  @override
  @JsonKey()
  final double doseFinal;
// ─── Nutrientes adicionados pelo calcário ─────────────────
  /// Ca adicionado (cmolc/dm³)  — Dose × FatorCa
  @override
  @JsonKey()
  final double caAdicionado;

  /// Mg adicionado (cmolc/dm³)  — Dose × FatorMg
  @override
  @JsonKey()
  final double mgAdicionado;
// ─── Novas saturações após calagem (Seção 7 do 01_calagem.md) ───
  /// Nova CTC estimada após calagem
  @override
  @JsonKey()
  final double CTCnova;

  /// % Ca na CTC após calagem
  @override
  @JsonKey()
  final double pctCa;

  /// % Mg na CTC após calagem
  @override
  @JsonKey()
  final double pctMg;

  /// % K na CTC após calagem
  @override
  @JsonKey()
  final double pctK;

  /// V% final estimada após calagem
  @override
  @JsonKey()
  final double vPctFinal;
// ─── Metadados ─────────────────────────────────────────────
  /// V2 desejado (Método 1 - Saturação por Bases)
  @override
  @JsonKey()
  final double v2Desejado;

  /// PRNT % do calcário utilizado
  @override
  @JsonKey()
  final double prntAplicado;

  /// Fator de profundidade
  @override
  @JsonKey()
  final double profFator;

  /// Fator de superfície de contato
  @override
  @JsonKey()
  final double scFator;

  /// Tipo de calcário (Dolomítico / Calcítico / Magnesiano)
  @override
  @JsonKey()
  final String tipoCalcario;

  /// Valor Y usado no cálculo
  @override
  @JsonKey()
  final double yUtilizado;

  /// Mensagens diagnósticas
  final List<String> _observacoes;

  /// Mensagens diagnósticas
  @override
  @JsonKey()
  List<String> get observacoes {
    if (_observacoes is EqualUnmodifiableListView) return _observacoes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_observacoes);
  }

  @override
  String toString() {
    return 'ResultadoCalagem(metodo: $metodo, ncBase: $ncBase, ncProfundidade: $ncProfundidade, ncPRNT: $ncPRNT, doseFinal: $doseFinal, caAdicionado: $caAdicionado, mgAdicionado: $mgAdicionado, CTCnova: $CTCnova, pctCa: $pctCa, pctMg: $pctMg, pctK: $pctK, vPctFinal: $vPctFinal, v2Desejado: $v2Desejado, prntAplicado: $prntAplicado, profFator: $profFator, scFator: $scFator, tipoCalcario: $tipoCalcario, yUtilizado: $yUtilizado, observacoes: $observacoes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultadoCalagemImpl &&
            (identical(other.metodo, metodo) || other.metodo == metodo) &&
            (identical(other.ncBase, ncBase) || other.ncBase == ncBase) &&
            (identical(other.ncProfundidade, ncProfundidade) ||
                other.ncProfundidade == ncProfundidade) &&
            (identical(other.ncPRNT, ncPRNT) || other.ncPRNT == ncPRNT) &&
            (identical(other.doseFinal, doseFinal) ||
                other.doseFinal == doseFinal) &&
            (identical(other.caAdicionado, caAdicionado) ||
                other.caAdicionado == caAdicionado) &&
            (identical(other.mgAdicionado, mgAdicionado) ||
                other.mgAdicionado == mgAdicionado) &&
            (identical(other.CTCnova, CTCnova) || other.CTCnova == CTCnova) &&
            (identical(other.pctCa, pctCa) || other.pctCa == pctCa) &&
            (identical(other.pctMg, pctMg) || other.pctMg == pctMg) &&
            (identical(other.pctK, pctK) || other.pctK == pctK) &&
            (identical(other.vPctFinal, vPctFinal) ||
                other.vPctFinal == vPctFinal) &&
            (identical(other.v2Desejado, v2Desejado) ||
                other.v2Desejado == v2Desejado) &&
            (identical(other.prntAplicado, prntAplicado) ||
                other.prntAplicado == prntAplicado) &&
            (identical(other.profFator, profFator) ||
                other.profFator == profFator) &&
            (identical(other.scFator, scFator) || other.scFator == scFator) &&
            (identical(other.tipoCalcario, tipoCalcario) ||
                other.tipoCalcario == tipoCalcario) &&
            (identical(other.yUtilizado, yUtilizado) ||
                other.yUtilizado == yUtilizado) &&
            const DeepCollectionEquality()
                .equals(other._observacoes, _observacoes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        metodo,
        ncBase,
        ncProfundidade,
        ncPRNT,
        doseFinal,
        caAdicionado,
        mgAdicionado,
        CTCnova,
        pctCa,
        pctMg,
        pctK,
        vPctFinal,
        v2Desejado,
        prntAplicado,
        profFator,
        scFator,
        tipoCalcario,
        yUtilizado,
        const DeepCollectionEquality().hash(_observacoes)
      ]);

  /// Create a copy of ResultadoCalagem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultadoCalagemImplCopyWith<_$ResultadoCalagemImpl> get copyWith =>
      __$$ResultadoCalagemImplCopyWithImpl<_$ResultadoCalagemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResultadoCalagemImplToJson(
      this,
    );
  }
}

abstract class _ResultadoCalagem implements ResultadoCalagem {
  const factory _ResultadoCalagem(
      {required final MetodoCalagem metodo,
      final double ncBase,
      final double ncProfundidade,
      final double ncPRNT,
      final double doseFinal,
      final double caAdicionado,
      final double mgAdicionado,
      final double CTCnova,
      final double pctCa,
      final double pctMg,
      final double pctK,
      final double vPctFinal,
      final double v2Desejado,
      final double prntAplicado,
      final double profFator,
      final double scFator,
      final String tipoCalcario,
      final double yUtilizado,
      final List<String> observacoes}) = _$ResultadoCalagemImpl;

  factory _ResultadoCalagem.fromJson(Map<String, dynamic> json) =
      _$ResultadoCalagemImpl.fromJson;

  @override
  MetodoCalagem
      get metodo; // ─── Dose calculada ──────────────────────────────────────
  /// NC base, sem correções (t/ha)
  @override
  double get ncBase;

  /// NC ajustada pela profundidade (t/ha)
  @override
  double get ncProfundidade;

  /// NC ajustada por PRNT (t/ha)
  @override
  double get ncPRNT;

  /// Dose final após todas as correções (t/ha)
  @override
  double
      get doseFinal; // ─── Nutrientes adicionados pelo calcário ─────────────────
  /// Ca adicionado (cmolc/dm³)  — Dose × FatorCa
  @override
  double get caAdicionado;

  /// Mg adicionado (cmolc/dm³)  — Dose × FatorMg
  @override
  double
      get mgAdicionado; // ─── Novas saturações após calagem (Seção 7 do 01_calagem.md) ───
  /// Nova CTC estimada após calagem
  @override
  double get CTCnova;

  /// % Ca na CTC após calagem
  @override
  double get pctCa;

  /// % Mg na CTC após calagem
  @override
  double get pctMg;

  /// % K na CTC após calagem
  @override
  double get pctK;

  /// V% final estimada após calagem
  @override
  double
      get vPctFinal; // ─── Metadados ─────────────────────────────────────────────
  /// V2 desejado (Método 1 - Saturação por Bases)
  @override
  double get v2Desejado;

  /// PRNT % do calcário utilizado
  @override
  double get prntAplicado;

  /// Fator de profundidade
  @override
  double get profFator;

  /// Fator de superfície de contato
  @override
  double get scFator;

  /// Tipo de calcário (Dolomítico / Calcítico / Magnesiano)
  @override
  String get tipoCalcario;

  /// Valor Y usado no cálculo
  @override
  double get yUtilizado;

  /// Mensagens diagnósticas
  @override
  List<String> get observacoes;

  /// Create a copy of ResultadoCalagem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultadoCalagemImplCopyWith<_$ResultadoCalagemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
