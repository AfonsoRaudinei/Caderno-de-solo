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
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // ── Acidez detalhada ───────────────────────────────────────────────────
  double? get h =>
      throw _privateConstructorUsedError; // Hidrogenio puro (separado de H+Al)
  double? get ctcEfetiva =>
      throw _privateConstructorUsedError; // CTC efetiva (t) = SB + Al
// ── Valores entregues pelo lab (NAO recalcular) ────────────────────────
  double? get ctc =>
      throw _privateConstructorUsedError; // C.T.C. extraida do laudo
  double? get sb =>
      throw _privateConstructorUsedError; // Soma de Bases extraida do laudo
  double? get vPercent =>
      throw _privateConstructorUsedError; // Saturacao por Bases V% extraida do laudo
  double? get mPercent =>
      throw _privateConstructorUsedError; // Saturacao por Al m% extraida do laudo
// ── Metadados do laudo ─────────────────────────────────────────────────
  String? get osLaboratorio =>
      throw _privateConstructorUsedError; // Numero da O.S. do laboratorio
  String? get dataEmissao =>
      throw _privateConstructorUsedError; // Data de emissao do laudo
  String? get consultor =>
      throw _privateConstructorUsedError; // Empresa consultora
  String? get labTemplateId =>
      throw _privateConstructorUsedError; // ID do template usado na importacao
// ── Unidades (para exibicao e conversao) ──────────────────────────────
  String? get unidadeNutrientes =>
      throw _privateConstructorUsedError; // "mmolc/dm3" ou "cmolc/dm3"
  String? get unidadeMO =>
      throw _privateConstructorUsedError; // "g/dm3", "dag/kg" ou "%"
  String? get unidadeTextura =>
      throw _privateConstructorUsedError; // "g/kg", "g/dm3" ou "%"
// ── Textura detalhada (MB separa areia grossa/fina) ───────────────────
  double? get cascalho => throw _privateConstructorUsedError;
  double? get areiaGrossa => throw _privateConstructorUsedError;
  double? get areiaFina =>
      throw _privateConstructorUsedError; // ── Micronutrientes adicionais ─────────────────────────────────────────
  double? get co =>
      throw _privateConstructorUsedError; // Cobalto (mg/dm3) -- MB
// ── Metadados adicionais do laudo ──────────────────────────────────────
  String? get municipio => throw _privateConstructorUsedError;
  String? get responsavelTecnico => throw _privateConstructorUsedError;
  String? get cnpjCliente =>
      throw _privateConstructorUsedError; // ── Fosforo adicional ─────────────────────────────────────────────────
  double? get pTotal =>
      throw _privateConstructorUsedError; // P Total em % -- Sellar
// ── Textura adicional ─────────────────────────────────────────────
  String? get classificacaoTextura =>
      throw _privateConstructorUsedError; // 'Media', 'Argilosa', 'Arenosa'
  int? get tipoSoloMapa =>
      throw _privateConstructorUsedError; // Tipo MAPA (1, 2, 3) -- IN02/2008
// ── Metadados adicionais Sellar ───────────────────────────────────────
  String? get solicitante => throw _privateConstructorUsedError;
  String? get convenio => throw _privateConstructorUsedError;
  String? get creaResponsavel => throw _privateConstructorUsedError;
  String? get cnpjLaboratorio =>
      throw _privateConstructorUsedError; // ── Campos Solum ──────────────────────────────────────────────────────
  String? get dataInicioEnsaio =>
      throw _privateConstructorUsedError; // Data de inicio dos ensaios
  String? get dataFimEnsaio =>
      throw _privateConstructorUsedError; // Data de fim dos ensaios
  String? get matriculaImovel =>
      throw _privateConstructorUsedError; // Matricula do imovel (SIGEF/SNCR)
  String? get codigoInterno =>
      throw _privateConstructorUsedError; // Codigo interno Solum
  String? get codigoExternoAmostra =>
      throw _privateConstructorUsedError; // Codigo externo da amostra
// ── Campos Exata Brasil ───────────────────────────────────────────────
  double? get caMaisMg =>
      throw _privateConstructorUsedError; // Ca+Mg somado (campo separado Exata)
  double? get kMgDm3 =>
      throw _privateConstructorUsedError; // K em mg/dm3 por NH4Cl (Exata)
// Micronutrientes por Mehlich I
  double? get cuMehlich =>
      throw _privateConstructorUsedError; // Cobre por Mehlich
  double? get feMehlich =>
      throw _privateConstructorUsedError; // Ferro por Mehlich
  double? get mnMehlich =>
      throw _privateConstructorUsedError; // Manganes por Mehlich
  double? get znMehlich =>
      throw _privateConstructorUsedError; // Zinco por Mehlich
// Micronutrientes por DTPA
  double? get cuDtpa => throw _privateConstructorUsedError; // Cobre por DTPA
  double? get feDtpa => throw _privateConstructorUsedError; // Ferro por DTPA
  double? get mnDtpa => throw _privateConstructorUsedError; // Manganes por DTPA
  double? get znDtpa => throw _privateConstructorUsedError; // Zinco por DTPA
// Metadados adicionais do laudo (Exata)
  String? get dataRecebimento =>
      throw _privateConstructorUsedError; // Data de recebimento da amostra no lab
  String? get numeroRelatorio =>
      throw _privateConstructorUsedError; // No do relatorio (ex: 16738.2025.V0.U)
  String? get codigoVerificacao =>
      throw _privateConstructorUsedError; // Codigo de verificacao do laudo digital
  String? get codigoTalhao =>
      throw _privateConstructorUsedError; // Codigo do talhao (T01, T02, 274)
  int? get totalAmostras => throw _privateConstructorUsedError;

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
      @TimestampConverter() DateTime? updatedAt,
      double? h,
      double? ctcEfetiva,
      double? ctc,
      double? sb,
      double? vPercent,
      double? mPercent,
      String? osLaboratorio,
      String? dataEmissao,
      String? consultor,
      String? labTemplateId,
      String? unidadeNutrientes,
      String? unidadeMO,
      String? unidadeTextura,
      double? cascalho,
      double? areiaGrossa,
      double? areiaFina,
      double? co,
      String? municipio,
      String? responsavelTecnico,
      String? cnpjCliente,
      double? pTotal,
      String? classificacaoTextura,
      int? tipoSoloMapa,
      String? solicitante,
      String? convenio,
      String? creaResponsavel,
      String? cnpjLaboratorio,
      String? dataInicioEnsaio,
      String? dataFimEnsaio,
      String? matriculaImovel,
      String? codigoInterno,
      String? codigoExternoAmostra,
      double? caMaisMg,
      double? kMgDm3,
      double? cuMehlich,
      double? feMehlich,
      double? mnMehlich,
      double? znMehlich,
      double? cuDtpa,
      double? feDtpa,
      double? mnDtpa,
      double? znDtpa,
      String? dataRecebimento,
      String? numeroRelatorio,
      String? codigoVerificacao,
      String? codigoTalhao,
      int? totalAmostras});
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
    Object? h = freezed,
    Object? ctcEfetiva = freezed,
    Object? ctc = freezed,
    Object? sb = freezed,
    Object? vPercent = freezed,
    Object? mPercent = freezed,
    Object? osLaboratorio = freezed,
    Object? dataEmissao = freezed,
    Object? consultor = freezed,
    Object? labTemplateId = freezed,
    Object? unidadeNutrientes = freezed,
    Object? unidadeMO = freezed,
    Object? unidadeTextura = freezed,
    Object? cascalho = freezed,
    Object? areiaGrossa = freezed,
    Object? areiaFina = freezed,
    Object? co = freezed,
    Object? municipio = freezed,
    Object? responsavelTecnico = freezed,
    Object? cnpjCliente = freezed,
    Object? pTotal = freezed,
    Object? classificacaoTextura = freezed,
    Object? tipoSoloMapa = freezed,
    Object? solicitante = freezed,
    Object? convenio = freezed,
    Object? creaResponsavel = freezed,
    Object? cnpjLaboratorio = freezed,
    Object? dataInicioEnsaio = freezed,
    Object? dataFimEnsaio = freezed,
    Object? matriculaImovel = freezed,
    Object? codigoInterno = freezed,
    Object? codigoExternoAmostra = freezed,
    Object? caMaisMg = freezed,
    Object? kMgDm3 = freezed,
    Object? cuMehlich = freezed,
    Object? feMehlich = freezed,
    Object? mnMehlich = freezed,
    Object? znMehlich = freezed,
    Object? cuDtpa = freezed,
    Object? feDtpa = freezed,
    Object? mnDtpa = freezed,
    Object? znDtpa = freezed,
    Object? dataRecebimento = freezed,
    Object? numeroRelatorio = freezed,
    Object? codigoVerificacao = freezed,
    Object? codigoTalhao = freezed,
    Object? totalAmostras = freezed,
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
      h: freezed == h
          ? _value.h
          : h // ignore: cast_nullable_to_non_nullable
              as double?,
      ctcEfetiva: freezed == ctcEfetiva
          ? _value.ctcEfetiva
          : ctcEfetiva // ignore: cast_nullable_to_non_nullable
              as double?,
      ctc: freezed == ctc
          ? _value.ctc
          : ctc // ignore: cast_nullable_to_non_nullable
              as double?,
      sb: freezed == sb
          ? _value.sb
          : sb // ignore: cast_nullable_to_non_nullable
              as double?,
      vPercent: freezed == vPercent
          ? _value.vPercent
          : vPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      mPercent: freezed == mPercent
          ? _value.mPercent
          : mPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      osLaboratorio: freezed == osLaboratorio
          ? _value.osLaboratorio
          : osLaboratorio // ignore: cast_nullable_to_non_nullable
              as String?,
      dataEmissao: freezed == dataEmissao
          ? _value.dataEmissao
          : dataEmissao // ignore: cast_nullable_to_non_nullable
              as String?,
      consultor: freezed == consultor
          ? _value.consultor
          : consultor // ignore: cast_nullable_to_non_nullable
              as String?,
      labTemplateId: freezed == labTemplateId
          ? _value.labTemplateId
          : labTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      unidadeNutrientes: freezed == unidadeNutrientes
          ? _value.unidadeNutrientes
          : unidadeNutrientes // ignore: cast_nullable_to_non_nullable
              as String?,
      unidadeMO: freezed == unidadeMO
          ? _value.unidadeMO
          : unidadeMO // ignore: cast_nullable_to_non_nullable
              as String?,
      unidadeTextura: freezed == unidadeTextura
          ? _value.unidadeTextura
          : unidadeTextura // ignore: cast_nullable_to_non_nullable
              as String?,
      cascalho: freezed == cascalho
          ? _value.cascalho
          : cascalho // ignore: cast_nullable_to_non_nullable
              as double?,
      areiaGrossa: freezed == areiaGrossa
          ? _value.areiaGrossa
          : areiaGrossa // ignore: cast_nullable_to_non_nullable
              as double?,
      areiaFina: freezed == areiaFina
          ? _value.areiaFina
          : areiaFina // ignore: cast_nullable_to_non_nullable
              as double?,
      co: freezed == co
          ? _value.co
          : co // ignore: cast_nullable_to_non_nullable
              as double?,
      municipio: freezed == municipio
          ? _value.municipio
          : municipio // ignore: cast_nullable_to_non_nullable
              as String?,
      responsavelTecnico: freezed == responsavelTecnico
          ? _value.responsavelTecnico
          : responsavelTecnico // ignore: cast_nullable_to_non_nullable
              as String?,
      cnpjCliente: freezed == cnpjCliente
          ? _value.cnpjCliente
          : cnpjCliente // ignore: cast_nullable_to_non_nullable
              as String?,
      pTotal: freezed == pTotal
          ? _value.pTotal
          : pTotal // ignore: cast_nullable_to_non_nullable
              as double?,
      classificacaoTextura: freezed == classificacaoTextura
          ? _value.classificacaoTextura
          : classificacaoTextura // ignore: cast_nullable_to_non_nullable
              as String?,
      tipoSoloMapa: freezed == tipoSoloMapa
          ? _value.tipoSoloMapa
          : tipoSoloMapa // ignore: cast_nullable_to_non_nullable
              as int?,
      solicitante: freezed == solicitante
          ? _value.solicitante
          : solicitante // ignore: cast_nullable_to_non_nullable
              as String?,
      convenio: freezed == convenio
          ? _value.convenio
          : convenio // ignore: cast_nullable_to_non_nullable
              as String?,
      creaResponsavel: freezed == creaResponsavel
          ? _value.creaResponsavel
          : creaResponsavel // ignore: cast_nullable_to_non_nullable
              as String?,
      cnpjLaboratorio: freezed == cnpjLaboratorio
          ? _value.cnpjLaboratorio
          : cnpjLaboratorio // ignore: cast_nullable_to_non_nullable
              as String?,
      dataInicioEnsaio: freezed == dataInicioEnsaio
          ? _value.dataInicioEnsaio
          : dataInicioEnsaio // ignore: cast_nullable_to_non_nullable
              as String?,
      dataFimEnsaio: freezed == dataFimEnsaio
          ? _value.dataFimEnsaio
          : dataFimEnsaio // ignore: cast_nullable_to_non_nullable
              as String?,
      matriculaImovel: freezed == matriculaImovel
          ? _value.matriculaImovel
          : matriculaImovel // ignore: cast_nullable_to_non_nullable
              as String?,
      codigoInterno: freezed == codigoInterno
          ? _value.codigoInterno
          : codigoInterno // ignore: cast_nullable_to_non_nullable
              as String?,
      codigoExternoAmostra: freezed == codigoExternoAmostra
          ? _value.codigoExternoAmostra
          : codigoExternoAmostra // ignore: cast_nullable_to_non_nullable
              as String?,
      caMaisMg: freezed == caMaisMg
          ? _value.caMaisMg
          : caMaisMg // ignore: cast_nullable_to_non_nullable
              as double?,
      kMgDm3: freezed == kMgDm3
          ? _value.kMgDm3
          : kMgDm3 // ignore: cast_nullable_to_non_nullable
              as double?,
      cuMehlich: freezed == cuMehlich
          ? _value.cuMehlich
          : cuMehlich // ignore: cast_nullable_to_non_nullable
              as double?,
      feMehlich: freezed == feMehlich
          ? _value.feMehlich
          : feMehlich // ignore: cast_nullable_to_non_nullable
              as double?,
      mnMehlich: freezed == mnMehlich
          ? _value.mnMehlich
          : mnMehlich // ignore: cast_nullable_to_non_nullable
              as double?,
      znMehlich: freezed == znMehlich
          ? _value.znMehlich
          : znMehlich // ignore: cast_nullable_to_non_nullable
              as double?,
      cuDtpa: freezed == cuDtpa
          ? _value.cuDtpa
          : cuDtpa // ignore: cast_nullable_to_non_nullable
              as double?,
      feDtpa: freezed == feDtpa
          ? _value.feDtpa
          : feDtpa // ignore: cast_nullable_to_non_nullable
              as double?,
      mnDtpa: freezed == mnDtpa
          ? _value.mnDtpa
          : mnDtpa // ignore: cast_nullable_to_non_nullable
              as double?,
      znDtpa: freezed == znDtpa
          ? _value.znDtpa
          : znDtpa // ignore: cast_nullable_to_non_nullable
              as double?,
      dataRecebimento: freezed == dataRecebimento
          ? _value.dataRecebimento
          : dataRecebimento // ignore: cast_nullable_to_non_nullable
              as String?,
      numeroRelatorio: freezed == numeroRelatorio
          ? _value.numeroRelatorio
          : numeroRelatorio // ignore: cast_nullable_to_non_nullable
              as String?,
      codigoVerificacao: freezed == codigoVerificacao
          ? _value.codigoVerificacao
          : codigoVerificacao // ignore: cast_nullable_to_non_nullable
              as String?,
      codigoTalhao: freezed == codigoTalhao
          ? _value.codigoTalhao
          : codigoTalhao // ignore: cast_nullable_to_non_nullable
              as String?,
      totalAmostras: freezed == totalAmostras
          ? _value.totalAmostras
          : totalAmostras // ignore: cast_nullable_to_non_nullable
              as int?,
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
      @TimestampConverter() DateTime? updatedAt,
      double? h,
      double? ctcEfetiva,
      double? ctc,
      double? sb,
      double? vPercent,
      double? mPercent,
      String? osLaboratorio,
      String? dataEmissao,
      String? consultor,
      String? labTemplateId,
      String? unidadeNutrientes,
      String? unidadeMO,
      String? unidadeTextura,
      double? cascalho,
      double? areiaGrossa,
      double? areiaFina,
      double? co,
      String? municipio,
      String? responsavelTecnico,
      String? cnpjCliente,
      double? pTotal,
      String? classificacaoTextura,
      int? tipoSoloMapa,
      String? solicitante,
      String? convenio,
      String? creaResponsavel,
      String? cnpjLaboratorio,
      String? dataInicioEnsaio,
      String? dataFimEnsaio,
      String? matriculaImovel,
      String? codigoInterno,
      String? codigoExternoAmostra,
      double? caMaisMg,
      double? kMgDm3,
      double? cuMehlich,
      double? feMehlich,
      double? mnMehlich,
      double? znMehlich,
      double? cuDtpa,
      double? feDtpa,
      double? mnDtpa,
      double? znDtpa,
      String? dataRecebimento,
      String? numeroRelatorio,
      String? codigoVerificacao,
      String? codigoTalhao,
      int? totalAmostras});
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
    Object? h = freezed,
    Object? ctcEfetiva = freezed,
    Object? ctc = freezed,
    Object? sb = freezed,
    Object? vPercent = freezed,
    Object? mPercent = freezed,
    Object? osLaboratorio = freezed,
    Object? dataEmissao = freezed,
    Object? consultor = freezed,
    Object? labTemplateId = freezed,
    Object? unidadeNutrientes = freezed,
    Object? unidadeMO = freezed,
    Object? unidadeTextura = freezed,
    Object? cascalho = freezed,
    Object? areiaGrossa = freezed,
    Object? areiaFina = freezed,
    Object? co = freezed,
    Object? municipio = freezed,
    Object? responsavelTecnico = freezed,
    Object? cnpjCliente = freezed,
    Object? pTotal = freezed,
    Object? classificacaoTextura = freezed,
    Object? tipoSoloMapa = freezed,
    Object? solicitante = freezed,
    Object? convenio = freezed,
    Object? creaResponsavel = freezed,
    Object? cnpjLaboratorio = freezed,
    Object? dataInicioEnsaio = freezed,
    Object? dataFimEnsaio = freezed,
    Object? matriculaImovel = freezed,
    Object? codigoInterno = freezed,
    Object? codigoExternoAmostra = freezed,
    Object? caMaisMg = freezed,
    Object? kMgDm3 = freezed,
    Object? cuMehlich = freezed,
    Object? feMehlich = freezed,
    Object? mnMehlich = freezed,
    Object? znMehlich = freezed,
    Object? cuDtpa = freezed,
    Object? feDtpa = freezed,
    Object? mnDtpa = freezed,
    Object? znDtpa = freezed,
    Object? dataRecebimento = freezed,
    Object? numeroRelatorio = freezed,
    Object? codigoVerificacao = freezed,
    Object? codigoTalhao = freezed,
    Object? totalAmostras = freezed,
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
      h: freezed == h
          ? _value.h
          : h // ignore: cast_nullable_to_non_nullable
              as double?,
      ctcEfetiva: freezed == ctcEfetiva
          ? _value.ctcEfetiva
          : ctcEfetiva // ignore: cast_nullable_to_non_nullable
              as double?,
      ctc: freezed == ctc
          ? _value.ctc
          : ctc // ignore: cast_nullable_to_non_nullable
              as double?,
      sb: freezed == sb
          ? _value.sb
          : sb // ignore: cast_nullable_to_non_nullable
              as double?,
      vPercent: freezed == vPercent
          ? _value.vPercent
          : vPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      mPercent: freezed == mPercent
          ? _value.mPercent
          : mPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      osLaboratorio: freezed == osLaboratorio
          ? _value.osLaboratorio
          : osLaboratorio // ignore: cast_nullable_to_non_nullable
              as String?,
      dataEmissao: freezed == dataEmissao
          ? _value.dataEmissao
          : dataEmissao // ignore: cast_nullable_to_non_nullable
              as String?,
      consultor: freezed == consultor
          ? _value.consultor
          : consultor // ignore: cast_nullable_to_non_nullable
              as String?,
      labTemplateId: freezed == labTemplateId
          ? _value.labTemplateId
          : labTemplateId // ignore: cast_nullable_to_non_nullable
              as String?,
      unidadeNutrientes: freezed == unidadeNutrientes
          ? _value.unidadeNutrientes
          : unidadeNutrientes // ignore: cast_nullable_to_non_nullable
              as String?,
      unidadeMO: freezed == unidadeMO
          ? _value.unidadeMO
          : unidadeMO // ignore: cast_nullable_to_non_nullable
              as String?,
      unidadeTextura: freezed == unidadeTextura
          ? _value.unidadeTextura
          : unidadeTextura // ignore: cast_nullable_to_non_nullable
              as String?,
      cascalho: freezed == cascalho
          ? _value.cascalho
          : cascalho // ignore: cast_nullable_to_non_nullable
              as double?,
      areiaGrossa: freezed == areiaGrossa
          ? _value.areiaGrossa
          : areiaGrossa // ignore: cast_nullable_to_non_nullable
              as double?,
      areiaFina: freezed == areiaFina
          ? _value.areiaFina
          : areiaFina // ignore: cast_nullable_to_non_nullable
              as double?,
      co: freezed == co
          ? _value.co
          : co // ignore: cast_nullable_to_non_nullable
              as double?,
      municipio: freezed == municipio
          ? _value.municipio
          : municipio // ignore: cast_nullable_to_non_nullable
              as String?,
      responsavelTecnico: freezed == responsavelTecnico
          ? _value.responsavelTecnico
          : responsavelTecnico // ignore: cast_nullable_to_non_nullable
              as String?,
      cnpjCliente: freezed == cnpjCliente
          ? _value.cnpjCliente
          : cnpjCliente // ignore: cast_nullable_to_non_nullable
              as String?,
      pTotal: freezed == pTotal
          ? _value.pTotal
          : pTotal // ignore: cast_nullable_to_non_nullable
              as double?,
      classificacaoTextura: freezed == classificacaoTextura
          ? _value.classificacaoTextura
          : classificacaoTextura // ignore: cast_nullable_to_non_nullable
              as String?,
      tipoSoloMapa: freezed == tipoSoloMapa
          ? _value.tipoSoloMapa
          : tipoSoloMapa // ignore: cast_nullable_to_non_nullable
              as int?,
      solicitante: freezed == solicitante
          ? _value.solicitante
          : solicitante // ignore: cast_nullable_to_non_nullable
              as String?,
      convenio: freezed == convenio
          ? _value.convenio
          : convenio // ignore: cast_nullable_to_non_nullable
              as String?,
      creaResponsavel: freezed == creaResponsavel
          ? _value.creaResponsavel
          : creaResponsavel // ignore: cast_nullable_to_non_nullable
              as String?,
      cnpjLaboratorio: freezed == cnpjLaboratorio
          ? _value.cnpjLaboratorio
          : cnpjLaboratorio // ignore: cast_nullable_to_non_nullable
              as String?,
      dataInicioEnsaio: freezed == dataInicioEnsaio
          ? _value.dataInicioEnsaio
          : dataInicioEnsaio // ignore: cast_nullable_to_non_nullable
              as String?,
      dataFimEnsaio: freezed == dataFimEnsaio
          ? _value.dataFimEnsaio
          : dataFimEnsaio // ignore: cast_nullable_to_non_nullable
              as String?,
      matriculaImovel: freezed == matriculaImovel
          ? _value.matriculaImovel
          : matriculaImovel // ignore: cast_nullable_to_non_nullable
              as String?,
      codigoInterno: freezed == codigoInterno
          ? _value.codigoInterno
          : codigoInterno // ignore: cast_nullable_to_non_nullable
              as String?,
      codigoExternoAmostra: freezed == codigoExternoAmostra
          ? _value.codigoExternoAmostra
          : codigoExternoAmostra // ignore: cast_nullable_to_non_nullable
              as String?,
      caMaisMg: freezed == caMaisMg
          ? _value.caMaisMg
          : caMaisMg // ignore: cast_nullable_to_non_nullable
              as double?,
      kMgDm3: freezed == kMgDm3
          ? _value.kMgDm3
          : kMgDm3 // ignore: cast_nullable_to_non_nullable
              as double?,
      cuMehlich: freezed == cuMehlich
          ? _value.cuMehlich
          : cuMehlich // ignore: cast_nullable_to_non_nullable
              as double?,
      feMehlich: freezed == feMehlich
          ? _value.feMehlich
          : feMehlich // ignore: cast_nullable_to_non_nullable
              as double?,
      mnMehlich: freezed == mnMehlich
          ? _value.mnMehlich
          : mnMehlich // ignore: cast_nullable_to_non_nullable
              as double?,
      znMehlich: freezed == znMehlich
          ? _value.znMehlich
          : znMehlich // ignore: cast_nullable_to_non_nullable
              as double?,
      cuDtpa: freezed == cuDtpa
          ? _value.cuDtpa
          : cuDtpa // ignore: cast_nullable_to_non_nullable
              as double?,
      feDtpa: freezed == feDtpa
          ? _value.feDtpa
          : feDtpa // ignore: cast_nullable_to_non_nullable
              as double?,
      mnDtpa: freezed == mnDtpa
          ? _value.mnDtpa
          : mnDtpa // ignore: cast_nullable_to_non_nullable
              as double?,
      znDtpa: freezed == znDtpa
          ? _value.znDtpa
          : znDtpa // ignore: cast_nullable_to_non_nullable
              as double?,
      dataRecebimento: freezed == dataRecebimento
          ? _value.dataRecebimento
          : dataRecebimento // ignore: cast_nullable_to_non_nullable
              as String?,
      numeroRelatorio: freezed == numeroRelatorio
          ? _value.numeroRelatorio
          : numeroRelatorio // ignore: cast_nullable_to_non_nullable
              as String?,
      codigoVerificacao: freezed == codigoVerificacao
          ? _value.codigoVerificacao
          : codigoVerificacao // ignore: cast_nullable_to_non_nullable
              as String?,
      codigoTalhao: freezed == codigoTalhao
          ? _value.codigoTalhao
          : codigoTalhao // ignore: cast_nullable_to_non_nullable
              as String?,
      totalAmostras: freezed == totalAmostras
          ? _value.totalAmostras
          : totalAmostras // ignore: cast_nullable_to_non_nullable
              as int?,
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
      @TimestampConverter() this.updatedAt,
      this.h,
      this.ctcEfetiva,
      this.ctc,
      this.sb,
      this.vPercent,
      this.mPercent,
      this.osLaboratorio,
      this.dataEmissao,
      this.consultor,
      this.labTemplateId,
      this.unidadeNutrientes,
      this.unidadeMO,
      this.unidadeTextura,
      this.cascalho,
      this.areiaGrossa,
      this.areiaFina,
      this.co,
      this.municipio,
      this.responsavelTecnico,
      this.cnpjCliente,
      this.pTotal,
      this.classificacaoTextura,
      this.tipoSoloMapa,
      this.solicitante,
      this.convenio,
      this.creaResponsavel,
      this.cnpjLaboratorio,
      this.dataInicioEnsaio,
      this.dataFimEnsaio,
      this.matriculaImovel,
      this.codigoInterno,
      this.codigoExternoAmostra,
      this.caMaisMg,
      this.kMgDm3,
      this.cuMehlich,
      this.feMehlich,
      this.mnMehlich,
      this.znMehlich,
      this.cuDtpa,
      this.feDtpa,
      this.mnDtpa,
      this.znDtpa,
      this.dataRecebimento,
      this.numeroRelatorio,
      this.codigoVerificacao,
      this.codigoTalhao,
      this.totalAmostras})
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
// ── Acidez detalhada ───────────────────────────────────────────────────
  @override
  final double? h;
// Hidrogenio puro (separado de H+Al)
  @override
  final double? ctcEfetiva;
// CTC efetiva (t) = SB + Al
// ── Valores entregues pelo lab (NAO recalcular) ────────────────────────
  @override
  final double? ctc;
// C.T.C. extraida do laudo
  @override
  final double? sb;
// Soma de Bases extraida do laudo
  @override
  final double? vPercent;
// Saturacao por Bases V% extraida do laudo
  @override
  final double? mPercent;
// Saturacao por Al m% extraida do laudo
// ── Metadados do laudo ─────────────────────────────────────────────────
  @override
  final String? osLaboratorio;
// Numero da O.S. do laboratorio
  @override
  final String? dataEmissao;
// Data de emissao do laudo
  @override
  final String? consultor;
// Empresa consultora
  @override
  final String? labTemplateId;
// ID do template usado na importacao
// ── Unidades (para exibicao e conversao) ──────────────────────────────
  @override
  final String? unidadeNutrientes;
// "mmolc/dm3" ou "cmolc/dm3"
  @override
  final String? unidadeMO;
// "g/dm3", "dag/kg" ou "%"
  @override
  final String? unidadeTextura;
// "g/kg", "g/dm3" ou "%"
// ── Textura detalhada (MB separa areia grossa/fina) ───────────────────
  @override
  final double? cascalho;
  @override
  final double? areiaGrossa;
  @override
  final double? areiaFina;
// ── Micronutrientes adicionais ─────────────────────────────────────────
  @override
  final double? co;
// Cobalto (mg/dm3) -- MB
// ── Metadados adicionais do laudo ──────────────────────────────────────
  @override
  final String? municipio;
  @override
  final String? responsavelTecnico;
  @override
  final String? cnpjCliente;
// ── Fosforo adicional ─────────────────────────────────────────────────
  @override
  final double? pTotal;
// P Total em % -- Sellar
// ── Textura adicional ─────────────────────────────────────────────
  @override
  final String? classificacaoTextura;
// 'Media', 'Argilosa', 'Arenosa'
  @override
  final int? tipoSoloMapa;
// Tipo MAPA (1, 2, 3) -- IN02/2008
// ── Metadados adicionais Sellar ───────────────────────────────────────
  @override
  final String? solicitante;
  @override
  final String? convenio;
  @override
  final String? creaResponsavel;
  @override
  final String? cnpjLaboratorio;
// ── Campos Solum ──────────────────────────────────────────────────────
  @override
  final String? dataInicioEnsaio;
// Data de inicio dos ensaios
  @override
  final String? dataFimEnsaio;
// Data de fim dos ensaios
  @override
  final String? matriculaImovel;
// Matricula do imovel (SIGEF/SNCR)
  @override
  final String? codigoInterno;
// Codigo interno Solum
  @override
  final String? codigoExternoAmostra;
// Codigo externo da amostra
// ── Campos Exata Brasil ───────────────────────────────────────────────
  @override
  final double? caMaisMg;
// Ca+Mg somado (campo separado Exata)
  @override
  final double? kMgDm3;
// K em mg/dm3 por NH4Cl (Exata)
// Micronutrientes por Mehlich I
  @override
  final double? cuMehlich;
// Cobre por Mehlich
  @override
  final double? feMehlich;
// Ferro por Mehlich
  @override
  final double? mnMehlich;
// Manganes por Mehlich
  @override
  final double? znMehlich;
// Zinco por Mehlich
// Micronutrientes por DTPA
  @override
  final double? cuDtpa;
// Cobre por DTPA
  @override
  final double? feDtpa;
// Ferro por DTPA
  @override
  final double? mnDtpa;
// Manganes por DTPA
  @override
  final double? znDtpa;
// Zinco por DTPA
// Metadados adicionais do laudo (Exata)
  @override
  final String? dataRecebimento;
// Data de recebimento da amostra no lab
  @override
  final String? numeroRelatorio;
// No do relatorio (ex: 16738.2025.V0.U)
  @override
  final String? codigoVerificacao;
// Codigo de verificacao do laudo digital
  @override
  final String? codigoTalhao;
// Codigo do talhao (T01, T02, 274)
  @override
  final int? totalAmostras;

  @override
  String toString() {
    return 'AnaliseModel(id: $id, userId: $userId, fazenda: $fazenda, produtor: $produtor, talhao: $talhao, numeroAmostra: $numeroAmostra, laboratorio: $laboratorio, profundidade: $profundidade, dataColeta: $dataColeta, status: $status, cultura: $cultura, safra: $safra, latitude: $latitude, longitude: $longitude, descricaoLocal: $descricaoLocal, pdfUrl: $pdfUrl, argila: $argila, silte: $silte, areiaTotal: $areiaTotal, phAgua: $phAgua, phSmp: $phSmp, phCaCl2: $phCaCl2, materiaOrganica: $materiaOrganica, carbonoOrganico: $carbonoOrganico, pMehlich: $pMehlich, pResina: $pResina, pRem: $pRem, s020: $s020, s2040: $s2040, k: $k, ca: $ca, mg: $mg, al: $al, hMaisAl: $hMaisAl, na: $na, b: $b, cu: $cu, fe: $fe, mn: $mn, zn: $zn, ni: $ni, mo: $mo, se: $se, fontePrincipalP: $fontePrincipalP, createdAt: $createdAt, updatedAt: $updatedAt, h: $h, ctcEfetiva: $ctcEfetiva, ctc: $ctc, sb: $sb, vPercent: $vPercent, mPercent: $mPercent, osLaboratorio: $osLaboratorio, dataEmissao: $dataEmissao, consultor: $consultor, labTemplateId: $labTemplateId, unidadeNutrientes: $unidadeNutrientes, unidadeMO: $unidadeMO, unidadeTextura: $unidadeTextura, cascalho: $cascalho, areiaGrossa: $areiaGrossa, areiaFina: $areiaFina, co: $co, municipio: $municipio, responsavelTecnico: $responsavelTecnico, cnpjCliente: $cnpjCliente, pTotal: $pTotal, classificacaoTextura: $classificacaoTextura, tipoSoloMapa: $tipoSoloMapa, solicitante: $solicitante, convenio: $convenio, creaResponsavel: $creaResponsavel, cnpjLaboratorio: $cnpjLaboratorio, dataInicioEnsaio: $dataInicioEnsaio, dataFimEnsaio: $dataFimEnsaio, matriculaImovel: $matriculaImovel, codigoInterno: $codigoInterno, codigoExternoAmostra: $codigoExternoAmostra, caMaisMg: $caMaisMg, kMgDm3: $kMgDm3, cuMehlich: $cuMehlich, feMehlich: $feMehlich, mnMehlich: $mnMehlich, znMehlich: $znMehlich, cuDtpa: $cuDtpa, feDtpa: $feDtpa, mnDtpa: $mnDtpa, znDtpa: $znDtpa, dataRecebimento: $dataRecebimento, numeroRelatorio: $numeroRelatorio, codigoVerificacao: $codigoVerificacao, codigoTalhao: $codigoTalhao, totalAmostras: $totalAmostras)';
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
                other.updatedAt == updatedAt) &&
            (identical(other.h, h) || other.h == h) &&
            (identical(other.ctcEfetiva, ctcEfetiva) ||
                other.ctcEfetiva == ctcEfetiva) &&
            (identical(other.ctc, ctc) || other.ctc == ctc) &&
            (identical(other.sb, sb) || other.sb == sb) &&
            (identical(other.vPercent, vPercent) ||
                other.vPercent == vPercent) &&
            (identical(other.mPercent, mPercent) ||
                other.mPercent == mPercent) &&
            (identical(other.osLaboratorio, osLaboratorio) ||
                other.osLaboratorio == osLaboratorio) &&
            (identical(other.dataEmissao, dataEmissao) ||
                other.dataEmissao == dataEmissao) &&
            (identical(other.consultor, consultor) ||
                other.consultor == consultor) &&
            (identical(other.labTemplateId, labTemplateId) ||
                other.labTemplateId == labTemplateId) &&
            (identical(other.unidadeNutrientes, unidadeNutrientes) ||
                other.unidadeNutrientes == unidadeNutrientes) &&
            (identical(other.unidadeMO, unidadeMO) ||
                other.unidadeMO == unidadeMO) &&
            (identical(other.unidadeTextura, unidadeTextura) ||
                other.unidadeTextura == unidadeTextura) &&
            (identical(other.cascalho, cascalho) ||
                other.cascalho == cascalho) &&
            (identical(other.areiaGrossa, areiaGrossa) ||
                other.areiaGrossa == areiaGrossa) &&
            (identical(other.areiaFina, areiaFina) ||
                other.areiaFina == areiaFina) &&
            (identical(other.co, co) || other.co == co) &&
            (identical(other.municipio, municipio) ||
                other.municipio == municipio) &&
            (identical(other.responsavelTecnico, responsavelTecnico) ||
                other.responsavelTecnico == responsavelTecnico) &&
            (identical(other.cnpjCliente, cnpjCliente) ||
                other.cnpjCliente == cnpjCliente) &&
            (identical(other.pTotal, pTotal) || other.pTotal == pTotal) &&
            (identical(other.classificacaoTextura, classificacaoTextura) ||
                other.classificacaoTextura == classificacaoTextura) &&
            (identical(other.tipoSoloMapa, tipoSoloMapa) ||
                other.tipoSoloMapa == tipoSoloMapa) &&
            (identical(other.solicitante, solicitante) ||
                other.solicitante == solicitante) &&
            (identical(other.convenio, convenio) ||
                other.convenio == convenio) &&
            (identical(other.creaResponsavel, creaResponsavel) ||
                other.creaResponsavel == creaResponsavel) &&
            (identical(other.cnpjLaboratorio, cnpjLaboratorio) ||
                other.cnpjLaboratorio == cnpjLaboratorio) &&
            (identical(other.dataInicioEnsaio, dataInicioEnsaio) ||
                other.dataInicioEnsaio == dataInicioEnsaio) &&
            (identical(other.dataFimEnsaio, dataFimEnsaio) ||
                other.dataFimEnsaio == dataFimEnsaio) &&
            (identical(other.matriculaImovel, matriculaImovel) ||
                other.matriculaImovel == matriculaImovel) &&
            (identical(other.codigoInterno, codigoInterno) ||
                other.codigoInterno == codigoInterno) &&
            (identical(other.codigoExternoAmostra, codigoExternoAmostra) ||
                other.codigoExternoAmostra == codigoExternoAmostra) &&
            (identical(other.caMaisMg, caMaisMg) ||
                other.caMaisMg == caMaisMg) &&
            (identical(other.kMgDm3, kMgDm3) || other.kMgDm3 == kMgDm3) &&
            (identical(other.cuMehlich, cuMehlich) || other.cuMehlich == cuMehlich) &&
            (identical(other.feMehlich, feMehlich) || other.feMehlich == feMehlich) &&
            (identical(other.mnMehlich, mnMehlich) || other.mnMehlich == mnMehlich) &&
            (identical(other.znMehlich, znMehlich) || other.znMehlich == znMehlich) &&
            (identical(other.cuDtpa, cuDtpa) || other.cuDtpa == cuDtpa) &&
            (identical(other.feDtpa, feDtpa) || other.feDtpa == feDtpa) &&
            (identical(other.mnDtpa, mnDtpa) || other.mnDtpa == mnDtpa) &&
            (identical(other.znDtpa, znDtpa) || other.znDtpa == znDtpa) &&
            (identical(other.dataRecebimento, dataRecebimento) || other.dataRecebimento == dataRecebimento) &&
            (identical(other.numeroRelatorio, numeroRelatorio) || other.numeroRelatorio == numeroRelatorio) &&
            (identical(other.codigoVerificacao, codigoVerificacao) || other.codigoVerificacao == codigoVerificacao) &&
            (identical(other.codigoTalhao, codigoTalhao) || other.codigoTalhao == codigoTalhao) &&
            (identical(other.totalAmostras, totalAmostras) || other.totalAmostras == totalAmostras));
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
        updatedAt,
        h,
        ctcEfetiva,
        ctc,
        sb,
        vPercent,
        mPercent,
        osLaboratorio,
        dataEmissao,
        consultor,
        labTemplateId,
        unidadeNutrientes,
        unidadeMO,
        unidadeTextura,
        cascalho,
        areiaGrossa,
        areiaFina,
        co,
        municipio,
        responsavelTecnico,
        cnpjCliente,
        pTotal,
        classificacaoTextura,
        tipoSoloMapa,
        solicitante,
        convenio,
        creaResponsavel,
        cnpjLaboratorio,
        dataInicioEnsaio,
        dataFimEnsaio,
        matriculaImovel,
        codigoInterno,
        codigoExternoAmostra,
        caMaisMg,
        kMgDm3,
        cuMehlich,
        feMehlich,
        mnMehlich,
        znMehlich,
        cuDtpa,
        feDtpa,
        mnDtpa,
        znDtpa,
        dataRecebimento,
        numeroRelatorio,
        codigoVerificacao,
        codigoTalhao,
        totalAmostras
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
      @TimestampConverter() final DateTime? updatedAt,
      final double? h,
      final double? ctcEfetiva,
      final double? ctc,
      final double? sb,
      final double? vPercent,
      final double? mPercent,
      final String? osLaboratorio,
      final String? dataEmissao,
      final String? consultor,
      final String? labTemplateId,
      final String? unidadeNutrientes,
      final String? unidadeMO,
      final String? unidadeTextura,
      final double? cascalho,
      final double? areiaGrossa,
      final double? areiaFina,
      final double? co,
      final String? municipio,
      final String? responsavelTecnico,
      final String? cnpjCliente,
      final double? pTotal,
      final String? classificacaoTextura,
      final int? tipoSoloMapa,
      final String? solicitante,
      final String? convenio,
      final String? creaResponsavel,
      final String? cnpjLaboratorio,
      final String? dataInicioEnsaio,
      final String? dataFimEnsaio,
      final String? matriculaImovel,
      final String? codigoInterno,
      final String? codigoExternoAmostra,
      final double? caMaisMg,
      final double? kMgDm3,
      final double? cuMehlich,
      final double? feMehlich,
      final double? mnMehlich,
      final double? znMehlich,
      final double? cuDtpa,
      final double? feDtpa,
      final double? mnDtpa,
      final double? znDtpa,
      final String? dataRecebimento,
      final String? numeroRelatorio,
      final String? codigoVerificacao,
      final String? codigoTalhao,
      final int? totalAmostras}) = _$AnaliseModelImpl;
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
  DateTime?
      get updatedAt; // ── Acidez detalhada ───────────────────────────────────────────────────
  @override
  double? get h; // Hidrogenio puro (separado de H+Al)
  @override
  double? get ctcEfetiva; // CTC efetiva (t) = SB + Al
// ── Valores entregues pelo lab (NAO recalcular) ────────────────────────
  @override
  double? get ctc; // C.T.C. extraida do laudo
  @override
  double? get sb; // Soma de Bases extraida do laudo
  @override
  double? get vPercent; // Saturacao por Bases V% extraida do laudo
  @override
  double? get mPercent; // Saturacao por Al m% extraida do laudo
// ── Metadados do laudo ─────────────────────────────────────────────────
  @override
  String? get osLaboratorio; // Numero da O.S. do laboratorio
  @override
  String? get dataEmissao; // Data de emissao do laudo
  @override
  String? get consultor; // Empresa consultora
  @override
  String? get labTemplateId; // ID do template usado na importacao
// ── Unidades (para exibicao e conversao) ──────────────────────────────
  @override
  String? get unidadeNutrientes; // "mmolc/dm3" ou "cmolc/dm3"
  @override
  String? get unidadeMO; // "g/dm3", "dag/kg" ou "%"
  @override
  String? get unidadeTextura; // "g/kg", "g/dm3" ou "%"
// ── Textura detalhada (MB separa areia grossa/fina) ───────────────────
  @override
  double? get cascalho;
  @override
  double? get areiaGrossa;
  @override
  double?
      get areiaFina; // ── Micronutrientes adicionais ─────────────────────────────────────────
  @override
  double? get co; // Cobalto (mg/dm3) -- MB
// ── Metadados adicionais do laudo ──────────────────────────────────────
  @override
  String? get municipio;
  @override
  String? get responsavelTecnico;
  @override
  String?
      get cnpjCliente; // ── Fosforo adicional ─────────────────────────────────────────────────
  @override
  double? get pTotal; // P Total em % -- Sellar
// ── Textura adicional ─────────────────────────────────────────────
  @override
  String? get classificacaoTextura; // 'Media', 'Argilosa', 'Arenosa'
  @override
  int? get tipoSoloMapa; // Tipo MAPA (1, 2, 3) -- IN02/2008
// ── Metadados adicionais Sellar ───────────────────────────────────────
  @override
  String? get solicitante;
  @override
  String? get convenio;
  @override
  String? get creaResponsavel;
  @override
  String?
      get cnpjLaboratorio; // ── Campos Solum ──────────────────────────────────────────────────────
  @override
  String? get dataInicioEnsaio; // Data de inicio dos ensaios
  @override
  String? get dataFimEnsaio; // Data de fim dos ensaios
  @override
  String? get matriculaImovel; // Matricula do imovel (SIGEF/SNCR)
  @override
  String? get codigoInterno; // Codigo interno Solum
  @override
  String? get codigoExternoAmostra; // Codigo externo da amostra
// ── Campos Exata Brasil ───────────────────────────────────────────────
  @override
  double? get caMaisMg; // Ca+Mg somado (campo separado Exata)
  @override
  double? get kMgDm3; // K em mg/dm3 por NH4Cl (Exata)
// Micronutrientes por Mehlich I
  @override
  double? get cuMehlich; // Cobre por Mehlich
  @override
  double? get feMehlich; // Ferro por Mehlich
  @override
  double? get mnMehlich; // Manganes por Mehlich
  @override
  double? get znMehlich; // Zinco por Mehlich
// Micronutrientes por DTPA
  @override
  double? get cuDtpa; // Cobre por DTPA
  @override
  double? get feDtpa; // Ferro por DTPA
  @override
  double? get mnDtpa; // Manganes por DTPA
  @override
  double? get znDtpa; // Zinco por DTPA
// Metadados adicionais do laudo (Exata)
  @override
  String? get dataRecebimento; // Data de recebimento da amostra no lab
  @override
  String? get numeroRelatorio; // No do relatorio (ex: 16738.2025.V0.U)
  @override
  String? get codigoVerificacao; // Codigo de verificacao do laudo digital
  @override
  String? get codigoTalhao; // Codigo do talhao (T01, T02, 274)
  @override
  int? get totalAmostras;

  /// Create a copy of AnaliseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnaliseModelImplCopyWith<_$AnaliseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
